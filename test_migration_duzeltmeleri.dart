// ============================================================================
// test_migration_duzeltmeleri.dart
// TÜM DÜZELTMELERİ TEST ET
// ============================================================================

import 'dart:async';
import 'lib/core/utils/app_logger.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/entities/makro_hedefleri.dart';
import 'lib/domain/entities/gunluk_plan.dart';
import 'lib/domain/usecases/ogun_planlayici.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';

void main() async {
  print('🧪 === TÜM DÜZELTMELERİ TEST ET ===');
  
  try {
    // 1. Hive başlat
    print('📦 Hive başlatılıyor...');
    await HiveService.init();
    
    // 2. Migration kontrolü
    print('\n🔄 Migration durumu kontrol ediliyor...');
    final migrationGerekli = await YemekMigration.migrationGerekliMi();
    print('Migration gerekli mi: $migrationGerekli');
    
    if (migrationGerekli) {
      print('🔄 Migration başlatılıyor...');
      final success = await YemekMigration.jsonToHiveMigration();
      if (success) {
        print('✅ Migration başarıyla tamamlandı!');
      } else {
        print('❌ Migration başarısız!');
        return;
      }
    }
    
    // 3. DB durumunu kontrol et
    print('\n📊 === VERİTABANI DURUMU ===');
    final yemekSayisi = await HiveService.yemekSayisi();
    final kategoriSayilari = await HiveService.kategoriSayilari();
    
    print('Toplam yemek sayısı: $yemekSayisi');
    print('Kategori dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('  $kategori: $sayi yemek');
    });
    
    // 4. Ara Öğün 2 testi
    print('\n🥪 === ARA ÖĞÜN 2 TESTİ ===');
    final araOgun2Yemekler = await HiveService.kategoriYemekleriGetir('Ara Öğün 2');
    print('Ara Öğün 2 yemek sayısı: ${araOgun2Yemekler.length}');
    if (araOgun2Yemekler.isNotEmpty) {
      print('✅ Ara Öğün 2 sorunu çözüldü!');
      print('Örnek yemekler:');
      for (int i = 0; i < (araOgun2Yemekler.length > 3 ? 3 : araOgun2Yemekler.length); i++) {
        print('  - ${araOgun2Yemekler[i].ad}');
      }
    } else {
      print('❌ Ara Öğün 2 sorunu devam ediyor!');
    }
    
    // 5. PAD ön eki testi
    print('\n🏷️ === PAD ÖN EKİ TESTİ ===');
    final tumYemekler = await HiveService.tumYemekleriGetir();
    final padOluYemekler = tumYemekler.where((y) => y.ad.startsWith('PAD ')).toList();
    print('PAD ön eki bulunan yemek sayısı: ${padOluYemekler.length}');
    if (padOluYemekler.isEmpty) {
      print('✅ PAD ön eki başarıyla temizlendi!');
    } else {
      print('❌ PAD ön eki temizlenmedi!');
      print('Örnek PAD ön ekli yemekler:');
      for (int i = 0; i < (padOluYemekler.length > 3 ? 3 : padOluYemekler.length); i++) {
        print('  - ${padOluYemekler[i].ad}');
      }
    }
    
    // 6. Protein filtresi testi
    print('\n🍖 === PROTEİN FİLTRESİ TESTİ ===');
    final kahvaltiYemekleri = await HiveService.kategoriYemekleriGetir('Kahvaltı');
    final proteinKaynaklari = ['balık', 'balik', 'tavuk', 'dana', 'hindi', 'somon'];
    final kahvaltidaProtein = kahvaltiYemekleri.where((y) {
      final mealName = y.ad.toLowerCase();
      return proteinKaynaklari.any((p) => mealName.contains(p));
    }).toList();
    
    print('Kahvaltı kategorisindeki protein yemekleri: ${kahvaltidaProtein.length}');
    if (kahvaltidaProtein.isEmpty) {
      print('✅ Protein filtresi çalışıyor! Kahvaltıda protein yemeği yok.');
    } else {
      print('⚠️ Kahvaltıda protein yemeği bulundu:');
      for (int i = 0; i < (kahvaltidaProtein.length > 3 ? 3 : kahvaltidaProtein.length); i++) {
        print('  - ${kahvaltidaProtein[i].ad}');
      }
    }
    
    // 7. Tolerans değerleri testi
    print('\n📏 === TOLERANS DEĞERLERİ TESTİ ===');
    print('GunlukPlan tolerans değerleri:');
    print('  Kalori: ${GunlukPlan.kaloriToleransYuzdesi}% (hedef: 15%)');
    print('  Protein: ${GunlukPlan.proteinToleransYuzdesi}% (hedef: 10%)');
    print('  Karbonhidrat: ${GunlukPlan.karbonhidratToleransYuzdesi}% (hedef: 10%)');
    print('  Yağ: ${GunlukPlan.yagToleransYuzdesi}% (hedef: 10%)');
    
    final toleransOK = GunlukPlan.kaloriToleransYuzdesi == 15.0 &&
                      GunlukPlan.proteinToleransYuzdesi == 10.0 &&
                      GunlukPlan.karbonhidratToleransYuzdesi == 10.0 &&
                      GunlukPlan.yagToleransYuzdesi == 10.0;
    
    if (toleransOK) {
      print('✅ Tolerans değerleri doğru!');
    } else {
      print('❌ Tolerans değerleri yanlış!');
    }
    
    // 8. Plan oluşturma testi
    print('\n📋 === PLAN OLUŞTURMA TESTİ ===');
    final makroHedefleri = MakroHedefleri(
      gunlukKalori: 1800,
      gunlukProtein: 120,
      gunlukKarbonhidrat: 200,
      gunlukYag: 60,
    );
    
    final dataSource = YemekHiveDataSource();
    final ogunPlanlayici = OgunPlanlayici(dataSource: dataSource);
    final plan = await ogunPlanlayici.gunlukPlanOlustur(
      hedefKalori: makroHedefleri.gunlukKalori,
      hedefProtein: makroHedefleri.gunlukProtein,
      hedefKarb: makroHedefleri.gunlukKarbonhidrat,
      hedefYag: makroHedefleri.gunlukYag,
      tarih: DateTime.now(),
    );
    
    if (plan != null) {
      print('✅ Plan başarıyla oluşturuldu!');
      print('Öğünler:');
      print('  Kahvaltı: ${plan.kahvalti?.ad ?? 'YOK'}');
      print('  Ara Öğün 1: ${plan.araOgun1?.ad ?? 'YOK'}');
      print('  Öğle: ${plan.ogleYemegi?.ad ?? 'YOK'}');
      print('  Ara Öğün 2: ${plan.araOgun2?.ad ?? 'YOK'}');
      print('  Akşam: ${plan.aksamYemegi?.ad ?? 'YOK'}');
      
      print('\nTolerans kontrolü:');
      print('  Kalori toleransta mı: ${plan.kaloriToleranstaMi}');
      print('  Protein toleransta mı: ${plan.proteinToleranstaMi}');
      print('  Karb toleransta mı: ${plan.karbonhidratToleranstaMi}');
      print('  Yağ toleransta mı: ${plan.yagToleranstaMi}');
      print('  Tüm makrolar toleransta mı: ${plan.tumMakrolarToleranstaMi}');
    } else {
      print('❌ Plan oluşturulamadı!');
    }
    
    print('\n🎉 === TEST TAMAMLANDI ===');
    
  } catch (e, stackTrace) {
    print('❌ Test hatası: $e');
    print('StackTrace: $stackTrace');
  }
}