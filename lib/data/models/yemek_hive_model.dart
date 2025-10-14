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

  /// JSON'dan YemekHiveModel oluştur (3 format desteği)
  factory YemekHiveModel.fromJson(Map<String, dynamic> json) {
    // 🔥 FORMAT TESPİTİ:
    // 1. Yeni Türkçe format: isim/ad/aciklama + kalori/protein/karbonhidrat/yag
    // 2. Eski İngilizce format v1: meal_name + calorie/protein_g/carb_g/fat_g
    // 3. SON EKLENEN format v2: meal_name + calories/protein/carbs/fat (ÇOĞUL!)
    
    final bool yeniTurkceFormat =
        json.containsKey('isim') || json.containsKey('ad') || json.containsKey('aciklama');
    
    // 🔥 YENİ: "calories" (çoğul) kontrolü - bu farklı bir format!
    final bool eskiFormatV2 = json.containsKey('calories'); // calories (çoğul) = v2

    YemekHiveModel model;

    if (yeniTurkceFormat) {
      // 🆕 FORMAT 1: YENİ TÜRKÇE FORMAT
      final rawId = json['id']?.toString();
      
      final kalori = _parseDouble(json['kalori']);
      final protein = _parseDouble(json['protein']);
      final karb = _parseDouble(json['karbonhidrat']);
      final yag = _parseDouble(json['yag']);
      
      model = YemekHiveModel(
        mealId: rawId != null && rawId.isNotEmpty ? rawId : generateMealId(),
        category: json['kategori']?.toString() ?? json['ogun']?.toString(),
        mealName: json['isim']?.toString() ?? json['ad']?.toString(),
        calorie: kalori,
        proteinG: protein,
        carbG: karb,
        fatG: yag,
        fiberG: 0.0,
        goalTag: json['goal']?.toString() ?? 'cut',
        difficulty: json['zorluk']?.toString(),
        prepTimeMin: _parseInt(json['hazirlamaSuresi']),
        ingredients: _parseStringList(json['malzemeler']),
        recipe: json['aciklama']?.toString(),
        imageUrl: json['gorselUrl']?.toString(),
        tags: _parseStringList(json['etiketler']),
        alternatives: _parseAlternatives(json['alternatifler']),
      );
    } else if (eskiFormatV2) {
      // 📜 FORMAT 2: ESKİ İNGİLİZCE V2 (calories-çoğul, protein, carbs, fat)
      final rawId = json['meal_id']?.toString();
      
      final kalori = _parseDouble(json['calories']); // ✅ ÇOĞUL!
      final protein = _parseDouble(json['protein']);  // ✅ Direkt protein
      final karb = _parseDouble(json['carbs']);       // ✅ carbs (çoğul)
      final yag = _parseDouble(json['fat']);          // ✅ Direkt fat
      
      model = YemekHiveModel(
        mealId: rawId != null && rawId.isNotEmpty ? rawId : generateMealId(),
        category: json['category']?.toString() ?? json['meal_type']?.toString(), // ✅ meal_type fallback!
        mealName: json['meal_name']?.toString(),
        calorie: kalori,
        proteinG: protein,
        carbG: karb,
        fatG: yag,
        fiberG: _parseDouble(json['fiber_g']) ?? _parseDouble(json['fiber']),
        goalTag: json['goal_tag']?.toString() ?? 'cut',
        difficulty: json['difficulty']?.toString() ?? 'kolay',
        prepTimeMin: _parseInt(json['prep_time_min']) ?? _parseInt(json['cooking_time']),
        ingredients: _parseStringList(json['ingredients']),
        recipe: json['recipe']?.toString(),
        imageUrl: json['image_url']?.toString(),
        tags: _parseStringList(json['tags']),
        alternatives: _parseAlternatives(json['alternatives']),
      );
    } else {
      // 📜 FORMAT 3: ESKİ İNGİLİZCE V1 (calorie-tekil, protein_g, carb_g, fat_g)
      final rawId = json['meal_id']?.toString();
      
      final kalori = _parseDouble(json['calorie']); // ✅ TEKİL!
      final protein = _parseDouble(json['protein_g']);
      final karb = _parseDouble(json['carb_g']);
      final yag = _parseDouble(json['fat_g']);
      
      model = YemekHiveModel(
        mealId: rawId != null && rawId.isNotEmpty ? rawId : generateMealId(),
        category: json['category']?.toString() ?? json['meal_type']?.toString(),
        mealName: json['meal_name']?.toString(),
        calorie: kalori,
        proteinG: protein,
        carbG: karb,
        fatG: yag,
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

    // 🔥 SON KONTROL: mealId hala null ise unique ID ata
    model.mealId ??= generateMealId();

    return model;
  }

  /// YemekHiveModel'i Yemek entity'sine çevir
  Yemek toEntity() {
    // 🔥 FIX V2: mealName boş/null ise öğün tipine göre varsayılan isim ver
    // Ara Öğün 2 isim sorunu çözümü (logda sadece "Ara Öğün 2:" görünmesi)
    String finalMealName = (mealName ?? '').trim();
    
    // Boş string veya sadece kategori ismi içeren isimleri düzelt
    if (finalMealName.isEmpty ||
        finalMealName == 'İsimsiz Yemek' ||
        finalMealName == 'Ara Öğün 2:' ||
        finalMealName == 'Ara Öğün 1:' ||
        finalMealName == 'Kahvaltı:' ||
        finalMealName == 'Öğle:' ||
        finalMealName == 'Akşam:' ||
        finalMealName.endsWith(':')) {
      // Varsayılan isim oluştur
      final defaultName = _getDefaultMealNameForCategory(category ?? '');
      
      // Eğer kalori bilgisi varsa ismini daha detaylı yap
      if (calorie != null && calorie! > 0) {
        finalMealName = '$defaultName (${calorie!.toStringAsFixed(0)} kcal)';
      } else {
        finalMealName = defaultName;
      }
    }
    
    return Yemek(
      id: mealId ?? '',
      ad: finalMealName,
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

  /// Kategori için varsayılan yemek adı oluştur
  static String _getDefaultMealNameForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ara öğün 2':
      case 'ara ogun 2':
      case 'ara_ogun_2':
        return 'Ara Öğün 2: Sağlıklı Atıştırmalık';
      case 'ara öğün 1':
      case 'ara ogun 1':
      case 'ara_ogun_1':
        return 'Ara Öğün 1: Hafif Atıştırmalık';
      case 'kahvaltı':
      case 'kahvalti':
        return 'Kahvaltı Menüsü';
      case 'öğle':
      case 'ogle':
      case 'öğle yemeği':
      case 'ogle yemegi':
        return 'Öğle Yemeği';
      case 'akşam':
      case 'aksam':
      case 'akşam yemeği':
      case 'aksam yemegi':
        return 'Akşam Yemeği';
      case 'gece atıştırma':
      case 'gece atıştırması':
      case 'gece atistirma':
      case 'gece atistirmasi':
      case 'gece_atistirmasi':
        return 'Gece Atıştırması';
      case 'cheat meal':
      case 'cheat_meal':
        return 'Cheat Meal';
      default:
        return 'Yemek Menüsü';
    }
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
