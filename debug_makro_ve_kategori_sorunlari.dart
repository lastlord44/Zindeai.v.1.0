// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı başlat
  await Hive.initFlutter();
  
  // Adapter'ı kaydet
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  
  // Box'ı aç
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('═══════════════════════════════════════════════════════════════');
  print('🔍 MAKRO VE KATEGORİ SORUNLARI ANALİZİ');
  print('═══════════════════════════════════════════════════════════════\n');
  
  // 1️⃣ TOPLAM İSTATİSTİK
  print('📊 TOPLAM VERİ:');
  print('   Toplam yemek sayısı: ${box.length}');
  print('');
  
  // 2️⃣ MAKRO SORUNLARI - Kalori 0 olanlar
  print('⚠️  MAKRO SORUNLARI (Kalori = 0):');
  final makroSorunlular = <String, YemekHiveModel>{};
  
  for (var i = 0; i < box.length; i++) {
    final yemekModel = box.getAt(i);
    if (yemekModel != null && (yemekModel.calorie == null || yemekModel.calorie == 0)) {
      makroSorunlular[yemekModel.mealId ?? 'unknown-$i'] = yemekModel;
    }
  }
  
  print('   Kalori = 0 olan yemek sayısı: ${makroSorunlular.length}');
  
  if (makroSorunlular.isNotEmpty) {
    print('\n   İlk 10 örnek:');
    var sayac = 0;
    for (final entry in makroSorunlular.entries) {
      if (sayac >= 10) break;
      final yemek = entry.value;
      print('   ${sayac + 1}. ${yemek.mealName ?? "İsimsiz"} (${yemek.category ?? "?"})');
      print('      Kalori: ${yemek.calorie}, Protein: ${yemek.proteinG}, Karb: ${yemek.carbG}, Yağ: ${yemek.fatG}');
      sayac++;
    }
  }
  print('');
  
  // 3️⃣ KATEGORİ SORUNLARI - Ana yemekler kahvaltıda
  print('⚠️  KATEGORİ SORUNLARI (Ana yemekler kahvaltıda):');
  final kategoriSorunlular = <String, YemekHiveModel>{};
  
  // Ana yemek işaretçileri (balık, et, tavuk vb.)
  final anaYemekIsaretcileri = [
    'uskumru', 'somon', 'levrek', 'hamsi', 'palamut', 'çipura', 'sardalya',
    'tavuk', 'hindi', 'et', 'dana', 'koyun', 'kuzu',
    'köfte', 'kıyma', 'rosto', 'biftek',
    'pilav', 'makarna', 'pizza', 'mantı',
  ];
  
  for (var i = 0; i < box.length; i++) {
    final yemekModel = box.getAt(i);
    if (yemekModel != null && 
        yemekModel.category != null && 
        yemekModel.category!.toLowerCase().contains('kahvalti')) {
      final adLower = (yemekModel.mealName ?? '').toLowerCase();
      
      // Ana yemek işaretçisi var mı?
      for (final isaretci in anaYemekIsaretcileri) {
        if (adLower.contains(isaretci)) {
          kategoriSorunlular[yemekModel.mealId ?? 'unknown-$i'] = yemekModel;
          break;
        }
      }
    }
  }
  
  print('   Kahvaltıda ana yemek olabilecek: ${kategoriSorunlular.length}');
  
  if (kategoriSorunlular.isNotEmpty) {
    print('\n   Tüm sorunlular:');
    var sayac = 0;
    for (final entry in kategoriSorunlular.entries) {
      final yemek = entry.value;
      print('   ${sayac + 1}. ${yemek.mealName ?? "İsimsiz"}');
      print('      Kalori: ${yemek.calorie}, Protein: ${yemek.proteinG}');
      sayac++;
    }
  }
  print('');
  
  // 4️⃣ TOPLAM ÖZET
  print('═══════════════════════════════════════════════════════════════');
  print('📋 ÖZET:');
  print('   ❌ Makro sorunu (0 kalori): ${makroSorunlular.length} yemek');
  print('   ❌ Kategori sorunu (kahvaltıda ana yemek): ${kategoriSorunlular.length} yemek');
  print('   ✅ Sağlıklı yemek: ${box.length - makroSorunlular.length} yemek');
  print('═══════════════════════════════════════════════════════════════');
  
  // 5️⃣ ÖZELLİKLE "Izgara Uskumru" kontrolü
  print('\n🔎 "Izgara Uskumru" özel kontrolü:');
  var uskumruBulundu = false;
  for (var i = 0; i < box.length; i++) {
    final yemekModel = box.getAt(i);
    if (yemekModel != null && 
        yemekModel.mealName != null && 
        yemekModel.mealName!.toLowerCase().contains('uskumru')) {
      uskumruBulundu = true;
      print('   ✓ Bulundu: ${yemekModel.mealName}');
      print('     Kategori: ${yemekModel.category}');
      print('     Kalori: ${yemekModel.calorie}');
      print('     Protein: ${yemekModel.proteinG}');
      print('     Karb: ${yemekModel.carbG}');
      print('     Yağ: ${yemekModel.fatG}');
      print('     ID: ${yemekModel.mealId}');
      print('');
    }
  }
  
  if (!uskumruBulundu) {
    print('   ❌ Veritabanında uskumru içeren yemek bulunamadı!');
  }
  
  // 6️⃣ RASTGELE 5 YEMEK ÖRNEK (Makro kontrolü için)
  print('═══════════════════════════════════════════════════════════════');
  print('📌 RASTGELE 5 YEMEK ÖRNEĞİ (Makro değerleri):');
  final rastgeleIndeksler = <int>[];
  while (rastgeleIndeksler.length < 5 && rastgeleIndeksler.length < box.length) {
    final indeks = (box.length * (rastgeleIndeksler.length + 1) / 6).floor();
    if (!rastgeleIndeksler.contains(indeks)) {
      rastgeleIndeksler.add(indeks);
    }
  }
  
  for (final indeks in rastgeleIndeksler) {
    final yemekModel = box.getAt(indeks);
    if (yemekModel != null) {
      print('\n${rastgeleIndeksler.indexOf(indeks) + 1}. ${yemekModel.mealName ?? "İsimsiz"}');
      print('   Kategori: ${yemekModel.category ?? "?"}');
      print('   Kalori: ${yemekModel.calorie ?? 0} kcal');
      print('   Protein: ${yemekModel.proteinG ?? 0}g');
      print('   Karb: ${yemekModel.carbG ?? 0}g');
      print('   Yağ: ${yemekModel.fatG ?? 0}g');
    }
  }
  print('═══════════════════════════════════════════════════════════════');
  
  await box.close();
}
