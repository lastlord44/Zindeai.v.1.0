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
    'aksam_combo_450.json', // 🔥 YENİ - SONMEALLER!
    'aksam_yemekbalık_150.json', // 🔥 YENİ - SONMEALLER!
    'aksam_yemekbalik_150.json', // 🔥 YENİ - alternatif isim
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

  /// JSON dosyalarını Hive'a migration yap (SESSIZ - kullanıcı "Plan Oluştur" butonuna basmadan log yok)
  static Future<bool> jsonToHiveMigration() async {
    try {
      // Log kaldırıldı - kullanıcı "Plan Oluştur" butonuna basmadan önce hiçbir yemek logu olmamalı

      int toplamYemek = 0;
      int basariliYemek = 0;
      int hataliYemek = 0;

      // 1. Normal dosyaları işle (sadece assets'ten oku - Web uyumlu)
      for (var dosya in _jsonDosyalari) {
        final assetsPath = '$_assetsPath$dosya';

        // Log kaldırıldı - sessiz çalışma

        try {
          List<dynamic> yemekler = [];

          // Assets'ten oku (Web uyumlu)
          try {
            final jsonStr = await rootBundle.loadString(assetsPath);
            yemekler = json.decode(jsonStr);
            // Sessiz çalışma - log yok
          } catch (e) {
            // Sadece kritik dosya bulunamama hatası
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
              // 🔥 KATEGORİ DÜZELTMESİ: Dosya adına göre kategori belirle (JSON'a güvenme!)
              final jsonMap =
                  Map<String, dynamic>.from(yemekJson as Map<String, dynamic>);

              // Dosya adından doğru kategoriyi al
              final dogruKategori = _dosyaAdindanKategoriBelirle(dosya);
              if (dogruKategori != null) {
                jsonMap['category'] =
                    dogruKategori; // ✅ Dosya adına göre category override et!
              }

              // 🔥 MEAL_NAME DÜZELTMESİ: Ara öğün yemeklerinin isimlerini düzelt
              final category = jsonMap['category'] as String?;
              final mealName = jsonMap['meal_name'] as String?;

              if (category != null && mealName != null) {
                // Ara Öğün 1: "Kahvaltı Kombinasyonu:" → "Ara Öğün 1:"
                if (category.toLowerCase().contains('ara') &&
                    category.contains('1') &&
                    mealName.startsWith('Kahvaltı Kombinasyonu:')) {
                  jsonMap['meal_name'] = mealName.replaceFirst(
                      'Kahvaltı Kombinasyonu:', 'Ara Öğün 1:');
                }
                // Ara Öğün 2: "Öğle:" → "Ara Öğün 2:"
                else if (category.toLowerCase().contains('ara') &&
                    category.contains('2') &&
                    mealName.startsWith('Öğle:')) {
                  jsonMap['meal_name'] =
                      mealName.replaceFirst('Öğle:', 'Ara Öğün 2:');
                }
              }

              final yemekModel = YemekHiveModel.fromJson(jsonMap);

              // 🔥 DUPLICATE KONTROLÜ: Aynı meal_id varsa ekleme!
              if (yemekModel.mealId != null) {
                final mevcutYemek =
                    await HiveService.yemekGetir(yemekModel.mealId!);
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
              // Sessiz çalışma - log yok
            }
          }

          // Toplu log KALDIRILDI - sessiz çalışma
        } catch (e) {
          // Sadece kritik dosya işleme hatası
          AppLogger.error('❌ $dosya işlenirken kritik hata: $e');
        }
      }

      // Sonuç raporu KALDIRILDI - sessiz çalışma
      // Veritabanı durumu KALDIRILDI - sessiz çalışma

      return basariliYemek > 0;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Migration durumunu kontrol et (SESSIZ - log yok)
  static Future<bool> migrationGerekliMi() async {
    try {
      final yemekSayisi = await HiveService.yemekSayisi();
      // Log kaldırıldı - kullanıcı "Plan Oluştur" butonuna basmadan log çıkmamalı
      return yemekSayisi == 0; // Yemek yoksa migration gerekli
    } catch (e) {
      // Sadece kritik hatalarda log bas
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

  /// 🔥 Dosya adından kategori belirle (JSON'daki category'ye güvenme!)
  static String? _dosyaAdindanKategoriBelirle(String dosyaAdi) {
    final dosyaLower = dosyaAdi.toLowerCase();

    // Dosya adına göre kategori mapping'i
    if (dosyaLower.contains('kahvalti')) return 'Kahvaltı';
    if (dosyaLower.contains('ara_ogun_1') || dosyaLower.contains('ara ogun 1'))
      return 'Ara Öğün 1';
    if (dosyaLower.contains('ara_ogun_2') || dosyaLower.contains('ara ogun 2'))
      return 'Ara Öğün 2';
    if (dosyaLower.contains('ara_ogun_toplu'))
      return 'Ara Öğün 2'; // 🔥 DÜZELTİLDİ: Toplu ara öğün = Ara Öğün 2
    if (dosyaLower.contains('ogle')) return 'Öğle Yemeği';
    if (dosyaLower.contains('aksam')) return 'Akşam Yemeği';
    if (dosyaLower.contains('gece')) return 'Gece Atıştırması';
    if (dosyaLower.contains('cheat')) return 'Cheat Meal';

    // Dosya adından belirlenemezse null dön (JSON'daki category kullanılacak)
    return null;
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
