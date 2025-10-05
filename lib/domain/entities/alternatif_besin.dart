// lib/domain/entities/alternatif_besin.dart

import 'package:equatable/equatable.dart';

/// Bir besin için alternatif öneri
class BesinAlternatifi extends Equatable {
  final String besin;
  final double miktar;
  final double benzerlikSkoru; // 0-1 arası

  const BesinAlternatifi({
    required this.besin,
    required this.miktar,
    required this.benzerlikSkoru,
  });

  @override
  List<Object?> get props => [besin, miktar, benzerlikSkoru];

  /// JSON'dan oluştur
  factory BesinAlternatifi.fromJson(Map<String, dynamic> json) {
    return BesinAlternatifi(
      besin: json['besin'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      benzerlikSkoru: (json['benzerlikSkoru'] as num).toDouble(),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'besin': besin,
      'miktar': miktar,
      'benzerlikSkoru': benzerlikSkoru,
    };
  }
}

/// Bir malzeme için alternatif besin önerileri
class AlternatifBesin extends Equatable {
  final String orijinalBesin;
  final double orijinalMiktar;
  final String birim;
  final List<BesinAlternatifi> alternatifler;

  const AlternatifBesin({
    required this.orijinalBesin,
    required this.orijinalMiktar,
    required this.birim,
    required this.alternatifler,
  });

  /// En iyi alternatifi getir
  BesinAlternatifi get enIyiAlternatif {
    if (alternatifler.isEmpty) {
      throw Exception('Alternatif bulunamadı');
    }
    return alternatifler
        .reduce((a, b) => a.benzerlikSkoru > b.benzerlikSkoru ? a : b);
  }

  /// Belirli benzerlik skorunun üzerindeki alternatifleri getir
  List<BesinAlternatifi> yuksekSkorluAlternatifler(double minSkor) {
    return alternatifler.where((a) => a.benzerlikSkoru >= minSkor).toList()
      ..sort((a, b) => b.benzerlikSkoru.compareTo(a.benzerlikSkoru));
  }

  @override
  List<Object?> get props =>
      [orijinalBesin, orijinalMiktar, birim, alternatifler];

  /// JSON'dan oluştur
  factory AlternatifBesin.fromJson(Map<String, dynamic> json) {
    return AlternatifBesin(
      orijinalBesin: json['orijinalBesin'] as String,
      orijinalMiktar: (json['orijinalMiktar'] as num).toDouble(),
      birim: json['birim'] as String,
      alternatifler: (json['alternatifler'] as List<dynamic>)
          .map((e) => BesinAlternatifi.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'orijinalBesin': orijinalBesin,
      'orijinalMiktar': orijinalMiktar,
      'birim': birim,
      'alternatifler': alternatifler.map((a) => a.toJson()).toList(),
    };
  }

  /// Copy with
  AlternatifBesin copyWith({
    String? orijinalBesin,
    double? orijinalMiktar,
    String? birim,
    List<BesinAlternatifi>? alternatifler,
  }) {
    return AlternatifBesin(
      orijinalBesin: orijinalBesin ?? this.orijinalBesin,
      orijinalMiktar: orijinalMiktar ?? this.orijinalMiktar,
      birim: birim ?? this.birim,
      alternatifler: alternatifler ?? this.alternatifler,
    );
  }
}
