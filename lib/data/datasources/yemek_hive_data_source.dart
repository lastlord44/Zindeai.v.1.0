// ============================================================================
// lib/data/datasources/yemek_hive_data_source.dart
// Hive database'den yemek verisi çeken data source
// ============================================================================

import 'package:hive/hive.dart';
import '../../domain/entities/yemek.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/yemek_migration_guncel.dart';
import '../../core/utils/ogun_mapping_util.dart';
import '../local/hive_service.dart';
import '../models/yemek_hive_model.dart';

/// Hive database'den yemek verisi çeken data source
class YemekHiveDataSource {
  // ⚡ PERFORMANS: Migration kontrolünü cache'le (tek seferlik kontrol)
  static bool _migrationKontrolYapildi = false;
  static bool _migrationBasarili = false;

  /// Migration kontrolünü yap (tek seferlik)
  Future<bool> _migrationKontrolEt() async {
    if (_migrationKontrolYapildi) {
      return _migrationBasarili;
    }

    try {
      if (await YemekMigration.migrationGerekliMi()) {
        AppLogger.info(
            '🔄 İlk yükleme: JSON\'dan Hive\'a migration yapılıyor...');
        _migrationBasarili = await YemekMigration.jsonToHiveMigration();
        if (!_migrationBasarili) {
          AppLogger.error('❌ Migration başarısız!');
        }
      } else {
        _migrationBasarili = true; // Zaten migration yapılmış
      }
    } catch (e) {
      AppLogger.error('Migration kontrol hatası', error: e);
      _migrationBasarili = false;
    } finally {
      _migrationKontrolYapildi = true;
    }

    return _migrationBasarili;
  }

  /// Belirli bir öğün tipine ait yemekleri yükle
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    try {
      AppLogger.info('${ogun.ad} için yemekler Hive\'dan yükleniyor...');

      // ⚡ Tek seferlik migration kontrolü
      final migrationOk = await _migrationKontrolEt();
      if (!migrationOk) {
        AppLogger.error('Migration başarısız, boş liste döndürülüyor');
        return [];
      }

      // 🔥 KRİTİK FIX: HiveService.kategoriYemekleriGetir() fallback sistemi kullanmıyor!
      // Direkt box'tan fallback ile arıyoruz
      List<Yemek> yemekler = [];
      
      // Fallback anahtarlarını al (birincil dahil)
      final fallbackKeys = OgunMappingUtil.fallbackKeysFor(ogun);
      AppLogger.debug('${ogun.name} için fallback anahtarları: ${fallbackKeys.join(", ")}');
      
      // 🔥 KRİTİK FIX: Hive box'ını direkt aç (HiveService tarzı)
      final Box<YemekHiveModel> box = Hive.isBoxOpen('yemekler')
          ? Hive.box<YemekHiveModel>('yemekler')
          : await Hive.openBox<YemekHiveModel>('yemekler');
      
      // Tüm fallback anahtarlarını dene
      for (final kategoriKey in fallbackKeys) {
        AppLogger.debug('$kategoriKey kategorisinde aranıyor...');
        
        final bulunanModeller = box.values
            .where((yemek) => yemek.category?.toLowerCase() == kategoriKey.toLowerCase())
            .toList();
            
        if (bulunanModeller.isNotEmpty) {
          yemekler.addAll(bulunanModeller.map((model) => model.toEntity()));
          AppLogger.info('✅ $kategoriKey kategorisinde ${bulunanModeller.length} yemek bulundu');
          break; // İlk bulduğumuz kategoriden devam
        } else {
          AppLogger.debug('❌ $kategoriKey kategorisi boş');
        }
      }

      AppLogger.success(
          '✅ ${ogun.ad} için ${yemekler.length} yemek Hive\'dan yüklendi');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Hive yemek yükleme hatası: ${ogun.ad}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Tüm yemekleri yükle
  Future<Map<OgunTipi, List<Yemek>>> tumYemekleriYukle() async {
    try {
      AppLogger.info('Tüm yemekler Hive\'dan yükleniyor...');

      // ⚡ Tek seferlik migration kontrolü
      final migrationOk = await _migrationKontrolEt();
      if (!migrationOk) {
        AppLogger.error('Migration başarısız, boş map döndürülüyor');
        return {};
      }

      // Tüm yemekleri getir
      final tumYemekler = await HiveService.tumYemekleriGetir();

      // Kategorilere göre grupla
      final yemekMap = <OgunTipi, List<Yemek>>{};
      for (var ogun in OgunTipi.values) {
        yemekMap[ogun] =
            tumYemekler.where((yemek) => yemek.ogun == ogun).toList();
      }

      final toplamYemek =
          yemekMap.values.fold(0, (sum, list) => sum + list.length);
      AppLogger.success('✅ $toplamYemek yemek Hive\'dan yüklendi');
      return yemekMap;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Hive toplu yemek yükleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Yemek ara
  Future<List<Yemek>> yemekAra(String arama) async {
    try {
      AppLogger.info('Hive\'da yemek aranıyor: "$arama"');

      final yemekler = await HiveService.yemekAra(arama);

      AppLogger.success('✅ "$arama" için ${yemekler.length} yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Hive yemek arama hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Belirli ID'ye sahip yemek getir
  Future<Yemek?> yemekGetir(String id) async {
    try {
      AppLogger.debug('Hive\'dan yemek getiriliyor: $id');

      final yemek = await HiveService.yemekGetir(id);

      if (yemek != null) {
        AppLogger.debug('✅ Yemek bulundu: ${yemek.ad}');
      } else {
        AppLogger.debug('ℹ️ Yemek bulunamadı: $id');
      }

      return yemek;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Hive yemek getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Kısıtlamalara göre yemekleri filtrele
  Future<List<Yemek>> yemekleriFiltrele(
    List<Yemek> yemekler,
    List<String> kisitlamalar,
  ) async {
    try {
      if (kisitlamalar.isEmpty) {
        AppLogger.debug('Kısıtlama yok, tüm yemekler döndürülüyor');
        return yemekler;
      }

      AppLogger.debug('Yemekler filtreleniyor: ${kisitlamalar.join(", ")}');

      final filtrelenmis = yemekler.where((yemek) {
        // Etiketlerde kısıtlama var mı kontrol et
        for (var kisitlama in kisitlamalar) {
          if (yemek.etiketler.contains(kisitlama.toLowerCase())) {
            return false; // Kısıtlama varsa yemeği dahil etme
          }
        }
        return true;
      }).toList();

      AppLogger.debug('Filtreleme sonucu: ${filtrelenmis.length} yemek');
      return filtrelenmis;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Yemek filtreleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return yemekler; // Hata durumunda orijinal listeyi döndür
    }
  }

  /// Veritabanı durumunu getir
  Future<Map<String, dynamic>> veritabaniDurumu() async {
    try {
      final istatistikler = await YemekMigration.migrationIstatistikleri();
      return istatistikler;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Veritabanı durumu getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  /// Migration'ı manuel olarak çalıştır
  Future<bool> migrationCalistir() async {
    try {
      AppLogger.info('🔄 Manuel migration başlatılıyor...');
      return await YemekMigration.jsonToHiveMigration();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Manuel migration hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Veritabanını temizle
  Future<void> veritabaniTemizle() async {
    try {
      AppLogger.info('🗑️ Veritabanı temizleniyor...');
      await YemekMigration.migrationTemizle();
      AppLogger.success('✅ Veritabanı temizlendi');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Veritabanı temizleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ========================================================================
  // HELPER METODLAR
  // ========================================================================

  // NOT: _ogunTipiToKategori metodu artık OgunMappingUtil.datasetKeyFor() ile değiştirildi
}
