// ============================================================================
// lib/data/datasources/yemek_local_data_source.dart
// FAZ 4: JSON PARSER VE DATA SOURCE
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/yemek.dart';

class YemekLocalDataSource {
  /// Tek bir öğün tipinin yemeklerini yükle
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/${ogun.name}.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => Yemek.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ ${ogun.name}.json yüklenemedi: $e');
      return [];
    }
  }

  /// Tüm öğünleri paralel yükle
  Future<Map<OgunTipi, List<Yemek>>> tumYemekleriYukle() async {
    final futures = OgunTipi.values.map((ogun) async {
      final yemekler = await yemekleriYukle(ogun);
      return MapEntry(ogun, yemekler);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// Filtrelenmiş yemekler getir
  Future<List<Yemek>> filtrelenmisYemekleriGetir({
    OgunTipi? ogun,
    List<String>? kisitlamalar,
    double? minProtein,
    double? maxKalori,
    List<String>? etiketler,
  }) async {
    List<Yemek> yemekler;

    if (ogun != null) {
      yemekler = await yemekleriYukle(ogun);
    } else {
      final tumYemeklerMap = await tumYemekleriYukle();
      yemekler = tumYemeklerMap.values.expand((e) => e).toList();
    }

    // Filtreleme
    if (kisitlamalar != null && kisitlamalar.isNotEmpty) {
      yemekler = yemekler
          .where((y) => y.kisitlamayaUygunMu(kisitlamalar))
          .toList();
    }

    if (minProtein != null) {
      yemekler = yemekler.where((y) => y.protein >= minProtein).toList();
    }

    if (maxKalori != null) {
      yemekler = yemekler.where((y) => y.kalori <= maxKalori).toList();
    }

    if (etiketler != null && etiketler.isNotEmpty) {
      yemekler = yemekler.where((y) {
        return etiketler.any((etiket) => y.etiketIceriyorMu(etiket));
      }).toList();
    }

    return yemekler;
  }
}
