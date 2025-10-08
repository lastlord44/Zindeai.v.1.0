import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  print('Hive DB Kategori Kontrolu Baslatiyor...\
');
  
  // Hive'i baslat
  final appDir = Directory.current.path;
  Hive.init('$appDir/hive_data');
  
  await HiveService.init();
  
  // YemekHiveDataSource'u kullan
  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  
  print('=' * 60);
  print('KATEGORI DAGILIMI');
  print('=' * 60);
  
  int toplam = 0;
  tumYemekler.forEach((ogunTipi, yemekler) {
    final kategoriAdi = ogunTipi.toString().split('.').last.padRight(20);
    print('$kategoriAdi : ${yemekler.length} yemek');
    toplam += yemekler.length;
  });
  
  print('-' * 60);
  print('${'TOPLAM'.padRight(20)} : $toplam yemek');
  print('=' * 60);
  
  // Ara ogun 2 kontrol
  print('\
ARA OGUN 2 DETAYLI KONTROL:');
  print('-' * 60);
  
  final araOgun2List = tumYemekler[OgunTipi.araOgun2];
  if (araOgun2List == null || araOgun2List.isEmpty) {
    print('ARA OGUN 2 BULUNAMADI!');
    print('SORUN: Migration sirasinda category mapping hatasi olabilir.');
  } else {
    print('Ara Ogun 2: ${araOgun2List.length} yemek bulundu');
    print('\
Ilk 3 ornek:');
    for (var i = 0; i < 3 && i < araOgun2List.length; i++) {
      final yemek = araOgun2List[i];
      print('  ${i + 1}. ${yemek.ad}');
      print('     Kalori: ${yemek.kalori}, Protein: ${yemek.protein}g');
    }
  }
  
  print('\
' + '=' * 60);
  print('Kontrol tamamlandi!');
  
  await Hive.close();
  exit(0);
}
