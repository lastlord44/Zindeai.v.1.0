import 'package:flutter/foundation.dart';
import '../../data/models/meal.dart';
import '../../data/repositories/meal_repository.dart';

// ============================================================================
// MEAL PROVIDER
// ============================================================================

class MealProvider with ChangeNotifier {
  final MealRepository _repo;

  MealProvider(this._repo);

  bool _loading = false;
  bool get loading => _loading;

  List<Meal> _items = [];
  List<Meal> get items => _items;

  String? _error;
  String? get error => _error;

  /// İlk yükleme - tüm öğünleri yükler
  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repo.loadAll();
      print('✅ MealProvider: ${_items.length} öğün yüklendi');
    } catch (e) {
      _error = 'Öğünler yüklenirken hata: $e';
      print('❌ MealProvider Hatası: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Gelişmiş filtreleme
  List<Meal> filter({
    MealCategory? category,
    GoalTag? goal,
    int? kcalMin,
    int? kcalMax,
    int? proteinMin,
    int? proteinMax,
    List<String>? restrictions,
    Difficulty? difficulty,
    int? maxPrepTime,
  }) {
    Iterable<Meal> q = _items;

    // Kategori filtresi
    if (category != null) {
      q = q.where((e) => e.category == category);
    }

    // Hedef filtresi
    if (goal != null) {
      q = q.where((e) => e.goalTag == goal);
    }

    // Kalori aralığı
    if (kcalMin != null) {
      q = q.where((e) => e.calorie >= kcalMin);
    }
    if (kcalMax != null) {
      q = q.where((e) => e.calorie <= kcalMax);
    }

    // Protein aralığı
    if (proteinMin != null) {
      q = q.where((e) => e.proteinG >= proteinMin);
    }
    if (proteinMax != null) {
      q = q.where((e) => e.proteinG <= proteinMax);
    }

    // Kısıtlamalar (alerji/diyet)
    if (restrictions != null && restrictions.isNotEmpty) {
      q = q.where((m) => m.matchesRestrictions(restrictions));
    }

    // Zorluk seviyesi
    if (difficulty != null) {
      q = q.where((e) => e.difficulty == difficulty);
    }

    // Maksimum hazırlık süresi
    if (maxPrepTime != null) {
      q = q.where((e) => e.prepTimeMin <= maxPrepTime);
    }

    return q.toList(growable: false);
  }

  /// Kategoriye göre öğünleri döndür
  List<Meal> getMealsByCategory(MealCategory category) {
    return _items.where((m) => m.category == category).toList();
  }

  /// Hedefe göre öğünleri döndür
  List<Meal> getMealsByGoal(GoalTag goal) {
    return _items.where((m) => m.goalTag == goal).toList();
  }

  /// Öğün ID'sine göre öğün bul
  Meal? getMealById(String mealId) {
    try {
      return _items.firstWhere((m) => m.mealId == mealId);
    } catch (e) {
      return null;
    }
  }

  /// İstatistikler
  Map<String, int> getStatistics() {
    return {
      'totalMeals': _items.length,
      'kahvalti': getMealsByCategory(MealCategory.kahvalti).length,
      'araOgun1': getMealsByCategory(MealCategory.araOgun1).length,
      'ogleYemegi': getMealsByCategory(MealCategory.ogleYemegi).length,
      'araOgun2': getMealsByCategory(MealCategory.araOgun2).length,
      'aksamYemegi': getMealsByCategory(MealCategory.aksamYemegi).length,
      'geceAtistirmasi': getMealsByCategory(MealCategory.geceAtistirmasi).length,
      'cheatMeal': getMealsByCategory(MealCategory.cheatMeal).length,
    };
  }
}
