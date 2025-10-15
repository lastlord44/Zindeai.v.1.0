import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/core/utils/yemek_migration_500_yeni.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 500 YENİ YEMEK MİGRATION TESTİ BAŞLIYOR...\n');
  
  // Hive'ı başlat
  await Hive.initFlutter();
  
  // Adapter kaydet
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  
  // Yemek box'ını aç
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📊 ŞU ANKİ DURUM:');
  print('   Toplam yemek sayısı: ${box.length}');
  print('');
  
  // Örnek yeni yemek ID'lerini kontrol et
  final ornekIDler = ['K951', 'O1001', 'A1001', 'AO1_1001', 'AO2_1001'];
  print('🔍 YENİ YEMEK ID KONTROLLERİ:');
  for (final id in ornekIDler) {
    final mevcut = box.containsKey(id);
    print('   $id: ${mevcut ? "✅ VAR" : "❌ YOK"}');
  }
  print('');
  
  // Migration gerekli mi?
  print('🤔 MİGRATION GEREKLİ Mİ KONTROLÜ:');
  final gerekli = await Yemek500Migration.migrationGerekliMi();
  print('   Sonuç: ${gerekli ? "✅ EVET, migration gerekli" : "❌ HAYIR, zaten yüklü"}');
  print('');
  
  if (gerekli) {
    print('🚀 500 YENİ YEMEK MİGRATION BAŞLATIYO...R');
    final baslangic = box.length;
    
    final success = await Yemek500Migration.migrate500NewMeals();
    
    final bitis = box.length;
    
    print('');
    print('═══════════════════════════════════════════');
    print(success ? '✅ MİGRATION BAŞARILI!' : '❌ MİGRATION BAŞARISIZ!');
    print('📈 Başlangıç yemek sayısı: $baslangic');
    print('📈 Bitiş yemek sayısı: $bitis');
    print('➕ Eklenen: ${bitis - baslangic} yemek');
    print('═══════════════════════════════════════════');
  } else {
    print('ℹ️  Migration atlandı - 500 yeni yemek zaten veritabanında.');
  }
  
  print('\n✅ Test tamamlandı!');
}
