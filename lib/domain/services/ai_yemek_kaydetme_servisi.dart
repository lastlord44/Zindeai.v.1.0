// ============================================================================
// lib/domain/services/ai_yemek_kaydetme_servisi.dart
// AI'DAN GELEN YEMEKLERİ HIVE DB'YE OTOMATİK KAYDETME SERVİSİ
// ============================================================================

import '../../core/utils/app_logger.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/yemek_hive_model.dart';
import '../entities/yemek.dart';
import '../entities/gunluk_plan.dart';

/// AI'dan gelen yemekleri Hive DB'ye otomatik kaydeden servis
class AIYemekKaydetmeServisi {
  /// Tek bir yemeği DB'ye kaydet
  static Future<bool> yemekKaydet(Yemek yemek) async {
    try {
      AppLogger.info('🤖 AI Yemek DB\'ye kaydediliyor: ${yemek.ad}');
      
      // Yemek entity'sini Hive modele çevir
      final hiveModel = YemekHiveModel.fromEntity(yemek);
      
      // DB'ye kaydet
      await HiveService.yemekKaydet(hiveModel);
      
      AppLogger.success('✅ AI Yemek DB\'ye kaydedildi: ${yemek.ad} (${yemek.kalori.toStringAsFixed(0)} kcal)');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Yemek kaydetme hatası: ${yemek.ad}', 
        error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Günlük plandaki tüm yemekleri DB'ye kaydet
  static Future<Map<String, bool>> gunlukPlanYemekleriKaydet(GunlukPlan plan) async {
    try {
      AppLogger.info('🤖 Günlük plan yemekleri DB\'ye kaydediliyor... (${plan.ogunler.length} öğün)');
      
      final sonuclar = <String, bool>{};
      int basariliSayisi = 0;
      
      for (final yemek in plan.ogunler) {
        final basarili = await yemekKaydet(yemek);
        sonuclar[yemek.id] = basarili;
        if (basarili) basariliSayisi++;
      }
      
      AppLogger.success('✅ ${basariliSayisi}/${plan.ogunler.length} AI yemek DB\'ye kaydedildi');
      return sonuclar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Günlük plan yemekleri kaydetme hatası', 
        error: e, stackTrace: stackTrace);
      return {};
    }
  }
  
  /// Haftalık plandaki tüm yemekleri DB'ye kaydet
  static Future<Map<String, int>> haftalikPlanYemekleriKaydet(List<GunlukPlan> haftalikPlan) async {
    try {
      AppLogger.info('🤖 Haftalık plan yemekleri DB\'ye kaydediliyor... (${haftalikPlan.length} gün)');
      
      int toplamYemek = 0;
      int basariliYemek = 0;
      int hataliYemek = 0;
      
      for (int gun = 0; gun < haftalikPlan.length; gun++) {
        final plan = haftalikPlan[gun];
        AppLogger.info('   📅 Gün ${gun + 1}/7: ${plan.ogunler.length} öğün kaydediliyor...');
        
        final sonuclar = await gunlukPlanYemekleriKaydet(plan);
        
        toplamYemek += plan.ogunler.length;
        basariliYemek += sonuclar.values.where((b) => b).length;
        hataliYemek += sonuclar.values.where((b) => !b).length;
      }
      
      AppLogger.success('✅ Haftalık plan kaydı tamamlandı: ${basariliYemek}/${toplamYemek} yemek başarılı');
      
      return {
        'toplam': toplamYemek,
        'basarili': basariliYemek,
        'hatali': hataliYemek,
      };
    } catch (e, stackTrace) {
      AppLogger.error('❌ Haftalık plan yemekleri kaydetme hatası', 
        error: e, stackTrace: stackTrace);
      return {
        'toplam': 0,
        'basarili': 0,
        'hatali': 0,
      };
    }
  }
  
  /// Yemeği favorilere ekle (AI'dan gelen yemekleri kullanıcı beğendiyse)
  static Future<bool> yemekFavoriyeEkle(String yemekId) async {
    try {
      await HiveService.favoriyeEkle(yemekId);
      AppLogger.success('⭐ AI Yemek favorilere eklendi: $yemekId');
      return true;
    } catch (e) {
      AppLogger.error('❌ Favoriye ekleme hatası: $yemekId', error: e);
      return false;
    }
  }
  
  /// DB'de aynı yemek var mı kontrol et (duplikasyon önleme)
  static Future<bool> yemekVarMi(String yemekId) async {
    try {
      final yemek = await HiveService.yemekGetir(yemekId);
      return yemek != null;
    } catch (e) {
      AppLogger.error('❌ Yemek kontrol hatası: $yemekId', error: e);
      return false;
    }
  }
  
  /// AI yemeklerini toplu olarak kaydet (duplikasyon kontrolü ile)
  static Future<Map<String, dynamic>> topluYemekKaydet(
    List<Yemek> yemekler, {
    bool duplikasyonKontrol = true,
  }) async {
    try {
      AppLogger.info('🤖 Toplu AI yemek kaydı başlıyor... (${yemekler.length} yemek)');
      
      int yeniYemek = 0;
      int mevcutYemek = 0;
      int hataliYemek = 0;
      final kaydedilenYemekler = <String>[];
      
      for (final yemek in yemekler) {
        // Duplikasyon kontrolü (opsiyonel)
        if (duplikasyonKontrol) {
          final mevcut = await yemekVarMi(yemek.id);
          if (mevcut) {
            mevcutYemek++;
            AppLogger.debug('⚠️ Yemek zaten var, atlanıyor: ${yemek.ad}');
            continue;
          }
        }
        
        // Yeni yemek kaydet
        final basarili = await yemekKaydet(yemek);
        if (basarili) {
          yeniYemek++;
          kaydedilenYemekler.add(yemek.id);
        } else {
          hataliYemek++;
        }
      }
      
      AppLogger.success('✅ Toplu kayıt tamamlandı: ${yeniYemek} yeni, ${mevcutYemek} mevcut, ${hataliYemek} hatalı');
      
      return {
        'toplam': yemekler.length,
        'yeni': yeniYemek,
        'mevcut': mevcutYemek,
        'hatali': hataliYemek,
        'kaydedilenler': kaydedilenYemekler,
      };
    } catch (e, stackTrace) {
      AppLogger.error('❌ Toplu yemek kaydetme hatası', 
        error: e, stackTrace: stackTrace);
      return {
        'toplam': 0,
        'yeni': 0,
        'mevcut': 0,
        'hatali': yemekler.length,
        'kaydedilenler': <String>[],
      };
    }
  }
}