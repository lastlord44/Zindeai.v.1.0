import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/core/utils/db_summary_service.dart';

void main() async {
  print('🔍 HIVE VERİTABANI DURUM KONTROLÜ');
  print('=' * 60);
  
  try {
    // Hive'ı başlat
    await Hive.initFlutter();
    
    // Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    print('\n📦 HIVE BOX KONTROLÜ:');
    print('-' * 60);
    
    // Box'ı aç
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('✓ Box adı: ${box.name}');
    print('✓ Box path: ${box.path}');
    print('✓ Box açık mı: ${box.isOpen}');
    print('✓ Box boş mu: ${box.isEmpty}');
    print('✓ Box key sayısı: ${box.keys.length}');
    print('✓ Box value sayısı: ${box.values.length}');
    
    if (box.isEmpty) {
      print('\n❌ VERİTABANI BOŞ!');
      print('⚠️  Migration yapılmamış veya hatalı!');
      
      // Hive dosyasının fiziksel varlığını kontrol et
      if (box.path != null) {
        final boxFile = File(box.path!);
        if (await boxFile.exists()) {
          final fileSize = await boxFile.length();
          print('📁 Hive dosyası var (${fileSize} bytes)');
        } else {
          print('📁 Hive dosyası yok!');
        }
      }
    } else {
      print('\n✓ VERİTABANI DOLU!');
      print('📊 Toplam yemek: ${box.length}');
      
      // İlk 3 yemeği göster
      print('\n🍽️  İLK 3 YEMEK:');
      var count = 0;
      for (var key in box.keys) {
        if (count >= 3) break;
        final yemek = box.get(key);
        if (yemek != null) {
          print('  ${count + 1}. ${yemek.mealName} (${yemek.calorie} kcal)');
        }
        count++;
      }
    }
    
    // HiveService kontrolü
    print('\n\n🔧 HIVE SERVICE KONTROLÜ:');
    print('-' * 60);
    final sayi = await HiveService.yemekSayisi();
    print('✓ HiveService.yemekSayisi(): $sayi');
    
    // DB Summary Service kontrolü
    print('\n\n📋 DB SUMMARY SERVICE KONTROLÜ:');
    print('-' * 60);
    try {
      final summary = await DBSummaryService.getDatabaseSummary();
      print('✓ Toplam yemek: ${summary['toplamYemek']}');
      
      final kategoriler = summary['kategoriler'] as Map<String, dynamic>?;
      if (kategoriler != null) {
        kategoriler.forEach((key, value) {
          print('  - $key: $value');
        });
      }
    } catch (e) {
      print('❌ DB Summary hatası: $e');
    }
    
    // Sağlık kontrolü
    print('\n\n🏥 SAĞLIK KONTROLÜ:');
    print('-' * 60);
    try {
      final health = await DBSummaryService.healthCheck();
      print('Durum: ${health['durum']}');
      if (health['uyarilar'] != null) {
        final uyarilar = health['uyarilar'] as List;
        for (var uyari in uyarilar) {
          print('⚠️  $uyari');
        }
      }
    } catch (e) {
      print('❌ Health check hatası: $e');
    }
    
    await box.close();
    
  } catch (e, stackTrace) {
    print('\n❌ HATA: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n' + '=' * 60);
  print('✅ Kontrol tamamlandı');
}
