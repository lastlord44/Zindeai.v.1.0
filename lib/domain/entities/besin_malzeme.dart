// lib/domain/entities/besin_malzeme.dart
// ZindeAI — Material-based dynamic basket system
// Clean, null-safe, JSON-STRICT friendly

import 'dart:convert';
import 'yemek.dart'; // ✅ OgunTipi import edildi (enum conflict çözüldü)

enum BesinKategorisi {
  protein,
  karbonhidrat,
  yag,
  sebze,
  meyve,
  sut,
}

class BesinMalzeme {
  final String id;
  final String ad;
  final BesinKategorisi kategori;
  final List<OgunTipi> uygunOgunler;
  final double protein100g;
  final double karbonhidrat100g;
  final double yag100g;
  final double kalori100g;
  final double fiyat100g;
  final bool ekonomik;
  final List<String> alternatifler; // id list
  final String? alternatifAciklama;

  const BesinMalzeme({
    required this.id,
    required this.ad,
    required this.kategori,
    required this.uygunOgunler,
    required this.protein100g,
    required this.karbonhidrat100g,
    required this.yag100g,
    required this.kalori100g,
    required this.fiyat100g,
    required this.ekonomik,
    this.alternatifler = const [],
    this.alternatifAciklama,
  });

  double get proteinKaloriOrani => kalori100g > 0 ? (protein100g * 4.0) / kalori100g : 0.0;
  double get karbonhidratKaloriOrani => kalori100g > 0 ? (karbonhidrat100g * 4.0) / kalori100g : 0.0;
  double get yagKaloriOrani => kalori100g > 0 ? (yag100g * 9.0) / kalori100g : 0.0;

  Map<String, dynamic> toJson() => {
        "id": id,
        "ad": ad,
        "kategori": kategori.name,
        "uygunOgunler": uygunOgunler.map((e) => e.name).toList(),
        "protein100g": protein100g,
        "karbonhidrat100g": karbonhidrat100g,
        "yag100g": yag100g,
        "kalori100g": kalori100g,
        "fiyat100g": fiyat100g,
        "ekonomik": ekonomik,
        "alternatifler": alternatifler,
        if (alternatifAciklama != null) "alternatifAciklama": alternatifAciklama,
      };

  static BesinMalzeme fromJson(Map<String, dynamic> m) {
    BesinKategorisi parseKategori(String s) =>
        BesinKategorisi.values.firstWhere((e) => e.name == s);
    List<OgunTipi> parseOgunler(List list) => list
        .map((e) => OgunTipi.values.firstWhere((x) => x.name == e))
        .toList();

    return BesinMalzeme(
      id: m["id"],
      ad: m["ad"],
      kategori: parseKategori(m["kategori"]),
      uygunOgunler: parseOgunler(List.from(m["uygunOgunler"] ?? const [])),
      protein100g: (m["protein100g"] as num).toDouble(),
      karbonhidrat100g: (m["karbonhidrat100g"] as num).toDouble(),
      yag100g: (m["yag100g"] as num).toDouble(),
      kalori100g: (m["kalori100g"] as num).toDouble(),
      fiyat100g: (m["fiyat100g"] as num).toDouble(),
      ekonomik: m["ekonomik"] == true,
      alternatifler: List<String>.from(m["alternatifler"] ?? const []),
      alternatifAciklama: m["alternatifAciklama"],
    );
  }

  static List<BesinMalzeme> listFromJsonString(String s) {
    final data = json.decode(s) as List;
    return data.map((e) => BesinMalzeme.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String listToJsonString(List<BesinMalzeme> list) {
    final data = list.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
