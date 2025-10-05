// ============================================================================
// lib/data/models/kullanici_hive_model.dart
// Hive için Kullanıcı Profili Model
// ============================================================================

import 'package:hive/hive.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/hedef.dart';

part 'kullanici_hive_model.g.dart';

@HiveType(typeId: 0)
class KullaniciHiveModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? ad;

  @HiveField(2)
  String? soyad;

  @HiveField(3)
  int? yas;

  @HiveField(4)
  double? boy;

  @HiveField(5)
  double? mevcutKilo;

  @HiveField(6)
  double? hedefKilo;

  @HiveField(7)
  String? cinsiyet;

  @HiveField(8)
  String? aktiviteSeviyesi;

  @HiveField(9)
  String? hedef;

  @HiveField(10)
  String? diyetTipi;

  @HiveField(11)
  List<String>? manuelAlerjiler;

  @HiveField(12)
  DateTime? kayitTarihi;

  KullaniciHiveModel({
    this.id,
    this.ad,
    this.soyad,
    this.yas,
    this.boy,
    this.mevcutKilo,
    this.hedefKilo,
    this.cinsiyet,
    this.aktiviteSeviyesi,
    this.hedef,
    this.diyetTipi,
    this.manuelAlerjiler,
    this.kayitTarihi,
  });

  factory KullaniciHiveModel.fromEntity(KullaniciProfili profil) {
    return KullaniciHiveModel(
      id: profil.id,
      ad: profil.ad,
      soyad: profil.soyad,
      yas: profil.yas,
      boy: profil.boy,
      mevcutKilo: profil.mevcutKilo,
      hedefKilo: profil.hedefKilo,
      cinsiyet: profil.cinsiyet.name,
      aktiviteSeviyesi: profil.aktiviteSeviyesi.name,
      hedef: profil.hedef.name,
      diyetTipi: profil.diyetTipi.name,
      manuelAlerjiler: profil.manuelAlerjiler,
      kayitTarihi: profil.kayitTarihi,
    );
  }

  KullaniciProfili toEntity() {
    return KullaniciProfili(
      id: id ?? '',
      ad: ad ?? '',
      soyad: soyad ?? '',
      yas: yas ?? 25,
      boy: boy ?? 170,
      mevcutKilo: mevcutKilo ?? 70,
      hedefKilo: hedefKilo,
      cinsiyet: Cinsiyet.values.firstWhere(
        (e) => e.name == cinsiyet,
        orElse: () => Cinsiyet.erkek,
      ),
      aktiviteSeviyesi: AktiviteSeviyesi.values.firstWhere(
        (e) => e.name == aktiviteSeviyesi,
        orElse: () => AktiviteSeviyesi.ortaAktif,
      ),
      hedef: Hedef.values.firstWhere(
        (e) => e.name == hedef,
        orElse: () => Hedef.formdaKal,
      ),
      diyetTipi: DiyetTipi.values.firstWhere(
        (e) => e.name == diyetTipi,
        orElse: () => DiyetTipi.normal,
      ),
      manuelAlerjiler: manuelAlerjiler ?? [],
      kayitTarihi: kayitTarihi ?? DateTime.now(),
    );
  }
}
