import 'dart:convert';

// ============================================================================
// MEAL ENUMS
// ============================================================================

enum MealCategory {
  kahvalti,
  araOgun1,
  ogleYemegi,
  araOgun2,
  aksamYemegi,
  geceAtistirmasi,
  cheatMeal
}

enum GoalTag { yagKaybi, kasGelisimi, bakim }

enum Difficulty { kolay, orta, zor }

// ============================================================================
// ENUM CONVERTERS
// ============================================================================

MealCategory _catFrom(String s) {
  switch (s) {
    case 'Kahvaltı':
      return MealCategory.kahvalti;
    case 'Ara Öğün 1':
      return MealCategory.araOgun1;
    case 'Öğle Yemeği':
      return MealCategory.ogleYemegi;
    case 'Ara Öğün 2':
      return MealCategory.araOgun2;
    case 'Akşam Yemeği':
      return MealCategory.aksamYemegi;
    case 'Gece Atıştırması':
      return MealCategory.geceAtistirmasi;
    case 'Cheat Meal':
      return MealCategory.cheatMeal;
    default:
      throw FormatException('Bilinmeyen kategori: $s');
  }
}

GoalTag _goalFrom(String s) {
  switch (s) {
    case 'Yağ Kaybı':
      return GoalTag.yagKaybi;
    case 'Kas Gelişimi':
      return GoalTag.kasGelisimi;
    case 'Bakım':
      return GoalTag.bakim;
    default:
      throw FormatException('Bilinmeyen goal_tag: $s');
  }
}

Difficulty _diffFrom(String s) {
  switch (s) {
    case 'Kolay':
      return Difficulty.kolay;
    case 'Orta':
      return Difficulty.orta;
    case 'Zor':
      return Difficulty.zor;
    default:
      throw FormatException('Bilinmeyen difficulty: $s');
  }
}

// ============================================================================
// MEAL MODEL
// ============================================================================

class Meal {
  final String mealId;
  final MealCategory category;
  final String mealName;
  final int calorie;
  final int proteinG;
  final int carbG;
  final int fatG;
  final int fiberG;
  final GoalTag goalTag;
  final Difficulty difficulty;
  final int prepTimeMin;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> dietTags;
  final List<String> mealTiming;
  final String season;

  // Opsiyonel alanlar
  final String? glycemicIndex;
  final String? mealType;
  final String? cuisineStyle;
  final String? costLevel;
  final String? proteinSource;
  final String? spiceLevel;
  final int? storageDays;
  final bool? mealPrepFriendly;
  final bool? restaurantAvailable;
  final double? popularityScore;

  Meal({
    required this.mealId,
    required this.category,
    required this.mealName,
    required this.calorie,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.fiberG,
    required this.goalTag,
    required this.difficulty,
    required this.prepTimeMin,
    required this.ingredients,
    required this.allergens,
    required this.dietTags,
    required this.mealTiming,
    required this.season,
    this.glycemicIndex,
    this.mealType,
    this.cuisineStyle,
    this.costLevel,
    this.proteinSource,
    this.spiceLevel,
    this.storageDays,
    this.mealPrepFriendly,
    this.restaurantAvailable,
    this.popularityScore,
  });

  factory Meal.fromJson(Map<String, dynamic> j) {
    return Meal(
      mealId: j['meal_id'] as String,
      category: _catFrom(j['category'] as String),
      mealName: j['meal_name'] as String,
      calorie: (j['calorie'] as num).toInt(),
      proteinG: (j['protein_g'] as num).toInt(),
      carbG: (j['carb_g'] as num).toInt(),
      fatG: (j['fat_g'] as num).toInt(),
      fiberG: (j['fiber_g'] as num).toInt(),
      goalTag: _goalFrom(j['goal_tag'] as String),
      difficulty: _diffFrom(j['difficulty'] as String),
      prepTimeMin: (j['prep_time_min'] as num).toInt(),
      ingredients: (j['ingredients'] as List).map((e) => e.toString()).toList(),
      allergens: (j['allergens'] as List).map((e) => e.toString()).toList(),
      dietTags: (j['diet_tags'] as List).map((e) => e.toString()).toList(),
      mealTiming: (j['meal_timing'] as List).map((e) => e.toString()).toList(),
      season: j['season'] as String,
      glycemicIndex: j['glycemic_index'] as String?,
      mealType: j['meal_type'] as String?,
      cuisineStyle: j['cuisine_style'] as String?,
      costLevel: j['cost_level'] as String?,
      proteinSource: j['protein_source'] as String?,
      spiceLevel: j['spice_level'] as String?,
      storageDays: (j['storage_days'] as num?)?.toInt(),
      mealPrepFriendly: j['meal_prep_friendly'] as bool?,
      restaurantAvailable: j['restaurant_available'] as bool?,
      popularityScore: (j['popularity_score'] is int)
          ? (j['popularity_score'] as int).toDouble()
          : (j['popularity_score'] as num?)?.toDouble(),
    );
  }

  static List<Meal> listFromJsonString(String source) {
    final raw = json.decode(source);
    if (raw is! List) {
      throw const FormatException('Kök JSON bir dizi (array) olmalı.');
    }
    return raw
        .map<Meal>((e) => Meal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Kullanıcı kısıtlamalarına göre filtreleme
  bool matchesRestrictions(List<String> restrictions) {
    if (restrictions.isEmpty) return true;
    
    // Eğer öğünün herhangi bir allergen'i kısıtlamalarda varsa, eşleşmiyor
    for (final allergen in allergens) {
      for (final restriction in restrictions) {
        if (allergen.toLowerCase().contains(restriction.toLowerCase()) ||
            restriction.toLowerCase().contains(allergen.toLowerCase())) {
          return false;
        }
      }
    }
    
    // İçindekiler listesini de kontrol et
    for (final ingredient in ingredients) {
      for (final restriction in restrictions) {
        if (ingredient.toLowerCase().contains(restriction.toLowerCase()) ||
            restriction.toLowerCase().contains(ingredient.toLowerCase())) {
          return false;
        }
      }
    }
    
    return true;
  }
}
