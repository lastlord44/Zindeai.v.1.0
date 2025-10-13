// 500 YENİ SAĞLIKLI YEMEK MİGRATION
// Dart batch dosyalarından Hive DB'ye yükleme

import 'package:hive/hive.dart';
import '../../data/models/yemek_hive_model.dart';
import '../utils/app_logger.dart';
import '../../mega_yemek_batch_20_kahvalti_saglikli.dart';
import '../../mega_yemek_batch_21_ogle_saglikli.dart';
import '../../mega_yemek_batch_22_aksam_saglikli.dart';
import '../../mega_yemek_batch_23_ara_ogun_1.dart';
import '../../mega_yemek_batch_24_29_ara_ogun_2.dart';

class Yemek500Migration {
  /// Migration gerekli mi kontrol et (500 yeni yemeğin ID'lerini kontrol eder)
  static Future<bool> migrationGerekliMi() async {
    try {
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      
      // 500 yeni yemekten örnek ID'leri kontrol et
      // K951 (kahvaltı), O1001 (öğle), A1001 (akşam), AO1_1001 (ara1), AO2_1001 (ara2)
      final ornekIDler = ['K951', 'O1001', 'A1001', 'AO1_1001', 'AO2_1001'];
      
      for (final id in ornekIDler) {
        if (!box.containsKey(id)) {
          AppLogger.info('🔍 500 yeni yemek migration gerekli: $id bulunamadı');
          return true; // En az biri yoksa migration gerekli
        }
      }
      
      AppLogger.debug('✅ 500 yeni yemek zaten yüklü, migration atlandı');
      return false; // Hepsi varsa zaten yüklü
    } catch (e) {
      AppLogger.error('Migration kontrolü hatası', error: e);
      return true; // Hata varsa migration yap
    }
  }

  /// 500 yeni yemek migration
  static Future<bool> migrate500NewMeals() async {
    try {
      AppLogger.info('🚀 500 YENİ YEMEK MİGRATION BAŞLIYOR...');
      
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      final baslangicSayisi = box.length;
      
      int yuklenen = 0;
      
      // BATCH 20: Kahvaltı
      try {
        final batch20 = getMegaYemekBatch20();
        for (var jsonYemek in batch20) {
          final yemek = YemekHiveModel.fromJson(jsonYemek);
          await box.put(yemek.mealId, yemek);
          yuklenen++;
        }
        AppLogger.info('✅ Batch 20 (Kahvaltı): ${batch20.length} yemek');
      } catch (e) {
        AppLogger.warning('⚠️ Batch 20 hatası: $e');
      }
      
      // BATCH 21: Öğle
      try {
        final batch21 = getMegaYemekBatch21();
        for (var jsonYemek in batch21) {
          final yemek = YemekHiveModel.fromJson(jsonYemek);
          await box.put(yemek.mealId, yemek);
          yuklenen++;
        }
        AppLogger.info('✅ Batch 21 (Öğle): ${batch21.length} yemek');
      } catch (e) {
        AppLogger.warning('⚠️ Batch 21 hatası: $e');
      }
      
      // BATCH 22: Akşam
      try {
        final batch22 = getMegaYemekBatch22();
        for (var jsonYemek in batch22) {
          final yemek = YemekHiveModel.fromJson(jsonYemek);
          await box.put(yemek.mealId, yemek);
          yuklenen++;
        }
        AppLogger.info('✅ Batch 22 (Akşam): ${batch22.length} yemek');
      } catch (e) {
        AppLogger.warning('⚠️ Batch 22 hatası: $e');
      }
      
      // BATCH 23: Ara Öğün 1
      try {
        final batch23 = getMegaYemekBatch23();
        for (var jsonYemek in batch23) {
          final yemek = YemekHiveModel.fromJson(jsonYemek);
          await box.put(yemek.mealId, yemek);
          yuklenen++;
        }
        AppLogger.info('✅ Batch 23 (Ara Öğün 1): ${batch23.length} yemek');
      } catch (e) {
        AppLogger.warning('⚠️ Batch 23 hatası: $e');
      }
      
      // BATCH 24-29: Ara Öğün 2 (300 yemek)
      try {
        final batch24_29 = getMegaYemekBatch24_29();
        for (var jsonYemek in batch24_29) {
          final yemek = YemekHiveModel.fromJson(jsonYemek);
          await box.put(yemek.mealId, yemek);
          yuklenen++;
        }
        AppLogger.info('✅ Batch 24-29 (Ara Öğün 2): ${batch24_29.length} yemek');
      } catch (e) {
        AppLogger.warning('⚠️ Batch 24-29 hatası: $e');
      }
      
      final bitisSayisi = box.length;
      
      AppLogger.info('═══════════════════════════════════════════');
      AppLogger.info('🎉 500 YENİ YEMEK MİGRATION TAMAMLANDI!');
      AppLogger.info('📈 Önceki yemek sayısı: $baslangicSayisi');
      AppLogger.info('📈 Yeni yemek sayısı: $bitisSayisi');
      AppLogger.info('➕ Eklenen toplam: $yuklenen yemek');
      AppLogger.info('═══════════════════════════════════════════');
      
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
