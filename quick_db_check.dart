import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📊 DB DURUM:');
  print('Toplam yemek: ${box.length}');
  
  if (box.isEmpty) {
    print('❌ DB BOŞ! Migration çalışmamış.');
  } else {
    // Öğün tiplerine göre say
    final Map<String, int> ogunSayilari = {};
    for (final yemek in box.values) {
      final ogun = yemek.category ?? 'Bilinmeyen';
      ogunSayilari[ogun] = (ogunSayilari[ogun] ?? 0) + 1;
    }
    
    print('\n📋 ÖĞÜN TİPİNE GÖRE DAĞILIM:');
    ogunSayilari.forEach((ogun, sayi) {
      print('   $ogun: $sayi yemek');
    });
  }
  
  await Hive.close();
}