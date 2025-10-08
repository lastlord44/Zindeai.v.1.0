// lib/domain/entities/yemek.dart

import 'package:equatable/equatable.dart';
import 'alternatif_besin.dart';
import 'makro_hedefleri.dart';

/// Öğün tipleri
enum OgunTipi {
  kahvalti('Kahvaltı', '🍳'),
  araOgun1('Ara Öğün 1', '🍎'),
  ogle('Öğle', '🍽️'),
  araOgun2('Ara Öğün 2', '🥤'),
  aksam('Akşam', '🌙'),
  geceAtistirma('Gece Atıştırma', '🌃'),
  cheatMeal('Cheat Meal', '🍕');

  final String ad;
  final String emoji;

  const OgunTipi(this.ad, this.emoji);
}

/// Yemek hazırlama zorluk seviyesi
enum Zorluk {
  kolay('Kolay', '⭐'),
  orta('Orta', '⭐⭐'),
  zor('Zor', '⭐⭐⭐');

  final String ad;
  final String emoji;

  const Zorluk(this.ad, this.emoji);
}

/// Yemek entity'si
class Yemek extends Equatable {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final List<AlternatifBesin> alternatifler;
  final int hazirlamaSuresi; // dakika
  final Zorluk zorluk;
  final List<String> etiketler; // ['vejetaryen', 'glutensiz', 'vegan']
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
    this.alternatifler = const [],
    required this.hazirlamaSuresi,
    required this.zorluk,
    this.etiketler = const [],
    this.tarif,
    this.gorselUrl,
  });

  /// JSON'dan oluştur (null-safe)
  factory Yemek.fromJson(Map<String, dynamic> json) {
    return Yemek(
      id: json['id']?.toString() ?? '',
      ad: json['ad']?.toString() ?? 'İsimsiz Yemek',
      ogun: ogunTipiFromString(json['ogun']?.toString() ?? 'kahvalti'),
      kalori: _parseDouble(json['kalori']) ?? 0.0,
      protein: _parseDouble(json['protein']) ?? 0.0,
      karbonhidrat: _parseDouble(json['karbonhidrat']) ?? 0.0,
      yag: _parseDouble(json['yag']) ?? 0.0,
      malzemeler: _parseStringList(json['malzemeler']) ?? [],
      alternatifler: _parseAlternatifler(json['alternatifler']) ?? [],
      hazirlamaSuresi: _parseInt(json['hazirlamaSuresi']) ?? 0,
      zorluk: zorlukFromString(json['zorluk']?.toString() ?? 'kolay'),
      etiketler: _parseStringList(json['etiketler']) ?? [],
      tarif: json['tarif']?.toString(),
      gorselUrl: json['gorselUrl']?.toString(),
    );
  }

  /// Double değer parse helper metodu
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Int değer parse helper metodu
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// String listesi parse helper metodu
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value.where((e) => e != null).map((e) => e.toString()).toList();
    } catch (e) {
      return null;
    }
  }

  /// Alternatif besinler parse helper metodu
  static List<AlternatifBesin>? _parseAlternatifler(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => AlternatifBesin.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// JSON'a çevir
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
      'alternatifler': alternatifler.map((a) => a.toJson()).toList(),
      'hazirlamaSuresi': hazirlamaSuresi,
      'zorluk': zorluk.name,
      'etiketler': etiketler,
      'tarif': tarif,
      'gorselUrl': gorselUrl,
    };
  }

  /// String'den OgunTipi enum'a çevir (public for YemekModel)
  static OgunTipi ogunTipiFromString(String ogun) {
    switch (ogun.toLowerCase()) {
      case 'kahvalti':
      case 'kahvaltı':
        return OgunTipi.kahvalti;
      case 'araogun1':
      case 'ara_ogun_1':
      case 'ara öğün 1':
        return OgunTipi.araOgun1;
      case 'ogle':
      case 'öğle':
      case 'öğle yemeği': // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.ogle;
      case 'araogun2':
      case 'ara_ogun_2':
      case 'ara öğün 2':
        return OgunTipi.araOgun2;
      case 'aksam':
      case 'akşam':
      case 'akşam yemeği': // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.aksam;
      case 'geceatistirma':
      case 'gece_atistirma':
      case 'gece atıştırma':
      case 'gece atıştırması': // ✅ FIX: Hive'daki tam kategori adı
        return OgunTipi.geceAtistirma;
      case 'cheatmeal':
      case 'cheat_meal':
      case 'cheat meal':
        return OgunTipi.cheatMeal;
      default:
        throw Exception('Bilinmeyen öğün tipi: $ogun');
    }
  }

  /// String'den Zorluk enum'a çevir (public for YemekModel)
  static Zorluk zorlukFromString(String zorluk) {
    switch (zorluk.toLowerCase()) {
      case 'kolay':
        return Zorluk.kolay;
      case 'orta':
        return Zorluk.orta;
      case 'zor':
        return Zorluk.zor;
      default:
        throw Exception('Bilinmeyen zorluk seviyesi: $zorluk');
    }
  }

  /// Makrolara uygunluk kontrolü
  bool makroyaUygunMu(MakroHedefleri hedefler, double tolerans) {
    // Günlük hedefin 1/5'i (5 öğün varsayımı)
    final hedefKalori = hedefler.gunlukKalori / 5;
    final kaloriFark = (kalori - hedefKalori).abs();

    return kaloriFark <= hedefKalori * tolerans;
  }

  /// Kısıtlamalara uygunluk kontrolü (alerji, vegan vb)
  bool kisitlamayaUygunMu(List<String> kisitlamalar) {
    if (kisitlamalar.isEmpty) return true;

    for (final kisitlama in kisitlamalar) {
      final kisitlamaLower = kisitlama.toLowerCase();

      // Malzemelerde arama
      if (malzemeler.any((m) => m.toLowerCase().contains(kisitlamaLower))) {
        return false;
      }

      // Etiketlerde arama (örn: vegan değil ise)
      if (kisitlamaLower == 'et' && !etiketler.contains('vejetaryen')) {
        return false;
      }
    }

    return true;
  }

  /// Tercih uygunluğu kontrolü (pozitif filtre)
  bool tercihUygunMu(List<String> tercihler) {
    if (tercihler.isEmpty) return true;

    for (final tercih in tercihler) {
      final tercihLower = tercih.toLowerCase();

      // Malzemelerde veya etiketlerde var mı?
      if (malzemeler.any((m) => m.toLowerCase().contains(tercihLower)) ||
          etiketler.any((e) => e.toLowerCase().contains(tercihLower))) {
        return true;
      }
    }

    return false;
  }

  /// Toplam makro (protein + karb + yağ)
  double get toplamMakro => protein + karbonhidrat + yag;

  /// Protein yüzdesi
  double get proteinYuzdesi => (protein * 4 / kalori) * 100;

  /// Karbonhidrat yüzdesi
  double get karbonhidratYuzdesi => (karbonhidrat * 4 / kalori) * 100;

  /// Yağ yüzdesi
  double get yagYuzdesi => (yag * 9 / kalori) * 100;

  /// Yemek açıklaması (kısa özet)
  String get kisaOzet {
    return '$ad - ${kalori.toInt()} kcal | P: ${protein.toInt()}g | K: ${karbonhidrat.toInt()}g | Y: ${yag.toInt()}g';
  }

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
        alternatifler,
        hazirlamaSuresi,
        zorluk,
        etiketler,
        tarif,
        gorselUrl,
      ];

  /// Copy with
  Yemek copyWith({
    String? id,
    String? ad,
    OgunTipi? ogun,
    double? kalori,
    double? protein,
    double? karbonhidrat,
    double? yag,
    List<String>? malzemeler,
    List<AlternatifBesin>? alternatifler,
    int? hazirlamaSuresi,
    Zorluk? zorluk,
    List<String>? etiketler,
    String? tarif,
    String? gorselUrl,
  }) {
    return Yemek(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      ogun: ogun ?? this.ogun,
      kalori: kalori ?? this.kalori,
      protein: protein ?? this.protein,
      karbonhidrat: karbonhidrat ?? this.karbonhidrat,
      yag: yag ?? this.yag,
      malzemeler: malzemeler ?? this.malzemeler,
      alternatifler: alternatifler ?? this.alternatifler,
      hazirlamaSuresi: hazirlamaSuresi ?? this.hazirlamaSuresi,
      zorluk: zorluk ?? this.zorluk,
      etiketler: etiketler ?? this.etiketler,
      tarif: tarif ?? this.tarif,
      gorselUrl: gorselUrl ?? this.gorselUrl,
    );
  }
}
