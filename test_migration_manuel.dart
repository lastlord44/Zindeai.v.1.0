import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('\n🔥 MANUEL MIGRATION TEST - DÜZELTİLMİŞ KOD İLE');
  print('═' * 60);

  try {
    // 1. Hive başlat
    print('\n📦 1. Hive başlatılıyor...');
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
      print('✅ Adapter kaydedildi');
    }
    
    // 2. Box'ı aç
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('✅ Box açıldı\n');

    // 3. Şu anki durum
    print('📊 2. Mevcut durum:');
    print('   Toplam yemek: ${box.length}');
    
    if (box.length > 0) {
      print('\n⚠️  Veritabanında veri var! Önce temizleniyor...');
      await box.clear();
      print('✅ Veritabanı temizlendi\n');
    }

    // 4. Migration çalıştır
    print('🚀 3. Migration başlatılıyor (DÜZELTİLMİŞ KOD)...\n');
    final success = await YemekMigration.jsonToHiveMigration();
    
    print('\n═' * 60);
    print('📊 4. SONUÇ:');
    print('═' * 60);
    
    if (success) {
      final yemekSayisi = box.length;
      print('✅ Migration başarılı!');
      print('📊 Toplam yemek: $yemekSayisi');
      
      // Kategori dağılımı
      final kategoriler = <String, int>{};
      for (var yemek in box.values) {
        final kategori = yemek.category ?? 'Bilinmeyen';
        kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
      }
      
      print('\n📂 Kategori Dağılımı:');
      kategoriler.forEach((k, v) {
        print('   • $k: $v yemek');
      });
      
      // İlk 3 yemek örneği
      print('\n🍽️ İlk 3 Yemek Örneği:');
      final ilk3 = box.values.take(3).toList();
      for (var i = 0; i < ilk3.length; i++) {
        final y = ilk3[i];
        print('\n${i + 1}. ${y.mealName ?? "İsimsiz"}');
        print('   Kategori: ${y.category ?? "Yok"}');
        print('   Kalori: ${y.calorie ?? 0} kcal');
        print('   Protein: ${y.proteinG ?? 0}g');
        print('   Karb: ${y.carbG ?? 0}g');
        print('   Yağ: ${y.fatG ?? 0}g');
        
        if (y.calorie == null || y.calorie == 0) {
          print('   ❌ HATA: Kalori değeri 0!');
        } else {
          print('   ✅ Kalori değeri OK!');
        }
      }
    } else {
      print('❌ Migration başarısız!');
    }
    
    print('\n═' * 60);
    print('✅ Test tamamlandı!\n');
    
    await box.close();
    await Hive.close();
    
  } catch (e, stackTrace) {
    print('\n❌ HATA: $e');
    print('Stack Trace:\n$stackTrace');
  }
}
