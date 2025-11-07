// Yabancı besinleri Hive DB'den temizleyen standalone script
// Flutter bağımlılığı yok, sadece Hive

import 'dart:io';
import 'package:hive/hive.dart';

void main() async {
  print('🧹 Yabancı Besin Temizleme Scripti Başlatılıyor...\n');

  // Hive'ı başlat
  final appDir = Directory.current.path;
  Hive.init('$appDir/hive_data');

  try {
    // Yemek box'ını aç
    final box = await Hive.openBox('yemekler');
    print('📦 Hive box açıldı: ${box.length} yemek bulundu\n');

    // Yabancı besin listesi (Türk mutfağında olmayan)
    final yabanciBesinler = [
      'tempeh',
      'quinoa', 
      'kinoa',
      'tofu',
      'edamame',
      'kimchi',
      'kombucha',
      'seitan',
      'miso',
      'tahini', // Tahinden farklı
      'hummus',
      'falafel',
      'couscous',
      'kuskus',
      'bulgur wheat',
      'chia',
      'acai',
      'goji',
      'spirulina',
      'matcha',
      'kale',
      'arugula',
      'rocket',
      'roka', // Türk'te yok genelde
      'bok choy',
      'nori',
      'wakame',
      'sushi',
      'sashimi',
      'wasabi',
      'sriracha',
      'paneer',
      'ghee',
      'naan',
      'basmati',
      'jasmine rice',
      'pad thai',
      'pho',
      'ramen',
      'udon',
      'soba',
      'mochi',
      'burrito',
      'taco',
      'quesadilla',
      'guacamole',
      'salsa',
      'tortilla',
      'enchilada',
      'chimichanga',
      'fajita',
      'nachos',
      'paella',
      'risotto',
      'gnocchi',
      'ravioli',
      'pesto',
      'bruschetta',
      'ciabatta',
      'focaccia',
      'bagel',
      'croissant',
      'baguette',
      'prosciutto',
      'salami',
      'chorizo',
      'pancetta',
      'brie',
      'camembert',
      'gorgonzola',
      'parmesan',
      'mozzarella',
      'ricotta',
      'mascarpone',
      'cheddar',
      'gouda',
      'swiss',
      'blue cheese',
      'cottage cheese',
      'cream cheese',
    ];

    int silinenSayisi = 0;
    final silinecekKeys = <dynamic>[];

    // Yabancı besinleri bul
    for (var key in box.keys) {
      try {
        final yemek = box.get(key);
        if (yemek is Map) {
          final mealName = (yemek['meal_name'] ?? yemek['mealName'] ?? yemek['ad'] ?? yemek['isim'] ?? '').toString().toLowerCase();
          final ingredients = (yemek['ingredients'] ?? yemek['malzemeler'] ?? []) as List;
          
          // Yemek adında yabancı besin var mı?
          bool yabanciMi = false;
          String? bulunanYabanci;
          
          for (var yabanci in yabanciBesinler) {
            if (mealName.contains(yabanci.toLowerCase())) {
              yabanciMi = true;
              bulunanYabanci = yabanci;
              break;
            }
          }
          
          // Malzemelerde yabancı besin var mı?
          if (!yabanciMi) {
            for (var malzeme in ingredients) {
              final malzemeStr = malzeme.toString().toLowerCase();
              for (var yabanci in yabanciBesinler) {
                if (malzemeStr.contains(yabanci.toLowerCase())) {
                  yabanciMi = true;
                  bulunanYabanci = yabanci;
                  break;
                }
              }
              if (yabanciMi) break;
            }
          }
          
          if (yabanciMi) {
            silinecekKeys.add(key);
            print('🗑️  Siliniyor: $mealName (içerik: $bulunanYabanci)');
            silinenSayisi++;
          }
        }
      } catch (e) {
        print('⚠️  Hata (key: $key): $e');
      }
    }

    // Toplu silme
    print('\n📊 Toplam $silinenSayisi yabancı besin bulundu');
    
    if (silinenSayisi > 0) {
      print('🔄 Silme işlemi başlatılıyor...');
      for (var key in silinecekKeys) {
        await box.delete(key);
      }
      print('✅ Silme tamamlandı!');
    } else {
      print('✅ Yabancı besin bulunamadı, veritabanı temiz!');
    }

    print('\n📦 Kalan yemek sayısı: ${box.length}');
    
    // Box'ı kapat
    await box.close();
    await Hive.close();
    
    print('\n🎉 Temizleme işlemi başarıyla tamamlandı!');
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('Stack: $stackTrace');
    exit(1);
  }
}