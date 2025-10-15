// migration_besin_malzemeleri_standalone.dart
// Standalone migration - Flutter dependency yok

import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';

void main() async {
  print('🚀 BESİN MALZEMELERİ MIGRATION BAŞLIYOR...\n');
  
  try {
    // Hive init
    Hive.init('hive_db');
    
    // Box aç
    final box = await Hive.openBox('besin_malzeme_box');
    
    // 20 batch dosyasını birleştir
    final batchDosyalari = [
      'besin_malzemeleri_200.json',
      'besin_malzemeleri_batch2_200.json',
      'besin_malzemeleri_batch2_0201_0400.json',
      'besin_malzemeleri_batch3_0401_0600.json',
      'besin_malzemeleri_batch4_0601_0800.json',
      'besin_malzemeleri_batch5_0801_1000.json',
      'besin_malzemeleri_batch6_1001_1200.json',
      'besin_malzemeleri_batch7_1201_1400_karbonhidrat_set3.json',
      'besin_malzemeleri_batch8_1401_1600_karbonhidrat_set4.json',
      'besin_malzemeleri_batch9_1601_1800_yag_sut_set1.json',
      'besin_malzemeleri_batch10_1801_2000_yag_sut_set2.json',
      'besin_malzemeleri_batch11_2001_2200_yag_sut_set3.json',
      'besin_malzemeleri_batch12_2201_2400_yag_sut_set4.json',
      'besin_malzemeleri_batch13_2401_2600_sebze_set1.json',
      'besin_malzemeleri_batch14_2601_2800_sebze_set2.json',
      'besin_malzemeleri_batch15_2801_3000_sebze_set3.json',
      'besin_malzemeleri_batch16_3001_3200_sebze_set4.json',
      'besin_malzemeleri_batch17_3201_3400_meyve_set1.json',
      'besin_malzemeleri_batch18_3401_3600_meyve_set2.json',
      'besin_malzemeleri_batch19_3601_3800_trend_modern_set1.json',
      'besin_malzemeleri_batch20_3801_4000_trend_modern_set2.json',
    ];
    
    final List<dynamic> tumBesinler = [];
    int toplamYuklenen = 0;
    
    for (int i = 0; i < batchDosyalari.length; i++) {
      final dosyaAdi = batchDosyalari[i];
      final dosyaYolu = 'hive_db/$dosyaAdi';
      
      print('📦 Batch ${i + 1}/21: $dosyaAdi yükleniyor...');
      
      final dosya = File(dosyaYolu);
      if (!await dosya.exists()) {
        print('   ⚠️  Dosya bulunamadı, atlanıyor');
        continue;
      }
      
      try {
        final jsonStr = await dosya.readAsString();
        final List<dynamic> batch = json.decode(jsonStr);
        tumBesinler.addAll(batch);
        toplamYuklenen += batch.length;
        print('   ✅ ${batch.length} besin yüklendi (Toplam: $toplamYuklenen)');
      } catch (e) {
        print('   ❌ Hata: $e');
      }
    }
    
    // Tüm besinleri tek bir JSON string olarak Hive'a kaydet
    final finalJson = json.encode(tumBesinler);
    await box.put('batch_json', finalJson);
    
    print('\n' + '=' * 60);
    print('✅ MIGRATION TAMAMLANDI!');
    print('📊 Toplam yüklenen besin: $toplamYuklenen');
    print('=' * 60);
    
    // Doğrulama
    final kaydedilen = box.get('batch_json');
    if (kaydedilen is String) {
      final dogrulama = json.decode(kaydedilen) as List;
      print('\n🔍 Doğrulama: Hive DB\'de ${dogrulama.length} besin var');
      
      if (dogrulama.isNotEmpty) {
        print('\n📋 Örnek besinler:');
        for (int i = 0; i < 5 && i < dogrulama.length; i++) {
          final besin = dogrulama[i];
          final ad = besin['ad'] ?? 'İsimsiz';
          final kategori = besin['kategori'] ?? 'Bilinmeyen';
          final kalori = besin['kalori100g'] ?? 0;
          print('   ${i + 1}. $ad ($kategori, $kalori kcal/100g)');
        }
      }
    }
    
    await box.close();
    
  } catch (e, stack) {
    print('\n❌ HATA: $e');
    print('Stack: $stack');
  }
}
