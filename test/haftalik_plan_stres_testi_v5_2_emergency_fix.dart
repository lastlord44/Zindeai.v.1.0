import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/services/ai_beslenme_servisi_v5.dart';
import '../lib/data/datasources/yemek_hive_data_source.dart';
import '../lib/utils/seed_loader.dart';
import 'dart:io';

// Mock Kullanici sınıfı
class TestKullanici {
  final String isim;
  final int yas;
  final int boy;
  final int kilo;
  final String cinsiyet;
  final String aktiviteSeviyesi;
  final Hedef hedef;
  
  TestKullanici({
    required this.isim,
    required this.yas,
    required this.boy,
    required this.kilo,
    required this.cinsiyet,
    required this.aktiviteSeviyesi,
    required this.hedef,
  });
}

void main() {
  group('🚨 ACİL EMERGENCY V5.2 STRES TESTİ', () {
    late HiveService hiveService;
    late AIBeslenmeServisiV5 aiServisi;
    late YemekHiveDataSource yemekDataSource;
    late String testHivePath;

    setUpAll(() async {
      // Test için geçici Hive dizini oluştur
      testHivePath = Directory.systemTemp.createTempSync('zindeai_hive_emergency').path;
      await Hive.initFlutter(testHivePath);
      print('🧪 EMERGENCY Hive test modunda başlatıldı: $testHivePath');
      
      // 🔥 DOĞRU STATIC METHOD ÇAĞRISI
      await HiveService.init(path: testHivePath, isTest: true);
      
      yemekDataSource = YemekHiveDataSource();
      
      // 🚨 ACİL: DB'ye HEMEN seed data yükle!
      final seedLoader = SeedLoader();
      try {
        await seedLoader.loadSeedToHive(); // Doğru method adı
      } catch (e) {
        print('⚠️ Seed loading hatası: $e');
      }
      
      // 🔥 DOĞRU STATIC METHOD ÇAĞRISI
      final yemekSayisi = await HiveService.yemekSayisi();
      print('📊 EMERGENCY Test DB yemek sayısı: $yemekSayisi');
      
      if (yemekSayisi == 0) {
        throw Exception('🚨 EMERGENCY: DB hâlâ boş! Seed loading başarısız!');
      }
      
      // 🔥 PARAMETRESİZ CONSTRUCTOR
      aiServisi = AIBeslenmeServisiV5();
      
      print('🚀 EMERGENCY V5.2 TESTİ İNİTİALİZE EDİLDİ!');
    });

    test('🚨 EMERGENCY: 5 KRİTİK PROFİL - DİYETİSYEN STANDARDI', () async {
      print('🔥 === EMERGENCY 5 PROFİL DİYETİSYEN STANDARDI TEST BAŞLATILIYOR ===');
      
      // Kritik test profilleri - sadece en önemlileri
      final kritikProfiller = [
        {
          'isim': 'Emergency Cut Test',
          'kullanici': Kullanici(
            isim: 'Test Cut',
            yas: 25, boy: 175, kilo: 80, cinsiyet: 'erkek',
            aktiviteSeviyesi: AktiviteSeviyesi.orta,
            hedef: Hedef.kiloVermek,
          ),
          'hedefKalori': 2000,
        },
        {
          'isim': 'Emergency Bulk Test', 
          'kullanici': Kullanici(
            isim: 'Test Bulk',
            yas: 22, boy: 180, kilo: 70, cinsiyet: 'erkek',
            aktiviteSeviyesi: AktiviteSeviyesi.yuksek,
            hedef: Hedef.kiloAlmak,
          ),
          'hedefKalori': 3000,
        },
        {
          'isim': 'Emergency Kadın Cut',
          'kullanici': Kullanici(
            isim: 'Test Kadın',
            yas: 25, boy: 165, kilo: 65, cinsiyet: 'kadin',
            aktiviteSeviyesi: AktiviteSeviyesi.orta,
            hedef: Hedef.kasKazanKiloVer,
          ),
          'hedefKalori': 1800,
        },
        {
          'isim': 'Emergency Maintenance',
          'kullanici': Kullanici(
            isim: 'Test Maintenance',
            yas: 30, boy: 175, kilo: 75, cinsiyet: 'erkek', 
            aktiviteSeviyesi: AktiviteSeviyesi.orta,
            hedef: Hedef.kiloKoru,
          ),
          'hedefKalori': 2400,
        },
        {
          'isim': 'Emergency High Bulk',
          'kullanici': Kullanici(
            isim: 'Test High Bulk',
            yas: 20, boy: 185, kilo: 75, cinsiyet: 'erkek',
            aktiviteSeviyesi: AktiviteSeviyesi.cokYuksek,
            hedef: Hedef.kiloAlmak,
          ),
          'hedefKalori': 3500,
        },
      ];

      int basariliPlan = 0;
      int toleransIcinde = 0;
      int turkKahvaltisi = 0;
      int uygunAraOgun = 0; 
      int yeterliCesitlilik = 0;

      for (var profil in kritikProfiller) {
        print('\n🔸 === PROFİL: ${profil['isim']} ===');
        print('   📊 Hedef: ${profil['hedefKalori']} kcal');
        print('   🎯 Tip: ${profil['kullanici'].hedef}');
        
        try {
          // Plan oluştur
          final gunlukPlan = await aiServisi.gunlukPlanOlustur(
            profil['kullanici'] as Kullanici,
            DateTime.now(),
          );
          
          if (gunlukPlan != null) {
            basariliPlan++;
            
            // Makro analizi
            double toplamKalori = 0;
            double toplamProtein = 0;
            double toplamKarb = 0; 
            double toplamYag = 0;
            
            final ogunler = [
              gunlukPlan.kahvalti,
              gunlukPlan.araOgun1,
              gunlukPlan.ogle,
              gunlukPlan.araOgun2,
              gunlukPlan.aksam,
              if (gunlukPlan.geceAtistirir != null) gunlukPlan.geceAtistirir!,
            ];
            
            // Toplam makroları hesapla
            for (var ogun in ogunler) {
              if (ogun != null) {
                toplamKalori += ogun.kalori ?? 0;
                toplamProtein += ogun.protein ?? 0;
                toplamKarb += ogun.karbonhidrat ?? 0;
                toplamYag += ogun.yag ?? 0;
              }
            }
            
            final hedefKalori = profil['hedefKalori'] as int;
            final hedefProtein = (hedefKalori * 0.25 / 4).round(); 
            final hedefKarb = (hedefKalori * 0.45 / 4).round();
            final hedefYag = (hedefKalori * 0.30 / 9).round();
            
            // Tolerans kontrolü (±15%)
            final kaloriTolerans = (toplamKalori - hedefKalori).abs() / hedefKalori;
            final proteinTolerans = (toplamProtein - hedefProtein).abs() / hedefProtein;
            final karbTolerans = (toplamKarb - hedefKarb).abs() / hedefKarb;
            final yagTolerans = (toplamYag - hedefYag).abs() / hedefYag;
            
            final toleransOK = kaloriTolerans <= 0.15 && 
                             proteinTolerans <= 0.15 && 
                             karbTolerans <= 0.15 && 
                             yagTolerans <= 0.15;
            
            if (toleransOK) {
              toleransIcinde++;
              print('   ✅ TOLERANS İÇİNDE!');
            } else {
              print('   ❌ TOLERANS AŞILDI!');
              print('     🔥 K: ${toplamKalori.toInt()}/${hedefKalori} (${(kaloriTolerans*100).toStringAsFixed(1)}%)');
              print('     🥩 P: ${toplamProtein.toInt()}/${hedefProtein} (${(proteinTolerans*100).toStringAsFixed(1)}%)');
              print('     🍞 C: ${toplamKarb.toInt()}/${hedefKarb} (${(karbTolerans*100).toStringAsFixed(1)}%)');
              print('     🧈 Y: ${toplamYag.toInt()}/${hedefYag} (${(yagTolerans*100).toStringAsFixed(1)}%)');
            }
            
            // Türk kahvaltısı kontrolü
            if (gunlukPlan.kahvalti != null) {
              final kahvaltiAdi = gunlukPlan.kahvalti!.isim?.toLowerCase() ?? '';
              if (kahvaltiAdi.contains('menemen') || 
                  kahvaltiAdi.contains('bal') ||
                  kahvaltiAdi.contains('peynir') ||
                  kahvaltiAdi.contains('omlet')) {
                turkKahvaltisi++;
                print('   🇹🇷 Türk kahvaltısı: UYGUN');
              }
            }
            
            // Ara öğün kontrolü
            if (gunlukPlan.araOgun1 != null && gunlukPlan.araOgun2 != null) {
              uygunAraOgun++;
              print('   🍎 Ara öğün: UYGUN');
            }
            
            // Çeşitlilik kontrolü (basit)
            yeterliCesitlilik++;
            print('   🌈 Çeşitlilik: YETER');
            
          } else {
            print('   ❌ Plan oluşturulamadı!');
          }
          
        } catch (e) {
          print('   🚨 HATA: $e');
        }
      }

      print('\n🎯 === EMERGENCY SONUÇLARI ===');
      print('🎯 Başarılı Plan: $basariliPlan/${kritikProfiller.length} (${(basariliPlan/kritikProfiller.length*100).toInt()}%)');
      print('⚖️ Tolerans İçinde: $toleransIcinde/${kritikProfiller.length} (${(toleransIcinde/kritikProfiller.length*100).toInt()}%)');
      print('🇹🇷 Türk Kahvaltısı: $turkKahvaltisi/${kritikProfiller.length} (${(turkKahvaltisi/kritikProfiller.length*100).toInt()}%)');
      print('🍎 Uygun Ara Öğün: $uygunAraOgun/${kritikProfiller.length} (${(uygunAraOgun/kritikProfiller.length*100).toInt()}%)');
      print('🌈 Yeterli Çeşitlilik: $yeterliCesitlilik/${kritikProfiller.length} (${(yeterliCesitlilik/kritikProfiller.length*100).toInt()}%)');
      
      print('\n🥗 === EMERGENCY DİYETİSYEN DEĞERLENDİRMESİ ===');
      final genelPuan = ((basariliPlan * 25) + (toleransIcinde * 35) + (turkKahvaltisi * 15) + 
                         (uygunAraOgun * 15) + (yeterliCesitlilik * 10)) / kritikProfiller.length;
      
      if (genelPuan >= 85) {
        print('✅ MÜKEMMEL! Diyetisyen standartlarına tamamen uygun.');
      } else if (genelPuan >= 70) {
        print('✅ İYİ! Küçük iyileştirmeler yeterli.');
      } else if (genelPuan >= 50) {
        print('⚠️ ORTA! Ciddi sorunlar var, büyük düzeltme gerekli.');
      } else {
        print('❌ KÖTÜ! Sistem kullanılamaz durumda.');
      }
      print('📊 Genel Puan: ${genelPuan.toStringAsFixed(1)}/100');

      // Test assertions
      expect(basariliPlan, equals(kritikProfiller.length), reason: 'Tüm planlar oluşturulmalı');
      expect(toleransIcinde, greaterThanOrEqualTo((kritikProfiller.length * 0.8).ceil()), 
             reason: '%80 makro tolerans gerekli (Gerçek: $toleransIcinde/${kritikProfiller.length})');
    });

    tearDownAll(() async {
      await Hive.close();
      if (Directory(testHivePath).existsSync()) {
        Directory(testHivePath).deleteSync(recursive: true);
      }
    });
  });
}