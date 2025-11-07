// // // 🔍 MALZEME PARSE EDİCİ SERVİSİ
// String malzemeleri besin/miktar/birim formatına çevirir
// ============================================================================

import '../../core/utils/app_logger.dart';

class ParsedMalzeme {
  final double miktar;
  final String birim;
  final String besinAdi;
  final String orijinalMetin;

  const ParsedMalzeme({
    required this.miktar,
    required this.birim,
    required this.besinAdi,
    required this.orijinalMetin,
  });
}

class MalzemeParserServisi {
  /// ⭐ ANA METOD: String malzemeyi parse et
  /// 
  /// Örnekler:
  /// - "2 yumurta" → ParsedMalzeme(miktar: 2, birim: "adet", besinAdi: "yumurta")
  /// - "10 adet badem" → ParsedMalzeme(miktar: 10, birim: "adet", besinAdi: "badem")
  /// - "100 gram tavuk göğsü" → ParsedMalzeme(miktar: 100, birim: "gram", besinAdi: "tavuk göğsü")
  /// - "1 dilim peynir" → ParsedMalzeme(miktar: 1, birim: "dilim", besinAdi: "peynir")
  /// - "1/2 su bardağı yoğurt" → ParsedMalzeme(miktar: 0.5, birim: "su bardağı", besinAdi: "yoğurt")
  static ParsedMalzeme? parse(String malzemeMetni) {
    final temizMetin = malzemeMetni.trim();
    
    if (temizMetin.isEmpty) return null;

    // ========================================================================
    // PATTERN 0: Besin Adı + Parantez içi Gram (YENİ! - En yaygın format)
    // Örn: "ızgara hindi göğsü (209 g)", "kinoa (80 g)", "lor peyniri (120 g)"
    // ========================================================================
    final pattern0 = RegExp(
      r'^(.+?)\s*\((\d+(?:[.,]\d+)?)\s*(g|gr|gram|ml)\)$',
      caseSensitive: false,
    );

    final match0 = pattern0.firstMatch(temizMetin);
    if (match0 != null) {
      final besinAdi = match0.group(1)!.trim();
      final miktarStr = match0.group(2)!.replaceAll(',', '.');
      final miktar = double.tryParse(miktarStr);
      final birim = match0.group(3)!.toLowerCase();

      if (miktar != null) {
        final normalizedBirim = _normalizeBirim(birim);
        AppLogger.debug('✅ [Pattern 0] Parse edildi: "$temizMetin" → $besinAdi ($miktar $normalizedBirim)');
        return ParsedMalzeme(
          miktar: miktar,
          birim: normalizedBirim,
          besinAdi: besinAdi,
          orijinalMetin: temizMetin,
        );
      }
    }

    // ========================================================================
    // PATTERN 1: Sayı + Birim + Besin (en yaygın)
    // Örn: "10 adet badem", "100 gram tavuk", "2 dilim peynir"
    // ========================================================================
    final pattern1 = RegExp(
      r'^(\d+(?:[.,]\d+)?)\s*(adet|tane|gram|gr|g|ml|litre|lt|l|su bardağı|bardak|çay bardağı|yemek kaşığı|tatlı kaşığı|kaşık|dilim|porsiyon)?\s+(.+)$',
      caseSensitive: false,
    );

    final match1 = pattern1.firstMatch(temizMetin);
    if (match1 != null) {
      final miktarStr = match1.group(1)!.replaceAll(',', '.');
      final miktar = double.tryParse(miktarStr);
      final birim = match1.group(2)?.toLowerCase() ?? 'adet'; // Default "adet"
      final besinAdi = match1.group(3)!.trim();

      if (miktar != null) {
        final normalizedBirim = _normalizeBirim(birim);
        AppLogger.debug('✅ [Pattern 1] Parse edildi: "$temizMetin" → $besinAdi ($miktar $normalizedBirim)');
        return ParsedMalzeme(
          miktar: miktar,
          birim: normalizedBirim,
          besinAdi: besinAdi,
          orijinalMetin: temizMetin,
        );
      }
    }

    // ========================================================================
    // PATTERN 2: Kesirli ifadeler (1/2, 1/4, 3/4)
    // Örn: "1/2 su bardağı yoğurt", "1/4 kaşık bal"
    // ========================================================================
    final pattern2 = RegExp(
      r'^(\d+)/(\d+)\s*(adet|tane|gram|gr|g|ml|litre|lt|l|su bardağı|bardak|çay bardağı|yemek kaşığı|tatlı kaşığı|kaşık|dilim|porsiyon)?\s+(.+)$',
      caseSensitive: false,
    );

    final match2 = pattern2.firstMatch(temizMetin);
    if (match2 != null) {
      final pay = double.tryParse(match2.group(1)!);
      final payda = double.tryParse(match2.group(2)!);
      final birim = match2.group(3)?.toLowerCase() ?? 'adet';
      final besinAdi = match2.group(4)!.trim();

      if (pay != null && payda != null && payda != 0) {
        final miktar = pay / payda;
        final normalizedBirim = _normalizeBirim(birim);
        AppLogger.debug('✅ [Pattern 2] Parse edildi (kesirli): "$temizMetin" → $besinAdi ($miktar $normalizedBirim)');
        return ParsedMalzeme(
          miktar: miktar,
          birim: normalizedBirim,
          besinAdi: besinAdi,
          orijinalMetin: temizMetin,
        );
      }
    }

    // ========================================================================
    // PATTERN 3: Sadece sayı + besin (birim yok)
    // Örn: "2 yumurta", "3 muz", "5 hurma"
    // ========================================================================
    final pattern3 = RegExp(
      r'^(\d+(?:[.,]\d+)?)\s+(.+)$',
      caseSensitive: false,
    );

    final match3 = pattern3.firstMatch(temizMetin);
    if (match3 != null) {
      final miktarStr = match3.group(1)!.replaceAll(',', '.');
      final miktar = double.tryParse(miktarStr);
      final besinAdi = match3.group(2)!.trim();

      if (miktar != null) {
        AppLogger.debug('✅ [Pattern 3] Parse edildi: "$temizMetin" → $besinAdi ($miktar adet)');
        return ParsedMalzeme(
          miktar: miktar,
          birim: 'adet', // Default "adet"
          besinAdi: besinAdi,
          orijinalMetin: temizMetin,
        );
      }
    }

    // ========================================================================
    // PATTERN 4: Birim + Besin (miktar yok - varsayılan 1)
    // Örn: "1 dilim peynir" → zaten pattern1'de yakalanır
    // Ama "dilim peynir" gibi durum için:
    // ========================================================================
    final pattern4 = RegExp(
      r'^(adet|tane|gram|gr|g|ml|litre|lt|l|su bardağı|bardak|çay bardağı|yemek kaşığı|tatlı kaşığı|kaşık|dilim|porsiyon)\s+(.+)$',
      caseSensitive: false,
    );

    final match4 = pattern4.firstMatch(temizMetin);
    if (match4 != null) {
      final birim = match4.group(1)!.toLowerCase();
      final besinAdi = match4.group(2)!.trim();

      final normalizedBirim = _normalizeBirim(birim);
      AppLogger.debug('✅ [Pattern 4] Parse edildi: "$temizMetin" → $besinAdi (1.0 $normalizedBirim)');
      return ParsedMalzeme(
        miktar: 1.0, // Varsayılan 1
        birim: normalizedBirim,
        besinAdi: besinAdi,
        orijinalMetin: temizMetin,
      );
    }

    // ========================================================================
    // FALLBACK: Parse edilemeyen durumlar
    // Örn: "tuz", "karabiber", "zeytinyağı" (ölçüsüz baharatlar)
    // Bu durumda null döndürüyoruz - alternatif sistemine dahil edilmeyecek
    // ========================================================================
    AppLogger.warning('⚠️ Parse edilemedi: "$temizMetin" (ölçü bilgisi bulunamadı)');
    return null;
  }

  /// ⭐ Birimi normalize et (standart hale getir)
  static String _normalizeBirim(String birim) {
    final normalizedBirim = birim.toLowerCase().trim();

    // Gram varyasyonları
    if (normalizedBirim == 'gr' || normalizedBirim == 'g') {
      return 'gram';
    }

    // Litre varyasyonları
    if (normalizedBirim == 'lt' || normalizedBirim == 'l') {
      return 'litre';
    }

    // ML
    if (normalizedBirim == 'ml') {
      return 'ml';
    }

    // Adet/Tane
    if (normalizedBirim == 'tane') {
      return 'adet';
    }

    // Bardak varyasyonları
    if (normalizedBirim == 'bardak' || normalizedBirim == 'su bardağı') {
      return 'su bardağı';
    }

    if (normalizedBirim == 'çay bardağı') {
      return 'çay bardağı';
    }

    // Kaşık varyasyonları
    if (normalizedBirim == 'kaşık') {
      return 'yemek kaşığı'; // Varsayılan olarak yemek kaşığı
    }

    if (normalizedBirim == 'yemek kaşığı') {
      return 'yemek kaşığı';
    }

    if (normalizedBirim == 'tatlı kaşığı') {
      return 'tatlı kaşığı';
    }

    // Dilim
    if (normalizedBirim == 'dilim') {
      return 'dilim';
    }

    // Porsiyon
    if (normalizedBirim == 'porsiyon') {
      return 'porsiyon';
    }

    // Diğer durumlar - olduğu gibi dön
    return normalizedBirim;
  }

  /// ⭐ Birimi gram/ml'ye çevir (hesaplama için)
  /// Bu metod alternatif hesaplamalarında kullanılabilir
  static double? birimToGramMl(String birim, double miktar) {
    final normalized = _normalizeBirim(birim);

    // Standart birimler (zaten gram/ml)
    if (normalized == 'gram' || normalized == 'ml') {
      return miktar;
    }

    // Litre → ML
    if (normalized == 'litre') {
      return miktar * 1000;
    }

    // Bardak → ML (su bardağı = 200ml, çay bardağı = 100ml)
    if (normalized == 'su bardağı') {
      return miktar * 200;
    }

    if (normalized == 'çay bardağı') {
      return miktar * 100;
    }

    // Kaşık → ML (yemek kaşığı = 15ml, tatlı kaşığı = 5ml)
    if (normalized == 'yemek kaşığı') {
      return miktar * 15;
    }

    if (normalized == 'tatlı kaşığı') {
      return miktar * 5;
    }

    // Adet, dilim, porsiyon gibi birimler gram/ml'ye direkt çevrilemez
    // Besin veritabanındaki standart porsiyon ağırlıklarını kullanmak gerekir
    return null;
  }

  /// ⭐ Test metodu (debug için)
  static void testParser() {
    final testCases = [
      '2 yumurta',
      '10 adet badem',
      '100 gram tavuk göğsü',
      '1 dilim peynir',
      '1/2 su bardağı yoğurt',
      '200 ml süt',
      '1 yemek kaşığı zeytinyağı',
      '3 muz',
      '50 gr ceviz',
      'tuz', // Parse edilemez
      '1.5 porsiyon pirinç',
    ];

    print('🔍 Malzeme Parser Test Sonuçları:');
    print('');

    for (final testCase in testCases) {
      final result = parse(testCase);

      if (result != null) {
        print('✅ "$testCase"');
        print('   → Miktar: ${result.miktar}');
        print('   → Birim: ${result.birim}');
        print('   → Besin: ${result.besinAdi}');
        print('');
      } else {
        print('❌ "$testCase" → Parse edilemedi');
        print('');
      }
    }
  }
}
