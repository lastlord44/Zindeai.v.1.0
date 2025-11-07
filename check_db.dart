import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔍 DB KONTROLÜ BAŞLIYOR...');
  
  // Hive başlat
  await Hive.initFlutter();
  
  // Adapter kaydet
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  // Box aç
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📊 Toplam yemek sayısı: ${box.length}');
  
  if (box.isEmpty) {
    print('❌ DB BOŞ! Migration çalışmadı.');
  } else {
    // Kategori sayıları
    final Map<String, int> kategoriler = {};
    
    for (final yemek in box.values) {
      final kategori = yemek.category ?? 'Bilinmeyen';
      kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
    }
    
    print('\n📋 KATEGORİ DAĞILIMI:');
    kategoriler.forEach((kategori, sayi) {
      print('   $kategori: $sayi yemek');
    });
  }
  
  await Hive.close();
}
