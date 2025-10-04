import 'package:equatable/equatable.dart';

class MakroHedefleri extends Equatable {
  final double gunlukKalori;
  final double gunlukProtein; // gram
  final double gunlukKarbonhidrat; // gram
  final double gunlukYag; // gram
  final DateTime olusturmaTarihi;

  const MakroHedefleri({
    required this.gunlukKalori,
    required this.gunlukProtein,
    required this.gunlukKarbonhidrat,
    required this.gunlukYag,
    required this.olusturmaTarihi,
  });

  @override
  List<Object?> get props => [
        gunlukKalori,
        gunlukProtein,
        gunlukKarbonhidrat,
        gunlukYag,
        olusturmaTarihi,
      ];

  Map<String, dynamic> toMap() {
    return {
      'gunlukKalori': gunlukKalori,
      'gunlukProtein': gunlukProtein,
      'gunlukKarbonhidrat': gunlukKarbonhidrat,
      'gunlukYag': gunlukYag,
      'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
    };
  }

  MakroHedefleri copyWith({
    double? gunlukKalori,
    double? gunlukProtein,
    double? gunlukKarbonhidrat,
    double? gunlukYag,
    DateTime? olusturmaTarihi,
  }) {
    return MakroHedefleri(
      gunlukKalori: gunlukKalori ?? this.gunlukKalori,
      gunlukProtein: gunlukProtein ?? this.gunlukProtein,
      gunlukKarbonhidrat: gunlukKarbonhidrat ?? this.gunlukKarbonhidrat,
      gunlukYag: gunlukYag ?? this.gunlukYag,
      olusturmaTarihi: olusturmaTarihi ?? this.olusturmaTarihi,
    );
  }
}
