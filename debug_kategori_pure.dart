import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

/// 🔍 KATEGORİ VE LOG SİSTEMİ SORUNU ANALİZİ (PURE DART)
void main() async {
  print('🔍 KATEGORİ VE LOG SORUNU ANALİZİ (PURE DART) BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA (PURE DART):');
    // Pure Dart için Hive başlat
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başarıyla başlatıldı (Pure Dart)');
    
    print('\n2️⃣ TEMEL VERİTABANI DURUMU:');
    final toplamYemekSayisi = box.length;
    print('   📊 Toplam yemek sayısı: $toplamYemekSayisi');
    
    if (toplamYemekSayisi == 0) {
      print('   ❌ VERİTABANI BOŞ! Migration gerekli.\n');
      return;
    }
    
    print('\n3️⃣ KATEGORİ DAĞILIMI ANALİZİ:');
    final kategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
    }
    print('   📋 Tespit edilen kategoriler:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n4️⃣ PROBLEMLİ KATEGORİLERİ TESPIT ET:');
    final problemliKategoriler = <String>[];
    
    final araOgun2Yemekleri = <YemekHiveModel>[];
    final kahvaltiYemekleri = <YemekHiveModel>[];
    final anaYemekKategorileri = <YemekHiveModel>[];
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = yemek.mealName ?? 'İsimsiz';
      
      // Ara Öğün 2 sorunları
      if (kategori.contains('ara') && kategori.contains('2')) {
        araOgun2Yemekleri.add(yemek);
        
        // İsim sorunu kontrolü
        if (mealName.trim().isEmpty || 
            mealName == 'Ara Öğün 2:' || 
            mealName == 'İsimsiz Yemek' ||
            mealName.endsWith(':')) {
          problemliKategoriler.add('Ara Öğün 2 İsim Sorunu: "$mealName"');
        }
      }
      
      // Kahvaltı sorunları  
      if (kategori.contains('kahvalt')) {
        kahvaltiYemekleri.add(yemek);
        
        // Ana yemek malzemeleri kahvaltıda?
        final malzemeler = yemek.ingredients?.join(' ').toLowerCase() ?? '';
        if (malzemeler.contains('et ') || 
            malzemeler.contains('köfte') ||
            malzemeler.contains('kuşbaşı')) {
          problemliKategoriler.add('Kahvaltıda Ana Yemek: "$mealName"');
        }
      }
      
      // Ana yemek kategorilerindeki ara öğün sorunları
      if ((kategori.contains('öğle') || kategori.contains('akşam')) &&
          (mealName.toLowerCase().contains('atıştırmalık') ||
           mealName.toLowerCase().contains('ara öğün'))) {
        problemliKategoriler.add('Ana Yemekte Ara Öğün: "$kategori" -> "$mealName"');
      }
    }
    
    print('   🚨 Tespit edilen problemler:');
    if (problemliKategoriler.isEmpty) {
      print('   ✅ Problem tespit edilmedi');
    } else {
      problemliKategoriler.take(10).forEach((problem) {
        print('   ❌ $problem');
      });
      if (problemliKategoriler.length > 10) {
        print('   ⚠️ +${problemliKategoriler.length - 10} tane daha problem var');
      }
    }
    
    print('\n5️⃣ ÖGUN TİPİ DÖNÜŞTÜRME TESTİ:');
    final ornekKategoriler = [
      'kahvaltı', 'kahvalti',
      'ara öğün 1', 'ara_ogun_1', 'ara1',
      'öğle', 'ogle',
      'ara öğün 2', 'ara_ogun_2', 'ara2',
      'akşam', 'aksam'
    ];
    
    for (final kategori in ornekKategoriler) {
      try {
        final ogunTipi = Yemek.ogunTipiFromString(kategori);
        print('   ✅ "$kategori" -> ${ogunTipi.name}');
      } catch (e) {
        print('   ❌ "$kategori" -> HATA: $e');
      }
    }
    
    print('\n6️⃣ ÖRNEK YEMEKLERİN KATEGORİ ANALİZİ:');
    print('   📂 Ara Öğün 2 örneği (${araOgun2Yemekleri.length} adet):');
    araOgun2Yemekleri.take(3).forEach((yemek) {
      print('      • "${yemek.mealName}" (${yemek.category})');
      print('        Kalori: ${yemek.calorie?.toInt()}kcal, Malzemeler: ${yemek.ingredients?.take(2).join(", ")}');
    });
    
    print('\n   📂 Kahvaltı örneği (${kahvaltiYemekleri.length} adet):');
    kahvaltiYemekleri.take(3).forEach((yemek) {
      print('      • "${yemek.mealName}" (${yemek.category})');
      print('        Protein: ${yemek.proteinG?.toInt()}g, Malzemeler: ${yemek.ingredients?.take(2).join(", ")}');
    });
    
    print('\n7️⃣ KATEGORİ STANDARDIZASYON TESTİ:');
    final kategoriMap = <String, String>{};
    for (final yemek in box.values.take(50)) { // İlk 50 yemek test et
      final rawCategory = yemek.category ?? '';
      try {
        final ogunTipi = Yemek.ogunTipiFromString(rawCategory);
        final standardCategory = ogunTipi.ad;
        if (rawCategory.toLowerCase() != standardCategory.toLowerCase()) {
          kategoriMap[rawCategory] = standardCategory;
        }
      } catch (e) {
        print('   ❌ Kategori dönüştürme hatası: "$rawCategory" -> $e');
      }
    }
    
    if (kategoriMap.isNotEmpty) {
      print('   🔄 Standardizasyon gereken kategoriler:');
      kategoriMap.entries.take(5).forEach((entry) {
        print('   📝 "${entry.key}" -> "${entry.value}"');
      });
    }
    
    print('\n📋 SONUÇ VE ÖNERİLER:');
    print('✅ Analiz tamamlandı');
    print('📊 Problem sayısı: ${problemliKategoriler.length}');
    print('🔧 Ana Sorunlar:');
    print('  1. Ara Öğün 2 yemeklerinde isim sorunları');
    print('  2. Kahvaltı kategorisinde ana yemek malzemeleri');
    print('  3. Ana yemek kategorilerinde ara öğün isimleri');
    print('  4. Kategori standardizasyon sorunu');
    
  } catch (e, stackTrace) {
    print('❌ Analiz hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}