// ============================================================================
// lib/core/utils/yemek_migration.dart
// JSON dosyalarından Hive'a yemek verilerini migration
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';

class YemekMigration {
  // JSON dosya listesi
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
  ];

  // JSON dosya yolları (assets klasörü - Web uyumlu)
  static const String _assetsPath = 'assets/data/';

  /// JSON dosyalarını Hive'a migration yap
  static Future<bool> jsonToHiveMigration() async {
    try {
      AppLogger.info('🚀 JSON to Hive migration başlatılıyor...');

      int toplamYemek = 0;
      int basariliYemek = 0;
      int hataliYemek = 0;

      // Assets'ten oku (Web uyumlu)
      for (var dosya in _jsonDosyalari) {
        final assetsPath = '$_assetsPath$dosya';

        AppLogger.info('📂 İşleniyor: $dosya');

        try {
          List<dynamic> yemekler = [];

          // Assets'ten oku (Web uyumlu)
          try {
            final jsonStr = await rootBundle.loadString(assetsPath);
            yemekler = json.decode(jsonStr);
            AppLogger.debug('✅ Assets\'ten okundu: $assetsPath');
          } catch (e) {
            AppLogger.warning('⚠️ Dosya bulunamadı: $dosya - $e');
            continue;
          }

          // Yemekleri Hive'a kaydet
          for (var yemekJson in yemekler) {
            toplamYemek++;
            try {
              final yemekModel =
                  YemekHiveModel.fromJson(yemekJson as Map<String, dynamic>);
              await HiveService.yemekKaydet(yemekModel);
              basariliYemek++;
            } catch (e) {
              hataliYemek++;
              AppLogger.warning(
                  '⚠️ Yemek kaydedilemedi: ${yemekJson['meal_name']} - $e');
            }
          }

          AppLogger.success('✅ $dosya tamamlandı: ${yemekler.length} yemek');
        } catch (e) {
          AppLogger.error('❌ $dosya işlenirken hata: $e');
        }
      }

      // Sonuç raporu
      AppLogger.info('📊 === MIGRATION RAPORU ===');
      AppLogger.info('Toplam yemek: $toplamYemek');
      AppLogger.info('Başarılı: $basariliYemek');
      AppLogger.info('Hatalı: $hataliYemek');
      AppLogger.info(
          'Başarı oranı: ${(basariliYemek / toplamYemek * 100).toStringAsFixed(1)}%');
      AppLogger.info('===========================');

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

      print('🍽️ === YEMEK VERİTABANI DURUMU ===');
      print('Toplam yemek sayısı: $yemekSayisi');
      print('─────────────────────────────────');
      print('Kategori dağılımı:');
      kategoriSayilari.forEach((kategori, sayi) {
        print('  $kategori: $sayi yemek');
      });
      print('=================================');
    } catch (e) {
      print('❌ Yemek veritabanı durumu hatası: $e');
    }
  }
}

