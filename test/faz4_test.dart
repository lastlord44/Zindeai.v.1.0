// test/faz4_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:zinde_ai/data/datasources/yemek_local_data_source.dart';
import 'package:zinde_ai/domain/entities/yemek.dart';
import 'package:zinde_ai/domain/entities/makro_hedefleri.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';

void main() {
  late YemekLocalDataSource dataSource;

  setUpAll(() {
    // Logger'ı başlat
    AppLogger.init(isDebug: true);
    dataSource = YemekLocalDataSource();
  });

  group('FAZ 4 - Yemek Entity ve JSON Parser Testleri', () {
    test('Kahvaltı yemeklerini yükle', () async {
      // Arrange
      AppLogger.info('🧪 Test: Kahvaltı yükleme');

      // Act
      final kahvaltilar = await dataSource.yemekleriYukle(OgunTipi.kahvalti);

      // Assert
      expect(kahvaltilar, isNotEmpty);
      expect(kahvaltilar.first.ogun, OgunTipi.kahvalti);

      AppLogger.success('✅ ${kahvaltilar.length} kahvaltı yüklendi');
      AppLogger.debug('İlk yemek: ${kahvaltilar.first.kisaOzet}');
    });

    test('Tüm öğünleri paralel yükle', () async {
      // Arrange
      AppLogger.info('🧪 Test: Tüm öğünleri yükleme');
      final stopwatch = Stopwatch()..start();

      // Act
      final tumYemekler = await dataSource.tumYemekleriYukle();
      stopwatch.stop();

      // Assert
      expect(tumYemekler, isNotEmpty);
      expect(tumYemekler.keys.length, OgunTipi.values.length);

      final toplamYemek = tumYemekler.values.fold<int>(
        0,
        (toplam, liste) => toplam + liste.length,
      );

      AppLogger.success(
          '✅ $toplamYemek yemek ${stopwatch.elapsedMilliseconds}ms\'de yüklendi');

      // Her öğün tipini kontrol et
      for (final entry in tumYemekler.entries) {
        AppLogger.debug('${entry.key.ad}: ${entry.value.length} yemek');
      }
    });

    test('Yemek makro uygunluğu kontrolü', () async {
      // Arrange
      final kahvaltilar = await dataSource.yemekleriYukle(OgunTipi.kahvalti);
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

    test('Alerji kısıtlaması ile filtreleme', () async {
      // Arrange
      final kisitlamalar = ['Süt', 'Yumurta'];

      // Act
      final filtrelenmis = await dataSource.yemekleriFiltrele(
        ogun: OgunTipi.kahvalti,
        kisitlamalar: kisitlamalar,
      );

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

    test('Kalori aralığına göre filtreleme', () async {
      // Arrange
      const minKalori = 300.0;
      const maxKalori = 450.0;

      // Act
      final filtrelenmis = await dataSource.yemekleriFiltrele(
        ogun: OgunTipi.kahvalti,
        minKalori: minKalori,
        maxKalori: maxKalori,
      );

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

    test('Vegan/Vejetaryen tercih filtresi', () async {
      // Arrange
      final tercihler = ['vegan'];

      // Act
      final filtrelenmis = await dataSource.yemekleriFiltrele(
        ogun: OgunTipi.kahvalti,
        tercihler: tercihler,
      );

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

    test('Yemek ID ile arama', () async {
      // Arrange
      final tumYemekler = await dataSource.tumYemekleriYukle();
      final ilkYemek = tumYemekler.values.first.first;

      // Act
      final bulunan = await dataSource.yemekBul(ilkYemek.id);

      // Assert
      expect(bulunan, isNotNull);
      expect(bulunan!.id, ilkYemek.id);
      expect(bulunan.ad, ilkYemek.ad);

      AppLogger.success('✅ Yemek ID ile bulundu: ${bulunan.ad}');
    });

    test('Zorluk seviyesine göre filtreleme', () async {
      // Arrange & Act
      final kolayYemekler = await dataSource.yemekleriFiltrele(
        ogun: OgunTipi.kahvalti,
        zorluk: Zorluk.kolay,
      );

      // Assert
      expect(kolayYemekler, isNotEmpty);

      for (final yemek in kolayYemekler) {
        expect(yemek.zorluk, Zorluk.kolay);
      }

      AppLogger.success('✅ ${kolayYemekler.length} kolay yemek bulundu');
    });

    test('Alternatif besin önerileri kontrolü', () async {
      // Arrange
      final kahvaltilar = await dataSource.yemekleriYukle(OgunTipi.kahvalti);

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

    test('FAZ 4 - GENEL PERFORMANS TESTİ', () async {
      AppLogger.info('🎯 FAZ 4 GENEL TEST BAŞLADI');

      final stopwatch = Stopwatch()..start();

      // 1. Tüm yemekleri yükle
      final tumYemekler = await dataSource.tumYemekleriYukle();
      final yuklemeZamani = stopwatch.elapsedMilliseconds;

      // 2. İstatistikler
      final toplamYemek = tumYemekler.values.fold<int>(
        0,
        (toplam, liste) => toplam + liste.length,
      );

      final ortalamaKalori = tumYemekler.values
              .expand((liste) => liste)
              .map((y) => y.kalori)
              .reduce((a, b) => a + b) /
          toplamYemek;

      final ortalamaProtein = tumYemekler.values
              .expand((liste) => liste)
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
      AppLogger.info('  • Öğün tipi sayısı: ${tumYemekler.keys.length}');
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
