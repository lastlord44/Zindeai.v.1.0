// 🔥 MEGA STRES TESTİ - 20 PROFİL DİYETİSYEN KALİTESİ
// V5.3 sistemi için kapsamlı analiz ve problem detection

import 'dart:io';
import 'dart:math';

// MOCK SYSTEM - Gerçek sistem simülasyonu
class MockYemek {
  final String ad;
  final double kalori100g;
  final double protein100g;
  final double karbonhidrat100g;
  final double yag100g;
  final OgunTipi kategori;
  final String malzemeler;
  final bool ekonomik;
  final int hazirlamaSuresi;

  MockYemek({
    required this.ad,
    required this.kalori100g,
    required this.protein100g,
    required this.karbonhidrat100g,
    required this.yag100g,
    required this.kategori,
    required this.malzemeler,
    this.ekonomik = false,
    this.hazirlamaSuresi = 15,
  });

  double kaloriPorsiyon(double porsiyon) => kalori100g * porsiyon / 100;
  double proteinPorsiyon(double porsiyon) => protein100g * porsiyon / 100;
  double karbPorsiyon(double porsiyon) => karbonhidrat100g * porsiyon / 100;
  double yagPorsiyon(double porsiyon) => yag100g * porsiyon / 100;
}

enum OgunTipi {
  kahvalti,
  araOgun1,
  ogle, 
  araOgun2,
  aksam,
  geceAtistirma
}

enum AmacTipi {
  CUT,
  MAINTENANCE,
  LEAN_BULK,
  MEGA_BULK,
  EXTREME_CUT,
  SLOW_BULK
}

// GENİŞLETİLMİŞ PROFİL SİSTEMİ
class TestProfili {
  final String ad;
  final int yas;
  final double kilo;
  final double boy;
  final String cinsiyet;
  final String aktivite;
  final AmacTipi amac;
  final double hedefKalori;
  final double hedefProtein;
  final double hedefKarb;
  final double hedefYag;
  final List<String> yasaklar;
  final List<String> tercihler;
  final double makroToleransi;

  TestProfili({
    required this.ad,
    required this.yas,
    required this.kilo,
    required this.boy,
    required this.cinsiyet,
    required this.aktivite,
    required this.amac,
    required this.hedefKalori,
    required this.hedefProtein,
    required this.hedefKarb,
    required this.hedefYag,
    this.yasaklar = const [],
    this.tercihler = const [],
    this.makroToleransi = 0.15, // %15 default
  });

  double get bmr {
    if (cinsiyet == 'erkek') {
      return 88.362 + (13.397 * kilo) + (4.799 * boy) - (5.677 * yas);
    } else {
      return 447.593 + (9.247 * kilo) + (3.098 * boy) - (4.330 * yas);
    }
  }

  double get tdee {
    Map<String, double> carp = {
      'sedanter': 1.2,
      'hafif': 1.375,
      'orta': 1.55,
      'agir': 1.725,
      'cok_agir': 1.9,
    };
    return bmr * (carp[aktivite] ?? 1.55);
  }
}

// MEGA YEMEK VERİTABANI - Çeşitli kategoriler
class MegaYemekVeritabani {
  static List<MockYemek> getYemekler() {
    return [
      // 🥐 KAHVALTI - Çeşitli kalori aralıkları
      MockYemek(ad: "Menemen", kalori100g: 145, protein100g: 8.5, 
               karbonhidrat100g: 5.2, yag100g: 11.3, kategori: OgunTipi.kahvalti,
               malzemeler: "yumurta,domates,biber,soğan,tereyağ", ekonomik: true),
      
      MockYemek(ad: "Omlet", kalori100g: 154, protein100g: 10.9, 
               karbonhidrat100g: 2.1, yag100g: 11.8, kategori: OgunTipi.kahvalti,
               malzemeler: "yumurta,süt,tereyağ", ekonomik: true),
               
      MockYemek(ad: "Avokadolu Tost", kalori100g: 280, protein100g: 8.2, 
               karbonhidrat100g: 25.1, yag100g: 17.5, kategori: OgunTipi.kahvalti,
               malzemeler: "ekmek,avokado,yumurta,domates"),
               
      MockYemek(ad: "Protein Pancake", kalori100g: 220, protein100g: 22.5, 
               karbonhidrat100g: 18.2, yag100g: 6.8, kategori: OgunTipi.kahvalti,
               malzemeler: "yumurta,protein_tozu,muz,yulaf"),
               
      MockYemek(ad: "Peynirli Börek", kalori100g: 320, protein100g: 15.2, 
               karbonhidrat100g: 28.5, yag100g: 18.1, kategori: OgunTipi.kahvalti,
               malzemeler: "yufka,beyaz_peynir,yumurta,süt", ekonomik: true),

      // 🍎 ARA ÖĞÜN 1 - Metabolizma boost
      MockYemek(ad: "Muz", kalori100g: 89, protein100g: 1.1, 
               karbonhidrat100g: 22.8, yag100g: 0.3, kategori: OgunTipi.araOgun1,
               malzemeler: "muz", ekonomik: true),
               
      MockYemek(ad: "Yoğurt", kalori100g: 61, protein100g: 10.0, 
               karbonhidrat100g: 4.7, yag100g: 1.5, kategori: OgunTipi.araOgun1,
               malzemeler: "süzme_yoğurt", ekonomik: true),
               
      MockYemek(ad: "Badem", kalori100g: 579, protein100g: 21.2, 
               karbonhidrat100g: 21.6, yag100g: 49.9, kategori: OgunTipi.araOgun1,
               malzemeler: "badem"),
               
      MockYemek(ad: "Protein Bar", kalori100g: 380, protein100g: 35.0, 
               karbonhidrat100g: 25.0, yag100g: 15.2, kategori: OgunTipi.araOgun1,
               malzemeler: "protein_tozu,hurma,badem"),
               
      MockYemek(ad: "Elma + Fıstık Ezmesi", kalori100g: 195, protein100g: 5.8, 
               karbonhidrat100g: 18.5, yag100g: 11.2, kategori: OgunTipi.araOgun1,
               malzemeler: "elma,fıstık_ezmesi"),

      // 🍛 ÖĞLE - Ana öğün çeşitliliği
      MockYemek(ad: "Izgara Tavuk + Pilav", kalori100g: 185, protein100g: 25.8, 
               karbonhidrat100g: 18.2, yag100g: 3.2, kategori: OgunTipi.ogle,
               malzemeler: "tavuk_göğsü,pirinç,tereyağ", ekonomik: true),
               
      MockYemek(ad: "Kuru Fasulye", kalori100g: 160, protein100g: 12.5, 
               karbonhidrat100g: 22.8, yag100g: 2.8, kategori: OgunTipi.ogle,
               malzemeler: "fasulye,soğan,domates,zeytinyağ", ekonomik: true),
               
      MockYemek(ad: "Somon + Quinoa", kalori100g: 220, protein100g: 28.5, 
               karbonhidrat100g: 15.2, yag100g: 6.8, kategori: OgunTipi.ogle,
               malzemeler: "somon,quinoa,sebze"),
               
      MockYemek(ad: "Köfte + Bulgur", kalori100g: 245, protein100g: 18.2, 
               karbonhidrat100g: 28.5, yag100g: 8.5, kategori: OgunTipi.ogle,
               malzemeler: "dana_kıyma,bulgur,soğan,baharat", ekonomik: true),
               
      MockYemek(ad: "Makarna Bolonez", kalori100g: 168, protein100g: 8.2, 
               karbonhidrat100g: 25.8, yag100g: 4.2, kategori: OgunTipi.ogle,
               malzemeler: "makarna,dana_kıyma,domates,zeytinyağ", ekonomik: true),

      // 🥨 ARA ÖĞÜN 2 - Akşam öncesi
      MockYemek(ad: "Hummus + Havuç", kalori100g: 125, protein100g: 5.2, 
               karbonhidrat100g: 15.8, yag100g: 4.8, kategori: OgunTipi.araOgun2,
               malzemeler: "nohut,havuç,tahin,limon"),
               
      MockYemek(ad: "Kefir", kalori100g: 41, protein100g: 3.4, 
               karbonhidrat100g: 4.7, yag100g: 1.0, kategori: OgunTipi.araOgun2,
               malzemeler: "kefir", ekonomik: true),
               
      MockYemek(ad: "Ceviz + Kuru Üzüm", kalori100g: 385, protein100g: 8.5, 
               karbonhidrat100g: 42.8, yag100g: 20.2, kategori: OgunTipi.araOgun2,
               malzemeler: "ceviz,kuru_üzüm"),
               
      MockYemek(ad: "Smoothie Bowl", kalori100g: 95, protein100g: 4.2, 
               karbonhidrat100g: 18.5, yag100g: 1.8, kategori: OgunTipi.araOgun2,
               malzemeler: "muz,yaban_mersini,yoğurt,granola"),
               
      MockYemek(ad: "Protein Shake", kalori100g: 145, protein100g: 28.0, 
               karbonhidrat100g: 5.2, yag100g: 1.5, kategori: OgunTipi.araOgun2,
               malzemeler: "protein_tozu,süt,muz"),

      // 🍽️ AKŞAM - Hafif ama doyurucu
      MockYemek(ad: "Balık + Sebze", kalori100g: 125, protein100g: 22.5, 
               karbonhidrat100g: 8.2, yag100g: 2.8, kategori: OgunTipi.aksam,
               malzemeler: "levrek,brokoli,havuç,zeytinyağ"),
               
      MockYemek(ad: "Omlet + Salata", kalori100g: 98, protein100g: 8.5, 
               karbonhidrat100g: 4.2, yag100g: 6.8, kategori: OgunTipi.aksam,
               malzemeler: "yumurta,salata_yeşillikleri,domates,zeytinyağ", ekonomik: true),
               
      MockYemek(ad: "Hindi Sote", kalori100g: 145, protein100g: 24.2, 
               karbonhidrat100g: 8.5, yag100g: 3.2, kategori: OgunTipi.aksam,
               malzemeler: "hindi,sebze_karışımı,zeytinyağ"),
               
      MockYemek(ad: "Mercimek Çorbası", kalori100g: 85, protein100g: 6.2, 
               karbonhidrat100g: 15.8, yag100g: 0.8, kategori: OgunTipi.aksam,
               malzemeler: "mercimek,soğan,havuç,tereyağ", ekonomik: true),
               
      MockYemek(ad: "Sebzeli Tavuk", kalori100g: 135, protein100g: 21.8, 
               karbonhidrat100g: 6.5, yag100g: 3.8, kategori: OgunTipi.aksam,
               malzemeler: "tavuk_göğsü,kabak,patlıcan,domates", ekonomik: true),

      // 🌙 GECE ATIŞTİRMA - Metabolizma desteği
      MockYemek(ad: "Kazetin", kalori100g: 115, protein100g: 24.0, 
               karbonhidrat100g: 2.5, yag100g: 1.2, kategori: OgunTipi.geceAtistirma,
               malzemeler: "kazein_protein,süt"),
               
      MockYemek(ad: "Süzme Yoğurt", kalori100g: 83, protein100g: 15.2, 
               karbonhidrat100g: 4.8, yag100g: 0.8, kategori: OgunTipi.geceAtistirma,
               malzemeler: "süzme_yoğurt", ekonomik: true),
               
      MockYemek(ad: "Badem + Süt", kalori100g: 165, protein100g: 8.5, 
               karbonhidrat100g: 8.2, yag100g: 12.5, kategori: OgunTipi.geceAtistirma,
               malzemeler: "badem,süt"),
               
      MockYemek(ad: "Cottage Cheese", kalori100g: 98, protein100g: 11.1, 
               karbonhidrat100g: 3.4, yag100g: 4.3, kategori: OgunTipi.geceAtistirma,
               malzemeler: "cottage_peynir"),
               
      MockYemek(ad: "Fıstık Ezmesi", kalori100g: 520, protein100g: 22.5, 
               karbonhidrat100g: 18.8, yag100g: 42.8, kategori: OgunTipi.geceAtistirma,
               malzemeler: "fıstık"),
    ];
  }
}

// GELİŞMİŞ PLAN YAPISI
class MockPlan {
  Map<OgunTipi, List<MockPorsiyonluYemek>> ogunler = {};
  double toplamKalori = 0;
  double toplamProtein = 0;
  double toplamKarb = 0;
  double toplamYag = 0;

  void ekleYemek(OgunTipi ogun, MockYemek yemek, double porsiyon) {
    if (!ogunler.containsKey(ogun)) {
      ogunler[ogun] = [];
    }
    
    ogunler[ogun]!.add(MockPorsiyonluYemek(yemek: yemek, porsiyon: porsiyon));
    
    toplamKalori += yemek.kaloriPorsiyon(porsiyon);
    toplamProtein += yemek.proteinPorsiyon(porsiyon);
    toplamKarb += yemek.karbPorsiyon(porsiyon);
    toplamYag += yemek.yagPorsiyon(porsiyon);
  }
}

class MockPorsiyonluYemek {
  final MockYemek yemek;
  final double porsiyon;

  MockPorsiyonluYemek({required this.yemek, required this.porsiyon});
}

// ULTRA GELİŞMİŞ AI SİSTEMİ
class UltraAkilliBeslenmeServisi {
  static final Random _random = Random();
  static final List<MockYemek> _yemekler = MegaYemekVeritabani.getYemekler();

  // AKILLI YEMEK SECICI - Kategori ve hedef bazli
  static List<MockYemek> akilliYemekSec(OgunTipi ogunTipi,
                                       AmacTipi amac,
                                       double hedefKalori,
                                       List<String> yasaklar) {
    
    var uygunYemekler = _yemekler.where((yemek) {
      // Kategori kontrolü
      if (yemek.kategori != ogunTipi) return false;
      
      // Yasak kontrolü
      for (String yasak in yasaklar) {
        if (yemek.malzemeler.contains(yasak)) return false;
      }
      
      // Amaç bazlı filtreleme
      switch (amac) {
        case AmacTipi.CUT:
        case AmacTipi.EXTREME_CUT:
          return yemek.kalori100g < 200; // Düşük kalori
        case AmacTipi.LEAN_BULK:
          return yemek.protein100g > 15; // Yüksek protein
        case AmacTipi.MEGA_BULK:
          return yemek.kalori100g > 150; // Yüksek kalori
        default:
          return true; // MAINTENANCE - hepsi uygun
      }
    }).toList();

    if (uygunYemekler.isEmpty) {
      uygunYemekler = _yemekler.where((y) => y.kategori == ogunTipi).toList();
    }

    return uygunYemekler;
  }

  // MEGA BULK İÇİN ÖZEL ALGORİTMA
  static double megaBulkPorsiyonHesapla(MockYemek yemek, double hedefKalori, OgunTipi ogun) {
    Map<OgunTipi, double> ogunDagilimi = {
      OgunTipi.kahvalti: 0.25,
      OgunTipi.araOgun1: 0.10,
      OgunTipi.ogle: 0.30,
      OgunTipi.araOgun2: 0.15,
      OgunTipi.aksam: 0.20,
      OgunTipi.geceAtistirma: 0.10,
    };

    double ogunHedefi = hedefKalori * (ogunDagilimi[ogun] ?? 0.2);
    double basePorsiyon = (ogunHedefi / yemek.kalori100g) * 100;
    
    // Mega bulk için ekstra ölçekleme
    if (hedefKalori > 3000) {
      basePorsiyon *= 1.3; // %30 artır
    }
    
    return basePorsiyon.clamp(50, 400); // Min 50g, Max 400g
  }

  // AKILLI PLAN OLUŞTURMA
  static MockPlan planOlustur(TestProfili profil) {
    MockPlan plan = MockPlan();
    
    Map<OgunTipi, double> ogunDagilimi = {
      OgunTipi.kahvalti: 0.25,
      OgunTipi.araOgun1: 0.10,
      OgunTipi.ogle: 0.30,
      OgunTipi.araOgun2: 0.15,
      OgunTipi.aksam: 0.20,
      OgunTipi.geceAtistirma: 0.10,
    };

    for (OgunTipi ogun in OgunTipi.values) {
      double ogunHedefi = profil.hedefKalori * (ogunDagilimi[ogun] ?? 0.2);
      
      // Uygun yemekleri getir
      var uygunYemekler = akilliYemekSec(ogun, profil.amac, ogunHedefi, profil.yasaklar);
      
      if (uygunYemekler.isNotEmpty) {
        MockYemek secilenYemek = uygunYemekler[_random.nextInt(uygunYemekler.length)];
        
        double porsiyon;
        if (profil.amac == AmacTipi.MEGA_BULK) {
          porsiyon = megaBulkPorsiyonHesapla(secilenYemek, profil.hedefKalori, ogun);
        } else {
          porsiyon = (ogunHedefi / secilenYemek.kalori100g) * 100;
          porsiyon = porsiyon.clamp(50, 350);
        }
        
        plan.ekleYemek(ogun, secilenYemek, porsiyon);
      }
    }

    return plan;
  }
}

// PROFESYONEL DİYETİSYEN ANALİZ SİSTEMİ
class DiyetisyenKaliteAnalizi {
  
  static Map<String, dynamic> diyetisyenAnalizYap(TestProfili profil, MockPlan plan) {
    // Makro analizi
    double kaloriSapma = ((plan.toplamKalori - profil.hedefKalori).abs() / profil.hedefKalori);
    double proteinSapma = ((plan.toplamProtein - profil.hedefProtein).abs() / profil.hedefProtein);
    double karbSapma = ((plan.toplamKarb - profil.hedefKarb).abs() / profil.hedefKarb);
    double yagSapma = ((plan.toplamYag - profil.hedefYag).abs() / profil.hedefYag);

    // Tolerans kontrolü
    bool kaloriOK = kaloriSapma <= profil.makroToleransi;
    bool proteinOK = proteinSapma <= profil.makroToleransi;
    bool karbOK = karbSapma <= profil.makroToleransi;
    bool yagOK = yagSapma <= profil.makroToleransi;

    // Genel başarı
    bool basarili = kaloriOK && proteinOK && karbOK && yagOK;

    // Puan hesaplama (diyetisyen standardı)
    double kaloriPuan = (1 - kaloriSapma).clamp(0, 1) * 30;
    double proteinPuan = (1 - proteinSapma).clamp(0, 1) * 25;
    double karbPuan = (1 - karbSapma).clamp(0, 1) * 25;
    double yagPuan = (1 - yagSapma).clamp(0, 1) * 20;

    double toplamPuan = kaloriPuan + proteinPuan + karbPuan + yagPuan;

    // Diyetisyen kalite değerlendirmesi
    String kaliteNotu;
    if (toplamPuan >= 90) kaliteNotu = "A+ (Mükemmel)";
    else if (toplamPuan >= 80) kaliteNotu = "A (Çok İyi)";
    else if (toplamPuan >= 70) kaliteNotu = "B (İyi)";
    else if (toplamPuan >= 60) kaliteNotu = "C (Orta)";
    else if (toplamPuan >= 50) kaliteNotu = "D (Zayıf)";
    else kaliteNotu = "F (Başarısız)";

    // Öğün çeşitliliği analizi
    int ogunSayisi = plan.ogunler.length;
    bool tumOgunlerVar = ogunSayisi == 6;

    return {
      'basarili': basarili,
      'toplamPuan': toplamPuan,
      'kaliteNotu': kaliteNotu,
      'kaloriSapma': kaloriSapma,
      'proteinSapma': proteinSapma,
      'karbSapma': karbSapma,
      'yagSapma': yagSapma,
      'kaloriOK': kaloriOK,
      'proteinOK': proteinOK,
      'karbOK': karbOK,
      'yagOK': yagOK,
      'ogunSayisi': ogunSayisi,
      'tumOgunlerVar': tumOgunlerVar,
    };
  }
}

// 20 ÇEŞİT PROFİL SİSTEMİ
class MegaProfilGenerator {
  static List<TestProfili> get20FarkliProfil() {
    return [
      // 1. EXTREME CUT - Kadın
      TestProfili(
        ad: "Ayşe EXTREME CUT",
        yas: 28, kilo: 65, boy: 165,
        cinsiyet: "kadın", aktivite: "orta",
        amac: AmacTipi.EXTREME_CUT,
        hedefKalori: 1200, hedefProtein: 110, hedefKarb: 80, hedefYag: 40,
        yasaklar: ["gluten", "süt"],
        makroToleransi: 0.10, // %10 çok sıkı
      ),

      // 2. CUT - Erkek
      TestProfili(
        ad: "Ahmet CUT",
        yas: 32, kilo: 82, boy: 178,
        cinsiyet: "erkek", aktivite: "agir",
        amac: AmacTipi.CUT,
        hedefKalori: 1800, hedefProtein: 150, hedefKarb: 120, hedefYag: 60,
        yasaklar: ["şeker"],
        makroToleransi: 0.15, // %15 normal
      ),

      // 3. MAINTENANCE - Kadın
      TestProfili(
        ad: "Fatma MAINTENANCE",
        yas: 35, kilo: 58, boy: 162,
        cinsiyet: "kadın", aktivite: "hafif",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 1600, hedefProtein: 95, hedefKarb: 180, hedefYag: 55,
        yasaklar: [],
        makroToleransi: 0.20, // %20 esnek
      ),

      // 4. LEAN BULK - Erkek
      TestProfili(
        ad: "Mehmet LEAN BULK",
        yas: 25, kilo: 75, boy: 180,
        cinsiyet: "erkek", aktivite: "cok_agir",
        amac: AmacTipi.LEAN_BULK,
        hedefKalori: 2800, hedefProtein: 180, hedefKarb: 280, hedefYag: 90,
        yasaklar: [],
        makroToleransi: 0.15,
      ),

      // 5. MEGA BULK - Erkek
      TestProfili(
        ad: "Emre MEGA BULK",
        yas: 22, kilo: 68, boy: 185,
        cinsiyet: "erkek", aktivite: "cok_agir",
        amac: AmacTipi.MEGA_BULK,
        hedefKalori: 3500, hedefProtein: 220, hedefKarb: 400, hedefYag: 120,
        yasaklar: [],
        makroToleransi: 0.12, // %12 sıkı
      ),

      // 6. SLOW BULK - Kadın
      TestProfili(
        ad: "Zehra SLOW BULK",
        yas: 30, kilo: 52, boy: 158,
        cinsiyet: "kadın", aktivite: "orta",
        amac: AmacTipi.SLOW_BULK,
        hedefKalori: 2200, hedefProtein: 125, hedefKarb: 250, hedefYag: 75,
        yasaklar: ["fıstık"],
        makroToleransi: 0.15,
      ),

      // 7. CUT - Yaşlı Erkek
      TestProfili(
        ad: "Hasan YAŞLI CUT",
        yas: 55, kilo: 90, boy: 172,
        cinsiyet: "erkek", aktivite: "hafif",
        amac: AmacTipi.CUT,
        hedefKalori: 1600, hedefProtein: 130, hedefKarb: 100, hedefYag: 55,
        yasaklar: ["yüksek_sodyum"],
        makroToleransi: 0.25, // %25 esnek yaş faktörü
      ),

      // 8. MAINTENANCE - Genç Kadın
      TestProfili(
        ad: "Elif GENÇ",
        yas: 19, kilo: 60, boy: 170,
        cinsiyet: "kadın", aktivite: "orta",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 1900, hedefProtein: 105, hedefKarb: 220, hedefYag: 70,
        yasaklar: [],
        makroToleransi: 0.18,
      ),

      // 9. EXTREME BULK - Ağır Atlet
      TestProfili(
        ad: "Burak POWERLIFTER",
        yas: 28, kilo: 95, boy: 185,
        cinsiyet: "erkek", aktivite: "cok_agir",
        amac: AmacTipi.MEGA_BULK,
        hedefKalori: 4200, hedefProtein: 250, hedefKarb: 500, hedefYag: 140,
        yasaklar: [],
        makroToleransi: 0.10, // %10 çok sıkı atlet
      ),

      // 10. MAINTENANCE - Vegan
      TestProfili(
        ad: "Selin VEGAN",
        yas: 27, kilo: 56, boy: 164,
        cinsiyet: "kadın", aktivite: "orta",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 1750, hedefProtein: 95, hedefKarb: 200, hedefYag: 65,
        yasaklar: ["et", "süt", "yumurta"],
        makroToleransi: 0.22, // %22 vegan zorluk
      ),

      // 11. CUT - Endomorph
      TestProfili(
        ad: "Kadir ENDOMORPH CUT",
        yas: 40, kilo: 95, boy: 175,
        cinsiyet: "erkek", aktivite: "orta",
        amac: AmacTipi.CUT,
        hedefKalori: 1700, hedefProtein: 160, hedefKarb: 90, hedefYag: 60,
        yasaklar: ["işlenmiş_karbonhidrat"],
        makroToleransi: 0.12, // %12 endomorph sıkı
      ),

      // 12. LEAN BULK - Ektomorf
      TestProfili(
        ad: "Cem EKTOMORF BULK",
        yas: 24, kilo: 62, boy: 182,
        cinsiyet: "erkek", aktivite: "agir",
        amac: AmacTipi.LEAN_BULK,
        hedefKalori: 3200, hedefProtein: 185, hedefKarb: 380, hedefYag: 105,
        yasaklar: [],
        makroToleransi: 0.15,
      ),

      // 13. MAINTENANCE - Hamile
      TestProfili(
        ad: "Nurcan HAMİLE",
        yas: 29, kilo: 72, boy: 166,
        cinsiyet: "kadın", aktivite: "hafif",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 2100, hedefProtein: 120, hedefKarb: 260, hedefYag: 75,
        yasaklar: ["alkol", "kafein"],
        makroToleransi: 0.25, // %25 hamilelik esnekliği
      ),

      // 14. CUT - Diyabetik
      TestProfili(
        ad: "Ali DİYABETİK CUT",
        yas: 48, kilo: 88, boy: 173,
        cinsiyet: "erkek", aktivite: "hafif",
        amac: AmacTipi.CUT,
        hedefKalori: 1500, hedefProtein: 140, hedefKarb: 80, hedefYag: 55,
        yasaklar: ["şeker", "beyaz_un"],
        makroToleransi: 0.08, // %8 çok sıkı diyabetik
      ),

      // 15. BULK - Genç Sporcu
      TestProfili(
        ad: "Yusuf GENÇ SPORCU",
        yas: 17, kilo: 65, boy: 178,
        cinsiyet: "erkek", aktivite: "cok_agir",
        amac: AmacTipi.LEAN_BULK,
        hedefKalori: 3400, hedefProtein: 200, hedefKarb: 420, hedefYag: 110,
        yasaklar: [],
        makroToleransi: 0.18, // %18 genç esnek
      ),

      // 16. MAINTENANCE - Menopoz
      TestProfili(
        ad: "Gülsün MENOPOZ",
        yas: 52, kilo: 68, boy: 160,
        cinsiyet: "kadın", aktivite: "hafif",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 1450, hedefProtein: 105, hedefKarb: 140, hedefYag: 55,
        yasaklar: ["aşırı_tuz"],
        makroToleransi: 0.30, // %30 menopoz esnekliği
      ),

      // 17. EXTREME BULK - Hardgainer
      TestProfili(
        ad: "Deniz HARDGAINER",
        yas: 21, kilo: 58, boy: 180,
        cinsiyet: "erkek", aktivite: "cok_agir",
        amac: AmacTipi.MEGA_BULK,
        hedefKalori: 3800, hedefProtein: 230, hedefKarb: 450, hedefYag: 125,
        yasaklar: [],
        makroToleransi: 0.20, // %20 hardgainer esnek
      ),

      // 18. CUT - Kadın Sporcu
      TestProfili(
        ad: "Pınar KADIN SPORCU CUT",
        yas: 26, kilo: 63, boy: 168,
        cinsiyet: "kadın", aktivite: "cok_agir",
        amac: AmacTipi.CUT,
        hedefKalori: 1600, hedefProtein: 135, hedefKarb: 120, hedefYag: 50,
        yasaklar: [],
        makroToleransi: 0.12, // %12 sporcu sıkı
      ),

      // 19. BULK - Beslenme Bozukluğu Geçmişi
      TestProfili(
        ad: "Merve REHABİLİTASYON",
        yas: 23, kilo: 48, boy: 163,
        cinsiyet: "kadın", aktivite: "hafif",
        amac: AmacTipi.SLOW_BULK,
        hedefKalori: 2000, hedefProtein: 110, hedefKarb: 240, hedefYag: 70,
        yasaklar: [],
        makroToleransi: 0.35, // %35 çok esnek rehabilitasyon
      ),

      // 20. MAINTENANCE - Düzenli Yaşam
      TestProfili(
        ad: "Okan DÜZENLI YAŞAM",
        yas: 35, kilo: 78, boy: 175,
        cinsiyet: "erkek", aktivite: "orta",
        amac: AmacTipi.MAINTENANCE,
        hedefKalori: 2300, hedefProtein: 130, hedefKarb: 270, hedefYag: 85,
        yasaklar: [],
        makroToleransi: 0.15, // %15 standart
      ),
    ];
  }
}

// MAIN TEST RUNNER
void main() async {
  print("🔥 20 PROFİL MEGA STRES TESTİ BAŞLATIILIYOR");
  print("" + "="*80);
  
  List<TestProfili> profiller = MegaProfilGenerator.get20FarkliProfil();
  
  int toplamTest = 0;
  int basariliTest = 0;
  List<Map<String, dynamic>> detayliSonuclar = [];
  
  Map<AmacTipi, List<double>> amacBazindaBasari = {};
  
  for (var profil in profiller) {
    print("\n📊 TEST EDİLİYOR: ${profil.ad}");
    print("Hedef: ${profil.hedefKalori.toInt()} kcal | "
          "P:${profil.hedefProtein.toInt()}g | "
          "C:${profil.hedefKarb.toInt()}g | "
          "F:${profil.hedefYag.toInt()}g");
    
    // Plan oluştur
    MockPlan plan = UltraAkilliBeslenmeServisi.planOlustur(profil);
    
    // Diyetisyen analizi
    Map<String, dynamic> analiz = DiyetisyenKaliteAnalizi.diyetisyenAnalizYap(profil, plan);
    
    toplamTest++;
    if (analiz['basarili']) basariliTest++;
    
    // Amaç bazında istatistik
    if (!amacBazindaBasari.containsKey(profil.amac)) {
      amacBazindaBasari[profil.amac] = [];
    }
    amacBazindaBasari[profil.amac]!.add(analiz['toplamPuan']);
    
    // Sonuç yazdır
    String durum = analiz['basarili'] ? "✅ BAŞARILI" : "❌ BAŞARISIZ";
    print("$durum - Puan: ${analiz['toplamPuan'].toStringAsFixed(1)}/100 (${analiz['kaliteNotu']})");
    
    print("Gerçek: ${plan.toplamKalori.toInt()} kcal | "
          "P:${plan.toplamProtein.toInt()}g | "
          "C:${plan.toplamKarb.toInt()}g | "
          "F:${plan.toplamYag.toInt()}g");
          
    print("Sapma: Kal:%${(analiz['kaloriSapma']*100).toStringAsFixed(1)} | "
          "P:%${(analiz['proteinSapma']*100).toStringAsFixed(1)} | "
          "C:%${(analiz['karbSapma']*100).toStringAsFixed(1)} | "
          "F:%${(analiz['yagSapma']*100).toStringAsFixed(1)}");
    
    // Öğün detayları
    print("Öğünler (${analiz['ogunSayisi']}/6):");
    plan.ogunler.forEach((ogun, yemekler) {
      for (var py in yemekler) {
        print("  $ogun: ${py.yemek.ad} (${py.porsiyon.toInt()}g)");
      }
    });
    
    detayliSonuclar.add({
      'profil': profil.ad,
      'basarili': analiz['basarili'],
      'puan': analiz['toplamPuan'],
      'amac': profil.amac,
      'kaloriSapma': analiz['kaloriSapma'],
    });
  }
  
  // FINAL İSTATİSTİKLER
  print("\n" + "="*80);
  print("🏆 FINAL SONUÇLAR - MEGA STRES TESTİ");
  print("="*80);
  
  double basariOrani = (basariliTest / toplamTest) * 100;
  print("📊 GENEL BAŞARI: $basariliTest/$toplamTest (%${basariOrani.toStringAsFixed(1)})");
  
  // Amaç bazında sonuçlar
  print("\n🎯 AMAÇ BAZINDA PERFORMANS:");
  amacBazindaBasari.forEach((amac, puanlar) {
    double ortalamaPuan = puanlar.reduce((a, b) => a + b) / puanlar.length;
    int basariSayisi = puanlar.where((p) => p >= 70).length; // 70+ başarılı
    double amacBasariOrani = (basariSayisi / puanlar.length) * 100;
    
    print("$amac: %${amacBasariOrani.toStringAsFixed(1)} başarı | "
          "Ort. puan: ${ortalamaPuan.toStringAsFixed(1)}/100");
  });
  
  // En başarılı ve başarısız profiller
  detayliSonuclar.sort((a, b) => b['puan'].compareTo(a['puan']));
  
  print("\n🥇 EN BAŞARILI 5 PROFİL:");
  for (int i = 0; i < 5 && i < detayliSonuclar.length; i++) {
    var sonuc = detayliSonuclar[i];
    print("${i+1}. ${sonuc['profil']} - ${sonuc['puan'].toStringAsFixed(1)} puan");
  }
  
  print("\n🥴 EN SORUNLU 5 PROFİL:");
  for (int i = detayliSonuclar.length - 5; i < detayliSonuclar.length; i++) {
    if (i >= 0) {
      var sonuc = detayliSonuclar[i];
      print("${detayliSonuclar.length - i}. ${sonuc['profil']} - ${sonuc['puan'].toStringAsFixed(1)} puan");
    }
  }
  
  // KRİTİK SORUN ANALİZİ
  print("\n🔍 DETECTED PROBLEMS:");
  int yuksekKaloriBasarisiz = detayliSonuclar
      .where((s) => s['amac'] == AmacTipi.MEGA_BULK && !s['basarili'])
      .length;
  
  if (yuksekKaloriBasarisiz > 0) {
    print("⚠️  MEGA BULK profillerde yüksek başarısızlık ($yuksekKaloriBasarisiz)");
  }
  
  int yuksekSapma = detayliSonuclar
      .where((s) => s['kaloriSapma'] > 0.25)
      .length;
  
  if (yuksekSapma > 0) {
    print("⚠️  %25+ kalori sapması olan profil sayısı: $yuksekSapma");
  }
  
  // DIYETISYEN GENEL DEĞERLENDIRME
  print("\n👨‍⚕️ DIYETISYEN PROFESYONEL DEĞERLENDİRME:");
  if (basariOrani >= 80) {
    print("✅ MÜKEMMEL: Sistem diyetisyen standardında çalışıyor");
  } else if (basariOrani >= 60) {
    print("⚠️ İYİ: Sistem kabul edilebilir, ince ayar gerekli"); 
  } else if (basariOrani >= 40) {
    print("❌ ORTA: Ciddi iyileştirmeler gerekli");
  } else {
    print("💀 ZAYIF: Sistem diyetisyen standardından uzak");
  }
  
  print("\n🔧 ÖNERİLER:");
  if (yuksekKaloriBasarisiz > 2) {
    print("• Mega bulk algoritması geliştirilmeli");
  }
  if (yuksekSapma > 5) {
    print("• Porsiyon hesaplama sistemi optimize edilmeli");
  }
  print("• Fallback yemek havuzu genişletilmeli");
  print("• Amaç-spesifik tolerans sistemi uygulanmalı");
  
  print("\n🎯 SONUÇ: Test tamamlandı. Sistem performansı analiz edildi.");
}