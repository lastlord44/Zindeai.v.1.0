// data/datasources/yemek_local_data_source.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/yemek.dart';
import '../../core/utils/app_logger.dart';
import '../models/yemek_model.dart';

/// Local JSON dosyalarından yemek verisi çeken data source
class YemekLocalDataSource {
  /// Belirli bir öğün tipine ait yemekleri yükle
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    try {
      final dosyaAdi = _ogunTipiDosyaAdi(ogun);
      AppLogger.debug('Yükleniyor: assets/data/$dosyaAdi');

      // JSON dosyasını oku
      final jsonString = await rootBundle.loadString('assets/data/$dosyaAdi');

      // Parse et
      final List<dynamic> jsonList = json.decode(jsonString);

      // Model'lere çevir
      final models = jsonList
          .map((json) => YemekModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Entity'lere dönüştür
      final entities = models.map((model) => model.toEntity()).toList();

      AppLogger.info('${ogun.ad} için ${entities.length} yemek yüklendi');
      return entities;
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

  /// Öğün tipi için dosya adı belirle
  String _ogunTipiDosyaAdi(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return 'kahvalti.json';
      case OgunTipi.araOgun1:
        return 'ara_ogun_1.json';
      case OgunTipi.ogle:
        return 'ogle.json';
      case OgunTipi.araOgun2:
        return 'ara_ogun_2.json';
      case OgunTipi.aksam:
        return 'aksam.json';
      case OgunTipi.geceAtistirma:
        return 'gece_atistirma.json';
      case OgunTipi.cheatMeal:
        return 'cheat_meal.json';
    }
  }
}
