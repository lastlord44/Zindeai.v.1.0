// DEBUG: Migration metodunu detaylı test et
import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  print('═══════════════════════════════════════════════════');
  print('🔍 MİGRATİON DETAYLI DEBUG');
  print('═══════════════════════════════════════════════════\n');

  // Hive init
  final appDocDir = Directory.current;
  Hive.init(appDocDir.path);
  
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  // Box aç
  print('📦 Box açılıyor...');
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  print('✅ Box açıldı\n');
  
  print('🗑️ Önce temizlik...');
  await box.clear();
  print('✅ Box temizlendi (${box.length} yemek)\n');
  
  print('📥 Migration başlatılıyor...');
  print('   (Detaylı loglara dikkat et)\n');
  
  try {
    final success = await YemekMigration.jsonToHiveMigration();
    
    print('\n═══════════════════════════════════════════════════');
    if (success) {
      print('✅ MİGRATİON BAŞARILI!');
      print('   Toplam yemek: ${box.length}');
    } else {
      print('❌ MİGRATİON BAŞARISIZ!');
      print('   Toplam yemek: ${box.length}');
      print('   Nedeni bilinmiyor - metoddan false döndü');
    }
    print('═══════════════════════════════════════════════════');
  } catch (e, stackTrace) {
    print('\n═══════════════════════════════════════════════════');
    print('💥 MİGRATİON EXCEPTION!');
    print('═══════════════════════════════════════════════════');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
  }
  
  await box.close();
  await Hive.close();
  exit(0);
}
