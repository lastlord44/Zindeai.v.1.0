// ============================================================================
// lib/data/local/hive_service.dart
// Hive Local Storage Service
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../models/kullanici_hive_model.dart';
import '../models/gunluk_plan_hive_model.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/gunluk_plan.dart';

class HiveService {
  static const String kullaniciBoxName = 'kullanici_profili';
  static const String planlarBoxName = 'gunluk_planlar';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(KullaniciHiveModelAdapter());
    Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  }

  // ==========================================================================
  // KULLANICI PROFİLİ İŞLEMLERİ
  // ==========================================================================

  static Future<void> kullaniciKaydet(KullaniciProfili profil) async {
    final box = await Hive.openBox<KullaniciHiveModel>(kullaniciBoxName);
    final hiveModel = KullaniciHiveModel.fromEntity(profil);
    await box.put('profil', hiveModel);
  }

  static Future<KullaniciProfili?> kullaniciGetir() async {
    final box = await Hive.openBox<KullaniciHiveModel>(kullaniciBoxName);
    final hiveModel = box.get('profil');
    return hiveModel?.toEntity();
  }

  static Future<bool> kullaniciVarMi() async {
    final box = await Hive.openBox<KullaniciHiveModel>(kullaniciBoxName);
    return box.containsKey('profil');
  }

  static Future<void> kullaniciSil() async {
    final box = await Hive.openBox<KullaniciHiveModel>(kullaniciBoxName);
    await box.delete('profil');
  }

  // ==========================================================================
  // GÜNLÜK PLAN İŞLEMLERİ
  // ==========================================================================

  static Future<void> planKaydet(GunlukPlan plan) async {
    final box = await Hive.openBox<GunlukPlanHiveModel>(planlarBoxName);
    final hiveModel = GunlukPlanHiveModel.fromEntity(plan);
    await box.put(plan.id, hiveModel);
  }

  static Future<GunlukPlan?> planGetir(String planId) async {
    final box = await Hive.openBox<GunlukPlanHiveModel>(planlarBoxName);
    final hiveModel = box.get(planId);
    return hiveModel?.toEntity();
  }

  static Future<List<GunlukPlan>> tumPlanlariGetir() async {
    final box = await Hive.openBox<GunlukPlanHiveModel>(planlarBoxName);
    final planlar = <GunlukPlan>[];

    for (final hiveModel in box.values) {
      planlar.add(hiveModel.toEntity());
    }

    // Tarihe göre sırala (en yeni önce)
    planlar.sort((a, b) => b.tarih.compareTo(a.tarih));

    return planlar;
  }

  static Future<List<GunlukPlan>> sonPlanlariGetir(int adet) async {
    final tumPlanlar = await tumPlanlariGetir();
    return tumPlanlar.take(adet).toList();
  }

  static Future<void> planSil(String planId) async {
    final box = await Hive.openBox<GunlukPlanHiveModel>(planlarBoxName);
    await box.delete(planId);
  }

  static Future<void> tumPlanlariSil() async {
    final box = await Hive.openBox<GunlukPlanHiveModel>(planlarBoxName);
    await box.clear();
  }

  // ==========================================================================
  // GENEL İŞLEMLER
  // ==========================================================================

  static Future<void> tumVerileriTemizle() async {
    await kullaniciSil();
    await tumPlanlariSil();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
