import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/utils/app_logger.dart';

/// 🔍 KATEGORİ VE LOG SİSTEMİ SORUNU ANALİZİ
void main() async {
  print('🔍 KATEGORİ VE LOG SİSTEMİ SORUNU ANALİZİ BAŞLIYOR...\n');
  
  try {
    // 1️⃣ LOG SİSTEMİ TEST - DEBUG seviyesinde başlat
    print('1️⃣ LOG SİSTEMİ TESTİ:');
    AppLogger.init(level: LogLevel.debug); // 🔧 DEBUG seviyesinde başlat
    print('   ✅ Log seviyesi DEBUG olarak ayarlandı');
    
    AppLogger.debug('🧪 Bu debug log görünecek mi?');
    AppLogger.info('ℹ️ Bu info log görünecek mi?');
    AppLogger.error('❌ Bu error log görünecek mi?');
    
    print('\n2️⃣ HİVE BAŞLATMA:');
    // Hive başlat
    await Hive.initFlutter();
    Hive.registerAdapter(YemekHiveModelAdapter());
    await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('   ✅ Hive başarıyla başlatıldı');
    
    print('\n3️⃣ TEMEL VERİTABANI DURUMU:');
    final toplamYemekSayisi = await HiveService.yemekSayisi();
    print('   📊 Toplam yemek sayısı: $toplamYemekSayisi');
    
    if (toplamYemekSayisi == 0) {
      print('   ❌ VERİTABANI BOŞ! Migration gerekli.\n');
      return;
    }
    
    print('\n4️⃣ KATEGORİ DAĞILIMI ANALİZİ:');
    final kategoriSayilari = await HiveService.kategoriSayilari();
    print('   📋 Tespit edilen kategoriler:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 "$kategori": $sayi adet');
    });
    
    print('\n5️⃣ PROBLEMLİ KATEGORİLERİ TESPIT ET:');
    final problemliKategoriler = <String>[];
    final box = Hive.box<YemekHiveModel>('yemekler');
    
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
          problemliKategoriler.add('Kahvaltıda Ana Yemek: "$mealName" - ${yemek.ingredients?.take(3).join(", ")}');
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
    
    print('\n6️⃣ ÖGUN TİPİ DÖNÜŞTÜRME TESTİ:');
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
    
    print('\n7️⃣ ÖRNEK YEMEKLERİN KATEGORİ ANALİZİ:');
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
    
    print('\n8️⃣ LOG SİSTEMİ FINAL TESTİ:');
    AppLogger.debug('🧪 Final debug test - bu görünmeli!');
    AppLogger.info('ℹ️ Final info test - bu da görünmeli!');
    AppLogger.success('✅ Final success test - bu da görünmeli!');
    AppLogger.warning('⚠️ Final warning test - bu da görünmeli!');
    AppLogger.error('❌ Final error test - bu da görünmeli!');
    
    print('\n📋 SONUÇ VE ÖNERİLER:');
    print('✅ Analiz tamamlandı');
    print('📊 Problem sayısı: ${problemliKategoriler.length}');
    print('🔧 Öneriler:');
    print('  1. Log sistemini DEBUG seviyesinde başlat (main.dart)');
    print('  2. Ara Öğün 2 isim sorunlarını düzelt (YemekHiveModel)');
    print('  3. Kategori mapping\'ini standartlaştır');
    print('  4. Kahvaltıdaki ana yemek malzemelerini temizle');
    
  } catch (e, stackTrace) {
    print('❌ Analiz hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}