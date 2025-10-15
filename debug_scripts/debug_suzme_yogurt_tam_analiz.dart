// 🔍 SÜZME YOĞURT SORUNU - TAM ANALİZ VE TEŞHİS
// Her olası nedeni kontrol eden debug scripti

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
  
  print('🔍 ===== SÜZME YOĞURT SORUNU - TAM ANALİZ =====\n');
  
  await runFullAnalysis();
  
  print('\n✅ ===== ANALİZ TAMAMLANDI =====\n');
  
  await Hive.close();
}

Future<void> runFullAnalysis() async {
  final box = await Hive.openBox<YemekHiveModel>('yemek_box');
  
  // TEST 1: DB Genel Durum
  print('📊 TEST 1: VERİTABANI GENEL DURUMU');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  final toplamYemek = box.length;
  print('✅ Toplam yemek sayısı: $toplamYemek');
  
  // Kategorilere göre dağılım
  final kategoriler = <OgunTipi, int>{};
  for (final model in box.values) {
    final entity = model.toEntity();
    kategoriler[entity.ogun] = (kategoriler[entity.ogun] ?? 0) + 1;
  }
  
  print('\n📋 Kategori Dağılımı:');
  for (final entry in kategoriler.entries) {
    final kategoriAd = entry.key.toString().split('.').last;
    print('   • $kategoriAd: ${entry.value} yemek');
  }
  
  // TEST 2: Ara Öğün 2 Detaylı Analiz
  print('\n\n🎯 TEST 2: ARA ÖĞÜN 2 DETAYLI ANALİZ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  final araOgun2List = box.values
      .map((m) => m.toEntity())
      .where((y) => y.ogun == OgunTipi.araOgun2)
      .toList();
  
  print('✅ Ara Öğün 2 toplam: ${araOgun2List.length}');
  
  if (araOgun2List.isEmpty) {
    print('❌ KRİTİK SORUN: Ara Öğün 2 YOK!');
    print('   → Profil sayfasından DB yenileme yapın');
    return;
  } else if (araOgun2List.length < 50) {
    print('⚠️  UYARI: Ara Öğün 2 çok az! (Beklenen: 120+)');
  }
  
  // Süzme yoğurt analizi
  final suzmeYogurtlar = araOgun2List
      .where((y) => y.ad.toLowerCase().contains('süzme') || 
                     y.ad.toLowerCase().contains('suzme'))
      .toList();
  
  print('\n🧀 Süzme Yoğurt Analizi:');
  print('   Sayı: ${suzmeYogurtlar.length}');
  print('   Oran: ${(suzmeYogurtlar.length / araOgun2List.length * 100).toStringAsFixed(1)}%');
  
  if (suzmeYogurtlar.isNotEmpty) {
    print('\n📋 Süzme Yoğurt Listesi:');
    for (final y in suzmeYogurtlar) {
      print('   • ${y.ad}');
      print('     Makro: ${y.kalori} kcal, P:${y.protein}g, K:${y.karbonhidrat}g, Y:${y.yag}g');
    }
  }
  
  // TEST 3: Çeşitlilik Geçmişi Kontrolü
  print('\n\n📜 TEST 3: ÇEŞİTLİLİK GEÇMİŞİ DURUMU');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  final gecmis = CesitlilikGecmisServisi.gecmisiGetir(OgunTipi.araOgun2);
  print('📋 Geçmiş uzunluğu: ${gecmis.length}');
  
  if (gecmis.isEmpty) {
    print('✅ Geçmiş temiz (ilk seçim)');
  } else {
    print('📝 Son 10 seçilen yemek ID:');
    final son10 = gecmis.length > 10 ? gecmis.sublist(gecmis.length - 10) : gecmis;
    for (int i = 0; i < son10.length; i++) {
      final id = son10[i];
      // ID'ye karşılık gelen yemeği bul
      final yemek = araOgun2List.firstWhere(
        (y) => y.id == id,
        orElse: () => Yemek(
          id: 'BULUNAMADI',
          ad: 'Yemek bulunamadı (eski ID: $id)',
          kalori: 0,
          protein: 0,
          karbonhidrat: 0,
          yag: 0,
          ogun: OgunTipi.araOgun2,
        ),
      );
      print('   ${i + 1}. ${yemek.ad}');
    }
    
    // Süzme yoğurt geçmişte var mı?
    final suzmeIDs = suzmeYogurtlar.map((y) => y.id).toList();
    final gecmisteVarMi = gecmis.any((id) => suzmeIDs.contains(id));
    
    if (gecmisteVarMi) {
      print('\n⚠️  SORUN: Süzme yoğurt geçmişte VAR ama yine seçiliyor!');
      print('   → Çeşitlilik mekanizması çalışmıyor olabilir');
    } else {
      print('\n✅ Süzme yoğurt geçmişte YOK');
    }
  }
  
  // TEST 4: Makro Uyumu Analizi
  print('\n\n🎯 TEST 4: MAKRO UYUMU ANALİZİ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('(160 kcal ara öğün için tipik hedefler)');
  
  const hedefKalori = 160.0;
  const hedefProtein = 15.0;
  const hedefKarb = 15.0;
  const hedefYag = 5.0;
  
  // Her yemek için fitness skoru hesapla
  final skorlar = <Map<String, dynamic>>[];
  
  for (final y in araOgun2List) {
    final kaloriSapma = ((y.kalori - hedefKalori).abs() / hedefKalori) * 100;
    final proteinSapma = ((y.protein - hedefProtein).abs() / hedefProtein) * 100;
    final karbSapma = ((y.karbonhidrat - hedefKarb).abs() / hedefKarb) * 100;
    final yagSapma = ((y.yag - hedefYag).abs() / hedefYag) * 100;
    
    final ortalamaSapma = (kaloriSapma + proteinSapma + karbSapma + yagSapma) / 4;
    final fitness = 100 - ortalamaSapma.clamp(0, 100);
    
    skorlar.add({
      'ad': y.ad,
      'fitness': fitness,
      'isSuzme': y.ad.toLowerCase().contains('süzme') || 
                  y.ad.toLowerCase().contains('suzme'),
    });
  }
  
  // En iyi 15 yemeği göster
  skorlar.sort((a, b) => (b['fitness'] as double).compareTo(a['fitness'] as double));
  
  print('\n🏆 EN İYİ 15 YEMEK (Makro Uygunluğu):');
  for (int i = 0; i < 15 && i < skorlar.length; i++) {
    final emoji = skorlar[i]['isSuzme'] == true ? '🧀' : '  ';
    print('   ${i + 1}. $emoji ${skorlar[i]['ad']} → ${(skorlar[i]['fitness'] as double).toStringAsFixed(1)}');
  }
  
  // Süzme yoğurt top 15'te kaç tane?
  final top15Suzme = skorlar
      .take(15)
      .where((s) => s['isSuzme'] == true)
      .length;
  
  if (top15Suzme > 0) {
    print('\n⚠️  KRİTİK BULGU: Süzme yoğurt en iyi $top15Suzme yemek arasında!');
    print('   → Makrolar için mükemmel uyum');
    print('   → Genetik algoritma sürekli onu seçiyor');
    print('   → ÇÖZÜM GEREKLİ!');
  }
  
  // TEST 5: Çeşitlilik Dağılımı
  print('\n\n📊 TEST 5: ÇEŞİTLİLİK DAĞILIMI');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  // İlk kelimeye göre grupla (örn: "Whey", "Süzme", "Badem", vb.)
  final gruplar = <String, int>{};
  for (final y in araOgun2List) {
    final ilkKelime = y.ad.split(' ').first.toLowerCase();
    gruplar[ilkKelime] = (gruplar[ilkKelime] ?? 0) + 1;
  }
  
  // En çok tekrar edenleri göster
  final sortedGruplar = gruplar.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  print('📋 En Sık Tekrar Eden Yemek Türleri (Top 10):');
  for (int i = 0; i < 10 && i < sortedGruplar.length; i++) {
    final oran = (sortedGruplar[i].value / araOgun2List.length * 100).toStringAsFixed(1);
    print('   ${i + 1}. "${sortedGruplar[i].key}": ${sortedGruplar[i].value} adet ($oran%)');
  }
  
  // ÖNERİLER
  print('\n\n💡 ÖNERİLER VE ÇÖZÜM STRATEJİLERİ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  if (araOgun2List.length < 50) {
    print('❗ Strateji 1: DB yenileme yap (çok az yemek var)');
  }
  
  if (top15Suzme > 3) {
    print('❗ Strateji 2: Süzme yoğurt için özel kural ekle');
    print('   → Son 7 günde seçilmişse yasak et');
    print('   → Ya da tamamen yasakla');
  }
  
  if (gecmis.isEmpty) {
    print('❗ Strateji 3: DB yenileme + plan oluştur');
    print('   → Çeşitlilik geçmişi boş, yeni plan gerekli');
  }
  
  final suzmeOrani = (suzmeYogurtlar.length / araOgun2List.length * 100);
  if (suzmeOrani > 10) {
    print('❗ Strateji 4: DB\'de çok fazla süzme yoğurt var (${suzmeOrani.toStringAsFixed(1)}%)');
    print('   → JSON dosyasını kontrol et');
  }
}
