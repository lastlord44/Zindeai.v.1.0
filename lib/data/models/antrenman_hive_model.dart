// ============================================================================
// ANTRENMAN HIVE MODEL - FAZ 9
// ============================================================================

import 'package:hive/hive.dart';
import '../../domain/entities/antrenman.dart';

part 'antrenman_hive_model.g.dart';

@HiveType(typeId: 2)
class TamamlananAntrenmanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String antrenmanId;

  @HiveField(2)
  DateTime tamamlanmaTarihi;

  @HiveField(3)
  int tamamlananSure;

  @HiveField(4)
  int yakilanKalori;

  @HiveField(5)
  List<String> tamamlananEgzersizler;

  @HiveField(6)
  double? kullaniciNotlari;

  @HiveField(7)
  String? yorum;

  TamamlananAntrenmanHiveModel({
    required this.id,
    required this.antrenmanId,
    required this.tamamlanmaTarihi,
    required this.tamamlananSure,
    required this.yakilanKalori,
    required this.tamamlananEgzersizler,
    this.kullaniciNotlari,
    this.yorum,
  });

  /// Domain entity'den model oluştur
  factory TamamlananAntrenmanHiveModel.fromDomain(TamamlananAntrenman entity) {
    return TamamlananAntrenmanHiveModel(
      id: entity.id,
      antrenmanId: entity.antrenmanId,
      tamamlanmaTarihi: entity.tamamlanmaTarihi,
      tamamlananSure: entity.tamamlananSure,
      yakilanKalori: entity.yakilanKalori,
      tamamlananEgzersizler: entity.tamamlananEgzersizler,
      kullaniciNotlari: entity.kullaniciNotlari,
      yorum: entity.yorum,
    );
  }

  /// Domain entity'ye dönüştür
  TamamlananAntrenman toDomain() {
    return TamamlananAntrenman(
      id: id,
      antrenmanId: antrenmanId,
      tamamlanmaTarihi: tamamlanmaTarihi,
      tamamlananSure: tamamlananSure,
      yakilanKalori: yakilanKalori,
      tamamlananEgzersizler: tamamlananEgzersizler,
      kullaniciNotlari: kullaniciNotlari,
      yorum: yorum,
    );
  }
}

// Not: AntrenmanProgrami ve Egzersiz için Hive modeli oluşturmuyoruz
// çünkü bunlar JSON'dan yüklenecek ve statik veriler.
// Sadece tamamlanmış antrenmanları local storage'a kaydetmemiz gerekiyor.
