// ============================================================================
// EGZERSİZ ENTITY - FAZ 9
// ============================================================================

/// Zorluk seviyeleri
enum Zorluk {
  baslangic('Başlangıç', '🟢'),
  orta('Orta', '🟡'),
  ileri('İleri', '🔴'),
  profesyonel('Profesyonel', '⚫');

  final String ad;
  final String emoji;

  const Zorluk(this.ad, this.emoji);
}

/// Egzersiz kategorileri
enum EgzersizKategorisi {
  kardiyovaskuler('Kardiyovasküler', '🏃'),
  guc('Güç', '💪'),
  esneklik('Esneklik', '🧘'),
  denge('Denge', '⚖️'),
  hiit('HIIT', '⚡'),
  yoga('Yoga', '🕉️'),
  pilates('Pilates', '🤸');

  final String ad;
  final String emoji;

  const EgzersizKategorisi(this.ad, this.emoji);
}

/// Hedef kas grupları
enum KasGrubu {
  gogus('Göğüs', '💪'),
  sirt('Sırt', '🦾'),
  bacak('Bacak', '🦵'),
  omuz('Omuz', '💪'),
  kol('Kol', '💪'),
  karin('Karın', '🔥'),
  tumVucut('Tüm Vücut', '🏋️');

  final String ad;
  final String emoji;

  const KasGrubu(this.ad, this.emoji);
}

/// Egzersiz entity'si
class Egzersiz {
  final String id;
  final String ad;
  final String aciklama;
  final int sure; // Saniye cinsinden
  final int kalori; // Tahmini yakılan kalori
  final Zorluk zorluk;
  final EgzersizKategorisi kategori;
  final List<KasGrubu> hedefKaslar;
  final String? videoUrl;
  final String? gorselUrl;
  final List<String> talimatlar;
  final int? tekrarSayisi;
  final int? setSayisi;

  const Egzersiz({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.sure,
    required this.kalori,
    required this.zorluk,
    required this.kategori,
    required this.hedefKaslar,
    this.videoUrl,
    this.gorselUrl,
    required this.talimatlar,
    this.tekrarSayisi,
    this.setSayisi,
  });

  /// Egzersiz bilgileri özeti
  String get bilgiOzeti {
    final sureDk = (sure / 60).ceil();
    final kaslar = hedefKaslar.map((k) => k.ad).join(', ');
    return '$sureDk dk • ${zorluk.ad} • $kalori kcal • $kaslar';
  }

  /// Set/tekrar bilgisi varsa formatla
  String? get setTekrarBilgisi {
    if (setSayisi != null && tekrarSayisi != null) {
      return '$setSayisi set x $tekrarSayisi tekrar';
    } else if (tekrarSayisi != null) {
      return '$tekrarSayisi tekrar';
    } else if (setSayisi != null) {
      return '$setSayisi set';
    }
    return null;
  }

  Egzersiz copyWith({
    String? id,
    String? ad,
    String? aciklama,
    int? sure,
    int? kalori,
    Zorluk? zorluk,
    EgzersizKategorisi? kategori,
    List<KasGrubu>? hedefKaslar,
    String? videoUrl,
    String? gorselUrl,
    List<String>? talimatlar,
    int? tekrarSayisi,
    int? setSayisi,
  }) {
    return Egzersiz(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      aciklama: aciklama ?? this.aciklama,
      sure: sure ?? this.sure,
      kalori: kalori ?? this.kalori,
      zorluk: zorluk ?? this.zorluk,
      kategori: kategori ?? this.kategori,
      hedefKaslar: hedefKaslar ?? this.hedefKaslar,
      videoUrl: videoUrl ?? this.videoUrl,
      gorselUrl: gorselUrl ?? this.gorselUrl,
      talimatlar: talimatlar ?? this.talimatlar,
      tekrarSayisi: tekrarSayisi ?? this.tekrarSayisi,
      setSayisi: setSayisi ?? this.setSayisi,
    );
  }
}
