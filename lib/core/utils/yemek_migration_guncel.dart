// ============================================================================
// lib/core/utils/yemek_migration_guncel.dart
// JSON dosyalarından Hive'a yemek verilerini migration (GÜNCEL)
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';

class YemekMigration {
  // 🆕 YENİ JSON DOSYA LİSTESİ (tüm kategoriler + SONMEALLER!)
  static const List<String> _jsonDosyalari = [
    // KAHVALTI (300 yemek)
    'zindeai_kahvalti_300.json',
    'kahvalti_batch_01.json',
    'kahvalti_batch_02.json',
    
    // ARA ÖĞÜN (120 + batch'ler)
    'ara_ogun_toplu_120.json',
    'ara_ogun_1_batch_01.json',
    'ara_ogun_1_batch_02.json',
    'ara_ogun_2_batch_01.json',
    'ara_ogun_2_batch_02.json',
    
    // ÖĞLE YEMEĞİ (300 + batch'ler)
    'zindeai_ogle_300.json',
    'ogle_yemegi_batch_01.json',
    'ogle_yemegi_batch_02.json',
    
    // AKŞAM YEMEĞİ (300 + 450 + 150 + 150) - ÇEŞİTLİLİK İÇİN TÜMÜ!
    'zindeai_aksam_300.json',
    'aksam_combo_450.json',             // 🔥 YENİ - SONMEALLER!
    'aksam_yemekbalık_150.json',        // 🔥 YENİ - SONMEALLER!
    'aksam_yemekbalik_150.json',        // 🔥 YENİ - alternatif isim
    'aksam_yemekleri_150_kofte_kiyma_kusbasi_haslama.json', // 🔥 YENİ - SONMEALLER!
    'aksam_yemegi_batch_01.json',
    'aksam_yemegi_batch_02.json',
    
    // GECE ATIŞTIRMASI
    'gece_atistirmasi.json',
    
    // CHEAT MEAL
    'cheat_meal.json',
  ];

  // JSON dosya yolları (assets klasörü - Web uyumlu)
  static const String _assetsPath = 'assets/data/';

  /// JSON dosyalarını Hive'a migration yap (GÜNCEL)
  static Future<bool> jsonToHiveMigration() async {
    try {
      AppLogger.info(
          '🚀 JSON to Hive migration başlatılıyor... (Optimized - Log minimized)');

      int toplamYemek = 0;
      int basariliYemek = 0;
      int hataliYemek = 0;

      // 1. Normal dosyaları işle (sadece assets'ten oku - Web uyumlu)
      for (var dosya in _jsonDosyalari) {
        final assetsPath = '$_assetsPath$dosya';

        AppLogger.info('📂 İşleniyor: $dosya');

        try {
          List<dynamic> yemekler = [];

          // Assets'ten oku (Web uyumlu)
          try {
            final jsonStr = await rootBundle.loadString(assetsPath);
            yemekler = json.decode(jsonStr);
            // Log minimized - sadece dosya okuma bilgisi
          } catch (e) {
            AppLogger.warning('⚠️ Dosya bulunamadı: $dosya - $e');
            continue;
          }

          // Yemekleri Hive'a kaydet (DUPLICATE ÖNLEME!)
          int dosyaBasarili = 0;
          int dosyaHatali = 0;
          int dosyaSkipped = 0;
          
          for (var yemekJson in yemekler) {
            toplamYemek++;
            try {
              final yemekModel =
                  YemekHiveModel.fromJson(yemekJson as Map<String, dynamic>);
              
              // 🔥 DUPLICATE KONTROLÜ: Aynı meal_id varsa ekleme!
              if (yemekModel.mealId != null) {
                final mevcutYemek = await HiveService.yemekGetir(yemekModel.mealId!);
                if (mevcutYemek != null) {
                  dosyaSkipped++;
                  continue; // Zaten var, atla
                }
              }
              
              await HiveService.yemekKaydet(yemekModel);
              basariliYemek++;
              dosyaBasarili++;
            } catch (e) {
              hataliYemek++;
              dosyaHatali++;
              // Sadece ilk 3 hatayı göster
              if (dosyaHatali <= 3) {
                AppLogger.warning(
                    '⚠️ Yemek kaydedilemedi: ${yemekJson['meal_name']} - $e');
              }
            }
          }
          
          // Toplu log - her yemek için değil
          final logMessage = dosyaSkipped > 0 
              ? '✅ $dosya: ${yemekler.length} yemek (Başarılı: $dosyaBasarili, Hatalı: $dosyaHatali, Zaten var: $dosyaSkipped)'
              : '✅ $dosya: ${yemekler.length} yemek (Başarılı: $dosyaBasarili, Hatalı: $dosyaHatali)';
          AppLogger.success(logMessage);

        } catch (e) {
          AppLogger.error('❌ $dosya işlenirken hata: $e');
        }
      }

      // Sonuç raporu
      AppLogger.info('📊 === MIGRATION RAPORU (GÜNCEL) ===');
      AppLogger.info('Toplam yemek: $toplamYemek');
      AppLogger.info('Başarılı: $basariliYemek');
      AppLogger.info('Hatalı: $hataliYemek');
      AppLogger.info(
          'Başarı oranı: ${(basariliYemek / toplamYemek * 100).toStringAsFixed(1)}%');
      AppLogger.info('=====================================');

      // Veritabanı durumunu göster
      await _yemekVeritabaniDurumu();

      return basariliYemek > 0;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Migration durumunu kontrol et
  static Future<bool> migrationGerekliMi() async {
    try {
      final yemekSayisi = await HiveService.yemekSayisi();
      AppLogger.debug('📊 Mevcut yemek sayısı: $yemekSayisi');
      return yemekSayisi == 0; // Yemek yoksa migration gerekli
    } catch (e) {
      AppLogger.error('❌ Migration kontrol hatası', error: e);
      return true; // Hata durumunda migration yap
    }
  }

  /// Migration'ı temizle (test amaçlı)
  static Future<void> migrationTemizle() async {
    try {
      AppLogger.info('🗑️ Migration temizleniyor...');
      await HiveService.tumYemekleriSil();
      AppLogger.success('✅ Migration temizlendi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration temizleme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Migration istatistikleri (Web uyumlu)
  static Future<Map<String, dynamic>> migrationIstatistikleri() async {
    try {
      final yemekSayisi = await HiveService.yemekSayisi();
      final kategoriSayilari = await HiveService.kategoriSayilari();

      return {
        'toplamYemek': yemekSayisi,
        'kategoriSayilari': kategoriSayilari,
        'migrationGerekli': yemekSayisi == 0,
      };
    } catch (e) {
      AppLogger.error('❌ İstatistik hatası', error: e);
      return {};
    }
  }

  /// Yemek veritabanı durumu (helper method)
  static Future<void> _yemekVeritabaniDurumu() async {
    try {
      final yemekSayisi = await HiveService.yemekSayisi();
      final kategoriSayilari = await HiveService.kategoriSayilari();

      AppLogger.info('🍽️ === YEMEK VERİTABANI DURUMU ===');
      AppLogger.info('Toplam yemek sayısı: $yemekSayisi');
      AppLogger.info('─────────────────────────────────');
      AppLogger.info('Kategori dağılımı:');
      kategoriSayilari.forEach((kategori, sayi) {
        AppLogger.info('  $kategori: $sayi yemek');
      });
      AppLogger.info('=================================');
    } catch (e) {
      AppLogger.error('❌ Yemek veritabanı durumu hatası', error: e);
    }
  }
}
