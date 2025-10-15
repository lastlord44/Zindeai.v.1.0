// migration_besin_malzemeleri.dart
// 4000 besin malzemesini Hive'a yükle

import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/local/besin_malzeme_hive_service.dart';

void main() async {
  print('🚀 BESİN MALZEMELERİ MIGRATION BAŞLIYOR...\n');
  
  try {
    // Hive init
    Hive.init('hive_db');
    
    final besinService = BesinMalzemeHiveService();
    int toplamYuklenen = 0;
    
    // 20 batch dosyasını yükle
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
    
    for (int i = 0; i < batchDosyalari.length; i++) {
      final dosyaAdi = batchDosyalari[i];
      final dosyaYolu = 'hive_db/$dosyaAdi';
      
      print('📦 Batch ${i + 1}/20: $dosyaAdi yükleniyor...');
      
      final dosya = File(dosyaYolu);
      if (!await dosya.exists()) {
        print('   ⚠️  Dosya bulunamadı, atlanıyor');
        continue;
      }
      
      try {
        final besinler = await besinService.loadFromAssetsOnce(dosyaYolu);
        toplamYuklenen += besinler.length;
        print('   ✅ ${besinler.length} besin yüklendi (Toplam: $toplamYuklenen)');
      } catch (e) {
        print('   ❌ Hata: $e');
      }
    }
    
    print('\n' + '=' * 60);
    print('✅ MIGRATION TAMAMLANDI!');
    print('📊 Toplam yüklenen besin: $toplamYuklenen');
    print('=' * 60);
    
    // Doğrulama
    final tumBesinler = await besinService.getAll();
    print('\n🔍 Doğrulama: Hive DB\'de ${tumBesinler.length} besin var');
    
    if (tumBesinler.isNotEmpty) {
      print('\n📋 Örnek besinler:');
      for (int i = 0; i < 5 && i < tumBesinler.length; i++) {
        final besin = tumBesinler[i];
        final ad = besin.ad;
        final kategori = besin.kategori.name;
        final kalori = besin.kalori100g.toStringAsFixed(0);
        print('   ${i + 1}. $ad ($kategori, $kalori kcal/100g)');
      }
    }
    
  } catch (e, stack) {
    print('\n❌ HATA: $e');
    print('Stack: $stack');
  }
}
