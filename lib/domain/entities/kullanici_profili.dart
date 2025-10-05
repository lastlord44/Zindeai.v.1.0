// ============================================================================
// lib/domain/entities/kullanici_profili.dart
// Kullanıcı Profili Entity
// ============================================================================

import 'package:equatable/equatable.dart';
import 'hedef.dart'; // Enum'ları buradan import et

class KullaniciProfili extends Equatable {
  final String id;
  final String ad;
  final String soyad;
  final int yas;
  final double boy; // cm
  final double mevcutKilo; // kg
  final double? hedefKilo; // kg
  final Cinsiyet cinsiyet;
  final AktiviteSeviyesi aktiviteSeviyesi;
  final Hedef hedef;
  final DiyetTipi diyetTipi;
  final List<String> manuelAlerjiler;
  final DateTime kayitTarihi;

  const KullaniciProfili({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.yas,
    required this.boy,
    required this.mevcutKilo,
    this.hedefKilo,
    required this.cinsiyet,
    required this.aktiviteSeviyesi,
    required this.hedef,
    required this.diyetTipi,
    this.manuelAlerjiler = const [],
    required this.kayitTarihi,
  });

  @override
  List<Object?> get props => [
        id,
        ad,
        soyad,
        yas,
        boy,
        mevcutKilo,
        hedefKilo,
        cinsiyet,
        aktiviteSeviyesi,
        hedef,
        diyetTipi,
        manuelAlerjiler,
        kayitTarihi,
      ];

  // Tüm kısıtlamaları birleştir (Diyet tipi + Manuel alerjiler)
  List<String> get tumKisitlamalar {
    final Set<String> kisitlamalar = {};
    
    // Diyet tipinden gelen varsayılan kısıtlamalar
    kisitlamalar.addAll(diyetTipi.varsayilanKisitlamalar);
    
    // Manuel eklenen alerjiler
    kisitlamalar.addAll(manuelAlerjiler);
    
    return kisitlamalar.toList();
  }

  // Bir yemeğin yenebilir olup olmadığını kontrol et
  bool yemekYenebilirMi(List<String> yemekIcerikleri) {
    final kisitlamalarKucuk = tumKisitlamalar.map((k) => k.toLowerCase()).toSet();
    
    for (final icerik in yemekIcerikleri) {
      if (kisitlamalarKucuk.contains(icerik.toLowerCase())) {
        return false; // Kısıtlama var, yenebilir değil
      }
    }
    return true; // Hiçbir kısıtlama yok
  }

  KullaniciProfili copyWith({
    String? id,
    String? ad,
    String? soyad,
    int? yas,
    double? boy,
    double? mevcutKilo,
    double? hedefKilo,
    Cinsiyet? cinsiyet,
    AktiviteSeviyesi? aktiviteSeviyesi,
    Hedef? hedef,
    DiyetTipi? diyetTipi,
    List<String>? manuelAlerjiler,
    DateTime? kayitTarihi,
  }) {
    return KullaniciProfili(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      soyad: soyad ?? this.soyad,
      yas: yas ?? this.yas,
      boy: boy ?? this.boy,
      mevcutKilo: mevcutKilo ?? this.mevcutKilo,
      hedefKilo: hedefKilo ?? this.hedefKilo,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      aktiviteSeviyesi: aktiviteSeviyesi ?? this.aktiviteSeviyesi,
      hedef: hedef ?? this.hedef,
      diyetTipi: diyetTipi ?? this.diyetTipi,
      manuelAlerjiler: manuelAlerjiler ?? this.manuelAlerjiler,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
    );
  }
}
