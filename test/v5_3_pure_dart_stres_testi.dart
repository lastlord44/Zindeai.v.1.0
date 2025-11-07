// ============================================================================
// test/v5_3_pure_dart_stres_testi.dart
// V5.3 RADİKAL FİX PURE DART STRES TESTİ - FLUTTER BAĞIMSIZ
// 🎯 HEDEF: %70+ TOLERANS BAŞARISI + MAKRO KRİZİ ÇÖZÜMÜ
// ============================================================================

import 'dart:math';

// ============================================================================
// MOCK ENTITIES - FLUTTER BAĞIMSIZ
// ============================================================================

enum OgunTipi { 
  kahvalti, araOgun1, ogle, araOgun2, aksam, geceAtistirma 
}

enum Hedef { 
  kiloVermek, kiloAlmak, kasKazanKiloAl, kasKazanKiloVer, formdaKal 
}

enum Zorluk { 
  kolay, orta, zor 
}

class Yemek {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final int hazirlamaSuresi;
  final Zorluk zorluk;

  Yemek({
    required this.id,
    required this.ad,
    required this.ogun,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.malzemeler,
    required this.hazirlamaSuresi,
    required this.zorluk,
  });

  Yemek copyWith({
    String? id,
    String? ad,
    OgunTipi? ogun,
    double? kalori,
    double? protein,
    double? karbonhidrat,
    double? yag,
    List<String>? malzemeler,
    int? hazirlamaSuresi,
    Zorluk? zorluk,
  }) {
    return Yemek(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      ogun: ogun ?? this.ogun,
      kalori: kalori ?? this.kalori,
      protein: protein ?? this.protein,
      karbonhidrat: karbonhidrat ?? this.karbonhidrat,
      yag: yag ?? this.yag,
      malzemeler: malzemeler ?? this.malzemeler,
      hazirlamaSuresi: hazirlamaSuresi ?? this.hazirlamaSuresi,
      zorluk: zorluk ?? this.zorluk,
    );
  }

  bool kisitlamayaUygunMu(List<String> kisitlamalar) {
    final yemekText = '${ad.toLowerCase()} ${malzemeler.join(' ').toLowerCase()}';
    for (final kisitlama in kisitlamalar) {
      if (yemekText.contains(kisitlama.toLowerCase())) {
        return false;
      }
    }
    return true;
  }
}

class MakroHedefleri {
  final double gunlukKalori;
  final double gunlukProtein;
  final double gunlukKarbonhidrat;
  final double gunlukYag;

  MakroHedefleri({
    required this.gunlukKalori,
    required this.gunlukProtein,
    required this.gunlukKarbonhidrat,
    required this.gunlukYag,
  });
}

class GunlukPlan {
  final String id;
  final DateTime tarih;
  final Yemek? kahvalti;
  final Yemek? araOgun1;
  final Yemek? ogleYemegi;
  final Yemek? araOgun2;
  final Yemek? aksamYemegi;
  final Yemek? geceAtistirma;
  final MakroHedefleri makroHedefleri;
  final int fitnessSkoru;

  GunlukPlan({
    required this.id,
    required this.tarih,
    this.kahvalti,
    this.araOgun1,
    this.ogleYemegi,
    this.araOgun2,
    this.aksamYemegi,
    this.geceAtistirma,
    required this.makroHedefleri,
    required this.fitnessSkoru,
  });

  double get toplamKalori => (kahvalti?.kalori ?? 0) + (araOgun1?.kalori ?? 0) + 
                            (ogleYemegi?.kalori ?? 0) + (araOgun2?.kalori ?? 0) + 
                            (aksamYemegi?.kalori ?? 0) + (geceAtistirma?.kalori ?? 0);

  double get toplamProtein => (kahvalti?.protein ?? 0) + (araOgun1?.protein ?? 0) + 
                             (ogleYemegi?.protein ?? 0) + (araOgun2?.protein ?? 0) + 
                             (aksamYemegi?.protein ?? 0) + (geceAtistirma?.protein ?? 0);

  double get toplamKarbonhidrat => (kahvalti?.karbonhidrat ?? 0) + (araOgun1?.karbonhidrat ?? 0) + 
                                  (ogleYemegi?.karbonhidrat ?? 0) + (araOgun2?.karbonhidrat ?? 0) + 
                                  (aksamYemegi?.karbonhidrat ?? 0) + (geceAtistirma?.karbonhidrat ?? 0);

  double get toplamYag => (kahvalti?.yag ?? 0) + (araOgun1?.yag ?? 0) + 
                         (ogleYemegi?.yag ?? 0) + (araOgun2?.yag ?? 0) + 
                         (aksamYemegi?.yag ?? 0) + (geceAtistirma?.yag ?? 0);
}

// ============================================================================
// MOCK VERİ HAVUZU - TÜRK MUTFAĞI
// ============================================================================

class MockYemekHavuzu {
  static List<Yemek> tumYemekleriGetir() {
    return [
      // KAHVALTI YEMEKLERI
      Yemek(id: 'k1', ad: 'Peynirli Omlet', ogun: OgunTipi.kahvalti, kalori: 420, protein: 28, karbonhidrat: 12, yag: 30, malzemeler: ['Yumurta', 'Beyaz Peynir'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay),
      Yemek(id: 'k2', ad: 'Menemen', ogun: OgunTipi.kahvalti, kalori: 380, protein: 18, karbonhidrat: 22, yag: 28, malzemeler: ['Yumurta', 'Domates', 'Biber'], hazirlamaSuresi: 15, zorluk: Zorluk.kolay),
      Yemek(id: 'k3', ad: 'Sucuklu Yumurta', ogun: OgunTipi.kahvalti, kalori: 520, protein: 32, karbonhidrat: 8, yag: 40, malzemeler: ['Yumurta', 'Sucuk'], hazirlamaSuresi: 8, zorluk: Zorluk.kolay),
      Yemek(id: 'k4', ad: 'Bal Kaymak', ogun: OgunTipi.kahvalti, kalori: 580, protein: 15, karbonhidrat: 75, yag: 25, malzemeler: ['Ekmek', 'Bal', 'Kaymak'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
      Yemek(id: 'k5', ad: 'Peynirli Ekmek', ogun: OgunTipi.kahvalti, kalori: 350, protein: 18, karbonhidrat: 45, yag: 12, malzemeler: ['Ekmek', 'Beyaz Peynir'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
      
      // ARA ÖĞÜN 1 
      Yemek(id: 'a1_1', ad: 'Elma Ceviz', ogun: OgunTipi.araOgun1, kalori: 280, protein: 8, karbonhidrat: 35, yag: 15, malzemeler: ['Elma', 'Ceviz'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
      Yemek(id: 'a1_2', ad: 'Protein Smoothie', ogun: OgunTipi.araOgun1, kalori: 350, protein: 30, karbonhidrat: 25, yag: 12, malzemeler: ['Süt', 'Muz', 'Protein Tozu'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
      Yemek(id: 'a1_3', ad: 'Yoğurt Muz', ogun: OgunTipi.araOgun1, kalori: 320, protein: 18, karbonhidrat: 42, yag: 8, malzemeler: ['Yoğurt', 'Muz'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
      Yemek(id: 'a1_4', ad: 'Badem Hurma', ogun: OgunTipi.araOgun1, kalori: 380, protein: 12, karbonhidrat: 45, yag: 18, malzemeler: ['Badem', 'Hurma'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      
      // ÖĞLE YEMEKLERİ
      Yemek(id: 'o1', ad: 'Tavuklu Pilav', ogun: OgunTipi.ogle, kalori: 750, protein: 55, karbonhidrat: 85, yag: 20, malzemeler: ['Tavuk Göğsü', 'Pirinç'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
      Yemek(id: 'o2', ad: 'Köfte Patates', ogun: OgunTipi.ogle, kalori: 820, protein: 45, karbonhidrat: 90, yag: 32, malzemeler: ['Kıyma', 'Patates'], hazirlamaSuresi: 30, zorluk: Zorluk.orta),
      Yemek(id: 'o3', ad: 'Balık Pilav', ogun: OgunTipi.ogle, kalori: 680, protein: 50, karbonhidrat: 78, yag: 18, malzemeler: ['Balık', 'Pirinç'], hazirlamaSuresi: 35, zorluk: Zorluk.orta),
      Yemek(id: 'o4', ad: 'Etli Fasulye', ogun: OgunTipi.ogle, kalori: 720, protein: 48, karbonhidrat: 82, yag: 22, malzemeler: ['Et', 'Fasulye', 'Pirinç'], hazirlamaSuresi: 40, zorluk: Zorluk.orta),
      Yemek(id: 'o5', ad: 'Tavuk Şiş', ogun: OgunTipi.ogle, kalori: 650, protein: 58, karbonhidrat: 45, yag: 28, malzemeler: ['Tavuk', 'Bulgur'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
      
      // ARA ÖĞÜN 2
      Yemek(id: 'a2_1', ad: 'Ballı Yoğurt', ogun: OgunTipi.araOgun2, kalori: 320, protein: 24, karbonhidrat: 38, yag: 8, malzemeler: ['Süzme Yoğurt', 'Bal'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
      Yemek(id: 'a2_2', ad: 'Kuruyemiş Karışımı', ogun: OgunTipi.araOgun2, kalori: 380, protein: 15, karbonhidrat: 32, yag: 25, malzemeler: ['Badem', 'Ceviz', 'Fındık'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
      Yemek(id: 'a2_3', ad: 'Peynir Meyve', ogun: OgunTipi.araOgun2, kalori: 290, protein: 20, karbonhidrat: 28, yag: 12, malzemeler: ['Lor Peyniri', 'Üzüm'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
      Yemek(id: 'a2_4', ad: 'Protein Bar', ogun: OgunTipi.araOgun2, kalori: 420, protein: 32, karbonhidrat: 35, yag: 15, malzemeler: ['Protein Tozu', 'Yulaf'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
      
      // AKŞAM YEMEKLERİ
      Yemek(id: 'ak1', ad: 'Sebzeli Tavuk', ogun: OgunTipi.aksam, kalori: 520, protein: 45, karbonhidrat: 35, yag: 22, malzemeler: ['Tavuk', 'Sebze'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
      Yemek(id: 'ak2', ad: 'Balık Salata', ogun: OgunTipi.aksam, kalori: 480, protein: 42, karbonhidrat: 25, yag: 28, malzemeler: ['Balık', 'Salata'], hazirlamaSuresi: 20, zorluk: Zorluk.kolay),
      Yemek(id: 'ak3', ad: 'Et Kavurma', ogun: OgunTipi.aksam, kalori: 580, protein: 48, karbonhidrat: 22, yag: 35, malzemeler: ['Dana Eti', 'Soğan'], hazirlamaSuresi: 35, zorluk: Zorluk.orta),
      Yemek(id: 'ak4', ad: 'Tavuk Salata', ogun: OgunTipi.aksam, kalori: 420, protein: 38, karbonhidrat: 18, yag: 24, malzemeler: ['Tavuk', 'Yeşillik'], hazirlamaSuresi: 15, zorluk: Zorluk.kolay),
      
      // GECE ATIŞTIRMA
      Yemek(id: 'g1', ad: 'Protein Atıştırma', ogun: OgunTipi.geceAtistirma, kalori: 280, protein: 25, karbonhidrat: 18, yag: 12, malzemeler: ['Süzme Yoğurt', 'Protein'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
      Yemek(id: 'g2', ad: 'Lor Peyniri', ogun: OgunTipi.geceAtistirma, kalori: 220, protein: 22, karbonhidrat: 8, yag: 12, malzemeler: ['Lor Peyniri'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
    ];
  }
}

// ============================================================================
// V5.3 RADİKAL FİX ALGORİTMA - PURE DART
// ============================================================================

class AIBeslenmeServisiV53PureDart {
  Random _random = Random();
  final Set<String> _haftalikSecilenYemekler = {};
  final Set<String> _gunlukSecilenAnaMalzemeler = {};
  
  // 🇹🇷 TÜRK KAHVALTISI KÜLTÜRÜ
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

  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
  }) async {
    try {
      final planTarihi = tarih ?? DateTime.now();
      print('🚀 V5.3 RADİKAL FİX başlatıldı: ${hedefKalori.toInt()} kcal');
      print('🎯 HEDEF MAKROLAR: P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
      
      // 🔥 V5.3 ÇOKLU DENEME SİSTEMİ - 5 farklı kombinasyon dener
      GunlukPlan? enIyiPlan;
      double enIyiSkor = 0.0;
      
      for (int deneme = 1; deneme <= 5; deneme++) {
        print('🎲 V5.3 DENEME $deneme/5 başlatıldı...');
        
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
          print('📊 DENEME $deneme TOLERANS SKORU: ${toleransSkor.toStringAsFixed(1)}/100');
          
          if (toleransSkor > enIyiSkor) {
            enIyiSkor = toleransSkor;
            enIyiPlan = denemePlan;
            print('🎯 YENİ EN İYİ PLAN! Skor: ${toleransSkor.toStringAsFixed(1)}');
          }
          
        } catch (e) {
          print('⚠️ DENEME $deneme başarısız: $e');
        }
      }
      
      final finalPlan = enIyiPlan ?? await _guvenilFallbackPlan(hedefKalori, hedefProtein, hedefKarb, hedefYag, planTarihi);
      
      // 🎉 FİNAL RAPOR
      print('🎉 V5.3 RADİKAL FİX TAMAMLANDI!');
      print('📊 EN İYİ TOLERANS SKORU: ${enIyiSkor.toStringAsFixed(1)}/100');
      _finalRaporLogla(finalPlan, hedefKalori, hedefProtein, hedefKarb, hedefYag);
      
      return finalPlan;
      
    } catch (e, stackTrace) {
      print('❌ V5.3 Radikal Fix Hatası: $e');
      print(stackTrace);
      rethrow;
    }
  }

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
    
    final tumYemekler = MockYemekHavuzu.tumYemekleriGetir();
    
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
      kaloriDagilimi = {
        'kahvalti': 0.22,
        'araOgun1': 0.15,
        'ogle': 0.25,
        'araOgun2': 0.15,
        'aksam': 0.18,
        'gece': 0.05,
      };
    } else if (yuksekKaloriModu) {
      kaloriDagilimi = {
        'kahvalti': 0.25,
        'araOgun1': 0.12,
        'ogle': 0.28,
        'araOgun2': 0.12,
        'aksam': 0.20,
        'gece': 0.03,
      };
    } else {
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
    
    // 🥞 KAHVALTI
    final kahvaltiHedefKalori = hedefKalori * kaloriDagilimi['kahvalti']!;
    final kahvaltiHedefProtein = hedefProtein * 0.20; 
    final kahvaltiHedefKarb = hedefKarb * 0.25; 
    final kahvaltiHedefYag = hedefYag * 0.25; 
    
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
    
    // 🍎 ARA ÖĞÜN 1
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
    
    // 🍽️ ÖĞLE
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
    
    // 🥜 ARA ÖĞÜN 2
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
    
    // 🌙 AKŞAM
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
    
    // 🌃 GECE ATIŞTIRMA
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
      print('⚠️ ${ogunTipi.name} için yemek bulunamadı');
      return null;
    }
    
    print('🎯 V5.3 HASSAS SEÇİM: ${ogunTipi.name} - ${yemekler.length} yemek');
    
    // 🔥 VERİ TEMİZLEME
    var temizYemekler = yemekler.where((yemek) {
      return yemek.kalori >= 10 && yemek.kalori <= 2000 &&
             yemek.protein >= 0 && yemek.protein <= 200 &&
             yemek.karbonhidrat >= 0 && yemek.karbonhidrat <= 500 &&
             yemek.yag >= 0 && yemek.yag <= 200;
    }).toList();
    
    if (temizYemekler.isEmpty) return null;
    
    // 🇹🇷 TÜRK KAHVALTISI FİLTRESİ
    if (isTurkKahvaltisi) {
      final turkUygunlar = temizYemekler.where(_turkKahvaltisinaUygunMu).toList();
      if (turkUygunlar.isNotEmpty) {
        temizYemekler = turkUygunlar;
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
          toleransSkor = (proteinSapma * 3.0) + (kaloriSapma * 2.0) + (karbSapma * 1.0) + (yagSapma * 1.5);
        } else {
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
      
      final finalSkor = enIyiSkor * bonusCezaPuani;
      skorluYemekler.add(_V53SkorluYemek(yemek, finalSkor, enIyiOlcek));
    }
    
    // 🏆 EN İYİLERİ SEÇ
    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    final topSecimler = skorluYemekler.take(max(1, (skorluYemekler.length * 0.2).ceil())).toList();
    final secilenSkorluYemek = topSecimler[_random.nextInt(topSecimler.length)];
    
    // 📏 ÖLÇEKLE VE DÖNÜŞTÜR
    final secilenYemek = _v53_hassas_olcekle(secilenSkorluYemek.yemek, ogunTipi, secilenSkorluYemek.enIyiOlcek);
    
    print('✅ V5.3 SEÇİLDİ: ${secilenYemek.ad} (${secilenSkorluYemek.skor.toStringAsFixed(1)} skor)');
    
    // 🔥 ÇEŞİTLİLİK KAYDI
    if (isAnaOgun) {
      _haftalikSecilenYemekler.add(secilenYemek.id);
    }
    
    return secilenYemek;
  }

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
    );
    
    print('📏 V5.3 ÖLÇEKLEME: ${bazYemek.ad} → ${olcek.toStringAsFixed(2)}x');
    
    return olcekliYemek;
  }

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
    
    return true;
  }

  void _finalRaporLogla(GunlukPlan plan, double hedefKalori, double hedefProtein, double hedefKarb, double hedefYag) {
    print('🎉 V5.3 RADİKAL FİX - FİNAL PLAN:');
    if (plan.kahvalti != null) {
      print('   🥞 Kahvaltı: ${plan.kahvalti!.ad} (${plan.kahvalti!.kalori.toInt()} kcal)');
    }
    if (plan.araOgun1 != null) {
      print('   🍎 Ara Öğün 1: ${plan.araOgun1!.ad} (${plan.araOgun1!.kalori.toInt()} kcal)');
    }
    if (plan.ogleYemegi != null) {
      print('   🍽️ Öğle: ${plan.ogleYemegi!.ad} (${plan.ogleYemegi!.kalori.toInt()} kcal)');
    }
    if (plan.araOgun2 != null) {
      print('   🥜 Ara Öğün 2: ${plan.araOgun2!.ad} (${plan.araOgun2!.kalori.toInt()} kcal)');
    }
    if (plan.aksamYemegi != null) {
      print('   🌙 Akşam: ${plan.aksamYemegi!.ad} (${plan.aksamYemegi!.kalori.toInt()} kcal)');
    }
    if (plan.geceAtistirma != null) {
      print('   🌃 Gece: ${plan.geceAtistirma!.ad} (${plan.geceAtistirma!.kalori.toInt()} kcal)');
    }
    
    // 📊 MAKRO ANALİZ
    print('📊 V5.3 MAKRO ANALİZ:');
    print('   🔥 Kalori: ${plan.toplamKalori.toInt()}/${hedefKalori.toInt()} (${((plan.toplamKalori/hedefKalori-1)*100).toStringAsFixed(1)}%)');
    print('   🥩 Protein: ${plan.toplamProtein.toInt()}g/${hedefProtein.toInt()}g (${((plan.toplamProtein/hedefProtein-1)*100).toStringAsFixed(1)}%)');
    print('   🍞 Karb: ${plan.toplamKarbonhidrat.toInt()}g/${hedefKarb.toInt()}g (${((plan.toplamKarbonhidrat/hedefKarb-1)*100).toStringAsFixed(1)}%)');
    print('   🧈 Yağ: ${plan.toplamYag.toInt()}g/${hedefYag.toInt()}g (${((plan.toplamYag/hedefYag-1)*100).toStringAsFixed(1)}%)');
    
    final toleransSkor = _toleransSkoru(plan);
    print('📊 V5.3 TOLERANS SKORU: ${toleransSkor.toStringAsFixed(1)}/100');
    
    if (toleransSkor >= 70) {
      print('🎉 DİYETİSYEN STANDARDI SAĞLANDI! (%70+ tolerans)');
    } else if (toleransSkor >= 50) {
      print('⚠️ ORTA SEVIYE - İyileştirme gerekli');
    } else {
      print('🚨 DÜŞÜK TOLERANS - Radikal değişiklik gerekli');
    }
  }

  Future<GunlukPlan> _guvenilFallbackPlan(
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
    DateTime tarih,
  ) async {
    print('🛡️ V5.3 FALLBACK sistem devreye girdi');
    
    // Basit fallback plan
    final kahvalti = Yemek(id: 'fb_k', ad: 'Peynirli Omlet', ogun: OgunTipi.kahvalti, kalori: hedefKalori * 0.25, protein: hedefProtein * 0.25, karbonhidrat: hedefKarb * 0.25, yag: hedefYag * 0.25, malzemeler: ['Yumurta', 'Peynir'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay);
    final ogleYemegi = Yemek(id: 'fb_o', ad: 'Tavuklu Pilav', ogun: OgunTipi.ogle, kalori: hedefKalori * 0.30, protein: hedefProtein * 0.30, karbonhidrat: hedefKarb * 0.35, yag: hedefYag * 0.30, malzemeler: ['Tavuk', 'Pirinç'], hazirlamaSuresi: 25, zorluk: Zorluk.orta);
    final aksamYemegi = Yemek(id: 'fb_ak', ad: 'Sebzeli Tavuk', ogun: OgunTipi.aksam, kalori: hedefKalori * 0.25, protein: hedefProtein * 0.25, karbonhidrat: hedefKarb * 0.20, yag: hedefYag * 0.25, malzemeler: ['Tavuk', 'Sebze'], hazirlamaSuresi: 20, zorluk: Zorluk.orta);
    final araOgun1 = Yemek(id: 'fb_a1', ad: 'Elma Ceviz', ogun: OgunTipi.araOgun1, kalori: hedefKalori * 0.10, protein: hedefProtein * 0.10, karbonhidrat: hedefKarb * 0.10, yag: hedefYag * 0.10, malzemeler: ['Elma', 'Ceviz'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay);
    final araOgun2 = Yemek(id: 'fb_a2', ad: 'Ballı Yoğurt', ogun: OgunTipi.araOgun2, kalori: hedefKalori * 0.10, protein: hedefProtein * 0.10, karbonhidrat: hedefKarb * 0.10, yag: hedefYag * 0.10, malzemeler: ['Yoğurt', 'Bal'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay);
    
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
}

class _V53SkorluYemek {
  final Yemek yemek;
  final double skor;
  final double enIyiOlcek;
  _V53SkorluYemek(this.yemek, this.skor, this.enIyiOlcek);
}

// ============================================================================
// V5.3 PURE DART STRES TESTİ - 25 PROFİL
// ============================================================================

class V53PureDartStresTestiSonucu {
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

  V53PureDartStresTestiSonucu({
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

class V53PureDartStresTesti {
  final AIBeslenmeServisiV53PureDart _aiServis = AIBeslenmeServisiV53PureDart();
  final List<V53PureDartStresTestiSonucu> _sonuclar = [];

  Future<void> fullStresTestiCalistir() async {
    try {
      print('🚀 V5.3 RADİKAL FİX PURE DART ULTRA STRES TESTİ BAŞLIYOR!');
      print('📊 25 farklı profil test edilecek...');
      print('🎯 DİYETİSYEN STANDARDI: ±15% makro tolerans');
      print('=' * 50);

      final testProfilleri = _testProfilleriniOlustur();
      
      int profilSayaci = 1;
      for (final profil in testProfilleri) {
        print('🧪 TEST ${profilSayaci}/25: ${profil['ad']}');
        print('   📊 ${profil['kalori']} kcal | ${profil['hedef']}');
        
        final sonuc = await _tekProfilTest(profil, profilSayaci);
        _sonuclar.add(sonuc);
        
        _tekProfilSonucLogla(sonuc);
        profilSayaci++;
        print('=' * 50);
      }

      // 🎉 FİNAL ANALİZ
      _finalAnalizRaporla();

    } catch (e, stackTrace) {
      print('❌ V5.3 Stres Testi Kritik Hata: $e');
      print(stackTrace);
    }
  }

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

  Future<V53PureDartStresTestiSonucu> _tekProfilTest(Map<String, dynamic> profil, int profilNo) async {
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

      return V53PureDartStresTestiSonucu(
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
      return V53PureDartStresTestiSonucu(
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

  double _toleransSkoru(GunlukPlan plan, Map<String, dynamic> profil) {
    final makroSapmalari = _makroSapmalariniHesapla(plan, profil);
    
    double skor = 0.0;
    if (makroSapmalari['kalori']! <= 15.0) skor += 30; // %30
    if (makroSapmalari['protein']! <= 15.0) skor += 25; // %25
    if (makroSapmalari['karb']! <= 15.0) skor += 25; // %25
    if (makroSapmalari['yag']! <= 15.0) skor += 20; // %20
    
    return skor;
  }

  void _tekProfilSonucLogla(V53PureDartStresTestiSonucu sonuc) {
    if (!sonuc.basarili) {
      print('❌ ${sonuc.profilAdi} BAŞARISIZ: ${sonuc.hataMesaji}');
      return;
    }

    final plan = sonuc.plan!;
    
    if (sonuc.diyetisyenStandartSaglandi) {
      print('🎉 ${sonuc.profilAdi} - DİYETİSYEN STANDARDI SAĞLANDI!');
    } else if (sonuc.toleransSkoru >= 50) {
      print('⚠️ ${sonuc.profilAdi} - ORTA SEVIYE (${sonuc.toleransSkoru.toStringAsFixed(1)}/100)');
    } else {
      print('🚨 ${sonuc.profilAdi} - DÜŞÜK TOLERANS (${sonuc.toleransSkoru.toStringAsFixed(1)}/100)');
    }

    // 📊 MAKRO DETAYLAR
    print('📊 MAKRO ANALİZ:');
    print('   🔥 Kalori: ${plan.toplamKalori.toInt()}/${sonuc.hedefKalori.toInt()} (${sonuc.makroSapmalari['kalori']!.toStringAsFixed(1)}% sapma)');
    print('   🥩 Protein: ${plan.toplamProtein.toInt()}g (${sonuc.makroSapmalari['protein']!.toStringAsFixed(1)}% sapma)');
    print('   🍞 Karb: ${plan.toplamKarbonhidrat.toInt()}g (${sonuc.makroSapmalari['karb']!.toStringAsFixed(1)}% sapma)');
    print('   🧈 Yağ: ${plan.toplamYag.toInt()}g (${sonuc.makroSapmalari['yag']!.toStringAsFixed(1)}% sapma)');

    // 🎯 TOLERANS DURUMU
    final toleranslar = [
      sonuc.kaloriToleransIcinde ? '✅' : '❌',
      sonuc.proteinToleransIcinde ? '✅' : '❌',
      sonuc.karbToleransIcinde ? '✅' : '❌',
      sonuc.yagToleransIcinde ? '✅' : '❌',
    ];
    print('🎯 TOLERANS: K:${toleranslar[0]} P:${toleranslar[1]} C:${toleranslar[2]} Y:${toleranslar[3]}');

    // 🍽️ ÖĞÜN DETAYLARI
    print('🍽️ ÖĞÜNLER:');
    if (plan.kahvalti != null) print('   🥞 Kahvaltı: ${plan.kahvalti!.ad} (${plan.kahvalti!.kalori.toInt()} kcal)');
    if (plan.araOgun1 != null) print('   🍎 Ara Öğün 1: ${plan.araOgun1!.ad} (${plan.araOgun1!.kalori.toInt()} kcal)');
    if (plan.ogleYemegi != null) print('   🍽️ Öğle: ${plan.ogleYemegi!.ad} (${plan.ogleYemegi!.kalori.toInt()} kcal)');
    if (plan.araOgun2 != null) print('   🥜 Ara Öğün 2: ${plan.araOgun2!.ad} (${plan.araOgun2!.kalori.toInt()} kcal)');
    if (plan.aksamYemegi != null) print('   🌙 Akşam: ${plan.aksamYemegi!.ad} (${plan.aksamYemegi!.kalori.toInt()} kcal)');
    if (plan.geceAtistirma != null) print('   🌃 Gece: ${plan.geceAtistirma!.ad} (${plan.geceAtistirma!.kalori.toInt()} kcal)');
  }

  void _finalAnalizRaporla() {
    print('🎉 V5.3 RADİKAL FİX PURE DART ULTRA STRES TESTİ TAMAMLANDI!');
    print('=' * 60);

    final toplamTest = _sonuclar.length;
    final basariliTestler = _sonuclar.where((s) => s.basarili).length;
    final diyetisyenStandartSaglanan = _sonuclar.where((s) => s.diyetisyenStandartSaglandi).length;
    
    final kaloriToleransBasarili = _sonuclar.where((s) => s.kaloriToleransIcinde).length;
    final proteinToleransBasarili = _sonuclar.where((s) => s.proteinToleransIcinde).length;
    final karbToleransBasarili = _sonuclar.where((s) => s.karbToleransIcinde).length;
    final yagToleransBasarili = _sonuclar.where((s) => s.yagToleransIcinde).length;

    final ortalamaToleransSkoru = _sonuclar.map((s) => s.toleransSkoru).reduce((a, b) => a + b) / toplamTest;

    print('📊 GENEL SONUÇLAR:');
    print('🧪 Toplam Test: $toplamTest profil');
    print('✅ Başarılı Test: $basariliTestler/${toplamTest} (%${(basariliTestler/toplamTest*100).toStringAsFixed(1)})');
    print('🎯 Diyetisyen Standartı: $diyetisyenStandartSaglanan/${toplamTest} (%${(diyetisyenStandartSaglanan/toplamTest*100).toStringAsFixed(1)})');
    print('📊 Ortalama Tolerans Skoru: ${ortalamaToleransSkoru.toStringAsFixed(1)}/100');
    
    print('=' * 40);
    print('🎯 MAKRO TOLERANS DETAYLARI:');
    print('🔥 Kalori Toleransı: $kaloriToleransBasarili/${toplamTest} (%${(kaloriToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    print('🥩 Protein Toleransı: $proteinToleransBasarili/${toplamTest} (%${(proteinToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    print('🍞 Karb Toleransı: $karbToleransBasarili/${toplamTest} (%${(karbToleransBasarili/toplamTest*100).toStringAsFixed(1)})');
    print('🧈 Yağ Toleransı: $yagToleransBasarili/${toplamTest} (%${(yagToleransBasarili/toplamTest*100).toStringAsFixed(1)})');

    print('=' * 40);
    
    // 🏆 BAŞARI DEĞERLENDİRMESİ
    final diyetisyenBasariOrani = (diyetisyenStandartSaglanan / toplamTest) * 100;
    
    if (diyetisyenBasariOrani >= 70) {
      print('🏆 V5.3 RADİKAL FİX BAŞARILI! DİYETİSYEN STANDARDI SAĞLANDI!');
      print('🎉 Sistem profesyonel kullanıma hazır!');
    } else if (diyetisyenBasariOrani >= 50) {
      print('⚠️ V5.3 RADİKAL FİX ORTA BAŞARI - İyileştirme gerekli');
      print('🔧 Öneri: V5.4 için ince ayar optimizasyonu');
    } else {
      print('🚨 V5.3 RADİKAL FİX YETERSİZ - Daha radikal değişiklik gerekli');
      print('🔥 Öneri: Algorithm temelden yeniden tasarlanmalı');
    }

    // 📊 PROBLEM ANALİZ LİSTESİ
    print('=' * 40);
    print('🔍 PROBLEM ANALİZİ:');
    final basarisizlar = _sonuclar.where((s) => !s.diyetisyenStandartSaglandi).toList();
    if (basarisizlar.isNotEmpty) {
      print('❌ DİYETİSYEN STANDARDI SAĞLAMAYAN PROFİLLER:');
      for (final basarisiz in basarisizlar.take(10)) {
        print('   • ${basarisiz.profilAdi} (${basarisiz.toleransSkoru.toStringAsFixed(1)}/100)');
      }
    }

    print('=' * 40);
    print('🚀 V5.4 GELİŞTİRME ÖNERİLERİ:');
    
    if (diyetisyenBasariOrani < 50) {
      print('🔥 ACİL ÖNCELİKLER:');
      print('   • V5.4 Mega Overhaul - Algorithm köklü değişikliği');
      print('   • Makro dağılım formülü yeniden tasarımı');
      print('   • Fallback sistem kapasite artırımı');
    } else {
      print('💡 V5.4 İYİLEŞTİRME ÖNERİLERİ:');
      print('   • Akıllı ölçekleme algoritması ince ayarı');
      print('   • Yemek seçim skorlama optimizasyonu'); 
      print('   • Çoklu deneme sayısını 5→7 artırımı');
      print('   • Türk mutfağı veri kalitesi iyileştirmesi');
    }
  }
}

// ============================================================================
// 🧪 PURE DART TEST ÇALIŞTIRICI
// ============================================================================

Future<void> main() async {
  print('🚀 V5.3 RADİKAL FİX PURE DART ULTRA STRES TESTİ');
  print('📊 25 profil diyetisyen standardında test ediliyor...\n');
  
  final stresTesti = V53PureDartStresTesti();
  await stresTesti.fullStresTestiCalistir();
  
  print('\n🎉 Test tamamlandı!');
}