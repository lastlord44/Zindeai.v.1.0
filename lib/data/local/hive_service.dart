// ============================================================================
// lib/data/local/hive_service.dart
// GELIŞMIŞ HIVE LOCAL STORAGE SERVICE (YEMEK DESTEKLİ)
// ============================================================================

import 'package:hive/hive.dart';
import 'dart:io';
import '../models/kullanici_hive_model.dart';
import '../models/gunluk_plan_hive_model.dart';
import '../models/antrenman_hive_model.dart';
import '../models/yemek_hive_model.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/gunluk_plan.dart';
import '../../domain/entities/antrenman.dart';
import '../../domain/entities/yemek.dart';
import '../../domain/entities/yemek_onay_sistemi.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/cesitlilik_gecmis_servisi.dart';

class HiveService {
  static const String _kullaniciBox = 'kullanici_box';
  static const String _planlarBox = 'planlar_box';
  static const String _favoriYemeklerBox = 'favori_yemekler_box';
  static const String _antrenmanBox = 'antrenman_box';
  static const String _yemekBox =
      'yemekler'; // ✅ Fiziksel dosya adıyla eşleşmeli!
  static const String _yemekOnayBox = 'yemek_onay_box';
  static const String _raporBox = 'rapor_box';

  // ========================================================================
  // BAŞLATMA
  // ========================================================================

  /// Hive'ı başlat ve tüm box'ları aç
  static Future<void> init({bool isTest = false}) async {
    try {
      // Adapter'ları kaydet
      if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
        Hive.registerAdapter(KullaniciHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
        Hive.registerAdapter(GunlukPlanHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(
          TamamlananAntrenmanHiveModelAdapter().typeId)) {
        Hive.registerAdapter(TamamlananAntrenmanHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
        Hive.registerAdapter(YemekHiveModelAdapter());
      }

      // Box'ları aç
      await Hive.openBox<KullaniciHiveModel>(_kullaniciBox);
      await Hive.openBox<GunlukPlanHiveModel>(_planlarBox);
      await Hive.openBox(_favoriYemeklerBox);
      await Hive.openBox<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      await Hive.openBox<YemekHiveModel>(_yemekBox);
      await Hive.openBox(_yemekOnayBox); // Yemek onayları için
      await Hive.openBox(_raporBox); // Rapor verileri için

      // 🔥 KRİTİK TEST FIX: Test modunda platforma bağımlı servisleri başlatma!
      if (!isTest) {
        // Cesitlilik gecmis servisi baslat
        await CesitlilikGecmisServisi.init();
      }

      AppLogger.info('✅ Hive başarıyla başlatıldı (Boxlar ve Adaptörler)');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Hive başlatma hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========================================================================
  // YEMEK İŞLEMLERİ
  // ========================================================================

  /// Yemek kaydet
  static Future<void> yemekKaydet(YemekHiveModel yemek) async {
    try {
      // 🔥 FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      // 🔥 FIX: mealId null olmamalı! Static method kullanarak garantili ID oluştur
      if (yemek.mealId == null || yemek.mealId!.isEmpty) {
        yemek.mealId = YemekHiveModel.generateMealId();
      }

      final key = yemek.mealId!; // Artık kesinlikle null değil

      // 🔥 DUPLICATE ID VERİ EZİLMESİ ÖNLEME - 905 adet duplicate fix!
      if (box.containsKey(key)) {
        // Aynı ID zaten var → deterministik yeni ID üret (isim+makro hash'i)
        final suffix = YemekHiveModel.generateHashSuffix(
          yemek.mealName ?? '',
          yemek.calorie ?? 0,
          yemek.proteinG ?? 0,
          yemek.carbG ?? 0,
          yemek.fatG ?? 0,
        );
        final newKey = '${key}_$suffix';
        yemek.mealId = newKey;
        await box.put(newKey, yemek);
        // AppLogger.debug('🔧 DUPLICATE ID FIX: $key → $newKey');
      } else {
        await box.put(key, yemek);
      }
      // Log removed - spam önleme (migration sırasında binlerce kez çağrılıyor)
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek kaydetme hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Yemek getir
  static Future<Yemek?> yemekGetir(String mealId) async {
    try {
      // 🔥 FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      final model = box.get(mealId);

      if (model != null) {
        // Log removed - spam önleme
        return model.toEntity();
      } else {
        // Log removed - spam önleme (migration sırasında binlerce kez çağrılıyor)
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek getirme hatası',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Kategori bazlı yemekleri getir
  static Future<List<Yemek>> kategoriYemekleriGetir(String kategori) async {
    try {
      // 🔥 KRITIK FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      final modeller = box.values
          .where((yemek) =>
              yemek.category?.toLowerCase() == kategori.toLowerCase())
          .toList();

      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug('✅ $kategori için ${yemekler.length} yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kategori yemekleri getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Tüm yemekleri getir - KRITIK METOD!
  static Future<List<Yemek>> tumYemekleriGetir() async {
    try {
      // 🔥 KRITIK FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      final modeller = box.values.toList();
      AppLogger.info('📊 BOX İÇERİK: ${modeller.length} yemek modeli bulundu');

      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.success(
          '✅ Toplam ${yemekler.length} yemek entity dönüştürüldü');

      // Box boşsa detaylı bilgi ver
      if (yemekler.isEmpty) {
        AppLogger.error('🚨 BOX BOŞ! Migration çalışmamış olabilir');
        AppLogger.info('📋 Box keys: ${box.keys.toList()}');
        AppLogger.info('📋 Box path: ${box.path}');
      }

      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ KRITIK HATA: Tüm yemekleri getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Yemek ara
  static Future<List<Yemek>> yemekAra(String arama) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller = box.values
          .where((yemek) =>
              yemek.mealName?.toLowerCase().contains(arama.toLowerCase()) ==
                  true ||
              yemek.ingredients?.any((malzeme) =>
                      malzeme.toLowerCase().contains(arama.toLowerCase())) ==
                  true)
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
      // 🔥 FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      final count = box.length;
      AppLogger.debug('📊 Toplam yemek sayısı: $count');
      return count;
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
      AppLogger.error('❌ Kategori sayıları getirme hatası',
          error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Tüm yemekleri sil
  static Future<void> tumYemekleriSil() async {
    try {
      // 🔥 FIX: Box açık değilse aç
      final Box<YemekHiveModel> box = Hive.isBoxOpen(_yemekBox)
          ? Hive.box<YemekHiveModel>(_yemekBox)
          : await Hive.openBox<YemekHiveModel>(_yemekBox);

      final count = box.length;
      await box.clear();
      AppLogger.info('🗑️ $count yemek silindi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek silme hatası', error: e, stackTrace: stackTrace);
    }
  }

  // ========================================================================
  // FAVORİ YEMEK İŞLEMLERİ
  // ========================================================================

  /// Yemeği favorilere ekle
  static Future<void> favoriyeEkle(String mealId) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final yemek = box.get(mealId);

      if (yemek != null) {
        yemek.isFavorite = true;
        await box.put(mealId, yemek);
        AppLogger.info('⭐ Yemek favorilere eklendi: ${yemek.mealName}');
      } else {
        AppLogger.warning('⚠️ Favori eklenirken yemek bulunamadı: $mealId');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Favoriye ekleme hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Yemeği favorilerden çıkar
  static Future<void> favoridenCikar(String mealId) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final yemek = box.get(mealId);

      if (yemek != null) {
        yemek.isFavorite = false;
        await box.put(mealId, yemek);
        AppLogger.info('🗑️ Yemek favorilerden çıkarıldı: ${yemek.mealName}');
      } else {
        AppLogger.warning(
            '⚠️ Favoriden çıkarılırken yemek bulunamadı: $mealId');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Favoriden çıkarma hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Favori durumunu toggle et
  static Future<bool> favoriToggle(String mealId) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final yemek = box.get(mealId);

      if (yemek != null) {
        yemek.isFavorite = !(yemek.isFavorite ?? false);
        await box.put(mealId, yemek);
        AppLogger.debug(
            '⭐ Favori durumu değişti: ${yemek.mealName} -> ${yemek.isFavorite}');
        return yemek.isFavorite ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Favori toggle hatası',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Yemek favori mi kontrol et
  static Future<bool> favoriMi(String mealId) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final yemek = box.get(mealId);
      return yemek?.isFavorite ?? false;
    } catch (e) {
      AppLogger.error('❌ Favori kontrolü hatası', error: e);
      return false;
    }
  }

  /// Tüm favori yemekleri getir
  static Future<List<Yemek>> favoriYemekleriGetir() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller =
          box.values.where((yemek) => yemek.isFavorite == true).toList();

      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug('⭐ ${yemekler.length} favori yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Favori yemekleri getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Kategori bazlı favori yemekleri getir
  static Future<List<Yemek>> kategoriFavoriYemekleriGetir(
      String kategori) async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final modeller = box.values
          .where((yemek) =>
              yemek.isFavorite == true &&
              yemek.category?.toLowerCase() == kategori.toLowerCase())
          .toList();

      final yemekler = modeller.map((model) => model.toEntity()).toList();
      AppLogger.debug(
          '⭐ $kategori için ${yemekler.length} favori yemek bulundu');
      return yemekler;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kategori favori yemekleri getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Favori yemek sayısı
  static Future<int> favoriSayisi() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      return box.values.where((yemek) => yemek.isFavorite == true).length;
    } catch (e) {
      AppLogger.error('❌ Favori sayısı getirme hatası', error: e);
      return 0;
    }
  }

  /// Tüm favorileri temizle
  static Future<void> tumFavorileriTemizle() async {
    try {
      final box = Hive.box<YemekHiveModel>(_yemekBox);
      final favoriler =
          box.values.where((yemek) => yemek.isFavorite == true).toList();

      for (final yemek in favoriler) {
        yemek.isFavorite = false;
        await box.put(yemek.mealId!, yemek);
      }

      AppLogger.info('🗑️ ${favoriler.length} favori temizlendi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Favorileri temizleme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  // ========================================================================
  // KULLANICI PROFİLİ İŞLEMLERİ
  // ========================================================================

  /// Kullanıcı profili kaydet
  static Future<void> kullaniciKaydet(KullaniciProfili profil) async {
    try {
      AppLogger.info('--- KULLANICI KAYDETME İŞLEMİ BAŞLADI ---');
      AppLogger.debug(
          'Gelen profil: ${profil.ad}, Hedef: ${profil.hedef.aciklama}');

      final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      AppLogger.debug('Kullanıcı kutusu açıldı. Path: ${box.path}');

      final model = KullaniciHiveModel.fromEntity(profil);
      AppLogger.debug(
          'KullaniciHiveModel oluşturuldu: ${model.ad}, Hedef: ${model.hedef}');

      await box.put('aktif_kullanici', model);
      AppLogger.info(
          '✅ "aktif_kullanici" anahtarıyla box.put() işlemi tamamlandı.');

      // Doğrulama adımı
      final kaydedilenModel = box.get('aktif_kullanici');
      if (kaydedilenModel != null) {
        AppLogger.success(
            '✅ DOĞRULAMA BAŞARILI: Kullanıcı verisi Hive\'a yazıldı ve geri okundu.');
        AppLogger.debug(
            'Okunan veri: ${kaydedilenModel.ad}, Hedef: ${kaydedilenModel.hedef}');
      } else {
        AppLogger.error(
            '❌ DOĞRULAMA BAŞARISIZ: Veri Hive\'a yazıldıktan sonra okunamadı!');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kullanıcı kaydetme hatası',
          error: e, stackTrace: stackTrace);
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
      AppLogger.error('❌ Kullanıcı getirme hatası',
          error: e, stackTrace: stackTrace);
      return null;
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

  /// Kullanıcı profilini güncelle
  static Future<void> kullaniciGuncelle(KullaniciProfili profil) async {
    await kullaniciKaydet(profil);
  }

  /// Kullanıcı sil
  static Future<void> kullaniciSil() async {
    try {
      final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      await box.delete('aktif_kullanici');
      AppLogger.info('🗑️ Kullanıcı profili silindi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kullanıcı silme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  // ========================================================================
  // GÜNLÜK PLAN İŞLEMLERİ
  // ========================================================================

  /// Günlük plan kaydet
  static Future<void> planKaydet(GunlukPlan plan) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final model = GunlukPlanHiveModel.fromEntity(plan);
      final key = _tarihAnahtariOlustur(plan.tarih);

      await box.put(key, model);
      AppLogger.info(
          '✅ Plan kaydedildi: ${plan.tarih.toString().split(' ')[0]}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Plan kaydetme hatası',
          error: e, stackTrace: stackTrace);
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
        AppLogger.debug(
            'ℹ️ Plan bulunamadı: ${tarih.toString().split(' ')[0]}');
      }

      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error('❌ Plan getirme hatası',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Bugünün planı var mı?
  static Future<bool> bugunPlanVarMi() async {
    final bugun = DateTime.now();
    final plan = await planGetir(bugun);
    return plan != null;
  }

  /// Tüm planları getir
  static Future<List<GunlukPlan>> tumPlanlariGetir() async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final planlar = <GunlukPlan>[];

      for (final model in box.values) {
        try {
          planlar.add(model.toEntity());
        } catch (e) {
          AppLogger.warning('⚠️ Plan parse hatası, atlanıyor: $e');
        }
      }

      planlar.sort((a, b) => b.tarih.compareTo(a.tarih));

      AppLogger.debug('✅ ${planlar.length} plan getirildi');
      return planlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Tüm planları getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Son N günün planlarını getir
  static Future<List<GunlukPlan>> sonPlanlariGetir({int gun = 30}) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final simdi = DateTime.now();
      final baslangic = simdi.subtract(Duration(days: gun));

      final planlar = <GunlukPlan>[];

      for (final model in box.values) {
        try {
          final plan = model.toEntity();
          final tarih = plan.tarih;

          if (tarih.isAfter(baslangic) &&
              tarih.isBefore(simdi.add(const Duration(days: 1)))) {
            planlar.add(plan);
          }
        } catch (e) {
          AppLogger.warning('⚠️ Plan parse hatası, atlanıyor: $e');
        }
      }

      planlar.sort((a, b) => b.tarih.compareTo(a.tarih));

      AppLogger.debug('✅ Son $gun günün ${planlar.length} planı getirildi');
      return planlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Son planları getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Tarih aralığındaki planları getir
  static Future<List<GunlukPlan>> tarihAraligiPlanlariGetir(
    DateTime baslangic,
    DateTime bitis,
  ) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final planlar = <GunlukPlan>[];

      for (final model in box.values) {
        try {
          final plan = model.toEntity();
          final tarih = plan.tarih;

          if ((tarih.isAfter(baslangic) || tarih.isAtSameMomentAs(baslangic)) &&
              (tarih.isBefore(bitis) || tarih.isAtSameMomentAs(bitis))) {
            planlar.add(plan);
          }
        } catch (e) {
          AppLogger.warning('⚠️ Plan parse hatası, atlanıyor: $e');
        }
      }

      planlar.sort((a, b) => a.tarih.compareTo(b.tarih));

      AppLogger.debug('✅ Tarih aralığı: ${planlar.length} plan bulundu');
      return planlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Tarih aralığı planları getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Plan sil
  static Future<void> planSil(String planId) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      await box.delete(planId);
      AppLogger.info('🗑️ Plan silindi: $planId');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Plan silme hatası', error: e, stackTrace: stackTrace);
    }
  }

  /// Belirli tarihteki planı sil
  static Future<void> tarihPlanSil(DateTime tarih) async {
    final key = _tarihAnahtariOlustur(tarih);
    await planSil(key);
  }

  /// Tamamlanan öğünleri getir
  static Future<Map<String, bool>> tamamlananOgunleriGetir(
      DateTime tarih) async {
    try {
      final box = Hive.box(_favoriYemeklerBox);
      final key = 'tamamlanan_${_tarihAnahtariOlustur(tarih)}';
      final data = box.get(key);

      if (data == null) return {};

      return Map<String, bool>.from(data as Map);
    } catch (e) {
      AppLogger.error('❌ Tamamlanan öğünleri getirme hatası', error: e);
      return {};
    }
  }

  /// Tamamlanan öğünleri kaydet
  static Future<void> tamamlananOgunleriKaydet(
    DateTime tarih,
    Map<String, bool> tamamlananlar,
  ) async {
    try {
      final box = Hive.box(_favoriYemeklerBox);
      final key = 'tamamlanan_${_tarihAnahtariOlustur(tarih)}';
      await box.put(key, tamamlananlar);
      AppLogger.debug(
          '✅ Tamamlanan öğünler kaydedildi: ${tamamlananlar.length} öğün');
    } catch (e) {
      AppLogger.error('❌ Tamamlanan öğünleri kaydetme hatası', error: e);
    }
  }

  /// Tüm planları sil
  static Future<void> tumPlanlariSil() async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final count = box.length;
      await box.clear();
      AppLogger.info('🗑️ $count plan silindi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Tüm planları silme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  // ========================================================================
  // İSTATİSTİK İŞLEMLERİ
  // ========================================================================

  /// Ortalama günlük kalori (son N gün)
  static Future<double> ortalamaGunlukKalori({int gun = 7}) async {
    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    final toplam = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.toplamKalori,
    );

    return toplam / planlar.length;
  }

  /// Ortalama günlük protein (son N gün)
  static Future<double> ortalamaGunlukProtein({int gun = 7}) async {
    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    final toplam = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.toplamProtein,
    );

    return toplam / planlar.length;
  }

  /// Ortalama günlük karbonhidrat (son N gün)
  static Future<double> ortalamaGunlukKarbonhidrat({int gun = 7}) async {
    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    final toplam = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.toplamKarbonhidrat,
    );

    return toplam / planlar.length;
  }

  /// Ortalama günlük yağ (son N gün)
  static Future<double> ortalamaGunlukYag({int gun = 7}) async {
    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    final toplam = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.toplamYag,
    );

    return toplam / planlar.length;
  }

  /// Ortalama fitness skoru (son N gün)
  static Future<double> ortalamaFitnessSkoru({int gun = 7}) async {
    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    final toplam = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.fitnessSkoru,
    );

    return toplam / planlar.length;
  }

  /// Hedef tutturma yüzdesi
  static Future<double> hedefTutturmaYuzdesi({int gun = 7}) async {
    final kullanici = await kullaniciGetir();
    if (kullanici == null) return 0;

    final planlar = await sonPlanlariGetir(gun: gun);
    if (planlar.isEmpty) return 0;

    return ortalamaFitnessSkoru(gun: gun);
  }

  // ========================================================================
  // TEMİZLİK İŞLEMLERİ
  // ========================================================================

  /// Eski planları temizle (30 günden eski)
  static Future<int> eskiPlanlariTemizle({int gunSiniri = 30}) async {
    try {
      final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
      final simdi = DateTime.now();
      final esikTarih = simdi.subtract(Duration(days: gunSiniri));

      final silinecekAnahtarlar = <String>[];

      for (final entry in box.toMap().entries) {
        try {
          final model = entry.value;
          final tarih = model.tarih;

          if (tarih.isBefore(esikTarih)) {
            silinecekAnahtarlar.add(entry.key);
          }
        } catch (e) {
          AppLogger.warning('⚠️ Plan kontrolü hatası, atlanıyor: $e');
        }
      }

      for (final key in silinecekAnahtarlar) {
        await box.delete(key);
      }

      AppLogger.info('🧹 ${silinecekAnahtarlar.length} eski plan temizlendi');
      return silinecekAnahtarlar.length;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Eski plan temizleme hatası',
          error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  // ========================================================================
  // ANTRENMAN İŞLEMLERİ
  // ========================================================================

  /// Tamamlanan antrenman kaydet
  static Future<void> tamamlananAntrenmanKaydet(
      TamamlananAntrenman antrenman) async {
    try {
      final box = Hive.box<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      final model = TamamlananAntrenmanHiveModel.fromDomain(antrenman);
      await box.put(antrenman.id, model);
      AppLogger.info('✅ Antrenman kaydedildi: ${antrenman.antrenmanId}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Antrenman kaydetme hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Tüm tamamlanmış antrenmanları getir
  static Future<List<TamamlananAntrenman>> tamamlananAntrenmanlar() async {
    try {
      final box = Hive.box<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      final antrenmanlar = <TamamlananAntrenman>[];

      for (final model in box.values) {
        try {
          antrenmanlar.add(model.toDomain());
        } catch (e) {
          AppLogger.warning('⚠️ Antrenman parse hatası, atlanıyor: $e');
        }
      }

      antrenmanlar
          .sort((a, b) => b.tamamlanmaTarihi.compareTo(a.tamamlanmaTarihi));

      AppLogger.debug('✅ ${antrenmanlar.length} antrenman getirildi');
      return antrenmanlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Antrenmanları getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Son N günün antrenmanlarını getir
  static Future<List<TamamlananAntrenman>> sonAntrenmanlar(
      {int gun = 30}) async {
    try {
      final box = Hive.box<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      final simdi = DateTime.now();
      final baslangic = simdi.subtract(Duration(days: gun));

      final antrenmanlar = <TamamlananAntrenman>[];

      for (final model in box.values) {
        try {
          final antrenman = model.toDomain();
          final tarih = antrenman.tamamlanmaTarihi;

          if (tarih.isAfter(baslangic) &&
              tarih.isBefore(simdi.add(const Duration(days: 1)))) {
            antrenmanlar.add(antrenman);
          }
        } catch (e) {
          AppLogger.warning('⚠️ Antrenman parse hatası, atlanıyor: $e');
        }
      }

      antrenmanlar
          .sort((a, b) => b.tamamlanmaTarihi.compareTo(a.tamamlanmaTarihi));

      AppLogger.debug(
          '✅ Son $gun günün ${antrenmanlar.length} antrenmanı getirildi');
      return antrenmanlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Son antrenmanları getirme hatası',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Antrenman sil
  static Future<void> antrenmanSil(String antrenmanId) async {
    try {
      final box = Hive.box<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      await box.delete(antrenmanId);
      AppLogger.info('🗑️ Antrenman silindi: $antrenmanId');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Antrenman silme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Tüm antrenmanları sil
  static Future<void> tumAntrenmanlariSil() async {
    try {
      final box = Hive.box<TamamlananAntrenmanHiveModel>(_antrenmanBox);
      final count = box.length;
      await box.clear();
      AppLogger.info('🗑️ $count antrenman silindi');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Tüm antrenmanları silme hatası',
          error: e, stackTrace: stackTrace);
    }
  }

  // ========================================================================
  // TEMİZLİK İŞLEMLERİ
  // ========================================================================

  /// Tüm verileri temizle
  static Future<void> tumVerileriTemizle() async {
    await kullaniciSil();
    await tumPlanlariSil();
    await tumAntrenmanlariSil();
    await tumYemekleriSil();
    AppLogger.info('🗑️ Tüm veriler temizlendi');
  }

  /// Tüm box'ları kapat
  static Future<void> close() async {
    try {
      await Hive.close();
      AppLogger.info('✅ Hive kapatıldı');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Hive kapatma hatası',
          error: e, stackTrace: stackTrace);
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
      final ortKalori = await ortalamaGunlukKalori(gun: 7);
      final ortProtein = await ortalamaGunlukProtein(gun: 7);
      final ortFitness = await ortalamaFitnessSkoru(gun: 7);
      final yemekSayisi = await HiveService.yemekSayisi();

      print('📊 === HIVE DEBUG BİLGİSİ ===');
      print('Kullanıcı var mı: ${kullaniciVar ? "✅ Evet" : "❌ Hayır"}');
      print('Bugün plan var mı: ${bugunPlanVar ? "✅ Evet" : "❌ Hayır"}');
      print('Toplam plan sayısı: ${box.length}');
      print('Toplam yemek sayısı: $yemekSayisi');
      print('─────────────────────────────');
      print('7 Günlük Ortalamalar:');
      print('  Kalori: ${ortKalori.toStringAsFixed(0)} kcal');
      print('  Protein: ${ortProtein.toStringAsFixed(0)} g');
      print('  Fitness Skoru: ${ortFitness.toStringAsFixed(1)}/100');
      print('=============================');
    } catch (e) {
      print('❌ Debug bilgisi hatası: $e');
    }
  }

  /// Storage boyutunu hesapla (MB cinsinden)
  static Future<double> storageBoyutu() async {
    try {
      final box1 = Hive.box<KullaniciHiveModel>(_kullaniciBox);
      final box2 = Hive.box<GunlukPlanHiveModel>(_planlarBox);

      final toplamEntry = box1.length + box2.length;
      final tahminiMB = toplamEntry * 0.01;

      return tahminiMB;
    } catch (e) {
      return 0;
    }
  }

  // ========================================================================
  // YEMEK ONAY SİSTEMİ İŞLEMLERİ
  // ========================================================================

  /// Yemek onay verisi getir
  static Future<GunlukOnayDurumu?> yemekOnayVerisiGetir(DateTime tarih) async {
    try {
      final box = Hive.box(_yemekOnayBox);
      final key = _tarihAnahtariOlustur(tarih);
      final data = box.get(key);

      if (data == null) return null;

      // Map'den GunlukOnayDurumu oluştur
      final yemekDurumlari = <String, YemekOnayVerisi>{};
      final yemekData = data['yemekDurumlari'] as Map? ?? {};

      for (final entry in yemekData.entries) {
        final yemekId = entry.key.toString();
        final durumData = entry.value as Map;

        final durum = YemekOnayVerisi(
          yemekId: yemekId,
          tarih: tarih,
          durum: YemekDurumu.values.firstWhere(
            (d) => d.name == durumData['durum'],
            orElse: () => YemekDurumu.bekliyor,
          ),
          yemeTarihi: durumData['yemeTarihi'] != null
              ? DateTime.parse(durumData['yemeTarihi'])
              : null,
          onayTarihi: durumData['onayTarihi'] != null
              ? DateTime.parse(durumData['onayTarihi'])
              : null,
          notlar: durumData['notlar'] as String?,
          degistirilebilir: durumData['degistirilebilir'] as bool? ?? true,
        );

        yemekDurumlari[yemekId] = durum;
      }

      return GunlukOnayDurumu(
        tarih: tarih,
        yemekDurumlari: yemekDurumlari,
        sonGuncelleme: DateTime.parse(data['sonGuncelleme']),
      );
    } catch (e) {
      AppLogger.error('❌ Yemek onay verisi getirme hatası: $e');
      return null;
    }
  }

  /// Yemek onay verisi kaydet
  static Future<void> yemekOnayVerisiKaydet(
      DateTime tarih, GunlukOnayDurumu durum) async {
    try {
      final box = Hive.box(_yemekOnayBox);
      final key = _tarihAnahtariOlustur(tarih);

      // GunlukOnayDurumu'yu Map'e çevir
      final yemekDurumlari = <String, Map>{};

      for (final entry in durum.yemekDurumlari.entries) {
        final yemekId = entry.key;
        final yemekDurumu = entry.value;

        yemekDurumlari[yemekId] = {
          'durum': yemekDurumu.durum.name,
          'yemeTarihi': yemekDurumu.yemeTarihi?.toIso8601String(),
          'onayTarihi': yemekDurumu.onayTarihi?.toIso8601String(),
          'notlar': yemekDurumu.notlar,
          'degistirilebilir': yemekDurumu.degistirilebilir,
        };
      }

      final data = {
        'yemekDurumlari': yemekDurumlari,
        'sonGuncelleme': durum.sonGuncelleme.toIso8601String(),
      };

      await box.put(key, data);
      AppLogger.debug(
          '✅ Yemek onay verisi kaydedildi: ${_tarihAnahtariOlustur(tarih)}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek onay verisi kaydetme hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Rapor verisi kaydet
  static Future<void> raporVerisiKaydet(
      DateTime tarih, Map<String, dynamic> raporVerisi) async {
    try {
      final box = Hive.box(_raporBox);
      final key =
          'rapor_${_tarihAnahtariOlustur(tarih)}_${DateTime.now().millisecondsSinceEpoch}';

      await box.put(key, raporVerisi);
      AppLogger.debug('✅ Rapor verisi kaydedildi: $key');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Rapor verisi kaydetme hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Rapor verilerini getir
  static Future<List<Map<String, dynamic>>> raporVerileriniGetir(
      DateTime tarih) async {
    try {
      final box = Hive.box(_raporBox);
      final tarihKey = _tarihAnahtariOlustur(tarih);
      final raporlar = <Map<String, dynamic>>[];

      for (final entry in box.toMap().entries) {
        if (entry.key.toString().contains('rapor_$tarihKey')) {
          raporlar.add(Map<String, dynamic>.from(entry.value as Map));
        }
      }

      return raporlar;
    } catch (e) {
      AppLogger.error('❌ Rapor verileri getirme hatası: $e');
      return [];
    }
  }
}
