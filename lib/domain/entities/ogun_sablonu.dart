// lib/domain/entities/ogun_sablonu.dart

import 'dart:convert';
import 'besin_malzeme.dart';
import 'yemek.dart'; // ✅ OgunTipi import edildi

class OgunKategoriKurali {
  final BesinKategorisi kategori;
  final int minAdet;
  final int maxAdet;
  final double minOran;
  final double maxOran;
  final List<String> zorunluMalzemeler;
  final List<String> yasakMalzemeler;

  const OgunKategoriKurali({
    required this.kategori,
    required this.minAdet,
    required this.maxAdet,
    required this.minOran,
    required this.maxOran,
    this.zorunluMalzemeler = const [],
    this.yasakMalzemeler = const [],
  });

  Map<String, dynamic> toJson() => {
        "kategori": kategori.name,
        "minAdet": minAdet,
        "maxAdet": maxAdet,
        "minOran": minOran,
        "maxOran": maxOran,
        "zorunluMalzemeler": zorunluMalzemeler,
        "yasakMalzemeler": yasakMalzemeler,
      };
}

class OgunSablonu {
  final OgunTipi ogunTipi;
  final Map<BesinKategorisi, OgunKategoriKurali> kategoriKurallari;

  const OgunSablonu({required this.ogunTipi, required this.kategoriKurallari});

  Map<String, dynamic> toJson() => {
        "ogunTipi": ogunTipi.name,
        "kategoriKurallari": kategoriKurallari.map((k, v) => MapEntry(k.name, v.toJson())),
      };
}

List<OgunSablonu> defaultTemplatesTRStrict() {
  return [
    OgunSablonu(
      ogunTipi: OgunTipi.kahvalti,
      kategoriKurallari: {
        BesinKategorisi.protein: OgunKategoriKurali(
          kategori: BesinKategorisi.protein,
          minAdet: 1, maxAdet: 2,
          minOran: 0.25, maxOran: 0.40,
          yasakMalzemeler: ["Tavuk Göğsü","Dana Bonfile","Kuzu Pirzola"],
        ),
        BesinKategorisi.karbonhidrat: OgunKategoriKurali(
          kategori: BesinKategorisi.karbonhidrat,
          minAdet: 1, maxAdet: 1,
          minOran: 0.35, maxOran: 0.50,
          yasakMalzemeler: ["Pirinç","Makarna","Patates"],
        ),
        BesinKategorisi.yag: OgunKategoriKurali(
          kategori: BesinKategorisi.yag,
          minAdet: 1, maxAdet: 2,
          minOran: 0.15, maxOran: 0.30,
        ),
        BesinKategorisi.sebze: OgunKategoriKurali(
          kategori: BesinKategorisi.sebze,
          minAdet: 0, maxAdet: 2,
          minOran: 0.0, maxOran: 0.15,
        ),
      },
    ),
    OgunSablonu(
      ogunTipi: OgunTipi.araOgun1,
      kategoriKurallari: {
        BesinKategorisi.protein: OgunKategoriKurali(
          kategori: BesinKategorisi.protein,
          minAdet: 0, maxAdet: 1,
          minOran: 0.15, maxOran: 0.30,
        ),
        BesinKategorisi.karbonhidrat: OgunKategoriKurali(
          kategori: BesinKategorisi.karbonhidrat,
          minAdet: 1, maxAdet: 1,
          minOran: 0.30, maxOran: 0.45,
          yasakMalzemeler: ["Pirinç","Patates","Makarna"],
        ),
        BesinKategorisi.yag: OgunKategoriKurali(
          kategori: BesinKategorisi.yag,
          minAdet: 0, maxAdet: 1,
          minOran: 0.15, maxOran: 0.25,
        ),
        BesinKategorisi.meyve: OgunKategoriKurali(
          kategori: BesinKategorisi.meyve,
          minAdet: 0, maxAdet: 1,
          minOran: 0.0, maxOran: 0.25,
        ),
      },
    ),
    OgunSablonu(
      ogunTipi: OgunTipi.ogle,
      kategoriKurallari: {
        BesinKategorisi.protein: OgunKategoriKurali(
          kategori: BesinKategorisi.protein,
          minAdet: 1, maxAdet: 1,
          minOran: 0.30, maxOran: 0.45,
        ),
        BesinKategorisi.karbonhidrat: OgunKategoriKurali(
          kategori: BesinKategorisi.karbonhidrat,
          minAdet: 0, maxAdet: 1,
          minOran: 0.25, maxOran: 0.40,
          yasakMalzemeler: ["Yulaf","Granola"],
        ),
        BesinKategorisi.sebze: OgunKategoriKurali(
          kategori: BesinKategorisi.sebze,
          minAdet: 1, maxAdet: 3,
          minOran: 0.10, maxOran: 0.25,
        ),
        BesinKategorisi.yag: OgunKategoriKurali(
          kategori: BesinKategorisi.yag,
          minAdet: 0, maxAdet: 1,
          minOran: 0.10, maxOran: 0.20,
        ),
      },
    ),
    OgunSablonu(
      ogunTipi: OgunTipi.araOgun2,
      kategoriKurallari: {
        BesinKategorisi.protein: OgunKategoriKurali(
          kategori: BesinKategorisi.protein,
          minAdet: 0, maxAdet: 1,
          minOran: 0.15, maxOran: 0.30,
        ),
        BesinKategorisi.karbonhidrat: OgunKategoriKurali(
          kategori: BesinKategorisi.karbonhidrat,
          minAdet: 0, maxAdet: 1,
          minOran: 0.20, maxOran: 0.35,
          yasakMalzemeler: ["Pirinç","Patates","Makarna"],
        ),
        BesinKategorisi.meyve: OgunKategoriKurali(
          kategori: BesinKategorisi.meyve,
          minAdet: 0, maxAdet: 1,
          minOran: 0.0, maxOran: 0.25,
        ),
        BesinKategorisi.yag: OgunKategoriKurali(
          kategori: BesinKategorisi.yag,
          minAdet: 0, maxAdet: 1,
          minOran: 0.10, maxOran: 0.20,
        ),
      },
    ),
    OgunSablonu(
      ogunTipi: OgunTipi.aksam,
      kategoriKurallari: {
        BesinKategorisi.protein: OgunKategoriKurali(
          kategori: BesinKategorisi.protein,
          minAdet: 1, maxAdet: 1,
          minOran: 0.40, maxOran: 0.50,
        ),
        BesinKategorisi.karbonhidrat: OgunKategoriKurali(
          kategori: BesinKategorisi.karbonhidrat,
          minAdet: 0, maxAdet: 1,
          minOran: 0.0, maxOran: 0.25,
          yasakMalzemeler: ["Yulaf","Granola","Mısır Gevreği"],
        ),
        BesinKategorisi.sebze: OgunKategoriKurali(
          kategori: BesinKategorisi.sebze,
          minAdet: 2, maxAdet: 4,
          minOran: 0.15, maxOran: 0.30,
        ),
        BesinKategorisi.yag: OgunKategoriKurali(
          kategori: BesinKategorisi.yag,
          minAdet: 0, maxAdet: 1,
          minOran: 0.10, maxOran: 0.20,
        ),
      },
    ),
  ];
}

String defaultTemplatesJsonString() {
  final list = defaultTemplatesTRStrict();
  final data = list.map((e) => e.toJson()).toList();
  return const JsonEncoder.withIndent('  ').convert(data);
}
