// ============================================================================
// check_current_db_status.dart
// Mevcut DB durumunu kontrol et ve eksik kategorileri tespit et
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';

void main() async {
  print('🔍 YEMEK VERİTABANI DURUM RAPORU');
  print('═' * 70);
  
  // Hive'ı başlat
  await Hive.initFlutter();
  
  // Adapter'ları kaydet
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  
  // HiveService'i başlat
  await HiveService.init();
  
  // Tüm yemekleri getir
  final tumYemekler = await HiveService.tumYemekleriGetir();
  
  print('\n📊 GENEL İSTATİSTİKLER:');
  print('   Toplam yemek: ${tumYemekler.length}');
  print('');
  
  // Kategori bazında analiz
  print('📂 KATEGORİ BAZINDA DAĞILIM:');
  print('─' * 70);
  
  final kategoriMap = <OgunTipi, List<Yemek>>{};
  for (var ogun in OgunTipi.values) {
    kategoriMap[ogun] = tumYemekler.where((y) => y.ogun == ogun).toList();
  }
  
  int toplam = 0;
  for (var entry in kategoriMap.entries) {
    final sayi = entry.value.length;
    toplam += sayi;
    final icon = _getIcon(entry.key);
    final durum = sayi < 500 ? '⚠️ EKSIK' : '✅ YETERLİ';
    print('   $icon ${entry.key.ad.padRight(20)} : ${sayi.toString().padLeft(4)} yemek $durum');
  }
  
  print('─' * 70);
  print('   TOPLAM:'.padRight(25) + '${toplam.toString().padLeft(4)} yemek');
  print('');
  
  // Makro analizi
  print('🔬 MAKRO BESİN ANALİZİ (Ortalamalar):');
  print('─' * 70);
  
  for (var entry in kategoriMap.entries) {
    if (entry.value.isEmpty) continue;
    
    final yemekler = entry.value;
    final ortKalori = yemekler.fold(0.0, (sum, y) => sum + y.kalori) / yemekler.length;
    final ortProtein = yemekler.fold(0.0, (sum, y) => sum + y.protein) / yemekler.length;
    final ortKarb = yemekler.fold(0.0, (sum, y) => sum + y.karbonhidrat) / yemekler.length;
    final ortYag = yemekler.fold(0.0, (sum, y) => sum + y.yag) / yemekler.length;
    
    print('   ${_getIcon(entry.key)} ${entry.key.ad}:');
    print('      Kalori: ${ortKalori.toStringAsFixed(0)} kcal | P: ${ortProtein.toStringAsFixed(1)}g | K: ${ortKarb.toStringAsFixed(1)}g | Y: ${ortYag.toStringAsFixed(1)}g');
  }
  
  print('');
  print('🎯 ÖNERİLER:');
  print('─' * 70);
  
  int toplamEksik = 0;
  for (var entry in kategoriMap.entries) {
    final sayi = entry.value.length;
    if (sayi < 500) {
      final eklenecek = 500 - sayi;
      toplamEksik += eklenecek;
      print('   • ${entry.key.ad}: $eklenecek yemek daha ekle (hedef: 500)');
    }
  }
  
  if (toplam < 3000) {
    print('   ⚠️ Toplam yemek sayısı 3000\'in altında!');
    print('   📌 Hedef: En az 3500 yemek (her kategori min 500)');
    print('   📊 Toplam eksik: $toplamEksik yemek');
  } else if (toplam >= 3500) {
    print('   ✅ Veritabanı hedef sayıya ulaştı! (3500+)');
  } else {
    final kalan = 3500 - toplam;
    print('   📌 3500 yemek hedefine $kalan yemek kaldı');
  }
  
  print('');
  print('═' * 70);
  print('✅ RAPOR TAMAMLANDI');
  
  await Hive.close();
}

String _getIcon(OgunTipi ogun) {
  switch (ogun) {
    case OgunTipi.kahvalti:
      return '🍳';
    case OgunTipi.araOgun1:
      return '🥗';
    case OgunTipi.ogle:
      return '🍽️';
    case OgunTipi.araOgun2:
      return '🍎';
    case OgunTipi.aksam:
      return '🌙';
    case OgunTipi.geceAtistirma:
      return '🌃';
    case OgunTipi.cheatMeal:
      return '🍕';
  }
}