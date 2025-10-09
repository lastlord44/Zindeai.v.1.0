// DEBUG: DB'deki gerçek kategori isimlerini listele
import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  final appDocDir = Directory.current;
  Hive.init(appDocDir.path);
  
  Hive.registerAdapter(YemekHiveModelAdapter());
  final box = await Hive.openBox<YemekHiveModel>('yemekler');

  print('═══════════════════════════════════════════════════');
  print('🔍 DB\'DEKİ GERÇEK KATEGORİ İSİMLERİ');
  print('═══════════════════════════════════════════════════\n');
  
  print('📦 Toplam yemek sayısı: ${box.length}');
  
  if (box.isEmpty) {
    print('❌ DB TAMAMEN BOŞ!');
    print('   Hive dosya yolu: ${appDocDir.path}');
    await box.close();
    await Hive.close();
    exit(1);
  }
  
  // Benzersiz kategorileri topla
  final kategoriler = <String, int>{};
  
  for (final yemek in box.values) {
    final cat = yemek.category ?? 'NULL';
    kategoriler[cat] = (kategoriler[cat] ?? 0) + 1;
  }
  
  print('\n📊 BENZERSIZ KATEGORİLER (${kategoriler.length} adet):\n');
  
  // Kategorileri sırala (yemek sayısına göre)
  final siraliKategoriler = kategoriler.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  for (final entry in siraliKategoriler) {
    print('   "${entry.key}" → ${entry.value} yemek');
  }
  
  print('\n═══════════════════════════════════════════════════');
  print('✅ ANALİZ TAMAMLANDI');
  print('═══════════════════════════════════════════════════');
  
  await box.close();
  await Hive.close();
  exit(0);
}
