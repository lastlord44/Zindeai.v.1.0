import 'dart:io';
import 'package:hive/hive.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/core/utils/yemek_migration_3000.dart'; // Veritabanını doldurmak için
class TestProfile {
  final String ad;
  final double hedefKalori;
  final double hedefProtein;
  final double hedefKarb;
  final double hedefYag;
  final Hedef hedef;
  final List<String> kisitlamalar;

  TestProfile({
    required this.ad,
    required this.hedefKalori,
    required this.hedefProtein,
    required this.hedefKarb,
    required this.hedefYag,
    required this.hedef,
    this.kisitlamalar = const [],
  });
}

Future<void> main() async {
  // Standalone script için Hive kurulumu
  // Her çalıştırmada temiz bir başlangıç için geçici bir test dizini kullanalım.
  final testDir = Directory('test/hive_test_data');
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
  }
  await testDir.create(recursive: true);
  
  // HiveService.init artık Hive.init'i kendi içinde çağırıyor ve yolu zorunlu kılıyor.
  await HiveService.init(path: testDir.path);

  // 🔥 KRİTİK: Test veritabanını gerçek verilerle doldur!
  print('=' * 80);
  print('|| TEST VERİTABANI DOLDURULUYOR... ||');
  await YemekMigration3000.yukle();
  print('|| TEST VERİTABANI HAZIR! ||');
  print('=' * 80);

  final beslenmeServisi = AIBeslenmeServisi();

  final List<TestProfile> profiller = [
    TestProfile(ad: 'Zayıf Kadın (Kilo Alma)', hedefKalori: 2850, hedefProtein: 130, hedefKarb: 350, hedefYag: 90, hedef: Hedef.kiloAlmak),
    TestProfile(ad: 'Fit Erkek (Kas Kazanımı)', hedefKalori: 3200, hedefProtein: 180, hedefKarb: 380, hedefYag: 100, hedef: Hedef.kasKazanKiloAl), // DÜZELTİLDİ
    TestProfile(ad: 'Ofis Çalışanı Kadın (Kilo Verme)', hedefKalori: 1600, hedefProtein: 100, hedefKarb: 150, hedefYag: 60, hedef: Hedef.kiloVermek),
    TestProfile(ad: 'Aktif Erkek (Kilo Verme)', hedefKalori: 2200, hedefProtein: 150, hedefKarb: 220, hedefYag: 80, hedef: Hedef.kiloVermek),
    TestProfile(ad: 'Yaşlı Birey (Formu Korumak)', hedefKalori: 1800, hedefProtein: 90, hedefKarb: 200, hedefYag: 70, hedef: Hedef.formdaKal),
    TestProfile(ad: 'Performans Sporcusu', hedefKalori: 3500, hedefProtein: 200, hedefKarb: 450, hedefYag: 100, hedef: Hedef.kasKazanKiloAl), // DÜZELTİLDİ
    TestProfile(ad: 'Vegan Kadın (Kilo Koruma)', hedefKalori: 2000, hedefProtein: 80, hedefKarb: 250, hedefYag: 75, hedef: Hedef.formdaKal, kisitlamalar: ['et', 'süt', 'yumurta', 'balık']),
    TestProfile(ad: 'Glutensiz Diyet (Kilo Verme)', hedefKalori: 1700, hedefProtein: 110, hedefKarb: 160, hedefYag: 70, hedef: Hedef.kiloVermek, kisitlamalar: ['gluten']),
    TestProfile(ad: 'Standart Erkek (Kilo Koruma)', hedefKalori: 2500, hedefProtein: 140, hedefKarb: 300, hedefYag: 85, hedef: Hedef.formdaKal),
    TestProfile(ad: 'Düşük Karb Diyet', hedefKalori: 2000, hedefProtein: 150, hedefKarb: 100, hedefYag: 120, hedef: Hedef.kiloVermek),
  ];

  print('=' * 80);
  print('|| KAPSAMLI PROFİL TESTİ BAŞLATILIYOR - 10 FARKLI SENARYO ||');
  print('=' * 80);

  for (final profil in profiller) {
    print('\n' + '-' * 80);
    print('▶️ TEST EDİLİYOR: ${profil.ad}');
    print('🎯 HEDEFLER: ${profil.hedefKalori.toInt()} kcal, P:${profil.hedefProtein.toInt()}g, C:${profil.hedefKarb.toInt()}g, Y:${profil.hedefYag.toInt()}g');
    if (profil.kisitlamalar.isNotEmpty) {
      print('🚫 KISITLAMALAR: ${profil.kisitlamalar.join(', ')}');
    }
    print('-' * 80);

    try {
      final plan = await beslenmeServisi.gunlukPlanOlustur(
        hedefKalori: profil.hedefKalori,
        hedefProtein: profil.hedefProtein,
        hedefKarb: profil.hedefKarb,
        hedefYag: profil.hedefYag,
        hedef: profil.hedef,
        kisitlamalar: profil.kisitlamalar,
        tarih: DateTime.now(),
      );

      _planiYazdir(plan);

    } catch (e, s) {
      print('❌❌❌ TEST BAŞARISIZ: ${profil.ad} için plan oluşturulamadı.');
      print('Hata: $e');
      print('Stack Trace: $s');
    }
    await Future.delayed(Duration(milliseconds: 200)); // Logların karışmaması için küçük bir bekleme
  }

  print('\n' + '=' * 80);
  print('|| KAPSAMLI PROFİL TESTİ TAMAMLANDI ||');
  print('=' * 80);

  // Hive'ı kapat ve script'i sonlandır
  await HiveService.close();
  // Test dizinini temizle
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
    print("\n🧹 Test veritabanı dizini temizlendi.");
  }
  exit(0);
}

void _planiYazdir(GunlukPlan plan) {
  print('✅ PLAN OLUŞTURULDU: ${plan.tarih.toLocal().toString().substring(0, 10)}');
  print('📊 HEDEF: ${plan.makroHedefleri.gunlukKalori.toInt()} kcal | GERÇEKLEŞEN: ${plan.toplamKalori.toInt()} kcal (Sapma: ${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%)');
  print('   Protein: H:${plan.makroHedefleri.gunlukProtein.toInt()}g | G:${plan.toplamProtein.toInt()}g');
  print('   Karb:    H:${plan.makroHedefleri.gunlukKarbonhidrat.toInt()}g | G:${plan.toplamKarbonhidrat.toInt()}g');
  print('   Yağ:     H:${plan.makroHedefleri.gunlukYag.toInt()}g | G:${plan.toplamYag.toInt()}g');

  plan.ogunler.forEach((yemek) {
    print('\n  -> ${yemek.ogun.ad.toUpperCase()} - ${yemek.ad} (${yemek.kalori.toInt()} kcal)');
    // Adet kontrolü için malzemeleri yazdır
    yemek.malzemeler.forEach((malzeme) {
      if (malzeme.toLowerCase().contains('adet')) {
        print('     - $malzeme  <-- ADET KONTROLÜ');
      } else {
        print('     - $malzeme');
      }
    });
  });

  if (plan.geceAtistirma != null) {
    print('\n  ✨ GECE ATIŞTIRMA EKLENDİ (Yüksek Kalori Modu)');
  }
  if (plan.makroHedefleri.gunlukKalori < 2800 && plan.geceAtistirma == null) {
     print('\n  👍 Gece atıştırma eklenmedi (Normal Kalori Modu)');
  }
}
