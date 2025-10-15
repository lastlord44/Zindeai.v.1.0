import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';

// MEGA YEMEK BATCH IMPORT
import 'mega_yemek_batch_1_kahvalti.dart';
import 'mega_yemek_batch_2_kahvalti.dart';
import 'mega_yemek_batch_3_kahvalti.dart';
import 'mega_yemek_batch_4_ogle.dart';
import 'mega_yemek_batch_5_ogle.dart';
import 'mega_yemek_batch_6_ogle.dart';
import 'mega_yemek_batch_7_ogle.dart';
import 'mega_yemek_batch_8_aksam.dart';
import 'mega_yemek_batch_9_aksam.dart';
import 'mega_yemek_batch_10_aksam.dart';
import 'mega_yemek_batch_11_aksam.dart';
import 'mega_yemek_batch_12_ara_ogun_1.dart';
import 'mega_yemek_batch_13_ara_ogun_1.dart';
import 'mega_yemek_batch_14_ara_ogun_1.dart';
import 'mega_yemek_batch_15_ara_ogun_2.dart';
import 'mega_yemek_batch_16_ara_ogun_2.dart';
import 'mega_yemek_batch_17_ara_ogun_2.dart';
import 'mega_yemek_batch_18_ara_ogun_2.dart';
import 'mega_yemek_batch_19_ara_ogun_2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n');
  print('═══════════════════════════════════════════════════════');
  print('🔥 MEGA YEMEKLER YÜKLENİYOR - ESKİ DB SİLİNİYOR!');
  print('═══════════════════════════════════════════════════════\n');

  try {
    // 1. Hive'ı başlat
    print('📦 Hive başlatılıyor...');
    await Hive.initFlutter();
    
    // 2. Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
      print('✅ Adapter kaydedildi');
    }
    
    // 3. Box'ı aç
    await Hive.openBox<YemekHiveModel>('yemekler');
    print('✅ Yemekler box\'ı açıldı\n');

    // 4. ESKİ DB'Yİ SİL!
    print('🗑️ ESKİ VERİTABANI SİLİNİYOR...');
    final eskiSayi = await HiveService.yemekSayisi();
    await HiveService.tumYemekleriSil();
    print('✅ $eskiSayi eski yemek silindi\n');

    // 5. MEGA YEMEKLERİ YÜKLE!
    print('🚀 MEGA YEMEKLER YÜKLENİYOR...\n');
    
    int toplamYuklenen = 0;
    int basarili = 0;
    int hatali = 0;

    // Tüm batch'leri al
    final batches = [
      {'name': 'Kahvaltı Batch 1', 'data': getMegaYemekBatch1()},
      {'name': 'Kahvaltı Batch 2', 'data': getMegaYemekBatch2()},
      {'name': 'Kahvaltı Batch 3', 'data': getMegaYemekBatch3()},
      {'name': 'Öğle Batch 4', 'data': getMegaYemekBatch4()},
      {'name': 'Öğle Batch 5', 'data': getMegaYemekBatch5()},
      {'name': 'Öğle Batch 6', 'data': getMegaYemekBatch6()},
      {'name': 'Öğle Batch 7', 'data': getMegaYemekBatch7()},
      {'name': 'Akşam Batch 8', 'data': getMegaYemekBatch8()},
      {'name': 'Akşam Batch 9', 'data': getMegaYemekBatch9()},
      {'name': 'Akşam Batch 10', 'data': getMegaYemekBatch10()},
      {'name': 'Akşam Batch 11', 'data': getMegaYemekBatch11()},
      {'name': 'Ara Öğün 1 Batch 12', 'data': getMegaYemekBatch12()},
      {'name': 'Ara Öğün 1 Batch 13', 'data': getMegaYemekBatch13()},
      {'name': 'Ara Öğün 1 Batch 14', 'data': getMegaYemekBatch14()},
      {'name': 'Ara Öğün 2 Batch 15', 'data': getMegaYemekBatch15()},
      {'name': 'Ara Öğün 2 Batch 16', 'data': getMegaYemekBatch16()},
      {'name': 'Ara Öğün 2 Batch 17', 'data': getMegaYemekBatch17()},
      {'name': 'Ara Öğün 2 Batch 18', 'data': getMegaYemekBatch18()},
      {'name': 'Ara Öğün 2 Batch 19', 'data': getMegaYemekBatch19()},
    ];

    // Her batch'i yükle
    for (final batch in batches) {
      final batchName = batch['name'] as String;
      final batchData = batch['data'] as List<Map<String, dynamic>>;
      
      print('📂 $batchName işleniyor... (${batchData.length} yemek)');
      
      int batchBasarili = 0;
      int batchHatali = 0;
      
      for (final yemekJson in batchData) {
        try {
          final yemekModel = YemekHiveModel.fromJson(yemekJson);
          await HiveService.yemekKaydet(yemekModel);
          batchBasarili++;
          basarili++;
        } catch (e) {
          batchHatali++;
          hatali++;
          print('   ❌ Hata: ${yemekJson['isim']} - $e');
        }
      }
      
      toplamYuklenen += batchData.length;
      print('   ✅ $batchBasarili başarılı, $batchHatali hatalı\n');
    }

    // 6. SONUÇ
    print('═══════════════════════════════════════════════════════');
    print('🎉 MEGA YEMEKLER YÜKLENDİ!');
    print('═══════════════════════════════════════════════════════');
    print('📊 Toplam: $toplamYuklenen yemek');
    print('✅ Başarılı: $basarili');
    print('❌ Hatalı: $hatali\n');

    // 7. Kategori dağılımını göster
    final kategoriSayilari = await HiveService.kategoriSayilari();
    print('📊 Kategori Dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   • $kategori: $sayi yemek');
    });

    print('\n✨ ARTIK SADECE MEGA YEMEKLER KULLANILIYOR!');
    print('═══════════════════════════════════════════════════════\n');

  } catch (e, stackTrace) {
    print('\n❌❌❌ KRİTİK HATA! ❌❌❌');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
  }
}
