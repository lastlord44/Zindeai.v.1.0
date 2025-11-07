// ============================================================================
// test/v5_3_radical_fix_stres_testi.dart
// V5.3 RADİKAL FİX STRES TESTİ - DİYETİSYEN STANDARDİ DOĞRULAMA
// 🎯 HEDEF: %70+ TOLERANS BAŞARISI + MAKRO KRİZİ ÇÖZÜMÜ
// ============================================================================

import 'dart:math';
import '../lib/domain/services/ai_beslenme_servisi_v5_3_radical_fix.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/core/utils/app_logger.dart';

// ============================================================================
// V5.3 ULTRA DETAYLI STRES TESTİ - 25 PROFİL
// ============================================================================

class V53RadicalFixStresTestiSonucu {
  final String profilAdi;
  final int profilNo;
  final double hedefKalori;
  final GunlukPlan? plan;
  final bool basarili;
  final double toleransSkoru;
  final String hataMesaji;
  final Map<String, double> makroSapmalari;
  final bool kaloriToleransIcinde;
  final bool proteinToleransIcinde;
  final bool karbToleransIcinde;
  final bool yagToleransIcinde;
  final bool diyetisyenStandartSaglandi;

  V53RadicalFixStresTestiSonucu({
    required this.profilAdi,
    required this.profilNo,
    required this.hedefKalori,
    required this.plan,
    required this.basarili,
    required this.toleransSkoru,
    required this.hataMesaji,
    required this.makroSapmalari,
    required this.kaloriToleransIcinde,
    required this.proteinToleransIcinde,
    required this.karbToleransIcinde,
    required this.yagToleransIcinde,
    required this.diyetisyenStandartSaglandi,
  });
}

class V53RadicalFixStresTesti {
  final AIBeslenmeServisiV53RadikalFix _aiServis = AIBeslenmeServisiV53RadikalFix();
  final List<V53RadicalFixStresTestiSonucu> _sonuclar = [];

  // ============================================================================
  // 🎯 25 PROFİL ULTRA KAPSAMLI TEST
  // ============================================================================
  
  Future<void> fullStresTestiCalistir() async {
    try {
      AppLogger.info('🚀 V5.3 RADİKAL FİX ULTRA STRES TESTİ BAŞLIYOR!');
      AppLogger.info('📊 25 farklı profil test edilecek...');
      AppLogger.info('🎯 DİYETİSYEN STANDARDI: ±15% makro tolerans');
      print('=' * 50);

      // Hive zaten initialize edilmiş durumda

      final testProfilleri = _testProfilleriniOlustur();
      
      int profilSayaci = 1;
      for (final profil in testProfilleri) {
        AppLogger.info('🧪 TEST ${profilSayaci}/25: ${profil['ad']}');
        AppLogger.info('   📊 ${profil['kalori']} kcal | ${profil['hedef']}');
        
        final sonuc = await _tekProfilTest(profil, profilSayaci);
        _sonuclar.add(sonuc);
        
        _tekProfilSonucLogla(sonuc);
        profilSayaci++;
        print('=' * 50);
      }

      // 🎉 FİNAL ANALİZ
      _finalAnalizRaporla();

    } catch (e, stackTrace) {
      AppLogger.error('❌ V5.3 Stres Testi Kritik Hata', error: e, stackTrace: stackTrace);
    }
  }

  // ============================================================================
  // 📊 TEST PROFİLLERİ OLUŞTURMA - 25 ÇEŞIT
  // ============================================================================
  
  List<Map<String, dynamic>> _testProfilleriniOlustur() {
    return [
      // 🏋️ BULK PROFİLLERİ (5 çeşit)
      {'ad': 'MEGA BULK - Ultra Yüksek', 'kalori': 3800.0, 'protein': 200.0, 'karb': 500.0, 'yag': 130.0, 'hedef': Hedef.kasKazanKiloAl},
      {'ad': 'BULK - Yüksek Kalori', 'kalori': 3200.0, 'protein': 180.0, 'karb': 400.0, 'yag': 110.0, 'hedef': Hedef.kasKazanKiloAl},
      {'ad': 'BULK - Orta Yüksek', 'kalori': 2800.0, 'protein': 150.0, 'karb': 350.0, 'yag': 95.0, 'hedef': Hedef.kiloAlmak},
      {'ad': 'BULK - Temiz Bulk', 'kalori': 2600.0, 'protein': 140.0, 'karb': 320.0, 'yag': 85.0, 'hedef': Hedef.kiloAlmak},
      {'ad': 'BULK - Lean Gains', 'kalori': 2400.0, 'protein': 130.0, 'karb': 280.0, 'yag': 80.0, 'hedef': Hedef.kasKazanKiloAl},

      // 🔥 CUT PROFİLLERİ (5 çeşit) 
      {'ad': 'CUT - Agresif', 'kalori': 1600.0, 'protein': 140.0, 'karb': 120.0, 'yag': 60.0, 'hedef': Hedef.kasKazanKiloVer},
      {'ad': 'CUT - Orta Agresif', 'kalori': 1800.0, 'protein': 130.0, 'karb': 150.0, 'yag': 70.0, 'hedef': Hedef.kiloVermek},
      {'ad': 'CUT - Moderate', 'kalori': 2000.0, 'protein': 120.0, 'karb': 180.0, 'yag': 80.0, 'hedef': Hedef.kiloVermek},
      {'ad': 'CUT - Soft Cut', 'kalori': 2200.0, 'protein': 110.0, 'karb': 220.0, 'yag': 85.0, 'hedef': Hedef.kasKazanKiloVer},
      {'ad': 'CUT - Mini Cut', 'kalori': 2100.0, 'protein': 125.0, 'karb': 200.0, 'yag': 75.0, 'hedef': Hedef.kiloVermek},

      // 💪 MAİNTENANCE PROFİLLERİ (5 çeşit)
      {'ad': 'MAINTAIN - Athletic', 'kalori': 2800.0, 'protein': 140.0, 'karb': 350.0, 'yag': 95.0, 'hedef': Hedef.formdaKal},
      {'ad': 'MAINTAIN - Active', 'kalori': 2500.0, 'protein': 125.0, 'karb': 300.0, 'yag': 85.0, 'hedef': Hedef.formdaKal},
      {'ad': 'MAINTAIN - Moderate', 'kalori': 2200.0, 'protein': 110.0, 'karb': 250.0, 'yag': 80.0, 'hedef': Hedef.formdaKal},
      {'ad': 'MAINTAIN - Light', 'kalori': 2000.0, 'protein': 100.0, 'karb': 220.0, 'yag': 75.0, 'hedef': Hedef.formdaKal},
      {'ad': 'MAINTAIN - Sedentary', 'kalori': 1900.0, 'protein': 95.0, 'karb': 210.0, 'yag': 70.0, 'hedef': Hedef.formdaKal},

      // 🎯 ÖZEL PROFİLLER (5 çeşit)
      {'ad': 'POWERLIFTER - Max', 'kalori': 4200.0, 'protein': 220.0, 'karb': 550.0, 'yag': 140.0, 'hedef': Hedef.kasKazanKiloAl},
      {'ad': 'ENDURANCE - Cyclist', 'kalori': 3500.0, 'protein': 150.0, 'karb': 500.0, 'yag': 110.0, 'hedef': Hedef.formdaKal},
      {'ad': 'BODYBUILDER - Prep', 'kalori': 1400.0, 'protein': 160.0, 'karb': 80.0, 'yag': 50.0, 'hedef': Hedef.kasKazanKiloVer},
      {'ad': 'CROSSFIT - High Vol', 'kalori': 3000.0, 'protein': 160.0, 'karb': 380.0, 'yag': 100.0, 'hedef': Hedef.kasKazanKiloAl},
      {'ad': 'MODEL - Contest Prep', 'kalori': 1300.0, 'protein': 130.0, 'karb': 70.0, 'yag': 45.0, 'hedef': Hedef.kiloVermek},

      // 🔥 EKSTREM PROFİLLER (5 çeşit)
      {'ad': 'SUMO - Maximum Mass', 'kalori': 5000.0, 'protein': 250.0, 'karb': 650.0, 'yag': 170.0, 'hedef': Hedef.kiloAlmak},
      {'ad': 'MARATHON - Ultra Distance', 'kalori': 4000.0, 'protein': 160.0, 'karb': 600.0, 'yag': 130.0, 'hedef': Hedef.formdaKal},
      {'ad': 'PHYSIQUE - Peak Week', 'kalori': 1200.0, 'protein': 140.0, 'karb': 50.0, 'yag': 40.0, 'hedef': Hedef.kasKazanKiloVer},
      {'ad': 'STRONGMAN - Offseason', 'kalori': 4500.0, 'protein': 230.0, 'karb': 580.0, 'yag': 150.0, 'hedef': Hedef.kasKazanKiloAl},
      {'ad': 'FITNESS - Bikini Comp', 'kalori': 1500.0, 'protein': 120.0, 'karb': 100.0, 'yag': 55.0, 'hedef': Hedef.kiloVermek},
    ];
  }

  // ============================================================================
  // 🧪 TEK PROFİL TEST METODU
  // ============================================================================
  
  Future<V53RadicalFixStresTestiSonucu> _tekProfilTest(Map<String, dynamic> profil, int profilNo) async {
    try {
      final tarih = DateTime.now().add(Duration(days: profilNo));
      
      final plan = await _aiServis.gunlukPlanOlustur(
        hedefKalori: profil['kalori'].toDouble(),
        hedefProtein: profil['protein'].toDouble(),
        hedefKarb: profil['karb'].toDouble(),
        hedefYag: profil['yag'].toDouble(),
        hedef: profil['hedef'],
        tarih: tarih,
      );

      // 📊 MAKRO SAPMA ANALİZİ
      final makroSapmalari = _makroSapmalariniHesapla(plan, profil);
      final toleransSkoru = _toleransSkoru(plan, profil);
      
      // 🎯 DİYETİSYEN STANDARDI KONTROLÜ
      final kaloriTolerans = makroSapmalari['kalori']! <= 15.0;
      final proteinTolerans = makroSapmalari['protein']! <= 15.0;
      final karbTolerans = makroSapmalari['karb']! <= 15.0;
      final yagTolerans = makroSapmalari['yag']! <= 15.0;
      final diyetisyenStandart = toleransSkoru >= 70.0;

      return V53RadicalFixStresTestiSonucu(
        profilAdi: profil['ad'],
        profilNo: profilNo,
        hedefKalori: profil['kalori'].toDouble(),
        plan: plan,
        basarili: true,
        toleransSkoru: toleransSkoru,
        hataMesaji: '',
        makroSapmalari: makroSapmalari,
        kaloriToleransIcinde: kaloriTolerans,
        proteinToleransIcinde: proteinTolerans,
        karbToleransIcinde: karbTolerans,
        yagToleransIcinde: yagTolerans,
        diyetisyenStandartSaglandi: diyetisyenStandart,
      );

    } catch (e) {
      return V53RadicalFixStresTestiSonucu(
        profilAdi: profil['ad'],
        profilNo: profilNo,
        hedefKalori: profil['kalori'].toDouble(),
        plan: null,
        basarili: false,
        toleransSkoru: 0.0,
        hataMesaji: e.toString(),
        makroSapmalari: {'kalori': 100.0, 'protein': 100.0, 'karb': 100.0, 'yag': 100.0},
        kaloriToleransIcinde: false,
        proteinToleransIcinde: false,
        karbToleransIcinde: false,
        yagToleransIcinde: false,
        diyetisyenStandartSaglandi: false,
      );
    }
  }

  // ============================================================================
  // 📊 MAKRO SAPMA HESAPLAMA
  // ============================================================================
  
  Map<String, double> _makroSapmalariniHesapla(GunlukPlan plan, Map<String, dynamic> profil) {
    final kaloriSapma = ((plan.toplamKalori - profil['kalori']) / profil['kalori']).abs() * 100;
    final proteinSapma = ((plan.toplamProtein - profil['protein']) / profil['protein']).abs() * 100;
    final karbSapma = ((plan.toplamKarbonhidrat - profil['karb']) / profil['karb']).abs() * 100;
    final yagSapma = ((plan.toplamYag - profil['yag']) / profil['yag']).abs() * 100;

    return {
      'kalori': kaloriSapma,
      'protein': proteinSapma,
      'karb': karbSapma,
      'yag': yagSapma,
    };
  }

  // ============================================================================
  // 🎯 TOLERANS SKORU HESAPLAMA
  // ============================================================================
  
  double _toleransSkoru(GunlukPlan plan, Map<String, dynamic> profil) {
    final makroSapmalari = _makroSapmalariniHesapla(plan, profil);
    
    double skor = 0.0;
    if (makroSapmalari['kalori']! <= 15.0) skor += 30; // %30
    if (makroSapmalari['protein']! <= 15.0) skor += 25; // %25
    if (makroSapmalari['karb']! <= 15.0) skor += 25; // %25
    if (makroSapmalari['yag']! <= 15.0) skor += 20; // %20
    
    return skor;
  }

  // ============================================================================
  // 📝 TEK PROFİL SONUÇ LOGLAMA
  // ============================================================================
  
  void _tekProfilSonucLogla(V53RadicalFixStresTestiSonucu sonuc) {
    if (!sonuc.basarili) {
      AppLogger.error('❌ ${sonuc.profilAdi} BAŞARISIZ: ${sonuc.hataMesaji}');
      return;
    }

    final plan = sonuc.plan!;
    
    if (sonuc.diyetisyenStandartSaglandi) {
      AppLogger.success('🎉 ${sonuc.profilAdi} - DİYETİSYEN STANDARDI SAĞLANDI!');
    } else if (sonuc.toleransSkoru >= 50) {
      AppLogger.info('⚠️ ${sonuc.profilAdi} - ORTA SEVIYE (${sonuc.toleransSkoru.toStringAsFixed(1)}/100)');
    } else {
      AppLogger.warning('🚨 ${sonuc.profilAdi} - DÜŞÜK TOLERANS (${sonuc.toleransSkoru.toStringAsFixed(1)}/100)');
    }

    // 📊 MAKRO DETAYLAR
    AppLogger.info('📊 MAKRO ANALİZ:');
    AppLogger.info('   🔥 Kalori: ${plan.toplamKalori.toInt()}/${sonuc.hedefKalori.toInt()} (${sonuc.makroSapmalari['kalori']!.toStringAsFixed(1)}% sapma)');
    AppLogger.info('   🥩 Protein: ${plan.toplamProtein.toInt()}g (${sonuc.makroSapmalari['protein']!.toStringAsFixed(1)}% sapma)');
    AppLogger.info('   🍞 Karb: ${plan.toplamKarbonhidrat.toInt()}g (${sonuc.makroSapmalari['karb']!.toStringAsFixed(1)}% sapma)');
    AppLogger.info('   🧈 Yağ: ${plan.toplamYag.toInt()}g (${sonuc.makroSapmalari['yag']!.toStringAsFixed(1)}% sapma)');

    // 🎯 TOLERANS DURUMU
    final toleranslar = [
      sonuc.kaloriToleransIcinde ? '✅' : '❌',
      sonuc.proteinToleransIcinde ? '✅' : '❌',
      sonuc.karbToleransIcinde ? '✅' : '❌',
      sonuc.yagToleransIcinde ? '✅' : '❌',
    ];
    AppLogger.info('🎯 TOLERANS: K:${toleranslar[0]} P:${toleranslar[1]} C:${toleranslar[2]} Y:${toleranslar[3]}');

    // 🍽️ ÖĞÜN DETAYLARI
    AppLogger.info('🍽️ ÖĞÜNLER:');
    if (plan.kahvalti != null) AppLogger.info('   🥞 Kahvaltı: ${plan.kahvalti!.ad} (${plan.kahvalti!.kalori.toInt()} kcal)');
    if (plan.araOgun1 != null) AppLogger.info('   🍎 Ara Öğün 1: ${plan.araOgun1!.ad} (${plan.araOgun1!.kalori.toInt()} kcal)');
    if (plan.ogleYemegi != null) AppLogger.info('   🍽️ Öğle: ${plan.ogleYemegi!.ad} (${plan.ogleYemegi!.kalori.toInt()} kcal)');
    if (plan.araOgun2 != null) AppLogger.info('   🥜 Ara Öğün 2: ${plan.araOgun2!.ad} (${plan.araOgun2!.kalori.toInt()} kcal)');
    if (plan.aksamYemegi != null) AppLogger.info('   🌙 Akşam: ${plan.aksamYemegi!.ad} (${plan.aksamYemegi!.kalori.toInt()} kcal)');
    if (plan.geceAtistirma != null) AppLogger.info('   🌃 Gece: ${plan.geceAtistirma!.ad} (${plan.geceAtistirma!.kalori.toInt()} kcal)');
  }

  // ============================================================================
  // 📈 FİNAL ANALİZ RAPORU
  // ============================================================================
  
  void _finalAnalizRaporla() {
    AppLogger.success('🎉 V5.3 RADİKAL FİX ULTRA STRES TESTİ TAMAMLANDI!');
    print('=' * 60);

    final toplamTest = _sonuclar.length;
    final basariliTestler = _sonuclar.where((s) => s.basarili).length;
    final diyetisyenStandartSaglanan = _sonuclar.where((s) => s.diyetisyenStandartSaglandi).length;
    
    final kaloriToleransBasarili = _sonuclar.where((s) => s.kaloriToleransIcinde).length;
    final proteinToleransBasarili = _sonuclar.where((s) => s.proteinToleransIcinde).length;
    final karbToleransBasarili = _sonuclar.where((s) => s.karbToleransIcinde).length;
    final yagToleransBasarili = _sonuclar.where((s) => s.yagToleransIcinde).length;

    final ortalamaToleransSkoru = _sonuclar.map((s) => s.toleransSkoru).reduce((a, b) => a + b) / toplamTest;

    AppLogger.success('📊 GENEL SONUÇLAR:');
    AppLogger.info('🧪 Toplam Test: $toplamTest profil');
    AppLogger.info('✅ Başarılı Test: $basariliTestler/${toplamTest} (%${(basariliTestler/toplamTest*100).toStringAsFixed(1)})');
    AppLogger.info('🎯 Diyetisyen Standartı: $diyetisyenStandartSaglanan/${toplamTest} (%${(diyetisyenStandartSaglanan/toplamTest*100).toStringAsFixed(1)})');
    AppLogger.info('📊 Ortalama Tolerans Skoru: ${ortalamaToleransSkoru.toStringAsFixed(1)}/100');
    
    print('=' * 40);
    AppLogger.success('🎯 MAKRO TOLERANS DETAYLARI:');
    AppLogger.info('🔥 Kalori Toleransı: $kaloriToleransBasarili/${toplamTest} (%${(kaloriToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    AppLogger.info('🥩 Protein Toleransı: $proteinToleransBasarili/${toplamTest} (%${(proteinToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    AppLogger.info('🍞 Karb Toleransı: $karbToleransBasarili/${toplamTest} (%${(karbToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    AppLogger.info('🧈 Yağ Toleransı: $yagToleransBasarili/${toplamTest} (%${(yagToleransBasarili/toplamTest*100).toStringAsFixed(1)})');

    print('=' * 40);
    
    // 🏆 BAŞARI DEĞERLENDİRMESİ
    final diyetisyenBasariOrani = (diyetisyenStandartSaglanan / toplamTest) * 100;
    
    if (diyetisyenBasariOrani >= 70) {
      AppLogger.success('🏆 V5.3 RADİKAL FİX BAŞARILI! DİYETİSYEN STANDARDI SAĞLANDI!');
      AppLogger.success('🎉 Sistem profesyonel kullanıma hazır!');
    } else if (diyetisyenBasariOrani >= 50) {
      AppLogger.info('⚠️ V5.3 RADİKAL FİX ORTA BAŞARI - İyileştirme gerekli');
      AppLogger.info('🔧 Öneril: V5.4 için ince ayar optimizasyonu');
    } else {
      AppLogger.warning('🚨 V5.3 RADİKAL FİX YETERSİZ - Daha radikal değişiklik gerekli');
      AppLogger.warning('🔥 Önerí: Algorithm temeldrn yeniden tasarlanmalı');
    }

    // 📊 PROBLEM ANALİZ LİSTESİ
    print('=' * 40);
    AppLogger.info('🔍 PROBLEM ANALİZİ:');
    final basarisizlar = _sonuclar.where((s) => !s.diyetisyenStandartSaglandi).toList();
    if (basarisizlar.isNotEmpty) {
      AppLogger.warning('❌ DİYETİSYEN STANDARDI SAĞLAMAYAN PROFİLLER:');
      for (final basarisiz in basarisizlar.take(10)) {
        AppLogger.warning('   • ${basarisiz.profilAdi} (${basarisiz.toleransSkoru.toStringAsFixed(1)}/100)');
      }
    }

    // 🎯 V5.4 ÖNERİLERİ
    _v54OneriUret(diyetisyenBasariOrani, kaloriToleransBasarili, proteinToleransBasarili, karbToleransBasarili, yagToleransBasarili, toplamTest);
  }

  // ============================================================================
  // 🚀 V5.4 ÖNERİ ÜRETİCİ
  // ============================================================================
  
  void _v54OneriUret(double diyetisyenBasariOrani, int kaloriOK, int proteinOK, int karbOK, int yagOK, int toplam) {
    print('=' * 40);
    AppLogger.info('🚀 V5.4 GELİŞTİRME ÖNERİLERİ:');
    
    if (diyetisyenBasariOrani < 50) {
      AppLogger.warning('🔥 ACİL ÖNCELİKLER:');
      AppLogger.warning('   • V5.4 Mega Overhaul - Algorithm köklü değişikliği');
      AppLogger.warning('   • Makro dağılım formülü yeniden tasarımı');
      AppLogger.warning('   • Fallback sistem kapasité artırımı');
    }

    // En problemli makro tespit et
    final makroBasariOranlari = [
      ('Kalori', kaloriOK / toplam * 100),
      ('Protein', proteinOK / toplam * 100),
      ('Karb', karbOK / toplam * 100),
      ('Yag', yagOK / toplam * 100),
    ];
    makroBasariOranlari.sort((a, b) => a.$2.compareTo(b.$2));
    
    AppLogger.info('🎯 MAKRO PRİORİTE SIRALAMASI:');
    for (int i = 0; i < makroBasariOranlari.length; i++) {
      final makro = makroBasariOranlari[i];
      final priorite = i == 0 ? '🔥 ÇOK KRİTİK' : i == 1 ? '⚠️ KRİTİK' : i == 2 ? '📊 ORTA' : '✅ İYİ';
      AppLogger.info('   ${i+1}. ${makro.$1}: %${makro.$2.toStringAsFixed(1)} - $priorite');
    }

    if (diyetisyenBasariOrani >= 50) {
      AppLogger.success('💡 V5.4 İYİLEŞTİRME ÖNERİLERİ:');
      AppLogger.info('   • Akıllı ölçekleme algoritmasi ince ayarı');
      AppLogger.info('   • Yemek seçim skorlama optimizasyonu');
      AppLogger.info('   • Çoklu deneme sayısını 5→7 artırımı');
      AppLogger.info('   • Türk mutfağı veri kalitesi iyileştirmesi');
    }
  }
}

// ============================================================================
// 🧪 TEST ÇALIŞTIRICI
// ============================================================================

Future<void> main() async {
  print('🚀 V5.3 RADİKAL FİX ULTRA STRES TESTİ');
  print('📊 25 profil diyetisyen standardında test ediliyor...\n');
  
  final stresTesti = V53RadicalFixStresTesti();
  await stresTesti.fullStresTestiCalistir();
  
  print('\n🎉 Test tamamlandı!');
}