// OTOMATIK MOCK SİSTEM TESTİ
// AI bypass sonrası makro hesaplama doğruluğunu test et

import 'dart:io';
import 'lib/domain/services/ai_beslenme_servisi.dart';
import 'lib/domain/entities/makro_hedefleri.dart';

void main() async {
  print('🧪 MOCK SİSTEM OTOMATİK TEST');
  print('=' * 60);
  
  final servis = AIBeslenmeServisi();
  
  // TEST CASE 1: Bulk (2500 kcal, 160g protein)
  print('\n📊 TEST 1: BULK DİYET (2500 kcal, 160P, 300K, 80Y)');
  await _testPlan(
    servis: servis,
    hedefKalori: 2500,
    hedefProtein: 160,
    hedefKarb: 300,
    hedefYag: 80,
    testAdi: 'BULK',
  );
  
  // TEST CASE 2: Cut (1800 kcal, 140g protein)
  print('\n📊 TEST 2: CUT DİYET (1800 kcal, 140P, 180K, 50Y)');
  await _testPlan(
    servis: servis,
    hedefKalori: 1800,
    hedefProtein: 140,
    hedefKarb: 180,
    hedefYag: 50,
    testAdi: 'CUT',
  );
  
  // TEST CASE 3: Maintain (2200 kcal, 150g protein)
  print('\n📊 TEST 3: MAINTAIN DİYET (2200 kcal, 150P, 250K, 70Y)');
  await _testPlan(
    servis: servis,
    hedefKalori: 2200,
    hedefProtein: 150,
    hedefKarb: 250,
    hedefYag: 70,
    testAdi: 'MAINTAIN',
  );
  
  print('\n' + '=' * 60);
  print('✅ TÜM TESTLER TAMAMLANDI');
  exit(0);
}

Future<void> _testPlan({
  required AIBeslenmeServisi servis,
  required double hedefKalori,
  required double hedefProtein,
  required double hedefKarb,
  required double hedefYag,
  required String testAdi,
}) async {
  try {
    final plan = await servis.gunlukPlanOlustur(
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
      tarih: DateTime.now(),
    );
    
    // Makroları hesapla
    final toplamKalori = plan.toplamKalori;
    final toplamProtein = plan.toplamProtein;
    final toplamKarb = plan.toplamKarbonhidrat;
    final toplamYag = plan.toplamYag;
    
    // Sapmaları hesapla
    final kaloriSapma = ((toplamKalori - hedefKalori).abs() / hedefKalori * 100);
    final proteinSapma = ((toplamProtein - hedefProtein).abs() / hedefProtein * 100);
    final karbSapma = ((toplamKarb - hedefKarb).abs() / hedefKarb * 100);
    final yagSapma = ((toplamYag - hedefYag).abs() / hedefYag * 100);
    
    // Sonuçları göster
    print('   📋 PLAN DETAYI:');
    print('      Kahvaltı: ${plan.kahvalti?.ad ?? "N/A"}');
    print('      Ara Öğün 1: ${plan.araOgun1?.ad ?? "N/A"}');
    print('      Öğle: ${plan.ogleYemegi?.ad ?? "N/A"}');
    print('      Ara Öğün 2: ${plan.araOgun2?.ad ?? "N/A"}');
    print('      Akşam: ${plan.aksamYemegi?.ad ?? "N/A"}');
    
    print('\n   📊 MAKRO KARŞILAŞTIRMA:');
    print('      Kalori: ${toplamKalori.toStringAsFixed(0)} / ${hedefKalori.toStringAsFixed(0)} kcal (Sapma: %${kaloriSapma.toStringAsFixed(1)})');
    print('      Protein: ${toplamProtein.toStringAsFixed(0)} / ${hedefProtein.toStringAsFixed(0)}g (Sapma: %${proteinSapma.toStringAsFixed(1)})');
    print('      Karb: ${toplamKarb.toStringAsFixed(0)} / ${hedefKarb.toStringAsFixed(0)}g (Sapma: %${karbSapma.toStringAsFixed(1)})');
    print('      Yağ: ${toplamYag.toStringAsFixed(0)} / ${hedefYag.toStringAsFixed(0)}g (Sapma: %${yagSapma.toStringAsFixed(1)})');
    
    // Başarı kontrolü (%5 tolerans)
    final maxSapma = [kaloriSapma, proteinSapma, karbSapma, yagSapma].reduce((a, b) => a > b ? a : b);
    
    if (maxSapma <= 5.0) {
      print('\n   ✅ BAŞARILI: Tüm makrolar %5 tolerans içinde!');
    } else {
      print('\n   ⚠️ UYARI: Maksimum sapma %${maxSapma.toStringAsFixed(1)} (Hedef: ≤%5)');
    }
    
  } catch (e, stack) {
    print('\n   ❌ HATA: $testAdi testi başarısız!');
    print('   Hata: $e');
    print('   Stack: $stack');
  }
}