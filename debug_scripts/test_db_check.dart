import 'package:flutter/material.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/core/utils/db_summary_service.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı başlat
  await HiveService.init();
  
  // DB sağlık kontrolü
  AppLogger.info('🔍 DB Sağlık Kontrolü Başlıyor...');
  final healthCheck = await DBSummaryService.healthCheck();
  
  print('=' * 60);
  print('DB SAĞLIK RAPORU');
  print('=' * 60);
  healthCheck.forEach((key, value) {
    print('$key: $value');
  });
  print('=' * 60);
  
  // Örnek yemekler
  AppLogger.info('📋 Örnek Yemekler Getiriliyor...');
  final ornekYemekler = await DBSummaryService.getSampleMeals();
  
  print('\
' + '=' * 60);
  print('ÖRNEK YEMEKLER (Her kategoriden 1)');
  print('=' * 60);
  for (var yemek in ornekYemekler) {
    print('\
${yemek['kategori']}:');
    print('  - Ad: ${yemek['ad']}');
    print('  - Kalori: ${yemek['kalori']}');
    print('  - Protein: ${yemek['protein']}g');
  }
  print('=' * 60);
  
  // DB özeti
  AppLogger.info('📊 Tam DB Özeti Getiriliyor...');
  final summary = await DBSummaryService.getDatabaseSummary();
  
  print('\
' + '=' * 60);
  print('DETAYLI DB ÖZETİ');
  print('=' * 60);
  summary.forEach((key, value) {
    print('$key: $value');
  });
  print('=' * 60);
}
