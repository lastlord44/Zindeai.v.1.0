import 'package:zinde_ai/data/datasources/yemek_hive_data_source.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/domain/entities/yemek.dart';

/// 🎯 Cline için DB özeti - JSON'lara girmeden bilgi verir
class DBSummaryService {
  /// DB özetini al
  static Future<Map<String, dynamic>> getDatabaseSummary() async {
    try {
      final dataSource = YemekHiveDataSource();
      final tumYemekler = await dataSource.tumYemekleriYukle();
      
      int toplamYemek = 0;
      final kategoriSayilari = <String, int>{};
      
      tumYemekler.forEach((ogunTipi, yemekler) {
        final kategoriAdi = ogunTipi.toString().split('.').last;
        kategoriSayilari[kategoriAdi] = yemekler.length;
        toplamYemek += yemekler.length;
      });
      
      return {
        'last_updated': DateTime.now().toIso8601String(),
        'total_meals': toplamYemek,
        'categories': kategoriSayilari,
        'migration_status': 'completed',
        'database_type': 'Hive Local Storage',
        
        // Cline için talimatlar
        'instructions_for_ai': {
          'note': 'Yemek verilerini görmek için RAW JSON OKUMA!',
          'how_to_query': 'YemekHiveDataSource().tumYemekleriYukle() kullan',
          'how_to_filter': 'tumYemekleriYukle() sonucu kategoriye göre filtrele',
          'sample_query': '''
            final dataSource = YemekHiveDataSource();
            final tumYemekler = await dataSource.tumYemekleriYukle();
            final kahvaltilar = tumYemekler[OgunTipi.kahvalti];
          ''',
        },
      };
    } catch (e) {
      AppLogger.error('DB Summary hatası: $e');
      return {'error': e.toString()};
    }
  }

  /// Örnek yemekler (ilk 5 - debug için)
  static Future<List<Map<String, dynamic>>> getSampleMeals() async {
    try {
      final dataSource = YemekHiveDataSource();
      final tumYemekler = await dataSource.tumYemekleriYukle();
      
      final ornekYemekler = <Map<String, dynamic>>[];
      
      // Her kategoriden 1 örnek al
      tumYemekler.forEach((ogunTipi, yemekler) {
        if (yemekler.isNotEmpty) {
          final yemek = yemekler.first;
          ornekYemekler.add({
            'kategori': ogunTipi.toString().split('.').last,
            'id': yemek.id,
            'ad': yemek.ad,
            'kalori': yemek.kalori,
            'protein': yemek.protein,
            'karbonhidrat': yemek.karbonhidrat,
            'yag': yemek.yag,
          });
        }
      });
      
      return ornekYemekler;
    } catch (e) {
      AppLogger.error('Sample meals hatası: $e');
      return [];
    }
  }

  /// Hive DB sağlıklı mı?
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final dataSource = YemekHiveDataSource();
      final tumYemekler = await dataSource.tumYemekleriYukle();
      
      int toplamYemek = 0;
      final kategoriSayilari = <String, int>{};
      
      tumYemekler.forEach((ogunTipi, yemekler) {
        final kategoriAdi = ogunTipi.toString().split('.').last;
        kategoriSayilari[kategoriAdi] = yemekler.length;
        toplamYemek += yemekler.length;
      });
      
      final bool healthy = toplamYemek > 0;
      
      return {
        'status': healthy ? 'healthy' : 'needs_migration',
        'total_meals': toplamYemek,
        'categories': kategoriSayilari,
        'recommendation': healthy 
          ? 'DB kullanıma hazır ✅' 
          : 'Migration çalıştır: YemekMigration.jsonToHiveMigration()',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.error('Health check hatası: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'recommendation': 'Hive initialization kontrol et',
      };
    }
  }
}
