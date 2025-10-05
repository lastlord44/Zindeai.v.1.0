// domain/entities/yemek.dart

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
