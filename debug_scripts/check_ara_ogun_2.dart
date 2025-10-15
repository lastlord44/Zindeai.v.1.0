import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  await Hive.initFlutter();
  await HiveService.init();

  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  final araOgun2 = tumYemekler[OgunTipi.araOgun2] ?? [];

  print('=== ARA OGUN 2 ANALIZI ===');
  print('Toplam: ${araOgun2.length} yemek\n');

  // İlk 10 yemeği göster
  for (int i = 0; i < (araOgun2.length > 10 ? 10 : araOgun2.length); i++) {
    final y = araOgun2[i];
    print('${i + 1}. ${y.ad}');
    print('   Malzemeler (${y.malzemeler.length} adet):');
    for (final malzeme in y.malzemeler) {
      print('     - $malzeme');
    }
    print('');
  }

  await Hive.close();
}
