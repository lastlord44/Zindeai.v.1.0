// ============================================================================
// ALTERNATİF BESİN SİSTEMİ
// ============================================================================

import 'package:equatable/equatable.dart';

// ============================================================================
// ALTERNATİF BESİN MODELİ
// ============================================================================

class AlternatifBesin extends Equatable {
  final String ad;
  final double miktar;
  final String birim;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final String neden; // Neden alternatif (örn: "Benzer protein profili")

  const AlternatifBesin({
    required this.ad,
    required this.miktar,
    required this.birim,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.neden,
  });

  @override
  List<Object?> get props =>
      [ad, miktar, birim, kalori, protein, karbonhidrat, yag, neden];

  factory AlternatifBesin.fromJson(Map<String, dynamic> json) {
    return AlternatifBesin(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      neden: json['neden'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'miktar': miktar,
      'birim': birim,
      'kalori': kalori,
      'protein': protein,
      'karbonhidrat': karbonhidrat,
      'yag': yag,
      'neden': neden,
    };
  }
}

// ============================================================================
// BESİN İÇERİĞİ (Meal model'e eklenecek)
// ============================================================================

class BesinIcerigi extends Equatable {
  final String ad;
  final double miktar;
  final String birim;
  final List<AlternatifBesin> alternatifler;

  const BesinIcerigi({
    required this.ad,
    required this.miktar,
    required this.birim,
    this.alternatifler = const [],
  });

  @override
  List<Object?> get props => [ad, miktar, birim, alternatifler];

  factory BesinIcerigi.fromJson(Map<String, dynamic> json) {
    final alternatiflerJson = json['alternatifler'] as List<dynamic>?;
    final alternatifler = alternatiflerJson
            ?.map((a) => AlternatifBesin.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return BesinIcerigi(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      alternatifler: alternatifler,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'miktar': miktar,
      'birim': birim,
      'alternatifler': alternatifler.map((a) => a.toJson()).toList(),
    };
  }
}
