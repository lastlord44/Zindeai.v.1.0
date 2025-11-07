import 'package:hive_flutter/hive_flutter.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/data/local/hive_service.dart';

Future<void> main() async {
  AppLogger.init(level: LogLevel.debug);
  await HiveService.init(isTest: true);

  final boxNames = [
    'yemekler', 
    'kullanici', 
    'planlar', 
    'antrenman', 
    'favori_yemekler', 
    'cesitlilik_gecmis',
    'rapor_box'
  ];

  AppLogger.info('🧹 Veritabanı temizleme işlemi başlıyor...');
  for (var boxName in boxNames) {
    try {
      if (await Hive.boxExists(boxName)) {
        await Hive.deleteBoxFromDisk(boxName);
        AppLogger.success('✅ "$boxName" kutusu başarıyla silindi.');
      } else {
        AppLogger.info('ℹ️ "$boxName" kutusu zaten mevcut değil.');
      }
    } catch (e) {
      AppLogger.error('❌ "$boxName" kutusu silinirken hata oluştu: $e');
    }
  }
  
  AppLogger.success('✨ Veritabanı temizliği tamamlandı!');
  await Hive.close();
}
