import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

/// 🔍 FİNAL SİSTEM KONTROLÜ VE DOĞRULAMA
void main() async {
  print('🔍 FİNAL SİSTEM KONTROLÜ BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başlatıldı - Yemek sayısı: ${box.length}');
    
    print('\n2️⃣ KATEGORİ DAĞILIMI KONTROLÜ:');
    final kategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Güncel kategori dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n3️⃣ ANA YEMEK KARIŞIKLIĞI KONTROLÜ:');
    
    final anaYemekMalzemeleri = [
      'dana', 'kuzu', 'et', 'köfte', 'kıyma', 'kuşbaşı', 'tavuk', 'piliç', 
      'ton balığı', 'ton', 'somon', 'balık', 'fish', 'hindi', 'makarna',
    ];
    
    int kahvaltiAnaYemek = 0;
    int ara1AnaYemek = 0; 
    int ara2AnaYemek = 0;
    
    final sorunluOrnekler = <String>[];
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      final tumText = '$mealName $malzemeler';
      
      bool anaYemekMi = false;
      for (final malzeme in anaYemekMalzemeleri) {
        if (tumText.contains(malzeme)) {
          anaYemekMi = true;
          break;
        }
      }
      
      if (anaYemekMi) {
        if (kategori.contains('kahvalt')) {
          kahvaltiAnaYemek++;
          if (sorunluOrnekler.length < 3) {
            sorunluOrnekler.add('KAHVALTI: ${yemek.mealName}');
          }
        } else if (kategori.contains('ara') && (kategori.contains('1') || kategori == 'ara1')) {
          ara1AnaYemek++;
          if (sorunluOrnekler.length < 3) {
            sorunluOrnekler.add('ARA ÖĞÜN 1: ${yemek.mealName}');
          }
        } else if (kategori.contains('ara') && (kategori.contains('2') || kategori == 'ara2')) {
          ara2AnaYemek++;
          if (sorunluOrnekler.length < 3) {
            sorunluOrnekler.add('ARA ÖĞÜN 2: ${yemek.mealName}');
          }
        }
      }
    }
    
    print('   📊 Ana yemek karışıklığı durumu:');
    print('   🚨 Kahvaltıda ana yemek: $kahvaltiAnaYemek adet');
    print('   🚨 Ara Öğün 1\'de ana yemek: $ara1AnaYemek adet');  
    print('   🚨 Ara Öğün 2\'de ana yemek: $ara2AnaYemek adet');
    
    if (sorunluOrnekler.isNotEmpty) {
      print('   ⚠️ Örnek sorunlu yemekler:');
      sorunluOrnekler.forEach((sorun) {
        print('   🔍 $sorun');
      });
    } else {
      print('   ✅ HİÇ ANA YEMEK KARIŞIKLIĞI YOK!');
    }
    
    print('\n4️⃣ GEREKSIZ MALZEME KONTROLÜ:');
    
    final gereksizler = [
      'kimyon', 'tuz', 'karabiber', 'sumak', 'nane', 'maydanoz',
      'limon', 'sirke', 'hardal', 'sarımsak',
    ];
    
    int gereksizMalzemeSayisi = 0;
    final gereksizOrnekler = <String>[];
    
    for (final yemek in box.values) {
      if (yemek.ingredients == null) continue;
      
      for (final malzeme in yemek.ingredients!) {
        final malzemeLower = malzeme.toLowerCase();
        
        for (final gereksiz in gereksizler) {
          if (malzemeLower.contains(gereksiz)) {
            gereksizMalzemeSayisi++;
            if (gereksizOrnekler.length < 5) {
              gereksizOrnekler.add('${yemek.mealName}: "$malzeme"');
            }
            break;
          }
        }
      }
    }
    
    print('   📊 Gereksiz malzeme durumu: $gereksizMalzemeSayisi adet');
    
    if (gereksizOrnekler.isNotEmpty) {
      print('   ⚠️ Örnek gereksiz malzemeler:');
      gereksizOrnekler.take(3).forEach((ornek) {
        print('   🧂 $ornek');
      });
    } else {
      print('   ✅ HİÇ GEREKSIZ MALZEME YOK!');
    }
    
    print('\n5️⃣ MALZEME KALİTESİ VE ÇEŞİTLİLİK KONTROLÜ:');
    
    int temizYemekSayisi = 0;
    int malzemesizYemekSayisi = 0;
    final kaliteliOrnekler = <String>[];
    
    for (final yemek in box.values) {
      if (yemek.ingredients == null || yemek.ingredients!.isEmpty) {
        malzemesizYemekSayisi++;
        continue;
      }
      
      // Kaliteli malzeme kontrolü
      final malzemeSayisi = yemek.ingredients!.length;
      if (malzemeSayisi >= 2 && malzemeSayisi <= 5) {
        temizYemekSayisi++;
        if (kaliteliOrnekler.length < 5) {
          kaliteliOrnekler.add('${yemek.mealName} (${malzemeSayisi} malzeme)');
        }
      }
    }
    
    print('   📊 Malzeme kalitesi:');
    print('   ✅ Temiz yemek (2-5 malzeme): $temizYemekSayisi adet');
    print('   ⚠️ Malzemesiz yemek: $malzemesizYemekSayisi adet');
    
    if (kaliteliOrnekler.isNotEmpty) {
      print('   🍽️ Örnek kaliteli yemekler:');
      kaliteliOrnekler.forEach((ornek) {
        print('   ✨ $ornek');
      });
    }
    
    print('\n6️⃣ MAKRO BEŞİN DEĞERİ KONTROLÜ:');
    
    int kaloriSizYemek = 0;
    int proteinSizYemek = 0;  
    int idealYemekSayisi = 0;
    
    for (final yemek in box.values) {
      final kalori = yemek.calorie ?? 0;
      final protein = yemek.proteinG ?? 0;
      
      if (kalori <= 0) kaloriSizYemek++;
      if (protein <= 0) proteinSizYemek++;
      
      if (kalori > 50 && protein > 3) {
        idealYemekSayisi++;
      }
    }
    
    print('   📊 Makro besin değerleri:');
    print('   ⚠️ Kalorisiz yemek: $kaloriSizYemek adet');
    print('   ⚠️ Proteinsiz yemek: $proteinSizYemek adet');
    print('   ✅ İdeal makrolu yemek: $idealYemekSayisi adet');
    
    print('\n7️⃣ KATEGORI BAZINDAKİ ÖRNEKLERİ GÖSTER:');
    
    final kategorileriGoster = ['kahvalti', 'ara1', 'ara2', 'ogle', 'aksam'];
    
    for (final kategori in kategorileriGoster) {
      final kategoriYemekleri = box.values.where((y) => 
        (y.category?.toLowerCase() ?? '').contains(kategori)).take(3);
      
      if (kategoriYemekleri.isNotEmpty) {
        print('   📂 $kategori kategorisi örnekleri:');
        for (final yemek in kategoriYemekleri) {
          final malzemeler = yemek.ingredients?.take(3).join(', ') ?? 'Malzemesiz';
          print('   • ${yemek.mealName} ($malzemeler)');
        }
      }
    }
    
    print('\n✅ FİNAL SİSTEM KONTROLÜ TAMAMLANDI!');
    print('📊 GENEL DURUM ÖZETİ:');
    print('  🗂️ Toplam yemek: ${box.length} adet');
    print('  🎯 Temiz yemek: $temizYemekSayisi adet');
    print('  ⚡ Ana yemek karışıklığı: ${kahvaltiAnaYemek + ara1AnaYemek + ara2AnaYemek} adet');
    print('  🧂 Gereksiz malzeme: $gereksizMalzemeSayisi adet');
    print('  💪 İdeal makrolu yemek: $idealYemekSayisi adet');
    
    if (kahvaltiAnaYemek + ara1AnaYemek + ara2AnaYemek == 0 && gereksizMalzemeSayisi < 100) {
      print('  🎉 SİSTEM TAM TEMİZ VE HAZIR!');
    } else {
      print('  ⚠️ Daha fazla iyileştirme gerekli');
    }
    
  } catch (e, stackTrace) {
    print('❌ Final sistem kontrolü hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}