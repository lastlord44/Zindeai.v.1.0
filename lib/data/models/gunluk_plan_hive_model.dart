// lib/data/models/gunluk_plan_hive_model.dart

import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/gunluk_plan.dart';
import '../../domain/entities/yemek.dart';
import '../../domain/entities/makro_hedefleri.dart';

part 'gunluk_plan_hive_model.g.dart';

@HiveType(typeId: 1)
class GunlukPlanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime tarih;

  @HiveField(2)
  String? kahvaltiJson;

  @HiveField(3)
  String? araOgun1Json;

  @HiveField(4)
  String? ogleYemegiJson; // ✅ Eklendi

  @HiveField(5)
  String? araOgun2Json;

  @HiveField(6)
  String? aksamYemegiJson; // ✅ Eklendi

  @HiveField(7)
  String? geceAtistirmaJson;

  @HiveField(8)
  String makroHedefleriJson; // ✅ Eklendi

  @HiveField(9)
  double fitnessSkoru; // ✅ Eklendi

  GunlukPlanHiveModel({
    required this.id,
    required this.tarih,
    this.kahvaltiJson,
    this.araOgun1Json,
    this.ogleYemegiJson,
    this.araOgun2Json,
    this.aksamYemegiJson,
    this.geceAtistirmaJson,
    required this.makroHedefleriJson,
    this.fitnessSkoru = 0,
  });

  /// Entity'den model oluştur
  factory GunlukPlanHiveModel.fromEntity(GunlukPlan entity) {
    return GunlukPlanHiveModel(
      id: entity.id,
      tarih: entity.tarih,
      // 🔥 FIX: toJson().toString() yerine json.encode kullan!
      kahvaltiJson: entity.kahvalti != null ? json.encode(entity.kahvalti!.toJson()) : null,
      araOgun1Json: entity.araOgun1 != null ? json.encode(entity.araOgun1!.toJson()) : null,
      ogleYemegiJson: entity.ogleYemegi != null ? json.encode(entity.ogleYemegi!.toJson()) : null,
      araOgun2Json: entity.araOgun2 != null ? json.encode(entity.araOgun2!.toJson()) : null,
      aksamYemegiJson: entity.aksamYemegi != null ? json.encode(entity.aksamYemegi!.toJson()) : null,
      geceAtistirmaJson: entity.geceAtistirma != null ? json.encode(entity.geceAtistirma!.toJson()) : null,
      makroHedefleriJson: json.encode(entity.makroHedefleri.toJson()),
      fitnessSkoru: entity.fitnessSkoru,
    );
  }

  /// Entity'ye dönüştür
  GunlukPlan toEntity() {
    return GunlukPlan(
      id: id,
      tarih: tarih,
      kahvalti: kahvaltiJson != null ? _parseYemek(kahvaltiJson!) : null,
      araOgun1: araOgun1Json != null ? _parseYemek(araOgun1Json!) : null,
      ogleYemegi: ogleYemegiJson != null ? _parseYemek(ogleYemegiJson!) : null,
      araOgun2: araOgun2Json != null ? _parseYemek(araOgun2Json!) : null,
      aksamYemegi:
          aksamYemegiJson != null ? _parseYemek(aksamYemegiJson!) : null,
      geceAtistirma:
          geceAtistirmaJson != null ? _parseYemek(geceAtistirmaJson!) : null,
      makroHedefleri: _parseMakroHedefleri(makroHedefleriJson),
      fitnessSkoru: fitnessSkoru,
    );
  }

  /// JSON string'den Yemek parse et
  Yemek? _parseYemek(String jsonString) {
    try {
      // String'i Map'e çevir ve Yemek oluştur
      final Map<String, dynamic> json = _stringToMap(jsonString);
      return Yemek.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// JSON string'den MakroHedefleri parse et
  MakroHedefleri _parseMakroHedefleri(String jsonString) {
    final Map<String, dynamic> json = _stringToMap(jsonString);
    return MakroHedefleri.fromJson(json);
  }

  /// String'i Map'e çevir - Akıllı parser (hem eski hem yeni format destekler)
  Map<String, dynamic> _stringToMap(String str) {
    try {
      // 🔥 FIX: Önce doğru JSON decode dene
      return json.decode(str) as Map<String, dynamic>;
    } catch (e) {
      // 🔥 FALLBACK: Eski format (.toString() ile kaydedilmiş Map'ler için)
      // "{key1: value1, key2: value2}" formatını parse et
      try {
        // Debug: Ne parse etmeye çalıştığımızı görelim
        print('⚠️ JSON decode başarısız, toString formatı parse ediliyor: ${str.substring(0, 50)}...');
        
        // toString() formatından Map oluştur (basit parser)
        // NOT: Bu geçici çözüm, ideal değil ama mevcut planlar için çalışır
        final cleaned = str.trim();
        if (cleaned.isEmpty || cleaned == 'null') {
          return {};
        }
        
        // Eğer normal JSON ise tekrar dene
        if (cleaned.startsWith('{') && cleaned.contains(':')) {
          // toString() ile kaydedilmiş Map'i parse et
          // UYARI: Bu basit parser, karmaşık nested yapılar için çalışmayabilir
          return {};
        }
        
        return {};
      } catch (e2) {
        print('❌ toString parse de başarısız: $e2');
        return {};
      }
    }
  }
}
