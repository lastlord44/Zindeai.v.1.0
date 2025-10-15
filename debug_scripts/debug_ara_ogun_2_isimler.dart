import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_local_data_source.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  print('🔍 ARA ÖĞÜN 2 - İSİM KONTROLÜ\n');
  
  await Hive.initFlutter();
  await HiveService.init();
  
  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  
  final araOgun2 = tumYemekler[OgunTipi.araOgun2] ?? [];
  
  print('════════════════════════════════════════════════════════');
  print('📊 GENEL BİLGİ');
  print('════════════════════════════════════════════════════════');
  print('Toplam Ara Öğün 2 yemeği: ${araOgun2.length}\n');
  
  // İsim problemlerini tespit et
  int bosIsim = 0;
  int kategoriIsimli = 0;
  int normalIsim = 0;
  
  print('════════════════════════════════════════════════════════');
  print('🔍 İSİM ANALİZİ');
  print('════════════════════════════════════════════════════════\n');
  
  for (var i = 0; i < araOgun2.length && i < 20; i++) {
    final yemek = araOgun2[i];
    
    // İsim kontrolleri
    if (yemek.ad.isEmpty) {
      bosIsim++;
      print('❌ BOŞ İSİM - ID: ${yemek.id}');
    } else if (yemek.ad.toLowerCase().contains('ara öğün') || 
               yemek.ad.toLowerCase().contains('araogun')) {
      kategoriIsimli++;
      print('⚠️  KATEGORİ İSİMLİ: "${yemek.ad}" (ID: ${yemek.id})');
      print('   Malzemeler: ${yemek.malzemeler.take(2).join(", ")}');
      print('   Kalori: ${yemek.kalori.toInt()} kcal');
    } else {
      normalIsim++;
      if (i < 5) {
        print('✅ NORMAL: "${yemek.ad}"');
        print('   Kalori: ${yemek.kalori.toInt()} kcal | P: ${yemek.protein.toInt()}g');
      }
    }
    print('');
  }
  
  print('════════════════════════════════════════════════════════');
  print('📊 ÖZET');
  print('════════════════════════════════════════════════════════');
  print('✅ Normal isimli yemekler: $normalIsim');
  print('⚠️  Kategori isimli yemekler: $kategoriIsimli');
  print('❌ Boş isimli yemekler: $bosIsim');
  print('');
  
  // Kategori kontrolü
  print('════════════════════════════════════════════════════════');
  print('🏷️  KATEGORİ KONTROLÜ');
  print('════════════════════════════════════════════════════════');
  int yanlisKategori = 0;
  for (var yemek in araOgun2.take(10)) {
    if (yemek.ogun != OgunTipi.araOgun2) {
      yanlisKategori++;
      print('❌ YANLIŞ KATEGORİ: ${yemek.ad} -> ${yemek.ogun.ad}');
    }
  }
  if (yanlisKategori == 0) {
    print('✅ Tüm yemekler doğru kategoride (ilk 10 kontrol edildi)');
  }
  
  await HiveService.close();
  exit(0);
}
