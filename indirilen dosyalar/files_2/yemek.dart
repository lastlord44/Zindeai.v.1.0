// ============================================================================
// lib/domain/entities/yemek.dart
// FAZ 4: YEMEK ENTITY
// ============================================================================

import 'package:equatable/equatable.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum OgunTipi {
  kahvalti('Kahvaltı', '🍳'),
  araOgun1('Ara Öğün 1', '🍎'),
  ogle('Öğle Yemeği', '🍽️'),
  araOgun2('Ara Öğün 2', '🥤'),
  aksam('Akşam Yemeği', '🌙'),
  geceAtistirma('Gece Atıştırması', '🌃'),
  cheatMeal('Cheat Meal', '🍔');

  final String aciklama;
  final String emoji;
  const OgunTipi(this.aciklama, this.emoji);
}

enum Zorluk {
  kolay('Kolay', '😊'),
  orta('Orta', '🤔'),
  zor('Zor', '💪');

  final String aciklama;
  final String emoji;
  const Zorluk(this.aciklama, this.emoji);
}

// ============================================================================
// YEMEK ENTITY
// ============================================================================

class Yemek extends Equatable {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final int hazirlamaSuresi; // dakika
  final Zorluk zorluk;
  final List<String> etiketler;
  final String? tarif;
  final String? gorselUrl;

  const Yemek({
    required this.id,
    required this.ad,
    required this.ogun,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.malzemeler,
    this.hazirlamaSuresi = 0,
    this.zorluk = Zorluk.kolay,
    this.etiketler = const [],
    this.tarif,
    this.gorselUrl,
  });

  @override
  List<Object?> get props => [
        id,
        ad,
        ogun,
        kalori,
        protein,
        karbonhidrat,
        yag,
        malzemeler,
        hazirlamaSuresi,
        zorluk,
        etiketler,
        tarif,
        gorselUrl,
      ];

  // ============================================================================
  // MAKRO KONTROLÜ
  // ============================================================================

  /// Makro hedeflerine uygun mu kontrol et
  bool makroyaUygunMu({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    double tolerans = 0.15,
  }) {
    final ogunBasinaKalori = hedefKalori / 5;
    final ogunBasinaProtein = hedefProtein / 5;

    final kaloriFark = (kalori - ogunBasinaKalori).abs();
    final kaloriToleranti = ogunBasinaKalori * tolerans;

    if (kaloriFark > kaloriToleranti) return false;

    final proteinFark = (protein - ogunBasinaProtein).abs();
    final proteinToleranti = ogunBasinaProtein * tolerans;

    if (proteinFark > proteinToleranti) return false;

    return true;
  }

  /// Makro skoru (0-100 arası)
  double makroSkoru({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    final ogunBasinaKalori = hedefKalori / 5;
    final ogunBasinaProtein = hedefProtein / 5;
    final ogunBasinaKarb = hedefKarb / 5;
    final ogunBasinaYag = hedefYag / 5;

    final kaloriSapma = (kalori - ogunBasinaKalori).abs() / ogunBasinaKalori;
    final proteinSapma = (protein - ogunBasinaProtein).abs() / ogunBasinaProtein;
    final karbSapma = (karbonhidrat - ogunBasinaKarb).abs() / ogunBasinaKarb;
    final yagSapma = (yag - ogunBasinaYag).abs() / ogunBasinaYag;

    final toplamSapma = (kaloriSapma * 0.4 +
            proteinSapma * 0.35 +
            karbSapma * 0.15 +
            yagSapma * 0.1)
        .clamp(0.0, 1.0);

    return (1 - toplamSapma) * 100;
  }

  // ============================================================================
  // KISITLAMA KONTROLÜ
  // ============================================================================

  /// Kısıtlamalara uygun mu kontrol et
  bool kisitlamayaUygunMu(List<String> kisitlamalar) {
    if (kisitlamalar.isEmpty) return true;

    final malzemelerKucuk = malzemeler.map((m) => m.toLowerCase()).toSet();
    final kisitlamalarKucuk = kisitlamalar.map((k) => k.toLowerCase()).toSet();

    for (final kisitlama in kisitlamalarKucuk) {
      for (final malzeme in malzemelerKucuk) {
        if (malzeme.contains(kisitlama)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Etiket kontrolü
  bool etiketIceriyorMu(String etiket) {
    return etiketler.any((e) => e.toLowerCase() == etiket.toLowerCase());
  }

  // ============================================================================
  // JSON SERIALIZATION
  // ============================================================================

  factory Yemek.fromJson(Map<String, dynamic> json) {
    return Yemek(
      id: json['id'] as String,
      ad: json['ad'] as String,
      ogun: OgunTipi.values.firstWhere(
        (e) => e.name == json['ogun'],
        orElse: () => OgunTipi.kahvalti,
      ),
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      malzemeler: (json['malzemeler'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      hazirlamaSuresi: json['hazirlamaSuresi'] as int? ?? 0,
      zorluk: json['zorluk'] != null
          ? Zorluk.values.firstWhere(
              (e) => e.name == json['zorluk'],
              orElse: () => Zorluk.kolay,
            )
          : Zorluk.kolay,
      etiketler: json['etiketler'] != null
          ? (json['etiketler'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      tarif: json['tarif'] as String?,
      gorselUrl: json['gorselUrl'] as String?,
    );
  }

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
      'hazirlamaSuresi': hazirlamaSuresi,
      'zorluk': zorluk.name,
      'etiketler': etiketler,
      'tarif': tarif,
      'gorselUrl': gorselUrl,
    };
  }

  @override
  String toString() {
    return '''
Yemek: $ad
Öğün: ${ogun.aciklama}
Kalori: ${kalori.toStringAsFixed(0)} kcal
Protein: ${protein.toStringAsFixed(1)}g
Karb: ${karbonhidrat.toStringAsFixed(1)}g
Yağ: ${yag.toStringAsFixed(1)}g
''';
  }
}
