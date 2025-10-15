import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔍 VERİTABANI DURUM KONTROLÜ BAŞLIYOR...\n');
  
  try {
    // Hive başlat (Flutter olmadan)
    final appDir = Directory.current.path;
    Hive.init('$appDir/hive_db');
    Hive.registerAdapter(YemekHiveModelAdapter());
    
    print('✅ Hive başlatıldı\n');
    
    // Toplam yemek sayısı
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    final toplamYemek = box.length;
    
    print('📊 TOPLAM YEMEK SAYISI: $toplamYemek');
    
    if (toplamYemek == 0) {
      print('❌ VERİTABANI BOŞ! Migration çalışmamış.');
      print('\n🔧 ÇÖZÜM: Migration çalıştırılması gerekiyor.');
      print('   Komut: dart mega_yemekleri_yukle.dart\n');
      await box.close();
      await Hive.close();
      return;
    }
    
    print('\n📈 KATEGORİ BAZINDA DAĞILIM:');
    print('=' * 50);
    
    // Her kategori için say
    final kategoriler = {
      'Kahvaltı': 'Kahvaltı',
      'Ara Öğün 1': 'Ara Öğün 1',
      'Öğle': 'Öğle',
      'Ara Öğün 2': 'Ara Öğün 2',
      'Akşam': 'Akşam',
    };
    
    for (var entry in kategoriler.entries) {
      final count = box.values.where((y) => 
        y.category?.toLowerCase().contains(entry.value.toLowerCase()) ?? false
      ).length;
      print('${entry.key.padRight(15)}: $count yemek');
    }
    
    print('\n🔍 ÖRNEK YEMEKLER (İlk 5 yemek):');
    print('=' * 50);
    
    final ilk5 = box.values.take(5).toList();
    for (var i = 0; i < ilk5.length; i++) {
      final yemek = ilk5[i];
      print('\n${i + 1}. ${yemek.mealName ?? "İsimsiz"}');
      print('   Kategori: ${yemek.category ?? "Yok"}');
      print('   Kalori: ${yemek.calorie ?? 0} kcal');
      print('   Protein: ${yemek.proteinG ?? 0}g');
      print('   Karbonhidrat: ${yemek.carbG ?? 0}g');
      print('   Yağ: ${yemek.fatG ?? 0}g');
      print('   Meal ID: ${yemek.mealId ?? "Yok"}');
      
      // Null kontrolü
      if (yemek.mealName == null || yemek.mealName!.isEmpty) {
        print('   ⚠️ İsim boş veya null!');
      }
      if (yemek.calorie == null || yemek.calorie == 0) {
        print('   ⚠️ Kalori null veya 0!');
      }
    }
    
    // Kategori bazında örnek
    print('\n🔍 KATEGORİ BAZINDA ÖRNEKLER:');
    print('=' * 50);
    
    for (var entry in kategoriler.entries) {
      final kategoriYemekleri = box.values.where((y) => 
        y.category?.toLowerCase().contains(entry.value.toLowerCase()) ?? false
      ).toList();
      
      if (kategoriYemekleri.isNotEmpty) {
        final ornek = kategoriYemekleri.first;
        print('\n${entry.key}:');
        print('  ${ornek.mealName} - ${ornek.calorie} kcal');
      } else {
        print('\n${entry.key}: ❌ Yemek yok!');
      }
    }
    
    print('\n✅ Veritabanı kontrolü tamamlandı');
    
    await box.close();
    await Hive.close();
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('Stack Trace: $stackTrace');
  }
}
