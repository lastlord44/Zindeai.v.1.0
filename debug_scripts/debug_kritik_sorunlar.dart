// DEBUG: Kritik sorunları analiz et
// 1. Ara Öğün 2 isim sorunu
// 2. Tolerans aşımı (kalori/karb)
// 3. Performans (frame skip)

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/utils/db_summary_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(YemekHiveModelAdapter());
  await Hive.openBox<YemekHiveModel>('yemekler');

  print('═══════════════════════════════════════════════════');
  print('🔍 KRİTİK SORUN ANALİZİ');
  print('═══════════════════════════════════════════════════\n');

  // 1️⃣ ARA ÖĞÜN 2 İSİM SORUNU ANALİZİ
  print('1️⃣ ARA ÖĞÜN 2 İSİM SORUNU:');
  print('─────────────────────────────────────────────────');
  
  final box = Hive.box<YemekHiveModel>('yemekler');
  final araOgun2Yemekler = box.values
      .where((y) => y.ogun == 'araOgun2' || y.ogun == 'araogun2' || y.ogun == 'ara_ogun_2')
      .toList();
  
  print('✅ Toplam Ara Öğün 2: ${araOgun2Yemekler.length}');
  
  // Boş/null isim kontrolü
  final bosIsimler = araOgun2Yemekler.where((y) => 
    y.ad == null || y.ad.trim().isEmpty
  ).toList();
  
  if (bosIsimler.isNotEmpty) {
    print('❌ SORUN: ${bosIsimler.length} yemekte isim BOŞ!');
    for (var y in bosIsimler.take(5)) {
      print('   - ID: ${y.id}, Ad: "${y.ad}", Kalori: ${y.kalori}');
    }
  } else {
    print('✅ Tüm Ara Öğün 2 yemeklerinde isim var');
  }
  
  // İlk 5 örnek
  print('\n📋 Ara Öğün 2 Örnekleri (ilk 5):');
  for (var y in araOgun2Yemekler.take(5)) {
    print('   ${y.ad} - ${y.kalori.toStringAsFixed(0)} kcal | P:${y.protein.toStringAsFixed(0)}g K:${y.karbonhidrat.toStringAsFixed(0)}g Y:${y.yag.toStringAsFixed(0)}g');
  }

  // 2️⃣ MAKRO HEDEFLERİ ANALİZİ
  print('\n\n2️⃣ MAKRO HEDEFLERİ VE TOLERANS ANALİZİ:');
  print('─────────────────────────────────────────────────');
  
  // Örnek hedefler (logdan)
  final hedefKalori = 3048.075;
  final hedefProtein = 160.6;
  final hedefKarb = 404.3;
  final hedefYag = 87.6;
  
  print('🎯 HEDEFLER:');
  print('   Kalori: ${hedefKalori.toStringAsFixed(0)} kcal');
  print('   Protein: ${hedefProtein.toStringAsFixed(0)}g');
  print('   Karb: ${hedefKarb.toStringAsFixed(0)}g');
  print('   Yağ: ${hedefYag.toStringAsFixed(0)}g');
  
  // Her öğün için ortalama makro ihtiyacı (5 öğün varsayımı)
  print('\n📊 ÖĞÜN BAŞINA ORTALAMA İHTİYAÇ (5 öğün):');
  print('   Kalori/öğün: ${(hedefKalori / 5).toStringAsFixed(0)} kcal');
  print('   Protein/öğün: ${(hedefProtein / 5).toStringAsFixed(0)}g');
  print('   Karb/öğün: ${(hedefKarb / 5).toStringAsFixed(0)}g');
  print('   Yağ/öğün: ${(hedefYag / 5).toStringAsFixed(0)}g');

  // Ara öğün 2 için gerçekçi hedefler
  final araOgun2HedefKalori = hedefKalori * 0.10; // %10 günlük kalorinin
  final araOgun2HedefProtein = hedefProtein * 0.10;
  final araOgun2HedefKarb = hedefKarb * 0.10;
  final araOgun2HedefYag = hedefYag * 0.10;
  
  print('\n🎯 ARA ÖĞÜN 2 İÇİN MAKUL HEDEF (%10 günlük):');
  print('   Kalori: ${araOgun2HedefKalori.toStringAsFixed(0)} kcal');
  print('   Protein: ${araOgun2HedefProtein.toStringAsFixed(0)}g');
  print('   Karb: ${araOgun2HedefKarb.toStringAsFixed(0)}g');
  print('   Yağ: ${araOgun2HedefYag.toStringAsFixed(0)}g');

  // Tolerans içinde kaç yemek var?
  final tolerans = 0.20; // %20 tolerans
  final uygunYemekler = araOgun2Yemekler.where((y) {
    final kaloriUygun = (y.kalori - araOgun2HedefKalori).abs() / araOgun2HedefKalori <= tolerans;
    final proteinUygun = (y.protein - araOgun2HedefProtein).abs() / araOgun2HedefProtein <= tolerans;
    final karbUygun = (y.karbonhidrat - araOgun2HedefKarb).abs() / araOgun2HedefKarb <= tolerans;
    final yagUygun = (y.yag - araOgun2HedefYag).abs() / araOgun2HedefYag <= tolerans;
    return kaloriUygun && proteinUygun && karbUygun && yagUygun;
  }).toList();
  
  print('\n✅ ±20% tolerans içinde: ${uygunYemekler.length}/${araOgun2Yemekler.length} yemek');
  
  if (uygunYemekler.isEmpty) {
    print('❌ SORUN: Ara Öğün 2\'de hedeflere uygun yemek YOK!');
  } else {
    print('📋 Uygun yemek örnekleri:');
    for (var y in uygunYemekler.take(3)) {
      print('   ${y.ad} - ${y.kalori.toStringAsFixed(0)} kcal');
    }
  }

  // 3️⃣ TÜM KATEGORİLER İÇİN İSTATİSTİK
  print('\n\n3️⃣ TÜM KATEGORİLER İÇİN İSTATİSTİK:');
  print('─────────────────────────────────────────────────');
  
  final kategoriler = ['kahvalti', 'araOgun1', 'ogle', 'araOgun2', 'aksam'];
  
  for (final kategori in kategoriler) {
    final yemekler = box.values
        .where((y) => y.ogun.toLowerCase().replaceAll('_', '').replaceAll(' ', '') == 
                      kategori.toLowerCase().replaceAll('_', '').replaceAll(' ', ''))
        .toList();
    
    if (yemekler.isEmpty) continue;
    
    final ortKalori = yemekler.map((y) => y.kalori).reduce((a, b) => a + b) / yemekler.length;
    final ortProtein = yemekler.map((y) => y.protein).reduce((a, b) => a + b) / yemekler.length;
    final ortKarb = yemekler.map((y) => y.karbonhidrat).reduce((a, b) => a + b) / yemekler.length;
    final ortYag = yemekler.map((y) => y.yag).reduce((a, b) => a + b) / yemekler.length;
    
    print('\n📊 ${kategori.toUpperCase()}:');
    print('   Toplam: ${yemekler.length} yemek');
    print('   Ort Kalori: ${ortKalori.toStringAsFixed(0)} kcal');
    print('   Ort Protein: ${ortProtein.toStringAsFixed(0)}g');
    print('   Ort Karb: ${ortKarb.toStringAsFixed(0)}g');
    print('   Ort Yağ: ${ortYag.toStringAsFixed(0)}g');
  }

  // 4️⃣ GENETİK ALGORİTMA PERFORMANS ANALİZİ
  print('\n\n4️⃣ GENETİK ALGORİTMA PERFORMANS ANALİZİ:');
  print('─────────────────────────────────────────────────');
  print('🔧 Mevcut parametreler:');
  print('   Popülasyon: 30');
  print('   Jenerasyon: 30');
  print('   Toplam iterasyon: 900');
  print('   Fitness fonksiyonu: 4 makro x 25 puan = 100 puan');
  print('\n⚡ Sorun: 900 iterasyon main thread\'de çalışıyor → UI donuyor');
  print('✅ Çözüm: Compute/Isolate kullan VEYA iterasyonu azalt');

  print('\n═══════════════════════════════════════════════════');
  print('✅ ANALİZ TAMAMLANDI');
  print('═══════════════════════════════════════════════════');
  
  await Hive.close();
}
