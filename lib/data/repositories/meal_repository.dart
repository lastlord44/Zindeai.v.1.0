import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../models/meal.dart';

// ============================================================================
// ISOLATE PARSER FUNCTION
// ============================================================================

Future<List<Meal>> _parseOnIsolate(String jsonStr) async {
  return Meal.listFromJsonString(jsonStr);
}

// ============================================================================
// MEAL REPOSITORY
// ============================================================================

class MealRepository {
  // Asset dosya yolları
  static const _assetFiles = <String>[
    'assets/data/kahvalti_batch_01.json',
    'assets/data/kahvalti_batch_02.json',
    'assets/data/ara_ogun_1_batch_01.json',
    'assets/data/ara_ogun_1_batch_02.json',
    'assets/data/ogle_yemegi_batch_01.json',
    'assets/data/ogle_yemegi_batch_02.json',
    'assets/data/ara_ogun_2_batch_01.json',
    'assets/data/ara_ogun_2_batch_02.json',
    'assets/data/aksam_yemegi_batch_01.json',
    'assets/data/aksam_yemegi_batch_02.json',
    'assets/data/gece_atistirmasi.json',
    'assets/data/cheat_meal.json',
  ];

  /// Tüm öğünleri yükler (paralel yükleme ile)
  Future<List<Meal>> loadAll() async {
    try {
      // Paralel olarak tüm dosyaları yükle
      final futures = _assetFiles.map((path) async {
        try {
          final jsonStr = await rootBundle.loadString(path, cache: true);
          return compute(_parseOnIsolate, jsonStr);
        } catch (e) {
          print('❌ Dosya yüklenirken hata: $path - $e');
          return <Meal>[];
        }
      }).toList();

      final chunks = await Future.wait(futures);
      final all = <Meal>[];
      final ids = <String>{};

      // Tüm parçaları birleştir ve tekrar edenleri filtrele
      for (final list in chunks) {
        for (final meal in list) {
          if (ids.add(meal.mealId)) {
            all.add(meal);
          } else {
            print('⚠️ Çakışan meal_id atlandı: ${meal.mealId}');
          }
        }
      }

      print('✅ ${all.length} öğün başarıyla yüklendi!');
      return all;
    } catch (e) {
      print('❌ Öğünler yüklenirken hata oluştu: $e');
      return [];
    }
  }

  /// Belirli bir kategoriye göre öğünleri filtreler
  Future<List<Meal>> byCategory(MealCategory category) async {
    final all = await loadAll();
    return all.where((m) => m.category == category).toList();
  }

  /// Belirli bir hedefe göre öğünleri filtreler
  Future<List<Meal>> byGoalTag(GoalTag goalTag) async {
    final all = await loadAll();
    return all.where((m) => m.goalTag == goalTag).toList();
  }

  /// Kalori aralığına göre filtreler
  Future<List<Meal>> byCalorieRange({
    required int minCalorie,
    required int maxCalorie,
  }) async {
    final all = await loadAll();
    return all
        .where((m) => m.calorie >= minCalorie && m.calorie <= maxCalorie)
        .toList();
  }
}
