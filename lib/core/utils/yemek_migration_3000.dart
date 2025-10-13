import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';

/// 3000 Yeni Yemek Migration Utility
/// 
/// assets/data/son/ klasöründeki 29 JSON dosyasını Hive DB'ye yükler
/// Her dosya 100 yemek içerir (toplam ~2900 yemek)

class YemekMigration3000 {
  static Future<void> yukle() async {
    if (kDebugMode) {
      print('🚀 3000 YEMEK MİGRATION BAŞLADI');
      print('━' * 60);
    }

    // Başlangıç durumu
    final baslangicSayisi = await HiveService.yemekSayisi();
    if (kDebugMode) {
      print('📊 Mevcut yemek sayısı: $baslangicSayisi');
      print('');
    }

    // JSON dosyalarının listesi
    final dosyalar = [
      // Tavuk bazlı (3 dosya - 300 yemek)
      'tavuk_aksam_100.json',
      'tavuk_ara_ogun_100.json',
      'tavuk_kahvalti_100.json',
      
      // Dana eti bazlı (3 dosya - 300 yemek)
      'dana_ogle_100.json',
      'dana_aksam_100.json',
      'dana_kahvalti_ara_100.json',
      
      // Köfte/Kıyma bazlı (3 dosya - 300 yemek)
      'kofte_ogle_100.json',
      'kofte_aksam_100.json',
      'kofte_ara_100.json',
      
      // Balık bazlı (3 dosya - 300 yemek)
      'balik_ogle_100.json',
      'balik_aksam_100.json',
      'balik_kahvalti_ara_100.json',
      
      // Hindi bazlı (2 dosya - 200 yemek)
      'hindi_ogle_100.json',
      'hindi_aksam_100.json',
      
      // Yumurta bazlı (4 dosya - 400 yemek)
      'yumurta_kahvalti_100.json',
      'yumurta_ara_ogun_1_100.json',
      'yumurta_ara_ogun_2_100.json',
      'yumurta_ogle_aksam_100.json',
      
      // Süzme yoğurt bazlı (3 dosya - 300 yemek)
      'yogurt_kahvalti_100.json',
      'yogurt_ara_ogun_1_100.json',
      'yogurt_ara_ogun_2_100.json',
      
      // Peynir bazlı (2 dosya - 200 yemek)
      'peynir_kahvalti_100.json',
      'peynir_ara_ogun_100.json',
      
      // Baklagil bazlı (3 dosya - 300 yemek)
      'baklagil_ogle_100.json',
      'baklagil_aksam_100.json',
      'baklagil_kahvalti_100.json',
      
      // Trend ara öğün (3 dosya - 300 yemek)
      'trend_ara_ogun_kahve_100.json',
      'trend_ara_ogun_meyve_100.json',
      'trend_ara_ogun_proteinbar_100.json',
    ];

    int toplamYuklenen = 0;
    int hataliDosya = 0;
    final Map<String, int> kategoriSayilari = {};

    // Her dosyayı işle
    for (final dosyaAdi in dosyalar) {
      try {
        if (kDebugMode) {
          print('📄 İşleniyor: $dosyaAdi');
        }
        
        // ✅ DÜZELTME: File() yerine rootBundle kullan (Android uyumlu)
        final dosyaYolu = 'assets/data/son/$dosyaAdi';
        
        // Assets dosyasını rootBundle ile yükle
        final jsonString = await rootBundle.loadString(dosyaYolu);
        final List<dynamic> jsonList = json.decode(jsonString);
        
        int dosyadanYuklenen = 0;
        
        for (final jsonData in jsonList) {
          try {
            // JSON'dan YemekHiveModel oluştur (fromJson otomatik parse eder)
            final yemekModel = YemekHiveModel.fromJson(jsonData as Map<String, dynamic>);
            
            // Hive'a kaydet
            await HiveService.yemekKaydet(yemekModel);
            
            dosyadanYuklenen++;
            toplamYuklenen++;
            
            // Kategori sayacı
            final yemekEntity = yemekModel.toEntity();
            final kategori = yemekEntity.ogun.toString();
            kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
            
          } catch (e) {
            if (kDebugMode) {
              print('   ⚠️  Yemek işlenirken hata: $e');
            }
          }
        }
        
        if (kDebugMode) {
          print('   ✅ $dosyadanYuklenen yemek yüklendi');
        }
        
      } catch (e) {
        if (kDebugMode) {
          print('   ❌ Dosya işlenirken hata: $e');
        }
        hataliDosya++;
      }
    }

    if (kDebugMode) {
      print('');
      print('━' * 60);
      print('📊 MİGRATION SONUÇLARI:');
      print('━' * 60);
      print('');
      
      print('✅ Başarılı dosya: ${dosyalar.length - hataliDosya}');
      print('❌ Hatalı dosya: $hataliDosya');
      print('📈 Toplam yüklenen: $toplamYuklenen yemek');
      print('');
      
      if (kategoriSayilari.isNotEmpty) {
        print('📊 KATEGORİ BAZINDA DAĞILIM:');
        kategoriSayilari.forEach((kategori, sayi) {
          print('   • $kategori: $sayi yemek');
        });
        print('');
      }
      
      // Son durum
      final bitisSayisi = await HiveService.yemekSayisi();
      print('🎯 GÜNCEL TOPLAM: $bitisSayisi yemek');
      print('🆕 Eklenen: ${bitisSayisi - baslangicSayisi} yeni yemek');
      print('');
      print('━' * 60);
      print('✨ MİGRATION TAMAMLANDI!');
    }
  }
}
