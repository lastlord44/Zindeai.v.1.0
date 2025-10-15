// 500 YENİ SAĞLIKLI YEMEK YÜKLEME SCRİPTİ
// Batch 20-24 (500 yemek): Kahvaltı, Öğle, Akşam, Ara Öğün 1, Ara Öğün 2

import 'package:hive/hive.dart';
import 'dart:io';
import 'lib/data/models/yemek_hive_model.dart';

// Batch dosyalarını import et
import 'lib/mega_yemek_batch_20_kahvalti_saglikli.dart';
import 'lib/mega_yemek_batch_21_ogle_saglikli.dart';
import 'lib/mega_yemek_batch_22_aksam_saglikli.dart';
import 'lib/mega_yemek_batch_23_ara_ogun_1.dart';
import 'lib/mega_yemek_batch_24_29_ara_ogun_2.dart';

void main() async {
  print('📦 500 YENİ SAĞLIKLI YEMEK YÜKLEME BAŞLIYOR...\n');
  
  try {
    // Hive'ı başlat
    final appDir = Directory.current.path;
    final hiveDir = Directory('$appDir/hive_db');
    
    if (!hiveDir.existsSync()) {
      hiveDir.createSync(recursive: true);
    }
    
    Hive.init(hiveDir.path);
    
    // Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    // Box'ı aç (FİZİKSEL DOSYA ADI: yemekler.hive)
    print('🔓 Box açılıyor: yemekler');
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    
    final baslangicSayisi = box.length;
    print('📊 Mevcut yemek sayısı: $baslangicSayisi\n');
    
    // BATCH 20: Kahvaltı (50 yemek)
    print('⏳ Batch 20 - Kahvaltı yükleniyor...');
    final batch20 = getMegaYemekBatch20();
    int yuklenenBatch20 = 0;
    for (var jsonYemek in batch20) {
      final yemek = YemekHiveModel.fromJson(jsonYemek);
      await box.put(yemek.mealId, yemek);
      yuklenenBatch20++;
    }
    print('✅ Batch 20 tamamlandı: $yuklenenBatch20 kahvaltı yemeği\n');
    
    // BATCH 21: Öğle (50 yemek)
    print('⏳ Batch 21 - Öğle yükleniyor...');
    final batch21 = getMegaYemekBatch21();
    int yuklenenBatch21 = 0;
    for (var jsonYemek in batch21) {
      final yemek = YemekHiveModel.fromJson(jsonYemek);
      await box.put(yemek.mealId, yemek);
      yuklenenBatch21++;
    }
    print('✅ Batch 21 tamamlandı: $yuklenenBatch21 öğle yemeği\n');
    
    // BATCH 22: Akşam (50 yemek)
    print('⏳ Batch 22 - Akşam yükleniyor...');
    final batch22 = getMegaYemekBatch22();
    int yuklenenBatch22 = 0;
    for (var jsonYemek in batch22) {
      final yemek = YemekHiveModel.fromJson(jsonYemek);
      await box.put(yemek.mealId, yemek);
      yuklenenBatch22++;
    }
    print('✅ Batch 22 tamamlandı: $yuklenenBatch22 akşam yemeği\n');
    
    // BATCH 23: Ara Öğün 1 (50 yemek)
    print('⏳ Batch 23 - Ara Öğün 1 yükleniyor...');
    final batch23 = getMegaYemekBatch23();
    int yuklenenBatch23 = 0;
    for (var jsonYemek in batch23) {
      final yemek = YemekHiveModel.fromJson(jsonYemek);
      await box.put(yemek.mealId, yemek);
      yuklenenBatch23++;
    }
    print('✅ Batch 23 tamamlandı: $yuklenenBatch23 ara öğün 1 yemeği\n');
    
    // BATCH 24-29: Ara Öğün 2 (300 yemek)
    print('⏳ Batch 24-29 - Ara Öğün 2 yükleniyor...');
    final batch24_29 = getMegaYemekBatch24_29();
    int yuklenenBatch24_29 = 0;
    for (var jsonYemek in batch24_29) {
      final yemek = YemekHiveModel.fromJson(jsonYemek);
      await box.put(yemek.mealId, yemek);
      yuklenenBatch24_29++;
    }
    print('✅ Batch 24-29 tamamlandı: $yuklenenBatch24_29 ara öğün 2 yemeği\n');
    
    // Sonuç
    final bitisSayisi = box.length;
    final eklenenToplam = bitisSayisi - baslangicSayisi;
    
    print('═══════════════════════════════════════════');
    print('🎉 YÜKLEME TAMAMLANDI!');
    print('═══════════════════════════════════════════');
    print('📈 Önceki yemek sayısı: $baslangicSayisi');
    print('📈 Yeni yemek sayısı: $bitisSayisi');
    print('➕ Eklenen toplam: $eklenenToplam yemek');
    print('');
    print('📋 DETAY:');
    print('  • Batch 20 (Kahvaltı): $yuklenenBatch20 yemek');
    print('  • Batch 21 (Öğle): $yuklenenBatch21 yemek');
    print('  • Batch 22 (Akşam): $yuklenenBatch22 yemek');
    print('  • Batch 23 (Ara Öğün 1): $yuklenenBatch23 yemek');
    print('  • Batch 24-29 (Ara Öğün 2): $yuklenenBatch24_29 yemek');
    print('═══════════════════════════════════════════\n');
    
    await box.close();
    print('✅ Box kapatıldı. İşlem başarılı!');
    
  } catch (e, stackTrace) {
    print('❌ HATA OLUŞTU: $e');
    print('Stack Trace: $stackTrace');
    exit(1);
  }
  
  exit(0);
}
