// ============================================================================
// FAZ 4: YEMEK ENTITY'LERİ VE JSON PARSER
// ============================================================================

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// ============================================================================
// ENUMS
// ============================================================================

enum OgunTipi {
  kahvalti('Kahvaltı', '🍳'),
  araOgun1('Ara Öğün 1', '🍎'),
  ogle('Öğle Yemeği', '🍽️'),
  araOgun2('Ara Öğün 2', '🥤'),
  aksam('Akşam Yemeği', '🌙'),
  geceAtistirma('Gece Atıştırması', '🌃'),
  cheatMeal('Cheat Meal', '🍔');

  final String aciklama;
  final String emoji;
  const OgunTipi(this.aciklama, this.emoji);
}

enum Zorluk {
  kolay('Kolay', '😊'),
  orta('Orta', '🤔'),
  zor('Zor', '💪');

  final String aciklama;
  final String emoji;
  const Zorluk(this.aciklama, this.emoji);
}

// ============================================================================
// YEMEK ENTITY
// ============================================================================

class Yemek extends Equatable {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final int hazirlamaSuresi; // dakika
  final Zorluk zorluk;
  final List<String> etiketler; // ['vejetaryen', 'glutensiz', 'protein_agirlıklı']
  final String? tarif;
  final String? gorselUrl;

  const Yemek({
    required this.id,
    required this.ad,
    required this.ogun,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.malzemeler,
    this.hazirlamaSuresi = 0,
    this.zorluk = Zorluk.kolay,
    this.etiketler = const [],
    this.tarif,
    this.gorselUrl,
  });

  @override
  List<Object?> get props => [
        id,
        ad,
        ogun,
        kalori,
        protein,
        karbonhidrat,
        yag,
        malzemeler,
        hazirlamaSuresi,
        zorluk,
        etiketler,
        tarif,
        gorselUrl,
      ];

  // ============================================================================
  // MAKRO UYUMU KONTROLÜ
  // ============================================================================

  /// Yemeğin makro hedeflerine uygunluğunu kontrol et
  bool makroyaUygunMu({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    double tolerans = 0.15, // %15 tolerans
  }) {
    // Öğün başına hedef (günlüğün 1/5'i)
    final ogunBasinaKalori = hedefKalori / 5;
    final ogunBasinaProtein = hedefProtein / 5;

    // Kalori kontrolü
    final kaloriFark = (kalori - ogunBasinaKalori).abs();
    final kaloriToleranti = ogunBasinaKalori * tolerans;

    if (kaloriFark > kaloriToleranti) {
      return false;
    }

    // Protein kontrolü (özellikle önemli)
    final proteinFark = (protein - ogunBasinaProtein).abs();
    final proteinToleranti = ogunBasinaProtein * tolerans;

    if (proteinFark > proteinToleranti) {
      return false;
    }

    return true;
  }

  /// Makro skoru hesapla (0-100 arası)
  double makroSkoru({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    final ogunBasinaKalori = hedefKalori / 5;
    final ogunBasinaProtein = hedefProtein / 5;
    final ogunBasinaKarb = hedefKarb / 5;
    final ogunBasinaYag = hedefYag / 5;

    // Sapmaları hesapla
    final kaloriSapma = (kalori - ogunBasinaKalori).abs() / ogunBasinaKalori;
    final proteinSapma = (protein - ogunBasinaProtein).abs() / ogunBasinaProtein;
    final karbSapma = (karbonhidrat - ogunBasinaKarb).abs() / ogunBasinaKarb;
    final yagSapma = (yag - ogunBasinaYag).abs() / ogunBasinaYag;

    // Ağırlıklı ortalama (protein en önemli)
    final toplamSapma = (kaloriSapma * 0.4 +
            proteinSapma * 0.35 +
            karbSapma * 0.15 +
            yagSapma * 0.1)
        .clamp(0.0, 1.0);

    // Skor: 0 sapma = 100 puan
    return (1 - toplamSapma) * 100;
  }

  // ============================================================================
  // KISITLAMA KONTROLÜ
  // ============================================================================

  /// Kısıtlamalara uygunluğu kontrol et (alerji, vegan vb)
  bool kisitlamayaUygunMu(List<String> kisitlamalar) {
    if (kisitlamalar.isEmpty) return true;

    final malzemelerKucuk =
        malzemeler.map((m) => m.toLowerCase()).toSet();
    final kisitlamalarKucuk =
        kisitlamalar.map((k) => k.toLowerCase()).toSet();

    for (final kisitlama in kisitlamalarKucuk) {
      for (final malzeme in malzemelerKucuk) {
        if (malzeme.contains(kisitlama)) {
          return false; // Kısıtlama bulundu
        }
      }
    }

    return true; // Hiçbir kısıtlama yok
  }

  /// Etiket bazlı filtreleme
  bool etiketIceriyorMu(String etiket) {
    return etiketler
        .any((e) => e.toLowerCase() == etiket.toLowerCase());
  }

  // ============================================================================
  // JSON SERIALIZATION
  // ============================================================================

  factory Yemek.fromJson(Map<String, dynamic> json) {
    return Yemek(
      id: json['id'] as String,
      ad: json['ad'] as String,
      ogun: OgunTipi.values.firstWhere(
        (e) => e.name == json['ogun'],
        orElse: () => OgunTipi.kahvalti,
      ),
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      malzemeler: (json['malzemeler'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      hazirlamaSuresi: json['hazirlamaSuresi'] as int? ?? 0,
      zorluk: json['zorluk'] != null
          ? Zorluk.values.firstWhere(
              (e) => e.name == json['zorluk'],
              orElse: () => Zorluk.kolay,
            )
          : Zorluk.kolay,
      etiketler: json['etiketler'] != null
          ? (json['etiketler'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      tarif: json['tarif'] as String?,
      gorselUrl: json['gorselUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'ogun': ogun.name,
      'kalori': kalori,
      'protein': protein,
      'karbonhidrat': karbonhidrat,
      'yag': yag,
      'malzemeler': malzemeler,
      'hazirlamaSuresi': hazirlamaSuresi,
      'zorluk': zorluk.name,
      'etiketler': etiketler,
      'tarif': tarif,
      'gorselUrl': gorselUrl,
    };
  }

  @override
  String toString() {
    return '''
Yemek: $ad
Öğün: ${ogun.aciklama}
Kalori: ${kalori.toStringAsFixed(0)} kcal
Protein: ${protein.toStringAsFixed(1)}g
Karb: ${karbonhidrat.toStringAsFixed(1)}g
Yağ: ${yag.toStringAsFixed(1)}g
Malzemeler: ${malzemeler.join(', ')}
''';
  }
}

// ============================================================================
// YEMEK LOCAL DATA SOURCE
// ============================================================================

class YemekLocalDataSource {
  /// Tek bir öğün tipinin yemeklerini yükle
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/${ogun.name}.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => Yemek.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ ${ogun.name}.json yüklenemedi: $e');
      return [];
    }
  }

  /// Tüm öğünleri paralel yükle
  Future<Map<OgunTipi, List<Yemek>>> tumYemekleriYukle() async {
    final futures = OgunTipi.values.map((ogun) async {
      final yemekler = await yemekleriYukle(ogun);
      return MapEntry(ogun, yemekler);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// Filtrelenmiş yemekler getir
  Future<List<Yemek>> filtrelenmisYemekleriGetir({
    OgunTipi? ogun,
    List<String>? kisitlamalar,
    double? minProtein,
    double? maxKalori,
    List<String>? etiketler,
  }) async {
    List<Yemek> yemekler;

    if (ogun != null) {
      yemekler = await yemekleriYukle(ogun);
    } else {
      final tumYemeklerMap = await tumYemekleriYukle();
      yemekler = tumYemeklerMap.values.expand((e) => e).toList();
    }

    // Filtreleme
    if (kisitlamalar != null && kisitlamalar.isNotEmpty) {
      yemekler = yemekler
          .where((y) => y.kisitlamayaUygunMu(kisitlamalar))
          .toList();
    }

    if (minProtein != null) {
      yemekler = yemekler.where((y) => y.protein >= minProtein).toList();
    }

    if (maxKalori != null) {
      yemekler = yemekler.where((y) => y.kalori <= maxKalori).toList();
    }

    if (etiketler != null && etiketler.isNotEmpty) {
      yemekler = yemekler.where((y) {
        return etiketler.any((etiket) => y.etiketIceriyorMu(etiket));
      }).toList();
    }

    return yemekler;
  }
}

// ============================================================================
// ÖRNEK JSON YAPISI
// ============================================================================

const ORNEK_JSON = '''
[
  {
    "id": "kahvalti_001",
    "ad": "Omlet + Tam Buğday Ekmek",
    "ogun": "kahvalti",
    "kalori": 450,
    "protein": 25,
    "karbonhidrat": 35,
    "yag": 20,
    "malzemeler": ["Yumurta", "Tam Buğday Ekmek", "Domates", "Biber"],
    "hazirlamaSuresi": 15,
    "zorluk": "kolay",
    "etiketler": ["protein_agirlıklı", "kahvaltı_klasik"],
    "tarif": "2 yumurtayı çırp, tavada pişir. Yanında tam buğday ekmeği ile servis et."
  },
  {
    "id": "kahvalti_002",
    "ad": "Yulaf + Muz + Badem",
    "ogun": "kahvalti",
    "kalori": 380,
    "protein": 12,
    "karbonhidrat": 55,
    "yag": 12,
    "malzemeler": ["Yulaf", "Muz", "Badem", "Süt"],
    "hazirlamaSuresi": 5,
    "zorluk": "kolay",
    "etiketler": ["sağlıklı", "hızlı"]
  },
  {
    "id": "ara_ogun_1_001",
    "ad": "10 Badem + 1 Elma",
    "ogun": "araOgun1",
    "kalori": 220,
    "protein": 6,
    "karbonhidrat": 18,
    "yag": 14,
    "malzemeler": ["Badem", "Elma"],
    "hazirlamaSuresi": 0,
    "zorluk": "kolay",
    "etiketler": ["kuruyemiş", "meyve"]
  }
]
''';

// ============================================================================
// TEST KODLARI
// ============================================================================

void main() async {
  print('\n' + '=' * 70);
  print('🧪 FAZ 4 TEST: YEMEK ENTITY\'LERİ VE JSON PARSER');
  print('=' * 70);

  final dataSource = YemekLocalDataSource();

  // Test 1: JSON Parsing
  print('\n📋 TEST 1: JSON PARSING');
  print('-' * 70);

  final ornekYemekler = (json.decode(ORNEK_JSON) as List<dynamic>)
      .map((j) => Yemek.fromJson(j as Map<String, dynamic>))
      .toList();

  for (final yemek in ornekYemekler) {
    print('✅ ${yemek.ad}');
    print('   Öğün: ${yemek.ogun.aciklama} ${yemek.ogun.emoji}');
    print('   Kalori: ${yemek.kalori} kcal');
    print('   Protein: ${yemek.protein}g');
    print('   Zorluk: ${yemek.zorluk.aciklama} ${yemek.zorluk.emoji}');
    print('');
  }

  // Test 2: Makro Uyumu Kontrolü
  print('\n📊 TEST 2: MAKRO UYUMU KONTROLÜ');
  print('-' * 70);

  final hedefler = {
    'kalori': 2500.0,
    'protein': 150.0,
    'karb': 300.0,
    'yag': 80.0,
  };

  final omlet = ornekYemekler[0];
  final uygunMu = omlet.makroyaUygunMu(
    hedefKalori: hedefler['kalori']!,
    hedefProtein: hedefler['protein']!,
    hedefKarb: hedeflers['karb']!,
    hedefYag: hedefler['yag']!,
  );

  final skor = omlet.makroSkoru(
    hedefKalori: hedefler['kalori']!,
    hedefProtein: hedefler['protein']!,
    hedefKarb: hedefler['karb']!,
    hedefYag: hedefler['yag']!,
  );

  print('Yemek: ${omlet.ad}');
  print('Günlük Hedef: ${hedefler['kalori']} kcal, ${hedefler['protein']}g protein');
  print('Öğün Hedefi: ${hedefler['kalori']! / 5} kcal, ${hedefler['protein']! / 5}g protein');
  print('Gerçek: ${omlet.kalori} kcal, ${omlet.protein}g protein');
  print('Uygun mu? ${uygunMu ? "✅ EVET" : "❌ HAYIR"}');
  print('Makro Skoru: ${skor.toStringAsFixed(1)}/100');

  // Test 3: Kısıtlama Kontrolü
  print('\n\n⚠️  TEST 3: KISITLAMA KONTROLÜ');
  print('-' * 70);

  final kisitlamalar = ['Yumurta', 'Süt'];
  print('Kısıtlamalar: ${kisitlamalar.join(', ')}');
  print('');

  for (final yemek in ornekYemekler) {
    final uygun = yemek.kisitlamayaUygunMu(kisitlamalar);
    print('${uygun ? "✅" : "❌"} ${yemek.ad}');
    if (!uygun) {
      final yasak = yemek.malzemeler
          .where((m) => kisitlamalar
              .any((k) => m.toLowerCase().contains(k.toLowerCase())))
          .toList();
      print('   Yasak malzeme: ${yasak.join(', ')}');
    }
    print('');
  }

  // Test 4: Etiket Filtreleme
  print('\n🏷️  TEST 4: ETİKET FİLTRELEME');
  print('-' * 70);

  final proteınAgirlıklı = ornekYemekler
      .where((y) => y.etiketIceriyorMu('protein_agirlıklı'))
      .toList();

  print('Protein Ağırlıklı Yemekler: ${proteınAgirlıklı.length} adet');
  for (final yemek in proteınAgirlıklı) {
    print('  ✅ ${yemek.ad} (${yemek.protein}g protein)');
  }

  print('\n' + '=' * 70);
  print('✅ FAZ 4 TAMAMLANDI!');
  print('=' * 70);
  print('\nSONRAKİ ADIM: FAZ 5 - Akıllı Öğün Eşleştirme Algoritması');
  print('');
}
