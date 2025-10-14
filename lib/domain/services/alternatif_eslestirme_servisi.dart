// ============================================================================
// lib/domain/services/alternatif_eslestirme_servisi.dart
// AKILLI ALTERNATİF YEMEK EŞLEŞTİRME SERVİSİ
// Her yemek için en uygun 2 alternatif yemeği bulur
// ============================================================================

import 'dart:math';
import '../entities/yemek.dart';
import '../../core/utils/app_logger.dart';

class AlternatifEslestirmeServisi {
  static const int _alternatifSayisi = 2;
  static const double _kaloriTolerans = 0.20; // ±20%
  static const double _proteinTolerans = 0.25; // ±25%
  static const double _karbTolerans = 0.25; // ±25%

  /// Her yemek için en uygun 2 alternatif yemek ID'si bul
  /// 
  /// Eşleştirme kriterleri (öncelik sırasına göre):
  /// 1. Aynı kategori (OgunTipi)
  /// 2. Benzer kalori (±20%)
  /// 3. Benzer protein (±25%)
  /// 4. Benzer karbonhidrat (±25%)
  /// 5. Farklı ana malzeme (çeşitlilik için)
  static List<String> alternatifleriBul(
    Yemek anaYemek,
    List<Yemek> tumYemekler,
  ) {
    try {
      // 1. Aynı kategorideki yemekleri filtrele (kendisi hariç)
      final ayniKategorideKi = tumYemekler
          .where((y) => y.ogun == anaYemek.ogun && y.id != anaYemek.id)
          .toList();

      if (ayniKategorideKi.isEmpty) {
        AppLogger.warning(
          '⚠️ ${anaYemek.ad} için alternatif bulunamadı (aynı kategoride başka yemek yok)',
        );
        return [];
      }

      // 2. Her adaya benzerlik skoru hesapla
      final adaylarVeSkorlar = <_AlternatifAday>[];
      
      for (final aday in ayniKategorideKi) {
        final skor = _benzerlikSkoruHesapla(anaYemek, aday);
        adaylarVeSkorlar.add(_AlternatifAday(
          yemek: aday,
          benzerlikSkoru: skor,
        ));
      }

      // 3. Skorlara göre sırala (en yüksek önce)
      adaylarVeSkorlar.sort((a, b) => b.benzerlikSkoru.compareTo(a.benzerlikSkoru));

      // 4. İlk 2'yi al (varsa)
      final alternatifler = adaylarVeSkorlar
          .take(_alternatifSayisi)
          .map((a) => a.yemek.id)
          .toList();

      // 5. Eğer 2'den az bulunduysa, rastgele ekle
      if (alternatifler.length < _alternatifSayisi && ayniKategorideKi.length >= _alternatifSayisi) {
        final eksik = _alternatifSayisi - alternatifler.length;
        final kalan = ayniKategorideKi
            .where((y) => !alternatifler.contains(y.id))
            .toList();
        
        if (kalan.isNotEmpty) {
          final random = Random();
          for (int i = 0; i < eksik && kalan.isNotEmpty; i++) {
            final rastgele = kalan[random.nextInt(kalan.length)];
            alternatifler.add(rastgele.id);
            kalan.remove(rastgele);
          }
        }
      }

      // Log (sadece geliştirme için)
      if (alternatifler.length == _alternatifSayisi) {
        final alt1 = tumYemekler.firstWhere((y) => y.id == alternatifler[0]);
        final alt2 = tumYemekler.firstWhere((y) => y.id == alternatifler[1]);
        
        AppLogger.debug(
          '✅ ${anaYemek.ad} (${anaYemek.kalori.toStringAsFixed(0)} kcal) → '
          'Alt1: ${alt1.ad} (${alt1.kalori.toStringAsFixed(0)} kcal), '
          'Alt2: ${alt2.ad} (${alt2.kalori.toStringAsFixed(0)} kcal)',
        );
      } else {
        AppLogger.warning(
          '⚠️ ${anaYemek.ad} için sadece ${alternatifler.length} alternatif bulundu (hedef: 2)',
        );
      }

      return alternatifler;

    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ Alternatif eşleştirme hatası: ${anaYemek.ad}',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// İki yemek arasındaki benzerlik skorunu hesapla (0-100 arası)
  /// 
  /// Skor hesaplama:
  /// - Kalori benzerliği: 40 puan (en önemli)
  /// - Protein benzerliği: 30 puan
  /// - Karbonhidrat benzerliği: 30 puan
  /// 
  /// Toplam: 100 puan
  static double _benzerlikSkoruHesapla(Yemek ana, Yemek aday) {
    // Kalori benzerliği (40 puan max)
    final kaloriFark = (ana.kalori - aday.kalori).abs();
    final kaloriOran = kaloriFark / ana.kalori;
    final kaloriSkoru = kaloriOran <= _kaloriTolerans
        ? 40.0 - (kaloriOran / _kaloriTolerans * 40.0)
        : max(0.0, 40.0 - (kaloriOran * 100.0)); // Tolerans dışında ceza

    // Protein benzerliği (30 puan max)
    final proteinFark = (ana.protein - aday.protein).abs();
    final proteinOran = ana.protein > 0 ? proteinFark / ana.protein : 0.0;
    final proteinSkoru = proteinOran <= _proteinTolerans
        ? 30.0 - (proteinOran / _proteinTolerans * 30.0)
        : max(0.0, 30.0 - (proteinOran * 80.0));

    // Karbonhidrat benzerliği (30 puan max)
    final karbFark = (ana.karbonhidrat - aday.karbonhidrat).abs();
    final karbOran = ana.karbonhidrat > 0 ? karbFark / ana.karbonhidrat : 0.0;
    final karbSkoru = karbOran <= _karbTolerans
        ? 30.0 - (karbOran / _karbTolerans * 30.0)
        : max(0.0, 30.0 - (karbOran * 80.0));

    // Bonus: Farklı ana malzeme (+10 puan)
    final anaAnaMalzeme = _anaMalzemeyiBul(ana.ad, ana.malzemeler);
    final adayAnaMalzeme = _anaMalzemeyiBul(aday.ad, aday.malzemeler);
    final malzemeBonus = (anaAnaMalzeme != null && adayAnaMalzeme != null && anaAnaMalzeme != adayAnaMalzeme)
        ? 10.0
        : 0.0;

    final toplamSkor = kaloriSkoru + proteinSkoru + karbSkoru + malzemeBonus;
    return toplamSkor.clamp(0.0, 110.0); // Bonus dahil max 110
  }

  /// Ana malzemeyi bul (somon, tavuk, et, balık, vb.)
  static String? _anaMalzemeyiBul(String yemekAdi, List<String> malzemeler) {
    final adLower = yemekAdi.toLowerCase();

    // Ana malzemeler listesi (öncelik sırasına göre - en spesifik önce)
    const anaMalzemeler = [
      'somon',
      'ton balığı',
      'alabalık',
      'levrek',
      'çipura',
      'hamsi',
      'uskumru',
      'sardalye',
      'balık',
      'tavuk göğsü',
      'tavuk but',
      'tavuk',
      'hindi',
      'dana eti',
      'dana',
      'kuzu eti',
      'kuzu',
      'kıyma',
      'köfte',
      'et',
      'yumurta',
      'nohut',
      'mercimek',
      'fasulye',
      'barbunya',
      'tofu',
      'peynir',
      'yoğurt',
      'süt',
    ];

    // Önce yemek adından ara
    for (final malzeme in anaMalzemeler) {
      if (adLower.contains(malzeme)) {
        return malzeme;
      }
    }

    // Sonra malzemeler listesinden ara
    for (final malzeme in anaMalzemeler) {
      for (final yemekMalzemesi in malzemeler) {
        if (yemekMalzemesi.toLowerCase().contains(malzeme)) {
          return malzeme;
        }
      }
    }

    return null;
  }

  /// Alternatif eşleştirme istatistikleri
  static Map<String, dynamic> eslesmeIstatistikleri(
    Map<String, List<String>> alternatiflerMap,
    List<Yemek> tumYemekler,
  ) {
    int toplamYemek = alternatiflerMap.length;
    int tam2Alternatif = 0;
    int tek1Alternatif = 0;
    int hicAlternatifYok = 0;

    for (final entry in alternatiflerMap.entries) {
      final altSayisi = entry.value.length;
      if (altSayisi == 2) {
        tam2Alternatif++;
      } else if (altSayisi == 1) {
        tek1Alternatif++;
      } else {
        hicAlternatifYok++;
      }
    }

    return {
      'toplamYemek': toplamYemek,
      'tam2Alternatif': tam2Alternatif,
      'tek1Alternatif': tek1Alternatif,
      'hicAlternatifYok': hicAlternatifYok,
      'basariOrani': toplamYemek > 0 
          ? ((tam2Alternatif / toplamYemek) * 100).toStringAsFixed(1) + '%'
          : '0%',
    };
  }
}

/// Alternatif aday (yemek + benzerlik skoru)
class _AlternatifAday {
  final Yemek yemek;
  final double benzerlikSkoru;

  _AlternatifAday({
    required this.yemek,
    required this.benzerlikSkoru,
  });
}