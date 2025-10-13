// ============================================================================
// lib/core/utils/yemek_migration_guncel.dart
// JSON dosyalarından Hive'a yemek verilerini migration (GÜNCEL)
// ============================================================================

import 'dart:convert';
import 'dart:io'; // Flutter bağımlılığını kaldır
import 'package:flutter/foundation.dart'; // Sadece AppLogger için
import 'package:flutter/services.dart';
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';

class YemekMigration {
  // 🔥 MEGA YEMEKLER - SADECE BENİM YAZDIĞIM YEMEKLER!
  static const List<String> _jsonDosyalari = [
    // KAHVALTI (300 yemek - 3 batch)
    'mega_kahvalti_batch_1.json',
    'mega_kahvalti_batch_2.json',
    'mega_kahvalti_batch_3.json',

    // ÖĞLE YEMEĞİ (400 yemek - 4 batch)
    'mega_ogle_batch_1.json',
    'mega_ogle_batch_2.json',
    'mega_ogle_batch_3.json',
    'mega_ogle_batch_4.json',

    // AKŞAM YEMEĞİ (400 yemek - 4 batch)
    'mega_aksam_batch_1.json',
    'mega_aksam_batch_2.json',
    'mega_aksam_batch_3.json',
    'mega_aksam_batch_4.json',

    // ARA ÖĞÜN 1 (450 yemek - 3 batch)
    'mega_ara_ogun_1_batch_1.json',
    'mega_ara_ogun_1_batch_2.json',
    'mega_ara_ogun_1_batch_3.json',

    // ARA ÖĞÜN 2 (750 yemek - 5 batch)
    'mega_ara_ogun_2_batch_1.json',
    'mega_ara_ogun_2_batch_2.json',
    'mega_ara_ogun_2_batch_3.json',
    'mega_ara_ogun_2_batch_4.json',
    'mega_ara_ogun_2_batch_5.json',
  ];

  // JSON dosya yolları (assets klasörü - Web uyumlu)
  static const String _assetsPath = 'assets/data/';

  /// JSON dosyalarını Hive'a migration yap (VERBOSE - DEBUG MODE)
  static Future<bool> jsonToHiveMigration() async {
    try {
      AppLogger.info('🔥 [DEBUG] Migration başlatıldı - jsonToHiveMigration()');

      int toplamYemek = 0;
      int basariliYemek = 0;
      int hataliYemek = 0;

      // 1. Normal dosyaları işle (sadece assets'ten oku - Web uyumlu)
      for (var dosya in _jsonDosyalari) {
        final assetsPath = '$_assetsPath$dosya';

        AppLogger.info('📂 [DEBUG] Dosya işleniyor: $dosya');

        try {
          List<dynamic> yemekler = [];

          // Dosyadan oku (Flutter için rootBundle, standalone script için dart:io)
          try {
            List<dynamic> yemeklerList;
            try {
              // Önce Flutter uygulaması için rootBundle dene
              final jsonStr = await rootBundle.loadString(assetsPath);
              yemeklerList = json.decode(jsonStr);
            } catch (e) {
              // rootBundle başarısız olursa, standalone script için dart:io dene
              final file = File(assetsPath);
              if (!await file.exists()) {
                AppLogger.warning('⚠️ Dosya bulunamadı: $assetsPath');
                continue;
              }
              final jsonStr = await file.readAsString();
              yemeklerList = json.decode(jsonStr);
            }
            yemekler = yemeklerList;
          } catch (e, stackTrace) {
            AppLogger.error('❌ [DEBUG] Dosya okuma hatası: $dosya', error: e, stackTrace: stackTrace);
            continue;
          }

          // Yemekleri Hive'a kaydet (DUPLICATE ÖNLEME!)
          int dosyaBasarili = 0;
          int dosyaHatali = 0;
          int dosyaSkipped = 0;

          AppLogger.info('   📊 [DEBUG] ${yemekler.length} yemek işlenecek');

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
              var mealName = jsonMap['meal_name'] as String?;

              if (category != null && mealName != null) {
                // Ara Öğün 1: "Kahvaltı Kombinasyonu:" → "Ara Öğün 1:"
                if (category.toLowerCase().contains('ara') &&
                    category.contains('1') &&
                    mealName.startsWith('Kahvaltı Kombinasyonu:')) {
                  mealName = mealName.replaceFirst(
                      'Kahvaltı Kombinasyonu:', 'Ara Öğün 1:');
                }
                // Ara Öğün 2: "Öğle:" → "Ara Öğün 2:"
                else if (category.toLowerCase().contains('ara') &&
                    category.contains('2') &&
                    mealName.startsWith('Öğle:')) {
                  mealName = mealName.replaceFirst('Öğle:', 'Ara Öğün 2:');
                }

                // 🔥 YENİ FİX: Eğer meal_name sadece kategori adı ise (yemek adı eksikse)
                // Malzemelerden anlamlı bir isim oluştur
                final categoryOnly = ['Kahvaltı:', 'Ara Öğün 1:', 'Ara Öğün 2:', 'Öğle:', 'Akşam:', 'Gece Atıştırması:'];
                final mealNameTrimmed = mealName.trim();
                if (categoryOnly.any((cat) => mealNameTrimmed == cat || mealNameTrimmed == cat.replaceAll(':', ''))) {
                  // Malzemeleri al
                  final malzemeler = jsonMap['malzemeler'] as List<dynamic>?;
                  if (malzemeler != null && malzemeler.isNotEmpty) {
                    // İlk 2-3 malzemeyi kullanarak isim oluştur
                    final malzemeIsimleri = <String>[];
                    for (var i = 0; i < (malzemeler.length > 3 ? 3 : malzemeler.length); i++) {
                      final malzeme = malzemeler[i].toString();
                      // Sadece besin adını al (miktar ve birim çıkar)
                      final besinAdi = malzeme.split('(').first.trim();
                      final kisaAd = besinAdi.split(' ').take(2).join(' '); // İlk 2 kelime
                      if (kisaAd.isNotEmpty && !malzemeIsimleri.contains(kisaAd)) {
                        malzemeIsimleri.add(kisaAd);
                      }
                    }
                    
                    if (malzemeIsimleri.isNotEmpty) {
                      // Kategori adını koru ama malzemelerle zenginleştir
                      final categoryName = category.contains('Ara Öğün 1') 
                          ? 'Ara Öğün 1:' 
                          : category.contains('Ara Öğün 2')
                              ? 'Ara Öğün 2:'
                              : category.contains('Öğle')
                                  ? 'Öğle:'
                                  : category.contains('Akşam')
                                      ? 'Akşam:'
                                      : category.contains('Kahvaltı')
                                          ? 'Kahvaltı:'
                                          : 'Gece Atıştırması:';
                      mealName = '$categoryName ${malzemeIsimleri.join(" + ")}';
                    }
                  }
                }
                
                jsonMap['meal_name'] = mealName;
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
            } catch (e, stackTrace) {
              hataliYemek++;
              dosyaHatali++;
              AppLogger.error('   ❌ [DEBUG] Yemek kaydetme hatası', error: e, stackTrace: stackTrace);
            }
          }

          AppLogger.info('   ✅ [DEBUG] $dosya tamamlandı: $dosyaBasarili başarılı, $dosyaHatali hatalı, $dosyaSkipped atlandı');
        } catch (e, stackTrace) {
          AppLogger.error('❌ [DEBUG] $dosya işlenirken kritik hata', error: e, stackTrace: stackTrace);
        }
      }

      AppLogger.info('\n🎉 [DEBUG] Migration tamamlandı!');
      AppLogger.info('   📊 Toplam: $toplamYemek yemek');
      AppLogger.info('   ✅ Başarılı: $basariliYemek');
      AppLogger.info('   ❌ Hatalı: $hataliYemek');

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
