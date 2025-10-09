// DEBUG: Öğün bazlı sistem neden çalışmıyor?
// Her öğün için DB'de ne var kontrol edelim

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(YemekHiveModelAdapter());
  await Hive.openBox<YemekHiveModel>('yemekler');

  print('═══════════════════════════════════════════════════');
  print('🔍 ÖĞÜN BAZLI SİSTEM DEBUG - DB ANALİZİ');
  print('═══════════════════════════════════════════════════\n');

  final box = Hive.box<YemekHiveModel>('yemekler');
  
  // Hedef makrolar (3093 kcal için)
  final hedefler = {
    'kahvalti': {'kalori': 773.0, 'protein': 40.0, 'karb': 104.0, 'yag': 22.0},
    'araOgun1': {'kalori': 309.0, 'protein': 16.0, 'karb': 41.0, 'yag': 9.0},
    'ogle': {'kalori': 928.0, 'protein': 48.0, 'karb': 125.0, 'yag': 26.0},
    'araOgun2': {'kalori': 309.0, 'protein': 16.0, 'karb': 41.0, 'yag': 9.0},
    'aksam': {'kalori': 773.0, 'protein': 40.0, 'karb': 104.0, 'yag': 22.0},
  };

  for (final entry in hedefler.entries) {
    final kategori = entry.key;
    final hedef = entry.value;
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 ${kategori.toUpperCase()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎯 HEDEF: ${hedef['kalori']!.toStringAsFixed(0)} kcal');
    
    // O kategorideki tüm yemekleri bul
    final yemekler = box.values.where((y) {
      final cat = y.category?.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('ö', 'o').replaceAll('ü', 'u').replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ş', 's').replaceAll('ç', 'c');
      final hedefCat = kategori.toLowerCase();
      return cat == hedefCat;
    }).toList();
    
    print('📦 Toplam yemek: ${yemekler.length}');
    
    if (yemekler.isEmpty) {
      print('❌ KRİTİK: Bu kategoride hiç yemek yok!');
      continue;
    }
    
    // Kalori aralığı analizi
    final kaloriler = yemekler.map((y) => y.calorie ?? 0.0).toList();
    kaloriler.sort();
    
    final minKalori = kaloriler.first;
    final maxKalori = kaloriler.last;
    final ortKalori = kaloriler.reduce((a, b) => a + b) / kaloriler.length;
    
    print('📈 Kalori Aralığı: ${minKalori.toStringAsFixed(0)} - ${maxKalori.toStringAsFixed(0)} kcal');
    print('📊 Ortalama: ${ortKalori.toStringAsFixed(0)} kcal');
    
    // Hedefe yakın yemekler (±20% tolerans)
    final hedefKalori = hedef['kalori']!;
    final minHedef = hedefKalori * 0.8;
    final maxHedef = hedefKalori * 1.2;
    
    final uygunYemekler = yemekler.where((y) {
      final kalori = y.calorie ?? 0.0;
      return kalori >= minHedef && kalori <= maxHedef;
    }).toList();
    
    print('✅ Hedefe yakın yemekler (±20%): ${uygunYemekler.length}/${yemekler.length}');
    
    if (uygunYemekler.isEmpty) {
      print('❌ SORUN: Hedefe uygun hiç yemek yok!');
      print('   Hedef: ${hedefKalori.toStringAsFixed(0)} kcal');
      print('   Aralık: ${minHedef.toStringAsFixed(0)} - ${maxHedef.toStringAsFixed(0)} kcal');
      print('   DB\'de en yüksek: ${maxKalori.toStringAsFixed(0)} kcal');
    } else {
      // İlk 3 örneği göster
      print('📋 Örnek yemekler:');
      for (var i = 0; i < uygunYemekler.length.clamp(0, 3); i++) {
        final y = uygunYemekler[i];
        print('   ${i + 1}. ${y.mealName} - ${y.calorie!.toStringAsFixed(0)} kcal');
      }
    }
    
    // Hedefin çok üstünde olanlar var mı?
    final yuksekKalorili = yemekler.where((y) => (y.calorie ?? 0) > hedefKalori * 0.9).toList();
    print('🔥 Hedefe yakın/üstü (>90%): ${yuksekKalorili.length}');
  }

  print('\n═══════════════════════════════════════════════════');
  print('✅ ANALİZ TAMAMLANDI');
  print('═══════════════════════════════════════════════════');
  
  await Hive.close();
}
