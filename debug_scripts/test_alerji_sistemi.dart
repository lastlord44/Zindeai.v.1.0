import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_local_data_source.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  print('🔍 Akıllı Alerji Sistemi Test\n');
  
  await Hive.initFlutter();
  await HiveService.init();
  
  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  
  // Test 1: Balık alerjisi
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🐟 TEST 1: BALIK ALERJISI\n');
  
  final balikAlerjisi = ['balık'];
  int toplamYemek = 0;
  int filtrelenenYemek = 0;
  int somonYemek = 0;
  
  for (final entry in tumYemekler.entries) {
    final ogunTipi = entry.key;
    final yemekler = entry.value;
    
    for (final yemek in yemekler) {
      toplamYemek++;
      
      // Somon içeren yemekleri say
      if (yemek.ad.toLowerCase().contains('somon')) {
        somonYemek++;
        print('   ⚠️  SOMON BULUNDU: ${yemek.ad} (${ogunTipi.ad})');
        
        // Filtrelenecek mi kontrol et
        if (!yemek.kisitlamayaUygunMu(balikAlerjisi)) {
          print('      ✅ FILTRELENDI (Alerji sistemi çalışıyor!)');
        } else {
          print('      ❌ FILTRELENMEDI (HATA!)');
        }
        print('');
      }
      
      // Genel balık içeren yemekleri say
      if (!yemek.kisitlamayaUygunMu(balikAlerjisi)) {
        filtrelenenYemek++;
      }
    }
  }
  
  print('📊 SONUÇ:');
  print('   • Toplam yemek: $toplamYemek');
  print('   • Filtrelenen yemek: $filtrelenenYemek');
  print('   • Somon içeren yemek: $somonYemek');
  print('');
  
  // Test 2: Süt alerjisi
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🥛 TEST 2: SUT ALERJISI\n');
  
  final sutAlerjisi = ['süt'];
  int sutFiltrelenen = 0;
  
  final araOgun2 = tumYemekler[OgunTipi.araOgun2] ?? [];
  print('Ara Ogun 2 toplam yemek: ${araOgun2.length}');
  
  for (final yemek in araOgun2) {
    if (!yemek.kisitlamayaUygunMu(sutAlerjisi)) {
      sutFiltrelenen++;
    } else {
      print('   ✅ SUTSUZ SECENEK: ${yemek.ad}');
    }
  }
  
  print('\n📊 SONUÇ:');
  print('   • Ara Ogun 2 sut içeren: $sutFiltrelenen');
  print('   • Ara Ogun 2 sutsuz: ${araOgun2.length - sutFiltrelenen}');
  print('');
  
  // Test 3: Ara Öğün 2 isim problemi
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 TEST 3: ARA OGUN 2 ISIM KONTROLU\n');
  
  for (final yemek in araOgun2.take(5)) {
    print('📌 ID: ${yemek.id}');
    print('   Ad: "${yemek.ad}"');
    print('   Kategori: ${yemek.ogun.ad}');
    print('   Malzemeler: ${yemek.malzemeler.take(3).join(", ")}...');
    print('   Kalori: ${yemek.kalori.toInt()} kcal');
    print('');
  }
  
  await HiveService.close();
  exit(0);
}
