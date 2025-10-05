// lib/domain/entities/alternatif_besin_legacy.dart
// ⚠️ LEGACY MODEL - Used by UI and service layer
// This is the OLD model structure that the UI expects

import 'package:equatable/equatable.dart';

/// Legacy AlternatifBesin model for backward compatibility
/// Used by UI widgets and alternatif_oneri_servisi
class AlternatifBesinLegacy extends Equatable {
  final String ad;
  final double miktar;
  final String birim;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final String neden;

  const AlternatifBesinLegacy({
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
  List<Object?> get props => [
        ad,
        miktar,
        birim,
        kalori,
        protein,
        karbonhidrat,
        yag,
        neden,
      ];

  /// JSON'dan oluştur
  factory AlternatifBesinLegacy.fromJson(Map<String, dynamic> json) {
    return AlternatifBesinLegacy(
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

  /// JSON'a çevir
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

  /// Copy with
  AlternatifBesinLegacy copyWith({
    String? ad,
    double? miktar,
    String? birim,
    double? kalori,
    double? protein,
    double? karbonhidrat,
    double? yag,
    String? neden,
  }) {
    return AlternatifBesinLegacy(
      ad: ad ?? this.ad,
      miktar: miktar ?? this.miktar,
      birim: birim ?? this.birim,
      kalori: kalori ?? this.kalori,
      protein: protein ?? this.protein,
      karbonhidrat: karbonhidrat ?? this.karbonhidrat,
      yag: yag ?? this.yag,
      neden: neden ?? this.neden,
    );
  }
}
