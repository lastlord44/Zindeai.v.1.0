import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔍 VERİTABANI KALORİ ANALİZİ\n');
  print('=' * 60);
  
  try {
    // Hive başlat
    final appDir = Directory.current.path;
    Hive.init('$appDir/hive_db');
    Hive.registerAdapter(YemekHiveModelAdapter());
    
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    final toplamYemek = box.length;
    
    print('📊 TOPLAM YEMEK: $toplamYemek\n');
    
    if (toplamYemek == 0) {
      print('❌ VERİTABANI BOŞ!\n');
      await box.close();
      await Hive.close();
      return;
    }
    
    // Kategorilere göre ayır
    final kategoriler = {
      'Kahvaltı': <YemekHiveModel>[],
      'Ara Öğün 1': <YemekHiveModel>[],
      'Öğle Yemeği': <YemekHiveModel>[],
      'Ara Öğün 2': <YemekHiveModel>[],
      'Akşam Yemeği': <YemekHiveModel>[],
      'Diğer': <YemekHiveModel>[],
    };
    
    for (var yemek in box.values) {
      final kategori = yemek.category?.trim() ?? 'Diğer';
      
      if (kategori.toLowerCase().contains('kahvaltı')) {
        kategoriler['Kahvaltı']!.add(yemek);
      } else if (kategori.toLowerCase().contains('ara') && kategori.contains('1')) {
        kategoriler['Ara Öğün 1']!.add(yemek);
      } else if (kategori.toLowerCase().contains('öğle')) {
        kategoriler['Öğle Yemeği']!.add(yemek);
      } else if (kategori.toLowerCase().contains('ara') && kategori.contains('2')) {
        kategoriler['Ara Öğün 2']!.add(yemek);
      } else if (kategori.toLowerCase().contains('akşam')) {
        kategoriler['Akşam Yemeği']!.add(yemek);
      } else {
        kategoriler['Diğer']!.add(yemek);
      }
    }
    
    // Her kategori için kalori analizi
    for (var entry in kategoriler.entries) {
      final kategoriAdi = entry.key;
      final yemekler = entry.value;
      
      if (yemekler.isEmpty) continue;
      
      print('━' * 60);
      print('📂 $kategoriAdi (${yemekler.length} yemek)');
      print('━' * 60);
      
      // Kalori dağılımı
      final kaloriler = yemekler.map((y) => y.calorie ?? 0).toList()..sort();
      final ortalama = kaloriler.reduce((a, b) => a + b) / kaloriler.length;
      final min = kaloriler.first;
      final max = kaloriler.last;
      final medyan = kaloriler[kaloriler.length ~/ 2];
      
      print('Kalori Dağılımı:');
      print('  • Min: ${min.toStringAsFixed(0)} kcal');
      print('  • Ortalama: ${ortalama.toStringAsFixed(0)} kcal');
      print('  • Medyan: ${medyan.toStringAsFixed(0)} kcal');
      print('  • Max: ${max.toStringAsFixed(0)} kcal');
      
      // Kalori aralıklarına göre dağılım
      final araliklar = {
        '0-100 kcal': 0,
        '100-200 kcal': 0,
        '200-300 kcal': 0,
        '300-400 kcal': 0,
        '400-500 kcal': 0,
        '500-600 kcal': 0,
        '600+ kcal': 0,
      };
      
      for (var kalori in kaloriler) {
        if (kalori < 100) araliklar['0-100 kcal'] = araliklar['0-100 kcal']! + 1;
        else if (kalori < 200) araliklar['100-200 kcal'] = araliklar['100-200 kcal']! + 1;
        else if (kalori < 300) araliklar['200-300 kcal'] = araliklar['200-300 kcal']! + 1;
        else if (kalori < 400) araliklar['300-400 kcal'] = araliklar['300-400 kcal']! + 1;
        else if (kalori < 500) araliklar['400-500 kcal'] = araliklar['400-500 kcal']! + 1;
        else if (kalori < 600) araliklar['500-600 kcal'] = araliklar['500-600 kcal']! + 1;
        else araliklar['600+ kcal'] = araliklar['600+ kcal']! + 1;
      }
      
      print('\nKalori Aralıkları:');
      araliklar.forEach((aralik, sayi) {
        final yuzde = (sayi / yemekler.length * 100).toStringAsFixed(1);
        print('  • $aralik: $sayi yemek ($yuzde%)');
      });
      
      // En yüksek 5 kalorili yemek
      final siralama = [...yemekler]..sort((a, b) => (b.calorie ?? 0).compareTo(a.calorie ?? 0));
      print('\nEn Yüksek 5 Kalorili Yemek:');
      for (var i = 0; i < 5 && i < siralama.length; i++) {
        final y = siralama[i];
        print('  ${i + 1}. ${y.mealName} - ${y.calorie?.toStringAsFixed(0) ?? 0} kcal');
      }
      
      // En düşük 5 kalorili yemek
      print('\nEn Düşük 5 Kalorili Yemek:');
      for (var i = 0; i < 5 && i < yemekler.length; i++) {
        final y = yemekler[yemekler.length - 1 - i];
        print('  ${i + 1}. ${y.mealName} - ${y.calorie?.toStringAsFixed(0) ?? 0} kcal');
      }
      
      print('');
    }
    
    // Garip isimli yemekleri bul
    print('=' * 60);
    print('🔍 GAR İP İSİMLİ YEMEKLER:');
    print('=' * 60);
    
    final garipKelimeler = [
      'gluten',
      'free',
      'kinoa',
      'quinoa',
      'protein bar',
      'smoothie',
      'chia',
      'midye',
      'granola',
    ];
    
    final garipYemekler = <YemekHiveModel>[];
    for (var yemek in box.values) {
      final isim = yemek.mealName?.toLowerCase() ?? '';
      for (var kelime in garipKelimeler) {
        if (isim.contains(kelime)) {
          garipYemekler.add(yemek);
          break;
        }
      }
    }
    
    if (garipYemekler.isEmpty) {
      print('✅ Garip isimli yemek bulunamadı.\n');
    } else {
      print('⚠️  ${garipYemekler.length} garip isimli yemek bulundu:\n');
      for (var i = 0; i < garipYemekler.length && i < 20; i++) {
        final y = garipYemekler[i];
        print('${i + 1}. ${y.mealName} (${y.category}) - ${y.calorie?.toStringAsFixed(0) ?? 0} kcal');
      }
      if (garipYemekler.length > 20) {
        print('... ve ${garipYemekler.length - 20} yemek daha');
      }
    }
    
    print('\n✅ Analiz tamamlandı!');
    
    await box.close();
    await Hive.close();
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('Stack Trace: $stackTrace');
  }
}
