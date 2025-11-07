import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/services/haftalik_plan_servisi.dart';
import '../lib/domain/services/makro_hesaplayici.dart';
import '../lib/data/datasources/yemek_hive_datasource.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/utils/hive_service.dart';

/// 🔥 20 PROFİL MEGA STRES TESTİ - DİYETİSYEN KALİTESİ ANALİZİ
/// 
/// Bu test 20 farklı profil ile haftalık plan sisteminin:
/// ✅ Diyetisyen seviyesinde doğruluk
/// ✅ Ara öğün mantığı
/// ✅ Makro tolerans dengesi 
/// ✅ Çeşitlilik ve pratiklik
/// 
/// Testini yapar.

void main() {
  group('🎯 20 PROFİL MEGA STRES TESTİ', () {
    late HaftalikPlanServisi haftalikPlanServisi;
    late YemekHiveDataSource yemekDataSource;
    late HiveService hiveService;
    
    setUpAll(() async {
      // Hive test ortamı
      var path = Directory.current.path;
      Hive.init('$path/test_hive');
      
      Hive.registerAdapter(YemekHiveModelAdapter());
      
      await Hive.openBox<YemekHiveModel>('yemekler');
      
      // Servisleri initialize et
      hiveService = HiveService();
      yemekDataSource = YemekHiveDataSource();
      haftalikPlanServisi = HaftalikPlanServisi(yemekDataSource);
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('🔥 20 PROFİL DİYETİSYEN KALİTESİ STRES TESTİ', () async {
      print('\n🎯 20 PROFİL MEGA STRES TESTİ BAŞLADI\n');
      print('=' * 60);
      
      // Test istatistikleri
      int basariliProfiller = 0;
      int toplamProfiller = 0;
      List<String> problemliProfiller = [];
      List<String> mukemmelProfiller = [];
      
      // 20 TEST PROFİLİ - Çok çeşitli demografik
      final testProfilleri = _20TestProfiliOlustur();
      
      for (final profilData in testProfilleri) {
        toplamProfiller++;
        final profilAdi = profilData[0] as String;
        
        try {
          print('\n🔍 PROFİL ${toplamProfiller}: $profilAdi');
          print('-' * 40);
          
          // Profil oluştur
          final profil = _profilOlustur(profilData);
          print('   📊 Hedef: ${profil.gunlukKaloriHedefi} kcal');
          print('   🎯 P:${profil.gunlukProteinHedefi}g | K:${profil.gunlukKarbonhidratHedefi}g | Y:${profil.gunlukYagHedefi}g');
          
          // Haftalık plan oluştur
          final haftalikPlan = await haftalikPlanServisi.haftalikPlanOlustur(profil);
          
          if (haftalikPlan.gunlukPlanlar.isEmpty) {
            print('   ❌ Plan oluşturulamadı!');
            problemliProfiller.add('$profilAdi - Plan boş');
            continue;
          }
          
          // Günlük planları analiz et
          bool profilBasarili = true;
          List<String> profilSorunlari = [];
          double toplamDayaniklilik = 0.0;
          
          for (int gun = 0; gun < haftalikPlan.gunlukPlanlar.length; gun++) {
            final gunlukPlan = haftalikPlan.gunlukPlanlar[gun];
            final analiz = await _gunlukPlanAnalizi(gunlukPlan, profil, gun + 1);
            
            toplamDayaniklilik += analiz['dayaniklilik'] as double;
            
            if (!(analiz['basarili'] as bool)) {
              profilBasarili = false;
              profilSorunlari.addAll(analiz['sorunlar'] as List<String>);
            }
          }
          
          // Profil sonucu
          double ortalamaDayaniklilik = toplamDayaniklilik / haftalikPlan.gunlukPlanlar.length;
          
          if (profilBasarili && ortalamaDayaniklilik >= 0.85) {
            basariliProfiller++;
            mukemmelProfiller.add('$profilAdi (${(ortalamaDayaniklilik*100).toStringAsFixed(1)}% doğruluk)');
            print('   ✅ BAŞARILI - Dayanıklılık: ${(ortalamaDayaniklilik*100).toStringAsFixed(1)}%');
          } else {
            problemliProfiller.add('$profilAdi - Dayanıklılık: ${(ortalamaDayaniklilik*100).toStringAsFixed(1)}%');
            print('   ❌ PROBLEMLİ - Dayanıklılık: ${(ortalamaDayaniklilik*100).toStringAsFixed(1)}%');
            for (final sorun in profilSorunlari) {
              print('      • $sorun');
            }
          }
          
        } catch (e) {
          print('   💥 HATA: $e');
          problemliProfiller.add('$profilAdi - Sistem hatası: $e');
        }
      }
      
      // FINAL RAPORU
      print('\n' + '=' * 60);
      print('🎯 STRES TESTİ SONUÇLARI');
      print('=' * 60);
      print('📊 Toplam Profil: $toplamProfiller');
      print('✅ Başarılı: $basariliProfiller');
      print('❌ Problemli: ${toplamProfiller - basariliProfiller}');
      print('🔥 BAŞARI ORANI: ${(basariliProfiller/toplamProfiller*100).toStringAsFixed(1)}%');
      
      if (mukemmelProfiller.isNotEmpty) {
        print('\n🏆 MÜKEMMEL PROFİLLER:');
        for (final profil in mukemmelProfiller) {
          print('   ✅ $profil');
        }
      }
      
      if (problemliProfiller.isNotEmpty) {
        print('\n⚠️ PROBLEMLİ PROFİLLER:');
        for (final profil in problemliProfiller) {
          print('   ❌ $profil');
        }
      }
      
      print('\n' + '=' * 60);
      
      // Minimum %75 başarı oranı bekliyoruz (V6.0 sistemi için)
      expect(basariliProfiller / toplamProfiller, greaterThanOrEqualTo(0.75),
          reason: 'Stres testi başarı oranı %75\'in altında: ${(basariliProfiller/toplamProfiller*100).toStringAsFixed(1)}%');
    });
  });
}

/// 20 çeşitli test profili - demografik çeşitlilik maksimum
List<List<dynamic>> _20TestProfiliOlustur() {
  return [
    // CUT PROFİLLERİ (8 profil) - Zayıflama odaklı
    ['Zeynep Cut', 25, 55, 160, 'kadin', 'zayiflama', 'hafif', 1400],
    ['Ahmet Cut', 30, 80, 175, 'erkek', 'zayiflama', 'orta', 1800],
    ['Elif Cut', 28, 65, 165, 'kadin', 'zayiflama', 'yogun', 1600],
    ['Murat Cut', 35, 90, 180, 'erkek', 'zayiflama', 'hafif', 2000],
    ['Ayşe Cut', 32, 70, 170, 'kadin', 'zayiflama', 'orta', 1500],
    ['Kemal Cut', 27, 85, 178, 'erkek', 'zayiflama', 'yogun', 1900],
    ['Sema Cut', 29, 58, 162, 'kadin', 'zayiflama', 'hafif', 1350],
    ['Volkan Cut', 33, 95, 185, 'erkek', 'zayiflama', 'orta', 2100],
    
    // LEAN BULK PROFİLLERİ (6 profil) - Kontrollü kas artışı
    ['Deniz Lean Bulk', 24, 60, 168, 'kadin', 'kasArtisi', 'yogun', 2200],
    ['Oğuz Lean Bulk', 26, 75, 172, 'erkek', 'kasArtisi', 'yogun', 2800],
    ['Pınar Lean Bulk', 31, 55, 158, 'kadin', 'kasArtisi', 'orta', 2000],
    ['Emre Lean Bulk', 28, 70, 176, 'erkek', 'kasArtisi', 'yogun', 2600],
    ['Gizem Lean Bulk', 26, 63, 164, 'kadin', 'kasArtisi', 'yogun', 2300],
    ['Barış Lean Bulk', 29, 78, 174, 'erkek', 'kasArtisi', 'orta', 2700],
    
    // BULK PROFİLLERİ (3 profil) - Maksimum kas artışı  
    ['Burak Bulk', 25, 82, 179, 'erkek', 'kasArtisi', 'yogun', 3200],
    ['Cem Bulk', 27, 88, 183, 'erkek', 'kasArtisi', 'yogun', 3400],
    
    // ÖZEL DURUMLAR (3 profil)
    ['Fatma Yaşlı', 45, 62, 158, 'kadin', 'korunum', 'hafif', 1600], // Yaşlı kadın
    ['Hasan Sedanter', 38, 85, 172, 'erkek', 'korunum', 'cok_hafif', 1900], // Sedanter erkek
    ['Zehra Sporcu', 23, 52, 162, 'kadin', 'kasArtisi', 'cok_yogun', 2400], // Elite sporcu
  ];
}

/// Test profili entity oluşturucu
KullaniciProfili _profilOlustur(List<dynamic> data) {
  final makroHedefleri = MakroHesaplayici.hesapla(
    yas: data[1] as int,
    kilo: (data[2] as int).toDouble(),
    boy: data[3] as int,
    cinsiyet: data[4] as String,
    aktiviteSeviyesi: data[6] as String,
    hedef: data[5] as String,
  );
  
  return KullaniciProfili(
    id: 'test_${data[0]}',
    ad: data[0] as String,
    yas: data[1] as int,
    kilo: (data[2] as int).toDouble(),
    boy: data[3] as int,
    cinsiyet: data[4] as String,
    aktiviteSeviyesi: data[6] as String,
    beslenmeHedefi: data[5] as String,
    gunlukKaloriHedefi: data[7] as int,
    gunlukProteinHedefi: makroHedefleri.protein.round(),
    gunlukKarbonhidratHedefi: makroHedefleri.karbonhidrat.round(),
    gunlukYagHedefi: makroHedefleri.yag.round(),
  );
}

/// Günlük plan detaylı analizi - DİYETİSYEN SEVİYESİ
Future<Map<String, dynamic>> _gunlukPlanAnalizi(dynamic gunlukPlan, KullaniciProfili profil, int gun) async {
  List<String> sorunlar = [];
  double dayaniklilik = 1.0;
  
  // 1. ÖĞÜN SAYISI KONTROLÜ
  final ogunSayisi = gunlukPlan.ogunler?.length ?? 0;
  if (ogunSayisi < 4) {
    sorunlar.add('Gün $gun: Öğün sayısı yetersiz ($ogunSayisi < 4)');
    dayaniklilik -= 0.2;
  } else if (ogunSayisi > 6) {
    sorunlar.add('Gün $gun: Çok fazla öğün ($ogunSayisi > 6)');
    dayaniklilik -= 0.1;
  }
  
  // 2. MAKRO HEDEFLERİ KONTROLÜ
  double toplamKalori = 0;
  double toplamProtein = 0;
  double toplamKarb = 0;
  double toplamYag = 0;
  
  for (final ogun in gunlukPlan.ogunler ?? []) {
    for (final yemek in ogun.yemekler ?? []) {
      toplamKalori += yemek.kalori * (yemek.porsiyon ?? 1.0);
      toplamProtein += yemek.protein * (yemek.porsiyon ?? 1.0);
      toplamKarb += yemek.karbonhidrat * (yemek.porsiyon ?? 1.0);
      toplamYag += yemek.yag * (yemek.porsiyon ?? 1.0);
    }
  }
  
  // Kalori toleransı
  double kaloriSapma = (toplamKalori - profil.gunlukKaloriHedefi).abs() / profil.gunlukKaloriHedefi;
  if (kaloriSapma > 0.15) { // %15'ten fazla sapma
    sorunlar.add('Gün $gun: Kalori sapması aşırı (${(kaloriSapma*100).toStringAsFixed(1)}%)');
    dayaniklilik -= kaloriSapma * 0.5;
  }
  
  // Protein toleransı
  double proteinSapma = (toplamProtein - profil.gunlukProteinHedefi).abs() / profil.gunlukProteinHedefi;
  if (proteinSapma > 0.20) { // %20'den fazla sapma
    sorunlar.add('Gün $gun: Protein sapması aşırı (${(proteinSapma*100).toStringAsFixed(1)}%)');
    dayaniklilik -= proteinSapma * 0.3;
  }
  
  // 3. ARA ÖĞÜN MANTIK KONTROLÜ
  bool kahvaltiVar = false;
  bool araOgunVar = false;
  bool ogleVar = false;
  bool aksamVar = false;
  
  for (final ogun in gunlukPlan.ogunler ?? []) {
    switch (ogun.tip) {
      case 'kahvalti':
        kahvaltiVar = true;
        break;
      case 'ara_ogun':
        araOgunVar = true;
        break;
      case 'ogle':
        ogleVar = true;
        break;
      case 'aksam':
        aksamVar = true;
        break;
    }
  }
  
  if (!kahvaltiVar) {
    sorunlar.add('Gün $gun: Kahvaltı eksik');
    dayaniklilik -= 0.15;
  }
  if (!ogleVar) {
    sorunlar.add('Gün $gun: Öğle yemeği eksik'); 
    dayaniklilik -= 0.15;
  }
  if (!aksamVar) {
    sorunlar.add('Gün $gun: Akşam yemeği eksik');
    dayaniklilik -= 0.15;
  }
  
  // Yüksek kalori profilleri için ara öğün zorunlu
  if (profil.gunlukKaloriHedefi > 2500 && !araOgunVar) {
    sorunlar.add('Gün $gun: Yüksek kalori profili için ara öğün eksik');
    dayaniklilik -= 0.1;
  }
  
  // 4. ÇEŞİTLİLİK KONTROLÜ
  List<String> yemekAdlari = [];
  for (final ogun in gunlukPlan.ogunler ?? []) {
    for (final yemek in ogun.yemekler ?? []) {
      yemekAdlari.add(yemek.ad);
    }
  }
  
  if (yemekAdlari.toSet().length < yemekAdlari.length * 0.8) {
    sorunlar.add('Gün $gun: Yemek çeşitliliği düşük');
    dayaniklilik -= 0.05;
  }
  
  // 5. PRAKTİKLİK KONTROLÜ
  double ortalamaSure = 0;
  int yemekSayisi = 0;
  
  for (final ogun in gunlukPlan.ogunler ?? []) {
    for (final yemek in ogun.yemekler ?? []) {
      ortalamaSure += yemek.hazirlamaSuresi ?? 10;
      yemekSayisi++;
    }
  }
  
  if (yemekSayisi > 0) {
    ortalamaSure /= yemekSayisi;
    if (ortalamaSure > 25) { // Ortalama 25dk'dan fazla
      sorunlar.add('Gün $gun: Ortalama hazırlama süresi çok yüksek (${ortalamaSure.toStringAsFixed(1)}dk)');
      dayaniklilik -= 0.05;
    }
  }
  
  // Dayanıklılık alt sınırı
  dayaniklilik = dayaniklilik.clamp(0.0, 1.0);
  
  return {
    'basarili': dayaniklilik >= 0.85 && sorunlar.isEmpty,
    'dayaniklilik': dayaniklilik,
    'sorunlar': sorunlar,
    'makrolar': {
      'kalori': toplamKalori,
      'protein': toplamProtein,
      'karbonhidrat': toplamKarb,
      'yag': toplamYag,
    }
  };
}