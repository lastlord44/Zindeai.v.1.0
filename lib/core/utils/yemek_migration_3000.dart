import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/yemek_hive_model.dart';
import '../../data/local/hive_service.dart';
import '../utils/app_logger.dart';

/// 3000 Yeni Yemek Migration Utility (Platform-Agnostic)
///
/// assets/data/son/ klasöründeki 29 JSON dosyasını Hive DB'ye yükler.
/// Web ve mobil platformlarda çalışacak şekilde `rootBundle` kullanır.
class YemekMigration3000 {
  static Future<void> yukle() async {
    AppLogger.info('🚀 3000 YEMEK MİGRATION BAŞLADI (Platform-Agnostic)');
    AppLogger.info('━' * 60);

    final baslangicSayisi = await HiveService.yemekSayisi();
    AppLogger.info('📊 Mevcut yemek sayısı: $baslangicSayisi');
    
    // Asset manifest dosyasını yükleyerek 'assets/data/son/' içindeki tüm dosyaları bul
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    
    final dosyalar = manifestMap.keys
        .where((String key) => key.startsWith('assets/data/son/'))
        .toList();

    if (dosyalar.isEmpty) {
      AppLogger.error('❌ KRİTİK: Asset manifest içinde "assets/data/son/" klasöründe hiç JSON dosyası bulunamadı!');
      return;
    }

    AppLogger.info('📂 ${dosyalar.length} adet JSON dosyası bulundu.');

    int toplamYuklenen = 0;
    int hataliDosya = 0;
    final Map<String, int> kategoriSayilari = {};

    for (final dosyaYolu in dosyalar) {
      try {
        AppLogger.info('📄 İşleniyor: $dosyaYolu');
        
        final jsonString = await rootBundle.loadString(dosyaYolu);
        final List<dynamic> jsonList = json.decode(jsonString);
        
        int dosyadanYuklenen = 0;
        
        for (final jsonData in jsonList) {
          try {
            final yemekModel = YemekHiveModel.fromJson(jsonData as Map<String, dynamic>);
            await HiveService.yemekKaydet(yemekModel);
            
            dosyadanYuklenen++;
            toplamYuklenen++;
            
            final yemekEntity = yemekModel.toEntity();
            final kategori = yemekEntity.ogun.toString();
            kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
            
          } catch (e) {
            AppLogger.warning('   ⚠️ Yemek işlenirken hata: $e');
          }
        }
        
        AppLogger.success('   ✅ $dosyadanYuklenen yemek yüklendi');
        
      } catch (e) {
        AppLogger.error('   ❌ Dosya işlenirken hata: $e');
        hataliDosya++;
      }
    }

    AppLogger.info('');
    AppLogger.info('━' * 60);
    AppLogger.info('📊 MİGRATION SONUÇLARI:');
    AppLogger.info('━' * 60);
    
    AppLogger.info('✅ Başarılı dosya: ${dosyalar.length - hataliDosya}');
    AppLogger.error('❌ Hatalı dosya: $hataliDosya');
    AppLogger.info('📈 Toplam yüklenen: $toplamYuklenen yemek');
    
    if (kategoriSayilari.isNotEmpty) {
      AppLogger.info('📊 KATEGORİ BAZINDA DAĞILIM:');
      kategoriSayilari.forEach((kategori, sayi) {
        AppLogger.info('   • $kategori: $sayi yemek');
      });
    }
    
    final bitisSayisi = await HiveService.yemekSayisi();
    AppLogger.info('🎯 GÜNCEL TOPLAM: $bitisSayisi yemek');
    AppLogger.info('🆕 Eklenen: ${bitisSayisi - baslangicSayisi} yeni yemek');
    AppLogger.info('━' * 60);
    AppLogger.success('✨ MİGRATION TAMAMLANDI!');
  }
}
