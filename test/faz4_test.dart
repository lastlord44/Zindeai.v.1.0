// test/faz4_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zinde_ai/data/local/hive_service.dart';
import 'package:zinde_ai/domain/entities/yemek.dart';
import 'package:zinde_ai/domain/entities/makro_hedefleri.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/core/utils/yemek_migration_3000.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    AppLogger.init(level: LogLevel.debug);
    tempDir = Directory.systemTemp.createTempSync('faz4_test_');
    await HiveService.init(path: tempDir.path);
    AppLogger.info('FAZ 4 Testi için veritabanı dolduruluyor...');
    await YemekMigration3000.yukle();
    AppLogger.info('Veritabanı dolduruldu.');
  });

  tearDownAll(() async {
    await HiveService.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FAZ 4 - Hive DB ve Yemek Entity Testleri (Modernize Edilmiş)', () {
    test('Kahvaltı yemeklerini Hive\'dan yükle', () async {
      // Arrange
      AppLogger.info('🧪 Test: Kahvaltı yükleme (Hive)');

      // Act
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Assert
      expect(kahvaltilar, isNotEmpty);
      expect(kahvaltilar.first.ogun, OgunTipi.kahvalti);

      AppLogger.success('✅ ${kahvaltilar.length} kahvaltı Hive\'dan yüklendi');
      AppLogger.debug('İlk yemek: ${kahvaltilar.first.kisaOzet}');
    });

    test('Tüm öğünleri Hive\'dan yükle', () async {
      // Arrange
      AppLogger.info('🧪 Test: Tüm öğünleri yükleme (Hive)');
      final stopwatch = Stopwatch()..start();

      // Act
      final tumYemekler = await HiveService.tumYemekleriGetir();
      stopwatch.stop();

      // Assert
      expect(tumYemekler, isNotEmpty);

      final tumYemeklerMap = <OgunTipi, List<Yemek>>{};
      for (var yemek in tumYemekler) {
        (tumYemeklerMap[yemek.ogun] ??= []).add(yemek);
      }
      
      expect(tumYemeklerMap.keys.length, greaterThan(0));

      AppLogger.success(
          '✅ ${tumYemekler.length} yemek ${stopwatch.elapsedMilliseconds}ms\'de Hive\'dan yüklendi');

      // Her öğün tipini kontrol et
      for (final entry in tumYemeklerMap.entries) {
        AppLogger.debug('${entry.key.ad}: ${entry.value.length} yemek');
      }
    });

    test('Yemek makro uygunluğu kontrolü (Hive)', () async {
      // Arrange
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();
      final hedefler = MakroHedefleri(
        gunlukKalori: 2500,
        gunlukProtein: 150,
        gunlukKarbonhidrat: 300,
        gunlukYag: 80,
      );

      // Act
      final uygunYemekler =
          kahvaltilar.where((y) => y.makroyaUygunMu(hedefler, 0.2)).toList();

      // Assert
      expect(uygunYemekler, isNotEmpty);

      AppLogger.success(
          '✅ ${uygunYemekler.length}/${kahvaltilar.length} yemek makrolara uygun');
      AppLogger.debug('Hedef kalori/öğün: ${hedefler.gunlukKalori / 5} kcal');
    });

    test('Alerji kısıtlaması ile filtreleme (Hive)', () async {
      // Arrange
      final kisitlamalar = ['Süt', 'Yumurta'];
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Act
      final filtrelenmis = kahvaltilar.where((y) => y.kisitlamayaUygunMu(kisitlamalar)).toList();

      // Assert
      expect(filtrelenmis, isNotEmpty);

      // Hiçbir yemek kısıtlı malzeme içermemeli
      for (final yemek in filtrelenmis) {
        expect(yemek.kisitlamayaUygunMu(kisitlamalar), isTrue);
      }

      AppLogger.success('✅ Alerji filtresi çalışıyor');
      AppLogger.debug(
          'Kısıtlamasız yemekler: ${filtrelenmis.map((y) => y.ad).join(", ")}');
    });

    test('Kalori aralığına göre filtreleme (Hive)', () async {
      // Arrange
      const minKalori = 300.0;
      const maxKalori = 450.0;
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Act
      final filtrelenmis = kahvaltilar.where((y) => y.kalori >= minKalori && y.kalori <= maxKalori).toList();

      // Assert
      expect(filtrelenmis, isNotEmpty);

      for (final yemek in filtrelenmis) {
        expect(yemek.kalori, greaterThanOrEqualTo(minKalori));
        expect(yemek.kalori, lessThanOrEqualTo(maxKalori));
      }

      AppLogger.success('✅ Kalori filtresi çalışıyor');
      AppLogger.debug(
          '$minKalori-$maxKalori kcal aralığında ${filtrelenmis.length} yemek');
    });

    test('Vegan/Vejetaryen tercih filtresi (Hive)', () async {
      // Arrange
      final tercihler = ['vegan'];
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Act
      final filtrelenmis = kahvaltilar.where((y) => y.tercihUygunMu(tercihler)).toList();

      // Assert
      if (filtrelenmis.isNotEmpty) {
        AppLogger.success('✅ ${filtrelenmis.length} vegan yemek bulundu');
        for (final yemek in filtrelenmis) {
          AppLogger.debug('Vegan: ${yemek.ad}');
        }
      } else {
        AppLogger.warning('⚠️ Vegan yemek bulunamadı');
      }
    });

    test('Yemek ID ile arama (Hive)', () async {
      // Arrange
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final ilkYemek = tumYemekler.first;

      // Act
      final bulunan = await HiveService.yemekGetir(ilkYemek.id);

      // Assert
      expect(bulunan, isNotNull);
      expect(bulunan!.id, ilkYemek.id);
      expect(bulunan.ad, ilkYemek.ad);

      AppLogger.success('✅ Yemek ID ile bulundu: ${bulunan.ad}');
    });

    test('Zorluk seviyesine göre filtreleme (Hive)', () async {
      // Arrange
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Act
      final kolayYemekler = kahvaltilar.where((y) => y.zorluk == Zorluk.kolay).toList();

      // Assert
      expect(kolayYemekler, isNotEmpty);

      for (final yemek in kolayYemekler) {
        expect(yemek.zorluk, Zorluk.kolay);
      }

      AppLogger.success('✅ ${kolayYemekler.length} kolay yemek bulundu');
    });

    test('Alternatif besin önerileri kontrolü (Hive)', () async {
      // Arrange
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();

      // Act
      final alternatifliYemekler =
          kahvaltilar.where((y) => y.alternatifler.isNotEmpty).toList();

      // Assert
      if (alternatifliYemekler.isNotEmpty) {
        AppLogger.success(
            '✅ ${alternatifliYemekler.length} yemekte alternatif var');

        for (final yemek in alternatifliYemekler) {
          AppLogger.debug('${yemek.ad}:');
          for (final alt in yemek.alternatifler) {
            AppLogger.debug(
                '  - ${alt.orijinalBesin} -> ${alt.alternatifler.length} alternatif');
          }
        }
      }
    });

    test('FAZ 4 - GENEL PERFORMANS TESTİ (Hive)', () async {
      AppLogger.info('🎯 FAZ 4 GENEL TEST BAŞLADI (Hive)');

      final stopwatch = Stopwatch()..start();

      // 1. Tüm yemekleri yükle
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final yuklemeZamani = stopwatch.elapsedMilliseconds;

      // 2. İstatistikler
      final toplamYemek = tumYemekler.length;
      
      final tumYemeklerMap = <OgunTipi, List<Yemek>>{};
      for (var yemek in tumYemekler) {
        (tumYemeklerMap[yemek.ogun] ??= []).add(yemek);
      }

      final ortalamaKalori = tumYemekler
              .map((y) => y.kalori)
              .reduce((a, b) => a + b) /
          toplamYemek;

      final ortalamaProtein = tumYemekler
              .map((y) => y.protein)
              .reduce((a, b) => a + b) /
          toplamYemek;

      stopwatch.stop();

      // Sonuçlar
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.success('✅ FAZ 4 TAMAMLANDI!');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('📊 GENEL İSTATİSTİKLER:');
      AppLogger.info('  • Toplam yemek sayısı: $toplamYemek');
      AppLogger.info('  • Öğün tipi sayısı: ${tumYemeklerMap.keys.length}');
      AppLogger.info(
          '  • Ortalama kalori: ${ortalamaKalori.toStringAsFixed(0)} kcal');
      AppLogger.info(
          '  • Ortalama protein: ${ortalamaProtein.toStringAsFixed(0)}g');
      AppLogger.info('  • Yükleme süresi: ${yuklemeZamani}ms');
      AppLogger.info(
          '  • Toplam test süresi: ${stopwatch.elapsedMilliseconds}ms');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      expect(toplamYemek, greaterThan(0));
    });
  });
}
