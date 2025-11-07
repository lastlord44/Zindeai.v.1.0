// ============================================================================
// lib/core/utils/yemek_migration_guncel.dart
// JSON dosyalarından Hive'a yemek verilerini migration (GÜNCEL)
// ============================================================================

import 'dart:convert';
import 'dart:io'; // Flutter bağımlılığını kaldır
import 'package:flutter/services.dart';
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';

class YemekMigration {
  // 🎯 KULLANICI TALEBİ: SON KLASÖRÜ TÜM DOSYALAR + KARBONHIDRAT/KAHVALTI
  static const List<String> _jsonDosyalari = [
    // 🔥 YENİ EKLEME: 200 Öğle Yemeği (Batch 3)
    'ogle_200_yemek.json',
    
    // 🌟 SON KLASÖRÜ - TÜM DOSYALAR (30 dosya × 100 = ~3000 yemek)
    'son/baklagil_aksam_100.json',
    'son/baklagil_kahvalti_100.json',
    'son/baklagil_ogle_100.json',
    'son/balik_aksam_100.json',
    'son/balik_kahvalti_ara_100.json',
    'son/balik_ogle_100.json',
    'son/dana_aksam_100.json',
    'son/dana_kahvalti_ara_100.json',
    'son/dana_ogle_100.json',
    'son/hindi_aksam_100.json',
    'son/hindi_ogle_100.json',
    'son/kofte_aksam_100.json',
    'son/kofte_ara_100.json',
    'son/kofte_ogle_100.json',
    'son/peynir_ara_ogun_100.json',
    'son/peynir_kahvalti_100.json',
    'son/tavuk_aksam_100.json',
    'son/tavuk_ara_ogun_100.json',
    'son/tavuk_kahvalti_100.json',
    'son/trend_ara_ogun_kahve_100.json',
    'son/trend_ara_ogun_meyve_100.json',
    'son/trend_ara_ogun_proteinbar_100.json',
    'son/yogurt_ara_ogun_1_100.json',
    'son/yogurt_ara_ogun_2_100.json',
    'son/yogurt_kahvalti_100.json',
    'son/yuksek_kalori_ana_ogunler_100.json',
    'son/yumurta_ara_ogun_1_100.json',
    'son/yumurta_ara_ogun_2_100.json',
    'son/yumurta_kahvalti_100.json',
    'son/yumurta_ogle_aksam_100.json',

    // 🥖 KARBONHIDRAT & KAHVALTI ÖZELİ (benim oluşturduklarım)
    'kahvalti_yuksek_karb_50.json',
    'kahvalti.json',
    
    // 🍳 SAĞLIKLI ÖĞÜNLER - HER ÖĞÜN İÇİN 150'ŞER YEMEK (TÜRK MUTFAĞI)
    'kahvalti_saglikli_150.json',
    'ara_ogun_1_saglikli_150.json',
    'ogle_yemegi_saglikli_150.json',
    'ara_ogun_2_saglikli_150.json',
    'aksam_yemegi_saglikli_150.json',
    
    // ⚡ MİNİMAL EK ÇEŞİTLİLİK (sadece gerekli olanlar)
    'ara_ogun_toplu_120.json',
    'cheat_meal.json',
    
    // 📊 TOPLAM: 34 dosya → ~3500-4000 yemek (ideal performans!)
    // 🚫 Tüm büyük dosyalar çıkarıldı: MEGA, BATCH, ZİNDEAI, COMBO
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
            AppLogger.error('❌ [DEBUG] Dosya okuma hatası: $dosya',
                error: e, stackTrace: stackTrace);
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

              // 🔥 ADIM 1: Dosya adından doğru kategoriyi al
              final dogruKategori = _dosyaAdindanKategoriBelirle(dosya);
              if (dogruKategori != null) {
                jsonMap['category'] = dogruKategori;
              }

              // 🔥 ADIM 2: MEAL_NAME İÇİNDE PROTEİN KONTROLÜ (EN KRİTİK!)
              // Tavuk/Balık/Et meal_name'de varsa KESİNLİKLE ana öğün olmalı!
              final mealNameLower =
                  (jsonMap['meal_name'] as String?)?.toLowerCase() ?? '';
              final proteinKaynaklari = [
               'tavuk',
               'balık',
               'balik',
               'dana',
               'hindi',
               'et',
               'köfte',
               'kofte',
               'somon',
               'uskumru',
               'ton balığı',
               'ton baligi',
               'hamsi',
               'sardalye',
               'sardalya', // 🔥 FIX: Sardalya da eklendi!
               'levrek',
               'çipura',
               'cipura',
               'kıyma',
               'kiyma',
               'kuzu',
               'sığır',
               'sigir',
               'alabalık',
               'alabalik',
               'mezgit',
               'palamut',
               'istavrit'
             ];

              final mealNamedeProteinVar =
                  proteinKaynaklari.any((p) => mealNameLower.contains(p));

              if (mealNamedeProteinVar) {
                // Protein tespit edildi! Category'yi kontrol et
                // 🔥 FIX: Hem category hem meal_type kontrol et!
                final currentCategory =
                    (jsonMap['category'] ?? jsonMap['meal_type'])
                            ?.toString()
                            .toLowerCase() ??
                        '';

                // Eğer kahvaltı veya ara öğündeyse, ANA ÖĞÜNE ÇEK!
                if (currentCategory.contains('kahvalti') ||
                    currentCategory.contains('kahvaltı') ||
                    currentCategory.contains('ara')) {
                  jsonMap['category'] = 'Öğle Yemeği'; // ✅ ZORUNLU DEĞİŞİM!
                  jsonMap['meal_type'] = 'ogle'; // ✅ meal_type'ı da güncelle!
                  // Debug log
                  print(
                      '🔧 FIX: "${jsonMap['meal_name']}" → Öğle Yemeği (Protein tespit edildi)');
                }
              }

              // 🔥 ADIM 3: MEAL_NAME DÜZELTMESİ: Ara öğün yemeklerinin isimlerini düzelt
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
                final categoryOnly = [
                  'Kahvaltı:',
                  'Ara Öğün 1:',
                  'Ara Öğün 2:',
                  'Öğle:',
                  'Akşam:',
                  'Gece Atıştırması:'
                ];
                final mealNameTrimmed = mealName.trim();
                if (categoryOnly.any((cat) =>
                    mealNameTrimmed == cat ||
                    mealNameTrimmed == cat.replaceAll(':', ''))) {
                  // Malzemeleri al
                  final malzemeler = jsonMap['malzemeler'] as List<dynamic>?;
                  if (malzemeler != null && malzemeler.isNotEmpty) {
                    // İlk 2-3 malzemeyi kullanarak isim oluştur
                    final malzemeIsimleri = <String>[];
                    for (var i = 0;
                        i < (malzemeler.length > 3 ? 3 : malzemeler.length);
                        i++) {
                      final malzeme = malzemeler[i].toString();
                      // Sadece besin adını al (miktar ve birim çıkar)
                      final besinAdi = malzeme.split('(').first.trim();
                      final kisaAd =
                          besinAdi.split(' ').take(2).join(' '); // İlk 2 kelime
                      if (kisaAd.isNotEmpty &&
                          !malzemeIsimleri.contains(kisaAd)) {
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

              // 🔥 ADIM 4: "PAD" ÖN EKİNİ TEMİZLE (UI'da görünmemesi için)
              var finalMealName = jsonMap['meal_name'] as String?;
              if (finalMealName != null && finalMealName.startsWith('PAD ')) {
                finalMealName = finalMealName.substring(4); // "PAD " kısmını çıkar
                jsonMap['meal_name'] = finalMealName;
              }

              // 🔥 ADIM 5: KALORİ KONTROLÜ (0 kalori olan yemekleri filtrele)
              final kaloriRaw = jsonMap['kalori'];
              double kalori = 0.0;
              if (kaloriRaw != null) {
                if (kaloriRaw is double) {
                  kalori = kaloriRaw;
                } else if (kaloriRaw is int) {
                  kalori = kaloriRaw.toDouble();
                } else if (kaloriRaw is String) {
                  kalori = double.tryParse(kaloriRaw) ?? 0.0;
                }
              }
              
              if (kalori <= 0) {
                // Kalori 0 veya negatif olan yemekleri atla
                dosyaSkipped++;
                continue;
              }

              // 🔥 ADIM 6: YABANCI BESİN KONTROLÜ (Türk mutfağı dışı besinler)
              final mealNameToCheck = finalMealName?.toLowerCase() ?? '';
              final malzemeler = jsonMap['malzemeler'] as List<dynamic>? ?? [];
              final malzemelerText = malzemeler.join(' ').toLowerCase();
              
              final yabanciBesinler = [
                'tempeh', 'quinoa', 'kinoa', 'tofu', 'edamame', 'kimchi',
                'kombucha', 'seitan', 'miso', 'hummus', 'falafel',
                'couscous', 'kuskus', 'chia', 'acai', 'goji', 'spirulina',
                'matcha', 'kale', 'arugula', 'rocket', 'bok choy', 'nori',
                'wakame', 'sushi', 'sashimi', 'wasabi', 'sriracha', 'paneer',
                'ghee', 'naan', 'basmati', 'jasmine rice', 'pad thai', 'pho',
                'ramen', 'udon', 'soba', 'mochi', 'burrito', 'taco',
                'quesadilla', 'guacamole', 'salsa', 'tortilla', 'enchilada',
                'chimichanga', 'fajita', 'nachos', 'paella', 'risotto',
                'gnocchi', 'ravioli', 'pesto', 'bruschetta', 'ciabatta',
                'focaccia', 'bagel', 'croissant', 'baguette', 'prosciutto',
                'salami', 'chorizo', 'pancetta', 'brie', 'camembert',
                'gorgonzola', 'parmesan', 'mozzarella', 'ricotta',
                'mascarpone', 'cheddar', 'gouda', 'swiss', 'blue cheese',
                'cottage cheese', 'cream cheese',
              ];
              
              bool yabanciBesinVar = false;
              for (var yabanci in yabanciBesinler) {
                if (mealNameToCheck.contains(yabanci) ||
                    malzemelerText.contains(yabanci)) {
                  yabanciBesinVar = true;
                  print('🚫 ENGELLENDI: "$finalMealName" (Yabancı besin: $yabanci)');
                  break;
                }
              }
              
              if (yabanciBesinVar) {
                dosyaSkipped++;
                continue; // Yabancı besin içeren yemeği atla
              }

              // 🔥 ADIM 7: VERİ TUTARSIZLIĞI KONTROLÜ VE OTOMATİK DÜZELTME
              // Yemek adı ile malzemeler uyumsuzsa, malzemelere göre yeni ad oluştur
              final finalMealNameLower = finalMealName?.toLowerCase() ?? '';
              final malzemelerList = malzemeler.map((m) => m.toString().toLowerCase()).toList();
              
              // Yemek adında geçen ana malzemeler
              final adtakiMalzemeler = [
                'tavuk', 'balık', 'balik', 'ton', 'somon', 'makarna', 'pirinç',
                'pirinci', 'bulgur', 'mercimek', 'nohut', 'dana', 'hindi', 'köfte'
              ];
              
              bool tutarsizlikVar = false;
              String? tutarsizMalzeme;
              
              for (var malzeme in adtakiMalzemeler) {
                if (finalMealNameLower.contains(malzeme)) {
                  // Yemek adında bu malzeme var, malzemelerde de var mı?
                  bool malzemelerdeBulunamadi = true;
                  for (var m in malzemelerList) {
                    if (m.contains(malzeme)) {
                      malzemelerdeBulunamadi = false;
                      break;
                    }
                  }
                  
                  if (malzemelerdeBulunamadi) {
                    tutarsizlikVar = true;
                    tutarsizMalzeme = malzeme;
                    break;
                  }
                }
              }
              
              if (tutarsizlikVar) {
                // Tutarsızlık tespit edildi! Malzemelerden yeni ad oluştur
                final anaMalzemeler = _anaMalzemeleriBelirleme(malzemelerList);
                
                if (anaMalzemeler.isNotEmpty) {
                  // Kategori önekini koru (Öğle:, Ara Öğün 1: vb.)
                  final kategoriOnek = finalMealName?.split(':').first ?? '';
                  final yeniAd = '$kategoriOnek: ${anaMalzemeler.join(" + ")}';
                  
                  jsonMap['meal_name'] = yeniAd;
                  print('🔧 DÜZELTME: "${finalMealName}" → "$yeniAd" (Tutarsızlık: $tutarsizMalzeme yok)');
                  finalMealName = yeniAd;
                } else {
                  // Ana malzeme belirlenemedi, yemeği atla
                  print('🚫 ATLANDI: "${finalMealName}" (Ana malzeme belirlenemedi)');
                  dosyaSkipped++;
                  continue;
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
            } catch (e, stackTrace) {
              hataliYemek++;
              dosyaHatali++;
              AppLogger.error('   ❌ [DEBUG] Yemek kaydetme hatası',
                  error: e, stackTrace: stackTrace);
            }
          }

          AppLogger.info(
              '   ✅ [DEBUG] $dosya tamamlandı: $dosyaBasarili başarılı, $dosyaHatali hatalı, $dosyaSkipped atlandı');
        } catch (e, stackTrace) {
          AppLogger.error('❌ [DEBUG] $dosya işlenirken kritik hata',
              error: e, stackTrace: stackTrace);
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

  /// 🔥 Dosya adından kategori belirle (ANA MALZEME BAZLI AKILLI SİSTEM!)
  static String? _dosyaAdindanKategoriBelirle(String dosyaAdi) {
    final dosyaLower = dosyaAdi.toLowerCase();

    // 🔥 ADIM 1: ÖNCELİK - Açıkça belirtilmiş ara öğünler
    if (dosyaLower.contains('ara_ogun_2') || dosyaLower.contains('ara ogun 2'))
      return 'Ara Öğün 2';
    if (dosyaLower.contains('ara_ogun_1') || dosyaLower.contains('ara ogun 1'))
      return 'Ara Öğün 1';
    if (dosyaLower.contains('ara_ogun') && dosyaLower.contains('toplu'))
      return 'Ara Öğün 2';

    // 🔥 ADIM 2: ANA MALZEME BAZLI KATEGORİZASYON
    // Tavuk, balık, et gibi proteinler KESİNLİKLE kahvaltıda OLMAMALI!
    final proteinKaynaklari = [
      'balik',
      'sardalya',
      'sardalye',
      'somon',
      'hamsi',
      'levrek',
      'uskumru',
      'ton',
      'palamut',
      'alabalik',
      'mezgit',
      'istavrit',
      'tavuk',
      'dana',
      'hindi',
      'kofte',
      'kiyma',
      'kuzbasi'
    ];
    final dosyaProteinIceriyor =
        proteinKaynaklari.any((p) => dosyaLower.contains(p));

    if (dosyaProteinIceriyor) {
      // Protein kaynağı tespit edildi → ANA ÖĞÜN olmalı!
      // Dosya adında "ogle" veya "aksam" varsa ona göre, yoksa default öğle
      if (dosyaLower.contains('aksam')) return 'Akşam Yemeği';
      if (dosyaLower.contains('ogle')) return 'Öğle Yemeği';

      // 🔥 KRİTİK: "tavuk_kahvalti", "balik_kahvalti_ara" gibi dosyalar
      // YANLIŞ ETİKETLENMİŞ! Bunlar aslında ANA ÖĞÜN!
      if (dosyaLower.contains('kahvalti') || dosyaLower.contains('ara')) {
        return 'Öğle Yemeği'; // Default: öğle yemeğine koy
      }

      // Hiçbir öğün belirtilmemişse default öğle
      return 'Öğle Yemeği';
    }

    // 🔥 ADIM 3: YOĞURT & PEYNİR - Hem kahvaltı hem ara öğün olabilir
    if (dosyaLower.contains('yogurt') || dosyaLower.contains('peynir')) {
      // Dosya adında açıkça belirtilmişse ona göre
      if (dosyaLower.contains('kahvalti')) return 'Kahvaltı';
      if (dosyaLower.contains('ara')) return 'Ara Öğün 1';
      // Default: kahvaltı
      return 'Kahvaltı';
    }

    // 🔥 ADIM 4: GENEL KATEGORİLER
    if (dosyaLower.startsWith('kahvalti') ||
        dosyaLower.contains('/kahvalti_batch')) return 'Kahvaltı';
    if (dosyaLower.contains('ogle')) return 'Öğle Yemeği';
    if (dosyaLower.contains('aksam')) return 'Akşam Yemeği';
    if (dosyaLower.contains('gece')) return 'Gece Atıştırması';
    if (dosyaLower.contains('cheat')) return 'Cheat Meal';

    // Hiçbir kurala uymuyorsa null dön (JSON'daki category kullanılacak)
    return null;
  }

  /// Ana malzemeleri belirle (malzeme listesinden yemek adı oluşturmak için)
  static List<String> _anaMalzemeleriBelirleme(List<String> malzemeler) {
    final anaBesinler = <String>[];
    
    // Malzeme önceliklendirmesi (protein > karbonhidrat > yağ > sebze)
    final proteinler = ['tavuk', 'balik', 'ton', 'somon', 'dana', 'hindi', 'yumurta', 'peynir'];
    final karbonhidratlar = ['makarna', 'pirinc', 'bulgur', 'ekmek', 'yulaf', 'bugday'];
    final sebzeler = ['domates', 'salatalik', 'biber', 'patlican', 'kabak', 'havuc'];
    final sutUrunleri = ['sut', 'yogurt', 'peynir', 'kasar'];
    
    // 1. Protein kaynağı bul
    for (var malzeme in malzemeler) {
      for (var protein in proteinler) {
        if (malzeme.contains(protein)) {
          if (protein == 'yumurta') {
            // Eğer sadece yumurta + un + süt varsa → Pancake/Krep
            final unVar = malzemeler.any((m) => m.contains('un') || m.contains('bugday'));
            final sutVar = malzemeler.any((m) => m.contains('sut'));
            if (unVar && sutVar) {
              anaBesinler.add('Pancake');
              return anaBesinler;
            }
            anaBesinler.add('Yumurta');
          } else if (protein == 'peynir') {
            anaBesinler.add('Peynir');
          } else {
            anaBesinler.add(protein[0].toUpperCase() + protein.substring(1));
          }
          break;
        }
      }
      if (anaBesinler.isNotEmpty) break;
    }
    
    // 2. Karbonhidrat bul
    for (var malzeme in malzemeler) {
      for (var karb in karbonhidratlar) {
        if (malzeme.contains(karb)) {
          anaBesinler.add(karb[0].toUpperCase() + karb.substring(1));
          break;
        }
      }
      if (anaBesinler.length >= 2) break;
    }
    
    // 3. Sebze ekle (max 1)
    if (anaBesinler.length < 2) {
      for (var malzeme in malzemeler) {
        for (var sebze in sebzeler) {
          if (malzeme.contains(sebze)) {
            anaBesinler.add(sebze[0].toUpperCase() + sebze.substring(1));
            break;
          }
        }
        if (anaBesinler.length >= 2) break;
      }
    }
    
    // 4. Süt ürünü ekle (eğer başka bir şey yoksa)
    if (anaBesinler.isEmpty) {
      for (var malzeme in malzemeler) {
        for (var sut in sutUrunleri) {
          if (malzeme.contains(sut)) {
            anaBesinler.add(sut[0].toUpperCase() + sut.substring(1));
            break;
          }
        }
        if (anaBesinler.isNotEmpty) break;
      }
    }
    
    return anaBesinler;
  }

}
