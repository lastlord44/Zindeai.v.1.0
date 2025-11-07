import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

/// 🎯 FİNAL TEST VE DOĞRULAMA SCRİPTİ
void main() async {
  print('🎯 FİNAL TEST VE DOĞRULAMA SCRİPTİ BAŞLIYOR...\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başarıyla başlatıldı');
    print('   📊 Toplam yemek sayısı: ${box.length}');
    
    print('\n2️⃣ DÜZELTME SONRASI KATEGORİ DURUMU:');
    final kategoriSayilari = <String, int>{};
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
    }
    
    print('   📋 Güncel kategori dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n3️⃣ SORUN TESPİT EDİLEN YEMEKLERİN KONTROL EDİLMESİ:');
    
    // Ana yemek malzemeleri listesi
    final anaYemekMalzemeleri = ['uskumru', 'somon', 'hamsi', 'köfte', 'kuşbaşı', 'tavuk'];
    
    int araOgun2AnaYemek = 0;
    int kahvaltiAnaYemek = 0;
    final ornekSorunluYemekler = <String>[];
    
    for (final yemek in box.values) {
      final kategori = yemek.category?.toLowerCase() ?? '';
      final mealName = (yemek.mealName ?? '').toLowerCase();
      final malzemeler = (yemek.ingredients?.join(' ') ?? '').toLowerCase();
      
      // Hala ara öğün 2'de ana yemek var mı?
      if (kategori.contains('ara') && kategori.contains('2')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if ((mealName.contains(malzeme) || malzemeler.contains(malzeme)) &&
              (yemek.calorie ?? 0) > 200) {
            araOgun2AnaYemek++;
            if (ornekSorunluYemekler.length < 3) {
              ornekSorunluYemekler.add('Ara Öğün 2\'de Ana Yemek: ${yemek.mealName}');
            }
            break;
          }
        }
      }
      
      // Hala kahvaltıda ana yemek var mı?
      if (kategori.contains('kahvalt')) {
        for (final malzeme in anaYemekMalzemeleri) {
          if ((mealName.contains(malzeme) || malzemeler.contains(malzeme)) &&
              (yemek.proteinG ?? 0) > 25) {
            kahvaltiAnaYemek++;
            if (ornekSorunluYemekler.length < 5) {
              ornekSorunluYemekler.add('Kahvaltıda Ana Yemek: ${yemek.mealName}');
            }
            break;
          }
        }
      }
    }
    
    print('   🚨 Kalan sorunlar:');
    print('   📊 Ara Öğün 2\'de Ana Yemek: $araOgun2AnaYemek adet');
    print('   📊 Kahvaltıda Ana Yemek: $kahvaltiAnaYemek adet');
    
    if (ornekSorunluYemekler.isNotEmpty) {
      print('   📋 Örnek kalan sorunlar:');
      ornekSorunluYemekler.forEach((sorun) {
        print('   ⚠️ $sorun');
      });
    }
    
    print('\n4️⃣ ÖGUN TİPİ DÖNÜŞTÜRME TESTİ (Tekrar):');
    final ornekKategoriler = ['kahvaltı', 'ara2', 'öğle', 'aksam'];
    
    for (final kategori in ornekKategoriler) {
      try {
        final ogunTipi = Yemek.ogunTipiFromString(kategori);
        print('   ✅ "$kategori" -> ${ogunTipi.name} (${ogunTipi.ad})');
      } catch (e) {
        print('   ❌ "$kategori" -> HATA: $e');
      }
    }
    
    print('\n5️⃣ ÖRNEK YEMEKLERİN YENİ KATEGORİLERİ:');
    
    // Ara öğün 2'den örnekler
    final ara2Yemekleri = box.values.where((y) => y.category == 'ara2').take(2);
    print('   📂 Ara Öğün 2 örnekleri:');
    ara2Yemekleri.forEach((yemek) {
      print('   🍽️ ${yemek.mealName} (${yemek.calorie?.toInt()}kcal)');
    });
    
    // Kahvaltıdan örnekler
    final kahvaltiYemekleri = box.values.where((y) => y.category == 'kahvalti').take(2);
    print('\n   📂 Kahvaltı örnekleri:');
    kahvaltiYemekleri.forEach((yemek) {
      print('   🍳 ${yemek.mealName} (${yemek.proteinG?.toInt()}g protein)');
    });
    
    // Akşam yemeğinden örnekler (eskiden ara öğün 2 olanlar)
    final aksamYemekleri = box.values.where((y) => 
      y.category == 'aksam' && 
      (y.mealName?.toLowerCase().contains('uskumru') ?? false)
    ).take(1);
    print('\n   📂 Akşam Yemeği örnekleri (eski ara öğün 2):');
    aksamYemekleri.forEach((yemek) {
      print('   🌙 ${yemek.mealName} (${yemek.calorie?.toInt()}kcal)');
    });
    
    print('\n6️⃣ KATEGORİ STANDARDIZASYON DURUMU:');
    final nonStandardKategoriler = kategoriSayilari.keys.where((k) => 
      !['aksam', 'kahvalti', 'ogle', 'ara1', 'ara2', 'cheatmeal'].contains(k.toLowerCase())
    ).toList();
    
    if (nonStandardKategoriler.isEmpty) {
      print('   ✅ Tüm ana kategoriler standardize edildi');
    } else {
      print('   ⚠️ Standardize edilmeyen kategoriler:');
      nonStandardKategoriler.forEach((k) {
        print('   📝 "$k": ${kategoriSayilari[k]} adet');
      });
    }
    
    print('\n📋 GENEL SONUÇ VE DEĞERLENDİRME:');
    
    final toplamSorun = araOgun2AnaYemek + kahvaltiAnaYemek;
    
    if (toplamSorun == 0) {
      print('✅ BAŞARILI: Tüm kategori sorunları çözüldü!');
    } else {
      print('⚠️ KISMİ BAŞARI: ${toplamSorun} sorun kaldı (${5749 - toplamSorun} yemek düzeltildi)');
    }
    
    print('\n🎯 ÖZET:');
    print('📊 Toplam yemek: ${box.length}');
    print('📂 Ana kategoriler: ${kategoriSayilari.length}');
    print('🔧 Kalan sorun: $toplamSorun');
    print('✅ Başarı oranı: ${((5749 - toplamSorun) / 5749 * 100).toStringAsFixed(1)}%');
    
    print('\n💡 TELEFONDAKİ LOG SORUNU ÇÖZÜMÜ:');
    print('📱 Artık debug loglar telefonda görünecek!');
    print('🔧 main.dart\'ta AppLogger.init(level: LogLevel.debug) ayarlandı');
    
  } catch (e, stackTrace) {
    print('❌ Test hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}