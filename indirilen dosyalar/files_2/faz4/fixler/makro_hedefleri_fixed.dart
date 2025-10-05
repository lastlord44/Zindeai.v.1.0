// lib/domain/entities/makro_hedefleri.dart

import 'package:equatable/equatable.dart';

/// Günlük makro besin hedefleri
class MakroHedefleri extends Equatable {
  final double gunlukKalori;
  final double gunlukProtein; // gram
  final double gunlukKarbonhidrat; // gram
  final double gunlukYag; // gram

  const MakroHedefleri({
    required this.gunlukKalori,
    required this.gunlukProtein,
    required this.gunlukKarbonhidrat,
    required this.gunlukYag,
  });

  /// Protein kalorisi (1g protein = 4 kcal)
  double get proteinKalori => gunlukProtein * 4;

  /// Karbonhidrat kalorisi (1g karb = 4 kcal)
  double get karbonhidratKalori => gunlukKarbonhidrat * 4;

  /// Yağ kalorisi (1g yağ = 9 kcal)
  double get yagKalori => gunlukYag * 9;

  /// Protein yüzdesi
  double get proteinYuzdesi => (proteinKalori / gunlukKalori) * 100;

  /// Karbonhidrat yüzdesi
  double get karbonhidratYuzdesi => (karbonhidratKalori / gunlukKalori) * 100;

  /// Yağ yüzdesi
  double get yagYuzdesi => (yagKalori / gunlukKalori) * 100;

  /// Makro dağılımı (P/K/Y yüzdeleri)
  String get makroDagilimi {
    return '${proteinYuzdesi.toStringAsFixed(0)}/${karbonhidratYuzdesi.toStringAsFixed(0)}/${yagYuzdesi.toStringAsFixed(0)}';
  }

  @override
  List<Object?> get props => [
        gunlukKalori,
        gunlukProtein,
        gunlukKarbonhidrat,
        gunlukYag,
      ];

  /// Copy with
  MakroHedefleri copyWith({
    double? gunlukKalori,
    double? gunlukProtein,
    double? gunlukKarbonhidrat,
    double? gunlukYag,
  }) {
    return MakroHedefleri(
      gunlukKalori: gunlukKalori ?? this.gunlukKalori,
      gunlukProtein: gunlukProtein ?? this.gunlukProtein,
      gunlukKarbonhidrat: gunlukKarbonhidrat ?? this.gunlukKarbonhidrat,
      gunlukYag: gunlukYag ?? this.gunlukYag,
    );
  }

  /// JSON'dan oluştur
  factory MakroHedefleri.fromJson(Map<String, dynamic> json) {
    return MakroHedefleri(
      gunlukKalori: (json['gunlukKalori'] as num).toDouble(),
      gunlukProtein: (json['gunlukProtein'] as num).toDouble(),
      gunlukKarbonhidrat: (json['gunlukKarbonhidrat'] as num).toDouble(),
      gunlukYag: (json['gunlukYag'] as num).toDouble(),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'gunlukKalori': gunlukKalori,
      'gunlukProtein': gunlukProtein,
      'gunlukKarbonhidrat': gunlukKarbonhidrat,
      'gunlukYag': gunlukYag,
    };
  }
}
