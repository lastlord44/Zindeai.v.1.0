import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('\n' + '=' * 80);
  print('ARA ÖĞÜN 2 DETAYLI ANALİZ');
  print('=' * 80);
  
  final araOgun2Yemekler = box.values.where((y) => 
    y.ogun == OgunTipi.araOgun2.toString()
  ).toList();
  
  print('\n📊 Toplam Ara Öğün 2 sayısı: ${araOgun2Yemekler.length}');
  
  if (araOgun2Yemekler.isEmpty) {
    print('❌ Ara Öğün 2 yemeği bulunamadı!');
    await box.close();
    return;
  }
  
  print('\n' + '-' * 80);
  print('İLK 10 ARA ÖĞÜN 2 DETAYLI İNCELEME:');
  print('-' * 80);
  
  int sayac = 0;
  for (final yemek in araOgun2Yemekler.take(10)) {
    sayac++;
    print('\n[$sayac] ID: ${yemek.id}');
    print('    Ad: "${yemek.ad}"');
    print('    Kalori: ${yemek.kalori}');
    print('    Protein: ${yemek.protein}');
    print('    Karbonhidrat: ${yemek.karbonhidrat}');
    print('    Yağ: ${yemek.yag}');
    print('    Malzeme Sayısı: ${yemek.malzemeler.length}');
    
    if (yemek.malzemeler.isNotEmpty) {
      print('    Malzemeler:');
      for (final malzeme in yemek.malzemeler.take(3)) {
        print('      - $malzeme');
      }
      if (yemek.malzemeler.length > 3) {
        print('      ... ve ${yemek.malzemeler.length - 3} malzeme daha');
      }
    }
    
    // Sorunlu yemekleri işaretle
    if (yemek.ad.isEmpty || yemek.ad == 'İsimsiz Yemek' || yemek.ad.contains('Ara Öğün 2:') && yemek.ad.length < 20) {
      print('    ⚠️ SORUNLU İSİM!');
    }
    if (yemek.kalori == 0 || yemek.kalori < 50) {
      print('    ⚠️ SORUNLU KALORİ!');
    }
  }
  
  // İstatistikler
  print('\n' + '-' * 80);
  print('İSTATİSTİKLER:');
  print('-' * 80);
  
  final isimsizSayisi = araOgun2Yemekler.where((y) => 
    y.ad.isEmpty || y.ad == 'İsimsiz Yemek'
  ).length;
  
  final kategoriAdliSayisi = araOgun2Yemekler.where((y) => 
    y.ad.contains('Ara Öğün 2:') || y.ad.contains('ARAOGUN2')
  ).length;
  
  final dusukKaloriSayisi = araOgun2Yemekler.where((y) => 
    y.kalori < 50
  ).length;
  
  final normalSayisi = araOgun2Yemekler.length - isimsizSayisi - kategoriAdliSayisi;
  
  print('İsimsiz yemek sayısı: $isimsizSayisi');
  print('Sadece kategori adı olan: $kategoriAdliSayisi');
  print('Düşük kalori (<50): $dusukKaloriSayisi');
  print('Normal görünen: $normalSayisi');
  
  print('\n' + '-' * 80);
  print('ÖRNEK DÜZGÜN ARA ÖĞÜN 2:');
  print('-' * 80);
  
  final normalYemek = araOgun2Yemekler.firstWhere(
    (y) => !y.ad.isEmpty && 
           y.ad != 'İsimsiz Yemek' && 
           !y.ad.contains('Ara Öğün 2:') &&
           y.kalori >= 100,
    orElse: () => araOgun2Yemekler.first,
  );
  
  print('Ad: ${normalYemek.ad}');
  print('Kalori: ${normalYemek.kalori}');
  print('Protein: ${normalYemek.protein}');
  print('Karb: ${normalYemek.karbonhidrat}');
  print('Yağ: ${normalYemek.yag}');
  
  await box.close();
  print('\n' + '=' * 80);
}
