// ============================================================================
// lib/data/local/hive_service.dart
// FAZ 6: HIVE LOCAL STORAGE SERVİSİ
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../models/kullanici_hive_model.dart';
import '../models/gunluk_plan_hive_model.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/gunluk_plan.dart';

class HiveService {
  static const String _kullaniciBox = 'kullanici';
  static const String _planlarBox = 'planlar';

  /// Hive'ı başlat
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapter'ları kaydet
    Hive.registerAdapter(KullaniciHiveModelAdapter());
    Hive.registerAdapter(GunlukPlanHiveModelAdapter());

    // Box'ları aç
    await Hive.openBox<KullaniciHiveModel>(_kullaniciBox);
    await Hive.openBox<GunlukPlanHiveModel>(_planlarBox);

    print('✅ Hive başlatıldı');
  }

  // ========================================================================
  // KULLANICI İŞLEMLERİ
  // ========================================================================

  /// Kullanıcı kaydet
  static Future<void> kullaniciKaydet(KullaniciProfili profil) async {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    final model = KullaniciHiveModel.fromDomain(profil);
    await box.put('aktif_kullanici', model);
    print('✅ Kullanıcı kaydedildi: ${profil.ad}');
  }

  /// Kullanıcı getir
  static KullaniciProfili? kullaniciGetir() {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    final model = box.get('aktif_kullanici');
    return model?.toDomain();
  }

  /// Kullanıcı var mı kontrol et
  static bool kullaniciVarMi() {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    return box.containsKey('aktif_kullanici');
  }

  /// Kullanıcı sil
  static Future<void> kullaniciSil() async {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    await box.delete('aktif_kullanici');
    print('🗑️ Kullanıcı silindi');
  }

  // ========================================================================
  // PLAN İŞLEMLERİ
  // ========================================================================

  /// Plan kaydet
  static Future<void> planKaydet(GunlukPlan plan) async {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final model = GunlukPlanHiveModel.fromDomain(plan);
    final key = _tarihToKey(plan.tarih);
    await box.put(key, model);
    print('✅ Plan kaydedildi: ${plan.tarih.day}/${plan.tarih.month}');
  }

  /// Plan getir (tarihe göre)
  static GunlukPlan? planGetir(DateTime tarih) {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final key = _tarihToKey(tarih);
    final model = box.get(key);
    return model?.toDomain();
  }

  /// Bugünün planı var mı
  static bool bugunPlanVarMi() {
    final bugun = DateTime.now();
    return planGetir(bugun) != null;
  }

  /// Son X günün planlarını getir
  static List<GunlukPlan> sonPlanlariGetir({int gun = 30}) {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final simdi = DateTime.now();
    final baslangic = simdi.subtract(Duration(days: gun));

    final planlar = <GunlukPlan>[];

    for (var model in box.values) {
      final planTarihi = DateTime.parse(model.tarih);
      if (planTarihi.isAfter(baslangic) && planTarihi.isBefore(simdi.add(const Duration(days: 1)))) {
        planlar.add(model.toDomain());
      }
    }

    // Tarihe göre sırala (yeniden eskiye)
    planlar.sort((a, b) => b.tarih.compareTo(a.tarih));
    return planlar;
  }

  /// Plan sil
  static Future<void> planSil(DateTime tarih) async {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final key = _tarihToKey(tarih);
    await box.delete(key);
    print('🗑️ Plan silindi: ${tarih.day}/${tarih.month}');
  }

  // ========================================================================
  // GENEL İŞLEMLERİ
  // ========================================================================

  /// Tüm verileri sil
  static Future<void> tumVerileriSil() async {
    await Hive.box<KullaniciHiveModel>(_kullaniciBox).clear();
    await Hive.box<GunlukPlanHiveModel>(_planlarBox).clear();
    print('🗑️ Tüm veriler silindi');
  }

  /// İstatistikler
  static Map<String, dynamic> istatistikler() {
    final kullaniciBox = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    final planlarBox = Hive.box<GunlukPlanHiveModel>(_planlarBox);

    return {
      'kullanici_var': kullaniciBox.containsKey('aktif_kullanici'),
      'toplam_plan': planlarBox.length,
      'son_30_gun_plan': sonPlanlariGetir(gun: 30).length,
    };
  }

  // ========================================================================
  // HELPER METODLAR
  // ========================================================================

  /// Tarih → Key dönüşümü (YYYY-MM-DD formatı)
  static String _tarihToKey(DateTime tarih) {
    return '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';
  }
}
