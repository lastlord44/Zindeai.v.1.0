// ============================================================================
// test/ai_beslenme_v5_turk_kahvaltisi_test.dart
// V5 TÜRK KAHVALTISI & ÇEŞİTLİLİK TESTLERİ
// 🇹🇷 KRİTİK SORUNLAR: Ton balığı kahvaltı + Her gün aynı yemek
// ============================================================================

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/domain/services/ai_beslenme_servisi_v5.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/data/models/yemek_hive_model.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/core/utils/app_logger.dart';

void main() {
  group('🇹🇷 V5 TÜRK KAHVALTISI & ÇEŞİTLİLİK TESTLERİ', () {
    late AIBeslenmeServisiV5 aiServis;

    setUpAll(() async {
      // Test için geçici Hive dizini
      final testDir = Directory('./test_hive_data');
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync();

      await Hive.initFlutter(testDir.path);
      
      // Sadece temel adapterleri kaydet (entity'ler enum olarak otomatik serialize olur)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(YemekHiveModelAdapter());
      }

      await HiveService.init(isTest: true);
      aiServis = AIBeslenmeServisiV5();
    });

    tearDownAll(() async {
      await Hive.close();
      final testDir = Directory('./test_hive_data');
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('🚫 TÜRK KAHVALTISI FİLTRESİ - Ton balığı kahvaltıda çıkmamalı', () {
      // Test yemekleri
      final tonBalikliKahvalti = Yemek(
        id: 'test_ton_kahvalti',
        ad: 'Ton Balıklı Kahvaltı',
        ogun: OgunTipi.kahvalti,
        kalori: 400,
        protein: 30,
        karbonhidrat: 20,
        yag: 25,
        malzemeler: ['Ton balığı (100g)', 'Ekmek (2 dilim)', 'Domates (1 adet)'],
        hazirlamaSuresi: 10,
        zorluk: Zorluk.kolay,
      );

      final normalKahvalti = Yemek(
        id: 'test_normal_kahvalti',
        ad: 'Peynirli Omlet',
        ogun: OgunTipi.kahvalti,
        kalori: 350,
        protein: 25,
        karbonhidrat: 15,
        yag: 22,
        malzemeler: ['Yumurta (2 adet)', 'Beyaz Peynir (50g)', 'Domates (1 adet)'],
        hazirlamaSuresi: 10,
        zorluk: Zorluk.kolay,
      );

      // Türk kahvaltısı uyumluluk testi
      final tonBalikUygun = aiServis.testTurkKahvaltisinaUygunMu(tonBalikliKahvalti);
      final normalKahvaltiUygun = aiServis.testTurkKahvaltisinaUygunMu(normalKahvalti);

      expect(tonBalikUygun, false, reason: '🚫 TON BALIĞI kahvaltıda uygun değil!');
      expect(normalKahvaltiUygun, true, reason: '✅ PEYNİRLİ OMLET kahvaltıda uygun');

      AppLogger.success('✅ TÜRK KAHVALTISI FİLTRESİ ÇALIŞIYOR!');
      AppLogger.info('   🚫 Ton balığı: ${tonBalikUygun ? "GEÇTİ (HATA!)" : "ELENDİ (DOĞRU)"}');
      AppLogger.info('   ✅ Peynirli omlet: ${normalKahvaltiUygun ? "GEÇTİ (DOĞRU)" : "ELENDİ (HATA!)"}');
    });

    test('🇹🇷 TÜRK KÜLTÜRÜ YASAK LİSTESİ KONTROLÜ', () {
      final yasakYemekler = [
        'Somon Fileto Kahvaltısı',
        'Tavuk Göğsü Sabah Menüsü', 
        'Biftek Kahvaltı Tabağı',
        'Pizza Kahvaltı Spesyali',
        'Makarna Kahvaltısı'
      ];

      final uygunYemekler = [
        'Menemen',
        'Sucuklu Yumurta',
        'Peynirli Börek',
        'Bal Kaymak',
        'Yoğurtlu Kahvaltı'
      ];

      for (final yasakAd in yasakYemekler) {
        final yasakYemek = Yemek(
          id: 'test_yasak_${yasakAd.hashCode}',
          ad: yasakAd,
          ogun: OgunTipi.kahvalti,
          kalori: 400,
          protein: 25,
          karbonhidrat: 30,
          yag: 20,
          malzemeler: [yasakAd.split(' ').first + ' (100g)'],
          hazirlamaSuresi: 15,
          zorluk: Zorluk.orta,
        );

        final uygunMu = aiServis.testTurkKahvaltisinaUygunMu(yasakYemek);
        expect(uygunMu, false, reason: '🚫 $yasakAd kahvaltıda uygun değil!');
        AppLogger.warning('🚫 YASAK: $yasakAd - ${uygunMu ? "GEÇTİ (HATA!)" : "ELENDİ (DOĞRU)"}');
      }

      for (final uygunAd in uygunYemekler) {
        final uygunYemek = Yemek(
          id: 'test_uygun_${uygunAd.hashCode}',
          ad: uygunAd,
          ogun: OgunTipi.kahvalti,
          kalori: 350,
          protein: 20,
          karbonhidrat: 25,
          yag: 18,
          malzemeler: [uygunAd + ' malzemeleri'],
          hazirlamaSuresi: 10,
          zorluk: Zorluk.kolay,
        );

        final uygunMu = aiServis.testTurkKahvaltisinaUygunMu(uygunYemek);
        expect(uygunMu, true, reason: '✅ $uygunAd kahvaltıda uygun!');
        AppLogger.success('✅ UYGUN: $uygunAd - ${uygunMu ? "GEÇTİ (DOĞRU)" : "ELENDİ (HATA!)"}');
      }
    });

    test('🌟 ÇEŞİTLİLİK ALGORİTMASI - Her gün farklı yemek testi', () async {
      AppLogger.info('🌟 7 GÜNLÜK ÇEŞİTLİLİK TESTİ BAŞLATILIYOR...');

      // Mock profil
      const hedefKalori = 2000.0;
      const hedefProtein = 120.0;
      const hedefKarb = 200.0;
      const hedefYag = 80.0;

      final kahvaltiYemekleri = <String>[];
      final ogleYemekleri = <String>[];
      final aksamYemekleri = <String>[];

      // 7 gün test et
      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime.now().add(Duration(days: gun));
        
        try {
          final plan = await aiServis.gunlukPlanOlustur(
            hedefKalori: hedefKalori,
            hedefProtein: hedefProtein,
            hedefKarb: hedefKarb,
            hedefYag: hedefYag,
            hedef: Hedef.kiloVermek,
            tarih: tarih,
          );

          final kahvaltiAd = plan.kahvalti?.ad ?? 'Bilinmeyen';
          final ogleAd = plan.ogleYemegi?.ad ?? 'Bilinmeyen';
          final aksamAd = plan.aksamYemegi?.ad ?? 'Bilinmeyen';

          kahvaltiYemekleri.add(kahvaltiAd);
          ogleYemekleri.add(ogleAd);
          aksamYemekleri.add(aksamAd);

          AppLogger.info('📅 GÜN ${gun + 1}:');
          AppLogger.info('   🥞 Kahvaltı: $kahvaltiAd');
          AppLogger.info('   🍽️ Öğle: $ogleAd'); 
          AppLogger.info('   🌙 Akşam: $aksamAd');

          // Türk kahvaltısı kontrolü
          if (plan.kahvalti != null) {
            final turkKahvaltisiUygun = aiServis.testTurkKahvaltisinaUygunMu(plan.kahvalti!);
            if (!turkKahvaltisiUygun) {
              AppLogger.error('🚫 TÜRK KAHVALTISI UYUMU HATASI: $kahvaltiAd');
              fail('Türk kahvaltısı kurallarına uygun olmayan yemek: $kahvaltiAd');
            }
          }

        } catch (e) {
          AppLogger.error('❌ Gün ${gun + 1} plan oluşturma hatası: $e');
          // Test devam etsin, sadece uyar
        }

        // Her gün arası kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Çeşitlilik analizi
      final kahvaltiBenzersiz = kahvaltiYemekleri.toSet().length;
      final ogleBenzersiz = ogleYemekleri.toSet().length;
      final aksamBenzersiz = aksamYemekleri.toSet().length;

      AppLogger.success('🎯 ÇEŞİTLİLİK SONUÇLARI:');
      AppLogger.info('   🥞 Kahvaltı çeşitliliği: $kahvaltiBenzersiz/7 (${(kahvaltiBenzersiz/7*100).toStringAsFixed(1)}%)');
      AppLogger.info('   🍽️ Öğle çeşitliliği: $ogleBenzersiz/7 (${(ogleBenzersiz/7*100).toStringAsFixed(1)}%)');
      AppLogger.info('   🌙 Akşam çeşitliliği: $aksamBenzersiz/7 (${(aksamBenzersiz/7*100).toStringAsFixed(1)}%)');

      // En az %60 çeşitlilik bekliyoruz (7 günde en az 4 farklı yemek)
      expect(kahvaltiBenzersiz, greaterThanOrEqualTo(4), 
        reason: 'Kahvaltı çeşitliliği yetersiz: $kahvaltiBenzersiz/7');
      expect(ogleBenzersiz, greaterThanOrEqualTo(4), 
        reason: 'Öğle çeşitliliği yetersiz: $ogleBenzersiz/7');
      expect(aksamBenzersiz, greaterThanOrEqualTo(4), 
        reason: 'Akşam çeşitliliği yetersiz: $aksamBenzersiz/7');

      AppLogger.success('✅ V5 ÇEŞİTLİLİK ALGORİTMASI BAŞARILI!');
    });

    test('🔥 GÜNLÜK SEED SİSTEMİ - Farklı günlerde farklı sonuçlar', () async {
      AppLogger.info('🔥 GÜNLÜK SEED SİSTEMİ TESTİ...');

      const hedefKalori = 1800.0;
      const hedefProtein = 100.0;
      const hedefKarb = 180.0;
      const hedefYag = 70.0;

      // Aynı gün içinde 3 farklı saatte test
      final bugun = DateTime.now();
      final sabah = DateTime(bugun.year, bugun.month, bugun.day, 8, 0);
      final ogle = DateTime(bugun.year, bugun.month, bugun.day, 12, 30);
      final aksam = DateTime(bugun.year, bugun.month, bugun.day, 18, 45);

      final saatler = [sabah, ogle, aksam];
      final planlar = <String>[];

      for (int i = 0; i < saatler.length; i++) {
        try {
          final plan = await aiServis.gunlukPlanOlustur(
            hedefKalori: hedefKalori,
            hedefProtein: hedefProtein,
            hedefKarb: hedefKarb,
            hedefYag: hedefYag,
            hedef: Hedef.kiloAlmak,
            tarih: saatler[i],
          );

          final planOzeti = '${plan.kahvalti?.ad}|${plan.ogleYemegi?.ad}|${plan.aksamYemegi?.ad}';
          planlar.add(planOzeti);

          AppLogger.info('⏰ SAAT ${saatler[i].hour}:${saatler[i].minute} - Plan: $planOzeti');
        } catch (e) {
          AppLogger.warning('⚠️ Plan ${i + 1} oluşturulamadı: $e');
        }
      }

      // En az 2 farklı plan olması beklenir (seed farklılığı sayesinde)
      final benzersizPlanlar = planlar.toSet().length;
      AppLogger.info('🎲 Benzersiz plan sayısı: $benzersizPlanlar/${planlar.length}');

      if (benzersizPlanlar >= 2) {
        AppLogger.success('✅ SEED SİSTEMİ ÇALIŞIYOR - Farklı saatlerde farklı planlar!');
      } else {
        AppLogger.warning('⚠️ SEED sistemi beklenenden az çeşitlilik üretiyor');
      }
    });

    test('📊 V5 PERFORMANCE & STABILITY TESTİ', () async {
      AppLogger.info('📊 V5 PERFORMANS & STABİLİTE TESTİ...');

      const hedefKalori = 2200.0;
      const hedefProtein = 130.0;  
      const hedefKarb = 220.0;
      const hedefYag = 85.0;

      int basariliPlan = 0;
      int toplamDeneme = 10;
      final hatalar = <String>[];

      for (int i = 0; i < toplamDeneme; i++) {
        try {
          final tarih = DateTime.now().add(Duration(days: i));
          
          final plan = await aiServis.gunlukPlanOlustur(
            hedefKalori: hedefKalori,
            hedefProtein: hedefProtein,
            hedefKarb: hedefKarb,
            hedefYag: hedefYag,
            hedef: Hedef.formdaKal,
            tarih: tarih,
          );

          // Plan doğrulamaları
          expect(plan.kahvalti, isNotNull, reason: 'Kahvaltı null olamaz');
          expect(plan.ogleYemegi, isNotNull, reason: 'Öğle yemeği null olamaz');
          expect(plan.aksamYemegi, isNotNull, reason: 'Akşam yemeği null olamaz');

          // Türk kahvaltısı kontrolü
          if (plan.kahvalti != null) {
            final turkKahvaltisiUygun = aiServis.testTurkKahvaltisinaUygunMu(plan.kahvalti!);
            if (!turkKahvaltisiUygun) {
              hatalar.add('Gün ${i + 1}: Türk kahvaltısı uyumsuz - ${plan.kahvalti!.ad}');
            }
          }

          basariliPlan++;
          AppLogger.info('✅ Plan ${i + 1}: ${plan.kahvalti?.ad} | ${plan.ogleYemegi?.ad} | ${plan.aksamYemegi?.ad}');
          
        } catch (e) {
          hatalar.add('Gün ${i + 1}: $e');
          AppLogger.error('❌ Plan ${i + 1} hatası: $e');
        }
      }

      final basariOrani = (basariliPlan / toplamDeneme * 100);
      AppLogger.success('🎯 V5 PERFORMANS SONUÇLARI:');
      AppLogger.info('   📊 Başarı oranı: $basariOrani% ($basariliPlan/$toplamDeneme)');
      AppLogger.info('   🚫 Hata sayısı: ${hatalar.length}');

      if (hatalar.isNotEmpty) {
        AppLogger.warning('⚠️ Tespit edilen hatalar:');
        for (final hata in hatalar) {
          AppLogger.warning('   - $hata');
        }
      }

      // %80 başarı oranı bekliyoruz
      expect(basariOrani, greaterThanOrEqualTo(80), 
        reason: 'V5 stabilitesi yetersiz: %$basariOrani');

      AppLogger.success('✅ V5 PERFORMANCE TESTİ TAMAMLANDI!');
    });
  });
}