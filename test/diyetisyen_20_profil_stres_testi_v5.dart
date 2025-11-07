// ============================================================================
// test/diyetisyen_20_profil_stres_testi_v5.dart
// 🥗 DİYETİSYEN STANDARDİNDA 20 PROFİL STRES TESTİ - V5 SİSTEMİ
// 
// TEST KRİTERLERİ:
// ✅ Makro toleransı (±15%)
// ✅ Türk kahvaltısı uygunluğu  
// ✅ Ara öğün uygunluğu
// ✅ Günlük çeşitlilik
// ✅ Sistem kararlılığı
// ============================================================================

import 'dart:io';
import 'package:test/test.dart';
import 'package:hive/hive.dart';
import '../lib/domain/services/ai_beslenme_servisi_v5.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/core/utils/app_logger.dart';

void main() {
  group('🥗 DİYETİSYEN STANDARDİNDA 20 PROFİL STRES TESTİ', () {
    late AIBeslenmeServisiV5 aiServis;

    setUpAll(() async {
      // Test için geçici Hive dizini
      final testDir = Directory('./test_hive_data_20_profil');
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync();

      Hive.init(testDir.path);
      
      // Sadece temel adapterleri kaydet
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(YemekHiveModelAdapter());
      }

      await HiveService.init(isTest: true);
      aiServis = AIBeslenmeServisiV5();
      
      AppLogger.info('🚀 V5 TESTİ İNİTİALİZE EDİLDİ!');
    });

    tearDownAll(() async {
      await Hive.close();
      final testDir = Directory('./test_hive_data_20_profil');
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('🔥 20 PROFİL MEGA STRESTESİ - DİYETİSYEN KRİTERLERİ', () async {
      AppLogger.info('🔥 === 20 PROFİL DİYETİSYEN STANDARDİ STRES TESTİ BAŞLATILIYOR ===');
      
      final testProfilleri = _20FarkliProfilleriOlustur();
      
      // Sonuç takibi
      int basariliPlan = 0;
      int toleransDahilinde = 0;
      int turkKahvalti = 0;
      int uygunAraOgun = 0;
      int cesitlilik = 0;
      final detayliSonuclar = <String>[];
      
      for (int i = 0; i < testProfilleri.length; i++) {
        final profil = testProfilleri[i];
        AppLogger.info('\n🔸 === PROFİL ${i+1}: ${profil['ad']} ===');
        AppLogger.info('   📊 Hedef: ${profil['kalori'].toInt()} kcal');
        AppLogger.info('   🎯 Tip: ${profil['hedef']}');
        
        try {
          // Plan oluştur
          final plan = await aiServis.gunlukPlanOlustur(
            hedefKalori: profil['kalori']!,
            hedefProtein: profil['protein']!,
            hedefKarb: profil['karb']!,
            hedefYag: profil['yag']!,
            hedef: profil['hedef']! as Hedef,
            tarih: DateTime.now().add(Duration(days: i)),
          );
          
          if (plan.kahvalti != null && plan.ogleYemegi != null && plan.aksamYemegi != null) {
            basariliPlan++;
            
            // Makro analizi
            final analiz = _makroAnaliziYap(plan, profil);
            AppLogger.info('   📈 Makro Analiz:');
            AppLogger.info('     🔥 Toplam: ${analiz['toplamKalori']!.toInt()} kcal');
            AppLogger.info('     🥩 Protein: ${analiz['protein']!.toInt()}g (${analiz['proteinOrani']!.toStringAsFixed(1)}%)');
            AppLogger.info('     🍞 Karb: ${analiz['karbonhidrat']!.toInt()}g (${analiz['karbOrani']!.toStringAsFixed(1)}%)');
            AppLogger.info('     🧈 Yağ: ${analiz['yag']!.toInt()}g (${analiz['yagOrani']!.toStringAsFixed(1)}%)');
            
            // TOLERANS KONTROLÜ (±15%)
            bool makroTolerans = _makroToleransKontrolu(analiz, profil);
            if (makroTolerans) {
              toleransDahilinde++;
              AppLogger.success('     ✅ Makro tolerans: İÇİNDE');
            } else {
              AppLogger.warning('     ❌ Makro tolerans: DIŞINDA');
            }
            
            // TÜRK KAHVALTISI KONTROLÜ
            bool turkKahvaltiUygun = true;
            if (plan.kahvalti != null) {
              turkKahvaltiUygun = aiServis.testTurkKahvaltisinaUygunMu(plan.kahvalti!);
              if (turkKahvaltiUygun) {
                turkKahvalti++;
                AppLogger.success('     🇹🇷 Türk kahvaltısı: UYGUN');
              } else {
                AppLogger.warning('     ⚠️ Türk kahvaltısı: UYGUNSUZ - ${plan.kahvalti!.ad}');
              }
            }
            
            // ARA ÖĞÜN KONTROLÜ
            bool araOgunUygun = true;
            if (plan.araOgun1 != null) {
              araOgunUygun = _araOguneUygunMu(plan.araOgun1!);
              if (araOgunUygun) {
                uygunAraOgun++;
                AppLogger.success('     🍎 Ara öğün: UYGUN');
              } else {
                AppLogger.warning('     ⚠️ Ara öğün: UYGUNSUZ - ${plan.araOgun1!.ad}');
              }
            } else {
              uygunAraOgun++; // Ara öğün yoksa sorun yok
              AppLogger.info('     🍎 Ara öğün: YOK');
            }
            
            // ÇEŞİTLİLİK KONTROLÜ (En az 3 farklı yemek)
            final yemekAdlari = <String>{
              if (plan.kahvalti != null) plan.kahvalti!.ad,
              if (plan.ogleYemegi != null) plan.ogleYemegi!.ad,
              if (plan.aksamYemegi != null) plan.aksamYemegi!.ad,
              if (plan.araOgun1 != null) plan.araOgun1!.ad,
              if (plan.araOgun2 != null) plan.araOgun2!.ad,
            };
            
            if (yemekAdlari.length >= 3) {
              cesitlilik++;
              AppLogger.success('     🌈 Çeşitlilik: YETER (${yemekAdlari.length} farklı)');
            } else {
              AppLogger.warning('     ⚠️ Çeşitlilik: YETERSIZ (${yemekAdlari.length} farklı)');
            }
            
            // Detaylı sonucu kaydet
            detayliSonuclar.add('${profil['ad']}: Makro=${makroTolerans ? '✅' : '❌'}, Türk=${turkKahvaltiUygun ? '✅' : '❌'}, Ara=${araOgunUygun ? '✅' : '❌'}, Çeşit=${yemekAdlari.length >= 3 ? '✅' : '❌'}');
            
          } else {
            AppLogger.error('     ❌ Plan eksik: K=${plan.kahvalti?.ad}, O=${plan.ogleYemegi?.ad}, A=${plan.aksamYemegi?.ad}');
          }
          
        } catch (e) {
          AppLogger.error('     💥 HATA: $e');
          detayliSonuclar.add('${profil['ad']}: HATA - $e');
        }
        
        // Kısa bekleme
        await Future.delayed(Duration(milliseconds: 50));
      }
      
      // === FINAL SONUÇLAR ===
      AppLogger.info('\n🎯 === FİNAL SONUÇLARI ===');
      AppLogger.info('🎯 Başarılı Plan: $basariliPlan/20 (${(basariliPlan/20*100).toInt()}%)');
      AppLogger.info('⚖️ Tolerans İçinde: $toleransDahilinde/20 (${(toleransDahilinde/20*100).toInt()}%)');
      AppLogger.info('🇹🇷 Türk Kahvaltısı: $turkKahvalti/20 (${(turkKahvalti/20*100).toInt()}%)');
      AppLogger.info('🍎 Uygun Ara Öğün: $uygunAraOgun/20 (${(uygunAraOgun/20*100).toInt()}%)');
      AppLogger.info('🌈 Yeterli Çeşitlilik: $cesitlilik/20 (${(cesitlilik/20*100).toInt()}%)');
      
      // DİYETİSYEN DEĞERLENDİRMESİ
      final genelPuan = (basariliPlan/20 + toleransDahilinde/20 + turkKahvalti/20 + uygunAraOgun/20 + cesitlilik/20) / 5 * 100;
      
      AppLogger.info('\n🥗 === DİYETİSYEN DEĞERLENDİRMESİ ===');
      if (genelPuan >= 90) {
        AppLogger.success('🏆 MÜKEMMEL! Profesyonel diyetisyen standardında sistem.');
      } else if (genelPuan >= 80) {
        AppLogger.success('✅ ÇOK İYİ! Küçük iyileştirmelerle mükemmel olabilir.');  
      } else if (genelPuan >= 70) {
        AppLogger.warning('⚠️ İYİ! Bazı kritik sorunlar var, düzeltme gerekli.');
      } else if (genelPuan >= 60) {
        AppLogger.error('❌ ORTA! Ciddi sorunlar var, büyük düzeltme gerekli.');
      } else {
        AppLogger.error('🚨 KÖTÜ! Sistem kullanıma hazır değil, major overhaul gerekli.');
      }
      AppLogger.info('📊 Genel Puan: ${genelPuan.toStringAsFixed(1)}/100');
      
      // Detaylı sonuçları logla
      AppLogger.info('\n📋 === DETAYLI SONUÇLAR ===');
      for (final sonuc in detayliSonuclar) {
        AppLogger.info('   $sonuc');
      }
      
      // ASSERT'LER - DİYETİSYEN KABUL KRİTERLERİ
      expect(basariliPlan, greaterThanOrEqualTo(18), 
        reason: '90% başarı oranı gerekli (Gerçek: ${basariliPlan}/20)');
      expect(toleransDahilinde, greaterThanOrEqualTo(14),
        reason: '70% makro tolerans gerekli (Gerçek: ${toleransDahilinde}/20)'); 
      expect(turkKahvalti, greaterThanOrEqualTo(16),
        reason: '80% Türk kahvaltısı uygunluğu gerekli (Gerçek: ${turkKahvalti}/20)');
      expect(uygunAraOgun, greaterThanOrEqualTo(16),
        reason: '80% ara öğün uygunluğu gerekli (Gerçek: ${uygunAraOgun}/20)');
      
      AppLogger.success('\n✅ 20 PROFİL DİYETİSYEN STANDARDİ STRES TESTİ TAMAMLANDI!');
    });
  });
}

/// 20 farklı profil oluştur (diyetisyen çeşitliliği)
List<Map<String, dynamic>> _20FarkliProfilleriOlustur() {
  return [
    // BULK PROFİLLERİ
    {'ad': 'Genç Bulk Erkek', 'kalori': 2800.0, 'protein': 140.0, 'karb': 350.0, 'yag': 93.0, 'hedef': Hedef.kiloAlmak},
    {'ad': 'Güçlü Bulk Erkek', 'kalori': 3200.0, 'protein': 160.0, 'karb': 400.0, 'yag': 107.0, 'hedef': Hedef.kasKazanKiloAl},
    {'ad': 'Kadın Bulk', 'kalori': 2400.0, 'protein': 120.0, 'karb': 300.0, 'yag': 80.0, 'hedef': Hedef.kasKazanKiloAl},
    {'ad': 'Mega Bulk', 'kalori': 3600.0, 'protein': 180.0, 'karb': 450.0, 'yag': 120.0, 'hedef': Hedef.kiloAlmak},
    
    // CUT PROFİLLERİ  
    {'ad': 'Erkek Cut', 'kalori': 2200.0, 'protein': 140.0, 'karb': 220.0, 'yag': 73.0, 'hedef': Hedef.kiloVermek},
    {'ad': 'Kadın Cut', 'kalori': 1800.0, 'protein': 110.0, 'karb': 180.0, 'yag': 60.0, 'hedef': Hedef.kasKazanKiloVer},
    {'ad': 'Hızlı Cut', 'kalori': 1900.0, 'protein': 120.0, 'karb': 190.0, 'yag': 63.0, 'hedef': Hedef.kiloVermek},
    {'ad': 'Mini Cut', 'kalori': 1600.0, 'protein': 100.0, 'karb': 160.0, 'yag': 53.0, 'hedef': Hedef.kiloVermek},
    
    // KORUMA PROFİLLERİ
    {'ad': 'Kas Koruma Erkek', 'kalori': 2500.0, 'protein': 125.0, 'karb': 250.0, 'yag': 83.0, 'hedef': Hedef.formdaKal},
    {'ad': 'Maintenance Kadın', 'kalori': 2100.0, 'protein': 105.0, 'karb': 210.0, 'yag': 70.0, 'hedef': Hedef.formdaKal},
    {'ad': 'Yaşlı Maintenance', 'kalori': 2000.0, 'protein': 100.0, 'karb': 200.0, 'yag': 67.0, 'hedef': Hedef.formdaKal},
    
    // ÖZEL DURUMLAR
    {'ad': 'Genç Sporcu', 'kalori': 3000.0, 'protein': 150.0, 'karb': 375.0, 'yag': 100.0, 'hedef': Hedef.kasKazanKiloAl},
    {'ad': 'Endomorph Cut', 'kalori': 2100.0, 'protein': 130.0, 'karb': 210.0, 'yag': 70.0, 'hedef': Hedef.kiloVermek},
    {'ad': 'Ektomorph Bulk', 'kalori': 2900.0, 'protein': 145.0, 'karb': 362.0, 'yag': 97.0, 'hedef': Hedef.kiloAlmak},
    
    // KADIN PROFİLLERİ
    {'ad': 'Bikini Prep', 'kalori': 1500.0, 'protein': 90.0, 'karb': 150.0, 'yag': 50.0, 'hedef': Hedef.kiloVermek},
    {'ad': 'Fit Kadın Bulk', 'kalori': 2300.0, 'protein': 115.0, 'karb': 287.0, 'yag': 77.0, 'hedef': Hedef.kasKazanKiloAl},
    {'ad': 'Orta Yaş Kadın', 'kalori': 1700.0, 'protein': 85.0, 'karb': 170.0, 'yag': 57.0, 'hedef': Hedef.kiloVermek},
    {'ad': 'Güçlü Kadın', 'kalori': 2200.0, 'protein': 110.0, 'karb': 220.0, 'yag': 73.0, 'hedef': Hedef.formdaKal},
    
    // KARIŞIK PROFİLLER
    {'ad': 'Dengeli Erkek', 'kalori': 2400.0, 'protein': 120.0, 'karb': 240.0, 'yag': 80.0, 'hedef': Hedef.formdaKal},
    {'ad': 'Genç Kadın Sporcu', 'kalori': 2100.0, 'protein': 105.0, 'karb': 262.0, 'yag': 70.0, 'hedef': Hedef.kasKazanKiloAl},
  ];
}

/// Makro analizi yap
Map<String, double> _makroAnaliziYap(dynamic plan, Map<String, dynamic> profil) {
  double toplamKalori = 0;
  double protein = 0;
  double karbonhidrat = 0;
  double yag = 0;
  
  final yemekler = <dynamic>[
    if (plan.kahvalti != null) plan.kahvalti,
    if (plan.ogleYemegi != null) plan.ogleYemegi,
    if (plan.aksamYemegi != null) plan.aksamYemegi,
    if (plan.araOgun1 != null) plan.araOgun1,
    if (plan.araOgun2 != null) plan.araOgun2,
    if (plan.geceAtistirma != null) plan.geceAtistirma,
  ];
  
  for (final yemek in yemekler) {
    toplamKalori += yemek.kalori;
    protein += yemek.protein;
    karbonhidrat += yemek.karbonhidrat;
    yag += yemek.yag;
  }
  
  final proteinOrani = (protein * 4 / toplamKalori) * 100;
  final karbOrani = (karbonhidrat * 4 / toplamKalori) * 100;
  final yagOrani = (yag * 9 / toplamKalori) * 100;
  
  return {
    'toplamKalori': toplamKalori,
    'protein': protein,
    'karbonhidrat': karbonhidrat,
    'yag': yag,
    'proteinOrani': proteinOrani,
    'karbOrani': karbOrani,
    'yagOrani': yagOrani,
  };
}

/// Makro tolerans kontrolü (±15%)
bool _makroToleransKontrolu(Map<String, double> analiz, Map<String, dynamic> profil) {
  final kaloriTolerans = _toleransKontrolu(analiz['toplamKalori']!, profil['kalori']! as double, 15);
  final proteinTolerans = _toleransKontrolu(analiz['protein']!, profil['protein']! as double, 15);
  final karbTolerans = _toleransKontrolu(analiz['karbonhidrat']!, profil['karb']! as double, 15);
  final yagTolerans = _toleransKontrolu(analiz['yag']!, profil['yag']! as double, 15);
  
  return kaloriTolerans && proteinTolerans && karbTolerans && yagTolerans;
}

/// Tolerans kontrolü helper
bool _toleransKontrolu(double gercek, double hedef, double toleransYuzdesi) {
  final altSinir = hedef * (100 - toleransYuzdesi) / 100;
  final ustSinir = hedef * (100 + toleransYuzdesi) / 100;
  return gercek >= altSinir && gercek <= ustSinir;
}

/// Ara öğüne uygun mu kontrolü
bool _araOguneUygunMu(dynamic yemek) {
  final ad = yemek.ad.toLowerCase();
  final kalori = yemek.kalori;
  
  // Ara öğün çok ağır olmamalı (400 kcal'den fazla olmamalı)
  if (kalori > 400) return false;
  
  // Ana yemek tarzı şeyler ara öğünde olmaz
  final uygunDegil = [
    'pilav', 'makarna', 'döner', 'kebab', 'köfte', 'çorba',
    'pizza', 'lahmacun', 'tantuni', 'hamburger', 'kıyma',
    'biftek', 'tavuk göğsü', 'dana eti'
  ];
  
  for (final uygunDegil_ in uygunDegil) {
    if (ad.contains(uygunDegil_)) return false;
  }
  
  return true;
}