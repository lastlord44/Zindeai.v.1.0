// temizle_ve_yukle_sadece_son_klasoru.dart
// DB'yi temizle ve SADECE assets/data/son klasöründeki dosyalardan yükle

import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔥 ===== DB TEMİZLİĞİ VE YENİ YÜKLEME =====');
  print('📂 Kaynak: SADECE assets/data/son klasörü\n');

  // Hive başlat
  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());

  // Eski yemekleri sil
  print('🗑️  Eski yemekler siliniyor...');
  try {
    if (Hive.isBoxOpen('yemekler')) {
      final box = Hive.box<YemekHiveModel>('yemekler');
      await box.clear();
      await box.close();
    }
    await Hive.deleteBoxFromDisk('yemekler');
    print('✅ Eski veriler tamamen silindi\n');
  } catch (e) {
    print('⚠️  Silme hatası (devam ediliyor): $e\n');
  }

  // Yeni box aç
  final box = await Hive.openBox<YemekHiveModel>('yemekler');

  // assets/data/son klasöründeki tüm JSON dosyalarını bul
  final sonDir = Directory('assets/data/son');
  if (!await sonDir.exists()) {
    print('❌ HATA: assets/data/son klasörü bulunamadı!');
    exit(1);
  }

  final jsonFiles = await sonDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.json'))
      .cast<File>()
      .toList();

  print('📁 Bulunan JSON dosyası sayısı: ${jsonFiles.length}\n');

  int toplamYuklenen = 0;
  int toplamHata = 0;

  // Her dosyayı yükle
  for (final file in jsonFiles) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    print('📄 Yükleniyor: $fileName');

    try {
      final content = await file.readAsString();
      final List<dynamic> data = json.decode(content);

      int dosyaYuklenen = 0;
      int dosyaHata = 0;

      for (var item in data) {
        try {
          final yemek = YemekHiveModel.fromJson(item);
          
          // ID oluştur
          if (yemek.mealId == null || yemek.mealId!.isEmpty) {
            yemek.mealId = YemekHiveModel.generateMealId();
          }

          await box.put(yemek.mealId!, yemek);
          dosyaYuklenen++;
        } catch (e) {
          dosyaHata++;
          if (dosyaHata <= 3) {
            print('   ⚠️  Yemek hatası: $e');
          }
        }
      }

      print('   ✅ Yüklendi: $dosyaYuklenen yemek');
      if (dosyaHata > 0) {
        print('   ⚠️  Hata: $dosyaHata yemek');
      }

      toplamYuklenen += dosyaYuklenen;
      toplamHata += dosyaHata;
    } catch (e) {
      print('   ❌ Dosya hatası: $e');
      toplamHata++;
    }
    print('');
  }

  // Özet
  print('\n════════════════════════════════════════════');
  print('📊 ÖZET:');
  print('   ✅ Toplam yüklenen: $toplamYuklenen yemek');
  print('   ❌ Toplam hata: $toplamHata');
  print('   📁 İşlenen dosya: ${jsonFiles.length}');
  print('════════════════════════════════════════════\n');

  // Kategori dağılımı
  print('📊 Kategori Dağılımı:');
  final kategoriler = <String, int>{};
  for (var yemek in box.values) {
    final kategori = yemek.category ?? 'Bilinmeyen';
    kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
  }

  kategoriler.forEach((kategori, sayi) {
    print('   $kategori: $sayi yemek');
  });

  print('\n🎉 İŞLEM TAMAMLANDI!');
  await box.close();
  await Hive.close();
  exit(0);
}
