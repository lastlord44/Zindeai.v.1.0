import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

/// 🔥 ULTRA AGRESİF TEMİZLİK - TÜM ANA YEMEKLERİ YAKALA VE TEMİZLE
void main() async {
  print('🔥 ULTRA AGRESİF TEMİZLİK SCRİPTİ BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başlatıldı - Yemek sayısı: ${box.length}');
    
    print('\n2️⃣ ULTRA KAPSAMLI ANA YEMEK MALZEMESİ LİSTESİ:');
    // Her türlü ana yemek malzemesi - çok daha kapsamlı
    final anaYemekMalzemeleri = [
      // Tüm et türleri
      'dana', 'kuzu', 'koyun', 'et', 'yağsız', 'beef', 'meat',
      'köfte', 'kıyma', 'kuşbaşı', 'biftek', 'rozbif', 'antrikot',
      
      // Tüm tavuk türleri  
      'tavuk', 'piliç', 'chicken', 'göğüs', 'but', 'kanat',
      'izgara tavuk', 'haşlama tavuk', 'rosto tavuk',
      
      // Tüm balık türleri
      'ton balığı', 'ton', 'somon', 'uskumru', 'hamsi', 'palamut', 
      'çipura', 'levrek', 'sardalya', 'istavrit', 'mezgit', 'lüfer', 
      'alabalık', 'barbunya', 'kalkan', 'dil balığı', 'fish',
      
      // Deniz ürünleri
      'karides', 'midye', 'kalamar', 'ahtapot', 'yengeç',
      
      // Makarna ve pirinç kombinasyonları
      'makarna', 'spagetti', 'penne', 'fusilli', 'rigatoni',
      'pirinç pilavı', 'pilav', 'bulgur pilavı',
      
      // Diğer ana protein kaynakları
      'hindi', 'ördek', 'kaz', 'tavşan', 'geyik',
    ];
    
    print('   📋 Ana yemek kelime sayısı: ${anaYemekMalzemeleri.length}');
    
    print('\n3️⃣ MEVCUT DURUM ANALİZİ:');
    final kategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Mevcut kategori dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n4️⃣ ULTRA AGRESİF SORUN TESPİTİ:');
    
    final duzeltilecekYemekler = <YemekHiveModel>[];
    final sorunluYemekler = <String>[];
    int kahvaltiAnaYemek = 0;
    int ara1AnaYemek = 0;
    int ara2AnaYemek = 0;
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      final tumText = '$mealName $malzemeler';
      
      bool degistirilecek = false;
      String yeniKategori = kategori;
      
      // KAHVALTIDA ANA YEMEK AVLAMA - ÇOK DÜŞÜK EŞİK
      if (kategori.contains('kahvalt')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            // Protein > 10g VEYA kalori > 120 ise ana yemek
            if ((yemek.proteinG ?? 0) > 10 || (yemek.calorie ?? 0) > 120) {
              yeniKategori = 'ogle';
              kahvaltiAnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('KAHVALTI -> ÖĞLE: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // ARA ÖĞÜN 1'DE ANA YEMEK AVLAMA - ÇOOOOK DÜŞÜK EŞİK
      if (kategori.contains('ara') && (kategori.contains('1') || kategori == 'ara1')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            // Protein > 8g VEYA kalori > 100 ise ana yemek
            if ((yemek.proteinG ?? 0) > 8 || (yemek.calorie ?? 0) > 100) {
              yeniKategori = 'ogle';
              ara1AnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('ARA ÖĞÜN 1 -> ÖĞLE: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // ARA ÖĞÜN 2'DE ANA YEMEK AVLAMA - ÇOOOOK DÜŞÜK EŞİK  
      if (kategori.contains('ara') && (kategori.contains('2') || kategori == 'ara2')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            // Protein > 8g VEYA kalori > 100 ise ana yemek
            if ((yemek.proteinG ?? 0) > 8 || (yemek.calorie ?? 0) > 100) {
              yeniKategori = 'aksam';
              ara2AnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('ARA ÖĞÜN 2 -> AKŞAM: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      if (degistirilecek) {
        yemek.category = yeniKategori;
        duzeltilecekYemekler.add(yemek);
      }
    }
    
    print('   🚨 ULTRA AGRESİF tespit edilen sorunlar:');
    print('   📊 Kahvaltıda Ana Yemek: $kahvaltiAnaYemek adet');
    print('   📊 Ara Öğün 1\'de Ana Yemek: $ara1AnaYemek adet');
    print('   📊 Ara Öğün 2\'de Ana Yemek: $ara2AnaYemek adet');
    print('   📊 Toplam düzeltilecek: ${duzeltilecekYemekler.length} adet');
    
    if (sorunluYemekler.isNotEmpty) {
      print('\n   📋 Örnek yakalanan sorunlu yemekler:');
      sorunluYemekler.take(20).forEach((sorun) {
        print('   🎯 $sorun');
      });
    }
    
    print('\n5️⃣ ULTRA AGRESİF DÜZELTME İŞLEMİ:');
    if (duzeltilecekYemekler.isNotEmpty) {
      print('   ⚡ ${duzeltilecekYemekler.length} yemek ultra agresif düzeltiliyor...');
      
      int duzeltilen = 0;
      for (final yemek in duzeltilecekYemekler) {
        try {
          await box.put(yemek.mealId!, yemek);
          duzeltilen++;
          
          if (duzeltilen % 25 == 0) {
            print('   📊 $duzeltilen/${duzeltilecekYemekler.length} yemek düzeltildi');
          }
        } catch (e) {
          print('   ❌ Hata: ${yemek.mealId} -> $e');
        }
      }
      
      print('   ✅ ULTRA AGRESİF: Toplam $duzeltilen yemek düzeltildi');
    } else {
      print('   ✅ Düzeltilecek yemek bulunamadı - sistem temiz!');
    }
    
    print('\n6️⃣ ULTRA TEMİZLİK SONRASI DURUM:');
    final yeniKategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      yeniKategoriSayilari[kategori] = (yeniKategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Ultra temizlik sonrası kategori dağılımı:');
    yeniKategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n7️⃣ KALAN SORUNLARI KONTROL ET:');
    // Son kontrol
    int kalanKahvalti = 0, kalanAra1 = 0, kalanAra2 = 0;
    final ornekKalanlar = <String>[];
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      final tumText = '$mealName $malzemeler';
      
      if (kategori.contains('kahvalt')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            kalanKahvalti++;
            if (ornekKalanlar.length < 5) {
              ornekKalanlar.add('KAHVALTI: ${yemek.mealName}');
            }
            break;
          }
        }
      }
      
      if (kategori.contains('ara') && (kategori.contains('1') || kategori == 'ara1')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            kalanAra1++;
            if (ornekKalanlar.length < 5) {
              ornekKalanlar.add('ARA ÖĞÜN 1: ${yemek.mealName}');
            }
            break;
          }
        }
      }
      
      if (kategori.contains('ara') && (kategori.contains('2') || kategori == 'ara2')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (tumText.contains(malzeme)) {
            kalanAra2++;
            if (ornekKalanlar.length < 5) {
              ornekKalanlar.add('ARA ÖĞÜN 2: ${yemek.mealName}');
            }
            break;
          }
        }
      }
    }
    
    print('   🔍 Son kontrol - kalan ana yemek sorunları:');
    print('   📊 Kahvaltıda kalan ana yemek: $kalanKahvalti');
    print('   📊 Ara Öğün 1\'de kalan ana yemek: $kalanAra1');
    print('   📊 Ara Öğün 2\'de kalan ana yemek: $kalanAra2');
    
    if (ornekKalanlar.isNotEmpty) {
      print('   🚨 Örnek kalan sorunlu yemekler:');
      ornekKalanlar.forEach((kalan) {
        print('   ⚠️ $kalan');
      });
    } else {
      print('   ✅ HİÇBİR ANA YEMEK KALMADI - TAM TEMİZLİK!');
    }
    
    print('\n✅ ULTRA AGRESİF TEMİZLİK TAMAMLANDI!');
    print('📊 Özet:');
    print('  • $kahvaltiAnaYemek kahvaltı ana yemeği temizlendi');
    print('  • $ara1AnaYemek ara öğün 1 ana yemeği temizlendi');
    print('  • $ara2AnaYemek ara öğün 2 ana yemeği temizlendi');
    print('  • Toplam ${duzeltilecekYemekler.length} yemek ultra agresif düzeltildi');
    
  } catch (e, stackTrace) {
    print('❌ Ultra agresif temizlik hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}