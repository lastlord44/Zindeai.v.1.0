// test/v6_haftalik_plan_stres_testi.dart
// V6.0 Deterministik Sistem - 20 Profil Stres Testi
import 'package:test/test.dart';
import '../lib/data/hive/yemek_hive_data_source.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/domain/entities/profil.dart';
import '../lib/domain/entities/yemek.dart';

void main() {
  group('V6.0 Deterministik Sistem - 20 Profil Mega Stres Test', () {
    late YemekHiveDataSource yemekDataSource;
    late AiBeslenmeServisi aiServisi;
    
    setUp(() async {
      yemekDataSource = YemekHiveDataSource();
      await yemekDataSource.init();
      aiServisi = AiBeslenmeServisi();
    });

    test('🚀 20 Profil Comprehensive Stres Testi - V6.0 Performance', () async {
      print('\n🎯 V6.0 DETERMİNİSTİK SİSTEM - 20 PROFİL STRES TESTİ BAŞLIYOR!');
      
      // 20 Farklı Profil - Çeşitli hedefler, kalori ihtiyaçları, kısıtlar
      final profiller = [
        // 1-5: Cut Female Profiles (1400-1800 kcal)
        Profil(
          cinsiyet: 'kadın', yas: 28, boy: 165.0, kilo: 68.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1450, araOgunTercih: false,
          besinAlerjileri: ['fındık', 'ceviz'], yasaKlilanBesinler: ['şeker'],
        ),
        Profil(
          cinsiyet: 'kadın', yas: 32, boy: 158.0, kilo: 55.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1650, araOgunTercih: true,
          besinAlerjileri: ['süt'], yasaKlilanBesinler: ['gluten'],
        ),
        Profil(
          cinsiyet: 'kadın', yas: 24, boy: 172.0, kilo: 75.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1750, araOgunTercih: false,
          besinAlerjileri: [], yasaKlilanBesinler: ['alkol', 'işlenmiş et'],
        ),
        Profil(
          cinsiyet: 'kadın', yas: 36, boy: 160.0, kilo: 62.0, aktiviteSeviyes: 'Düşük (Haftada 0-2 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1380, araOgunTercih: true,
          besinAlerjileri: ['yumurta'], yasaKlilanBesinler: ['şeker', 'beyaz un'],
        ),
        Profil(
          cinsiyet: 'kadın', yas: 29, boy: 168.0, kilo: 70.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1850, araOgunTercih: false,
          besinAlerjileri: [], yasaKlilanBesinler: ['kızartma'],
        ),

        // 6-10: Lean Bulk Male Profiles (2800-3200 kcal)
        Profil(
          cinsiyet: 'erkek', yas: 25, boy: 180.0, kilo: 78.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'kas yapma', gunlukKalori: 2950, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: ['fast food'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 30, boy: 175.0, kilo: 72.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'kas yapma', gunlukKalori: 2850, araOgunTercih: false,
          besinAlerjileri: ['balık'], yasaKlilanBesinler: ['süt ürünleri'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 27, boy: 185.0, kilo: 82.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'kas yapma', gunlukKalori: 3150, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 22, boy: 178.0, kilo: 65.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'kas yapma', gunlukKalori: 2800, araOgunTercih: false,
          besinAlerjileri: ['fıstık'], yasaKlilanBesinler: ['alkol'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 35, boy: 182.0, kilo: 85.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'kas yapma', gunlukKalori: 3250, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: ['şeker'],
        ),

        // 11-15: Bulk Profiles (3200-3800 kcal)
        Profil(
          cinsiyet: 'erkek', yas: 21, boy: 188.0, kilo: 70.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3500, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 26, boy: 183.0, kilo: 75.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3300, araOgunTercih: false,
          besinAlerjileri: ['süt'], yasaKlilanBesinler: ['gluten'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 24, boy: 190.0, kilo: 78.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3750, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: ['fast food'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 28, boy: 176.0, kilo: 68.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3200, araOgunTercih: false,
          besinAlerjileri: ['kabuklu deniz ürünleri'], yasaKlilanBesinler: ['alkol'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 23, boy: 185.0, kilo: 72.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3600, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),

        // 16-20: Mixed Profiles (Maintain, High Fiber, Special Requirements)
        Profil(
          cinsiyet: 'kadın', yas: 40, boy: 163.0, kilo: 58.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'kilo koruma', gunlukKalori: 2100, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: ['şeker', 'beyaz un'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 45, boy: 177.0, kilo: 85.0, aktiviteSeviyes: 'Düşük (Haftada 0-2 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 2200, araOgunTercih: false,
          besinAlerjileri: ['fındık', 'badem'], yasaKlilanBesinler: ['kızartma', 'işlenmiş et'],
        ),
        Profil(
          cinsiyet: 'kadın', yas: 33, boy: 170.0, kilo: 65.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'kilo koruma', gunlukKalori: 2350, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: ['gluten', 'laktoz'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 31, boy: 174.0, kilo: 90.0, aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 2400, araOgunTercih: false,
          besinAlerjileri: ['soya'], yasaKlilanBesinler: ['alkol', 'şeker'],
        ),
        Profil(
          cinsiyet: 'erkek', yas: 26, boy: 192.0, kilo: 95.0, aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)',
          hedef: 'bulk', gunlukKalori: 3900, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),
      ];

      int basariliProfil = 0;
      int toplamProfil = profiller.length;
      final detayliLoglar = <String>[];

      for (int i = 0; i < profiller.length; i++) {
        final profil = profiller[i];
        final profilAdi = 'Profil ${i + 1} (${profil.cinsiyet}, ${profil.hedef}, ${profil.gunlukKalori} kcal)';
        
        print('\n🎯 $profilAdi test ediliyor...');
        
        try {
          final plan = await aiServisi.haftalikPlanOlustur(profil, DateTime.now());
          
          if (plan?.gunlukPlanlar.isEmpty ?? true) {
            detayliLoglar.add('❌ $profilAdi: Plan oluşturulamadı');
            continue;
          }

          // İlk günün planını analiz et
          final ilkGun = plan!.gunlukPlanlar.first;
          double toplamKalori = 0;
          double toplamProtein = 0;
          double toplamKarb = 0;
          double toplamYag = 0;
          double toplamLif = 0;

          for (final ogun in ilkGun.ogunPlanları) {
            for (final yemekPorsiyon in ogun.yemekPorsiyonları) {
              final porsiyon = yemekPorsiyon.miktar;
              final yemek = yemekPorsiyon.yemek;
              
              toplamKalori += (yemek.kalori * porsiyon / 100);
              toplamProtein += (yemek.protein * porsiyon / 100);
              toplamKarb += (yemek.karbonhidrat * porsiyon / 100);
              toplamYag += (yemek.yag * porsiyon / 100);
              toplamLif += (yemek.lif * porsiyon / 100);
            }
          }

          // Tolerans kontrolü (%15 kcal, makrolar genel sınırlarda)
          final kaloriSapma = ((toplamKalori - profil.gunlukKalori).abs() / profil.gunlukKalori * 100);
          final proteinMinimum = profil.kilo * (profil.hedef == 'definasyon' ? 2.0 : 1.8);
          final proteinOk = toplamProtein >= proteinMinimum && toplamProtein <= proteinMinimum * 1.5;
          final lifOk = toplamLif >= 25.0;
          
          final kaloriOk = kaloriSapma <= 15.0;
          final basarili = kaloriOk && proteinOk && lifOk;
          
          if (basarili) {
            basariliProfil++;
            detayliLoglar.add('✅ $profilAdi: Başarılı! Kalori: ${toplamKalori.toInt()}, Protein: ${toplamProtein.toInt()}g');
          } else {
            String sebep = '';
            if (!kaloriOk) sebep += 'Kalori sapma: ${kaloriSapma.toStringAsFixed(1)}%. ';
            if (!proteinOk) sebep += 'Protein yetersiz: ${toplamProtein.toInt()}g. ';
            if (!lifOk) sebep += 'Lif yetersiz: ${toplamLif.toInt()}g. ';
            
            detayliLoglar.add('❌ $profilAdi: $sebep');
          }
          
          print('   Kalori: ${toplamKalori.toInt()}/${profil.gunlukKalori} (${kaloriSapma.toStringAsFixed(1)}% sapma)');
          print('   Protein: ${toplamProtein.toInt()}g, Karb: ${toplamKarb.toInt()}g, Yağ: ${toplamYag.toInt()}g, Lif: ${toplamLif.toInt()}g');
          print('   Durum: ${basarili ? '✅ BAŞARILI' : '❌ BAŞARISIZ'}');
          
        } catch (e) {
          detayliLoglar.add('❌ $profilAdi: Hata - ${e.toString()}');
          print('   ❌ HATA: $e');
        }
      }

      final basariYuzdesi = (basariliProfil / toplamProfil * 100);
      
      print('\n🏆 V6.0 DETERMİNİSTİK SİSTEM SONUÇLARI:');
      print('═════════════════════════════════════');
      print('📊 Toplam Test: $toplamProfil profil');
      print('✅ Başarılı: $basariliProfil profil');
      print('❌ Başarısız: ${toplamProfil - basariliProfil} profil');
      print('🎯 Başarı Oranı: ${basariYuzdesi.toStringAsFixed(1)}%');
      print('');
      print('📋 DETAYLI SONUÇLAR:');
      for (final log in detayliLoglar) {
        print('   $log');
      }

      // V6.0 beklentisi: %80+ başarı oranı (V5.3'ten çok daha iyi)
      expect(basariYuzdesi, greaterThanOrEqualTo(75.0), 
        reason: 'V6.0 Deterministik Sistem en az %75 başarı göstermeli! Mevcut: ${basariYuzdesi.toStringAsFixed(1)}%');
      
      print('\n🎊 V6.0 DETERMİNİSTİK SİSTEM STRES TESTİ TAMAMLANDI!');
      print('🚀 Sonuç: ${basariYuzdesi >= 80 ? 'MÜKEMMEİL PERFORMANS!' : basariYuzdesi >= 70 ? 'İYİ PERFORMANS' : 'GELİŞTİRME GEREKLİ'}');
    });

    test('🔥 Ekstrem Profil Testi - Çok Yüksek/Düşük Kalori', () async {
      print('\n🔥 EKSTREM PROFİL TESTİ BAŞLIYOR...');
      
      // Çok zorlu profiller
      final ekstremProfiller = [
        // Çok düşük kalori - Female Cut
        Profil(
          cinsiyet: 'kadın', yas: 25, boy: 155.0, kilo: 45.0, 
          aktiviteSeviyes: 'Düşük (Haftada 0-2 gün egzersiz)',
          hedef: 'definasyon', gunlukKalori: 1200, araOgunTercih: false,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),
        // Çok yüksek kalori - Male Bulk  
        Profil(
          cinsiyet: 'erkek', yas: 22, boy: 195.0, kilo: 100.0,
          aktiviteSeviyes: 'Yüksek (Haftada 6+ gün egzersiz)', 
          hedef: 'bulk', gunlukKalori: 4200, araOgunTercih: true,
          besinAlerjileri: [], yasaKlilanBesinler: [],
        ),
        // Çoklu kısıt - Orta kalori
        Profil(
          cinsiyet: 'kadın', yas: 30, boy: 165.0, kilo: 60.0,
          aktiviteSeviyes: 'Orta (Haftada 3-5 gün egzersiz)',
          hedef: 'kilo koruma', gunlukKalori: 1900, araOgunTercih: true,
          besinAlerjileri: ['süt', 'yumurta', 'fındık'], 
          yasaKlilanBesinler: ['gluten', 'şeker', 'kızartma'],
        ),
      ];

      int ekstremBasarili = 0;
      
      for (int i = 0; i < ekstremProfiller.length; i++) {
        final profil = ekstremProfiller[i];
        final profilAdi = 'Ekstrem ${i + 1} (${profil.gunlukKalori} kcal)';
        
        try {
          final plan = await aiServisi.haftalikPlanOlustur(profil, DateTime.now());
          
          if (plan?.gunlukPlanlar.isNotEmpty ?? false) {
            ekstremBasarili++;
            print('✅ $profilAdi: Plan oluşturuldu');
          } else {
            print('❌ $profilAdi: Plan oluşturulamadı');
          }
        } catch (e) {
          print('❌ $profilAdi: Hata - $e');
        }
      }
      
      final ekstremBasariYuzdesi = (ekstremBasarili / ekstremProfiller.length * 100);
      print('🔥 Ekstrem Test Sonucu: ${ekstremBasariYuzdesi.toStringAsFixed(0)}% (${ekstremBasarili}/${ekstremProfiller.length})');
      
      // Ekstrem profillerde en az %60 başarı bekliyoruz
      expect(ekstremBasariYuzdesi, greaterThanOrEqualTo(60.0));
    });
  });
}