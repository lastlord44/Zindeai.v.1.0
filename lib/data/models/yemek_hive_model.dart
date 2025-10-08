// ============================================================================
// lib/data/models/yemek_hive_model.dart
// Yemek Hive Model - JSON dosyalarından Hive'a migration için
// ============================================================================

import 'package:hive/hive.dart';
import 'dart:math';
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

  /// JSON'dan YemekHiveModel oluştur (hem eski hem yeni format desteği)
  factory YemekHiveModel.fromJson(Map<String, dynamic> json) {
    // Yeni format kontrolü (Türkçe field adları)
    final bool yeniFormat =
        json.containsKey('isim') || json.containsKey('aciklama');

    YemekHiveModel model;

    if (yeniFormat) {
      // 🆕 YENİ FORMAT (zindeai_*.json dosyaları)
      final rawId = json['id']?.toString();
      model = YemekHiveModel(
        mealId: rawId != null && rawId.isNotEmpty ? rawId : generateMealId(),
        category: json['kategori']?.toString(),
        mealName: json['isim']?.toString(),
        calorie: _parseDouble(json['kalori']),
        proteinG: _parseDouble(json['protein']),
        carbG: _parseDouble(json['karbonhidrat']),
        fatG: _parseDouble(json['yag']),
        fiberG: 0.0, // Yeni formatta yok
        goalTag: json['goal']?.toString() ?? 'cut',
        difficulty: json['zorluk']?.toString(),
        prepTimeMin: _parseInt(json['hazirlamaSuresi']),
        ingredients: _parseStringList(json['malzemeler']),
        recipe: json['aciklama']?.toString(), // Açıklama = tarif
        imageUrl: json['gorselUrl']?.toString(),
        tags: _parseStringList(json['etiketler']),
        alternatives: _parseAlternatives(json['alternatifler']),
      );
    } else {
      // 📜 ESKİ FORMAT (mevcut JSON dosyaları)
      final rawId = json['meal_id']?.toString();
      model = YemekHiveModel(
        mealId: rawId != null && rawId.isNotEmpty ? rawId : generateMealId(),
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

    // 🔥 SON KONTROL: mealId hala null ise unique ID ata (GARANTILI!)
    model.mealId ??= generateMealId();

    return model;
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

  /// 🔥 Unique Meal ID Generator (STATIC - her yerden erişilebilir!)
  static String generateMealId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'MEAL-$timestamp-$random';
  }

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
      case 'kahvalti': // Türkçe karakter yok
      case 'kahvalt':
        return OgunTipi.kahvalti;
      case 'ara öğün 1':
      case 'ara ogun 1': // Türkçe karakter yok
      case 'ara_ogun_1': // 🔥 FIX: Underscore formatı
        return OgunTipi.araOgun1;
      case 'öğle':
      case 'ogle': // Türkçe karakter yok
      case 'öğle yemeği':
      case 'ogle yemegi': // Türkçe karakter yok
        return OgunTipi.ogle;
      case 'ara öğün 2':
      case 'ara ogun 2': // Türkçe karakter yok
      case 'ara_ogun_2': // 🔥 FIX: Underscore formatı - KRITIK!
        return OgunTipi.araOgun2;
      case 'akşam':
      case 'aksam': // Türkçe karakter yok
      case 'akşam yemeği':
      case 'aksam yemegi': // Türkçe karakter yok
        return OgunTipi.aksam;
      case 'gece atıştırma':
      case 'gece atıştırması':
      case 'gece atistirma': // Türkçe karakter yok
      case 'gece atistirmasi': // Türkçe karakter yok
      case 'gece_atistirmasi': // 🔥 FIX: Underscore formatı
        return OgunTipi.geceAtistirma;
      case 'cheat meal':
      case 'cheat_meal': // 🔥 FIX: Underscore formatı
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
