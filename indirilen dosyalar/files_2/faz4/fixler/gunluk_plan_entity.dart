// lib/domain/entities/gunluk_plan.dart

import 'package:equatable/equatable.dart';
import 'yemek.dart';
import 'makro_hedefleri.dart';

/// Günlük beslenme planı
class GunlukPlan extends Equatable {
  final String id;
  final DateTime tarih;
  final Yemek? kahvalti;
  final Yemek? araOgun1;
  final Yemek? ogleYemegi; // ✅ Eklendi
  final Yemek? araOgun2;
  final Yemek? aksamYemegi; // ✅ Eklendi
  final Yemek? geceAtistirma;
  final MakroHedefleri makroHedefleri; // ✅ Eklendi
  final double fitnessSkoru; // ✅ Eklendi (0-100 arası)

  const GunlukPlan({
    required this.id,
    required this.tarih,
    this.kahvalti,
    this.araOgun1,
    this.ogleYemegi,
    this.araOgun2,
    this.aksamYemegi,
    this.geceAtistirma,
    required this.makroHedefleri,
    this.fitnessSkoru = 0,
  });

  /// Tüm öğünleri liste olarak döndür
  List<Yemek> get ogunler {
    return [
      if (kahvalti != null) kahvalti!,
      if (araOgun1 != null) araOgun1!,
      if (ogleYemegi != null) ogleYemegi!,
      if (araOgun2 != null) araOgun2!,
      if (aksamYemegi != null) aksamYemegi!,
      if (geceAtistirma != null) geceAtistirma!,
    ];
  }

  /// Toplam kalori
  double get toplamKalori {
    return ogunler.fold(0, (total, yemek) => total + yemek.kalori);
  }

  /// Toplam protein
  double get toplamProtein {
    return ogunler.fold(0, (total, yemek) => total + yemek.protein);
  }

  /// Toplam karbonhidrat
  double get toplamKarbonhidrat {
    return ogunler.fold(0, (total, yemek) => total + yemek.karbonhidrat);
  }

  /// Toplam yağ
  double get toplamYag {
    return ogunler.fold(0, (total, yemek) => total + yemek.yag);
  }

  /// Hedefe göre kalori farkı yüzdesi
  double get kaloriYuzdesi {
    return (toplamKalori / makroHedefleri.gunlukKalori) * 100;
  }

  /// Hedefe göre protein farkı yüzdesi
  double get proteinYuzdesi {
    return (toplamProtein / makroHedefleri.gunlukProtein) * 100;
  }

  /// Hedefe göre karbonhidrat farkı yüzdesi
  double get karbonhidratYuzdesi {
    return (toplamKarbonhidrat / makroHedefleri.gunlukKarbonhidrat) * 100;
  }

  /// Hedefe göre yağ farkı yüzdesi
  double get yagYuzdesi {
    return (toplamYag / makroHedefleri.gunlukYag) * 100;
  }

  /// Plan tamamlandı mı?
  bool get tamamlandi {
    return kahvalti != null &&
        ogleYemegi != null &&
        aksamYemegi != null;
  }

  /// Kaç öğün planlandı?
  int get planlananOgunSayisi => ogunler.length;

  @override
  List<Object?> get props => [
        id,
        tarih,
        kahvalti,
        araOgun1,
        ogleYemegi,
        araOgun2,
        aksamYemegi,
        geceAtistirma,
        makroHedefleri,
        fitnessSkoru,
      ];

  /// Copy with
  GunlukPlan copyWith({
    String? id,
    DateTime? tarih,
    Yemek? kahvalti,
    Yemek? araOgun1,
    Yemek? ogleYemegi,
    Yemek? araOgun2,
    Yemek? aksamYemegi,
    Yemek? geceAtistirma,
    MakroHedefleri? makroHedefleri,
    double? fitnessSkoru,
  }) {
    return GunlukPlan(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      kahvalti: kahvalti ?? this.kahvalti,
      araOgun1: araOgun1 ?? this.araOgun1,
      ogleYemegi: ogleYemegi ?? this.ogleYemegi,
      araOgun2: araOgun2 ?? this.araOgun2,
      aksamYemegi: aksamYemegi ?? this.aksamYemegi,
      geceAtistirma: geceAtistirma ?? this.geceAtistirma,
      makroHedefleri: makroHedefleri ?? this.makroHedefleri,
      fitnessSkoru: fitnessSkoru ?? this.fitnessSkoru,
    );
  }

  /// JSON'dan oluştur
  factory GunlukPlan.fromJson(Map<String, dynamic> json) {
    return GunlukPlan(
      id: json['id'] as String,
      tarih: DateTime.parse(json['tarih'] as String),
      kahvalti: json['kahvalti'] != null
          ? Yemek.fromJson(json['kahvalti'] as Map<String, dynamic>)
          : null,
      araOgun1: json['araOgun1'] != null
          ? Yemek.fromJson(json['araOgun1'] as Map<String, dynamic>)
          : null,
      ogleYemegi: json['ogleYemegi'] != null
          ? Yemek.fromJson(json['ogleYemegi'] as Map<String, dynamic>)
          : null,
      araOgun2: json['araOgun2'] != null
          ? Yemek.fromJson(json['araOgun2'] as Map<String, dynamic>)
          : null,
      aksamYemegi: json['aksamYemegi'] != null
          ? Yemek.fromJson(json['aksamYemegi'] as Map<String, dynamic>)
          : null,
      geceAtistirma: json['geceAtistirma'] != null
          ? Yemek.fromJson(json['geceAtistirma'] as Map<String, dynamic>)
          : null,
      makroHedefleri: MakroHedefleri.fromJson(
        json['makroHedefleri'] as Map<String, dynamic>,
      ),
      fitnessSkoru: (json['fitnessSkoru'] as num?)?.toDouble() ?? 0,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tarih': tarih.toIso8601String(),
      'kahvalti': kahvalti?.toJson(),
      'araOgun1': araOgun1?.toJson(),
      'ogleYemegi': ogleYemegi?.toJson(),
      'araOgun2': araOgun2?.toJson(),
      'aksamYemegi': aksamYemegi?.toJson(),
      'geceAtistirma': geceAtistirma?.toJson(),
      'makroHedefleri': makroHedefleri.toJson(),
      'fitnessSkoru': fitnessSkoru,
    };
  }
}
