// lib/core/services/db_standardizer.dart
// 100g pişmiş bazlı standardizasyon + NutrientProvider implementasyonu
import 'dart:math' as math;
import '../validators/macro_validator.dart';

enum MeasureType { per100g, perUnit }
enum FoodState { raw, cooked }

class FoodRecordRaw {
  final String id;
  final MeasureType measure;
  final FoodState state;
  final double? unitWeightG; // perUnit ise zorunlu
  // Besinler (ölçü türüne göre per100g veya perUnit)
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double satFatG;

  FoodRecordRaw({
    required this.id,
    required this.measure,
    required this.state,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.satFatG = 0,
    this.unitWeightG,
  });
}

class StandardizationConfig {
  /// Çiğ -> pişmiş verim (kütle) katsayısı. Örn: pirinç ≈ 2.8
  final Map<String, double> rawToCookedYieldFactor;

  /// Pişirme kaybı (makro sönümlenmesi), 0.90–1.00 arası önerilir.
  final double macroLossFactor;

  const StandardizationConfig({
    this.rawToCookedYieldFactor = const {
      'pirinc': 2.8,
      'bulgur': 2.5,
      'makarna': 2.4,
      'yulaf': 1.0,
      'tavuk_gogus': 1.0,
      'somon': 1.0,
    },
    this.macroLossFactor = 0.97,
  });
}

class StandardizedFoodDB implements NutrientProvider {
  final Map<String, NutrientSnapshot> _per100gCooked = {};

  StandardizedFoodDB._();

  factory StandardizedFoodDB.fromRaw(List<FoodRecordRaw> raws, {StandardizationConfig config = const StandardizationConfig()}) {
    final db = StandardizedFoodDB._();

    NutrientSnapshot per100FromUnit(FoodRecordRaw r) {
      if (r.unitWeightG == null || r.unitWeightG! <= 0) {
        throw ArgumentError('unitWeightG yok veya geçersiz: ${r.id}');
      }
      final factor = 100.0 / r.unitWeightG!;
      return NutrientSnapshot(
        kcalPer100g: r.kcal * factor,
        proteinPer100g: r.proteinG * factor,
        carbsPer100g: r.carbsG * factor,
        fatPer100g: r.fatG * factor,
        fiberPer100g: r.fiberG * factor,
        satFatPer100g: r.satFatG * factor,
      );
    }

    NutrientSnapshot maybeApplyCooking(FoodRecordRaw r, NutrientSnapshot snap) {
      if (r.state == FoodState.cooked) return snap;
      // Çiğ ise yield faktörü biliniyorsa uygula (100 g pişmiş = 100 / yield g çiğ)
      final key = _guessKeyFromId(r.id);
      final y = config.rawToCookedYieldFactor[key];
      if (y == null || y <= 0) return snap; // veri yoksa dokunma
      final loss = config.macroLossFactor.clamp(0.85, 1.0);
      return NutrientSnapshot(
        kcalPer100g: (snap.kcalPer100g / y) * loss,
        proteinPer100g: (snap.proteinPer100g / y) * loss,
        carbsPer100g: (snap.carbsPer100g / y) * loss,
        fatPer100g: (snap.fatPer100g / y) * loss,
        fiberPer100g: (snap.fiberPer100g / y) * loss,
        satFatPer100g: (snap.satFatPer100g / y) * loss,
      );
    }

    for (final r in raws) {
      NutrientSnapshot base;
      if (r.measure == MeasureType.per100g) {
        base = NutrientSnapshot(
          kcalPer100g: _nz(r.kcal),
          proteinPer100g: _nz(r.proteinG),
          carbsPer100g: _nz(r.carbsG),
          fatPer100g: _nz(r.fatG),
          fiberPer100g: _nz(r.fiberG),
          satFatPer100g: _nz(r.satFatG),
        );
      } else {
        base = per100FromUnit(r);
      }
      final cooked100 = maybeApplyCooking(r, base);
      db._per100gCooked[r.id] = _sanitize(cooked100);
    }

    return db;
  }

  static String _guessKeyFromId(String id) {
    // id'lerden kök anahtar çıkar (pirinc_pis -> pirinc)
    final i = id.indexOf('_');
    return i == -1 ? id : id.substring(0, i);
  }

  static double _nz(double? v) => v == null || v.isNaN || v.isInfinite ? 0 : math.max(0, v);

  static NutrientSnapshot _sanitize(NutrientSnapshot n) {
    double clip(double v) => v.isNaN || v.isInfinite ? 0 : math.max(0, v);
    return NutrientSnapshot(
      kcalPer100g: clip(n.kcalPer100g),
      proteinPer100g: clip(n.proteinPer100g),
      carbsPer100g: clip(n.carbsPer100g),
      fatPer100g: clip(n.fatPer100g),
      fiberPer100g: clip(n.fiberPer100g),
      satFatPer100g: clip(n.satFatPer100g),
    );
  }

  @override
  NutrientSnapshot? getPer100g(String foodId) => _per100gCooked[foodId];

  @override
  bool hasFood(String foodId) => _per100gCooked.containsKey(foodId);

  Iterable<String> get allIds => _per100gCooked.keys;
}

/// BONUS: Örnek kayıt listesi (istersen testte/seed'de kullan)
List<FoodRecordRaw> exampleRawFoods() => [
  FoodRecordRaw(
    id: 'pirinc_pis',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 130, proteinG: 2.4, carbsG: 28.7, fatG: 0.3, fiberG: 0.4, satFatG: 0.1,
  ),
  FoodRecordRaw(
    id: 'bulgur_pis',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 83, proteinG: 3.1, carbsG: 18.6, fatG: 0.2, fiberG: 2.0, satFatG: 0.0,
  ),
  FoodRecordRaw(
    id: 'tavuk_gogus_pis',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 165, proteinG: 31, carbsG: 0, fatG: 3.6, fiberG: 0.0, satFatG: 1.0,
  ),
  FoodRecordRaw(
    id: 'somon_pis',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 208, proteinG: 20, carbsG: 0, fatG: 13, fiberG: 0.0, satFatG: 2.7,
  ),
  FoodRecordRaw(
    id: 'yulaf_kuru',
    measure: MeasureType.per100g,
    state: FoodState.raw,
    kcal: 389, proteinG: 16.9, carbsG: 66.3, fatG: 6.9, fiberG: 10.6, satFatG: 1.2,
  ),
  FoodRecordRaw(
    id: 'whey_scoop',
    measure: MeasureType.perUnit, unitWeightG: 30,
    state: FoodState.raw,
    kcal: 120, proteinG: 24, carbsG: 3, fatG: 1.5, fiberG: 0.0, satFatG: 0.5,
  ),
  FoodRecordRaw(
    id: 'zeytinyagi',
    measure: MeasureType.per100g,
    state: FoodState.raw,
    kcal: 884, proteinG: 0, carbsG: 0, fatG: 100, fiberG: 0.0, satFatG: 14.0,
  ),
  FoodRecordRaw(
    id: 'yogurt',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 61, proteinG: 3.5, carbsG: 4.7, fatG: 3.3, fiberG: 0.0, satFatG: 2.1,
  ),
  FoodRecordRaw(
    id: 'muz',
    measure: MeasureType.per100g,
    state: FoodState.raw,
    kcal: 89, proteinG: 1.1, carbsG: 22.8, fatG: 0.3, fiberG: 2.6, satFatG: 0.1,
  ),
  FoodRecordRaw(
    id: 'sebze_karisik',
    measure: MeasureType.per100g,
    state: FoodState.cooked,
    kcal: 40, proteinG: 2, carbsG: 7, fatG: 0.5, fiberG: 3.0, satFatG: 0.1,
  ),
  FoodRecordRaw(
    id: 'findik',
    measure: MeasureType.per100g,
    state: FoodState.raw,
    kcal: 628, proteinG: 15, carbsG: 17, fatG: 61, fiberG: 10, satFatG: 4.5,
  ),
];