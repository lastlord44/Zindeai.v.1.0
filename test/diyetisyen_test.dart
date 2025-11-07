import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zinde_ai/data/models/kullanici_hive_model.dart';
import 'package:zinde_ai/data/models/yemek_hive_model.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/usecases/makro_hesapla.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/domain/services/diyetisyen_duzeltme_servisi.dart';
import '../lib/core/utils/app_logger.dart';
import '../lib/data/local/hive_service.dart'; // HiveService import'u eklendi
import '../lib/core/utils/yemek_migration_3000.dart'; // Migration import'u eklendi

void main() {
  late Directory tempDir;

  // Test ortamı için Hive'ı başlatma ve temizleme
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_test_diyetisyen');
    // Tüm Hive başlatma işlemleri HiveService üzerinden merkezi olarak yapılır.
    await HiveService.init(path: tempDir.path);
    // 🔥 KRİTİK: Testin çalışması için veritabanını doldur.
    AppLogger.info('Diyetisyen testi için veritabanı dolduruluyor...');
    await YemekMigration3000.yukle();
    AppLogger.info('Veritabanı dolduruldu.');
  });

  tearDownAll(() async {
    await HiveService.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  
  group('Ultra Profesyonel Diyetisyen Testleri', () {
    test('Kas Kazanma Senaryosu: Kalori hedefin altındaysa porsiyon küçültmemeli', () async {
    // 1. Test Profili Oluşturma (Doğru parametrelerle)
    final profil = KullaniciProfili(
      id: 'test_kullanici',
      ad: 'Ahmet',
      soyad: 'Yılmaz',
      yas: 25,
      cinsiyet: Cinsiyet.erkek,
      boy: 180,
      mevcutKilo: 73,
      hedefKilo: 78,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloAl,
      diyetTipi: DiyetTipi.normal, // 'standart' -> 'normal' olarak düzeltildi
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    AppLogger.info('--- TEST BAŞLADI: Ultra Profesyonel Diyetisyen Senaryosu ---');
    AppLogger.info('Profil: ${profil.ad}, Hedef: ${profil.hedef.aciklama}');

    // 2. Makro Hesaplama
    final makroHesaplayici = MakroHesapla();
    final hedefler = makroHesaplayici.tamHesaplama(profil);
    
    AppLogger.info('--- ADIM 1: Makro Hedefleri Hesaplandı ---');
    AppLogger.info('Kalori: ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal');
    AppLogger.info('Protein: ${hedefler.gunlukProtein.toStringAsFixed(0)}g');
    AppLogger.info('Karb: ${hedefler.gunlukKarbonhidrat.toStringAsFixed(0)}g');
    AppLogger.info('Yağ: ${hedefler.gunlukYag.toStringAsFixed(0)}g');

    // 3. Plan Oluşturma
    final aiServisi = AIBeslenmeServisi();
    final ilkPlan = await aiServisi.gunlukPlanOlustur(
      hedefKalori: hedefler.gunlukKalori,
      hedefProtein: hedefler.gunlukProtein,
      hedefKarb: hedefler.gunlukKarbonhidrat,
      hedefYag: hedefler.gunlukYag,
      hedef: profil.hedef,
      tarih: DateTime.now(),
    );

    AppLogger.info('--- ADIM 2: AI Beslenme Servisi Ham Planı Oluşturdu ---');
    ilkPlan.ogunler.forEach((ogun) {
      if (ogun != null) {
        AppLogger.info('${ogun.ogun.name.toUpperCase()}: ${ogun.ad} - ${ogun.kalori.toStringAsFixed(0)} kcal');
      }
    });
    AppLogger.info('Toplam: ${ilkPlan.toplamKalori.toStringAsFixed(0)} kcal, P:${ilkPlan.toplamProtein.toStringAsFixed(0)}g, K:${ilkPlan.toplamKarbonhidrat.toStringAsFixed(0)}g, Y:${ilkPlan.toplamYag.toStringAsFixed(0)}g');


    // 4. Diyetisyen Düzeltmesi
    final diyetisyenServisi = DiyetisyenDuzeltmeServisi();
    final nihaiPlan = await diyetisyenServisi.planiDuzelt(ilkPlan, profil.hedef);

    AppLogger.info('--- ADIM 3: Diyetisyen Servisi Nihai Planı Oluşturdu ---');
    // Not: DiyetisyenDuzeltmeServisi zaten kendi içinde detaylı loglama yapıyor.
    // Bu yüzden buradaki loglama basitleştirilebilir veya kaldırılabilir.
    // Ancak testin kendi çıktısını da görmek adına bırakıyoruz.
    nihaiPlan.ogunler.forEach((ogun) {
      if (ogun != null) {
        final makroStr = 'P:${ogun.protein.toStringAsFixed(0)}g, K:${ogun.karbonhidrat.toStringAsFixed(0)}g, Y:${ogun.yag.toStringAsFixed(0)}g';
        AppLogger.info('${ogun.ogun.name.toUpperCase()}: ${ogun.ad} (${ogun.kalori.toStringAsFixed(0)} kcal | $makroStr)');
        if (ogun.malzemeler.isNotEmpty) {
          AppLogger.info('   Malzemeler: ${ogun.malzemeler.join(" | ")}');
        }
      }
    });
    AppLogger.info('--- TEST SONUCU: NİHAİ PLAN ---');
    AppLogger.info('Toplam: ${nihaiPlan.toplamKalori.toStringAsFixed(0)} kcal, P:${nihaiPlan.toplamProtein.toStringAsFixed(0)}g, K:${nihaiPlan.toplamKarbonhidrat.toStringAsFixed(0)}g, Y:${nihaiPlan.toplamYag.toStringAsFixed(0)}g');
    AppLogger.info('Hedef: ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal, P:${hedefler.gunlukProtein.toStringAsFixed(0)}g, K:${hedefler.gunlukKarbonhidrat.toStringAsFixed(0)}g, Y:${hedefler.gunlukYag.toStringAsFixed(0)}g');
    AppLogger.info('--- TEST BİTTİ ---');

    expect(nihaiPlan.toplamKalori, greaterThan(1000));
    expect(nihaiPlan.ogunler.isNotEmpty, isTrue);
    // Kuralın çalıştığını doğrula: İlk plan hedefin altındaysa, düzeltilmiş planın kalorisi daha düşük olmamalı.
    if (ilkPlan.toplamKalori < hedefler.gunlukKalori) {
      expect(nihaiPlan.toplamKalori, greaterThanOrEqualTo(ilkPlan.toplamKalori), reason: "Kas kazanma hedefinde, kalori hedefin altındayken porsiyon küçültülmemeli.");
    }
  });

  test('Kilo Verme Senaryosu: Kalori fazlaysa porsiyonları akıllıca küçültmeli', () async {
    // 1. Kilo verme profili
    final profil = KullaniciProfili(
      id: 'test_kilo_ver',
      ad: 'Ayşe',
      soyad: 'Kaya',
      yas: 30,
      cinsiyet: Cinsiyet.kadin,
      boy: 165,
      mevcutKilo: 70,
      hedefKilo: 60,
      aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    AppLogger.info('--- TEST BAŞLADI: Kilo Verme Senaryosu ---');
    AppLogger.info('Profil: ${profil.ad}, Hedef: ${profil.hedef.aciklama}');

    // 2. Makro Hesaplama
    final makroHesaplayici = MakroHesapla();
    final hedefler = makroHesaplayici.tamHesaplama(profil);
    AppLogger.info('Hesaplanan Hedef Kalori: ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal');

    // 3. Kasıtlı olarak yüksek kalorili bir plan oluştur
    final ilkPlan = GunlukPlan(
      id: 'kilo_ver_test',
      tarih: DateTime.now(),
      makroHedefleri: hedefler,
      kahvalti: Yemek(id: 'k1', ad: 'Test Kahvaltı', ogun: OgunTipi.kahvalti, kalori: 800, protein: 40, karbonhidrat: 80, yag: 30, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      ogleYemegi: Yemek(id: 'o1', ad: 'Test Öğle', ogun: OgunTipi.ogle, kalori: 1000, protein: 60, karbonhidrat: 100, yag: 40, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      aksamYemegi: Yemek(id: 'a1', ad: 'Test Akşam', ogun: OgunTipi.aksam, kalori: 900, protein: 50, karbonhidrat: 90, yag: 35, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      araOgun1: null, araOgun2: null, geceAtistirma: null,
    );
    AppLogger.info('Oluşturulan Yüksek Kalorili Plan: ${ilkPlan.toplamKalori.toStringAsFixed(0)} kcal');


    // 4. Diyetisyen Düzeltmesi
    final diyetisyenServisi = DiyetisyenDuzeltmeServisi();
    final nihaiPlan = await diyetisyenServisi.planiDuzelt(ilkPlan, profil.hedef);
    AppLogger.info('Düzeltme Sonrası Nihai Plan: ${nihaiPlan.toplamKalori.toStringAsFixed(0)} kcal');

    // ASSERT
    expect(nihaiPlan.toplamKalori, lessThan(ilkPlan.toplamKalori), reason: "Kilo verme hedefinde, kalori fazlası olan planın kalorisi düşürülmeliydi.");
    expect(nihaiPlan.toplamKalori, closeTo(hedefler.gunlukKalori, hedefler.gunlukKalori * 0.15), reason: "Nihai kalori, hedefe %15 toleransla yakın olmalıydı.");
  });

  test('Formda Kalma Senaryosu: Kaloriyi hedefe yakın tutmalı', () async {
    // 1. Formda kalma profili
    final profil = KullaniciProfili(
      id: 'test_formda_kal',
      ad: 'Can',
      soyad: 'Demir',
      yas: 28,
      cinsiyet: Cinsiyet.erkek,
      boy: 178,
      mevcutKilo: 75,
      hedefKilo: 75,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.formdaKal,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    AppLogger.info('--- TEST BAŞLADI: Formda Kalma Senaryosu ---');
    AppLogger.info('Profil: ${profil.ad}, Hedef: ${profil.hedef.aciklama}');

    // 2. Makro Hesaplama
    final makroHesaplayici = MakroHesapla();
    final hedefler = makroHesaplayici.tamHesaplama(profil);
    AppLogger.info('Hesaplanan Hedef Kalori: ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal');

    // 3. Plan Oluşturma
    final aiServisi = AIBeslenmeServisi();
    final ilkPlan = await aiServisi.gunlukPlanOlustur(
      hedefKalori: hedefler.gunlukKalori,
      hedefProtein: hedefler.gunlukProtein,
      hedefKarb: hedefler.gunlukKarbonhidrat,
      hedefYag: hedefler.gunlukYag,
      hedef: profil.hedef,
      tarih: DateTime.now(),
    );

    // 4. Diyetisyen Düzeltmesi
    final diyetisyenServisi = DiyetisyenDuzeltmeServisi();
    final nihaiPlan = await diyetisyenServisi.planiDuzelt(ilkPlan, profil.hedef);
    AppLogger.info('Düzeltme Sonrası Nihai Plan: ${nihaiPlan.toplamKalori.toStringAsFixed(0)} kcal');

    // ASSERT
    expect(nihaiPlan.toplamKalori, closeTo(hedefler.gunlukKalori, hedefler.gunlukKalori * 0.10), reason: "Formda kalma hedefinde, nihai kalori hedefe %10 toleransla çok yakın olmalıydı.");
  });

  test('Kas Kazan & Kilo Ver (Recomposition) Senaryosu: Proteini koruyarak kaloriyi düşürmeli', () async {
    // 1. Recomposition profili
    final profil = KullaniciProfili(
      id: 'test_recomp',
      ad: 'Zeynep',
      soyad: 'Öz',
      yas: 27,
      cinsiyet: Cinsiyet.kadin,
      boy: 170,
      mevcutKilo: 65,
      hedefKilo: 62,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloVer,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    AppLogger.info('--- TEST BAŞLADI: Recomposition Senaryosu ---');
    AppLogger.info('Profil: ${profil.ad}, Hedef: ${profil.hedef.aciklama}');

    // 2. Makro Hesaplama
    final makroHesaplayici = MakroHesapla();
    final hedefler = makroHesaplayici.tamHesaplama(profil);
    AppLogger.info('Hesaplanan Hedef Kalori: ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal, Protein: ${hedefler.gunlukProtein.toStringAsFixed(0)}g');

    // 3. Kasıtlı olarak hedeften YÜKSEK kalorili bir plan oluştur (Düzeltme test edilecek)
    final ilkPlan = GunlukPlan(
      id: 'recomp_test',
      tarih: DateTime.now(),
      makroHedefleri: hedefler,
      kahvalti: Yemek(id: 'k1', ad: 'Yüksek Proteinli Kahvaltı', ogun: OgunTipi.kahvalti, kalori: 800, protein: 60, karbonhidrat: 50, yag: 40, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      ogleYemegi: Yemek(id: 'o1', ad: 'Düşük Proteinli Öğle', ogun: OgunTipi.ogle, kalori: 1200, protein: 40, karbonhidrat: 150, yag: 50, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      aksamYemegi: Yemek(id: 'a1', ad: 'Yüksek Proteinli Akşam', ogun: OgunTipi.aksam, kalori: 900, protein: 70, karbonhidrat: 60, yag: 45, malzemeler: [], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      araOgun1: null, araOgun2: null, geceAtistirma: null,
    );
    AppLogger.info('Oluşturulan Yüksek Kalorili Plan: ${ilkPlan.toplamKalori.toStringAsFixed(0)} kcal, Protein: ${ilkPlan.toplamProtein.toStringAsFixed(0)}g');

    // 4. Diyetisyen Düzeltmesi
    final diyetisyenServisi = DiyetisyenDuzeltmeServisi();
    final nihaiPlan = await diyetisyenServisi.planiDuzelt(ilkPlan, profil.hedef);
    AppLogger.info('Düzeltme Sonrası Nihai Plan: ${nihaiPlan.toplamKalori.toStringAsFixed(0)} kcal, Protein: ${nihaiPlan.toplamProtein.toStringAsFixed(0)}g');

    // ASSERT
    // Kalorinin düşmesini ama proteinin mümkün olduğunca korunmasını bekliyoruz.
    // Servis, en düşük proteinli öğün olan "Düşük Proteinli Öğle" yemeğini hedef almalı.
    expect(nihaiPlan.toplamKalori, lessThan(ilkPlan.toplamKalori), reason: "Kalori fazlası olan planın kalorisi düşürülmeliydi.");
    expect(nihaiPlan.toplamProtein, closeTo(ilkPlan.toplamProtein, ilkPlan.toplamProtein * 0.25), reason: "Protein mümkün olduğunca korunmalıydı, büyük bir düşüş olmamalı.");
    expect(nihaiPlan.ogleYemegi!.kalori, lessThan(800), reason: "En düşük proteinli öğün olan öğle yemeğinin kalorisi düşürülmeliydi.");
    expect(nihaiPlan.kahvalti!.kalori, greaterThanOrEqualTo(600), reason: "Yüksek proteinli kahvaltıya dokunulmamalıydı veya çok az değiştirilmeliydi.");
  });
});
}
