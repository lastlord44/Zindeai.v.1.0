// lib/data/models/yemek_model.dart

import '../../domain/entities/yemek.dart';
import '../../domain/entities/alternatif_besin.dart';

/// Yemek model sınıfı (Data layer)
/// Entity ile aynı yapıda, sadece JSON parsing için kullanılır
class YemekModel extends Yemek {
  const YemekModel({
    required super.id,
    required super.ad,
    required super.ogun,
    required super.kalori,
    required super.protein,
    required super.karbonhidrat,
    required super.yag,
    required super.malzemeler,
    super.alternatifler,
    required super.hazirlamaSuresi,
    required super.zorluk,
    super.etiketler,
    super.tarif,
    super.gorselUrl,
  });

  /// JSON'dan model oluştur (null-safe)
  factory YemekModel.fromJson(Map<String, dynamic> json) {
    // Required field kontrolü ve default değerler
    final id = json['id']?.toString() ?? '';
    final ad = json['ad']?.toString() ?? 'İsimsiz Yemek';
    final ogunStr = json['ogun']?.toString() ?? 'kahvalti';
    
    // Makro değerleri için null-safe parsing
    final kalori = _parseDouble(json['kalori']) ?? 0.0;
    final protein = _parseDouble(json['protein']) ?? 0.0;
    final karbonhidrat = _parseDouble(json['karbonhidrat']) ?? 0.0;
    final yag = _parseDouble(json['yag']) ?? 0.0;
    
    // Malzemeler listesi için null-safe parsing
    final malzemeler = _parseStringList(json['malzemeler']) ?? [];
    
    // Alternatifler için null-safe parsing
    final alternatifler = _parseAlternatifler(json['alternatifler']) ?? [];
    
    // Hazırlama süresi için null-safe parsing
    final hazirlamaSuresi = _parseInt(json['hazirlamaSuresi']) ?? 0;
    
    // Zorluk için null-safe parsing
    final zorlukStr = json['zorluk']?.toString() ?? 'kolay';
    
    // Etiketler için null-safe parsing
    final etiketler = _parseStringList(json['etiketler']) ?? [];
    
    return YemekModel(
      id: id,
      ad: ad,
      ogun: _ogunTipiFromString(ogunStr),
      kalori: kalori,
      protein: protein,
      karbonhidrat: karbonhidrat,
      yag: yag,
      malzemeler: malzemeler,
      alternatifler: alternatifler,
      hazirlamaSuresi: hazirlamaSuresi,
      zorluk: _zorlukFromString(zorlukStr),
      etiketler: etiketler,
      tarif: json['tarif']?.toString(),
      gorselUrl: json['gorselUrl']?.toString(),
    );
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
      return value
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Alternatif besinler parse helper metodu
  static List<AlternatifBesin>? _parseAlternatifler(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => AlternatifBesin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Model'i JSON'a çevir (Yemek entity'sinde zaten var)
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  /// Entity'ye dönüştür (zaten Yemek extend ediyor, direkt kullanılabilir)
  Yemek toEntity() => this;

  /// Entity'den model oluştur
  factory YemekModel.fromEntity(Yemek entity) {
    return YemekModel(
      id: entity.id,
      ad: entity.ad,
      ogun: entity.ogun,
      kalori: entity.kalori,
      protein: entity.protein,
      karbonhidrat: entity.karbonhidrat,
      yag: entity.yag,
      malzemeler: entity.malzemeler,
      alternatifler: entity.alternatifler,
      hazirlamaSuresi: entity.hazirlamaSuresi,
      zorluk: entity.zorluk,
      etiketler: entity.etiketler,
      tarif: entity.tarif,
      gorselUrl: entity.gorselUrl,
    );
  }

  /// String'den OgunTipi enum'a çevir
  static OgunTipi _ogunTipiFromString(String ogun) {
    return Yemek.ogunTipiFromString(ogun);
  }

  /// String'den Zorluk enum'a çevir
  static Zorluk _zorlukFromString(String zorluk) {
    return Yemek.zorlukFromString(zorluk);
  }
}
