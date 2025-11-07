// PURE HIVE DB DURUM KONTROLÜ
import 'dart:io';
import 'package:hive/hive.dart';

Future<void> main() async {
  print('📊 === PURE HIVE DB DURUM ANALİZİ ===\n');
  
  try {
    // Hive setup (pure)
    Hive.init('./hive_data');
    
    // Box'ı aç
    final box = await Hive.openBox('yemekler');
    
    print('🗂️  BOX BİLGİLERİ:');
    print('   Box ismi: ${box.name}');
    print('   Box path: ${box.path}');
    print('   Toplam entry: ${box.length}');
    print('   Box açık mı: ${box.isOpen}');
    print('   Box keys: ${box.keys.take(5).toList()}'); // İlk 5 key
    
    if (box.isEmpty) {
      print('\n❌ BOX TAMAMEN BOŞ! Migration hiç çalışmamış.');
      print('   🔄 Yemek verilerini baştan yüklemek gerekiyor.\n');
      await box.close();
      return;
    }
    
    print('\n📈 RAW VERİ ANALİZİ:');
    
    int toplamEntry = 0;
    int gecerliEntry = 0;
    int bozukEntry = 0;
    
    final kaloriBilgileri = <double>[];
    final kategoriler = <String, int>{};
    
    for (var entry in box.toMap().entries) {
      toplamEntry++;
      try {
        final data = entry.value;
        
        if (data == null) {
          bozukEntry++;
          continue;
        }
        
        // Basit Map kontrolü
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          
          // Temel alanlar var mı?
          if (mapData.containsKey('mealName') && mapData.containsKey('calories')) {
            gecerliEntry++;
            
            // Kalori bilgisi
            final kalori = mapData['calories'];
            if (kalori != null && kalori is num) {
              kaloriBilgileri.add(kalori.toDouble());
            }
            
            // Kategori bilgisi  
            final kategori = mapData['category']?.toString() ?? 'Bilinmeyen';
            kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
            
          } else {
            bozukEntry++;
          }
        } else {
          bozukEntry++;
        }
      } catch (e) {
        bozukEntry++;
        print('   ⚠️ Entry parse hatası: $e');
      }
    }
    
    print('   ✅ Geçerli entry: $gecerliEntry');
    print('   ❌ Bozuk entry: $bozukEntry');
    print('   📊 Başarı oranı: ${(gecerliEntry / toplamEntry * 100).toStringAsFixed(1)}%');
    
    // Kalori analizi
    if (kaloriBilgileri.isNotEmpty) {
      kaloriBilgileri.sort();
      final minKalori = kaloriBilgileri.first;
      final maxKalori = kaloriBilgileri.last;
      final ortKalori = kaloriBilgileri.reduce((a, b) => a + b) / kaloriBilgileri.length;
      
      print('\n🔥 KALORİ ANALİZİ:');
      print('   Min: ${minKalori.toInt()} kcal');
      print('   Max: ${maxKalori.toInt()} kcal');
      print('   Ortalama: ${ortKalori.toInt()} kcal');
      print('   0 kalori yemek: ${kaloriBilgileri.where((k) => k <= 0).length}');
      print('   Çok düşük (<50): ${kaloriBilgileri.where((k) => k > 0 && k < 50).length}');
      print('   Normal (50-800): ${kaloriBilgileri.where((k) => k >= 50 && k <= 800).length}');
      print('   Yüksek (>800): ${kaloriBilgileri.where((k) => k > 800).length}');
    }
    
    // Top kategoriler
    if (kategoriler.isNotEmpty) {
      print('\n🏷️  TOP KATEGORİLER:');
      final sortedKategoriler = kategoriler.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (int i = 0; i < 10 && i < sortedKategoriler.length; i++) {
        final entry = sortedKategoriler[i];
        print('   ${entry.key}: ${entry.value} yemek');
      }
    }
    
    // Örnek yemekler
    print('\n🍽️  ÖRNEK YEMEKLER:');
    int ornekSayac = 0;
    for (var entry in box.toMap().entries) {
      if (ornekSayac >= 5) break;
      try {
        final data = entry.value;
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          final name = mapData['mealName']?.toString() ?? 'İsimsiz';
          final calories = mapData['calories'] ?? 0;
          final category = mapData['category']?.toString() ?? '?';
          
          if (calories > 0) {
            print('   ${ornekSayac + 1}. $name - ${calories} kcal ($category)');
            ornekSayac++;
          }
        }
      } catch (e) {
        // Skip
      }
    }
    
    // Final değerlendirme
    final basariOrani = gecerliEntry / toplamEntry * 100;
    print('\n🎯 FINAL DEĞERLENDİRME:');
    
    if (basariOrani >= 80 && gecerliEntry >= 1000) {
      print('   ✅ DB DURUMU İYİ');
      print('   🚀 ${gecerliEntry} kullanılabilir yemek var');
      print('   👍 V5.1 sistemi ile devam edilebilir');
    } else if (basariOrani >= 50 && gecerliEntry >= 500) {
      print('   ⚠️  DB DURUMU ORTA');
      print('   🔧 ${gecerliEntry} yemek var ama temizleme gerek');
      print('   💡 Bozuk verileri filtrele ve devam et');
    } else {
      print('   ❌ DB DURUMU KÖTÜ');
      print('   📊 Sadece ${gecerliEntry} geçerli yemek');
      print('   🔄 YENİDEN MİGRATION YAPILMALI');
    }
    
    await box.close();
    
  } catch (e, stack) {
    print('❌ ANALİZ HATASI: $e');
    print('Stack: $stack');
  }
  
  print('\n=============================');
}