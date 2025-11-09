// lib/core/utils/ogun_mapping_util.dart

import '../../domain/entities/yemek.dart';

/// Öğün tipi ve veri anahtarı arasında mapping yapan utility sınıfı
/// 🔥 KRİTİK FIX: camelCase vs underscore uyumsuzluğu çözümü
class OgunMappingUtil {
  
  /// App'in öğün tipini veri setindeki gerçek anahtara çevirir
  /// 🎯 DB'deki gerçek format: ara_ogun_1, ara_ogun_2, aksam, kahvalti, ogle
  static String datasetKeyFor(OgunTipi ogunTipi) {
    switch (ogunTipi) {
      case OgunTipi.kahvalti:
        return 'kahvalti';        // ✅ DB'de bu formatta
      case OgunTipi.ogle:
        return 'ogle';            // ✅ DB'de bu formatta  
      case OgunTipi.aksam:
        return 'aksam';           // ✅ DB'de bu formatta
      case OgunTipi.araOgun1:
        return 'ara_ogun_1';      // 🔑 ALIAS: camelCase → underscore
      case OgunTipi.araOgun2:
        return 'ara_ogun_2';      // 🔑 ALIAS: camelCase → underscore
      case OgunTipi.geceAtistirma:
        return 'ara_ogun_2';      // 🔑 FALLBACK: gece yoksa ara öğün 2'den beslen
      case OgunTipi.cheatMeal:
        return 'cheat_meal';      // Standardize edilmiş format
    }
  }

  /// Fallback stratejisi - ana anahtar bulunamazsa alternatif dene
  /// 🔥 KRİTİK FIX: Türkçe tam kategorileri de dahil et!
  static List<String> fallbackKeysFor(OgunTipi ogunTipi) {
    switch (ogunTipi) {
      case OgunTipi.araOgun1:
        return ['ara_ogun_1', 'Ara Öğün 1', 'araOgun1', 'ara1', 'snack1'];
      case OgunTipi.araOgun2:
        return ['ara_ogun_2', 'Ara Öğün 2', 'araOgun2', 'ara2', 'snack2'];
      case OgunTipi.geceAtistirma:
        return ['gece_atistirma', 'Gece Atıştırması', 'ara_ogun_2', 'night_snack'];
      case OgunTipi.kahvalti:
        return ['kahvalti', 'Kahvaltı', 'kahvaltı', 'breakfast'];
      case OgunTipi.ogle:
        return ['ogle', 'Öğle Yemeği', 'Öğle', 'öğle', 'lunch'];
      case OgunTipi.aksam:
        return ['aksam', 'Akşam Yemeği', 'Akşam', 'akşam', 'dinner'];
      case OgunTipi.cheatMeal:
        return ['cheat_meal', 'Cheat Meal', 'cheatMeal', 'cheat'];
    }
  }

  /// String normalizasyon - farklı kaynaklardan gelen kategori adlarını standartlaştır
  static String normalizeOgunKey(String raw) {
    final s = raw.toLowerCase()
        .replaceAll('ö', 'o')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    bool has(String k) => s.contains(k);
    
    if (has('kahvalti') || has('breakfast')) return 'kahvalti';
    if (has('ogle') || has('lunch')) return 'ogle';
    if (has('aksam') || has('dinner')) return 'aksam';
    if (has('ara ogun 1') || has('snack1') || has('mid morning')) return 'ara_ogun_1';
    if (has('ara ogun 2') || has('snack2') || has('afternoon')) return 'ara_ogun_2';
    if (has('gece atistirma') || has('night')) return 'ara_ogun_2'; // fallback
    if (has('cheat')) return 'cheat_meal';
    
    return 'ara_ogun_2'; // ultimate fallback
  }

  /// Debug için - hangi kategorilerde kaç yemek var göster
  static Future<void> debugPrintCounts() async {
    // Bu metodun implementasyonu HiveService'e bağımlı
    // Ayrı bir debug utility'de implement edilecek
  }
}