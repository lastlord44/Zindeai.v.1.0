// 🔥 GERÇEK HİVE DB İLE MEGA STRES TESTİ
// Gerçek sistem ile 20 profil diyetisyen kalitesi testi

import 'dart:io';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;

// Import gerçek sistem bileşenleri
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/beslenme_plani.dart';
import '../lib/domain/usecases/makro_hesapla.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/data/datasources/yemek_hive_datasource.dart';
import '../lib/data/services/hive_service.dart';

enum TestAmacTipi {
  CUT,
  MAINTENANCE,
  LEAN_BULK,
  MEGA_BULK,
  EXTREME_CUT,
  SLOW_BULK
}

// GERÇEK SİSTEM TEST PROFİLİ
class GercekTestProfili {
  final String ad;
  final int yas;
  final double kilo;
  final double boy;
  final Cinsiyet cinsiyet;
  final AktiviteDuzeyi aktivite;
  final TestAmacTipi amac;
  final double hedefKalori;
  final double hedefProtein;
  final double hedefKarb;
  final double hedefYag;
  final List<String> yasaklar;
  final double makroToleransi;

  GercekTestProfili({
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
    this.makroToleransi = 0.15,
  });

  // Gerçek kullanıcı profiline dönüştür
  KullaniciProfili toKullaniciProfili() {
    return KullaniciProfili(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ad: ad,
      yas: yas,
      kilo: kilo,
      boy: boy,
      cinsiyet: cinsiyet,
      aktiviteDuzeyi: aktivite,
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarbonhidrat: hedefKarb,
      hedefYag: hedefYag,
      yasakliBesinler: yasaklar,
    );
  }
}

// 20 ÇEŞİTLİ TEST PROFİLİ GENERATOR
class GercekProfilGenerator {
  static List<GercekTestProfili> get20FarkliProfil() {
    return [
      // 1. EXTREME CUT - Kadın
      GercekTestProfili(
        ad: "Ayşe EXTREME CUT",
        yas: 28, kilo: 65, boy: 165,
        cinsiyet: Cinsiyet.kadin, aktivite: AktiviteDuzeyi.orta,
        amac: TestAmacTipi.EXTREME_CUT,
        hedefKalori: 1200, hedefProtein: 110, hedefKarb: 80, hedefYag: 40,
        yasaklar: ["gluten", "süt"],
        makroToleransi: 0.10,
      ),

      // 2. CUT - Erkek  
      GercekTestProfili(
        ad: "Ahmet CUT",
        yas: 32, kilo: 82, boy: 178,
        cinsiyet: Cinsiyet.erkek, aktivite: AktiviteDuzeyi.yuksek,
        amac: TestAmacTipi.CUT,
        hedefKalori: 1800, hedefProtein: 150, hedefKarb: 120, hedefYag: 60,
        yasaklar: ["şeker"],
        makroToleransi: 0.15,
      ),

      // 3. MAINTENANCE - Kadın
      GercekTestProfili(
        ad: "Fatma MAINTENANCE",
        yas: 35, kilo: 58, boy: 162,
        cinsiyet: Cinsiyet.kadin, aktivite: AktiviteDuzeyi.dusuk,
        amac: TestAmacTipi.MAINTENANCE,
        hedefKalori: 1600, hedefProtein: 95, hedefKarb: 180, hedefYag: 55,
        yasaklar: [],
        makroToleransi: 0.20,
      ),

      // 4. LEAN BULK - Erkek
      GercekTestProfili(
        ad: "Mehmet LEAN BULK",
        yas: 25, kilo: 75, boy: 180,
        cinsiyet: Cinsiyet.erkek, aktivite: AktiviteDuzeyi.cokYuksek,
        amac: TestAmacTipi.LEAN_BULK,
        hedefKalori: 2800, hedefProtein: 180, hedefKarb: 280, hedefYag: 90,
        yasaklar: [],
        makroToleransi: 0.15,
      ),

      // 5. MEGA BULK - Erkek
      GercekTestProfili(
        ad: "Emre MEGA BULK",
        yas: 22, kilo: 68, boy: 185,
        cinsiyet: Cinsiyet.erkek, aktivite: AktiviteDuzeyi.cokYuksek,
        amac: TestAmacTipi.MEGA_BULK,
        hedefKalori: 3500, hedefProtein: 220, hedefKarb: 400, hedefYag: 120,
        yasaklar: [],
        makroToleransi: 0.12,
      ),

      // 6-20 diğer profiller (kısaltılmış)
      GercekTestProfili(
        ad: "Zehra SLOW BULK", yas: 30, kilo: 52, boy: 158,
        cinsiyet: Cinsiyet.kadin, aktivite: AktiviteDuzeyi.orta,
        amac: TestAmacTipi.SLOW_BULK,
        hedefKalori: 2200, hedefProtein: 125, hedefKarb: 250, hedefYag: 75,
        yasaklar: ["fıstık"], makroToleransi: 0.15,
      ),

      GercekTestProfili(
        ad: "Hasan YAŞLI CUT", yas: 55, kilo: 90, boy: 172,
        cinsiyet: Cinsiyet.erkek, aktivite: AktiviteDuzeyi.dusuk,
        amac: TestAmacTipi.CUT,
        hedefKalori: 1600, hedefProtein: 130, hedefKarb: 100, hedefYag: 55,
        yasaklar: ["yüksek_sodyum"], makroToleransi: 0.25,
      ),

      GercekTestProfili(
        ad: "Elif GENÇ", yas: 19, kilo: 60, boy: 170,
        cinsiyet: Cinsiyet.kadin, aktivite: AktiviteDuzeyi.orta,
        amac: TestAmacTipi.MAINTENANCE,
        hedefKalori: 1900, hedefProtein: 105, hedefKarb: 220, hedefYag: 70,
        yasaklar: [], makroToleransi: 0.18,
      ),

      GercekTestProfili(
        ad: "Burak POWERLIFTER", yas: 28, kilo: 95, boy: 185,
        cinsiyet: Cinsiyet.erkek, aktivite: AktiviteDuzeyi.cokYuksek,
        amac: TestAmacTipi.MEGA_BULK,
        hedefKalori: 4200, hedefProtein: 250, hedefKarb: 500, hedefYag: 140,
        yasaklar: [], makroToleransi: 0.10,
      ),

      GercekTestProfili(
        ad: "Selin VEGAN", yas: 27, kilo: 56, boy: 164,
        cinsiyet: Cinsiyet.kadin, aktivite: AktiviteDuzeyi.orta,
        amac: TestAmacTipi.MAINTENANCE,
        hedefKalori: 1750, hedefProtein: 95, hedefKarb: 200, hedefYag: 65,
        yasaklar: ["et", "süt", "yumurta"], makroToleransi: 0.22,
      ),

      // 11-20 ek profiller (temel örnekler)
      ...List.generate(10, (index) => GercekTestProfili(
        ad: "Test Profil ${index + 11}",
        yas: 25 + (index * 3),
        kilo: 60 + (index * 5).toDouble(),
        boy: 160 + (index * 2).toDouble(),
        cinsiyet: index % 2 == 0 ? Cinsiyet.erkek : Cinsiyet.kadin,
        aktivite: AktiviteDuzeyi.values[index % AktiviteDuzeyi.values.length],
        amac: TestAmacTipi.values[index % TestAmacTipi.values.length],
        hedefKalori: 1500 + (index * 200).toDouble(),
        hedefProtein: 100 + (index * 10).toDouble(),
        hedefKarb: 150 + (index * 20).toDouble(),
        hedefYag: 50 + (index * 5).toDouble(),
        yasaklar: [],
        makroToleransi: 0.15,
      ))
    ];
  }
}

// GERÇEK SİSTEM TEST RUNNER
class GercekSistemTestRunner {
  late HiveService hiveService;
  late YemekHiveDataSource yemekDataSource;
  late AIBeslenmeServisi aiBeslenmeServisi;
  late MakroHesapla makroHesaplama;

  // Hive setup
  Future<void> initializeHive() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    // Test için geçici directory kullan
    String currentDir = Directory.current.path;
    String testHiveDir = path.join(currentDir, 'test_hive');
    
    await Hive.initFlutter(testHiveDir);
    
    // Servisleri başlat
    hiveService = HiveService();
    yemekDataSource = YemekHiveDataSource();
    aiBeslenmeServisi = AIBeslenmeServisi(yemekDataSource);
    makroHesaplama = MakroHesapla();
    
    print("✅ Hive ve servisler başlatıldı");
  }

  // Gerçek sistem ile plan oluştur
  Future<BeslenmePlani?> gercekPlanOlustur(GercekTestProfili testProfili) async {
    try {
      KullaniciProfili kullanici = testProfili.toKullaniciProfili();
      
      // AI beslenme servisi ile plan oluştur
      BeslenmePlani? plan = await aiBeslenmeServisi.gunlukPlanOlustur(
        kullanici,
        DateTime.now(),
      );
      
      return plan;
      
    } catch (e) {
      print("❌ Plan oluşturma hatası: $e");
      return null;
    }
  }

  // Diyetisyen kalitesi analizi
  Map<String, dynamic> diyetisyenAnalizi(GercekTestProfili profil, BeslenmePlani plan) {
    // Toplam makrolar hesapla
    double toplamKalori = 0;
    double toplamProtein = 0;
    double toplamKarb = 0;
    double toplamYag = 0;
    
    for (var ogun in plan.ogunler) {
      for (var yemekPortion in ogun.yemekler) {
        double porsiyon = yemekPortion.porsiyon;
        Yemek yemek = yemekPortion.yemek;
        
        toplamKalori += yemek.kalori100g * porsiyon / 100;
        toplamProtein += yemek.protein100g * porsiyon / 100;
        toplamKarb += yemek.karbonhidrat100g * porsiyon / 100;
        toplamYag += yemek.yag100g * porsiyon / 100;
      }
    }
    
    // Sapma hesapla
    double kaloriSapma = (toplamKalori - profil.hedefKalori).abs() / profil.hedefKalori;
    double proteinSapma = (toplamProtein - profil.hedefProtein).abs() / profil.hedefProtein;
    double karbSapma = (toplamKarb - profil.hedefKarb).abs() / profil.hedefKarb;
    double yagSapma = (toplamYag - profil.hedefYag).abs() / profil.hedefYag;
    
    // Tolerans kontrolü
    bool kaloriOK = kaloriSapma <= profil.makroToleransi;
    bool proteinOK = proteinSapma <= profil.makroToleransi;
    bool karbOK = karbSapma <= profil.makroToleransi;
    bool yagOK = yagSapma <= profil.makroToleransi;
    
    bool basarili = kaloriOK && proteinOK && karbOK && yagOK;
    
    // Puan hesapla
    double kaloriPuan = (1 - kaloriSapma).clamp(0, 1) * 30;
    double proteinPuan = (1 - proteinSapma).clamp(0, 1) * 25;
    double karbPuan = (1 - karbSapma).clamp(0, 1) * 25;
    double yagPuan = (1 - yagSapma).clamp(0, 1) * 20;
    
    double toplamPuan = kaloriPuan + proteinPuan + karbPuan + yagPuan;
    
    String kaliteNotu;
    if (toplamPuan >= 90) kaliteNotu = "A+ (Mükemmel)";
    else if (toplamPuan >= 80) kaliteNotu = "A (Çok İyi)";
    else if (toplamPuan >= 70) kaliteNotu = "B (İyi)";
    else if (toplamPuan >= 60) kaliteNotu = "C (Orta)";
    else if (toplamPuan >= 50) kaliteNotu = "D (Zayıf)";
    else kaliteNotu = "F (Başarısız)";
    
    return {
      'basarili': basarili,
      'toplamPuan': toplamPuan,
      'kaliteNotu': kaliteNotu,
      'toplamKalori': toplamKalori,
      'toplamProtein': toplamProtein,
      'toplamKarb': toplamKarb,
      'toplamYag': toplamYag,
      'kaloriSapma': kaloriSapma,
      'proteinSapma': proteinSapma,
      'karbSapma': karbSapma,
      'yagSapma': yagSapma,
      'kaloriOK': kaloriOK,
      'proteinOK': proteinOK,
      'karbOK': karbOK,
      'yagOK': yagOK,
      'ogunSayisi': plan.ogunler.length,
    };
  }

  // Ana test fonksiyonu
  Future<void> megaStresTestiCalistir() async {
    print("🔥 GERÇEK HİVE SİSTEMİ İLE 20 PROFİL MEGA STRES TESTİ");
    print("=" * 80);
    
    await initializeHive();
    
    List<GercekTestProfili> profiller = GercekProfilGenerator.get20FarkliProfil();
    
    int toplamTest = 0;
    int basariliTest = 0;
    List<Map<String, dynamic>> sonuclar = [];
    Map<TestAmacTipi, List<double>> amacBazindaBasari = {};
    
    for (var profil in profiller) {
      print("\n📊 TEST EDİLİYOR: ${profil.ad}");
      print("Hedef: ${profil.hedefKalori.toInt()} kcal | "
            "P:${profil.hedefProtein.toInt()}g | "
            "C:${profil.hedefKarb.toInt()}g | "
            "F:${profil.hedefYag.toInt()}g");
      
      // Gerçek sistem ile plan oluştur
      BeslenmePlani? plan = await gercekPlanOlustur(profil);
      
      if (plan == null) {
        print("❌ PLAN OLUŞTURURULAMADI");
        toplamTest++;
        sonuclar.add({
          'profil': profil.ad,
          'basarili': false,
          'puan': 0.0,
          'amac': profil.amac,
          'hata': 'plan_olusturulamadi'
        });
        continue;
      }
      
      // Diyetisyen analizi yap
      Map<String, dynamic> analiz = diyetisyenAnalizi(profil, plan);
      
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
      
      print("Gerçek: ${analiz['toplamKalori'].toInt()} kcal | "
            "P:${analiz['toplamProtein'].toInt()}g | "
            "C:${analiz['toplamKarb'].toInt()}g | "
            "F:${analiz['toplamYag'].toInt()}g");
            
      print("Sapma: Kal:%${(analiz['kaloriSapma']*100).toStringAsFixed(1)} | "
            "P:%${(analiz['proteinSapma']*100).toStringAsFixed(1)} | "
            "C:%${(analiz['karbSapma']*100).toStringAsFixed(1)} | "
            "F:%${(analiz['yagSapma']*100).toStringAsFixed(1)}");
      
      print("Öğünler (${analiz['ogunSayisi']}): ${plan.ogunler.map((o) => o.tip).join(', ')}");
      
      sonuclar.add({
        'profil': profil.ad,
        'basarili': analiz['basarili'],
        'puan': analiz['toplamPuan'],
        'amac': profil.amac,
        'kaloriSapma': analiz['kaloriSapma'],
      });
    }
    
    // FINAL İSTATİSTİKLER
    print("\n" + "=" * 80);
    print("🏆 GERÇEK SİSTEM FINAL SONUÇLAR");
    print("=" * 80);
    
    double basariOrani = (basariliTest / toplamTest) * 100;
    print("📊 GENEL BAŞARI: $basariliTest/$toplamTest (%${basariOrani.toStringAsFixed(1)})");
    
    // Amaç bazında sonuçlar
    print("\n🎯 AMAÇ BAZINDA PERFORMANS:");
    amacBazindaBasari.forEach((amac, puanlar) {
      double ortalamaPuan = puanlar.reduce((a, b) => a + b) / puanlar.length;
      int basariSayisi = puanlar.where((p) => p >= 70).length;
      double amacBasariOrani = (basariSayisi / puanlar.length) * 100;
      
      print("$amac: %${amacBasariOrani.toStringAsFixed(1)} başarı | "
            "Ort. puan: ${ortalamaPuan.toStringAsFixed(1)}/100");
    });
    
    // Diyetisyen değerlendirmesi
    print("\n👨‍⚕️ GERÇEK SİSTEM DIYETISYEN DEĞERLENDİRME:");
    if (basariOrani >= 80) {
      print("✅ MÜKEMMEL: Gerçek sistem profesyonel kalitede");
    } else if (basariOrani >= 60) {
      print("⚠️ İYI: Gerçek sistem kabul edilebilir");
    } else if (basariOrani >= 40) {
      print("❌ ORTA: Gerçek sistem ciddi sorunları var");
    } else {
      print("💀 FELAKETİ: Gerçek sistem diyetisyen standardından çok uzak");
    }
    
    await Hive.close();
  }
}

void main() async {
  GercekSistemTestRunner testRunner = GercekSistemTestRunner();
  await testRunner.megaStresTestiCalistir();
}