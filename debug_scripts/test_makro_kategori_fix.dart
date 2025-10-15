// debug_scripts/test_makro_kategori_fix.dart
// 🔍 MAKRO VE KATEGORİ DÜZELTMELERİNİ TEST ET

import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/data/local/hive_service.dart';
import '../lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  print('🔍 MAKRO VE KATEGORİ DÜZELTMESİ TEST EDİLİYOR...\n');

  try {
    // Hive'ı başlat
    await Hive.initFlutter();
    await HiveService.init();

    print('📊 ADIM 1: MEVCUT DURUM KONTROLÜ');
    print('=' * 70);
    await _mevcutDurumKontrol();

    print('\n🗑️ ADIM 2: DB TEMİZLENİYOR...');
    print('=' * 70);
    await HiveService.tumYemekleriSil();
    print('✅ DB temizlendi\n');

    print('🔄 ADIM 3: YENİ MİGRATION BAŞLATILIYOR...');
    print('=' * 70);
    final basarili = await YemekMigration.jsonToHiveMigration();
    if (!basarili) {
      print('❌ Migration başarısız!');
      exit(1);
    }
    print('✅ Migration tamamlandı\n');

    print('✅ ADIM 4: YENİ DURUM KONTROLÜ');
    print('=' * 70);
    await _yeniDurumKontrol();

    print('\n🎉 TEST TAMAMLANDI!');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Mevcut durum kontrolü
Future<void> _mevcutDurumKontrol() async {
  final sayi = await HiveService.yemekSayisi();
  print('Toplam yemek sayısı: $sayi');

  final kategoriSayilari = await HiveService.kategoriSayilari();
  print('\nKategori dağılımı:');
  kategoriSayilari.forEach((kategori, sayi) {
    print('  $kategori: $sayi yemek');
  });
}

/// Yeni durum kontrolü ve validasyon
Future<void> _yeniDurumKontrol() async {
  // 1. Toplam sayı kontrolü
  final sayi = await HiveService.yemekSayisi();
  print('Toplam yemek sayısı: $sayi');

  // 2. Kategori dağılımı
  final kategoriSayilari = await HiveService.kategoriSayilari();
  print('\nKategori dağılımı:');
  kategoriSayilari.forEach((kategori, sayi) {
    print('  $kategori: $sayi yemek');
  });

  // 3. 0 kalorili yemek kontrolü
  print('\n🔍 0 Kalorili Yemek Kontrolü:');
  final tumYemekler = await HiveService.tumYemekleriGetir();
  final sifirKaloriliYemekler =
      tumYemekler.where((y) => y.kalori == 0).toList();

  if (sifirKaloriliYemekler.isEmpty) {
    print('✅ Hiç 0 kalorili yemek yok!');
  } else {
    print('❌ 0 kalorili yemek sayısı: ${sifirKaloriliYemekler.length}');
    print('   İlk 5 örnek:');
    sifirKaloriliYemekler.take(5).forEach((y) {
      print('     - ${y.ad} (Kategori: ${y.ogun.ad})');
    });
  }

  // 4. "Izgara Uskumru" kontrolü
  print('\n🐟 "Izgara Uskumru" Kontrolü:');
  try {
    final uskumru = tumYemekler.firstWhere(
      (y) => y.ad.toLowerCase().contains('uskumru'),
    );
    print('✅ Bulundu: ${uskumru.ad}');
    print('   Kategori: ${uskumru.ogun.ad}');
    print('   Kalori: ${uskumru.kalori} kcal');
    print('   Protein: ${uskumru.protein}g');

    if (uskumru.ogun.ad.toLowerCase().contains('kahvaltı')) {
      print('   ❌ HATA: Hala Kahvaltı kategorisinde!');
    } else {
      print('   ✅ Kategori doğru!');
    }
  } catch (e) {
    print('⚠️ "Izgara Uskumru" bulunamadı');
  }

  // 5. Kahvaltı kategorisi kontrolü
  print('\n🍳 Kahvaltı Kategorisi Örnekleri:');
  final kahvaltilar = tumYemekler
      .where((y) => y.ogun.ad.toLowerCase().contains('kahvaltı'))
      .toList();
  print('Toplam kahvaltı: ${kahvaltilar.length}');
  print('İlk 5 kahvaltı:');
  kahvaltilar.take(5).forEach((y) {
    print('  - ${y.ad} (${y.kalori} kcal, ${y.protein}g protein)');
  });

  // 6. Ara Öğün 1 kategorisi kontrolü
  print('\n🍎 Ara Öğün 1 Kategorisi Örnekleri:');
  final araOgun1 =
      tumYemekler.where((y) => y.ogun.ad.contains('Ara Öğün 1')).toList();
  print('Toplam ara öğün 1: ${araOgun1.length}');
  print('İlk 5 ara öğün 1:');
  araOgun1.take(5).forEach((y) {
    print('  - ${y.ad} (${y.kalori} kcal, ${y.protein}g protein)');
  });
}
