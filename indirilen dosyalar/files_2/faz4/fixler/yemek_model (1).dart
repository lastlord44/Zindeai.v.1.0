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

  /// JSON'dan model oluştur
  factory YemekModel.fromJson(Map<String, dynamic> json) {
    return YemekModel(
      id: json['id'] as String,
      ad: json['ad'] as String,
      ogun: _ogunTipiFromString(json['ogun'] as String),
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      malzemeler: (json['malzemeler'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alternatifler: json['alternatifler'] != null
          ? (json['alternatifler'] as List<dynamic>)
              .map((e) => AlternatifBesin.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      hazirlamaSuresi: json['hazirlamaSuresi'] as int,
      zorluk: _zorlukFromString(json['zorluk'] as String),
      etiketler: json['etiketler'] != null
          ? (json['etiketler'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
          : [],
      tarif: json['tarif'] as String?,
      gorselUrl: json['gorselUrl'] as String?,
    );
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
    return Yemek._ogunTipiFromString(ogun);
  }

  /// String'den Zorluk enum'a çevir
  static Zorluk _zorlukFromString(String zorluk) {
    return Yemek._zorlukFromString(zorluk);
  }
}
