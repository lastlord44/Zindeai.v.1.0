// data/datasources/yemek_local_data_source.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/yemek.dart';
import '../../core/utils/app_logger.dart';
import '../models/yemek_model.dart';

/// Local JSON dosyalarından yemek verisi çeken data source
class YemekLocalDataSource {
  /// Belirli bir öğün tipine ait yemekleri yükle (tüm batch dosyalarından)
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    try {
      AppLogger.info('${ogun.ad} için yemekler yükleniyor...');

      // Tüm batch dosyalarını yükle
      final tumYemekler = await _tumBatchleriYukle(ogun);

      AppLogger.info('${ogun.ad} için ${tumYemekler.length} yemek yüklendi');
      return tumYemekler;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Yemek yükleme hatası: ${ogun.ad}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Tüm öğünleri paralel olarak yükle (performans için)
  Future<Map<OgunTipi, List<Yemek>>> tumYemekleriYukle() async {
    try {
      AppLogger.info('Tüm yemekler yükleniyor...');

      // Tüm öğünler için paralel yükleme
      final futures = OgunTipi.values.map((ogun) async {
        final yemekler = await yemekleriYukle(ogun);
        return MapEntry(ogun, yemekler);
      });

      // Tümünü bekle
      final results = await Future.wait(futures);

      // Map'e çevir
      final yemekMap = Map.fromEntries(results);

      final toplamYemek = yemekMap.values.fold<int>(
        0,
        (toplam, liste) => toplam + liste.length,
      );

      AppLogger.success('✅ $toplamYemek yemek başarıyla yüklendi');
      return yemekMap;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Toplu yemek yükleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Belirli kriterlere göre yemek filtrele
  Future<List<Yemek>> yemekleriFiltrele({
    OgunTipi? ogun,
    double? minKalori,
    double? maxKalori,
    List<String>? kisitlamalar,
    List<String>? tercihler,
    Zorluk? zorluk,
  }) async {
    // Yemekleri yükle
    final tumYemekler = ogun != null
        ? await yemekleriYukle(ogun)
        : (await tumYemekleriYukle()).values.expand((x) => x).toList();

    // Filtreleme
    var filtrelenmis = tumYemekler;

    // Kalori filtresi
    if (minKalori != null) {
      filtrelenmis = filtrelenmis.where((y) => y.kalori >= minKalori).toList();
    }
    if (maxKalori != null) {
      filtrelenmis = filtrelenmis.where((y) => y.kalori <= maxKalori).toList();
    }

    // Kısıtlama filtresi (alerji vb)
    if (kisitlamalar != null && kisitlamalar.isNotEmpty) {
      filtrelenmis = filtrelenmis
          .where((y) => y.kisitlamayaUygunMu(kisitlamalar))
          .toList();
    }

    // Tercih filtresi
    if (tercihler != null && tercihler.isNotEmpty) {
      filtrelenmis =
          filtrelenmis.where((y) => y.tercihUygunMu(tercihler)).toList();
    }

    // Zorluk filtresi
    if (zorluk != null) {
      filtrelenmis = filtrelenmis.where((y) => y.zorluk == zorluk).toList();
    }

    AppLogger.debug('Filtreleme sonucu: ${filtrelenmis.length} yemek');
    return filtrelenmis;
  }

  /// ID'ye göre yemek bul
  Future<Yemek?> yemekBul(String id) async {
    final tumYemekler = await tumYemekleriYukle();

    for (final yemekListesi in tumYemekler.values) {
      try {
        return yemekListesi.firstWhere((y) => y.id == id);
      } catch (_) {
        continue;
      }
    }

    AppLogger.warning('Yemek bulunamadı: $id');
    return null;
  }

  /// Öğün tipi için tüm dosyaları yükle (batch_01 ve batch_02)
  Future<List<Yemek>> _tumBatchleriYukle(OgunTipi ogun) async {
    final tumYemekler = <Yemek>[];
    final dosyaAdlari = _ogunTipiBatchDosyalari(ogun);

    for (final dosyaAdi in dosyaAdlari) {
      try {
        AppLogger.debug('Yükleniyor: assets/data/$dosyaAdi');
        final jsonString = await rootBundle.loadString('assets/data/$dosyaAdi');
        final List<dynamic> jsonList = json.decode(jsonString);
        final models = jsonList
            .map((json) => YemekModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final entities = models.map((model) => model.toEntity()).toList();
        tumYemekler.addAll(entities);
        AppLogger.debug('  → ${entities.length} yemek eklendi');
      } catch (e) {
        AppLogger.warning('  → $dosyaAdi yüklenemedi, atlanıyor: $e');
        // Hata durumunda devam et, diğer batch'leri yükle
      }
    }

    return tumYemekler;
  }

  /// Öğün tipi için batch dosya adlarını döndür
  List<String> _ogunTipiBatchDosyalari(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return ['kahvalti_batch_01.json', 'kahvalti_batch_02.json'];
      case OgunTipi.araOgun1:
        return ['ara_ogun_1_batch_01.json', 'ara_ogun_1_batch_02.json'];
      case OgunTipi.ogle:
        return ['ogle_yemegi_batch_01.json', 'ogle_yemegi_batch_02.json'];
      case OgunTipi.araOgun2:
        return ['ara_ogun_2_batch_01.json', 'ara_ogun_2_batch_02.json'];
      case OgunTipi.aksam:
        return ['aksam_yemegi_batch_01.json', 'aksam_yemegi_batch_02.json'];
      case OgunTipi.geceAtistirma:
        return ['gece_atistirmasi.json'];
      case OgunTipi.cheatMeal:
        return ['cheat_meal.json'];
    }
  }
}
