// 500 YENİ YEMEK MİGRATION MANUEL TEST
// Bu script migration'ı direkt çalıştırır ve tüm hataları gösterir

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/core/utils/app_logger.dart';
import 'lib/core/utils/yemek_migration_500_yeni.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('═══════════════════════════════════════════════════════════');
  print('🔧 500 YENİ YEMEK MİGRATION MANUEL TEST BAŞLIYOR...');
  print('═══════════════════════════════════════════════════════════\n');
  
  try {
    // 1. Hive'ı başlat
    print('📦 Hive başlatılıyor...');
    await Hive.initFlutter();
    Hive.registerAdapter(YemekHiveModelAdapter());
    print('✅ Hive başlatıldı\n');
    
    // 2. Box'ı aç
    print('📂 Yemekler box\'ı açılıyor...');
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('✅ Box açıldı\n');
    
    // 3. Mevcut durum
    print('📊 MEVCUT DURUM:');
    print('   Toplam yemek: ${box.length}');
    
    // Kategori sayıları
    final kategoriler = <String, int>{};
    for (var yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
    }
    print('\n   Kategori Dağılımı:');
    kategoriler.forEach((kategori, sayi) {
      print('     - $kategori: $sayi yemek');
    });
    print('');
    
    // 4. Migration gerekli mi kontrol et
    print('🔍 Migration gerekli mi kontrol ediliyor...');
    final gerekliMi = await Yemek500Migration.migrationGerekliMi();
    print('   Sonuç: ${gerekliMi ? "✅ EVET, migration gerekli" : "❌ HAYIR, zaten yüklü"}\n');
    
    if (!gerekliMi) {
      print('⚠️  Migration gerekli değil ama kontrol için ID\'leri doğrulayalım:\n');
      final ornekIDler = ['K951', 'O1001', 'A1001', 'AO1_1001', 'AO2_1001'];
      for (final id in ornekIDler) {
        final varMi = box.containsKey(id);
        if (varMi) {
          final yemek = box.get(id);
          print('   $id: ✅ VAR - ${yemek?.mealName}');
        } else {
          print('   $id: ❌ YOK!');
        }
      }
      print('');
    }
    
    // 5. Migration'ı çalıştır (gerekli olsun olmasın)
    print('═══════════════════════════════════════════════════════════');
    print('🚀 MİGRATION ÇALIŞTIRILIYOR (zorla)...');
    print('═══════════════════════════════════════════════════════════\n');
    
    final basarili = await Yemek500Migration.migrate500NewMeals();
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print(basarili ? '✅ MİGRATION BAŞARILI!' : '❌ MİGRATION BAŞARISIZ!');
    print('═══════════════════════════════════════════════════════════\n');
    
    // 6. Yeni durum
    print('📊 YENİ DURUM:');
    print('   Toplam yemek: ${box.length}');
    
    // Yeni kategori sayıları
    final yeniKategoriler = <String, int>{};
    for (var yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      yeniKategoriler[kategori] = (yeniKategoriler[kategori] ?? 0) + 1;
    }
    print('\n   Kategori Dağılımı:');
    yeniKategoriler.forEach((kategori, sayi) {
      print('     - $kategori: $sayi yemek');
    });
    print('');
    
    // 7. Örnek yemekleri göster
    print('📝 500 YENİ YEMEKTEN ÖRNEKLER:\n');
    final yeniIDler = ['K951', 'K955', 'O1001', 'O1005', 'A1001', 'A1005', 
                        'AO1_1001', 'AO1_1005', 'AO2_1001', 'AO2_1050'];
    
    for (final id in yeniIDler) {
      final yemek = box.get(id);
      if (yemek != null) {
        print('   ✅ $id: ${yemek.mealName}');
        print('      Kalori: ${yemek.calorie?.toStringAsFixed(0)} kcal, '
              'Protein: ${yemek.proteinG?.toStringAsFixed(1)}g, '
              'Kategori: ${yemek.category}');
      } else {
        print('   ❌ $id: BULUNAMADI!');
      }
    }
    
    print('\n═══════════════════════════════════════════════════════════');
    print('✅ TEST TAMAMLANDI!');
    print('═══════════════════════════════════════════════════════════');
    
    await box.close();
    
  } catch (e, stackTrace) {
    print('\n❌ HATA OLUŞTU!');
    print('═══════════════════════════════════════════════════════════');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
    print('═══════════════════════════════════════════════════════════');
  }
}
