// ============================================================================
// lib/core/services/cesitlilik_gecmis_servisi.dart
// CESITLILIK GECMIS SERVISI - Secilen yemeklerin gecmisini saklar
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';
import '../../domain/entities/yemek.dart';

/// Secilen yemeklerin gecmisini Hive'da saklar
/// Boylece uygulama kapanip acilsa bile cesitlilik saglanir
class CesitlilikGecmisServisi {
  static const String _boxName = 'cesitlilik_gecmis';
  static const int _maxGecmis = 10; // Her ogun tipi icin max 10 yemek hatirla

  static Box<List<String>>? _box;

  /// Servisi baslat
  static Future<void> init() async {
    try {
      _box = await Hive.openBox<List<String>>(_boxName);
      AppLogger.info('Cesitlilik gecmis servisi baslatildi');
    } catch (e) {
      AppLogger.error('Cesitlilik gecmis servisi baslatilamadi', error: e);
    }
  }

  /// Bir yemegin secildigini kaydet
  static Future<void> yemekSecildi(OgunTipi ogunTipi, String yemekId) async {
    if (_box == null) {
      AppLogger.warning('Cesitlilik gecmis box acik degil');
      return;
    }

    final key = ogunTipi.toString();
    final gecmis = _box!.get(key, defaultValue: <String>[])!.toList();

    // Eger yemek zaten listede varsa, eski kaydi sil
    gecmis.remove(yemekId);

    // Yeni kaydi en sona ekle
    gecmis.add(yemekId);

    // Maksimum 10 yemek hatirla
    if (gecmis.length > _maxGecmis) {
      gecmis.removeAt(0);
    }

    await _box!.put(key, gecmis);
  }

  /// Bir ogun tipi icin secilen yemeklerin gecmisini getir
  static List<String> gecmisiGetir(OgunTipi ogunTipi) {
    if (_box == null) {
      return [];
    }

    final key = ogunTipi.toString();
    return _box!.get(key, defaultValue: <String>[])!.toList();
  }

  /// Tum gecmisi temizle
  static Future<void> gecmisiTemizle() async {
    if (_box == null) return;
    await _box!.clear();
    AppLogger.info('Cesitlilik gecmisi temizlendi');
  }

  /// Belirli bir ogun tipinin gecmisini temizle
  static Future<void> ogunGecmisiniTemizle(OgunTipi ogunTipi) async {
    if (_box == null) return;
    await _box!.delete(ogunTipi.toString());
  }
}
