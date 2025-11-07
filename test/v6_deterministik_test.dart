// test/v6_deterministik_test.dart
// Unit + Integration + Regression + Basit Benchmark

import 'package:test/test.dart';
import 'dart:math' as math;

import '../lib/core/validators/macro_validator.dart';
import '../lib/core/services/macro_adjuster.dart';
import '../lib/domain/services/ai_beslenme_servisi_v6.dart';

// --- Stub AiClient ---
class StubAiClient implements AiClient {
  @override
  Future<String> complete({required String systemPrompt, required String userMessage}) async {
    // Kasten biraz sapmalı bir plan döndür (protein düşük) – adjuster düzeltsin
    return '''
{
  "day": "2025-11-07",
  "meals": [
    {"name": "Kahvaltı", "items": [
      {"food_id": "yulaf_kuru", "grams": 80},
      {"food_id": "yogurt", "grams": 200},
      {"food_id": "muz", "grams": 150}
    ]},
    {"name": "Öğle", "items": [
      {"food_id": "pirinc_pis", "grams": 400},
      {"food_id": "sebze_karisik", "grams": 200}
    ]},
    {"name": "Antrenman Sonrası", "items": [
      {"food_id": "whey_scoop", "grams": 30}
    ]},
    {"name": "Akşam", "items": [
      {"food_id": "somon_pis", "grams": 120},
      {"food_id": "bulgur_pis", "grams": 250}
    ]}
  ]
}
''';
  }
}

void main() {
  group('MacroValidator', () {
    test('BMR/TDEE hesaplama ve hedef önerileri', () {
      final profile = Profile(sex: Sex.male, age: 37, heightCm: 178, weightKg: 73, workoutsPerWeek: 4);
      final bmr = mifflinStJeorBmr(weightKg: profile.weightKg, heightCm: profile.heightCm, age: profile.age, sex: profile.sex);
      expect(bmr, closeTo(1662.5, 0.5));

      final tdee = tdeeFromBmr(bmr: bmr, workoutsPerWeek: profile.workoutsPerWeek);
      expect(tdee, closeTo(2577, 10));

      final targets = suggestTargets(profile: profile, tdee: tdee, goal: 'lean_bulk', surplusPct: 0.12);
      expect(targets.caloriesKcal, closeTo(2887, 60));
      expect(targets.proteinMin, closeTo(1.8 * 73, 0.1));
      expect(targets.fiberMin, greaterThanOrEqualTo(30));
    });
  });

  group('Adjuster + Validator Integration', () {
    // Minimal DB (standardize edilmiş varsayımı ile)
    final db = <String, StandardFood>{
      'pirinc_pis': StandardFood(id: 'pirinc_pis', per100g: Macronutrients(kcal: 130, p: 2.4, c: 28.7, f: 0.3, fiber: 0.4, satFat: 0)),
      'bulgur_pis': StandardFood(id: 'bulgur_pis', per100g: Macronutrients(kcal: 83, p: 3.1, c: 18.6, f: 0.2, fiber: 2.0, satFat: 0)),
      'tavuk_gogus_pis': StandardFood(id: 'tavuk_gogus_pis', per100g: Macronutrients(kcal: 165, p: 31, c: 0, f: 3.6)),
      'somon_pis': StandardFood(id: 'somon_pis', per100g: Macronutrients(kcal: 208, p: 20, c: 0, f: 13)),
      'zeytinyagi': StandardFood(id: 'zeytinyagi', per100g: Macronutrients(kcal: 884, p: 0, c: 0, f: 100)),
      'yulaf_kuru': StandardFood(id: 'yulaf_kuru', per100g: Macronutrients(kcal: 389, p: 16.9, c: 66.3, f: 6.9, fiber: 10.6)),
      'whey_scoop': StandardFood(id: 'whey_scoop', per100g: Macronutrients(kcal: 400, p: 80, c: 10, f: 5)), // 30g scoop ≈ 120kcal
      'yogurt': StandardFood(id: 'yogurt', per100g: Macronutrients(kcal: 61, p: 3.5, c: 4.7, f: 3.3)),
      'muz': StandardFood(id: 'muz', per100g: Macronutrients(kcal: 89, p: 1.1, c: 22.8, f: 0.3)),
      'sebze_karisik': StandardFood(id: 'sebze_karisik', per100g: Macronutrients(kcal: 40, p: 2, c: 7, f: 0.5, fiber: 3)),
      'findik': StandardFood(id: 'findik', per100g: Macronutrients(kcal: 628, p: 15, c: 17, f: 61, fiber: 10)),
    };

    test('Adjuster 3 denemede toleransa sokuyor', () {
      final profile = Profile(sex: Sex.male, age: 37, heightCm: 178, weightKg: 73, workoutsPerWeek: 4);
      final tdee = tdeeFromBmr(bmr: mifflinStJeorBmr(weightKg: 73, heightCm: 178, age: 37, sex: Sex.male), workoutsPerWeek: 4);
      final targets = suggestTargets(profile: profile, tdee: tdee, goal: 'lean_bulk', surplusPct: 0.12);

      final initialPlan = DailyPlan(day: '2025-11-07', meals: [
        Meal(name: 'Kahvaltı', items: [
          MealItem(foodId: 'yulaf_kuru', grams: 60),
          MealItem(foodId: 'yogurt', grams: 150),
          MealItem(foodId: 'muz', grams: 120),
        ]),
        Meal(name: 'Öğle', items: [
          MealItem(foodId: 'pirinc_pis', grams: 350),
          MealItem(foodId: 'sebze_karisik', grams: 200),
        ]),
        Meal(name: 'Antrenman Sonrası', items: [
          MealItem(foodId: 'whey_scoop', grams: 25),
        ]),
        Meal(name: 'Akşam', items: [
          MealItem(foodId: 'somon_pis', grams: 100),
          MealItem(foodId: 'bulgur_pis', grams: 200),
        ]),
      ]);

      final rep0 = validatePlan(plan: initialPlan, db: db, targets: targets);
      expect(rep0.withinAll, isFalse);

      final adjusted = MacroAdjuster.adjustPlan(
        plan: initialPlan,
        db: db,
        targets: targets,
        config: AdjusterConfig.defaultTR(),
        maxAttempts: 3,
      );

      final rep1 = validatePlan(plan: adjusted.plan, db: db, targets: targets);
      expect(rep1.withinAll, isTrue, reason: '3 denemede toleransa girmeli.\nLog:\n${adjusted.log.join('\n')}');
    });

    test('AI servisinin çıktısı parse + validate + auto-correct akışı', () async {
      final svc = AiBeslenmeServisiV6(client: StubAiClient(), adjusterConfig: AdjusterConfig.defaultTR());

      final profile = Profile(sex: Sex.male, age: 37, heightCm: 178, weightKg: 73, workoutsPerWeek: 4);
      final tdee = tdeeFromBmr(bmr: mifflinStJeorBmr(weightKg: 73, heightCm: 178, age: 37, sex: Sex.male), workoutsPerWeek: 4);
      final targets = suggestTargets(profile: profile, tdee: tdee, goal: 'lean_bulk', surplusPct: 0.12);

      final plan = await svc.generateValidatedPlan(
        profile: profile,
        targets: targets,
        db: db,
        dayIso: '2025-11-07',
      );

      final rep = validatePlan(plan: plan, db: db, targets: targets);
      expect(rep.withinAll, isTrue);
    });

    test('Regression: per-meal protein eşiği', () {
      final targets = MacroTargets(
        caloriesKcal: 2500,
        proteinMin: 140, proteinMax: 170,
        carbsMin: 300, carbsMax: 360,
        fatMin: 60, fatMax: 90,
        fiberMin: 30,
        kcalTolerancePct: 0.05,
        proteinPerMealMin: 20, // örnek eşik
      );

      final plan = DailyPlan(day: '2025-11-07', meals: [
        Meal(name: 'Kahvaltı', items: [MealItem(foodId: 'yulaf_kuru', grams: 50)]), // protein düşük
        Meal(name: 'Öğle', items: [MealItem(foodId: 'tavuk_gogus_pis', grams: 150)]),
      ]);

      final rep = validatePlan(plan: plan, db: db, targets: targets);
      expect(rep.perMealProteinOk, isFalse);
    });

    test('Benchmark (bilgi amaçlı)', () {
      final profile = Profile(sex: Sex.male, age: 37, heightCm: 178, weightKg: 73, workoutsPerWeek: 4);
      final tdee = tdeeFromBmr(bmr: mifflinStJeorBmr(weightKg: 73, heightCm: 178, age: 37, sex: Sex.male), workoutsPerWeek: 4);
      final targets = suggestTargets(profile: profile, tdee: tdee, goal: 'lean_bulk', surplusPct: 0.12);

      final plan = DailyPlan(day: '2025-11-07', meals: [
        Meal(name: 'A', items: [MealItem(foodId: 'pirinc_pis', grams: 500)]),
        Meal(name: 'B', items: [MealItem(foodId: 'tavuk_gogus_pis', grams: 200)]),
        Meal(name: 'C', items: [MealItem(foodId: 'zeytinyagi', grams: 15)]),
        Meal(name: 'D', items: [MealItem(foodId: 'bulgur_pis', grams: 300)]),
      ]);

      final sw = Stopwatch()..start();
      final adjusted = MacroAdjuster.adjustPlan(
        plan: plan,
        db: db,
        targets: targets,
        config: AdjusterConfig.defaultTR(),
        maxAttempts: 3,
      );
      sw.stop();
      // Bilgi amaçlı çıktı:
      // ignore: avoid_print
      print('Adjuster time: ${sw.elapsedMilliseconds} ms; attempts=${adjusted.attempts}');
      expect(adjusted.plan.meals.length, greaterThan(0));
    });
  });
}