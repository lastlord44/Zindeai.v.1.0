import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  await Hive.initFlutter();
  
  // Hive adapter'ları kaydet
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  }

  AppLogger.info('═══════════════════════════════════════════');
  AppLogger.info('🔍 KARBONHIDRAT VE ÖĞÜN SORUNLARI ANALIZI');
  AppLogger.info('═══════════════════════════════════════════');

  // 1. Her kategorideki yemeklerin ortalama karbonhidratını kontrol et
  for (final kategori in OgunTipi.values) {
    final yemekler = await HiveService.kategoriYemekleriGetir(kategori.name);
    
    if (yemekler.isEmpty) {
      AppLogger.warning('⚠️  ${kategori.ad}: BOŞ!');
      continue;
    }

    final ortalamaKarb = yemekler.map((y) => y.karbonhidrat).reduce((a, b) => a + b) / yemekler.length;
    final ortalamaKalori = yemekler.map((y) => y.kalori).reduce((a, b) => a + b) / yemekler.length;
    
    // En yüksek karbonhidratlı yemeği bul
    final enYuksekKarb = yemekler.reduce((a, b) => a.karbonhidrat > b.karbonhidrat ? a : b);
    
    AppLogger.info('');
    AppLogger.info('📊 ${kategori.ad}:');
    AppLogger.info('   Yemek Sayısı: ${yemekler.length}');
    AppLogger.info('   Ortalama Kalori: ${ortalamaKalori.toStringAsFixed(0)} kcal');
    AppLogger.info('   Ortalama Karbonhidrat: ${ortalamaKarb.toStringAsFixed(1)}g');
    AppLogger.info('   En Yüksek Karb: ${enYuksekKarb.ad} (${enYuksekKarb.karbonhidrat.toStringAsFixed(1)}g)');

    // İlk 3 yemeği göster (kategori kontrolü için)
    AppLogger.info('   İlk 3 Yemek:');
    for (int i = 0; i < 3 && i < yemekler.length; i++) {
      final y = yemekler[i];
      AppLogger.info('     ${i + 1}. ${y.ad} (${y.ogun.ad}) - ${y.kalori.toStringAsFixed(0)} kcal, ${y.karbonhidrat.toStringAsFixed(1)}g karb');
    }
  }

  AppLogger.info('');
  AppLogger.info('═══════════════════════════════════════════');
  AppLogger.info('🎯 ÖRNEK HEDEF HESAPLAMA (3093 kcal hedef)');
  AppLogger.info('═══════════════════════════════════════════');
  
  const hedefKalori = 3093.0;
  const hedefKarb = 415.0;
  
  // Öğün dağılımı
  final kahvaltiHedefKarb = hedefKarb * 0.20;  // %20
  final araOgun1HedefKarb = hedefKarb * 0.15;  // %15
  final ogleHedefKarb = hedefKarb * 0.35;      // %35
  final araOgun2HedefKarb = hedefKarb * 0.10;  // %10
  final aksamHedefKarb = hedefKarb * 0.20;     // %20
  
  AppLogger.info('Kahvaltı hedef: ${kahvaltiHedefKarb.toStringAsFixed(1)}g karb');
  AppLogger.info('Ara Öğün 1 hedef: ${araOgun1HedefKarb.toStringAsFixed(1)}g karb');
  AppLogger.info('Öğle hedef: ${ogleHedefKarb.toStringAsFixed(1)}g karb');
  AppLogger.info('Ara Öğün 2 hedef: ${araOgun2HedefKarb.toStringAsFixed(1)}g karb');
  AppLogger.info('Akşam hedef: ${aksamHedefKarb.toStringAsFixed(1)}g karb');
  AppLogger.info('TOPLAM: ${(kahvaltiHedefKarb + araOgun1HedefKarb + ogleHedefKarb + araOgun2HedefKarb + aksamHedefKarb).toStringAsFixed(1)}g karb');
  
  AppLogger.info('');
  AppLogger.info('═══════════════════════════════════════════');
  AppLogger.info('🔍 KATEGORI UYGUNLUK KONTROLÜ');
  AppLogger.info('═══════════════════════════════════════════');
  
  // Her kategorideki yemeklerin gerçekten o kategoride olup olmadığını kontrol et
  for (final kategori in OgunTipi.values) {
    final yemekler = await HiveService.kategoriYemekleriGetir(kategori.name);
    
    if (yemekler.isEmpty) continue;
    
    // Yanlış kategorideki yemekleri bul
    final yanlisKategoriler = yemekler.where((y) => y.ogun != kategori).toList();
    
    if (yanlisKategoriler.isNotEmpty) {
      AppLogger.error('❌ ${kategori.ad} kategorisinde ${yanlisKategoriler.length} yanlış kategorili yemek bulundu!');
      for (final y in yanlisKategoriler.take(5)) {
        AppLogger.error('   - ${y.ad} (gerçek kategori: ${y.ogun.ad})');
      }
    } else {
      AppLogger.success('✅ ${kategori.ad}: Tüm yemekler doğru kategoride');
    }
  }

  await Hive.close();
}