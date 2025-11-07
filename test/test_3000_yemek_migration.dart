import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/data/local/hive_service.dart';

/// 3000 Yeni Yemek Migration Test
/// 
/// assets/data/son/ klasöründeki 29 JSON dosyasını Hive DB'ye yükler
/// Her dosya 100 yemek içerir (toplam ~2900 yemek)

void main() {
  test('3000 Yemek Migration', () async {
    print('🚀 3000 YEMEK MİGRATION BAŞLADI');
    print('━' * 60);

    // Test için geçici bir dizin oluştur
    final tempDir = Directory.systemTemp.createTempSync('migration_test_');
    print('📦 Geçici test veritabanı dizini: ${tempDir.path}');

    try {
      // Hive'ı geçici dizinde başlat
      await HiveService.init(path: tempDir.path);

      // Başlangıç durumu
      final baslangicSayisi = await HiveService.yemekSayisi();
    print('📊 Mevcut yemek sayısı: $baslangicSayisi');
    print('');

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
        print('📄 İşleniyor: $dosyaAdi');
        
        final dosyaYolu = 'assets/data/son/$dosyaAdi';
        final dosya = File(dosyaYolu);
        
        if (!dosya.existsSync()) {
          print('   ⚠️  Dosya bulunamadı: $dosyaYolu');
          hataliDosya++;
          continue;
        }

        final jsonString = await dosya.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        
        int dosyadanYuklenen = 0;
        
        for (final jsonData in jsonList) {
          try {
            // JSON'dan YemekHiveModel oluştur (fromJson otomatik parse eder)
            final yemekModel = YemekHiveModel.fromJson(jsonData as Map<String, dynamic>);
            
            // Hive'a kaydet (doğru method adı)
            await HiveService.yemekKaydet(yemekModel);
            
            dosyadanYuklenen++;
            toplamYuklenen++;
            
            // Kategori sayacı
            final yemekEntity = yemekModel.toEntity();
            final kategori = yemekEntity.ogun.toString();
            kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
            
          } catch (e) {
            print('   ⚠️  Yemek işlenirken hata: $e');
          }
        }
        
        print('   ✅ $dosyadanYuklenen yemek yüklendi');
        
      } catch (e) {
        print('   ❌ Dosya işlenirken hata: $e');
        hataliDosya++;
      }
    }

    print('');
    print('━' * 60);
    print('📊 MİGRATION SONUÇLARI:');
    print('━' * 60);
    print('');
    
    print('✅ Başarılı dosya: ${dosyalar.length - hataliDosya}');
    print('❌ Hatalı dosya: $hataliDosya');
    print('📈 Toplam yüklenen: $toplamYuklenen yemek');
    print('');
    
    print('📊 KATEGORİ BAZINDA DAĞILIM:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   • $kategori: $sayi yemek');
    });
    print('');
    
    // Son durum
    final bitisSayisi = await HiveService.yemekSayisi();
    print('🎯 GÜNCEL TOPLAM: $bitisSayisi yemek');
    print('🆕 Eklenen: ${bitisSayisi - baslangicSayisi} yeni yemek');
    print('');
    print('━' * 60);
    print('✨ MİGRATION TAMAMLANDI!');
    
    // Test assertion
    expect(toplamYuklenen, greaterThan(0), reason: 'En az bir yemek yüklenmiş olmalı');

    } finally {
      // Test bittiğinde kaynakları temizle
      await HiveService.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        print('🧹 Geçici test veritabanı temizlendi.');
      }
    }
  });
}
