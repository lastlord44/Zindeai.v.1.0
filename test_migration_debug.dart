import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/core/utils/app_logger.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n');
  print('═══════════════════════════════════════════════════════');
  print('🔍 MIGRATION DEBUG TEST BAŞLADI');
  print('═══════════════════════════════════════════════════════\n');

  try {
    // 1. Hive'ı başlat
    print('📦 Hive başlatılıyor...');
    await Hive.initFlutter();
    
    // 2. Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
      print('✅ YemekHiveModel adapter kaydedildi');
    }
    
    // 3. Box'ı aç
    await Hive.openBox<YemekHiveModel>('yemekler');
    print('✅ Yemekler box\'ı açıldı\n');

    // 4. Mevcut durumu göster
    final mevcutSayi = await HiveService.yemekSayisi();
    print('📊 Mevcut yemek sayısı: $mevcutSayi\n');

    // 5. Migration'ı temizle
    print('🗑️ Migration temizleniyor...');
    await YemekMigration.migrationTemizle();
    print('');

    // 6. Temizlik sonrası kontrol
    final temizlikSonrasi = await HiveService.yemekSayisi();
    print('📊 Temizlik sonrası yemek sayısı: $temizlikSonrasi\n');

    // 7. Migration'ı yükle (DEBUG MODE!)
    print('🔥🔥🔥 MİGRATION YÜKLEME BAŞLIYOR 🔥🔥🔥\n');
    print('═══════════════════════════════════════════════════════');
    
    final success = await YemekMigration.jsonToHiveMigration();
    
    print('═══════════════════════════════════════════════════════');
    print('\n🎯 Migration sonucu: ${success ? "BAŞARILI ✅" : "BAŞARISIZ ❌"}\n');

    // 8. Yükleme sonrası kontrol
    final yuklemeSonrasi = await HiveService.yemekSayisi();
    print('📊 Yükleme sonrası yemek sayısı: $yuklemeSonrasi');

    if (yuklemeSonrasi > 0) {
      print('\n✅✅✅ MİGRATION BAŞARILI! ✅✅✅');
      
      // Kategori dağılımını göster
      final kategoriSayilari = await HiveService.kategoriSayilari();
      print('\n📊 Kategori Dağılımı:');
      kategoriSayilari.forEach((kategori, sayi) {
        print('   • $kategori: $sayi yemek');
      });
    } else {
      print('\n❌❌❌ MİGRATION BAŞARISIZ - VERİTABANI BOŞ! ❌❌❌');
    }

  } catch (e, stackTrace) {
    print('\n❌❌❌ KRİTİK HATA! ❌❌❌');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
  } finally {
    print('\n═══════════════════════════════════════════════════════');
    print('🏁 TEST TAMAMLANDI');
    print('═══════════════════════════════════════════════════════\n');
  }
}
