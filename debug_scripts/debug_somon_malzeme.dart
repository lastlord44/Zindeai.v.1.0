import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_local_data_source.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  print('🔍 Somon Izgara Malzeme Analizi\n');
  
  await Hive.initFlutter();
  
  final hiveService = HiveService();
  await hiveService.init();
  
  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  
  // Tüm öğün tiplerinde "somon" içeren yemekleri bul
  for (final entry in tumYemekler.entries) {
    final ogunTipi = entry.key;
    final yemekler = entry.value;
    
    for (final yemek in yemekler) {
      if (yemek.ad.toLowerCase().contains('somon')) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📌 Öğün: ${ogunTipi.ad}');
        print('📌 Yemek: ${yemek.ad}');
        print('📌 Malzemeler:');
        for (var malzeme in yemek.malzemeler) {
          print('   • $malzeme');
        }
        print('📌 Etiketler: ${yemek.etiketler}');
        print('');
      }
    }
  }
  
  await hiveService.close();
  exit(0);
}
