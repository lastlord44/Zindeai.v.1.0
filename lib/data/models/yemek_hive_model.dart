// ============================================================================
// lib/data/models/yemek_hive_model.dart
// Yemek Hive Model - JSON dosyalarından Hive'a migration için
// ============================================================================

import 'package:hive/hive.dart';
import '../../domain/entities/yemek.dart';
import '../../domain/entities/alternatif_besin.dart';

part 'yemek_hive_model.g.dart';

@HiveType(typeId: 3)
class YemekHiveModel extends HiveObject {
  @HiveField(0)
  String? mealId;

  @HiveField(1)
  String? category;

  @HiveField(2)
  String? mealName;

  @HiveField(3)
  double? calorie;

  @HiveField(4)
  double? proteinG;

  @HiveField(5)
  double? carbG;

  @HiveField(6)
  double? fatG;

  @HiveField(7)
  double? fiberG;

  @HiveField(8)
  String? goalTag;

  @HiveField(9)
  String? difficulty;

  @HiveField(10)
  int? prepTimeMin;

  @HiveField(11)
  List<String>? ingredients;

  @HiveField(12)
  String? recipe;

  @HiveField(13)
  String? imageUrl;

  @HiveField(14)
  List<String>? tags;

  @HiveField(15)
  List<Map<String, dynamic>>? alternatives;

  // Constructor
  YemekHiveModel({
    this.mealId,
    this.category,
    this.mealName,
    this.calorie,
    this.proteinG,
    this.carbG,
    this.fatG,
    this.fiberG,
    this.goalTag,
    this.difficulty,
    this.prepTimeMin,
    this.ingredients,
    this.recipe,
    this.imageUrl,
    this.tags,
    this.alternatives,
  });

  /// JSON'dan YemekHiveModel oluştur
  factory YemekHiveModel.fromJson(Map<String, dynamic> json) {
    return YemekHiveModel(
      mealId: json['meal_id']?.toString(),
      category: json['category']?.toString(),
      mealName: json['meal_name']?.toString(),
      calorie: _parseDouble(json['calorie']),
      proteinG: _parseDouble(json['protein_g']),
      carbG: _parseDouble(json['carb_g']),
      fatG: _parseDouble(json['fat_g']),
      fiberG: _parseDouble(json['fiber_g']),
      goalTag: json['goal_tag']?.toString(),
      difficulty: json['difficulty']?.toString(),
      prepTimeMin: _parseInt(json['prep_time_min']),
      ingredients: _parseStringList(json['ingredients']),
      recipe: json['recipe']?.toString(),
      imageUrl: json['image_url']?.toString(),
      tags: _parseStringList(json['tags']),
      alternatives: _parseAlternatives(json['alternatives']),
    );
  }

  /// YemekHiveModel'i Yemek entity'sine çevir
  Yemek toEntity() {
    return Yemek(
      id: mealId ?? '',
      ad: mealName ?? 'İsimsiz Yemek',
      ogun: _categoryToOgunTipi(category ?? ''),
      kalori: calorie ?? 0.0,
      protein: proteinG ?? 0.0,
      karbonhidrat: carbG ?? 0.0,
      yag: fatG ?? 0.0,
      malzemeler: ingredients ?? [],
      alternatifler: _parseAlternatifBesinler(alternatives ?? []),
      hazirlamaSuresi: prepTimeMin ?? 0,
      zorluk: _difficultyToZorluk(difficulty ?? ''),
      etiketler: tags ?? [],
      tarif: recipe,
      gorselUrl: imageUrl,
    );
  }

  /// Yemek entity'sinden YemekHiveModel oluştur
  factory YemekHiveModel.fromEntity(Yemek yemek) {
    return YemekHiveModel(
      mealId: yemek.id,
      category: yemek.ogun.ad,
      mealName: yemek.ad,
      calorie: yemek.kalori,
      proteinG: yemek.protein,
      carbG: yemek.karbonhidrat,
      fatG: yemek.yag,
      fiberG: 0.0, // Entity'de yok
      goalTag: 'Bakım', // Default
      difficulty: yemek.zorluk.ad,
      prepTimeMin: yemek.hazirlamaSuresi,
      ingredients: yemek.malzemeler,
      recipe: yemek.tarif,
      imageUrl: yemek.gorselUrl,
      tags: yemek.etiketler,
      alternatives: yemek.alternatifler.map((a) => a.toJson()).toList(),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'category': category,
      'meal_name': mealName,
      'calorie': calorie,
      'protein_g': proteinG,
      'carb_g': carbG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'goal_tag': goalTag,
      'difficulty': difficulty,
      'prep_time_min': prepTimeMin,
      'ingredients': ingredients,
      'recipe': recipe,
      'image_url': imageUrl,
      'tags': tags,
      'alternatives': alternatives,
    };
  }

  // ========================================================================
  // HELPER METODLAR
  // ========================================================================

  /// Double değer parse helper metodu
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Int değer parse helper metodu
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// String listesi parse helper metodu
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value.where((e) => e != null).map((e) => e.toString()).toList();
    } catch (e) {
      return null;
    }
  }

  /// Alternatifler parse helper metodu
  static List<Map<String, dynamic>>? _parseAlternatives(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// AlternatifBesin listesi parse helper metodu
  static List<AlternatifBesin> _parseAlternatifBesinler(
      List<Map<String, dynamic>> alternatives) {
    try {
      return alternatives.map((alt) => AlternatifBesin.fromJson(alt)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Kategori string'ini OgunTipi enum'una çevir
  static OgunTipi _categoryToOgunTipi(String category) {
    switch (category.toLowerCase()) {
      case 'kahvaltı':
        return OgunTipi.kahvalti;
      case 'ara öğün 1':
        return OgunTipi.araOgun1;
      case 'öğle':
      case 'öğle yemeği':  // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.ogle;
      case 'ara öğün 2':
        return OgunTipi.araOgun2;
      case 'akşam':
      case 'akşam yemeği':  // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.aksam;
      case 'gece atıştırma':
      case 'gece atıştırması':  // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.geceAtistirma;
      case 'cheat meal':
        return OgunTipi.cheatMeal;
      default:
        return OgunTipi.kahvalti;
    }
  }

  /// Zorluk string'ini Zorluk enum'una çevir
  static Zorluk _difficultyToZorluk(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
        return Zorluk.kolay;
      case 'orta':
        return Zorluk.orta;
      case 'zor':
        return Zorluk.zor;
      default:
        return Zorluk.kolay;
    }
  }
}
