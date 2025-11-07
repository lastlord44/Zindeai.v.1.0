// lib/core/validators/macro_validator.dart
// Deterministik makro hesap & tolerans doğrulayıcı + ortak modeller
import 'dart:convert';
import 'dart:math' as math;

/// Cinsiyet
enum Sex { male, female }

/// Kullanıcı profili
class Profile {
  final Sex sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final int workoutsPerWeek;
  final bool deskJob;

  const Profile({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.workoutsPerWeek,
    this.deskJob = true,
  });
}

/// Mifflin–St Jeor BMR
double mifflinStJeor(Profile p) {
  final s = (p.sex == Sex.male) ? 5.0 : -161.0;
  return 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + s;
}

/// Antrenman sayısından aktivite katsayısı
double activityFactorFromWorkouts(int workoutsPerWeek) {
  if (workoutsPerWeek <= 0) return 1.2;
  if (workoutsPerWeek <= 2) return 1.375;
  if (workoutsPerWeek <= 4) return 1.55;
  if (workoutsPerWeek <= 6) return 1.725;
  return 1.9;
}

/// TDEE
double tdee(Profile p) => mifflinStJeor(p) * activityFactorFromWorkouts(p.workoutsPerWeek);

/// Birim: gram
class MacroBreakdown {
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double satFatG;

  const MacroBreakdown({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.satFatG = 0,
  });

  MacroBreakdown add(MacroBreakdown o) => MacroBreakdown(
        kcal: kcal + o.kcal,
        proteinG: proteinG + o.proteinG,
        carbsG: carbsG + o.carbsG,
        fatG: fatG + o.fatG,
        fiberG: fiberG + o.fiberG,
        satFatG: satFatG + o.satFatG,
      );

  MacroBreakdown scale(double s) => MacroBreakdown(
        kcal: kcal * s,
        proteinG: proteinG * s,
        carbsG: carbsG * s,
        fatG: fatG * s,
        fiberG: fiberG * s,
        satFatG: satFatG * s,
      );

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sat_fat_g': satFatG,
      };
}

/// DB'den per 100 g besin anlık görüntüsü
class NutrientSnapshot {
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double satFatPer100g;

  const NutrientSnapshot({
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.satFatPer100g = 0,
  });
}

/// Harici DB servislerinin implement edeceği arayüz
abstract class NutrientProvider {
  NutrientSnapshot? getPer100g(String foodId);
  bool hasFood(String foodId) => getPer100g(foodId) != null;
}

/// Hedefler (bantlı)
class MacroTargets {
  final double caloriesKcal;
  final double proteinMinG;
  final double proteinMaxG;
  final double carbsMinG;
  final double carbsMaxG;
  final double fatMinG;
  final double fatMaxG;
  final double fiberMinG;
  final double satFatMaxG;
  final double kcalTolerancePct;

  const MacroTargets({
    required this.caloriesKcal,
    required this.proteinMinG,
    required this.proteinMaxG,
    required this.carbsMinG,
    required this.carbsMaxG,
    required this.fatMinG,
    required this.fatMaxG,
    required this.fiberMinG,
    required this.satFatMaxG,
    this.kcalTolerancePct = 0.05,
  });

  /// Lean bulk için pratik hedefler
  factory MacroTargets.forLeanBulk(Profile p, {required double tdeeKcal, double surplusPct = 0.12}) {
    final calories = tdeeKcal * (1 + surplusPct);

    final proteinMin = 1.9 * p.weightKg;
    final proteinMax = 2.2 * p.weightKg;

    final fatMin = 0.8 * p.weightKg;
    final fatMax = 1.0 * p.weightKg;

    // Karbonhidrat aralığını protein/fat aralığından türet
    final carbsMin = math.max(0, (calories - 4 * proteinMax - 9 * fatMax) / 4);
    final carbsMax = math.max(0, (calories - 4 * proteinMin - 9 * fatMin) / 4);

    final fiberMin = 30.0;
    final satFatMax = (0.10 * calories) / 9.0;

    return MacroTargets(
      caloriesKcal: calories,
      proteinMinG: proteinMin,
      proteinMaxG: proteinMax,
      carbsMinG: carbsMin,
      carbsMaxG: carbsMax,
      fatMinG: fatMin,
      fatMaxG: fatMax,
      fiberMinG: fiberMin,
      satFatMaxG: satFatMax,
    );
  }

  /// Cut için hedefler
  factory MacroTargets.forCut(Profile p, {required double tdeeKcal, double deficitPct = 0.18}) {
    final calories = tdeeKcal * (1 - deficitPct);

    final proteinMin = 2.0 * p.weightKg;
    final proteinMax = 2.4 * p.weightKg;

    final fatMin = 0.7 * p.weightKg;
    final fatMax = 0.9 * p.weightKg;

    final carbsMin = math.max(0, (calories - 4 * proteinMax - 9 * fatMax) / 4);
    final carbsMax = math.max(0, (calories - 4 * proteinMin - 9 * fatMin) / 4);

    final fiberMin = 35.0;
    final satFatMax = (0.08 * calories) / 9.0;

    return MacroTargets(
      caloriesKcal: calories,
      proteinMinG: proteinMin,
      proteinMaxG: proteinMax,
      carbsMinG: carbsMin,
      carbsMaxG: carbsMax,
      fatMinG: fatMin,
      fatMaxG: fatMax,
      fiberMinG: fiberMin,
      satFatMaxG: satFatMax,
    );
  }

  /// Bulk için hedefler  
  factory MacroTargets.forBulk(Profile p, {required double tdeeKcal, double surplusPct = 0.20}) {
    final calories = tdeeKcal * (1 + surplusPct);

    final proteinMin = 1.8 * p.weightKg;
    final proteinMax = 2.0 * p.weightKg;

    final fatMin = 0.9 * p.weightKg;
    final fatMax = 1.2 * p.weightKg;

    final carbsMin = math.max(0, (calories - 4 * proteinMax - 9 * fatMax) / 4);
    final carbsMax = math.max(0, (calories - 4 * proteinMin - 9 * fatMin) / 4);

    final fiberMin = 28.0;
    final satFatMax = (0.12 * calories) / 9.0;

    return MacroTargets(
      caloriesKcal: calories,
      proteinMinG: proteinMin,
      proteinMaxG: proteinMax,
      carbsMinG: carbsMin,
      carbsMaxG: carbsMax,
      fatMinG: fatMin,
      fatMaxG: fatMax,
      fiberMinG: fiberMin,
      satFatMaxG: satFatMax,
    );
  }
}

/// Tolerans raporu
class ToleranceReport {
  final bool caloriesOk;
  final bool proteinOk;
  final bool carbsOk;
  final bool fatOk;
  final bool fiberOk;
  final bool satFatOk;

  const ToleranceReport({
    required this.caloriesOk,
    required this.proteinOk,
    required this.carbsOk,
    required this.fatOk,
    required this.fiberOk,
    required this.satFatOk,
  });

  bool get allOk => caloriesOk && proteinOk && carbsOk && fatOk && fiberOk && satFatOk;

  @override
  String toString() =>
      'ToleranceReport(cal:$caloriesOk, P:$proteinOk, C:$carbsOk, F:$fatOk, fiber:$fiberOk, satFat:$satFatOk)';
}

/// Ana öğün başına minimum protein eşiği (≈0.3 g/kg)
double perMealProteinThreshold(Profile p) => 0.3 * p.weightKg;

/// Kalori tolerans bandı kontrolü
bool _kcalWithin(double kcal, double target, double pct) {
  final lo = target * (1 - pct);
  final hi = target * (1 + pct);
  return kcal >= lo && kcal <= hi;
}

/// Makro tolerans kontrolü (±%5 kcal, bantlı P/C/F; fiber min; doymuş yağ max)
ToleranceReport checkTolerance(MacroBreakdown total, MacroTargets target) {
  final caloriesOk = _kcalWithin(total.kcal, target.caloriesKcal, target.kcalTolerancePct);
  final proteinOk = total.proteinG >= target.proteinMinG && total.proteinG <= target.proteinMaxG;
  final carbsOk = total.carbsG >= target.carbsMinG && total.carbsG <= target.carbsMaxG;
  final fatOk = total.fatG >= target.fatMinG && total.fatG <= target.fatMaxG;
  final fiberOk = total.fiberG >= target.fiberMinG;
  final satFatOk = total.satFatG <= target.satFatMaxG;
  return ToleranceReport(
    caloriesOk: caloriesOk,
    proteinOk: proteinOk,
    carbsOk: carbsOk,
    fatOk: fatOk,
    fiberOk: fiberOk,
    satFatOk: satFatOk,
  );
}

/// Basit toplayıcı (gram -> makro)
MacroBreakdown macrosFromGrams({
  required double grams,
  required NutrientSnapshot nutPer100g,
}) {
  final s = grams / 100.0;
  final kcal = nutPer100g.kcalPer100g * s;
  final p = nutPer100g.proteinPer100g * s;
  final c = nutPer100g.carbsPer100g * s;
  final f = nutPer100g.fatPer100g * s;
  final fiber = nutPer100g.fiberPer100g * s;
  final sat = nutPer100g.satFatPer100g * s;
  return MacroBreakdown(kcal: kcal, proteinG: p, carbsG: c, fatG: f, fiberG: fiber, satFatG: sat);
}

/// --------- Plan Modeli (JSON <-> Model) ----------

class MealItem {
  final String foodId;
  final double grams;

  MealItem({required this.foodId, required this.grams});

  MealItem copyWith({String? foodId, double? grams}) =>
      MealItem(foodId: foodId ?? this.foodId, grams: grams ?? this.grams);

  Map<String, dynamic> toJson() => {'food_id': foodId, 'grams': grams};

  factory MealItem.fromJson(Map<String, dynamic> j) =>
      MealItem(foodId: j['food_id'] as String, grams: (j['grams'] as num).toDouble());
}

class Meal {
  final String name;
  final List<MealItem> items;

  Meal({required this.name, required this.items});

  Meal copyWith({String? name, List<MealItem>? items}) =>
      Meal(name: name ?? this.name, items: items ?? this.items);

  Map<String, dynamic> toJson() => {'name': name, 'items': items.map((e) => e.toJson()).toList()};

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        name: j['name'] as String,
        items: (j['items'] as List).map((e) => MealItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

class MealPlan {
  final String day; // ISO-8601 (YYYY-MM-DD)
  final List<Meal> meals;

  MealPlan({required this.day, required this.meals});

  Map<String, dynamic> toJson() => {'day': day, 'meals': meals.map((e) => e.toJson()).toList()};

  factory MealPlan.fromJson(Map<String, dynamic> j) => MealPlan(
        day: j['day'] as String,
        meals: (j['meals'] as List).map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList(),
      );

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// Planın toplam makroları
MacroBreakdown computePlanTotals(MealPlan plan, NutrientProvider provider) {
  MacroBreakdown total = const MacroBreakdown(kcal: 0, proteinG: 0, carbsG: 0, fatG: 0, fiberG: 0, satFatG: 0);
  for (final meal in plan.meals) {
    for (final it in meal.items) {
      final nut = provider.getPer100g(it.foodId);
      if (nut == null) continue; // bilinmeyen id'yi atla
      total = total.add(macrosFromGrams(grams: it.grams, nutPer100g: nut));
    }
  }
  // Sayıları 1 ondalığa yuvarla (deterministik görünüm)
  MacroBreakdown round1(MacroBreakdown m) => MacroBreakdown(
        kcal: double.parse(m.kcal.toStringAsFixed(1)),
        proteinG: double.parse(m.proteinG.toStringAsFixed(1)),
        carbsG: double.parse(m.carbsG.toStringAsFixed(1)),
        fatG: double.parse(m.fatG.toStringAsFixed(1)),
        fiberG: double.parse(m.fiberG.toStringAsFixed(1)),
        satFatG: double.parse(m.satFatG.toStringAsFixed(1)),
      );
  return round1(total);
}