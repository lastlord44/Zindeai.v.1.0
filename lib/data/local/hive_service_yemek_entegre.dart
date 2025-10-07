// ============================================================================
// lib/data/local/hive_service_yemek_entegre.dart
// HiveService'e yemek desteği entegrasyonu
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../models/kullanici_hive_model.dart';
import '../models/gunluk_plan_hive_model.dart';
import '../models/antrenman_hive_model.dart';
import '../models/yemek_hive_model.dart'; // ✅ YEMEK MODEL EKLENDİ
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/gunluk_plan.dart';
import '../../domain/entities/yemek.dart'; // ✅ YEMEK ENTITY EKLENDİ
import '../../core/utils/app_logger.dart';

class HiveService {
  static const String _kullaniciBox = 'kullanici_box';
  static const String _planlarBox = 'planlar_box';
  static const String _favoriYemeklerBox = 'favori_yemekler_box';
  static const String _antrenmanBox = 'antrenman_box';
  static const String _yemekBox = 'yemek_box'; // ✅ YEMEK BOX EKLENDİ

  // ========================================================================
  // BAŞLATMA
  // ========================================================================

  /// Hive'ı başlat ve tüm box'ları aç (YEMEK DESTEKLİ)
  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Adapter'ları kaydet
      Hive.registerAdapter(KullaniciHiveModelAdapter());
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
      Hive.registerAdapter(TamamlananAntrenmanHiveModelAdapter());
      Hive.registerAdapter(YemekHiveModelAdapter()); // ✅ YEMEK ADAPTER EKLENDİ

      // Box'ları aç
      await Hive.openBox<KullaniciHiveModel>(_kullaniciBox);
      await Hive.openBox<GunlukPlanHiveModel>(_planlarBox);
      await Hive.openBox(_favoriYemeklerBox);
      await Hive.openBox<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      await Hive.openBox<YemekHiveModel>(_yemekBox); // ✅ YEMEK BOX AÇILDI

      AppLogger.info('✅ Hive başarıyla başlatıldı (Yemek desteği ile)');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Hive başlatma hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========================================================================
  // YEMEK İŞLEMLERİ
  // ========================================================================

  /// Yemek kaydet
  static Future<void> yemekKaydet(YemekHiveModel yemek) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      await box.put(yemek.mealId, yemek);
      AppLogger.debug('✅ Yemek kaydedildi: ${yemek.mealName}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek kaydetme hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Yemek getir
  static Future<Yemek?> yemekGetir(String mealId) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final model = box.get(mealId);
      
      if (model != null) {
        AppLogger.debug('✅ Yemek bulundu: ${model.mealName}');
        return model.toEntity();
      } else {
        AppLogger.debug('ℹ️ Yemek bulunamadı: $mealId');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek getirme hatası', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Kategori bazlı yemekleri getir
  static Future<List<Yemek>> kategoriYemekleriGetir(String kategori) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller = box.values
          .where((yemek) => yemek.category?.toLowerCase() == kategori.toLowerCase())
          .toList();
      
      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug('✅ $kategori için ${yemekler.length} yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kategori yemekleri getirme hatası', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Tüm yemekleri getir
  static Future<List<Yemek>> tumYemekleriGetir() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller = box.values.toList();
      
      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug('✅ Toplam ${yemekler.length} yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Tüm yemekleri getirme hatası', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Yemek ara
  static Future<List<Yemek>> yemekAra(String arama) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller = box.values
          .where((yemek) => 
              yemek.mealName?.toLowerCase().contains(arama.toLowerCase()) == true ||
              yemek.ingredients?.any((malzeme) => 
                  malzeme.toLowerCase().contains(arama.toLowerCase())) == true)
          .toList();
      
      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug('✅ "$arama" için ${yemekler.length} yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek arama hatası', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Yemek sayısını getir
  static Future<int> yemekSayisi() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      return box.length;
    } catch (e) {
      AppLogger.error('❌ Yemek sayısı getirme hatası', error: e);
      return 0;
    }
  }

  /// Kategori sayılarını getir
  static Future<Map<String, int>> kategoriSayilari() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final sayilar = <String, int>{};
      
      for (var yemek in box.values) {
        final kategori = yemek.category ?? 'Bilinmeyen';
        sayilar[kategori] = (sayilar[kategori] ?? 0) + 1;
      }
      
      AppLogger.debug('✅ Kategori sayıları: $sayilar');
      return sayilar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kategori sayıları getirme hatası', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Tüm yemekleri sil
  static Future<void> tumYemekleriSil() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final count = box.length;
      await box.clear();
      AppLogger.info('🗑️ $count yemek silindi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek silme hatası', error: e, stackTrace: stackTrace);
    }
  }

  /// Yemek veritabanı durumu
  static Future<void> yemekVeritabaniDurumu() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final kategoriSayilari = await HiveService.kategoriSayilari();
      
      print('🍽️ === YEMEK VERİTABANI DURUMU ===');
      print('Toplam yemek sayısı: ${box.length}');
      print('─────────────────────────────────');
      print('Kategori dağılımı:');
      kategoriSayilari.forEach((kategori, sayi) {
        print('  $kategori: $sayi yemek');
      });
      print('=================================');
    } catch (e) {
      print('❌ Yemek veritabanı durumu hatası: $e');
    }
  }

  // ========================================================================
  // KULLANICI PROFİLİ İŞLEMLERİ (MEVCUT)
  // ========================================================================

  /// Kullanıcı profili kaydet
  static Future<void> kullaniciKaydet(KullaniciProfili profil) async {
    try {
      final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      final model = KullaniciHiveModel.fromEntity(profil);
      await box.put('aktif_kullanici', model);
      AppLogger.info('✅ Kullanıcı kaydedildi: ${profil.ad} ${profil.soyad}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kullanıcı kaydetme hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Kullanıcı profili getir
  static Future<KullaniciProfili?> kullaniciGetir() async {
    try {
      final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      final model = box.get('aktif_kullanici');
      
      if (model != null) {
        AppLogger.debug('✅ Kullanıcı bulundu: ${model.ad} ${model.soyad}');
      } else {
        AppLogger.warning('⚠️ Aktif kullanıcı bulunamadı');
      }
      
      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kullanıcı getirme hatası', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // ========================================================================
  // GÜNLÜK PLAN İŞLEMLERİ (MEVCUT)
  // ========================================================================

  /// Günlük plan kaydet
  static Future<void> planKaydet(GunlukPlan plan) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final model = GunlukPlanHiveModel.fromEntity(plan);
      final key = _tarihAnahtariOlustur(plan.tarih);
      
      await box.put(key, model);
      AppLogger.info('✅ Plan kaydedildi: ${plan.tarih.toString().split(' ')[0]}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Plan kaydetme hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Belirli tarihte plan getir
  static Future<GunlukPlan?> planGetir(DateTime tarih) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final key = _tarihAnahtariOlustur(tarih);
      final model = box.get(key);
      
      if (model != null) {
        AppLogger.debug('✅ Plan bulundu: ${tarih.toString().split(' ')[0]}');
      } else {
        AppLogger.debug('ℹ️ Plan bulunamadı: ${tarih.toString().split(' ')[0]}');
      }
      
      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error('❌ Plan getirme hatası', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // ========================================================================
  // YARDIMCI METODLAR
  // ========================================================================

  /// Tarih için benzersiz anahtar oluştur (YYYY-MM-DD formatı)
  static String _tarihAnahtariOlustur(DateTime tarih) {
    return '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';
  }

  /// Debug bilgisi yazdır (Geliştirme amaçlı)
  static Future<void> debugBilgisi() async {
    try {
      final kullaniciVar = await kullaniciVarMi();
      final bugunPlanVar = await bugunPlanVarMi();
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final yemekSayisi = await HiveService.yemekSayisi();

      print('📊 === HIVE DEBUG BİLGİSİ ===');
      print('Kullanıcı var mı: ${kullaniciVar ? "✅ Evet" : "❌ Hayır"}');
      print('Bugün plan var mı: ${bugunPlanVar ? "✅ Evet" : "❌ Hayır"}');
      print('Toplam plan sayısı: ${box.length}');
      print('Toplam yemek sayısı: $yemekSayisi');
      print('=============================');
    } catch (e) {
      print('❌ Debug bilgisi hatası: $e');
    }
  }

  /// Kullanıcı var mı kontrolü
  static Future<bool> kullaniciVarMi() async {
    try {
      final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      return box.containsKey('aktif_kullanici');
    } catch (e) {
      AppLogger.error('❌ Kullanıcı varlık kontrolü hatası', error: e);
      return false;
    }
  }

  /// Bugünün planı var mı?
  static Future<bool> bugunPlanVarMi() async {
    final bugun = DateTime.now();
    final plan = await planGetir(bugun);
    return plan != null;
  }

  /// Tüm box'ları kapat
  static Future<void> close() async {
    try {
      await Hive.close();
      AppLogger.info('✅ Hive kapatıldı');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Hive kapatma hatası', error: e, stackTrace: stackTrace);
    }
  }
}

