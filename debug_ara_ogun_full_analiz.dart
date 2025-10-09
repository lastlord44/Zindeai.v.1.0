// 🔍 ARA ÖĞÜN 2 SÜZME YOĞURT SORUNU - TAM ANALİZ
// Tüm olası nedenleri test eden debug scripti

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/core/services/cesitlilik_gecmis_servisi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Adapter kaydet
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  
  print('🔍 ===== ARA ÖĞÜN 2 SÜZME YOĞURT SORUNU ANALİZİ =====\n');
  
  // TEST 1: DB'de Ara Öğün 2 yemekleri kontrolü
  print('📊 TEST 1: DB\'de Ara Öğün 2 Kontrolü');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  await test1_araOgun2Sayisi();
  
  // TEST 2: Süzme yoğurt sayısı
  print('\n🧀 TEST 2: Süzme Yoğurt Analizi');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  await test2_suzmeYogurtSayisi();
  
  // TEST 3: Çeşitlilik geçmişi kontrolü
  print('\n📜 TEST 3: Çeşitlilik Geçmişi');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  await test3_cesitlilikGecmisi();
  
  // TEST 4: Ara Öğün 2 yemeklerinin makro analizi
  print('\n🎯 TEST 4: Makro Analizi (Neden Süzme Yoğurt Seçiliyor?)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  await test4_makroAnalizi();
  
  // TEST 5: Örnek seçim simülasyonu
  print('\n🎲 TEST 5: Rastgele Seçim Simülasyonu (10 deneme)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  await test5_secimSimulasyonu();
  
  print('\n✅ ===== ANALİZ TAMAMLANDI =====\n');
  
  await Hive.close();
}

// TEST 1: Ara Öğün 2 yemekleri var mı?
Future<void> test1_araOgun2Sayisi() async {
  final box = await Hive.openBox<YemekHiveModel>('yemek_box');
  
  final araOgun2List = box.values
      .where((y) => y.ogun == OgunTipi.araOgun2.index)
      .toList();
  
  print('✅ Toplam Ara Öğün 2 sayısı: ${araOgun2List.length}');
  
  if (araOgun2List.isEmpty) {
    print('❌ KRİTİK SORUN: Ara Öğün 2 yemekleri DB\'de YOK!');
    print('   → Migration başarısız olmuş olabilir');
    print('   → Profil sayfasından DB yenileme yapın');
  } else if (araOgun2List.length < 50) {
    print('⚠️  UYARI: Ara Öğün 2 yemekleri çok az (${araOgun2List.length})');
    print('   → Beklenen: 120+ yemek');
    print('   → Migration eksik olabilir');
  } else {
    print('✅ Ara Öğün 2 yemekleri yeterli');
  }
  
  // İlk 5 yemeği göster
  print('\n📋 İlk 5 Ara Öğün 2 Yemeği:');
  for (int i = 0; i < 5 && i < araOgun2List.length; i++) {
    final y = araOgun2List[i];
    print('   ${i + 1}. ${y.ad} (${y.kalori} kcal, P:${y.protein}g, K:${y.karbonhidrat}g, Y:${y.yag}g)');
  }
}

// TEST 2: Süzme yoğurt kaç tane var?
Future<void> test2_suzmeYogurtSayisi() async {
  final box = await Hive.openBox<YemekHiveModel>('yemek_box');
  
  final suzmeYogurtlar = box.values
      .where((y) => y.ogun == OgunTipi.araOgun2.index)
      .where((y) => y.ad.toLowerCase().contains('süzme') || 
                     y.ad.toLowerCase().contains('suzme'))
      .toList();
  
  print('🧀 Süzme yoğurt çeşitleri: ${suzmeYogurtlar.length}');
  
  if (suzmeYogurtlar.isEmpty) {
    print('✅ Süzme yoğurt yok - sorun başka bir yerde');
  } else {
    print('\n📋 Süzme Yoğurt Listesi:');
    for (final y in suzmeYogurtlar) {
      print('   • ${y.ad} (ID: ${y.id})');
      print('     Makro: ${y.kalori} kcal, P:${y.protein}g, K:${y.karbonhidrat}g, Y:${y.yag}g');
    }
    
    final araOgun2Toplam = box.values
        .where((y) => y.ogun == OgunTipi.araOgun2.index)
        .length;
    
    final oran = (suzmeYogurtlar.length / araOgun2Toplam * 100).toStringAsFixed(1);
    print('\n📊 Süzme yoğurt oranı: $oran% (${suzmeYogurtlar.length}/${araOgun2Toplam})');
    
    if (suzmeYogurtlar.length > araOgun2Toplam * 0.1) {
      print('⚠️  UYARI: Süzme yoğurt oranı yüksek!');
      print('   → Çeşitlilik mekanizması zorlanabilir');
    }
  }
}

// TEST 3: Çeşitlilik geçmişi dolu mu?
Future<void> test3_cesitlilikGecmisi() async {
  final gecmis = CesitlilikGecmisServisi.gecmisiGetir(OgunTipi.araOgun2);
  
  print('📜 Ara Öğün 2 geçmiş uzunluğu: ${gecmis.length}');
  
  if (gecmis.isEmpty) {
    print('✅ Geçmiş temiz - ilk seçim yapılacak');
  } else {
    print('📋 Son kullanılan yemek ID\'leri:');
    final sonrakiler = gecmis.length > 10 ? gecmis.sublist(gecmis.length - 10) : gecmis;
    for (int i = 0; i < sonrakiler.length; i++) {
      print('   ${i + 1}. ${sonrakiler[i]}');
    }
    
    // Süzme yoğurt ID'leri geçmişte mi?
    final box = await Hive.openBox<YemekHiveModel>('yemek_box');
    final suzmeYogurtIDs = box.values
        .where((y) => y.ogun == OgunTipi.araOgun2.index)
        .where((y) => y.ad.toLowerCase().contains('süzme') || 
                       y.ad.toLowerCase().contains('suzme'))
        .map((y) => y.id)
        .toList();
    
    final gecmisteVarMi = gecmis.any((id) => suzmeYogurtIDs.contains(id));
    
    if (gecmisteVarMi) {
      print('⚠️  Süzme yoğurt geçmişte VAR ama yine seçiliyor!');
      print('   → Çeşitlilik filtreleme çalışmıyor olabilir');
    } else {
      print('✅ Süzme yoğurt geçmişte YOK');
    }
  }
}

// TEST 4: Makro analizi - neden süzme yoğurt?
Future<void> test4_makroAnalizi() async {
  final box = await Hive.openBox<YemekHiveModel>('yemek_box');
  
  final araOgun2List = box.values
      .where((y) => y.ogun == OgunTipi.araOgun2.index)
      .toList();
  
  // Örnek hedef makrolar (160 kcal ara öğün için tipik)
  const hedefKalori = 160.0;
  const hedefProtein = 15.0;
  const hedefKarb = 15.0;
  const hedefYag = 5.0;
  
  print('🎯 Hedef Makrolar: ${hedefKalori} kcal, P:${hedefProtein}g, K:${hedefKarb}g, Y:${hedefYag}g');
  print('');
  
  // Her yemek için fitness skoru hesapla
  final skorlar = <MapEntry<String, double>>[];
  
  for (final y in araOgun2List) {
    final kaloriSapma = ((y.kalori - hedefKalori).abs() / hedefKalori) * 100;
    final proteinSapma = ((y.protein - hedefProtein).abs() / hedefProtein) * 100;
    final karbSapma = ((y.karbonhidrat - hedefKarb).abs() / hedefKarb) * 100;
    final yagSapma = ((y.yag - hedefYag).abs() / hedefYag) * 100;
    
    final ortalamaSapma = (kaloriSapma + proteinSapma + karbSapma + yagSapma) / 4;
    final fitness = 100 - ortalamaSapma;
    
    skorlar.add(MapEntry('${y.ad} (${y.kalori} kcal)', fitness));
  }
  
  // En iyi 10 yemeği göster
  skorlar.sort((a, b) => b.value.compareTo(a.value));
  
  print('🏆 EN İYİ 10 YEMEK (Makro Uygunluğu):');
  for (int i = 0; i < 10 && i < skorlar.length; i++) {
    final isSuzme = skorlar[i].key.toLowerCase().contains('süzme') || 
                    skorlar[i].key.toLowerCase().contains('suzme');
    final emoji = isSuzme ? '🧀' : '  ';
    print('   ${i + 1}. $emoji ${skorlar[i].key} → Skor: ${skorlar[i].value.toStringAsFixed(1)}');
  }
  
  // Süzme yoğurt top 10'da mı?
  final top10Suzme = skorlar
      .take(10)
      .where((e) => e.key.toLowerCase().contains('süzme') || 
                     e.key.toLowerCase().contains('suzme'))
      .length;
  
  if (top10Suzme > 0) {
    print('\n⚠️  SORUN BULUNDU: Süzme yoğurt en iyi $top10Suzme yemek arasında!');
    print('   → Makrolar için mükemmel uyum gösteriyor');
    print('   → Genetik algoritma sürekli onu seçiyor');
    print('   → ÇÖZÜM: Çeşitlilik filtreleme güçlendirilmeli');
  }
}

// TEST 5: Seçim simülasyonu
Future<void> test5_secimSimulasyonu() async {
  final box = await Hive.openBox<YemekHiveModel>('yemek_box');
  
  final araOgun2List = box.values
      .where((y) => y.ogun == OgunTipi.araOgun2.index)
      .toList();
  
  print('🎲 10 rastgele seçim yapılıyor...\n');
  
  final secimler = <String>[];
  
  for (int i = 0; i < 10; i++) {
    // Basit rastgele seçim (çeşitlilik mekanizması olmadan)
    final rastgele = (DateTime.now().microsecondsSinceEpoch % araOgun2List.length);
    final secilen = araOgun2List[rastgele];
    secimler.add(secilen.ad);
    print('   ${i + 1}. ${secilen.ad}');
  }
  
  // Süzme yoğurt kaç kez seçildi?
  final suzmeCount = secimler
      .where((ad) => ad.toLowerCase().contains('süzme') || 
                      ad.toLowerCase().contains('suzme'))
      .length;
  
  print('\n📊 Süzme yoğurt seçilme: $suzmeCount/10');
  
  if (suzmeCount > 3) {
    print('⚠️  UYARI: Rastgele seçimde bile sık çıkıyor!');
    print('   → DB\'de çok fazla süzme yoğurt olabilir');
  }
  
  // Çeşitlilik kontrolü
  final benzersizSayi = secimler.toSet().length;
  print('🎯 Çeşitlilik: $benzersizSayi/10 farklı yemek');
  
  if (benzersizSayi < 7) {
    print('⚠️  Çeşitlilik düşük - tekrar eden yemekler var');
  }
}
