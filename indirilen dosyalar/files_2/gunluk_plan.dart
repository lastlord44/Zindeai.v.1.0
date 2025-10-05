// ============================================================================
// lib/domain/entities/gunluk_plan.dart
// FAZ 5: GÜNLÜK PLAN ENTITY
// ============================================================================

import 'package:equatable/equatable.dart';
import 'yemek.dart';

class GunlukPlan extends Equatable {
  final String id;
  final DateTime tarih;
  final Yemek kahvalti;
  final Yemek araOgun1;
  final Yemek ogle;
  final Yemek araOgun2;
  final Yemek aksam;
  final Yemek? geceAtistirma;
  final double fitnessSkor; // 0-100 arası

  const GunlukPlan({
    required this.id,
    required this.tarih,
    required this.kahvalti,
    required this.araOgun1,
    required this.ogle,
    required this.araOgun2,
    required this.aksam,
    this.geceAtistirma,
    required this.fitnessSkor,
  });

  // Toplam makrolar
  double get toplamKalori =>
      kahvalti.kalori +
      araOgun1.kalori +
      ogle.kalori +
      araOgun2.kalori +
      aksam.kalori +
      (geceAtistirma?.kalori ?? 0);

  double get toplamProtein =>
      kahvalti.protein +
      araOgun1.protein +
      ogle.protein +
      araOgun2.protein +
      aksam.protein +
      (geceAtistirma?.protein ?? 0);

  double get toplamKarbonhidrat =>
      kahvalti.karbonhidrat +
      araOgun1.karbonhidrat +
      ogle.karbonhidrat +
      araOgun2.karbonhidrat +
      aksam.karbonhidrat +
      (geceAtistirma?.karbonhidrat ?? 0);

  double get toplamYag =>
      kahvalti.yag +
      araOgun1.yag +
      ogle.yag +
      araOgun2.yag +
      aksam.yag +
      (geceAtistirma?.yag ?? 0);

  List<Yemek> get tumOgunler => [
        kahvalti,
        araOgun1,
        ogle,
        araOgun2,
        aksam,
        if (geceAtistirma != null) geceAtistirma!,
      ];

  @override
  List<Object?> get props => [
        id,
        tarih,
        kahvalti,
        araOgun1,
        ogle,
        araOgun2,
        aksam,
        geceAtistirma,
        fitnessSkor,
      ];

  GunlukPlan copyWith({
    String? id,
    DateTime? tarih,
    Yemek? kahvalti,
    Yemek? araOgun1,
    Yemek? ogle,
    Yemek? araOgun2,
    Yemek? aksam,
    Yemek? geceAtistirma,
    double? fitnessSkor,
  }) {
    return GunlukPlan(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      kahvalti: kahvalti ?? this.kahvalti,
      araOgun1: araOgun1 ?? this.araOgun1,
      ogle: ogle ?? this.ogle,
      araOgun2: araOgun2 ?? this.araOgun2,
      aksam: aksam ?? this.aksam,
      geceAtistirma: geceAtistirma ?? this.geceAtistirma,
      fitnessSkor: fitnessSkor ?? this.fitnessSkor,
    );
  }

  @override
  String toString() {
    return '''
📅 Günlük Plan (${tarih.day}/${tarih.month}/${tarih.year})
🏆 Fitness Skoru: ${fitnessSkor.toStringAsFixed(1)}/100

🍳 Kahvaltı: ${kahvalti.ad}
🍎 Ara Öğün 1: ${araOgun1.ad}
🍽️  Öğle: ${ogle.ad}
🥤 Ara Öğün 2: ${araOgun2.ad}
🌙 Akşam: ${aksam.ad}
${geceAtistirma != null ? '🌃 Gece: ${geceAtistirma!.ad}' : ''}

📊 TOPLAM MAKROLAR:
   🔥 Kalori: ${toplamKalori.toStringAsFixed(0)} kcal
   💪 Protein: ${toplamProtein.toStringAsFixed(1)} g
   🍚 Karbonhidrat: ${toplamKarbonhidrat.toStringAsFixed(1)} g
   🥑 Yağ: ${toplamYag.toStringAsFixed(1)} g
''';
  }
}
