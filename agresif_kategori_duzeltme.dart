import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

/// 🔥 AGRESİF KATEGORİ DÜZELTME SCRİPTİ - TÜM ANA YEMEKLERİ YAKALA
void main() async {
  print('🔥 AGRESİF KATEGORİ DÜZELTME SCRİPTİ BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başarıyla başlatıldı');
    print('   📊 Toplam yemek sayısı: ${box.length}');
    
    print('\n2️⃣ GENİŞ ANA YEMEK MALZEMESİ LİSTESİ:');
    // Çok daha kapsamlı ana yemek malzemesi listesi
    final anaYemekMalzemeleri = [
      // Balık türleri
      'ton balığı', 'ton', 'somon', 'uskumru', 'hamsi', 'palamut', 'çipura', 
      'levrek', 'sardalya', 'istavrit', 'mezgit', 'lüfer', 'alabalık',
      
      // Et türleri
      'köfte', 'kıyma', 'kuşbaşı', 'biftek', 'dana', 'kuzu', 'koyun',
      'yağsız kıyma', 'dana kıyma',
      
      // Tavuk türleri
      'tavuk', 'piliç', 'tavuk göğsü', 'tavuk but', 'tavuk kanat', 'chicken',
      'izgara tavuk', 'haşlama tavuk',
      
      // Makarna kombinasyonları (ana yemek yapan)
      'makarna', 'spagetti', 'penne',
      
      // Pirinç kombinasyonları (protein ile birlikte)
      'pirinç pilavı', 'pilav',
      
      // Diğer ana protein kaynakları
      'et', 'beef', 'meat', 'seafood',
    ];
    
    // Ara öğün olması gereken malzemeler
    final araOgunMalzemeleri = [
      'muz', 'elma', 'portakal', 'çilek', 'üzüm',
      'yoğurt', 'süzme yoğurt', 'lor', 'cottage cheese',
      'badem', 'ceviz', 'fındık', 'antep fıstığı',
      'protein tozu', 'whey',
      'smoothie', 'shake'
    ];
    
    print('   📋 Ana yemek malzemesi sayısı: ${anaYemekMalzemeleri.length}');
    print('   📋 Ara öğün malzemesi sayısı: ${araOgunMalzemeleri.length}');
    
    print('\n3️⃣ SORUNLU YEMEKLERİ TESPIT ET:');
    
    final duzeltilecekYemekler = <YemekHiveModel>[];
    final sorunluYemekler = <String>[];
    int araOgun1AnaYemek = 0;
    int araOgun2AnaYemek = 0;
    int kahvaltiAnaYemek = 0;
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      final combinedText = '$mealName $malzemeler';
      
      bool degistirilecek = false;
      String yeniKategori = kategori;
      
      // ARA ÖĞÜN 1'DEKİ ANA YEMEKLERİ YAKALA
      if (kategori.contains('ara') && (kategori.contains('1') || kategori == 'ara1')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (combinedText.contains(malzeme)) {
            // Kalori > 150 veya protein > 15g ise kesinlikle ana yemek
            if ((yemek.calorie ?? 0) > 150 || (yemek.proteinG ?? 0) > 15) {
              yeniKategori = 'ogle';  // Öğle yemeğine taşı
              araOgun1AnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('Ara Öğün 1 -> Öğle: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // ARA ÖĞÜN 2'DEKİ ANA YEMEKLERİ YAKALA
      if (kategori.contains('ara') && (kategori.contains('2') || kategori == 'ara2')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (combinedText.contains(malzeme)) {
            // Kalori > 150 veya protein > 15g ise kesinlikle ana yemek
            if ((yemek.calorie ?? 0) > 150 || (yemek.proteinG ?? 0) > 15) {
              yeniKategori = 'aksam';  // Akşam yemeğine taşı
              araOgun2AnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('Ara Öğün 2 -> Akşam: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // KAHVALTIDA ANA YEMEK MALZEMELERİ
      if (kategori.contains('kahvalt')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (combinedText.contains(malzeme)) {
            // Protein > 20g ise kesinlikle ana yemek
            if ((yemek.proteinG ?? 0) > 20) {
              yeniKategori = 'ogle';  // Öğle yemeğine taşı
              kahvaltiAnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('Kahvaltı -> Öğle: ${yemek.mealName}');
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
    
    print('   🚨 Yeni tespit edilen sorunlar:');
    print('   📊 Ara Öğün 1\'de Ana Yemek: $araOgun1AnaYemek adet');
    print('   📊 Ara Öğün 2\'de Ana Yemek: $araOgun2AnaYemek adet');
    print('   📊 Kahvaltıda Ana Yemek: $kahvaltiAnaYemek adet');
    print('   📊 Toplam düzeltilecek yemek: ${duzeltilecekYemekler.length} adet');
    
    if (sorunluYemekler.isNotEmpty) {
      print('\n   📋 Örnek sorunlu yemekler:');
      sorunluYemekler.take(15).forEach((sorun) {
        print('   🔄 $sorun');
      });
    }
    
    print('\n4️⃣ AGRESİF DÜZELTME İŞLEMİ:');
    if (duzeltilecekYemekler.isNotEmpty) {
      print('   ⏳ ${duzeltilecekYemekler.length} yemek düzeltiliyor...');
      
      int duzeltilen = 0;
      for (final yemek in duzeltilecekYemekler) {
        try {
          await box.put(yemek.mealId!, yemek);
          duzeltilen++;
          
          if (duzeltilen % 50 == 0) {
            print('   📊 $duzeltilen/${duzeltilecekYemekler.length} yemek düzeltildi');
          }
        } catch (e) {
          print('   ❌ Düzeltme hatası: ${yemek.mealId} -> $e');
        }
      }
      
      print('   ✅ Toplam $duzeltilen yemek başarıyla düzeltildi');
    } else {
      print('   ✅ Düzeltilecek yemek bulunamadı!');
    }
    
    print('\n5️⃣ SON DURUM KONTROLü:');
    final yeniKategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      yeniKategoriSayilari[kategori] = (yeniKategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Agresif düzeltme sonrası kategori dağılımı:');
    yeniKategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n✅ AGRESİF KATEGORİ DÜZELTME TAMAMLANDI!');
    print('📊 Özet:');
    print('  • $araOgun1AnaYemek ara öğün 1 yemeği öğle yemeğine taşındı');
    print('  • $araOgun2AnaYemek ara öğün 2 yemeği akşam yemeğine taşındı');
    print('  • $kahvaltiAnaYemek kahvaltı yemeği öğle yemeğine taşındı');
    print('  • Toplam ${duzeltilecekYemekler.length} yemek düzeltildi');
    
  } catch (e, stackTrace) {
    print('❌ Agresif fix scripti hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}