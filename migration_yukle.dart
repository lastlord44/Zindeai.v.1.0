// ============================================================================
// MİGRATION YÜKLE - FLUTTER TEST RUNNER İLE ÇALIŞIR
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() {
  test('Hive DB temizle ve yeni yemekleri yükle', () async {
    // Hive'ı başlat
    await Hive.initFlutter();

    // Adapterleri kaydet
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(KullaniciHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
    }

    // Box'ları aç
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemekBox');
    final planBox = await Hive.openBox<GunlukPlanHiveModel>('gunlukPlanBox');

    print('📊 ÖNCEKİ DURUM:');
    print('  - Yemekler: ${yemekBox.length}');

    // SADECE YEMEK VE PLANLARI TEMİZLE
    print('🗑️ Temizleniyor...');
    await yemekBox.clear();
    await planBox.clear();
    print('✅ Temizlendi!');

    // YENİ MİGRATION ÇALIŞTIR
    print('🚀 Yeni yemekler yükleniyor...');
    print('📂 Dosyalar:');
    print('   - zindeai_kahvalti_300.json');
    print('   - kahvalti_batch_01.json');
    print('   - kahvalti_batch_02.json');
    print('   - zindeai_ogle_300.json');
    print('   - ogle_yemegi_batch_01.json');
    print('   - ogle_yemegi_batch_02.json');
    print('   - zindeai_aksam_300.json');
    print('   - aksam_combo_450.json');
    print('   - aksam_yemekbalık_150.json');
    print('   - aksam_yemekleri_150_kofte_kiyma_kusbasi_haslama.json');
    print('   - aksam_yemegi_batch_01.json');
    print('   - aksam_yemegi_batch_02.json');
    print('   - ara_ogun_1_batch_01.json');
    print('   - ara_ogun_1_batch_02.json');
    print('   - ara_ogun_2_batch_01.json');
    print('   - ara_ogun_2_batch_02.json');
    print('   - ara_ogun_toplu_120.json');
    print('   - cheat_meal.json');
    print('   - gece_atistirmasi.json');

    final success = await YemekMigration.jsonToHiveMigration();

    print('📊 YENİ DURUM:');
    print('  - Yemekler: ${yemekBox.length}');

    if (success && yemekBox.length > 0) {
      print('✅ ✅ ✅ BAŞARILI! ✅ ✅ ✅');
      print('🎉 ${yemekBox.length} yemek başarıyla yüklendi!');
      
      // Kategori bazında breakdown
      final allMeals = yemekBox.values.toList();
      final kahvalti = allMeals.where((m) => m.category == 'kahvalti').length;
      final ogle = allMeals.where((m) => m.category == 'ogle').length;
      final aksam = allMeals.where((m) => m.category == 'aksam').length;
      final araOgun1 = allMeals.where((m) => m.category == 'ara_ogun_1').length;
      final araOgun2 = allMeals.where((m) => m.category == 'ara_ogun_2').length;
      final cheat = allMeals.where((m) => m.category == 'cheat_meal').length;
      final gece = allMeals.where((m) => m.category == 'gece_atistirmasi').length;
      
      print('📊 KATEGORİ BAZINDA:');
      print('  - Kahvaltı: $kahvalti');
      print('  - Öğle: $ogle');
      print('  - Akşam: $aksam');
      print('  - Ara Öğün 1: $araOgun1');
      print('  - Ara Öğün 2: $araOgun2');
      print('  - Cheat Meal: $cheat');
      print('  - Gece Atıştırması: $gece');
    } else {
      print('❌ SORUN VAR!');
      print('Success: $success');
      print('Yemek sayısı: ${yemekBox.length}');
    }

    // Test assertion
    expect(success, true, reason: 'Migration başarısız oldu');
    expect(yemekBox.length, greaterThan(0), reason: 'Hiç yemek yüklenmedi!');

    print('✅ Migration tamamlandı!');
  });
}
