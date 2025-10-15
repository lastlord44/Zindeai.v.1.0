import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  print('🔥 MEGA YEMEK MIGRATION TEST BAŞLATILIYOR...\n');

  try {
    // 1. Hive'ı başlat
    print('📦 Hive başlatılıyor...');
    final dir = Directory.current.path;
    Hive.init('$dir/hive_data');
    
    // Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    await HiveService.init();
    print('✅ Hive başlatıldı\n');

    // 2. Eski DB'yi temizle
    print('🗑️ Eski veritabanı temizleniyor...');
    await YemekMigration.migrationTemizle();
    
    final oncekiSayi = await HiveService.yemekSayisi();
    print('✅ Temizlendi - Mevcut yemek sayısı: $oncekiSayi\n');

    // 3. MEGA yemekleri yükle
    print('🚀 MEGA YEMEKLER yükleniyor...');
    final basarili = await YemekMigration.jsonToHiveMigration();
    
    if (!basarili) {
      print('❌ Migration başarısız!');
      exit(1);
    }

    // 4. Sonuçları göster
    print('\n' + '='*60);
    print('📊 MIGRATION SONUÇLARI');
    print('='*60);
    
    final toplamYemek = await HiveService.yemekSayisi();
    final kategoriSayilari = await HiveService.kategoriSayilari();
    
    print('\n🎯 Toplam Yemek Sayısı: $toplamYemek');
    print('\n📂 Kategori Dağılımı:');
    kategoriSayilari.forEach((kategori, sayi) {
      print('   $kategori: $sayi yemek');
    });
    
    print('\n' + '='*60);
    
    // 5. Beklenen değerlerle karşılaştır
    print('\n🔍 DOĞRULAMA:');
    final beklenenMin = 2000; // En az 2000 yemek olmalı
    if (toplamYemek >= beklenenMin) {
      print('✅ Başarılı! $toplamYemek yemek yüklendi (Beklenen: ${beklenenMin}+)');
    } else {
      print('⚠️ Uyarı! Sadece $toplamYemek yemek yüklendi (Beklenen: ${beklenenMin}+)');
    }
    
    // 6. Hive'ı kapat
    await Hive.close();
    print('\n✅ Migration tamamlandı!');
    
  } catch (e, stackTrace) {
    print('\n❌ HATA: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
