// DEBUG: DB'de her öğün için yeterli yemek var mı?
// Pure Dart - Flutter gerektirmez

import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  // Hive init
  final appDocDir = Directory.current;
  Hive.init(appDocDir.path);
  
  Hive.registerAdapter(YemekHiveModelAdapter());
  final box = await Hive.openBox<YemekHiveModel>('yemekler');

  print('═══════════════════════════════════════════════════');
  print('🔍 DB ANALİZİ - ÖĞÜN BAZLI SİSTEM DEBUG');
  print('═══════════════════════════════════════════════════\n');

  // Hedef makrolar (3093 kcal için %25, %10, %30, %10, %25 dağılım)
  final hedefler = {
    'kahvalti': 773.0,
    'araogun1': 309.0,
    'ogle': 928.0,
    'araogun2': 309.0,
    'aksam': 773.0,
  };

  for (final entry in hedefler.entries) {
    final kategori = entry.key;
    final hedefKalori = entry.value;
    
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 ${kategori.toUpperCase()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎯 HEDEF: ${hedefKalori.toStringAsFixed(0)} kcal');
    
    // Kategori mapping (Türkçe karaktersiz)
    final yemekler = box.values.where((y) {
      final cat = y.category?.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c');
      final hedefCat = kategori.toLowerCase();
      return cat == hedefCat;
    }).toList();
    
    print('📦 Toplam yemek: ${yemekler.length}');
    
    if (yemekler.isEmpty) {
      print('❌ KRİTİK: Bu kategoride hiç yemek yok!');
      continue;
    }
    
    // Kalori analizi
    final kaloriler = yemekler.map((y) => y.calorie ?? 0.0).toList();
    kaloriler.sort();
    
    final minKal = kaloriler.first;
    final maxKal = kaloriler.last;
    final ortKal = kaloriler.reduce((a, b) => a + b) / kaloriler.length;
    
    print('📈 Kalori Aralığı: ${minKal.toStringAsFixed(0)} - ${maxKal.toStringAsFixed(0)} kcal');
    print('📊 Ortalama: ${ortKal.toStringAsFixed(0)} kcal');
    
    // ±20% toleransta kaç yemek var?
    final minHedef = hedefKalori * 0.8;
    final maxHedef = hedefKalori * 1.2;
    
    final uygunlar = yemekler.where((y) {
      final kal = y.calorie ?? 0.0;
      return kal >= minHedef && kal <= maxHedef;
    }).toList();
    
    print('✅ Hedefe yakın (±20%): ${uygunlar.length}/${yemekler.length}');
    
    if (uygunlar.isEmpty) {
      print('❌ SORUN: Hedefe uygun hiç yemek yok!');
      print('   Hedef: ${hedefKalori.toStringAsFixed(0)} kcal');
      print('   Gerekli aralık: ${minHedef.toStringAsFixed(0)}-${maxHedef.toStringAsFixed(0)} kcal');
      print('   DB\'de en yüksek: ${maxKal.toStringAsFixed(0)} kcal');
      print('   SONUÇ: DB\'de yeterli kalorili yemek YOK!');
    } else {
      // Örnekler göster
      print('📋 Örnek yemekler:');
      for (var i = 0; i < (uygunlar.length < 3 ? uygunlar.length : 3); i++) {
        final y = uygunlar[i];
        print('   ${i + 1}. ${y.mealName} - ${(y.calorie ?? 0).toStringAsFixed(0)} kcal');
      }
    }
    
    // >90% hedef kaç yemek?
    final yuksek = yemekler.where((y) => (y.calorie ?? 0) > hedefKalori * 0.9).length;
    print('🔥 Hedefe yakın/üstü (>90%): $yuksek');
  }

  print('\n═══════════════════════════════════════════════════');
  print('✅ ANALİZ TAMAMLANDI');
  print('═══════════════════════════════════════════════════');
  
  await box.close();
  await Hive.close();
  exit(0);
}
