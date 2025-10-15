// debug_karb_eksigi_analiz.dart
// Hangi kategoride ne kadar karbonhidrat eksik olduğunu analiz et

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

import 'package:flutter_test/flutter_test.dart'; // flutter_test import'u eklendi

void main() {
  testWidgets('Karbonhidrat Eksikliği Analizi', (WidgetTester tester) async {
    // ========================================================================
    // TEST ORTAMI İÇİN KURULUM
    // ========================================================================
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('hive_test_karb');
    Hive.init(tempDir.path); // Hive.initFlutter yerine Hive.init kullanıldı

    // Adaptörleri kaydet
    if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
      Hive.registerAdapter(KullaniciHiveModelAdapter());
    }
    // ========================================================================

    print('🔍 KARBONHİDRAT EKSİĞİ ANALİZİ\n');
    print('=' * 80);

    // Tüm yemekleri yükle
    final tumYemekler = await HiveService.tumYemekleriGetir();
    
    // Hedef karbonhidrat: 246g (loglardan)
    // Kahvaltı: %20 = 49g
    // Ara Öğün 1: %15 = 37g
    // Öğle: %35 = 86g
    // Ara Öğün 2: %10 = 25g
    // Akşam: %20 = 49g

    final hedefler = {
      OgunTipi.kahvalti: 49.0,
      OgunTipi.araOgun1: 37.0,
      OgunTipi.ogle: 86.0,
      OgunTipi.araOgun2: 25.0,
      OgunTipi.aksam: 49.0,
    };

    for (final entry in hedefler.entries) {
      final ogun = entry.key;
      final hedefKarb = entry.value;
      final yemekler = tumYemekler.where((y) => y.ogun == ogun).toList();

      print('\n📊 ${ogun.ad.toUpperCase()}');
      print('-' * 80);
      print('Toplam yemek: ${yemekler.length}');
      print('Hedef karbonhidrat: ${hedefKarb.toStringAsFixed(0)}g (±20% = ${(hedefKarb * 0.8).toStringAsFixed(0)}-${(hedefKarb * 1.2).toStringAsFixed(0)}g)');

      // Karbonhidrata göre sırala
      yemekler.sort((a, b) => b.karbonhidrat.compareTo(a.karbonhidrat));

      // İstatistikler
      if (yemekler.isEmpty) {
        print('❌ SORUN: Hiç yemek yok!');
        continue;
      }

      final ortalamaKarb = yemekler.map((y) => y.karbonhidrat).reduce((a, b) => a + b) / yemekler.length;
      final maxKarb = yemekler.first.karbonhidrat;
      final minKarb = yemekler.last.karbonhidrat;

      print('Ortalama karb: ${ortalamaKarb.toStringAsFixed(1)}g');
      print('En yüksek karb: ${maxKarb.toStringAsFixed(1)}g');
      print('En düşük karb: ${minKarb.toStringAsFixed(1)}g');

      // Hedef aralığında kaç yemek var?
      final uygunYemekler = yemekler.where((y) {
        return y.karbonhidrat >= hedefKarb * 0.8 && y.karbonhidrat <= hedefKarb * 1.2;
      }).toList();

      print('Hedef aralığındaki yemek sayısı: ${uygunYemekler.length}');

      if (uygunYemekler.length < 50) {
        print('❌ SORUN: Hedef aralığında YETERSİZ yemek! (En az 50 olmalı)');
        print('   Çözüm: Bu kategoriye 100 tane daha yüksek karbonhidratlı yemek ekle!');
      } else {
        print('✅ OK: Hedef aralığında yeterli yemek var.');
      }

      // En yüksek karbonhidratlı 5 yemek
      print('\n🏆 EN YÜKSEK KARBONHİDRATLI 5 YEMEK:');
      for (int i = 0; i < 5 && i < yemekler.length; i++) {
        final y = uygunYemekler[i]; // Sadece uygun yemeklerden göster
        print('   ${i + 1}. ${y.ad} → ${y.karbonhidrat.toStringAsFixed(1)}g karb, ${y.kalori.toStringAsFixed(0)} kcal');
      }
    }

    print('\n' + '=' * 80);
    print('ANALİZ TAMAMLANDI\n');

    await Hive.close();
    await tempDir.delete(recursive: true);
  });
}