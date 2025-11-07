import 'package:hive_flutter/hive_flutter.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';

class DbMaintenance {
  static Future<void> nukeAll() async {
    AppLogger.warning('☢️ NUKE ALL: Tüm Hive kutuları siliniyor...');
    await Hive.close();

    final boxes = [
      'yemekler',
      'kullanici',
      'planlar',
      'antrenman',
      'favori_yemekler',
      'cesitlilik_gecmis',
      'rapor_box'
    ];
    
    for (final name in boxes) {
      try {
        await Hive.deleteBoxFromDisk(name);
        AppLogger.info('   - "$name" silindi.');
      } catch (e) {
        AppLogger.error('   - "$name" silinirken hata: $e');
      }
    }
    AppLogger.success('✅ Nuke işlemi tamamlandı.');
  }
}
