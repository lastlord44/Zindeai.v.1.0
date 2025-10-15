// 500 YENİ YEMEK DOĞRULAMA TESTİ

import 'package:hive/hive.dart';
import 'dart:io';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔍 500 YENİ YEMEK DOĞRULAMA TESTİ BAŞLIYOR...\n');
  
  try {
    // Hive'ı başlat
    final appDir = Directory.current.path;
    final hiveDir = Directory('$appDir/hive_db');
    
    Hive.init(hiveDir.path);
    
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('📊 GENEL DURUM:');
    print('═══════════════════════════════════════════');
    print('Toplam yemek sayısı: ${box.length}');
    print('');
    
    // Kategori bazında sayım
    final kategoriler = <String, int>{};
    final yeniYemekler = <String, List<String>>{};
    
    for (var yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmiyor';
      kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
      
      // Yeni eklenen yemekleri tespit et (ID'leri kontrol et)
      final id = yemek.mealId ?? '';
      if (id.startsWith('K95') || id.startsWith('K96') || id.startsWith('K97') || 
          id.startsWith('K98') || id.startsWith('K99') || id.startsWith('K100') ||
          id.startsWith('O100') || id.startsWith('O101') || id.startsWith('O102') || 
          id.startsWith('O103') || id.startsWith('O104') || id.startsWith('O105') ||
          id.startsWith('A100') || id.startsWith('A101') || id.startsWith('A102') || 
          id.startsWith('A103') || id.startsWith('A104') || id.startsWith('A105') ||
          id.startsWith('AO1_100') || id.startsWith('AO1_101') || id.startsWith('AO1_102') ||
          id.startsWith('AO2_1')) {
        yeniYemekler.putIfAbsent(kategori, () => []);
        yeniYemekler[kategori]!.add('$id: ${yemek.mealName}');
      }
    }
    
    print('📋 KATEGORİ BAZINDA DAĞILIM:');
    print('═══════════════════════════════════════════');
    kategoriler.forEach((kategori, sayi) {
      print('  • $kategori: $sayi yemek');
    });
    print('');
    
    print('🆕 YENİ EKLENEN YEMEKLER (Batch 20-24):');
    print('═══════════════════════════════════════════');
    var toplamYeni = 0;
    yeniYemekler.forEach((kategori, yemekListesi) {
      print('\n$kategori (${yemekListesi.length} adet):');
      // İlk 5 örneği göster
      for (var i = 0; i < (yemekListesi.length > 5 ? 5 : yemekListesi.length); i++) {
        print('  ${i + 1}. ${yemekListesi[i]}');
      }
      if (yemekListesi.length > 5) {
        print('  ... ve ${yemekListesi.length - 5} yemek daha');
      }
      toplamYeni += yemekListesi.length;
    });
    print('');
    print('═══════════════════════════════════════════');
    print('✅ Yeni eklenen toplam: $toplamYeni yemek');
    print('');
    
    // Örnek yemekleri göster
    print('🍽️  ÖRNEK YEMEKLER (İlk 10):');
    print('═══════════════════════════════════════════');
    var counter = 0;
    for (var yemek in box.values) {
      if (counter >= 10) break;
      print('${counter + 1}. ${yemek.mealName} (${yemek.category})');
      print('   Protein: ${yemek.proteinG}g | Karb: ${yemek.carbG}g | Yağ: ${yemek.fatG}g | Kalori: ${yemek.calorie}');
      print('');
      counter++;
    }
    
    await box.close();
    print('✅ Test tamamlandı!');
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('Stack Trace: $stackTrace');
    exit(1);
  }
  
  exit(0);
}
