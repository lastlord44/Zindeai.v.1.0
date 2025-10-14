// lib/domain/services/alternatif_yemek_servisi.dart

import 'dart:math';
import '../entities/yemek.dart';

class AlternatifYemekServisi {
  /// Verilen bir yemeğe benzer makrolara sahip alternatif yemekler bulur.
  ///
  /// [orijinalYemek]: Değiştirilmek istenen yemek.
  /// [yemekHavuzu]: Alternatiflerin aranacağı aynı öğün tipindeki yemek listesi.
  /// [adet]: Döndürülecek maksimum alternatif sayısı.
  static List<Yemek> alternatifYemekleriBul({
    required Yemek orijinalYemek,
    required List<Yemek> yemekHavuzu,
    int adet = 5,
  }) {
    if (yemekHavuzu.isEmpty) {
      return [];
    }

    // Orijinal yemeği havuzdan çıkar
    final adayYemekler =
        yemekHavuzu.where((y) => y.id != orijinalYemek.id).toList();

    if (adayYemekler.isEmpty) {
      return [];
    }

    // Her aday yemek için bir "benzerlik skoru" hesapla
    final skorluYemekler = <Map<String, dynamic>>[];

    for (final aday in adayYemekler) {
      final skor = _benzerlikSkoruHesapla(orijinalYemek, aday);
      skorluYemekler.add({'yemek': aday, 'skor': skor});
    }

    // Skorlara göre sırala (düşük skor daha iyi)
    skorluYemekler.sort((a, b) => (a['skor'] as double).compareTo(b['skor'] as double));

    // En iyi 'adet' yemeği al ve döndür
    return skorluYemekler
        .take(adet)
        .map((map) => map['yemek'] as Yemek)
        .toList();
  }

  /// İki yemek arasındaki makro benzerlik skorunu hesaplar.
  /// Düşük skor, daha yüksek benzerlik anlamına gelir.
  static double _benzerlikSkoruHesapla(Yemek y1, Yemek y2) {
    // Makro farklarının ağırlıklı toplamı
    // Kalori en önemli, sonra protein, sonra karb ve yağ
    final kaloriFarki = (y1.kalori - y2.kalori).abs();
    final proteinFarki = (y1.protein - y2.protein).abs();
    final karbFarki = (y1.karbonhidrat - y2.karbonhidrat).abs();
    final yagFarki = (y1.yag - y2.yag).abs();

    // Ağırlıklar: Kalori=0.4, Protein=0.3, Karb=0.15, Yağ=0.15
    final skor = (kaloriFarki * 0.4) +
        (proteinFarki * 0.3) +
        (karbFarki * 0.15) +
        (yagFarki * 0.15);

    return skor;
  }
}