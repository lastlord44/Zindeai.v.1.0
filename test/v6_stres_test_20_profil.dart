// test/v6_stres_test_20_profil.dart
// V6.0 Deterministik Sistem vs V5.3 - 20 Profil Performance Karşılaştırması
import 'package:test/test.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/data/services/hive_service.dart';
import '../lib/utils/db_summary_service.dart';

void main() {
  group('🚀 V6.0 DETERMİNİSTİK SİSTEM - 20 PROFİL MEGA STRES TEST', () {
    late AiBeslenmeServisi aiServisi;
    late HiveService hiveService;

    setUpAll(() async {
      // DB başlat ve kontrol et
      hiveService = HiveService();
      await hiveService.init();
      
      // DB sağlık kontrolü
      final healthCheck = await DBSummaryService.healthCheck();
      print('\n🔍 DB Sağlık Kontrolü: $healthCheck');
      
      if (!healthCheck['isHealthy']) {
        throw Exception('🚨 DB sağlık kontrolü başarısız! ${healthCheck['issues']}');
      }
      
      final yemekSayisi = await hiveService.yemekSayisi();
      print('📊 Toplam yemek sayısı: $yemekSayisi');
      expect(yemekSayisi, greaterThan(6000), reason: 'En az 6000+ yemek olmalı');
      
      aiServisi = AiBeslenmeServisi();
      print('✅ Test ortamı hazır!');
    });

    test('🎯 20 Profil Comprehensive Stres Testi - V6.0 vs V5.3 Performance', () async {
      print('\n🚀 20 PROFİL STRES TESTİ BAŞLIYOR!');
      print('═══════════════════════════════════════════════════');
      
      // 20 Gerçek dünya profili - çeşitli hedefler ve kısıtlar
      final testProfilleri = <Map<String, dynamic>>[
        // 1-5: Cut Female (1400-1800 kcal)
        {'ad': 'Cut F1', 'cinsiyet': 'kadın', 'yas': 28, 'boy': 165.0, 'kilo': 68.0, 'hedef': 'definasyon', 'kalori': 1450, 'protein': 136},
        {'ad': 'Cut F2', 'cinsiyet': 'kadın', 'yas': 32, 'boy': 158.0, 'kilo': 55.0, 'hedef': 'definasyon', 'kalori': 1650, 'protein': 110},
        {'ad': 'Cut F3', 'cinsiyet': 'kadın', 'yas': 24, 'boy': 172.0, 'kilo': 75.0, 'hedef': 'definasyon', 'kalori': 1750, 'protein': 150},
        {'ad': 'Cut F4', 'cinsiyet': 'kadın', 'yas': 36, 'boy': 160.0, 'kilo': 62.0, 'hedef': 'definasyon', 'kalori': 1380, 'protein': 124},
        {'ad': 'Cut F5', 'cinsiyet': 'kadın', 'yas': 29, 'boy': 168.0, 'kilo': 70.0, 'hedef': 'definasyon', 'kalori': 1850, 'protein': 140},

        // 6-10: Lean Bulk Male (2800-3200 kcal)
        {'ad': 'LeanBulk M1', 'cinsiyet': 'erkek', 'yas': 25, 'boy': 180.0, 'kilo': 78.0, 'hedef': 'kas yapma', 'kalori': 2950, 'protein': 156},
        {'ad': 'LeanBulk M2', 'cinsiyet': 'erkek', 'yas': 30, 'boy': 175.0, 'kilo': 72.0, 'hedef': 'kas yapma', 'kalori': 2850, 'protein': 144},
        {'ad': 'LeanBulk M3', 'cinsiyet': 'erkek', 'yas': 27, 'boy': 185.0, 'kilo': 82.0, 'hedef': 'kas yapma', 'kalori': 3150, 'protein': 164},
        {'ad': 'LeanBulk M4', 'cinsiyet': 'erkek', 'yas': 22, 'boy': 178.0, 'kilo': 65.0, 'hedef': 'kas yapma', 'kalori': 2800, 'protein': 130},
        {'ad': 'LeanBulk M5', 'cinsiyet': 'erkek', 'yas': 35, 'boy': 182.0, 'kilo': 85.0, 'hedef': 'kas yapma', 'kalori': 3250, 'protein': 170},

        // 11-15: Bulk (3200-3800 kcal)
        {'ad': 'Bulk M1', 'cinsiyet': 'erkek', 'yas': 21, 'boy': 188.0, 'kilo': 70.0, 'hedef': 'bulk', 'kalori': 3500, 'protein': 140},
        {'ad': 'Bulk M2', 'cinsiyet': 'erkek', 'yas': 26, 'boy': 183.0, 'kilo': 75.0, 'hedef': 'bulk', 'kalori': 3300, 'protein': 150},
        {'ad': 'Bulk M3', 'cinsiyet': 'erkek', 'yas': 24, 'boy': 190.0, 'kilo': 78.0, 'hedef': 'bulk', 'kalori': 3750, 'protein': 156},
        {'ad': 'Bulk M4', 'cinsiyet': 'erkek', 'yas': 28, 'boy': 176.0, 'kilo': 68.0, 'hedef': 'bulk', 'kalori': 3200, 'protein': 136},
        {'ad': 'Bulk M5', 'cinsiyet': 'erkek', 'yas': 23, 'boy': 185.0, 'kilo': 72.0, 'hedef': 'bulk', 'kalori': 3600, 'protein': 144},

        // 16-20: Mixed & Special Cases
        {'ad': 'Maintain F', 'cinsiyet': 'kadın', 'yas': 40, 'boy': 163.0, 'kilo': 58.0, 'hedef': 'kilo koruma', 'kalori': 2100, 'protein': 116},
        {'ad': 'Cut M Mature', 'cinsiyet': 'erkek', 'yas': 45, 'boy': 177.0, 'kilo': 85.0, 'hedef': 'definasyon', 'kalori': 2200, 'protein': 170},
        {'ad': 'Maintain F Active', 'cinsiyet': 'kadın', 'yas': 33, 'boy': 170.0, 'kilo': 65.0, 'hedef': 'kilo koruma', 'kalori': 2350, 'protein': 130},
        {'ad': 'Cut M Heavy', 'cinsiyet': 'erkek', 'yas': 31, 'boy': 174.0, 'kilo': 90.0, 'hedef': 'definasyon', 'kalori': 2400, 'protein': 180},
        {'ad': 'Mega Bulk', 'cinsiyet': 'erkek', 'yas': 26, 'boy': 192.0, 'kilo': 95.0, 'hedef': 'bulk', 'kalori': 3900, 'protein': 190},
      ];

      int basariliProfil = 0;
      int toplamProfil = testProfilleri.length;
      final detayliLoglar = <String>[];
      final performansMetrikleri = <String, List<double>>{
        'kalori_sapmalar': [],
        'protein_sapmalar': [],
        'test_sureleri': [],
      };

      for (int i = 0; i < testProfilleri.length; i++) {
        final profilData = testProfilleri[i];
        final profilAdi = profilData['ad'] as String;
        
        print('\n🎯 Test $i+1/20: $profilAdi (${profilData['kalori']} kcal)');
        
        final stopwatch = Stopwatch()..start();
        
        try {
          // Profil nesnesi oluştur
          final profil = KullaniciProfili(
            id: 'test_${i}_$profilAdi',
            ad: profilAdi,
            cinsiyet: profilData['cinsiyet'],
            yas: profilData['yas'],
            boy: profilData['boy'],
            kilo: profilData['kilo'],
            aktiviteSeviyesi: 'Orta (Haftada 3-5 gün egzersiz)',
            hedef: profilData['hedef'],
            gunlukKaloriHedefi: profilData['kalori'].toDouble(),
            besinAlerjileri: [],
            yasaKlilanBesinler: [],
          );

          // Plan oluştur (V6.0 sistemini test et)
          final plan = await aiServisi.haftalikPlanOlustur(profil, DateTime.now());
          stopwatch.stop();
          final testSuresi = stopwatch.elapsedMilliseconds;
          performansMetrikleri['test_sureleri']!.add(testSuresi.toDouble());

          if (plan == null || plan.gunlukPlanlar.isEmpty) {
            detayliLoglar.add('❌ $profilAdi: Plan oluşturulamadı');
            print('   ❌ BAŞARISIZ: Plan oluşturulamadı');
            continue;
          }

          // İlk günün planını analiz et
          final ilkGun = plan.gunlukPlanlar.first;
          double toplamKalori = 0;
          double toplamProtein = 0;
          double toplamKarbonhidrat = 0;
          double toplamYag = 0;
          double toplamLif = 0;

          for (final ogun in ilkGun.ogunPlanlari) {
            for (final yemekPorsiyon in ogun.yemekPorsiyonlari) {
              final porsiyon = yemekPorsiyon.miktar;
              final yemek = yemekPorsiyon.yemek;
              
              final carpan = porsiyon / 100.0;
              toplamKalori += (yemek.kalori * carpan);
              toplamProtein += (yemek.protein * carpan);
              toplamKarbonhidrat += (yemek.karbonhidrat * carpan);
              toplamYag += (yemek.yag * carpan);
              toplamLif += (yemek.lif * carpan);
            }
          }

          // Performance metrikleri hesapla
          final hedefKalori = profilData['kalori'].toDouble();
          final hedefProtein = profilData['protein'].toDouble();
          
          final kaloriSapma = ((toplamKalori - hedefKalori).abs() / hedefKalori * 100);
          final proteinSapma = ((toplamProtein - hedefProtein).abs() / hedefProtein * 100);
          
          performansMetrikleri['kalori_sapmalar']!.add(kaloriSapma);
          performansMetrikleri['protein_sapmalar']!.add(proteinSapma);

          // Tolerans kontrolü - Gerçekçi profesyonel diyetisyen standartları
          final kaloriOk = kaloriSapma <= 15.0; // %15 kalori toleransı
          final proteinOk = toplamProtein >= hedefProtein * 0.85 && toplamProtein <= hedefProtein * 1.15; // %15 protein toleransı
          final lifOk = toplamLif >= 25.0; // Minimum lif
          final makroOk = (toplamProtein * 4 + toplamKarbonhidrat * 4 + toplamYag * 9) >= (hedefKalori * 0.85);
          
          final basarili = kaloriOk && proteinOk && lifOk && makroOk;
          
          if (basarili) {
            basariliProfil++;
            detayliLoglar.add('✅ $profilAdi: BAŞARILI! K:${toplamKalori.toInt()}, P:${toplamProtein.toInt()}g, L:${toplamLif.toInt()}g (${testSuresi}ms)');
            print('   ✅ BAŞARILI - Kalori: ${toplamKalori.toInt()}/${hedefKalori.toInt()} (${kaloriSapma.toStringAsFixed(1)}%), Protein: ${toplamProtein.toInt()}g');
          } else {
            String sebep = '';
            if (!kaloriOk) sebep += 'Kalori sapma: ${kaloriSapma.toStringAsFixed(1)}%. ';
            if (!proteinOk) sebep += 'Protein sapma: ${proteinSapma.toStringAsFixed(1)}%. ';
            if (!lifOk) sebep += 'Lif yetersiz: ${toplamLif.toInt()}g. ';
            if (!makroOk) sebep += 'Makro dengesizlik. ';
            
            detayliLoglar.add('❌ $profilAdi: $sebep (${testSuresi}ms)');
            print('   ❌ BAŞARISIZ - $sebep');
          }
          
        } catch (e, stackTrace) {
          stopwatch.stop();
          detayliLoglar.add('❌ $profilAdi: HATA - ${e.toString()}');
          print('   ❌ HATA: $e');
          print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
        }
      }

      // Performance analizi
      final basariYuzdesi = (basariliProfil / toplamProfil * 100);
      final ortalamaSure = performansMetrikleri['test_sureleri']!.reduce((a, b) => a + b) / performansMetrikleri['test_sureleri']!.length;
      final ortalamaKaloriSapma = performansMetrikleri['kalori_sapmalar']!.isNotEmpty 
        ? performansMetrikleri['kalori_sapmalar']!.reduce((a, b) => a + b) / performansMetrikleri['kalori_sapmalar']!.length
        : 0.0;
      final ortalamaProteinSapma = performansMetrikleri['protein_sapmalar']!.isNotEmpty
        ? performansMetrikleri['protein_sapmalar']!.reduce((a, b) => a + b) / performansMetrikleri['protein_sapmalar']!.length
        : 0.0;

      print('\n🏆 V6.0 DETERMİNİSTİK SİSTEM SONUÇLARI');
      print('═════════════════════════════════════════════════════════════');
      print('📊 Test Edilen Profil: $toplamProfil');
      print('✅ Başarılı Profil: $basariliProfil');
      print('❌ Başarısız Profil: ${toplamProfil - basariliProfil}');
      print('🎯 BAŞARI ORANI: ${basariYuzdesi.toStringAsFixed(1)}%');
      print('⏱️  Ortalama Test Süresi: ${ortalamaSure.toStringAsFixed(0)}ms');
      print('📈 Ortalama Kalori Sapma: ${ortalamaKaloriSapma.toStringAsFixed(1)}%');
      print('🥩 Ortalama Protein Sapma: ${ortalamaProteinSapma.toStringAsFixed(1)}%');
      print('');
      
      // V5.3 vs V6.0 Karşılaştırma
      print('📋 V5.3 vs V6.0 KARŞILAŞTIRMA:');
      print('   V5.3 Radical Fix: %31.5 başarı (95.4% protein sapma)');
      print('   V6.0 Deterministik: ${basariYuzdesi.toStringAsFixed(1)}% başarı (${ortalamaProteinSapma.toStringAsFixed(1)}% protein sapma)');
      final iyilestirme = basariYuzdesi / 31.5;
      print('   🚀 İYİLEŞTİRME: ${iyilestirme.toStringAsFixed(1)}x daha iyi!');
      print('');

      print('📋 DETAYLI SONUÇLAR:');
      for (final log in detayliLoglar) {
        print('   $log');
      }

      // Assertion - V6.0 beklentileri
      expect(basariYuzdesi, greaterThanOrEqualTo(75.0), 
        reason: 'V6.0 Deterministik Sistem %75+ başarı göstermeli! Mevcut: ${basariYuzdesi.toStringAsFixed(1)}%');
      
      expect(ortalamaKaloriSapma, lessThanOrEqualTo(20.0),
        reason: 'Ortalama kalori sapma %20 altında olmalı! Mevcut: ${ortalamaKaloriSapma.toStringAsFixed(1)}%');
        
      expect(ortalamaProteinSapma, lessThanOrEqualTo(30.0),
        reason: 'Ortalama protein sapma %30 altında olmalı! Mevcut: ${ortalamaProteinSapma.toStringAsFixed(1)}%');
        
      expect(ortalamaSure, lessThanOrEqualTo(5000.0),
        reason: 'Ortalama test süresi 5 saniye altında olmalı! Mevcut: ${ortalamaSure.toStringAsFixed(0)}ms');

      // Final değerlendirme
      String performansDerecesi;
      if (basariYuzdesi >= 90) {
        performansDerecesi = '🌟 MÜKEMMEİL PERFORMANS!';
      } else if (basariYuzdesi >= 80) {
        performansDerecesi = '🔥 SÜPER PERFORMANS!';
      } else if (basariYuzdesi >= 70) {
        performansDerecesi = '✅ İYİ PERFORMANS';
      } else {
        performansDerecesi = '⚠️ GELİŞTİRME GEREKLİ';
      }

      print('\n🎊 V6.0 DETERMİNİSTİK SİSTEM STRES TESTİ TAMAMLANDI!');
      print('🚀 SONUÇ: $performansDerecesi');
      print('💎 V5.3\'ten ${iyilestirme.toStringAsFixed(1)}x daha iyi performans!');
    });

    test('🔥 Ekstrem Edge Cases - Çok Düşük/Yüksek Kalori', () async {
      print('\n🔥 EKSTREM EDGE CASE TESTİ');
      
      final ekstremProfiller = [
        {'ad': 'Mini Cut', 'cinsiyet': 'kadın', 'yas': 25, 'boy': 155.0, 'kilo': 45.0, 'hedef': 'definasyon', 'kalori': 1200},
        {'ad': 'Mega Bulk', 'cinsiyet': 'erkek', 'yas': 22, 'boy': 195.0, 'kilo': 100.0, 'hedef': 'bulk', 'kalori': 4500},
        {'ad': 'High Maintenance', 'cinsiyet': 'kadın', 'yas': 35, 'boy': 175.0, 'kilo': 80.0, 'hedef': 'kilo koruma', 'kalori': 2800},
      ];

      int ekstremBasarili = 0;
      
      for (final data in ekstremProfiller) {
        try {
          final profil = KullaniciProfili(
            id: 'ekstrem_${data['ad']}',
            ad: data['ad'] as String,
            cinsiyet: data['cinsiyet'] as String,
            yas: data['yas'] as int,
            boy: (data['boy'] as double),
            kilo: (data['kilo'] as double),
            aktiviteSeviyesi: 'Orta (Haftada 3-5 gün egzersiz)',
            hedef: data['hedef'] as String,
            gunlukKaloriHedefi: (data['kalori'] as int).toDouble(),
            besinAlerjileri: [],
            yasaKlilanBesinler: [],
          );

          final plan = await aiServisi.haftalikPlanOlustur(profil, DateTime.now());
          
          if (plan != null && plan.gunlukPlanlar.isNotEmpty) {
            ekstremBasarili++;
            print('✅ ${data['ad']}: Plan oluşturuldu');
          } else {
            print('❌ ${data['ad']}: Plan oluşturulamadı');
          }
        } catch (e) {
          print('❌ ${data['ad']}: Hata - $e');
        }
      }
      
      final ekstremBasariYuzdesi = (ekstremBasarili / ekstremProfiller.length * 100);
      print('🔥 Ekstrem Test Sonucu: ${ekstremBasariYuzdesi.toStringAsFixed(0)}% (${ekstremBasarili}/${ekstremProfiller.length})');
      
      expect(ekstremBasariYuzdesi, greaterThanOrEqualTo(60.0),
        reason: 'Ekstrem profillerde %60+ başarı bekleniyor');
    });
  });
}