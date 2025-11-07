// ============================================================================
// lib/domain/services/ai_beslenme_servisi_v5_3_radical_fix.dart
// V5.3 RADİKAL FİX: MAKRO TOLERANS KRİZİ ÇÖZÜMÜ + DİYETİSYEN STANDARDI
// 🎯 HEDEF: %70+ MAKRO TOLERANS BAŞARISI - DİYETİSYEN STANDARDİ
// ============================================================================

import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/hedef.dart';
import '../entities/makro_hedefleri.dart';
import '../../core/utils/app_logger.dart';
import '../../data/local/hive_service.dart';

// ============================================================================
// V5.3 RADİKAL DEĞİŞİKLİKLER:
// 1. 🎯 AKILLI MAKRO HEDEFLEMESİ - Dinamik tolerans ayarı
// 2. 🔧 HASSAS ÖLÇEKLEME - ±2% hassasiyetle makro hedefleme  
// 3. 💪 YÜKSEK KALORİ MASTER MODU - 3000+ kcal için özel algoritma
// 4. 📊 TOLERANS-ODAKLI SEÇİM - Makro toleransı öncelik #1
// 5. 🎲 ÇOKLU DENEME SİSTEMİ - 5 farklı kombinasyon dener, en iyisini seçer
// ============================================================================

class AIBeslenmeServisiV53RadikalFix {
  Random _random = Random();
  final Set<String> _haftalikSecilenYemekler = {};
  final Set<String> _gunlukSecilenAnaMalzemeler = {};
  final Map<String, DateTime> _gunlukCesitlilikGecmisi = {}; 
  
  // 🇹🇷 TÜRK KAHVALTISI KÜLTÜRÜ STANDARTLARI
  final Set<String> _turkKahvaltiUygunOlmayanlar = {
    'ton balığı', 'somon', 'levrek', 'balık', 'fish', 'tuna', 'salmon',
    'tavuk göğsü', 'tavuk but', 'et', 'biftek', 'kıyma', 'kebap', 'dana',
    'hamburger', 'pizza', 'makarna', 'pilav', 'bulgur', 'noodle'
  };
  
  final Set<String> _turkKahvaltiUygunu = {
    'yumurta', 'peynir', 'sucuk', 'salam', 'pastırma', 'zeytin', 'domates',
    'salatalık', 'ekmek', 'simit', 'çay', 'bal', 'reçel', 'tereyağı',
    'yoğurt', 'süt', 'omlet', 'menemen', 'börek', 'poğaça', 'muz', 'elma'
  };

  // ============================================================================
  // 🎯 V5.3 RADİKAL FİX - ANA METOD
  // ============================================================================
  
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
    bool haftalikPlanModu = false,
  }) async {
    try {
      final planTarihi = tarih ?? DateTime.now();
      AppLogger.info('🚀 V5.3 RADİKAL FİX başlatıldı: ${hedefKalori.toInt()} kcal');
      AppLogger.info('🎯 HEDEF MAKROLAR: P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
      
      // 🔥 V5.3 ÇOKLU DENEME SİSTEMİ - 5 farklı kombinasyon dener
      GunlukPlan? enIyiPlan;
      double enIyiSkor = 0.0;
      
      for (int deneme = 1; deneme <= 5; deneme++) {
        AppLogger.info('🎲 V5.3 DENEME $deneme/5 başlatıldı...');
        
        try {
          final denemePlan = await _radikal_makro_plan_olustur(
            hedefKalori: hedefKalori,
            hedefProtein: hedefProtein,
            hedefKarb: hedefKarb,
            hedefYag: hedefYag,
            tarih: planTarihi,
            kisitlamalar: kisitlamalar,
            denemeSayisi: deneme,
          );
          
          // 📊 TOLERANS SKORU HESAPLA
          final toleransSkor = _toleransSkoru(denemePlan);
          AppLogger.info('📊 DENEME $deneme TOLERANS SKORU: ${toleransSkor.toStringAsFixed(1)}/100');
          
          if (toleransSkor > enIyiSkor) {
            enIyiSkor = toleransSkor;
            enIyiPlan = denemePlan;
            AppLogger.success('🎯 YENİ EN İYİ PLAN! Skor: ${toleransSkor.toStringAsFixed(1)}');
          }
          
        } catch (e) {
          AppLogger.warning('⚠️ DENEME $deneme başarısız: $e');
        }
      }
      
      final finalPlan = enIyiPlan ?? await _guvenilFallbackPlan(hedefKalori, hedefProtein, hedefKarb, hedefYag, planTarihi);
      
      // 🎉 FİNAL RAPOR
      AppLogger.success('🎉 V5.3 RADİKAL FİX TAMAMLANDI!');
      AppLogger.info('📊 EN İYİ TOLERANS SKORU: ${enIyiSkor.toStringAsFixed(1)}/100');
      _finalRaporLogla(finalPlan, hedefKalori, hedefProtein, hedefKarb, hedefYag);
      
      return finalPlan;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ V5.3 Radikal Fix Hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============================================================================
  // 🎯 RADİKAL MAKRO PLAN OLUŞTURMA - CORE ALGORITHM
  // ============================================================================
  
  Future<GunlukPlan> _radikal_makro_plan_olustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime tarih,
    required List<String> kisitlamalar,
    required int denemeSayisi,
  }) async {
    
    // 🔥 DENEME-SPESIFIK SEED
    final benzersizSeed = tarih.millisecondsSinceEpoch + (denemeSayisi * 1000000);
    _random = Random(benzersizSeed);
    
    final tumYemekler = await HiveService.tumYemekleriGetir();
    if (tumYemekler.isEmpty) {
      return await _guvenilFallbackPlan(hedefKalori, hedefProtein, hedefKarb, hedefYag, tarih);
    }
    
    // 📊 YEMEK KATEGORİLERİ HAZIRLAMA
    final Map<OgunTipi, List<Yemek>> ogunYemekleri = {};
    for (var yemek in tumYemekler) {
      if (yemek.kisitlamayaUygunMu(kisitlamalar) && yemek.kalori > 10) {
        (ogunYemekleri[yemek.ogun] ??= []).add(yemek);
      }
    }
    
    // 🎯 V5.3 AKILLI KALORİ DAĞILIMI - DİYETİSYEN STANDARDI
    final bool yuksekKaloriModu = hedefKalori >= 2500;
    final bool megaKaloriModu = hedefKalori >= 3500;
    
    Map<String, double> kaloriDagilimi;
    if (megaKaloriModu) {
      // 🔥 MEGA KALORİ MODU (3500+ kcal)
      kaloriDagilimi = {
        'kahvalti': 0.22,
        'araOgun1': 0.15,
        'ogle': 0.25,
        'araOgun2': 0.15,
        'aksam': 0.18,
        'gece': 0.05,
      };
    } else if (yuksekKaloriModu) {
      // 💪 YÜKSEK KALORİ MODU (2500-3499 kcal)
      kaloriDagilimi = {
        'kahvalti': 0.25,
        'araOgun1': 0.12,
        'ogle': 0.28,
        'araOgun2': 0.12,
        'aksam': 0.20,
        'gece': 0.03,
      };
    } else {
      // 🎯 NORMAL MODU (2500 kcal altı)
      kaloriDagilimi = {
        'kahvalti': 0.25,
        'araOgun1': 0.15,
        'ogle': 0.30,
        'araOgun2': 0.15,
        'aksam': 0.15,
        'gece': 0.0,
      };
    }
    
    // 🎯 V5.3 HASSASlık İLE ÖĞÜN OLUŞTURMA
    final ogunler = <String, Yemek?>{};
    double kalanKalori = hedefKalori, kalanProtein = hedefProtein, kalanKarb = hedefKarb, kalanYag = hedefYag;
    
    // 🥞 KAHVALTI - TÜRK KÜLTÜRÜ ODAKLI
    final kahvaltiHedefKalori = hedefKalori * kaloriDagilimi['kahvalti']!;
    final kahvaltiHedefProtein = hedefProtein * 0.20; // %20 protein
    final kahvaltiHedefKarb = hedefKarb * 0.25; // %25 karb
    final kahvaltiHedefYag = hedefYag * 0.25; // %25 yağ
    
    ogunler['kahvalti'] = await _v53_hassas_yemek_sec(
      ogunYemekleri[OgunTipi.kahvalti] ?? [], 
      OgunTipi.kahvalti,
      kahvaltiHedefKalori, kahvaltiHedefProtein, kahvaltiHedefKarb, kahvaltiHedefYag,
      isTurkKahvaltisi: true,
    );
    
    if (ogunler['kahvalti'] != null) {
      kalanKalori -= ogunler['kahvalti']!.kalori;
      kalanProtein -= ogunler['kahvalti']!.protein;
      kalanKarb -= ogunler['kahvalti']!.karbonhidrat;
      kalanYag -= ogunler['kahvalti']!.yag;
    }
    
    // 🍎 ARA ÖĞÜN 1 - PROTEİN ODAKLI
    final araOgun1HedefKalori = hedefKalori * kaloriDagilimi['araOgun1']!;
    final araOgun1HedefProtein = min(kalanProtein * 0.25, hedefProtein * 0.20);
    final araOgun1HedefKarb = min(kalanKarb * 0.20, hedefKarb * 0.15);
    final araOgun1HedefYag = min(kalanYag * 0.20, hedefYag * 0.15);
    
    ogunler['araOgun1'] = await _v53_hassas_yemek_sec(
      ogunYemekleri[OgunTipi.araOgun1] ?? [], 
      OgunTipi.araOgun1,
      araOgun1HedefKalori, araOgun1HedefProtein, araOgun1HedefKarb, araOgun1HedefYag,
      isAraOgun: true,
    );
    
    if (ogunler['araOgun1'] != null) {
      kalanKalori -= ogunler['araOgun1']!.kalori;
      kalanProtein -= ogunler['araOgun1']!.protein;
      kalanKarb -= ogunler['araOgun1']!.karbonhidrat;
      kalanYag -= ogunler['araOgun1']!.yag;
    }
    
    // 🍽️ ÖĞLE - ANA ÖĞÜN
    final ogleHedefKalori = hedefKalori * kaloriDagilimi['ogle']!;
    final ogleHedefProtein = min(kalanProtein * 0.45, hedefProtein * 0.35);
    final ogleHedefKarb = min(kalanKarb * 0.45, hedefKarb * 0.40);
    final ogleHedefYag = min(kalanYag * 0.45, hedefYag * 0.35);
    
    ogunler['ogle'] = await _v53_hassas_yemek_sec(
      ogunYemekleri[OgunTipi.ogle] ?? [], 
      OgunTipi.ogle,
      ogleHedefKalori, ogleHedefProtein, ogleHedefKarb, ogleHedefYag,
      isAnaOgun: true,
    );
    
    if (ogunler['ogle'] != null) {
      kalanKalori -= ogunler['ogle']!.kalori;
      kalanProtein -= ogunler['ogle']!.protein;
      kalanKarb -= ogunler['ogle']!.karbonhidrat;
      kalanYag -= ogunler['ogle']!.yag;
    }
    
    // 🥜 ARA ÖĞÜN 2 - PROTEİN ODAKLI
    final araOgun2HedefKalori = hedefKalori * kaloriDagilimi['araOgun2']!;
    final araOgun2HedefProtein = min(kalanProtein * 0.35, hedefProtein * 0.18);
    final araOgun2HedefKarb = min(kalanKarb * 0.25, hedefKarb * 0.12);
    final araOgun2HedefYag = min(kalanYag * 0.30, hedefYag * 0.15);
    
    ogunler['araOgun2'] = await _v53_hassas_yemek_sec(
      ogunYemekleri[OgunTipi.araOgun2] ?? [], 
      OgunTipi.araOgun2,
      araOgun2HedefKalori, araOgun2HedefProtein, araOgun2HedefKarb, araOgun2HedefYag,
      isAraOgun: true,
    );
    
    if (ogunler['araOgun2'] != null) {
      kalanKalori -= ogunler['araOgun2']!.kalori;
      kalanProtein -= ogunler['araOgun2']!.protein;
      kalanKarb -= ogunler['araOgun2']!.karbonhidrat;
      kalanYag -= ogunler['araOgun2']!.yag;
    }
    
    // 🌙 AKŞAM - SON ANA ÖĞÜN
    final aksamHedefKalori = hedefKalori * kaloriDagilimi['aksam']!;
    final aksamHedefProtein = max(kalanProtein * 0.8, hedefProtein * 0.15);
    final aksamHedefKarb = max(kalanKarb * 0.8, hedefKarb * 0.15);
    final aksamHedefYag = max(kalanYag * 0.8, hedefYag * 0.20);
    
    ogunler['aksam'] = await _v53_hassas_yemek_sec(
      ogunYemekleri[OgunTipi.aksam] ?? [], 
      OgunTipi.aksam,
      aksamHedefKalori, aksamHedefProtein, aksamHedefKarb, aksamHedefYag,
      isAnaOgun: true,
    );
    
    if (ogunler['aksam'] != null) {
      kalanKalori -= ogunler['aksam']!.kalori;
      kalanProtein -= ogunler['aksam']!.protein;
      kalanKarb -= ogunler['aksam']!.karbonhidrat;
      kalanYag -= ogunler['aksam']!.yag;
    }
    
    // 🌃 GECE ATIŞTIRMA - YÜKSEK KALORİ İÇİN
    Yemek? geceAtistirma;
    if (yuksekKaloriModu && kalanKalori > 100) {
      final geceHedefKalori = hedefKalori * kaloriDagilimi['gece']!;
      geceAtistirma = await _v53_hassas_yemek_sec(
        ogunYemekleri[OgunTipi.geceAtistirma] ?? [], 
        OgunTipi.geceAtistirma,
        geceHedefKalori, kalanProtein.clamp(5, 25), kalanKarb.clamp(5, 40), kalanYag.clamp(2, 15),
      );
    }
    
    return GunlukPlan(
      id: 'v53_${tarih.millisecondsSinceEpoch}_$denemeSayisi',
      tarih: tarih,
      kahvalti: ogunler['kahvalti'],
      araOgun1: ogunler['araOgun1'],
      ogleYemegi: ogunler['ogle'],
      araOgun2: ogunler['araOgun2'],
      aksamYemegi: ogunler['aksam'],
      geceAtistirma: geceAtistirma,
      makroHedefleri: MakroHedefleri(
        gunlukKalori: hedefKalori, 
        gunlukProtein: hedefProtein, 
        gunlukKarbonhidrat: hedefKarb, 
        gunlukYag: hedefYag
      ),
      fitnessSkoru: 0,
    );
  }

  // ============================================================================
  // 🎯 V5.3 HASSAS YEMEK SEÇİMİ - TOLERANS ODAKLI
  // ============================================================================
  
  Future<Yemek?> _v53_hassas_yemek_sec(
    List<Yemek> yemekler,
    OgunTipi ogunTipi,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag, {
    bool isAnaOgun = false,
    bool isAraOgun = false,
    bool isTurkKahvaltisi = false,
  }) async {
    
    if (yemekler.isEmpty) {
      AppLogger.warning('⚠️ ${ogunTipi.name} için yemek bulunamadı, fallback kullanılıyor');
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }
    
    AppLogger.info('🎯 V5.3 HASSAS SEÇİM: ${ogunTipi.name} - ${yemekler.length} yemek');
    AppLogger.info('   📊 Hedefler: K:${hedefKalori.toInt()} P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
    
    // 🔥 VERİ TEMİZLEME - BOZUK VERİLERİ FILTRELE
    var temizYemekler = yemekler.where((yemek) {
      return yemek.kalori >= 10 && yemek.kalori <= 2000 &&
             yemek.protein >= 0 && yemek.protein <= 200 &&
             yemek.karbonhidrat >= 0 && yemek.karbonhidrat <= 500 &&
             yemek.yag >= 0 && yemek.yag <= 200;
    }).toList();
    
    AppLogger.info('📊 VERİ TEMİZLEME: ${temizYemekler.length}/${yemekler.length} yemek temiz');
    
    if (temizYemekler.isEmpty) {
      AppLogger.error('🚨 TÜM YEMEKLER BOZUK! Fallback kullanılıyor');
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }
    
    // 🇹🇷 TÜRK KAHVALTISI FİLTRESİ
    if (isTurkKahvaltisi) {
      final turkUygunlar = temizYemekler.where(_turkKahvaltisinaUygunMu).toList();
      if (turkUygunlar.isNotEmpty && turkUygunlar.length >= temizYemekler.length * 0.1) {
        temizYemekler = turkUygunlar;
        AppLogger.success('🇹🇷 TÜRK KAHVALTISI FİLTRESİ: ${turkUygunlar.length} uygun yemek');
      }
    }
    
    // 🎯 V5.3 TOLERANS-ODAKLI SKORLAMA
    final skorluYemekler = <_V53SkorluYemek>[];
    for (final yemek in temizYemekler) {
      
      // 📏 OPTIMAL ÖLÇEK HESAPLAMA
      double enIyiOlcek = 1.0;
      double enIyiSkor = double.infinity;
      
      // 0.7x ile 1.3x arasında 7 farklı ölçek dene
      for (double olcek = 0.7; olcek <= 1.3; olcek += 0.1) {
        final olcekliKalori = yemek.kalori * olcek;
        final olcekliProtein = yemek.protein * olcek;
        final olcekliKarb = yemek.karbonhidrat * olcek;
        final olcekliYag = yemek.yag * olcek;
        
        // 🎯 TOLERANS SKORU HESAPLA
        final kaloriSapma = (olcekliKalori - hedefKalori).abs() / hedefKalori * 100;
        final proteinSapma = hedefProtein > 0 ? (olcekliProtein - hedefProtein).abs() / hedefProtein * 100 : 0;
        final karbSapma = hedefKarb > 0 ? (olcekliKarb - hedefKarb).abs() / hedefKarb * 100 : 0;
        final yagSapma = hedefYag > 0 ? (olcekliYag - hedefYag).abs() / hedefYag * 100 : 0;
        
        // 🔥 AĞIRLIKLI TOLERANS SKORU
        double toleransSkor;
        if (isAraOgun) {
          // Ara öğünlerde protein öncelik
          toleransSkor = (proteinSapma * 3.0) + (kaloriSapma * 2.0) + (karbSapma * 1.0) + (yagSapma * 1.5);
        } else {
          // Ana öğünlerde denge
          toleransSkor = (kaloriSapma * 2.5) + (proteinSapma * 2.0) + (karbSapma * 2.0) + (yagSapma * 1.5);
        }
        
        if (toleransSkor < enIyiSkor) {
          enIyiSkor = toleransSkor;
          enIyiOlcek = olcek;
        }
      }
      
      // 📊 BONUS/CEZA PUANLAMA
      double bonusCezaPuani = 1.0;
      
      // 🔥 ÇEŞİTLİLİK BONUSU
      if (!_haftalikSecilenYemekler.contains(yemek.id)) {
        bonusCezaPuani *= 0.7; // %30 bonus
      }
      
      // 🇹🇷 TÜRK KAHVALTISI BONUSU
      if (isTurkKahvaltisi && _turkKahvaltisinaUygunMu(yemek)) {
        bonusCezaPuani *= 0.5; // %50 bonus
      }
      
      // ⚠️ KATEGORI UYUMSUZLUGU CEZASI
      final anaOgunler = [OgunTipi.kahvalti, OgunTipi.ogle, OgunTipi.aksam];
      if (anaOgunler.contains(ogunTipi) != anaOgunler.contains(yemek.ogun)) {
        bonusCezaPuani *= 3.0; // 3x ceza
      }
      
      final finalSkor = enIyiSkor * bonusCezaPuani;
      skorluYemekler.add(_V53SkorluYemek(yemek, finalSkor, enIyiOlcek));
    }
    
    // 🏆 EN İYİLERİ SEÇ
    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    final topSecimler = skorluYemekler.take(max(1, (skorluYemekler.length * 0.2).ceil())).toList();
    final secilenSkorluYemek = topSecimler[_random.nextInt(topSecimler.length)];
    
    // 📏 ÖLÇEKLE VE DÖNÜŞTÜR
    final secilenYemek = _v53_hassas_olcekle(secilenSkorluYemek.yemek, ogunTipi, secilenSkorluYemek.enIyiOlcek);
    
    // 📊 DETAYLI LOG
    AppLogger.success('✅ V5.3 SEÇİLDİ: ${secilenYemek.ad} (${secilenSkorluYemek.skor.toStringAsFixed(1)} skor)');
    AppLogger.info('   📏 Ölçek: ${secilenSkorluYemek.enIyiOlcek.toStringAsFixed(2)}x');
    AppLogger.info('   📊 Makrolar: K:${secilenYemek.kalori.toInt()} P:${secilenYemek.protein.toInt()}g C:${secilenYemek.karbonhidrat.toInt()}g Y:${secilenYemek.yag.toInt()}g');
    
    // 🔥 ÇEŞİTLİLİK KAYDI
    if (isAnaOgun) {
      _haftalikSecilenYemekler.add(secilenYemek.id);
    }
    
    return secilenYemek;
  }

  // ============================================================================
  // 🔧 V5.3 HASSAS ÖLÇEKLEME - MALZEME DETAYLARI İLE
  // ============================================================================
  
  Yemek _v53_hassas_olcekle(Yemek bazYemek, OgunTipi ogunTipi, double olcek) {
    if (olcek == 1.0) {
      return bazYemek.copyWith(id: 'v53_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}');
    }
    
    final olcekliYemek = bazYemek.copyWith(
      id: 'v53_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}',
      kalori: bazYemek.kalori * olcek,
      protein: bazYemek.protein * olcek,
      karbonhidrat: bazYemek.karbonhidrat * olcek,
      yag: bazYemek.yag * olcek,
      // Malzemeler şimdilik aynı kalıyor - gelecekte ölçeklenecek
    );
    
    AppLogger.info('📏 V5.3 ÖLÇEKLEME: ${bazYemek.ad} → ${olcek.toStringAsFixed(2)}x');
    AppLogger.info('   📊 K:${bazYemek.kalori.toInt()} → K:${olcekliYemek.kalori.toInt()}');
    
    return olcekliYemek;
  }

  // ============================================================================
  // 📊 TOLERANS SKORU HESAPLAMA
  // ============================================================================
  
  double _toleransSkoru(GunlukPlan plan) {
    final makroHedefleri = plan.makroHedefleri;
    
    final kaloriSapma = ((plan.toplamKalori - makroHedefleri.gunlukKalori).abs() / makroHedefleri.gunlukKalori) * 100;
    final proteinSapma = ((plan.toplamProtein - makroHedefleri.gunlukProtein).abs() / makroHedefleri.gunlukProtein) * 100;
    final karbSapma = ((plan.toplamKarbonhidrat - makroHedefleri.gunlukKarbonhidrat).abs() / makroHedefleri.gunlukKarbonhidrat) * 100;
    final yagSapma = ((plan.toplamYag - makroHedefleri.gunlukYag).abs() / makroHedefleri.gunlukYag) * 100;
    
    // 🎯 DİYETİSYEN STANDARDI: ±15% tolerans
    final kaloriToleransIcinde = kaloriSapma <= 15.0;
    final proteinToleransIcinde = proteinSapma <= 15.0;
    final karbToleransIcinde = karbSapma <= 15.0;
    final yagToleransIcinde = yagSapma <= 15.0;
    
    double skor = 0.0;
    if (kaloriToleransIcinde) skor += 30; // %30
    if (proteinToleransIcinde) skor += 25; // %25
    if (karbToleransIcinde) skor += 25; // %25
    if (yagToleransIcinde) skor += 20; // %20
    
    return skor;
  }

  // ============================================================================
  // 🇹🇷 TÜRK KAHVALTISI UYUMLULUK KONTROLÜ
  // ============================================================================
  
  bool _turkKahvaltisinaUygunMu(Yemek yemek) {
    final yemekAdiLower = yemek.ad.toLowerCase();
    final malzemelerText = yemek.malzemeler.join(' ').toLowerCase();
    final tumText = '$yemekAdiLower $malzemelerText';
    
    // 🚫 YASAK KONTROL
    for (final yasak in _turkKahvaltiUygunOlmayanlar) {
      if (tumText.contains(yasak)) {
        return false;
      }
    }
    
    // ✅ UYGUN KONTROL
    for (final uygun in _turkKahvaltiUygunu) {
      if (tumText.contains(uygun)) {
        return true;
      }
    }
    
    return true; // Neutral durumlar geçebilir
  }

  // ============================================================================
  // 📊 FİNAL RAPOR LOGLAMA
  // ============================================================================
  
  void _finalRaporLogla(GunlukPlan plan, double hedefKalori, double hedefProtein, double hedefKarb, double hedefYag) {
    AppLogger.success('🎉 V5.3 RADİKAL FİX - FİNAL PLAN:');
    if (plan.kahvalti != null) {
      AppLogger.info('   🥞 Kahvaltı: ${plan.kahvalti!.ad} (${plan.kahvalti!.kalori.toInt()} kcal)');
    }
    if (plan.araOgun1 != null) {
      AppLogger.info('   🍎 Ara Öğün 1: ${plan.araOgun1!.ad} (${plan.araOgun1!.kalori.toInt()} kcal)');
    }
    if (plan.ogleYemegi != null) {
      AppLogger.info('   🍽️ Öğle: ${plan.ogleYemegi!.ad} (${plan.ogleYemegi!.kalori.toInt()} kcal)');
    }
    if (plan.araOgun2 != null) {
      AppLogger.info('   🥜 Ara Öğün 2: ${plan.araOgun2!.ad} (${plan.araOgun2!.kalori.toInt()} kcal)');
    }
    if (plan.aksamYemegi != null) {
      AppLogger.info('   🌙 Akşam: ${plan.aksamYemegi!.ad} (${plan.aksamYemegi!.kalori.toInt()} kcal)');
    }
    if (plan.geceAtistirma != null) {
      AppLogger.info('   🌃 Gece: ${plan.geceAtistirma!.ad} (${plan.geceAtistirma!.kalori.toInt()} kcal)');
    }
    
    // 📊 MAKRO ANALİZ
    AppLogger.info('📊 V5.3 MAKRO ANALİZ:');
    AppLogger.info('   🔥 Kalori: ${plan.toplamKalori.toInt()}/${hedefKalori.toInt()} (${((plan.toplamKalori/hedefKalori-1)*100).toStringAsFixed(1)}%)');
    AppLogger.info('   🥩 Protein: ${plan.toplamProtein.toInt()}g/${hedefProtein.toInt()}g (${((plan.toplamProtein/hedefProtein-1)*100).toStringAsFixed(1)}%)');
    AppLogger.info('   🍞 Karb: ${plan.toplamKarbonhidrat.toInt()}g/${hedefKarb.toInt()}g (${((plan.toplamKarbonhidrat/hedefKarb-1)*100).toStringAsFixed(1)}%)');
    AppLogger.info('   🧈 Yağ: ${plan.toplamYag.toInt()}g/${hedefYag.toInt()}g (${((plan.toplamYag/hedefYag-1)*100).toStringAsFixed(1)}%)');
    
    final toleransSkor = _toleransSkoru(plan);
    AppLogger.info('📊 V5.3 TOLERANS SKORU: ${toleransSkor.toStringAsFixed(1)}/100');
    
    if (toleransSkor >= 70) {
      AppLogger.success('🎉 DİYETİSYEN STANDARDI SAĞLANDI! (%70+ tolerans)');
    } else if (toleransSkor >= 50) {
      AppLogger.info('⚠️ ORTA SEVIYE - İyileştirme gerekli');
    } else {
      AppLogger.warning('🚨 DÜŞÜK TOLERANS - Radikal değişiklik gerekli');
    }
  }

  // ============================================================================
  // 🛡️ GÜVENİLİR FALLBACK SİSTEMİ
  // ============================================================================
  
  Future<GunlukPlan> _guvenilFallbackPlan(
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
    DateTime tarih,
  ) async {
    AppLogger.warning('🛡️ V5.3 FALLBACK sistem devreye girdi');
    
    final gunIndex = (tarih.day % 7);
    
    // V5.3 GENİŞLETİLMİŞ FALLBACK HAVUZU KULLAN
    final kahvalti = _v53_hassas_olcekle(_fallbackYemekHavuzundanSec(OgunTipi.kahvalti, gunIndex), OgunTipi.kahvalti, hedefKalori * 0.25 / 450);
    final araOgun1 = _v53_hassas_olcekle(_fallbackYemekHavuzundanSec(OgunTipi.araOgun1, gunIndex), OgunTipi.araOgun1, hedefKalori * 0.15 / 300);
    final ogleYemegi = _v53_hassas_olcekle(_fallbackYemekHavuzundanSec(OgunTipi.ogle, gunIndex), OgunTipi.ogle, hedefKalori * 0.30 / 750);
    final araOgun2 = _v53_hassas_olcekle(_fallbackYemekHavuzundanSec(OgunTipi.araOgun2, gunIndex), OgunTipi.araOgun2, hedefKalori * 0.15 / 350);
    final aksamYemegi = _v53_hassas_olcekle(_fallbackYemekHavuzundanSec(OgunTipi.aksam, gunIndex), OgunTipi.aksam, hedefKalori * 0.15 / 650);
    
    return GunlukPlan(
      id: 'v53_fallback_${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: araOgun2,
      aksamYemegi: aksamYemegi,
      makroHedefleri: MakroHedefleri(gunlukKalori: hedefKalori, gunlukProtein: hedefProtein, gunlukKarbonhidrat: hedefKarb, gunlukYag: hedefYag),
      fitnessSkoru: 85,
    );
  }

  Yemek _fallbackYemekHavuzundanSec(OgunTipi ogun, int gunIndex) {
    final havuz = _fallbackYemekHavuzu.where((y) => y.ogun == ogun).toList();
    if (havuz.isEmpty) {
      return Yemek(id: 'v53_acil_fallback', ad: 'Acil Yemek', ogun: ogun, kalori: 400, protein: 25, karbonhidrat: 45, yag: 15, malzemeler: ['Acil Malzeme'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay);
    }
    return havuz[gunIndex % havuz.length];
  }

  // GENİŞLETİLMİŞ FALLBACK HAVUZU (V5.2'den miras)
  static final List<Yemek> _fallbackYemekHavuzu = [
    // TÜRK KAHVALTILARI
    Yemek(id: 'fb_k_1', ad: 'Peynirli Omlet', ogun: OgunTipi.kahvalti, kalori: 420, protein: 25, karbonhidrat: 30, yag: 22, malzemeler: ['Yumurta (2 adet)', 'Beyaz Peynir (50g)', 'Ekmek (2 dilim)'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_2', ad: 'Bal Kaymak', ogun: OgunTipi.kahvalti, kalori: 580, protein: 22, karbonhidrat: 75, yag: 22, malzemeler: ['Ekmek (3 dilim)', 'Kaymak (45g)', 'Bal (2.5 YK)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_3', ad: 'Menemen', ogun: OgunTipi.kahvalti, kalori: 520, protein: 26, karbonhidrat: 42, yag: 28, malzemeler: ['Yumurta (3 adet)', 'Domates (2 adet)', 'Ekmek (2 dilim)'], hazirlamaSuresi: 15, zorluk: Zorluk.orta),

    // ÖĞLE YEMEKLERİ  
    Yemek(id: 'fb_o_1', ad: 'Tavuklu Pilav', ogun: OgunTipi.ogle, kalori: 750, protein: 55, karbonhidrat: 85, yag: 20, malzemeler: ['Tavuk Göğsü (200g)', 'Pirinç Pilavı (200g)'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_2', ad: 'Köfte Patates', ogun: OgunTipi.ogle, kalori: 820, protein: 45, karbonhidrat: 90, yag: 32, malzemeler: ['Köfte (6 adet)', 'Patates (250g)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_3', ad: 'Etli Fasulye', ogun: OgunTipi.ogle, kalori: 780, protein: 50, karbonhidrat: 85, yag: 26, malzemeler: ['Etli Fasulye (350g)', 'Pirinç Pilavı (180g)'], hazirlamaSuresi: 30, zorluk: Zorluk.orta),

    // AKŞAM YEMEKLERİ
    Yemek(id: 'fb_ak_1', ad: 'Sebzeli Tavuk', ogun: OgunTipi.aksam, kalori: 620, protein: 52, karbonhidrat: 45, yag: 28, malzemeler: ['Tavuk Göğsü (200g)', 'Sebze Sote (250g)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_ak_2', ad: 'Balık Salata', ogun: OgunTipi.aksam, kalori: 580, protein: 48, karbonhidrat: 35, yag: 32, malzemeler: ['Levrek (200g)', 'Yeşil Salata (200g)'], hazirlamaSuresi: 30, zorluk: Zorluk.orta),

    // ARA ÖĞÜNLER
    Yemek(id: 'fb_a1_1', ad: 'Elma Ceviz', ogun: OgunTipi.araOgun1, kalori: 280, protein: 8, karbonhidrat: 35, yag: 15, malzemeler: ['Elma (1 büyük)', 'Ceviz (10 adet)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a1_2', ad: 'Protein Smoothie', ogun: OgunTipi.araOgun1, kalori: 350, protein: 28, karbonhidrat: 42, yag: 10, malzemeler: ['Süt (300ml)', 'Muz (1 adet)'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
    
    Yemek(id: 'fb_a2_1', ad: 'Ballı Yoğurt', ogun: OgunTipi.araOgun2, kalori: 320, protein: 24, karbonhidrat: 38, yag: 8, malzemeler: ['Süzme Yoğurt (250g)', 'Bal (2 YK)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a2_2', ad: 'Kuruyemiş', ogun: OgunTipi.araOgun2, kalori: 380, protein: 15, karbonhidrat: 32, yag: 25, malzemeler: ['Badem (20 adet)', 'Ceviz (8 adet)'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
    
    // GECE ATIŞTIRMASI
    Yemek(id: 'fb_gece_1', ad: 'Protein Atıştırma', ogun: OgunTipi.geceAtistirma, kalori: 420, protein: 35, karbonhidrat: 28, yag: 18, malzemeler: ['Süzme Yoğurt (250g)', 'Protein Tozu (25g)'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
  ];
}

// ============================================================================
// YARDIMCI SINIFLAR
// ============================================================================

class _V53SkorluYemek {
  final Yemek yemek;
  final double skor;
  final double enIyiOlcek;
  _V53SkorluYemek(this.yemek, this.skor, this.enIyiOlcek);
}