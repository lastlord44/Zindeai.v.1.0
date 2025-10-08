// ============================================================================
// HIVE VERİTABANINI TEMİZLE VE YENİ VERI YÜKLE
// ============================================================================

import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/data/models/antrenman_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  print('🗑️ Hive veritabanı temizleniyor...');

  // Hive'ı başlat (Flutter olmadan)
  Hive.init(Directory.current.path);

  // Adapterleri kaydet
  Hive.registerAdapter(YemekHiveModelAdapter());
  Hive.registerAdapter(KullaniciHiveModelAdapter());
  Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  Hive.registerAdapter(AntrenmanHiveModelAdapter());

  try {
    // Tüm box'ları aç
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemekBox');
    final kullaniciBox = await Hive.openBox<KullaniciHiveModel>('kullaniciBox');
    final planBox = await Hive.openBox<GunlukPlanHiveModel>('gunlukPlanBox');
    final antrenmanBox = await Hive.openBox<AntrenmanHiveModel>('antrenmanBox');

    print('📊 Mevcut veri:');
    print('  - Yemekler: ${yemekBox.length}');
    print('  - Kullanıcılar: ${kullaniciBox.length}');
    print('  - Planlar: ${planBox.length}');
    print('  - Antrenmanlar: ${antrenmanBox.length}');

    // SADECE YEMEK VERİTABANINI TEMİZLE (kullanıcı verileri korunsun!)
    print('🗑️ Yemek veritabanı temizleniyor...');
    await yemekBox.clear();
    print('✅ Yemek veritabanı temizlendi!');

    // Planları da temizle (yeni yemeklerle plan oluşturulacak)
    print('🗑️ Eski planlar temizleniyor...');
    await planBox.clear();
    print('✅ Eski planlar temizlendi!');

    // Yeni migration çalıştır
    print('🚀 Yeni yemekler yükleniyor...');
    print('📂 Dosyalar:');
    print('   - zindeai_kahvalti_300.json (300 kahvaltı)');
    print('   - zindeai_ogle_300.json (300 öğle yemeği)');
    print('   - zindeai_aksam_300.json (300 akşam yemeği)');

    final success = await YemekMigration.jsonToHiveMigration();

    if (success) {
      print('✅ ✅ ✅ BAŞARILI! ✅ ✅ ✅');
      print('📊 Yeni veritabanı durumu:');
      print('  - Toplam yemek: ${yemekBox.length}');
      print('🎉 Artık yeni yemekler kullanılıyor!');
      print('🎉 900 farklı yemek seçeneği var!');
    } else {
      print('❌ Migration başarısız!');
    }

    // Kapat
    await Hive.close();

    print('✅ İşlem tamamlandı. Uygulamayı kapatıp tekrar açın.');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print(stackTrace);
    exit(1);
  }
}
