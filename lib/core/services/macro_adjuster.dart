// lib/core/services/macro_adjuster.dart
// Otomatik düzeltme: C -> Y -> P sırası, 3 iterasyon
import 'dart:math' as math;
import '../validators/macro_validator.dart';
import 'db_standardizer.dart';

class AdjusterConfig {
  final List<String> carbIds;
  final List<String> fatIds;
  final List<String> proteinIds;
  final String fiberHelperId; // lif takviyesi için sebze
  final double maxDeltaGramPerItem; // tek adımda en fazla değişim
  final double minStepGram; // çok küçük dalgalanmaları ignore

  const AdjusterConfig({
    this.carbIds = const ['pirinc_pis', 'bulgur_pis', 'yulaf_kuru'],
    this.fatIds = const ['zeytinyagi', 'findik'],
    this.proteinIds = const ['tavuk_gogus_pis', 'yumurta', 'whey_scoop'],
    this.fiberHelperId = 'sebze_karisik',
    this.maxDeltaGramPerItem = 200,
    this.minStepGram = 5,
  });
}

class MacroAdjuster {
  final AdjusterConfig cfg;

  const MacroAdjuster({this.cfg = const AdjusterConfig()});

  MealPlan adjust({
    required MealPlan plan,
    required StandardizedFoodDB db,
    required MacroTargets targets,
    Profile? profile,
    int maxTries = 3,
  }) {
    MealPlan cur = plan;

    for (int attempt = 0; attempt < maxTries; attempt++) {
      final totals = computePlanTotals(cur, db);
      final rep = checkTolerance(totals, targets);
      if (rep.allOk) return cur;

      // Önce Carb -> sonra Fat -> sonra Protein
      if (!rep.carbsOk) {
        final need = _deltaRange(totals.carbsG, targets.carbsMinG, targets.carbsMaxG);
        cur = _tuneMacro(cur, db, macro: 'carb', deltaG: need);
      }

      if (!rep.fatOk) {
        final need = _deltaRange(totals.fatG, targets.fatMinG, targets.fatMaxG);
        cur = _tuneMacro(cur, db, macro: 'fat', deltaG: need);
      }

      if (!rep.proteinOk) {
        final need = _deltaRange(totals.proteinG, targets.proteinMinG, targets.proteinMaxG);
        cur = _tuneMacro(cur, db, macro: 'protein', deltaG: need);
      }

      // Fiber min'i sağla
      final totals2 = computePlanTotals(cur, db);
      if (totals2.fiberG < targets.fiberMinG && db.hasFood(cfg.fiberHelperId)) {
        final addG = math.max(0, (targets.fiberMinG - totals2.fiberG)) /
            math.max(0.1, db.getPer100g(cfg.fiberHelperId)!.fiberPer100g) * 100.0;
        cur = _ensureAndBump(cur, cfg.fiberHelperId, addG.clamp(0, cfg.maxDeltaGramPerItem));
      }

      // Döngü devam eder; en fazla maxTries
    }
    return cur; // Son hali döndür (kısmen düzelmiş olabilir)
  }

  /// Gerekli delta: hedef aralığına girmek için negatif ise azalt, pozitif ise arttır.
  double _deltaRange(double val, double min, double max) {
    if (val < min) return (min - val);
    if (val > max) return (max - val) * -1;
    return 0;
  }

  MealPlan _tuneMacro(MealPlan plan, StandardizedFoodDB db, {required String macro, required double deltaG}) {
    if (deltaG.abs() < 0.1) return plan;
    final ids = (macro == 'carb')
        ? cfg.carbIds
        : (macro == 'fat')
            ? cfg.fatIds
            : cfg.proteinIds;

    // Birden fazla öğüne küçük paylarla dağıt
    final perItemAdjust = (String id) {
      final nut = db.getPer100g(id);
      if (nut == null) return 0.0;

      final per100 =
          (macro == 'carb') ? nut.carbsPer100g : (macro == 'fat') ? nut.fatPer100g : nut.proteinPer100g;
      if (per100 <= 0) return 0.0;

      // Gram = ihtiyaç(g) * 100 / (per100g değeri)
      return (deltaG * 100.0) / per100;
    };

    MealPlan cur = plan;
    double remaining = deltaG;

    for (final id in ids) {
      if (remaining.abs() < (macro == 'fat' ? 1.0 : 2.0)) break; // yeterince yakın

      final g = perItemAdjust(id);
      if (g.abs() < cfg.minStepGram) continue;

      final clamped = g.clamp(-cfg.maxDeltaGramPerItem, cfg.maxDeltaGramPerItem).toDouble();
      cur = _ensureAndBump(cur, id, clamped);
      // kalan ihtiyacı güncelle
      final nut = db.getPer100g(id)!;
      final deltaByThis = (clamped / 100.0) *
          ((macro == 'carb') ? nut.carbsPer100g : (macro == 'fat') ? nut.fatPer100g : nut.proteinPer100g);
      remaining -= deltaByThis;
    }

    return cur;
  }

  MealPlan _ensureAndBump(MealPlan plan, String foodId, double gramDelta) {
    if (plan.meals.isEmpty) {
      return MealPlan(day: plan.day, meals: [
        Meal(name: 'Öğün 1', items: [MealItem(foodId: foodId, grams: math.max(0, gramDelta))])
      ]);
    }

    // Basit strateji: son öğünde ayarla; yoksa ekle
    final meals = plan.meals.map((m) => m).toList();
    Meal last = meals.last;
    final idx = last.items.indexWhere((it) => it.foodId == foodId);
    if (idx >= 0) {
      final it = last.items[idx];
      final newG = math.max(0, it.grams + gramDelta);
      last.items[idx] = it.copyWith(grams: _round1(newG));
    } else {
      if (gramDelta > 0) {
        last.items.add(MealItem(foodId: foodId, grams: _round1(gramDelta)));
      } // azaltma gerekiyorsa ve yoksa, pas
    }
    meals[meals.length - 1] = last;
    return MealPlan(day: plan.day, meals: meals);
  }

  double _round1(double v) => double.parse(v.toStringAsFixed(1));
}