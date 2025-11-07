// ============================================================================
// lib/data/migrations/migration_runner.dart
// MİGRATION ÇALIŞTIRICI - TERMİNALDEN VEYA KODDDAN ÇAĞIRILABİLİR
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/app_logger.dart';
import 'add_100_ogle_yemekleri.dart';

/// Migration runner - terminal veya kod içinden çağrılabilir
class MigrationRunner {
  /// Tüm migration'ları çalıştır
  static Future<void> runAll() async {
    try {
      AppLogger.info('🚀 Tüm migration\'lar başlatılıyor...');
      
      // Hive başlatıldı mı kontrol et
      if (!Hive.isBoxOpen('yemekler')) {
        await Hive.initFlutter();
        AppLogger.info('✅ Hive başlatıldı');
      }
      
      // 100 öğle yemeği migration'ı
      await Add100OgleYemekleriMigration.run();
      
      AppLogger.success('🎉 Tüm migration\'lar tamamlandı!');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration runner hatası', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Sadece öğle yemekleri migration'ını çalıştır
  static Future<void> runOgleYemekleri() async {
    try {
      AppLogger.info('🚀 Öğle yemekleri migration başlatılıyor...');
      
      if (!Hive.isBoxOpen('yemekler')) {
        await Hive.initFlutter();
      }
      
      await Add100OgleYemekleriMigration.run();
      
      AppLogger.success('🎉 Öğle yemekleri migration tamamlandı!');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Öğle yemekleri migration hatası', error: e, stackTrace: stackTrace);
    }
  }
}

/// Terminal'den çalıştırmak için main fonksiyonu
Future<void> main() async {
  await MigrationRunner.runAll();
}