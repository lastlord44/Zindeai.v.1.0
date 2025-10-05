// data/models/yemek_model.dart

import '../../domain/entities/yemek.dart';
import '../../domain/entities/alternatif_besin.dart';

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

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'ogun': ogun.name,
      'kalori': kalori,
      'protein': protein,
      'karbonhidrat': karbonhidrat,
      'yag': yag,
      'malzemeler': malzemeler,
      'alternatifler': alternatifler.map((a) => a.toJson()).toList(),
      'hazirlamaSuresi': hazirlamaSuresi,
      'zorluk': zorluk.name,
      'etiketler': etiketler,
      'tarif': tarif,
      'gorselUrl': gorselUrl,
    };
  }

  /// Entity'ye dönüştür
  Yemek toEntity() {
    return Yemek(
      id: id,
      ad: ad,
      ogun: ogun,
      kalori: kalori,
      protein: protein,
      karbonhidrat: karbonhidrat,
      yag: yag,
      malzemeler: malzemeler,
      alternatifler: alternatifler,
      hazirlamaSuresi: hazirlamaSuresi,
      zorluk: zorluk,
      etiketler: etiketler,
      tarif: tarif,
      gorselUrl: gorselUrl,
    );
  }

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
    switch (ogun.toLowerCase()) {
      case 'kahvalti':
        return OgunTipi.kahvalti;
      case 'araogun1':
      case 'ara_ogun_1':
        return OgunTipi.araOgun1;
      case 'ogle':
        return OgunTipi.ogle;
      case 'araogun2':
      case 'ara_ogun_2':
        return OgunTipi.araOgun2;
      case 'aksam':
        return OgunTipi.aksam;
      case 'geceatistirma':
      case 'gece_atistirma':
        return OgunTipi.geceAtistirma;
      case 'cheatmeal':
      case 'cheat_meal':
        return OgunTipi.cheatMeal;
      default:
        throw Exception('Bilinmeyen öğün tipi: $ogun');
    }
  }

  /// String'den Zorluk enum'a çevir
  static Zorluk _zorlukFromString(String zorluk) {
    switch (zorluk.toLowerCase()) {
      case 'kolay':
        return Zorluk.kolay;
      case 'orta':
        return Zorluk.orta;
      case 'zor':
        return Zorluk.zor;
      default:
        throw Exception('Bilinmeyen zorluk seviyesi: $zorluk');
    }
  }
}

/// AlternatifBesin için JSON extension
extension AlternatifBesinJson on AlternatifBesin {
  Map<String, dynamic> toJson() {
    return {
      'orijinalBesin': orijinalBesin,
      'orijinalMiktar': orijinalMiktar,
      'birim': birim,
      'alternatifler': alternatifler
          .map((a) => {
                'besin': a.besin,
                'miktar': a.miktar,
                'benzerlikSkoru': a.benzerlikSkoru,
              })
          .toList(),
    };
  }

  static AlternatifBesin fromJson(Map<String, dynamic> json) {
    return AlternatifBesin(
      orijinalBesin: json['orijinalBesin'] as String,
      orijinalMiktar: (json['orijinalMiktar'] as num).toDouble(),
      birim: json['birim'] as String,
      alternatifler: (json['alternatifler'] as List<dynamic>)
          .map((e) => BesinAlternatifi(
                besin: e['besin'] as String,
                miktar: (e['miktar'] as num).toDouble(),
                benzerlikSkoru: (e['benzerlikSkoru'] as num).toDouble(),
              ))
          .toList(),
    );
  }
}
