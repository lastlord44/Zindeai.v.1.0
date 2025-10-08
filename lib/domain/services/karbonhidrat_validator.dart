// ============================================================================
// lib/domain/services/karbonhidrat_validator.dart
// KARBONHIDRAT VALIDATOR - Coklu karbonhidrat kontrolu
// ============================================================================

import '../entities/yemek.dart';
import '../../core/utils/app_logger.dart';

/// Yemeklerdeki karbonhidrat kombinasyonlarini kontrol eden servis
class KarbonhidratValidator {
  // Karbonhidrat kaynak kelimeleri
  static const List<String> _karbonhidratKaynaklari = [
    'pilav',
    'makarna',
    'bulgur',
    'pirinc',
    'spagetti',
    'eriste',
    'sehriye',
    'manti',
    'borek',
    'gozleme',
    'patates',
    'nohut',
    'fasulye',
    'mercimek',
    'barbunya',
    'kuru fasulye',
    'ekmek',
    'lavas',
    'pide',
  ];

  // ISTISNA: Baklagiller birbirleriyle kombine edilebilir (tek karbonhidrat sayilir)
  static const List<String> _baklagiller = [
    'nohut',
    'fasulye',
    'mercimek',
    'barbunya',
    'kuru fasulye',
  ];

  /// Yemekte birden fazla FARKLI karbonhidrat kaynagi var mi kontrol et
  static bool yemekGecerliMi(Yemek yemek) {
    final adLower = yemek.ad.toLowerCase();
    final malzemelerLower = yemek.malzemeler.map((m) => m.toLowerCase()).toList();

    // Yemekte bulunan karbonhidrat kaynaklarini tespit et
    final bulunanKarbonhidratlar = <String>[];

    for (final karb in _karbonhidratKaynaklari) {
      if (adLower.contains(karb) || malzemelerLower.any((m) => m.contains(karb))) {
        bulunanKarbonhidratlar.add(karb);
      }
    }

    // Karbonhidrat yoksa gecerli
    if (bulunanKarbonhidratlar.isEmpty) {
      return true;
    }

    // Tek karbonhidrat varsa gecerli
    if (bulunanKarbonhidratlar.length == 1) {
      return true;
    }

    // Baklagil kontrolu: Tum karbonhidratlar baklagil mi?
    final hepsiBaklagilMi = bulunanKarbonhidratlar.every((karb) {
      return _baklagiller.any((baklagil) => karb.contains(baklagil));
    });

    if (hepsiBaklagilMi) {
      // Tum karbonhidratlar baklagil - GECERLI (tek karbonhidrat grubu)
      return true;
    }

    // Birden fazla FARKLI karbonhidrat grubu var - GECERSIZ! (sessiz)
    return false;
  }

  /// Liste icindeki gecersiz yemekleri filtrele (sessiz)
  static List<Yemek> yemekleriFiltrele(List<Yemek> yemekler) {
    final gecerliYemekler = yemekler.where((y) => yemekGecerliMi(y)).toList();
    return gecerliYemekler; // Sessiz çalış, log spam önlendi
  }

  /// Karbonhidrat kaynaklarini tespit et (debug icin)
  static List<String> findKarbonhidratlar(Yemek yemek) {
    final adLower = yemek.ad.toLowerCase();
    final malzemelerLower = yemek.malzemeler.map((m) => m.toLowerCase()).toList();

    final bulunanlar = <String>[];
    for (final karb in _karbonhidratKaynaklari) {
      if (adLower.contains(karb) || malzemelerLower.any((m) => m.contains(karb))) {
        bulunanlar.add(karb);
      }
    }

    return bulunanlar;
  }
}
