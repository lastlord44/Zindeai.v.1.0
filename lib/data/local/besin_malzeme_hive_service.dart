
// lib/data/local/besin_malzeme_hive_service.dart
// Besin malzemelerini asset'lerden yükleyen ve Hive'da cache'leyen servis

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../../domain/entities/besin_malzeme.dart';
import '../../core/utils/app_logger.dart';

class BesinMalzemeHiveService {
  static const _boxName = 'besin_malzeme_box';
  static const _keyAllBesinler = 'all_besinler_json';
  static const _keyIsLoaded = 'is_loaded';
  
  // 20 batch dosyasının listesi
  static const _batchFiles = [
    'assets/data/hive_db/besin_malzemeleri_200.json',
    'assets/data/hive_db/besin_malzemeleri_batch2_200.json',
    'assets/data/hive_db/besin_malzemeleri_batch2_0201_0400.json',
    'assets/data/hive_db/besin_malzemeleri_batch3_0401_0600.json',
    'assets/data/hive_db/besin_malzemeleri_batch4_0601_0800.json',
    'assets/data/hive_db/besin_malzemeleri_batch5_0801_1000.json',
    'assets/data/hive_db/besin_malzemeleri_batch6_1001_1200.json',
    'assets/data/hive_db/besin_malzemeleri_batch7_1201_1400_karbonhidrat_set3.json',
    'assets/data/hive_db/besin_malzemeleri_batch8_1401_1600_karbonhidrat_set4.json',
    'assets/data/hive_db/besin_malzemeleri_batch9_1601_1800_yag_sut_set1.json',
    'assets/data/hive_db/besin_malzemeleri_batch10_1801_2000_yag_sut_set2.json',
    'assets/data/hive_db/besin_malzemeleri_batch11_2001_2200_yag_sut_set3.json',
    'assets/data/hive_db/besin_malzemeleri_batch12_2201_2400_yag_sut_set4.json',
    'assets/data/hive_db/besin_malzemeleri_batch13_2401_2600_sebze_set1.json',
    'assets/data/hive_db/besin_malzemeleri_batch14_2601_2800_sebze_set2.json',
    'assets/data/hive_db/besin_malzemeleri_batch15_2801_3000_sebze_set3.json',
    'assets/data/hive_db/besin_malzemeleri_batch16_3001_3200_sebze_set4.json',
    'assets/data/hive_db/besin_malzemeleri_batch17_3201_3400_meyve_set1.json',
    'assets/data/hive_db/besin_malzemeleri_batch18_3401_3600_meyve_set2.json',
    'assets/data/hive_db/besin_malzemeleri_batch19_3601_3800_trend_modern_set1.json',
    'assets/data/hive_db/besin_malzemeleri_batch20_3801_4000_trend_modern_set2.json',
  ];

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Tüm besin malzemelerini getir - İlk çağrıda otomatik yükler
  Future<List<BesinMalzeme>> getAll() async {
    await init();
    final box = Hive.box(_boxName);
    
    // Eğer daha önce yüklenmemişse, şimdi yükle
    final isLoaded = box.get(_keyIsLoaded, defaultValue: false);
    if (!isLoaded) {
      AppLogger.info('🔄 Besin malzemeleri ilk kez yükleniyor...');
      await _loadAllBesinlerFromAssets();
    }
    
    // Cache'den getir
    final raw = box.get(_keyAllBesinler);
    if (raw is String) {
      final besinler = BesinMalzeme.listFromJsonString(raw);
      AppLogger.debug('✅ ${besinler.length} besin malzemesi cache\'den getirildi');
      return besinler;
    }
    
    return [];
  }

  /// Tüm besin malzemelerini asset'lerden yükle ve birleştir
  Future<void> _loadAllBesinlerFromAssets() async {
    try {
      final box = Hive.box(_boxName);
      final tumBesinler = <Map<String, dynamic>>[];
      int toplamYuklenen = 0;
      
      AppLogger.info('📦 20 batch dosyası yükleniyor...');
      
      for (int i = 0; i < _batchFiles.length; i++) {
        try {
          final dosyaYolu = _batchFiles[i];
          final jsonString = await rootBundle.loadString(dosyaYolu);
          final List<dynamic> besinListesi = json.decode(jsonString);
          
          tumBesinler.addAll(besinListesi.cast<Map<String, dynamic>>());
          toplamYuklenen += besinListesi.length;
          
          AppLogger.debug('   ✅ Batch ${i + 1}/20: ${besinListesi.length} besin (Toplam: $toplamYuklenen)');
        } catch (e) {
          AppLogger.warning('   ⚠️ Batch ${i + 1} yüklenemedi: $e');
        }
      }
      
      // Tüm besinleri JSON string olarak cache'e kaydet
      final tumBesinlerJson = json.encode(tumBesinler);
      await box.put(_keyAllBesinler, tumBesinlerJson);
      await box.put(_keyIsLoaded, true);
      
      AppLogger.success('✅ Toplam $toplamYuklenen besin malzemesi başarıyla yüklendi ve cache\'lendi!');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Besin malzemeleri yüklenirken hata', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Cache'i temizle (debug için)
  Future<void> clearCache() async {
    await init();
    final box = Hive.box(_boxName);
    await box.clear();
    AppLogger.info('🗑️ Besin malzemesi cache\'i temizlendi');
  }

  /// Yeniden yükle (cache'i temizle ve tekrar yükle)
  Future<void> reload() async {
    await clearCache();
    await getAll();
  }
  
  // Geriye dönük uyumluluk için eski metodları koru
  Future<List<BesinMalzeme>> loadFromAssetsOnce(String assetPath) async {
    return await getAll();
  }

  Future<void> replaceWithJsonString(String jsonString) async {
    await init();
    final box = Hive.box(_boxName);
    await box.put(_keyAllBesinler, jsonString);
    await box.put(_keyIsLoaded, true);
  }
}
