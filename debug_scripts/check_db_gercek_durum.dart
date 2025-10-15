import 'dart:io';
import 'package:hive/Hive.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/utils/app_logger.dart';

/// Gerçek DB durumunu kontrol et (db_summary.json güncel olmayabilir)
void main() async {
  try {
    // Hive'ı başlat
    final appDir = Directory.current.path;
    Hive.init('$appDir/hive_data');

    // HiveService'i başlat
    await HiveService.init();

    print('🔍 GERÇEK DB DURUMU KONTROLÜ\n');

    // Toplam yemek sayısı
    final toplamSayi = await HiveService.yemekSayisi();
    print('📊 Toplam yemek: $toplamSayi');

    // Kategori bazında sayılar
    final boxName = 'yemekler';
    final box = await Hive.openBox(boxName);

    int kahvalti = 0, ogle = 0, aksam = 0, araOgun1 = 0, araOgun2 = 0;
    int cheatMeal = 0, geceAtistirma = 0;

    for (var key in box.keys) {
      final item = box.get(key);
      if (item != null && item is Map) {
        final ogunStr = item['ogun']?.toString() ?? '';

        if (ogunStr.contains('kahvalti')) kahvalti++;
        else if (ogunStr.contains('ogle')) ogle++;
        else if (ogunStr.contains('aksam')) aksam++;
        else if (ogunStr.contains('araOgun1')) araOgun1++;
        else if (ogunStr.contains('araOgun2')) araOgun2++;
        else if (ogunStr.contains('cheatMeal')) cheatMeal++;
        else if (ogunStr.contains('geceAtistirmasi')) geceAtistirma++;
      }
    }

    print('\n📋 KATEGORI BAZINDA:');
    print('   Kahvaltı: $kahvalti');
    print('   Öğle: $ogle');
    print('   Akşam: $aksam');
    print('   Ara Öğün 1: $araOgun1');
    print('   Ara Öğün 2: $araOgun2');
    print('   Cheat Meal: $cheatMeal');
    print('   Gece Atıştırması: $geceAtistirma');

    print('\n🎯 ANA YEMEK DURUMU:');
    final toplamAnaYemek = ogle + aksam;
    print('   Toplam Ana Yemek (Öğle + Akşam): $toplamAnaYemek');
    print('   Hedef: Minimum 200 ana yemek');

    if (toplamAnaYemek < 200) {
      print('   ❌ EKSİK! ${200 - toplamAnaYemek} daha fazla ana yemek gerekli.');
    } else {
      print('   ✅ YETER! Hedef aşıldı.');
    }

    await box.close();
    await Hive.close();
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print(stackTrace);
  }
}
