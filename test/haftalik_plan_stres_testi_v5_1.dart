import 'package:flutter_test/flutter_test.dart';
import '../lib/data/datasources/yemek_hive_data_source.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/services/ai_beslenme_servisi_v5.dart';
import '../lib/data/services/hive_service.dart';
import '../lib/main.dart' as app;

/// 🍽️ DIYETISYEN STRES TESTI v5.1
/// 
/// 20 Farklı Profil ile Profesyonel Diyetisyen Standardında Test
/// 
/// TEST KRITERLERI:
/// ✅ Makro oranları tolerans içinde mi? (±15%)
/// ✅ Türk kahvaltı kültürüne uygun mu?
/// ✅ Ara öğünler uygun mu?
/// ✅ Günlük çeşitlilik sağlanıyor mu?
/// ✅ Porsiyon boyutları mantıklı mı?
/// ✅ Sistem kararlılığı nasıl?

void main() async {
  group('🥗 DİYETİSYEN STANDARDİNDA V5 STRES TESTİ', () {
    late HiveService hiveService;
    late YemekHiveDataSource yemekDataSource;
    late AIBeslenmeServisiV5 aiServisi;
    
    setUpAll(() async {
      await app.main();
      hiveService = HiveService();
      yemekDataSource = YemekHiveDataSource();
      aiServisi = AIBeslenmeServisiV5(yemekDataSource);
    });

    test('🔍 DB Durumu ve Yemek Kalitesi Kontrolü', () async {
      print('\n📊 === VERİTABANI SAĞLIK KONTROLÜ ===');
      
      // Toplam yemek sayısı
      final toplamYemek = await hiveService.yemekSayisi();
      print('📦 Toplam Yemek Sayısı: $toplamYemek');
      expect(toplamYemek, greaterThan(1000), 
        reason: 'En az 1000 yemek olmalı');
      
      // Kategori bazında dağılım
      final tumYemekler = await yemekDataSource.tumYemekleriYukle();
      for (final entry in tumYemekler.entries) {
        final kategori = entry.key.name.toUpperCase();
        final yemekler = entry.value;
        print('🍽️ $kategori: ${yemekler.length} yemek');
      }
      
      // Kritik kategoriler kontrolü
      expect(tumYemekler[OgunTipi.kahvalti]?.length ?? 0, greaterThan(100),
        reason: 'Kahvaltı yemekleri yetersiz');
      expect(tumYemekler[OgunTipi.ogle]?.length ?? 0, greaterThan(200),
        reason: 'Öğle yemekleri yetersiz');
      expect(tumYemekler[OgunTipi.aksam]?.length ?? 0, greaterThan(200),
        reason: 'Akşam yemekleri yetersiz');
      expect(tumYemekler[OgunTipi.araOgun]?.length ?? 0, greaterThan(100),
        reason: 'Ara öğün yemekleri yetersiz');
        
      print('✅ Veritabanı sağlık kontrolü BAŞARILI!');
    });

    test('🧪 20 PROFİL MEGA STRES TESTİ - DİYETİSYEN STANDARDINDA', () async {
      print('\n🚀 === 20 PROFİL DİYETİSYEN STANDARDİ STRES TESTİ ===');
      
      final testProfilleri = _20FarkliProfilleriOlustur();
      
      final testSonuclari = <String, dynamic>{};
      int basariliPlan = 0;
      int toleransDahilinde = 0;
      int turkKahvalti = 0;
      int uygunAraOgun = 0;
      int cesitlilik = 0;
      
      for (int i = 0; i < testProfilleri.length; i++) {
        final profil = testProfilleri[i];
        print('\n🔸 PROFIL ${i+1}: ${profil.ad}');
        print('   📊 Hedef: ${profil.hedefKalori.toInt()} kcal');
        print('   🎯 Tip: ${profil.hedefTip.name}');
        print('   ⚖️ Kilo: ${profil.kilo}kg, Boy: ${profil.boy}cm');
        
        try {
          // Plan oluştur
          final plan = await aiServisi.haftalikPlanOlustur(profil);
          
          if (plan.gunlukPlanlar.isNotEmpty) {
            basariliPlan++;
            
            // İlk günü detaylı analiz et
            final ilkGun = plan.gunlukPlanlar.first;
            final analiz = _gunlukPlanAnaliziYap(ilkGun, profil);
            
            print('   📈 Günlük Analiz:');
            print('     🔥 Toplam Kalori: ${analiz['toplamKalori'].toInt()}');
            print('     🥩 Protein: ${analiz['protein'].toInt()}g (${analiz['proteinOrani'].toStringAsFixed(1)}%)');
            print('     🍞 Karb: ${analiz['karbonhidrat'].toInt()}g (${analiz['karbOrani'].toStringAsFixed(1)}%)');
            print('     🧈 Yağ: ${analiz['yag'].toInt()}g (${analiz['yagOrani'].toStringAsFixed(1)}%)');
            
            // Makro tolerans kontrolü
            final proteinToleransk = _toleransKontrolu(analiz['proteinOrani'], 25, 15);
            final karbToleransk = _toleransKontrolu(analiz['karbOrani'], 45, 15);  
            final yagToleransk = _toleransKontrolu(analiz['yagOrani'], 30, 15);
            
            if (proteinToleransk && karbToleransk && yagToleransk) {
              toleransDahilinde++;
              print('     ✅ Makro tolerans: İÇİNDE');
            } else {
              print('     ❌ Makro tolerans: DIŞINDA');
              print('       Protein: ${proteinToleransk ? '✅' : '❌'}');
              print('       Karb: ${karbToleransk ? '✅' : '❌'}');
              print('       Yağ: ${yagToleransk ? '✅' : '❌'}');
            }
            
            // Türk kahvaltısı kontrolü
            final kahvaltilari = ilkGun.ogunler.where((o) => o.tip == OgunTipi.kahvalti).toList();
            bool turkKahvaltiUygun = true;
            for (final ogun in kahvaltilari) {
              for (final yemek in ogun.yemekler) {
                if (_turkKahvaltisinaUygunMu(yemek)) {
                  continue;
                } else {
                  turkKahvaltiUygun = false;
                  print('     ⚠️ Uygunsuz kahvaltı: ${yemek.ad}');
                }
              }
            }
            if (turkKahvaltiUygun) turkKahvalti++;
            
            // Ara öğün kontrolü
            final araOgunler = ilkGun.ogunler.where((o) => o.tip == OgunTipi.araOgun).toList();
            bool araOgunUygun = true;
            for (final ogun in araOgunler) {
              for (final yemek in ogun.yemekler) {
                if (_araOguneUygunMu(yemek)) {
                  continue;
                } else {
                  araOgunUygun = false;
                  print('     ⚠️ Uygunsuz ara öğün: ${yemek.ad}');
                }
              }
            }
            if (araOgunUygun) uygunAraOgun++;
            
            // Çeşitlilik kontrolü
            final tumYemekAdlari = ilkGun.ogunler
                .expand((o) => o.yemekler)
                .map((y) => y.ad)
                .toSet();
            if (tumYemekAdlari.length >= 4) cesitlilik++;
            
            print('     🌈 Çeşitlilik: ${tumYemekAdlari.length} farklı yemek');
            
          } else {
            print('     ❌ Plan oluşturulamadı!');
          }
          
        } catch (e) {
          print('     💥 HATA: $e');
        }
        
        // Test hızlandırma için kısa bekle
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      // SONUÇ RAPORU
      print('\n📊 === FİNAL SONUÇLARI ===');
      print('🎯 Başarılı Plan: $basariliPlan/20 (${(basariliPlan/20*100).toInt()}%)');
      print('⚖️ Tolerans İçinde: $toleransDahilinde/20 (${(toleransDahilinde/20*100).toInt()}%)');
      print('🇹🇷 Türk Kahvaltısı: $turkKahvalti/20 (${(turkKahvalti/20*100).toInt()}%)');
      print('🍎 Uygun Ara Öğün: $uygunAraOgun/20 (${(uygunAraOgun/20*100).toInt()}%)');
      print('🌈 Yeterli Çeşitlilik: $cesitlilik/20 (${(cesitlilik/20*100).toInt()}%)');
      
      // DİYETİSYEN DEĞERLENDİRMESİ
      print('\n🥗 === DİYETİSYEN DEĞERLENDİRMESİ ===');
      
      final genel_puan = (basariliPlan/20 + toleransDahilinde/20 + turkKahvalti/20 + uygunAraOgun/20 + cesitlilik/20) / 5 * 100;
      
      if (genel_puan >= 90) {
        print('🏆 MÜKEMMEL! Profesyonel diyetisyen standardında sistem.');
      } else if (genel_puan >= 80) {
        print('✅ ÇOK İYİ! Küçük iyileştirmelerle mükemmel olabilir.');  
      } else if (genel_puan >= 70) {
        print('⚠️ İYİ! Bazı kritik sorunlar var, düzeltme gerekli.');
      } else if (genel_puan >= 60) {
        print('❌ ORTA! Ciddi sorunlar var, büyük düzeltme gerekli.');
      } else {
        print('🚨 KÖTÜ! Sistem kullanıma hazır değil, major overhaul gerekli.');
      }
      
      print('📊 Genel Puan: ${genel_puan.toStringAsFixed(1)}/100');
      
      // Minimum kabul kriterleri
      expect(basariliPlan, greaterThanOrEqualTo(18), 
        reason: '90% başarı oranı gerekli');
      expect(toleransDahilinde, greaterThanOrEqualTo(14),
        reason: '70% makro tolerans gerekli'); 
      expect(turkKahvalti, greaterThanOrEqualTo(16),
        reason: '80% Türk kahvaltısı uygunluğu gerekli');
    });
  });
}

/// Test için 20 farklı profil oluştur
List<Kullanici> _20FarkliProfilleriOlustur() {
  return [
    // BULK PROFİLLERİ
    Kullanici(id: '1', ad: 'Kas Yapmak İsteyen Genç', yas: 25, cinsiyet: Cinsiyet.erkek, 
        kilo: 70, boy: 175, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasYapma, hedefKalori: 2800),
    Kullanici(id: '2', ad: 'Güçlü Bulk Erkek', yas: 30, cinsiyet: Cinsiyet.erkek,
        kilo: 85, boy: 180, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.kasYapma, hedefKalori: 3200),
    Kullanici(id: '3', ad: 'Kadın Kas Yapma', yas: 28, cinsiyet: Cinsiyet.kadin,
        kilo: 60, boy: 165, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasYapma, hedefKalori: 2400),

    // CUT PROFİLLERİ  
    Kullanici(id: '4', ad: 'Yağ Yakan Erkek', yas: 35, cinsiyet: Cinsiyet.erkek,
        kilo: 90, boy: 175, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.yagYakma, hedefKalori: 2200),
    Kullanici(id: '5', ad: 'Definasyon Kadın', yas: 32, cinsiyet: Cinsiyet.kadin,
        kilo: 70, boy: 160, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.yagYakma, hedefKalori: 1800),
    Kullanici(id: '6', ad: 'Hızlı Cut Erkek', yas: 27, cinsiyet: Cinsiyet.erkek,
        kilo: 80, boy: 170, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.yagYakma, hedefKalori: 1900),

    // KORUMA PROFİLLERİ
    Kullanici(id: '7', ad: 'Kas Koruma Erkek', yas: 40, cinsiyet: Cinsiyet.erkek,
        kilo: 75, boy: 175, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasKoruma, hedefKalori: 2500),
    Kullanici(id: '8', ad: 'Maintenance Kadın', yas: 35, cinsiyet: Cinsiyet.kadin,
        kilo: 65, boy: 168, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasKoruma, hedefKalori: 2100),

    // ÖZEL DURUMLAR
    Kullanici(id: '9', ad: 'Genç Sporcu', yas: 20, cinsiyet: Cinsiyet.erkek,
        kilo: 65, boy: 180, aktiviteSeviyesi: AktiviteSeviyesi.cokYuksek, hedefTip: HedefTip.kasYapma, hedefKalori: 3000),
    Kullanici(id: '10', ad: 'Yaşlı Aktif Erkek', yas: 55, cinsiyet: Cinsiyet.erkek,
        kilo: 80, boy: 172, aktiviteSeviyesi: AktiviteSeviyesi.dusuk, hedefTip: HedefTip.yagYakma, hedefKalori: 2000),

    // EKSTREM DURUMLAR
    Kullanici(id: '11', ad: 'Mini Cut', yas: 25, cinsiyet: Cinsiyet.erkek,
        kilo: 75, boy: 175, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.yagYakma, hedefKalori: 1600),
    Kullanici(id: '12', ad: 'Mega Bulk', yas: 22, cinsiyet: Cinsiyet.erkek,
        kilo: 85, boy: 185, aktiviteSeviyesi: AktiviteSeviyesi.cokYuksek, hedefTip: HedefTip.kasYapma, hedefKalori: 3600),
    
    // KADIN PROFİLLERİ
    Kullanici(id: '13', ad: 'Fit Kadın Bulk', yas: 26, cinsiyet: Cinsiyet.kadin,
        kilo: 55, boy: 162, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.kasYapma, hedefKalori: 2300),
    Kullanici(id: '14', ad: 'Bikini Prep', yas: 29, cinsiyet: Cinsiyet.kadin,
        kilo: 58, boy: 165, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.yagYakma, hedefKalori: 1500),
    Kullanici(id: '15', ad: 'Güçlü Kadın', yas: 33, cinsiyet: Cinsiyet.kadin,
        kilo: 68, boy: 170, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.kasKoruma, hedefKalori: 2200),

    // KARIŞIK PROFİLLER  
    Kullanici(id: '16', ad: 'Endomorph Cut', yas: 38, cinsiyet: Cinsiyet.erkek,
        kilo: 95, boy: 175, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.yagYakma, hedefKalori: 2100),
    Kullanici(id: '17', ad: 'Ektomorf Bulk', yas: 24, cinsiyet: Cinsiyet.erkek,
        kilo: 60, boy: 180, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasYapma, hedefKalori: 2900),
    Kullanici(id: '18', ad: 'Orta Yaş Kadın', yas: 45, cinsiyet: Cinsiyet.kadin,
        kilo: 72, boy: 160, aktiviteSeviyesi: AktiviteSeviyesi.dusuk, hedefTip: HedefTip.yagYakma, hedefKalori: 1700),
    Kullanici(id: '19', ad: 'Genç Kadın Sporcu', yas: 21, cinsiyet: Cinsiyet.kadin,
        kilo: 52, boy: 158, aktiviteSeviyesi: AktiviteSeviyesi.yuksek, hedefTip: HedefTip.kasYapma, hedefKalori: 2100),
    Kullanici(id: '20', ad: 'Dengeli Erkek', yas: 30, cinsiyet: Cinsiyet.erkek,
        kilo: 77, boy: 177, aktiviteSeviyesi: AktiviteSeviyesi.orta, hedefTip: HedefTip.kasKoruma, hedefKalori: 2400),
  ];
}

/// Günlük plan makro analizini yap
Map<String, double> _gunlukPlanAnaliziYap(dynamic gunlukPlan, Kullanici profil) {
  double toplamKalori = 0;
  double protein = 0;
  double karbonhidrat = 0;
  double yag = 0;
  
  for (final ogun in gunlukPlan.ogunler) {
    for (final yemek in ogun.yemekler) {
      final porsiyon = ogun.porsiyonlar[yemek.ad] ?? 1.0;
      toplamKalori += yemek.kalori100gr * porsiyon;
      protein += yemek.protein100gr * porsiyon;
      karbonhidrat += yemek.karbonhidrat100gr * porsiyon;  
      yag += yemek.yag100gr * porsiyon;
    }
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

/// Makro tolerans kontrolü
bool _toleransKontrolu(double actual, double hedef, double toleransYuzdesi) {
  final altSinir = hedef * (100 - toleransYuzdesi) / 100;
  final ustSinir = hedef * (100 + toleransYuzdesi) / 100;
  return actual >= altSinir && actual <= ustSinir;
}

/// Türk kahvaltısına uygun mu kontrolü  
bool _turkKahvaltisinaUygunMu(YemekHiveModel yemek) {
  final ad = yemek.ad.toLowerCase();
  
  // YASAK yemekler
  final yasaklar = [
    'ton balığı', 'somon', 'levrek', 'çupra', 'hamsi', 'sardalya',
    'tavuk göğsü', 'tavuk eti', 'dana eti', 'kuzu eti', 'kıyma',
    'köfte', 'kebab', 'döner', 'şiş', 'tantuni', 'lahmacun',
    'pizza', 'hamburger', 'sosisli', 'hot dog', 'nugget',
    'pilav', 'makarna', 'noodle', 'ramen', 'spaghetti',
    'çorba', 'soup', 'krem çorba', 'mercimek çorba'
  ];
  
  for (final yasak in yasaklar) {
    if (ad.contains(yasak)) return false;
  }
  
  return true;
}

/// Ara öğüne uygun mu kontrolü
bool _araOguneUygunMu(YemekHiveModel yemek) {
  final ad = yemek.ad.toLowerCase();
  final kalori = yemek.kalori100gr;
  
  // Ara öğün çok ağır olmamalı (100gr başına 300'den fazla kalori olmamalı)
  if (kalori > 400) return false;
  
  // Ana yemek tarzı şeyler ara öğünde olmaz
  final uygunDegil = [
    'pilav', 'makarna', 'döner', 'kebab', 'köfte', 'çorba',
    'pizza', 'lahmacun', 'tantuni', 'hamburger', 'kıyma'
  ];
  
  for (final uygunDegil_ in uygunDegil) {
    if (ad.contains(uygunDegil_)) return false;
  }
  
  return true;
}