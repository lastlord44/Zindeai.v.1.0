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
  // JSON dosya listesi (Web uyumlu - TÜM DOSYALAR!)
  static const List<String> _jsonDosyalari = [
    'kahvalti_batch_01.json',
    'kahvalti_batch_02.json',
    'ara_ogun_1_batch_01.json',
    'ara_ogun_1_batch_02.json',
    'ogle_yemegi_batch_01.json',
    'ogle_yemegi_batch_02.json',
    'ara_ogun_2_batch_01.json',
    'ara_ogun_2_batch_02.json',
    'aksam_yemegi_batch_01.json',
    'aksam_yemegi_batch_02.json',
    'gece_atistirmasi.json',
    'cheat_meal.json',
    // 🆕 YENİ EKLENEN DOSYALAR (750+ yeni yemek!)
    'aksam_combo_450.json', // 450 combo yemek
    'aksam_yemekbalik_150.json', // 150 balık yemeği
    'aksam_yemekleri_150_kofte.json', // 150 et yemeği
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

          // Yemekleri Hive'a kaydet (LOG MİNİMİZED!)
          int dosyaBasarili = 0;
          int dosyaHatali = 0;
          
          for (var yemekJson in yemekler) {
            toplamYemek++;
            try {
              final yemekModel =
                  YemekHiveModel.fromJson(yemekJson as Map<String, dynamic>);
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
          AppLogger.success('✅ $dosya: ${yemekler.length} yemek (Başarılı: $dosyaBasarili, Hatalı: $dosyaHatali)');
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
