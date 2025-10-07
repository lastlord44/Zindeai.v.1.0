// ============================================================================
// ANTRENMAN ENTITY - FAZ 9
// ============================================================================

import 'egzersiz.dart';

/// Antrenman programı entity'si
class AntrenmanProgrami {
  final String id;
  final String ad;
  final String aciklama;
  final List<Egzersiz> egzersizler;
  final Zorluk zorluk;
  final int toplamSure; // Saniye cinsinden
  final int toplamKalori;
  final List<KasGrubu> hedefKasGruplari;
  final String? gorselUrl;

  const AntrenmanProgrami({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.egzersizler,
    required this.zorluk,
    required this.toplamSure,
    required this.toplamKalori,
    required this.hedefKasGruplari,
    this.gorselUrl,
  });

  /// Toplam süreyi dakika olarak döndür
  int get toplamSureDakika => (toplamSure / 60).ceil();

  /// Egzersiz sayısı
  int get egzersizSayisi => egzersizler.length;

  /// Özet bilgi
  String get ozet {
    return '$egzersizSayisi egzersiz • $toplamSureDakika dk • $toplamKalori kcal';
  }

  /// Kas grubu özetleri emoji ile
  String get kasGruplariOzet {
    return hedefKasGruplari.map((k) => k.emoji).join(' ');
  }

  AntrenmanProgrami copyWith({
    String? id,
    String? ad,
    String? aciklama,
    List<Egzersiz>? egzersizler,
    Zorluk? zorluk,
    int? toplamSure,
    int? toplamKalori,
    List<KasGrubu>? hedefKasGruplari,
    String? gorselUrl,
  }) {
    return AntrenmanProgrami(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      aciklama: aciklama ?? this.aciklama,
      egzersizler: egzersizler ?? this.egzersizler,
      zorluk: zorluk ?? this.zorluk,
      toplamSure: toplamSure ?? this.toplamSure,
      toplamKalori: toplamKalori ?? this.toplamKalori,
      hedefKasGruplari: hedefKasGruplari ?? this.hedefKasGruplari,
      gorselUrl: gorselUrl ?? this.gorselUrl,
    );
  }

  /// Factory method: Egzersizlerden otomatik hesaplama ile program oluştur
  factory AntrenmanProgrami.fromEgzersizler({
    required String id,
    required String ad,
    required String aciklama,
    required List<Egzersiz> egzersizler,
    String? gorselUrl,
  }) {
    // Toplam süre hesapla
    final toplamSure = egzersizler.fold<int>(
      0,
      (sum, egz) => sum + egz.sure,
    );

    // Toplam kalori hesapla
    final toplamKalori = egzersizler.fold<int>(
      0,
      (sum, egz) => sum + egz.kalori,
    );

    // En yüksek zorluk seviyesini al
    final zorluk = egzersizler.isEmpty
        ? Zorluk.baslangic
        : egzersizler
            .map((e) => e.zorluk)
            .reduce((a, b) => a.index > b.index ? a : b);

    // Tüm hedef kas gruplarını topla (unique)
    final hedefKasGruplari = <KasGrubu>{};
    for (final egz in egzersizler) {
      hedefKasGruplari.addAll(egz.hedefKaslar);
    }

    return AntrenmanProgrami(
      id: id,
      ad: ad,
      aciklama: aciklama,
      egzersizler: egzersizler,
      zorluk: zorluk,
      toplamSure: toplamSure,
      toplamKalori: toplamKalori,
      hedefKasGruplari: hedefKasGruplari.toList(),
      gorselUrl: gorselUrl,
    );
  }
}

/// Tamamlanmış antrenman kaydı
class TamamlananAntrenman {
  final String id;
  final String antrenmanId;
  final DateTime tamamlanmaTarihi;
  final int tamamlananSure; // Gerçek süre (saniye)
  final int yakilanKalori; // Gerçek yakılan kalori
  final List<String> tamamlananEgzersizler; // Egzersiz ID'leri
  final double? kullaniciNotlari; // 1-5 arası rating
  final String? yorum;

  const TamamlananAntrenman({
    required this.id,
    required this.antrenmanId,
    required this.tamamlanmaTarihi,
    required this.tamamlananSure,
    required this.yakilanKalori,
    required this.tamamlananEgzersizler,
    this.kullaniciNotlari,
    this.yorum,
  });

  /// Tamamlanma yüzdesi
  double tamamlanmaYuzdesi(int toplamEgzersizSayisi) {
    if (toplamEgzersizSayisi == 0) return 0;
    return (tamamlananEgzersizler.length / toplamEgzersizSayisi) * 100;
  }

  TamamlananAntrenman copyWith({
    String? id,
    String? antrenmanId,
    DateTime? tamamlanmaTarihi,
    int? tamamlananSure,
    int? yakilanKalori,
    List<String>? tamamlananEgzersizler,
    double? kullaniciNotlari,
    String? yorum,
  }) {
    return TamamlananAntrenman(
      id: id ?? this.id,
      antrenmanId: antrenmanId ?? this.antrenmanId,
      tamamlanmaTarihi: tamamlanmaTarihi ?? this.tamamlanmaTarihi,
      tamamlananSure: tamamlananSure ?? this.tamamlananSure,
      yakilanKalori: yakilanKalori ?? this.yakilanKalori,
      tamamlananEgzersizler:
          tamamlananEgzersizler ?? this.tamamlananEgzersizler,
      kullaniciNotlari: kullaniciNotlari ?? this.kullaniciNotlari,
      yorum: yorum ?? this.yorum,
    );
  }
}
