import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import '../lib/core/utils/app_logger.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/data/models/kullanici_hive_model.dart';
import '../lib/data/models/gunluk_plan_hive_model.dart';
import '../lib/data/models/antrenman_hive_model.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/usecases/makro_hesapla.dart';
import '../lib/domain/usecases/ogun_planlayici.dart';
import '../lib/core/utils/yemek_migration_3000.dart'; // Migration import'u eklendi

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  // Hive'ı test ortamı için başlat
  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('stres_test_');
    // Tüm Hive başlatma işlemleri HiveService üzerinden merkezi olarak yapılır.
    await HiveService.init(path: tempDir.path);
    // 🔥 KRİTİK: Testin çalışması için veritabanını doldur.
    AppLogger.info('Haftalık stres testi için veritabanı dolduruluyor...');
    await YemekMigration3000.yukle();
    AppLogger.info('Veritabanı dolduruldu.');
  });

  tearDownAll(() async {
    await HiveService.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('HAFTALIK STRES TESTİ: 50 FARKLI DİNAMİK PROFİL', () async {
    final random = Random();
    final makroHesaplayici = MakroHesapla();
    final planlayici = OgunPlanlayici();
    const profilSayisi = 50;
    
    List<KullaniciProfili> profiller = [];

    // 1. 50 Adet Dinamik Profil Oluştur
    for (int i = 0; i < profilSayisi; i++) {
      final cinsiyet = Cinsiyet.values[random.nextInt(Cinsiyet.values.length)];
      final boy = 155 + random.nextInt(45); // 155-200 cm
      final mevcutKilo = 50 + random.nextInt(70); // 50-120 kg
      final hedef = Hedef.values[random.nextInt(Hedef.values.length)];
      
      double hedefKilo;
      if (hedef == Hedef.kiloAlmak || hedef == Hedef.kasKazanKiloAl) {
        hedefKilo = mevcutKilo.toDouble() + 5 + random.nextInt(10);
      } else if (hedef == Hedef.kiloVermek) {
        hedefKilo = mevcutKilo.toDouble() - 5 - random.nextInt(10);
      } else {
        hedefKilo = mevcutKilo.toDouble();
      }

      profiller.add(KullaniciProfili(
        id: 'stres_test_profil_$i',
        ad: 'Kullanıcı',
        soyad: '$i',
        yas: 18 + random.nextInt(42), // 18-60 yaş
        cinsiyet: cinsiyet,
        boy: boy.toDouble(),
        mevcutKilo: mevcutKilo.toDouble(),
        hedefKilo: hedefKilo,
        aktiviteSeviyesi: AktiviteSeviyesi.values[random.nextInt(AktiviteSeviyesi.values.length)],
        hedef: hedef,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
      ));
    }

    AppLogger.info('--- HAFTALIK STRES TESTİ BAŞLADI: $profilSayisi FARKLI PROFİL ---');

    int basariliProfil = 0;
    List<String> basarisizProfilRaporlari = [];

    // 2. Her Profil İçin Haftalık Plan Oluştur ve Doğrula
    for (var i = 0; i < profiller.length; i++) {
      final profil = profiller[i];
      AppLogger.info('--- Profil ${i + 1}/$profilSayisi İşleniyor: ${profil.hedef.aciklama} (${profil.cinsiyet.name}, ${profil.yas} yaş, ${profil.mevcutKilo}kg -> ${profil.hedefKilo}kg) ---');
      
      final hedefler = makroHesaplayici.tamHesaplama(profil);
      final baslangicTarihi = DateTime.now();
      List<GunlukPlan> haftalikPlan = [];
      bool profilBasarili = true;

      try {
        // Haftalık planı oluştur
        for (int gun = 0; gun < 7; gun++) {
          final planGunu = baslangicTarihi.add(Duration(days: gun));
          final gunlukPlan = await planlayici.gunlukPlanOlustur(
            hedefKalori: hedefler.gunlukKalori,
            hedefProtein: hedefler.gunlukProtein,
            hedefKarb: hedefler.gunlukKarbonhidrat,
            hedefYag: hedefler.gunlukYag,
            hedef: profil.hedef,
            kisitlamalar: profil.tumKisitlamalar,
            tarih: planGunu,
          );
          haftalikPlan.add(gunlukPlan);
        }

        // 3. Doğrulama Adımları
        // a) Çeşitlilik Kontrolü
        final anaOgunler = haftalikPlan.expand((plan) => [plan.ogleYemegi?.ad, plan.aksamYemegi?.ad]).where((ad) => ad != null).toList();
        final benzersizAnaOgunSayisi = anaOgunler.toSet().length;
        final cesitlilikOrani = (benzersizAnaOgunSayisi / anaOgunler.length) * 100;
        
        expect(cesitlilikOrani, greaterThan(50), reason: 'Profil ${i+1}: Haftalık ana öğün çeşitliliği çok düşük (${cesitlilikOrani.toStringAsFixed(1)}%).');

        // b) Hedefe Uygunluk Kontrolü
        for (final gunlukPlan in haftalikPlan) {
          if (profil.hedef == Hedef.kiloAlmak || profil.hedef == Hedef.kasKazanKiloAl) {
            expect(gunlukPlan.toplamKalori, greaterThanOrEqualTo(hedefler.gunlukKalori * 0.90), reason: 'Profil ${i+1}: Kilo alma hedefinde kalori hedefin çok altında kalmamalı.');
          }
          if (profil.hedef == Hedef.kiloVermek) {
            expect(gunlukPlan.toplamKalori, lessThanOrEqualTo(hedefler.gunlukKalori * 1.15), reason: 'Profil ${i+1}: Kilo verme hedefinde kalori hedefi çok fazla aşmamalı.');
          }
        }
        
        basariliProfil++;
        AppLogger.success('✅ Profil ${i + 1} testi geçti. Çeşitlilik: ${cesitlilikOrani.toStringAsFixed(1)}%');

      } catch (e) {
        profilBasarili = false;
        final rapor = '❌ Profil ${i + 1} (${profil.hedef.aciklama}) BAŞARISIZ: $e';
        basarisizProfilRaporlari.add(rapor);
        AppLogger.error(rapor);
      }
    }

    // 4. Final Raporu
    AppLogger.info('--- HAFTALIK STRES TESTİ TAMAMLANDI ---');
    AppLogger.success('✅ Başarılı Profil Sayısı: $basariliProfil / $profilSayisi');
    
    if (basarisizProfilRaporlari.isNotEmpty) {
      AppLogger.error('❌ Başarısız Profil Raporları:');
      basarisizProfilRaporlari.forEach(AppLogger.error);
    }

    expect(basarisizProfilRaporlari.isEmpty, isTrue, reason: 'Stres testinde ${basarisizProfilRaporlari.length} profil başarısız oldu.');

  }, timeout: const Timeout(Duration(minutes: 10))); // Testin uzun sürebileceğini belirt
}
