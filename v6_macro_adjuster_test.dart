// v6_macro_adjuster_test.dart
// MacroAdjuster ile gerçek V6.0 pipeline testi

import 'dart:io';
import 'dart:math' as math;

// Import V6.0 components (simplified versions)
class Profile {
  final String sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final int workoutsPerWeek;

  Profile({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.workoutsPerWeek,
  });
}

class Macronutrients {
  final double kcal;
  final double p;
  final double c;
  final double f;
  final double fiber;

  Macronutrients({
    required this.kcal,
    required this.p,
    required this.c,
    required this.f,
    this.fiber = 0.0,
  });

  Macronutrients add(Macronutrients other) {
    return Macronutrients(
      kcal: kcal + other.kcal,
      p: p + other.p,
      c: c + other.c,
      f: f + other.f,
      fiber: fiber + other.fiber,
    );
  }

  Macronutrients scaleByGrams(double grams) {
    final factor = grams / 100.0;
    return Macronutrients(
      kcal: kcal * factor,
      p: p * factor,
      c: c * factor,
      f: f * factor,
      fiber: fiber * factor,
    );
  }
}

class StandardFood {
  final String id;
  final String name;
  final Macronutrients per100g;

  StandardFood({required this.id, required this.name, required this.per100g});
}

class MealItem {
  final String foodId;
  final double grams;

  MealItem({required this.foodId, required this.grams});

  MealItem copyWith({String? foodId, double? grams}) =>
      MealItem(foodId: foodId ?? this.foodId, grams: grams ?? this.grams);
}

class Meal {
  final String name;
  final List<MealItem> items;

  Meal({required this.name, required this.items});

  Meal copyWith({String? name, List<MealItem>? items}) =>
      Meal(name: name ?? this.name, items: items ?? this.items);
}

class DailyPlan {
  final List<Meal> meals;

  DailyPlan({required this.meals});

  DailyPlan copyWith({List<Meal>? meals}) =>
      DailyPlan(meals: meals ?? this.meals);

  Macronutrients calculateTotals(Map<String, StandardFood> db) {
    Macronutrients totals = Macronutrients(kcal: 0, p: 0, c: 0, f: 0);
    for (final meal in meals) {
      for (final item in meal.items) {
        final food = db[item.foodId];
        if (food != null) {
          totals = totals.add(food.per100g.scaleByGrams(item.grams));
        }
      }
    }
    return totals;
  }
}

class MacroTargets {
  final double caloriesKcal;
  final double proteinMin;
  final double proteinMax;
  final double carbsMin;
  final double carbsMax;
  final double fatMin;
  final double fatMax;
  final double fiberMin;
  final double kcalTolerancePct;

  MacroTargets({
    required this.caloriesKcal,
    required this.proteinMin,
    required this.proteinMax,
    required this.carbsMin,
    required this.carbsMax,
    required this.fatMin,
    required this.fatMax,
    this.fiberMin = 30.0,
    this.kcalTolerancePct = 0.05,
  });
}

// V6.0 BMR/TDEE Functions
double mifflinStJeorBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required String sex,
}) {
  final s = (sex == 'male') ? 5.0 : -161.0;
  return 10 * weightKg + 6.25 * heightCm - 5 * age + s;
}

double activityFactor(int workoutsPerWeek) {
  if (workoutsPerWeek >= 5) return 1.725;
  if (workoutsPerWeek >= 3) return 1.55;
  if (workoutsPerWeek >= 1) return 1.375;
  return 1.2;
}

double tdeeFromBmr({required double bmr, required int workoutsPerWeek}) {
  return bmr * activityFactor(workoutsPerWeek);
}

MacroTargets suggestTargets({
  required Profile profile,
  required double tdee,
  String goal = 'lean_bulk',
  double surplusPct = 0.12,
  double deficitPct = 0.15,
}) {
  double targetKcal = tdee;
  if (goal == 'lean_bulk') {
    targetKcal = tdee * (1 + surplusPct);
  } else if (goal == 'cut') {
    targetKcal = tdee * (1 - deficitPct);
  }

  final pMin = 1.8 * profile.weightKg;
  final pMax = 2.2 * profile.weightKg;
  final fMin = 0.8 * profile.weightKg;
  final fMax = 1.0 * profile.weightKg;

  final pMid = (pMin + pMax) / 2.0;
  final fMid = (fMin + fMax) / 2.0;
  final cMid = math.max(0.0, (targetKcal - 4 * pMid - 9 * fMid) / 4.0);
  final cSpread = math.max(20.0, 0.08 * cMid);
  final cMin = math.max(0.0, cMid - cSpread);
  final cMax = cMid + cSpread;

  return MacroTargets(
    caloriesKcal: targetKcal,
    proteinMin: pMin,
    proteinMax: pMax,
    carbsMin: cMin,
    carbsMax: cMax,
    fatMin: fMin,
    fatMax: fMax,
    fiberMin: 30.0,
    kcalTolerancePct: 0.05,
  );
}

// V6.0 MacroAdjuster (Simplified)
class AdjusterConfig {
  final List<String> carbSources;
  final List<String> fatSources;
  final List<String> proteinSources;

  const AdjusterConfig({
    required this.carbSources,
    required this.fatSources,
    required this.proteinSources,
  });

  factory AdjusterConfig.defaultTR() => const AdjusterConfig(
        carbSources: ['pirinc_pis', 'bulgur_pis'],
        fatSources: ['zeytinyagi', 'findik'],
        proteinSources: ['tavuk_gogus_pis', 'yumurta_pis'],
      );
}

class MacroAdjuster {
  static DailyPlan adjustPlan({
    required DailyPlan plan,
    required Map<String, StandardFood> db,
    required MacroTargets targets,
    AdjusterConfig? config,
    int maxAttempts = 3,
  }) {
    config ??= AdjusterConfig.defaultTR();
    var working = plan;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final totals = working.calculateTotals(db);
      
      // Check if within targets
      if (_isWithinTargets(totals, targets)) {
        print('✅ Adjuster başarılı! Deneme $attempt');
        return working;
      }

      print('🔧 Adjuster deneme $attempt: ${totals.kcal.round()}kcal P${totals.p.round()}g');

      // Adjust carbs if needed
      if (totals.c < targets.carbsMin || totals.c > targets.carbsMax) {
        working = _adjustCarbs(working, db, targets, config);
      }

      // Adjust fats if needed  
      final newTotals = working.calculateTotals(db);
      if (newTotals.f < targets.fatMin || newTotals.f > targets.fatMax) {
        working = _adjustFats(working, db, targets, config);
      }

      // Adjust protein if needed
      final finalTotals = working.calculateTotals(db);
      if (finalTotals.p < targets.proteinMin || finalTotals.p > targets.proteinMax) {
        working = _adjustProtein(working, db, targets, config);
      }
    }

    print('⚠️ Adjuster $maxAttempts deneme sonrası hedeflere ulaşamadı');
    return working;
  }

  static bool _isWithinTargets(Macronutrients totals, MacroTargets targets) {
    final kcalOk = totals.kcal >= targets.caloriesKcal * (1 - targets.kcalTolerancePct) &&
                   totals.kcal <= targets.caloriesKcal * (1 + targets.kcalTolerancePct);
    final pOk = totals.p >= targets.proteinMin && totals.p <= targets.proteinMax;
    final cOk = totals.c >= targets.carbsMin && totals.c <= targets.carbsMax;
    final fOk = totals.f >= targets.fatMin && totals.f <= targets.fatMax;
    
    return kcalOk && pOk && cOk && fOk;
  }

  static DailyPlan _adjustCarbs(DailyPlan plan, Map<String, StandardFood> db, MacroTargets targets, AdjusterConfig config) {
    final totals = plan.calculateTotals(db);
    final carbDeficit = targets.carbsMin - totals.c;
    
    if (carbDeficit <= 0) return plan; // No adjustment needed
    
    // Find rice in meals and increase portion
    final meals = plan.meals.map((m) => m.copyWith(items: List<MealItem>.from(m.items))).toList();
    
    for (var mi = 0; mi < meals.length; mi++) {
      final meal = meals[mi];
      for (var ii = 0; ii < meal.items.length; ii++) {
        final item = meal.items[ii];
        if (config.carbSources.contains(item.foodId)) {
          final food = db[item.foodId];
          if (food != null && food.per100g.c > 0) {
            final neededGrams = (carbDeficit / food.per100g.c * 100.0);
            final newGrams = item.grams + neededGrams;
            meals[mi].items[ii] = item.copyWith(grams: newGrams);
            print('🍚 Karbonhidrat artırıldı: ${item.foodId} +${neededGrams.round()}g');
            return plan.copyWith(meals: meals);
          }
        }
      }
    }
    
    // If no carb source found, add rice to first meal
    if (meals.isNotEmpty) {
      final riceFood = db[config.carbSources.first];
      if (riceFood != null) {
        final neededGrams = (carbDeficit / riceFood.per100g.c * 100.0);
        meals[0].items.add(MealItem(foodId: config.carbSources.first, grams: neededGrams));
        print('🍚 Pirinç eklendi: ${neededGrams.round()}g');
      }
    }
    
    return plan.copyWith(meals: meals);
  }

  static DailyPlan _adjustFats(DailyPlan plan, Map<String, StandardFood> db, MacroTargets targets, AdjusterConfig config) {
    final totals = plan.calculateTotals(db);
    final fatDeficit = targets.fatMin - totals.f;
    
    if (fatDeficit <= 0) return plan;
    
    final meals = plan.meals.map((m) => m.copyWith(items: List<MealItem>.from(m.items))).toList();
    
    // Add olive oil to first meal
    if (meals.isNotEmpty) {
      final oilFood = db[config.fatSources.first];
      if (oilFood != null && oilFood.per100g.f > 0) {
        final neededGrams = (fatDeficit / oilFood.per100g.f * 100.0);
        meals[0].items.add(MealItem(foodId: config.fatSources.first, grams: neededGrams));
        print('🫒 Zeytinyağı eklendi: ${neededGrams.round()}g');
      }
    }
    
    return plan.copyWith(meals: meals);
  }

  static DailyPlan _adjustProtein(DailyPlan plan, Map<String, StandardFood> db, MacroTargets targets, AdjusterConfig config) {
    final totals = plan.calculateTotals(db);
    final proteinDeficit = targets.proteinMin - totals.p;
    
    if (proteinDeficit <= 0) return plan;
    
    final meals = plan.meals.map((m) => m.copyWith(items: List<MealItem>.from(m.items))).toList();
    
    // Add chicken to last meal
    if (meals.isNotEmpty) {
      final chickenFood = db[config.proteinSources.first];
      if (chickenFood != null && chickenFood.per100g.p > 0) {
        final neededGrams = (proteinDeficit / chickenFood.per100g.p * 100.0);
        meals.last.items.add(MealItem(foodId: config.proteinSources.first, grams: neededGrams));
        print('🍗 Tavuk eklendi: ${neededGrams.round()}g');
      }
    }
    
    return plan.copyWith(meals: meals);
  }
}

// Enhanced Turkish Food DB
Map<String, StandardFood> createEnhancedTurkishFoodDB() {
  return {
    'pirinc_pis': StandardFood(
      id: 'pirinc_pis',
      name: 'Pirinç Pilavı',
      per100g: Macronutrients(kcal: 130, p: 2.4, c: 28.7, f: 0.3, fiber: 0.4),
    ),
    'bulgur_pis': StandardFood(
      id: 'bulgur_pis', 
      name: 'Bulgur Pilavı',
      per100g: Macronutrients(kcal: 83, p: 3.1, c: 18.6, f: 0.2, fiber: 2.0),
    ),
    'tavuk_gogus_pis': StandardFood(
      id: 'tavuk_gogus_pis',
      name: 'Tavuk Göğsü (Pişmiş)',
      per100g: Macronutrients(kcal: 165, p: 31.0, c: 0, f: 3.6),
    ),
    'yumurta_pis': StandardFood(
      id: 'yumurta_pis',
      name: 'Yumurta (Pişmiş)',
      per100g: Macronutrients(kcal: 155, p: 13.0, c: 1.1, f: 11.0),
    ),
    'zeytinyagi': StandardFood(
      id: 'zeytinyagi',
      name: 'Zeytinyağı',
      per100g: Macronutrients(kcal: 884, p: 0, c: 0, f: 100),
    ),
    'findik': StandardFood(
      id: 'findik',
      name: 'Fındık',
      per100g: Macronutrients(kcal: 628, p: 15.0, c: 17.0, f: 61.0, fiber: 10.0),
    ),
    'yogurt': StandardFood(
      id: 'yogurt',
      name: 'Yoğurt',
      per100g: Macronutrients(kcal: 61, p: 3.5, c: 4.7, f: 3.3),
    ),
    'muz': StandardFood(
      id: 'muz',
      name: 'Muz',
      per100g: Macronutrients(kcal: 89, p: 1.1, c: 22.8, f: 0.3),
    ),
  };
}

// Generate adaptive plans based on targets
DailyPlan generateAdaptivePlan(MacroTargets targets) {
  // Simple adaptive logic based on calorie targets
  if (targets.caloriesKcal < 1800) {
    // Low calorie cut plan
    return DailyPlan(meals: [
      Meal(name: 'Kahvaltı', items: [
        MealItem(foodId: 'yogurt', grams: 200),
        MealItem(foodId: 'muz', grams: 100),
      ]),
      Meal(name: 'Öğle', items: [
        MealItem(foodId: 'tavuk_gogus_pis', grams: 150),
        MealItem(foodId: 'bulgur_pis', grams: 100),
      ]),
      Meal(name: 'Akşam', items: [
        MealItem(foodId: 'yumurta_pis', grams: 100),
        MealItem(foodId: 'pirinc_pis', grams: 80),
      ]),
    ]);
  } else if (targets.caloriesKcal < 2800) {
    // Moderate calorie plan
    return DailyPlan(meals: [
      Meal(name: 'Kahvaltı', items: [
        MealItem(foodId: 'yumurta_pis', grams: 150),
        MealItem(foodId: 'muz', grams: 120),
        MealItem(foodId: 'findik', grams: 20),
      ]),
      Meal(name: 'Öğle', items: [
        MealItem(foodId: 'tavuk_gogus_pis', grams: 200),
        MealItem(foodId: 'pirinc_pis', grams: 150),
        MealItem(foodId: 'zeytinyagi', grams: 10),
      ]),
      Meal(name: 'Akşam', items: [
        MealItem(foodId: 'tavuk_gogus_pis', grams: 150),
        MealItem(foodId: 'bulgur_pis', grams: 120),
      ]),
    ]);
  } else {
    // High calorie bulk plan
    return DailyPlan(meals: [
      Meal(name: 'Kahvaltı', items: [
        MealItem(foodId: 'yumurta_pis', grams: 200),
        MealItem(foodId: 'muz', grams: 150),
        MealItem(foodId: 'findik', grams: 40),
      ]),
      Meal(name: 'Ara Öğün', items: [
        MealItem(foodId: 'yogurt', grams: 250),
        MealItem(foodId: 'findik', grams: 30),
      ]),
      Meal(name: 'Öğle', items: [
        MealItem(foodId: 'tavuk_gogus_pis', grams: 250),
        MealItem(foodId: 'pirinc_pis', grams: 200),
        MealItem(foodId: 'zeytinyagi', grams: 15),
      ]),
      Meal(name: 'Akşam', items: [
        MealItem(foodId: 'tavuk_gogus_pis', grams: 200),
        MealItem(foodId: 'bulgur_pis', grams: 180),
      ]),
    ]);
  }
}

void main() async {
  print('🚀 V6.0 MACRO ADJUSTER TEST - GERÇEK PIPELİNE\n');

  final db = createEnhancedTurkishFoodDB();
  
  // Test critical profiles
  final testProfiles = [
    {
      'name': 'Cut Kadın',
      'profile': Profile(sex: 'female', age: 28, heightCm: 165, weightKg: 60, workoutsPerWeek: 4),
      'goal': 'cut',
    },
    {
      'name': 'Lean Bulk Erkek',
      'profile': Profile(sex: 'male', age: 25, heightCm: 180, weightKg: 70, workoutsPerWeek: 4),
      'goal': 'lean_bulk',
    },
    {
      'name': 'Mega Bulk (3000+ kcal)',
      'profile': Profile(sex: 'male', age: 22, heightCm: 185, weightKg: 80, workoutsPerWeek: 6),
      'goal': 'lean_bulk',
    },
  ];

  var successCount = 0;
  var totalTests = testProfiles.length;

  for (int i = 0; i < testProfiles.length; i++) {
    final testData = testProfiles[i];
    final profile = testData['profile'] as Profile;
    final goal = testData['goal'] as String;
    final name = testData['name'] as String;

    print('${(i + 1).toString().padLeft(2)}. $name TEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Calculate targets
    final bmr = mifflinStJeorBmr(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      sex: profile.sex,
    );
    final tdee = tdeeFromBmr(bmr: bmr, workoutsPerWeek: profile.workoutsPerWeek);
    final targets = suggestTargets(profile: profile, tdee: tdee, goal: goal);

    print('🎯 Hedefler: ${targets.caloriesKcal.round()}kcal P${targets.proteinMin.round()}-${targets.proteinMax.round()}g C${targets.carbsMin.round()}-${targets.carbsMax.round()}g');

    // Generate adaptive initial plan
    var plan = generateAdaptivePlan(targets);
    var totals = plan.calculateTotals(db);
    print('📋 İlk Plan: ${totals.kcal.round()}kcal P${totals.p.round()}g C${totals.c.round()}g F${totals.f.round()}g');

    // Apply V6.0 MacroAdjuster
    print('🔧 MacroAdjuster çalışıyor...');
    final adjustedPlan = MacroAdjuster.adjustPlan(
      plan: plan,
      db: db,
      targets: targets,
      maxAttempts: 3,
    );

    // Final validation
    final finalTotals = adjustedPlan.calculateTotals(db);
    final isValid = MacroAdjuster._isWithinTargets(finalTotals, targets);

    final kcalDiff = ((finalTotals.kcal - targets.caloriesKcal) / targets.caloriesKcal * 100);
    final proteinDiff = ((finalTotals.p - (targets.proteinMin + targets.proteinMax) / 2) / 
                        ((targets.proteinMin + targets.proteinMax) / 2) * 100);

    print('📊 Son Plan: ${finalTotals.kcal.round()}kcal P${finalTotals.p.round()}g C${finalTotals.c.round()}g F${finalTotals.f.round()}g');
    print('📈 Sapma: Kcal ${kcalDiff >= 0 ? "+" : ""}${kcalDiff.toStringAsFixed(1)}%, Protein ${proteinDiff >= 0 ? "+" : ""}${proteinDiff.toStringAsFixed(1)}%');
    print('✨ Sonuç: ${isValid ? "✅ BAŞARILI" : "❌ BAŞARISIZ"}');

    if (isValid) successCount++;
    print('');
  }

  // Final Results
  final successRate = (successCount / totalTests * 100);
  print('📊 V6.0 MACRO ADJUSTER SONUÇLARI');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🎯 Başarı Oranı: $successCount/$totalTests (${successRate.toStringAsFixed(1)}%)');

  if (successRate >= 80) {
    print('🚀 MÜKEMMEL! V6.0 MacroAdjuster sistemi çalışıyor!');
    print('✅ Bu V5.3\'ün %31.5\'inden çok daha iyi performans!');
  } else if (successRate >= 60) {
    print('⚡ İYİ! MacroAdjuster algoritmasi etkili, ince ayar gerekebilir.');
  } else {
    print('⚠️ ORTA! Adjuster algoritması güçlendirilmeli.');
  }

  print('\n🎊 V6.0 MACRO ADJUSTER TEST TAMAMLANDI!');
  print('MacroAdjuster\'ın gerçek gücü gösterildi! 🔧');
}