import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

/// 🔧 KATEGORİ DÜZELTME VE LOG SİSTEMİ FİX SCRİPTİ
void main() async {
  print('🔧 KATEGORİ DÜZELTME VE LOG SİSTEMİ FİX SCRİPTİ BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başarıyla başlatıldı');
    print('   📊 Toplam yemek sayısı: ${box.length}');
    
    print('\n2️⃣ SORUNLU YEMEKLERİ TESPIT ET:');
    
    // Ana yemek malzemeleri listesi
    final anaYemekMalzemeleri = [
      'uskumru', 'somon', 'levrek', 'hamsi', 'palamut', 'çipura',
      'köfte', 'kuşbaşı', 'biftek', 'dana', 'kuzu',
      'tavuk göğsü', 'tavuk but', 'piliç',
      'et', 'kebap'
    ];
    
    // Ara öğün malzemeleri listesi
    final araOgunMalzemeleri = [
      'yoğurt', 'muz', 'elma', 'portakal', 'çilek',
      'badem', 'ceviz', 'fındık',
      'lor peyniri', 'cottage cheese', 'süzme yoğurt',
      'protein tozu', 'whey', 'casein',
      'smoothie', 'shake', 'atıştırmalık'
    ];
    
    final sorunluYemekler = <String>[];
    final duzeltilecekYemekler = <YemekHiveModel>[];
    int araOgun2AnaYemek = 0;
    int kahvaltiAnaYemek = 0;
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      
      bool degistirilecek = false;
      
      // ARA ÖĞÜN 2'DEKİ ANA YEMEK SORUNLARI
      if (kategori.contains('ara') && kategori.contains('2')) {
        // Ana yemek malzemesi varsa
        for (final malzeme in anaYemekMalzemeleri) {
          if (mealName.contains(malzeme) || malzemeler.contains(malzeme)) {
            // Eğer kalori > 200 ise büyük ihtimalle ana yemek
            if ((yemek.calorie ?? 0) > 200) {
              // Akşam yemeği yap
              yemek.category = 'aksam';
              araOgun2AnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('Ara Öğün 2 -> Akşam: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // KAHVALTIDA ANA YEMEK SORUNLARI
      if (kategori.contains('kahvalt')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if (mealName.contains(malzeme) || malzemeler.contains(malzeme)) {
            // Eğer protein > 25g ise büyük ihtimalle ana yemek
            if ((yemek.proteinG ?? 0) > 25) {
              // Öğle yemeği yap
              yemek.category = 'ogle';
              kahvaltiAnaYemek++;
              degistirilecek = true;
              sorunluYemekler.add('Kahvaltı -> Öğle: ${yemek.mealName}');
              break;
            }
          }
        }
      }
      
      // KATEGORİ STANDARDIZASYONU
      String? yeniKategori;
      switch (kategori) {
        case 'aksam':
        case 'akşam yemeği':
          yeniKategori = 'aksam';
          break;
        case 'kahvalti':
        case 'kahvaltı':
          yeniKategori = 'kahvalti';
          break;
        case 'ogle':
        case 'öğle':
        case 'öğle yemeği':
          yeniKategori = 'ogle';
          break;
        case 'ara öğün 1':
        case 'ara_ogun_1':
        case 'ara1':
          yeniKategori = 'ara1';
          break;
        case 'ara öğün 2':
        case 'ara_ogun_2':
        case 'ara2':
          yeniKategori = 'ara2';
          break;
        case 'cheat meal':
          yeniKategori = 'cheatmeal';
          break;
      }
      
      if (yeniKategori != null && yeniKategori != kategori) {
        yemek.category = yeniKategori;
        degistirilecek = true;
      }
      
      if (degistirilecek) {
        duzeltilecekYemekler.add(yemek);
      }
    }
    
    print('   🚨 Tespit edilen sorunlar:');
    print('   📊 Ara Öğün 2\'de Ana Yemek: $araOgun2AnaYemek adet');
    print('   📊 Kahvaltıda Ana Yemek: $kahvaltiAnaYemek adet');
    print('   📊 Toplam düzeltilecek yemek: ${duzeltilecekYemekler.length} adet');
    
    if (sorunluYemekler.isNotEmpty) {
      print('\n   📋 Örnek sorunlu yemekler:');
      sorunluYemekler.take(10).forEach((sorun) {
        print('   🔄 $sorun');
      });
    }
    
    print('\n3️⃣ DÜZELTME İŞLEMİ:');
    print('   ⏳ ${duzeltilecekYemekler.length} yemek düzeltiliyor...');
    
    int duzeltilen = 0;
    for (final yemek in duzeltilecekYemekler) {
      try {
        await box.put(yemek.mealId!, yemek);
        duzeltilen++;
        
        if (duzeltilen % 100 == 0) {
          print('   📊 $duzeltilen/${duzeltilecekYemekler.length} yemek düzeltildi');
        }
      } catch (e) {
        print('   ❌ Düzeltme hatası: ${yemek.mealId} -> $e');
      }
    }
    
    print('   ✅ Toplam $duzeltilen yemek başarıyla düzeltildi');
    
    print('\n4️⃣ DÜZELTME SONRASI KATEGORİ DURUMU:');
    final yeniKategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      yeniKategoriSayilari[kategori] = (yeniKategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Güncellenmiş kategori dağılımı:');
    yeniKategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n5️⃣ LOG SİSTEMİ DÜZELTMESİ:');
    print('   📝 main.dart dosyasında log seviyesi DEBUG olarak değiştirilmeli');
    print('   💡 Değişiklik: AppLogger.init(level: LogLevel.debug);');
    
    print('\n✅ KATEGORİ DÜZELTME İŞLEMİ TAMAMLANDI!');
    print('📊 Özet:');
    print('  • $araOgun2AnaYemek ara öğün 2 yemeği akşam yemeğine taşındı');
    print('  • $kahvaltiAnaYemek kahvaltı yemeği öğle yemeğine taşındı');
    print('  • Kategori isimleri standardize edildi');
    print('  • Log sistemi için düzeltme önerisi verildi');
    
  } catch (e, stackTrace) {
    print('❌ Fix scripti hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}