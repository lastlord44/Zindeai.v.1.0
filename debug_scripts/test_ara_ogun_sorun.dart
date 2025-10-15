import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('🔍 Ara Öğün 2 & Karbonhidrat Tekrarı Analizi Başlıyor...\n');

  await Hive.initFlutter();
  await HiveService.init();

  final dataSource = YemekHiveDataSource();

  // 1. Ara Öğün 2 Çeşitliliğini Kontrol Et
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📋 ARA ÖĞÜN 2 ÇEŞITLILIK ANALİZİ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  final tumYemekler = await dataSource.tumYemekleriYukle();
  final araOgun2Listesi = tumYemekler[OgunTipi.araOgun2] ?? [];

  print('Toplam Ara Öğün 2 yemek sayısı: ${araOgun2Listesi.length}\n');

  if (araOgun2Listesi.isEmpty) {
    print('❌ SORUN: Ara Öğün 2\'de hiç yemek yok!\n');
  } else {
    print('İlk 10 Ara Öğün 2 yemeği:\n');
    for (int i = 0; i < (araOgun2Listesi.length > 10 ? 10 : araOgun2Listesi.length); i++) {
      final yemek = araOgun2Listesi[i];
      print('${i + 1}. ${yemek.ad}');
      print('   Kalori: ${yemek.kalori.toStringAsFixed(0)} kcal');
      print('   Protein: ${yemek.protein.toStringAsFixed(1)}g');
      print('   ID: ${yemek.id}');
      print('   Malzemeler: ${yemek.malzemeler.take(3).join(", ")}${yemek.malzemeler.length > 3 ? "..." : ""}');
      print('');
    }

    // Eşsiz yemek isimleri
    final esizIsimler = araOgun2Listesi.map((y) => y.ad.toLowerCase().trim()).toSet();
    print('Eşsiz yemek ismi sayısı: ${esizIsimler.length}');
    print('Tekrarlanan yemekler var mı? ${araOgun2Listesi.length != esizIsimler.length ? "EVET" : "Hayır"}\n');
  }

  // 2. Ana Öğünlerde Karbonhidrat Tekrarı Kontrolü
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🍚 KARBONHİDRAT TEKRARI ANALİZİ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Karbonhidrat kelime listesi
  final karbonhidratKelimeleri = [
    'pilav',
    'makarna',
    'bulgur',
    'patates',
    'ekmek',
    'nohut',
    'fasulye',
    'mercimek',
    'pirinç',
    'spagetti',
    'mantı',
    'börek',
    'gözleme',
  ];

  int problemliYemekSayisi = 0;

  // Öğle ve akşam yemeklerini kontrol et
  for (final ogunTipi in [OgunTipi.ogle, OgunTipi.aksam]) {
    final yemekListesi = tumYemekler[ogunTipi] ?? [];
    print('${ogunTipi == OgunTipi.ogle ? "ÖĞLE" : "AKŞAM"} Yemeği Analizi:');
    print('Toplam ${yemekListesi.length} yemek\n');

    for (final yemek in yemekListesi.take(20)) {
      final adLower = yemek.ad.toLowerCase();
      final malzemelerLower = yemek.malzemeler.map((m) => m.toLowerCase()).toList();

      // Bu yemekte kaç farklı karbonhidrat var?
      final bulunanKarbonhidratlar = <String>[];

      for (final karb in karbonhidratKelimeleri) {
        if (adLower.contains(karb) || malzemelerLower.any((m) => m.contains(karb))) {
          bulunanKarbonhidratlar.add(karb);
        }
      }

      if (bulunanKarbonhidratlar.length > 1) {
        problemliYemekSayisi++;
        print('⚠️ SORUNLU: ${yemek.ad}');
        print('   Karbonhidratlar: ${bulunanKarbonhidratlar.join(", ")}');
        print('   Malzemeler: ${yemek.malzemeler.join(", ")}');
        print('');

        if (problemliYemekSayisi >= 5) {
          print('(İlk 5 sorunlu yemek gösterildi, devamı var...)\n');
          break;
        }
      }
    }

    if (problemliYemekSayisi == 0) {
      print('✅ Bu kategoride sorunlu yemek bulunamadı.\n');
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 SONUÇ ÖZETİ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  print('1. Ara Öğün 2 Çeşitlilik: ${araOgun2Listesi.length} yemek var');
  print('2. Karbonhidrat Tekrarı: $problemliYemekSayisi+ sorunlu yemek tespit edildi');
  print('');

  await Hive.close();
}
