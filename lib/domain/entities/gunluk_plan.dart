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

  // ========================================================================
  // 🎯 MAKRO TOLERANS KONTROLÜ (Diyetisyen Standartları)
  // ========================================================================

  /// 🔥 Kalori için tolerans limiti (%12) - UNİFORM STANDARD
  static const double kaloriToleransYuzdesi = 12.0;

  /// 🔥 Protein için tolerans limiti (%12) - UNİFORM STANDARD
  static const double proteinToleransYuzdesi = 12.0;

  /// 🔥 Karbonhidrat için tolerans limiti (%12) - UNİFORM STANDARD
  static const double karbonhidratToleransYuzdesi = 12.0;

  /// 🔥 Yağ için tolerans limiti (%12) - UNİFORM STANDARD
  static const double yagToleransYuzdesi = 12.0;

  /// Kalori tolerans içinde mi?
  bool get kaloriToleranstaMi {
    final sapma = ((toplamKalori - makroHedefleri.gunlukKalori).abs() /
            makroHedefleri.gunlukKalori) *
        100;
    return sapma <= kaloriToleransYuzdesi;
  }

  /// Protein tolerans içinde mi?
  bool get proteinToleranstaMi {
    final sapma = ((toplamProtein - makroHedefleri.gunlukProtein).abs() /
            makroHedefleri.gunlukProtein) *
        100;
    return sapma <= proteinToleransYuzdesi;
  }

  /// Karbonhidrat tolerans içinde mi?
  bool get karbonhidratToleranstaMi {
    final sapma =
        ((toplamKarbonhidrat - makroHedefleri.gunlukKarbonhidrat).abs() /
                makroHedefleri.gunlukKarbonhidrat) *
            100;
    return sapma <= karbonhidratToleransYuzdesi;
  }

  /// Yağ tolerans içinde mi?
  bool get yagToleranstaMi {
    final sapma = ((toplamYag - makroHedefleri.gunlukYag).abs() /
            makroHedefleri.gunlukYag) *
        100;
    return sapma <= yagToleransYuzdesi;
  }

  /// TÜM makrolar tolerans içinde mi? (KRİTİK KONTROL!)
  bool get tumMakrolarToleranstaMi {
    return kaloriToleranstaMi &&
        proteinToleranstaMi &&
        karbonhidratToleranstaMi &&
        yagToleranstaMi;
  }

  /// Kalori sapma yüzdesi (mutlak değer)
  double get kaloriSapmaYuzdesi {
    return ((toplamKalori - makroHedefleri.gunlukKalori).abs() /
            makroHedefleri.gunlukKalori) *
        100;
  }

  /// Protein sapma yüzdesi (mutlak değer)
  double get proteinSapmaYuzdesi {
    return ((toplamProtein - makroHedefleri.gunlukProtein).abs() /
            makroHedefleri.gunlukProtein) *
        100;
  }

  /// Karbonhidrat sapma yüzdesi (mutlak değer)
  double get karbonhidratSapmaYuzdesi {
    return ((toplamKarbonhidrat - makroHedefleri.gunlukKarbonhidrat).abs() /
            makroHedefleri.gunlukKarbonhidrat) *
        100;
  }

  /// Yağ sapma yüzdesi (mutlak değer)
  double get yagSapmaYuzdesi {
    return ((toplamYag - makroHedefleri.gunlukYag).abs() /
            makroHedefleri.gunlukYag) *
        100;
  }

  /// Tolerans aşan makroların listesi (debug/UI için)
  List<String> get toleransAsanMakrolar {
    final asanlar = <String>[];

    if (!kaloriToleranstaMi) {
      asanlar.add('Kalori (${kaloriSapmaYuzdesi.toStringAsFixed(1)}% sapma)');
    }
    if (!proteinToleranstaMi) {
      asanlar.add('Protein (${proteinSapmaYuzdesi.toStringAsFixed(1)}% sapma)');
    }
    if (!karbonhidratToleranstaMi) {
      asanlar.add(
          'Karbonhidrat (${karbonhidratSapmaYuzdesi.toStringAsFixed(1)}% sapma)');
    }
    if (!yagToleranstaMi) {
      asanlar.add('Yağ (${yagSapmaYuzdesi.toStringAsFixed(1)}% sapma)');
    }

    return asanlar;
  }

  /// Makro kalitesi skoru (0-100) - tolerans göz önünde bulundurularak
  double get makroKaliteSkoru {
    if (tumMakrolarToleranstaMi) {
      // Tüm makrolar toleransta: 90-100 puan (sapma ne kadar az o kadar yüksek)
      final ortalamaSapma = (kaloriSapmaYuzdesi +
              proteinSapmaYuzdesi +
              karbonhidratSapmaYuzdesi +
              yagSapmaYuzdesi) /
          4;
      return 100 - (ortalamaSapma * 2); // Sapma arttıkça skor azalır
    } else {
      // Tolerans aşıldı: 0-89 puan (ceza!)
      final ortalamaSapma = (kaloriSapmaYuzdesi +
              proteinSapmaYuzdesi +
              karbonhidratSapmaYuzdesi +
              yagSapmaYuzdesi) /
          4;
      return (90 - (ortalamaSapma * 5)).clamp(0.0, 89.0); // Ağır ceza
    }
  }

  /// Plan tamamlandı mı?
  bool get tamamlandi {
    return kahvalti != null && ogleYemegi != null && aksamYemegi != null;
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

  /// ID'ye göre bir öğünü günceller veya kaldırır
  GunlukPlan copyWithOgun(String ogunId, Yemek? yeniOgun) {
    return GunlukPlan(
      id: id,
      tarih: tarih,
      makroHedefleri: makroHedefleri,
      fitnessSkoru: fitnessSkoru,
      kahvalti: kahvalti?.id == ogunId ? yeniOgun : kahvalti,
      araOgun1: araOgun1?.id == ogunId ? yeniOgun : araOgun1,
      ogleYemegi: ogleYemegi?.id == ogunId ? yeniOgun : ogleYemegi,
      araOgun2: araOgun2?.id == ogunId ? yeniOgun : araOgun2,
      aksamYemegi: aksamYemegi?.id == ogunId ? yeniOgun : aksamYemegi,
      geceAtistirma: geceAtistirma?.id == ogunId ? yeniOgun : geceAtistirma,
    );
  }
}
