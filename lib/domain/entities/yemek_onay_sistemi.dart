// ============================================================================
// lib/domain/entities/yemek_onay_sistemi.dart
// YEMEK ONAY SİSTEMİ VERİ MODELLERİ
// ============================================================================

enum YemekDurumu {
  bekliyor('Bekliyor'),           // Henüz yemedi, plan durumunda
  yedi('Yedi'),                   // Yedi ama henüz onaylamadı
  onaylandi('Onaylandı'),         // Yedi ve onayladı (değiştirilmez)
  ataldi('Atladı');               // Bu öğünü yemedi/atladı

  const YemekDurumu(this.aciklama);
  final String aciklama;
}

class YemekOnayVerisi {
  final String yemekId;
  final DateTime tarih;
  final YemekDurumu durum;
  final DateTime? yemeTarihi;        // Yediği tarih
  final DateTime? onayTarihi;       // Onayladığı tarih
  final String? notlar;              // Kullanıcı notları
  final bool degistirilebilir;       // Artık değiştirilip değiştirilemez
  
  const YemekOnayVerisi({
    required this.yemekId,
    required this.tarih,
    required this.durum,
    this.yemeTarihi,
    this.onayTarihi,
    this.notlar,
    required this.degistirilebilir,
  });
  
  /// Yemeği yedi olarak işaretle
  YemekOnayVerisi yediOlarakIsaretle({String? notlar}) {
    return YemekOnayVerisi(
      yemekId: yemekId,
      tarih: tarih,
      durum: YemekDurumu.yedi,
      yemeTarihi: DateTime.now(),
      onayTarihi: onayTarihi,
      notlar: notlar ?? this.notlar,
      degistirilebilir: true, // Yedi ama henüz onaylamadı, değiştirilebilir
    );
  }
  
  /// Yemeği onayla (artık değiştirilemesin)
  YemekOnayVerisi onayla({String? notlar}) {
    return YemekOnayVerisi(
      yemekId: yemekId,
      tarih: tarih,
      durum: YemekDurumu.onaylandi,
      yemeTarihi: yemeTarihi ?? DateTime.now(),
      onayTarihi: DateTime.now(),
      notlar: notlar ?? this.notlar,
      degistirilebilir: false, // ✅ ARTIK DEĞİŞTİRİLEMEZ!
    );
  }
  
  /// Yemeği atla
  YemekOnayVerisi atla({String? notlar}) {
    return YemekOnayVerisi(
      yemekId: yemekId,
      tarih: tarih,
      durum: YemekDurumu.ataldi,
      yemeTarihi: null,
      onayTarihi: DateTime.now(),
      notlar: notlar ?? this.notlar,
      degistirilebilir: false, // Atlayınca da değiştirilemez
    );
  }
  
  /// Durumu sıfırla (bekliyor durumuna getir)
  YemekOnayVerisi sifirla() {
    return YemekOnayVerisi(
      yemekId: yemekId,
      tarih: tarih,
      durum: YemekDurumu.bekliyor,
      yemeTarihi: null,
      onayTarihi: null,
      notlar: null,
      degistirilebilir: true,
    );
  }
  
  /// Onaylanmış mı?
  bool get onaylanmisMi => durum == YemekDurumu.onaylandi;
  
  /// Yenmiş mi?
  bool get yenmis => durum == YemekDurumu.yedi || durum == YemekDurumu.onaylandi;
  
  /// Atlanmış mı?
  bool get atlanmis => durum == YemekDurumu.ataldi;
  
  /// Durum renk kodu
  String get durumRengiKodu {
    switch (durum) {
      case YemekDurumu.bekliyor:
        return '#9E9E9E'; // Gri
      case YemekDurumu.yedi:
        return '#FF9800'; // Turuncu - henüz onaylanmadı
      case YemekDurumu.onaylandi:
        return '#4CAF50'; // Yeşil - onaylandı
      case YemekDurumu.ataldi:
        return '#F44336'; // Kırmızı - atlandı
    }
  }
  
  /// Durum ikonu
  String get durumIkonu {
    switch (durum) {
      case YemekDurumu.bekliyor:
        return '⏳';
      case YemekDurumu.yedi:
        return '🍽️';
      case YemekDurumu.onaylandi:
        return '✅';
      case YemekDurumu.ataldi:
        return '❌';
    }
  }
  
  /// Geçen süre metni
  String get gecenSureMetni {
    if (yemeTarihi == null) return '';
    
    final gecenSure = DateTime.now().difference(yemeTarihi!);
    if (gecenSure.inMinutes < 60) {
      return '${gecenSure.inMinutes} dk önce';
    } else if (gecenSure.inHours < 24) {
      return '${gecenSure.inHours} saat önce';
    } else {
      return '${gecenSure.inDays} gün önce';
    }
  }
  
  @override
  String toString() {
    return 'YemekOnayVerisi(${durum.aciklama}, değiştirilebilir: $degistirilebilir)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YemekOnayVerisi &&
          runtimeType == other.runtimeType &&
          yemekId == other.yemekId &&
          tarih == other.tarih;

  @override
  int get hashCode => yemekId.hashCode ^ tarih.hashCode;
}

class GunlukOnayDurumu {
  final DateTime tarih;
  final Map<String, YemekOnayVerisi> yemekDurumlari;
  final DateTime sonGuncelleme;
  
  const GunlukOnayDurumu({
    required this.tarih,
    required this.yemekDurumlari,
    required this.sonGuncelleme,
  });
  
  /// Günlük uyum yüzdesi
  double get uyumYuzdesi {
    if (yemekDurumlari.isEmpty) return 0.0;
    
    final yenilenSayisi = yemekDurumlari.values
        .where((durum) => durum.yenmis)
        .length;
    
    return (yenilenSayisi / yemekDurumlari.length) * 100;
  }
  
  /// Onaylanan yemek sayısı
  int get onaylananSayisi => yemekDurumlari.values
      .where((durum) => durum.onaylanmisMi)
      .length;
  
  /// Toplam yemek sayısı
  int get toplamYemekSayisi => yemekDurumlari.length;
  
  /// Atlanan yemek sayısı
  int get atlananSayisi => yemekDurumlari.values
      .where((durum) => durum.atlanmis)
      .length;
  
  /// Bekleyen yemek sayısı
  int get bekleyenSayisi => yemekDurumlari.values
      .where((durum) => durum.durum == YemekDurumu.bekliyor)
      .length;
  
  /// Günün durumu
  String get gunDurumu {
    if (onaylananSayisi == toplamYemekSayisi) {
      return 'Mükemmel! Tüm öğünler onaylandı 🎉';
    } else if (uyumYuzdesi >= 80) {
      return 'Harika gidiyor! 💪';
    } else if (uyumYuzdesi >= 60) {
      return 'İyi bir gün 👍';
    } else if (uyumYuzdesi >= 40) {
      return 'Orta seviye 😐';
    } else {
      return 'Daha fazla çaba gerekli 💭';
    }
  }
  
  /// Belirli bir yemeğin durumu
  YemekOnayVerisi? yemekDurumu(String yemekId) => yemekDurumlari[yemekId];
  
  /// Yemek durumunu güncelle
  GunlukOnayDurumu yemekDurumunuGuncelle(String yemekId, YemekOnayVerisi yeniDurum) {
    final yeniMap = Map<String, YemekOnayVerisi>.from(yemekDurumlari);
    yeniMap[yemekId] = yeniDurum;
    
    return GunlukOnayDurumu(
      tarih: tarih,
      yemekDurumlari: yeniMap,
      sonGuncelleme: DateTime.now(),
    );
  }
  
  @override
  String toString() {
    return 'GunlukOnayDurumu(${tarih.day}/${tarih.month}, ${uyumYuzdesi.toStringAsFixed(0)}% uyum)';
  }
}