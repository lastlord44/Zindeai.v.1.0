import 'package:equatable/equatable.dart';
import 'hedef.dart';

class KullaniciProfili extends Equatable {
  final String id;
  final String ad;
  final String soyad;
  final int yas;
  final Cinsiyet cinsiyet;
  final double boy; // cm
  final double mevcutKilo; // kg
  final double? hedefKilo; // kg
  final Hedef hedef;
  final AktiviteSeviyesi aktiviteSeviyesi;
  final DiyetTipi diyetTipi;
  
  // ⭐ YENİ: Alerji/Kısıtlama Sistemi
  final List<String> manuelAlerjiler; // Kullanıcının manuel eklediği
  final DateTime kayitTarihi;

  const KullaniciProfili({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.yas,
    required this.cinsiyet,
    required this.boy,
    required this.mevcutKilo,
    this.hedefKilo,
    required this.hedef,
    required this.aktiviteSeviyesi,
    this.diyetTipi = DiyetTipi.normal,
    this.manuelAlerjiler = const [],
    required this.kayitTarihi,
  });

  // ⭐ TÜM KISITLAMALARI BİRLEŞTİR (Diyet + Manuel)
  List<String> get tumKisitlamalar {
    final Set<String> kisitlamalar = {};
    
    // Diyet tipinden gelen kısıtlamalar
    kisitlamalar.addAll(diyetTipi.varsayilanKisitlamalar);
    
    // Manuel eklenen alerjiler
    kisitlamalar.addAll(manuelAlerjiler);
    
    return kisitlamalar.toList();
  }

  // ⭐ BİR YEMEĞİN YENEBİLİR OLUP OLMADIĞINI KONTROL ET
  bool yemekYenebilirMi(List<String> yemekIcerikleri) {
    final kisitlamalarKucuk = tumKisitlamalar.map((k) => k.toLowerCase()).toSet();
    
    for (final icerik in yemekIcerikleri) {
      if (kisitlamalarKucuk.contains(icerik.toLowerCase())) {
        return false; // Kısıtlama var, yenebilir değil
      }
    }
    return true; // Hiçbir kısıtlama yok
  }

  @override
  List<Object?> get props => [
        id,
        ad,
        soyad,
        yas,
        cinsiyet,
        boy,
        mevcutKilo,
        hedefKilo,
        hedef,
        aktiviteSeviyesi,
        diyetTipi,
        manuelAlerjiler,
        kayitTarihi,
      ];

  KullaniciProfili copyWith({
    String? id,
    String? ad,
    String? soyad,
    int? yas,
    Cinsiyet? cinsiyet,
    double? boy,
    double? mevcutKilo,
    double? hedefKilo,
    Hedef? hedef,
    AktiviteSeviyesi? aktiviteSeviyesi,
    DiyetTipi? diyetTipi,
    List<String>? manuelAlerjiler,
    DateTime? kayitTarihi,
  }) {
    return KullaniciProfili(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      soyad: soyad ?? this.soyad,
      yas: yas ?? this.yas,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      boy: boy ?? this.boy,
      mevcutKilo: mevcutKilo ?? this.mevcutKilo,
      hedefKilo: hedefKilo ?? this.hedefKilo,
      hedef: hedef ?? this.hedef,
      aktiviteSeviyesi: aktiviteSeviyesi ?? this.aktiviteSeviyesi,
      diyetTipi: diyetTipi ?? this.diyetTipi,
      manuelAlerjiler: manuelAlerjiler ?? this.manuelAlerjiler,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
    );
  }
}
