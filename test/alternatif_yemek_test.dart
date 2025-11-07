import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/data/local/hive_service.dart';
import 'package:zinde_ai/domain/entities/yemek.dart';
import 'package:zinde_ai/domain/services/ai_beslenme_servisi.dart';
import 'package:zinde_ai/core/utils/yemek_migration_3000.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final testDir = Directory('test/hive_test_data_alternatif');
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    await testDir.create(recursive: true);

    // HiveService.init artık yolu zorunlu kılıyor ve Hive.init'i kendi içinde hallediyor.
    await HiveService.init(path: testDir.path);

    AppLogger.info('🧪 Alternatif Testi: Veritabanı dolduruluyor...');
    await YemekMigration3000.yukle();
    final yemekSayisi = await HiveService.yemekSayisi();
    AppLogger.info('✅ Alternatif Testi: Veritabanında $yemekSayisi yemek var.');
  });

  tearDownAll(() async {
    await HiveService.close(); // HiveService üzerinden kapatmak daha güvenli.
    final testDir = Directory('test/hive_test_data_alternatif');
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('Dinamik Alternatif Yemek Sistemi Testi', () async {
    AppLogger.info('--- 🍲 ALTERNATİF YEMEK SİSTEMİ TESTİ BAŞLADI ---');

    final beslenmeServisi = AIBeslenmeServisi();
    final tumYemekler = await HiveService.tumYemekleriGetir();

    expect(tumYemekler, isNotEmpty, reason: 'Testin çalışması için veritabanında yemek olmalı.');

    // Rastgele bir ana öğün seç (kahvaltı, öğle veya akşam)
    final anaOgunYemekleri = tumYemekler.where((y) => y.ogun == OgunTipi.ogle || y.ogun == OgunTipi.aksam).toList();
    final testYemegi = anaOgunYemekleri.first;

    AppLogger.info('Seçilen Test Yemeği: ${testYemegi.ad} (Öğün: ${testYemegi.ogun.name})');

    // 1. Alternatifleri Getir
    final alternatifler = await beslenmeServisi.alternatifleriGetir(testYemegi);

    // 2. Doğrulamalar
    AppLogger.info('🔍 ${alternatifler.length} adet alternatif bulundu. Doğrulama yapılıyor...');

    expect(alternatifler, isNotEmpty, reason: 'Hiç alternatif yemek bulunamadı.');
    expect(alternatifler.length, lessThanOrEqualTo(3), reason: 'En fazla 3 alternatif dönmeli.');

    for (var altYemek in alternatifler) {
      AppLogger.info('  -> Alternatif: ${altYemek.ad} (Öğün: ${altYemek.ogun.name})');
      
      // a) Öğün tipi aynı mı?
      expect(altYemek.ogun, testYemegi.ogun, reason: 'Alternatif yemeğin öğün tipi (${altYemek.ogun.name}) orijinal yemekle (${testYemegi.ogun.name}) aynı olmalı.');
      
      // b) Alternatif, orijinal yemeğin kendisi mi?
      expect(altYemek.id, isNot(testYemegi.id), reason: 'Alternatif yemek, orijinal yemeğin kendisi olamaz.');
    }

    AppLogger.success('✅ Tüm alternatifler doğrulandı!');
    AppLogger.info('--- 🍲 ALTERNATİF YEMEK SİSTEMİ TESTİ BAŞARIYLA TAMAMLANDI ---');
  });
}
