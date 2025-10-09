import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n🧹 Hive Temizleme ve Yeniden Yükleme Başlıyor...\n');
  
  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());
  Hive.registerAdapter(KullaniciHiveModelAdapter());
  Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  
  try {
    // 1. TÜM BOX'LARI AÇ
    print('📦 Box\'lar açılıyor...');
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
    final kullaniciBox = await Hive.openBox<KullaniciHiveModel>('kullanici');
    final planlBox = await Hive.openBox<GunlukPlanHiveModel>('gunluk_planlar');
    final tamamlananBox = await Hive.openBox('tamamlanan_ogunler');
    
    print('✅ Box\'lar açıldı');
    print('   - Mevcut yemek sayısı: ${yemekBox.length}');
    print('   - Mevcut plan sayısı: ${planlBox.length}');
    
    // 2. SADECE YEMEK VE PLAN BOX'LARINI TEMİZLE (kullanıcı profilini koru!)
    print('\n🧹 Temizlik yapılıyor...');
    await yemekBox.clear();
    await planlBox.clear();
    await tamamlananBox.clear();
    print('✅ Yemekler, planlar ve tamamlanan öğünler temizlendi');
    
    // 3. YENİDEN YÜKLE (GÜNCELLENMİŞ MİGRATİON İLE)
    print('\n📥 Yeniden yükleme başlıyor...');
    print('   (Bu işlem 30-60 saniye sürebilir...)\n');
    
    await YemekMigration.jsonToHiveMigration();
    
    print('\n✅ Migration tamamlandı!');
    
    // 4. KONTROL ET
    print('\n📊 Yeni Durum:');
    print('   - Toplam yemek: ${yemekBox.length}');
    
    final araOgun2Sayisi = yemekBox.values.where((y) => 
      y.toEntity().ogun.toString() == 'OgunTipi.araOgun2'
    ).length;
    print('   - Ara Öğün 2 sayısı: $araOgun2Sayisi');
    
    // İlk birkaç Ara Öğün 2'yi göster
    print('\n📋 Örnek Ara Öğün 2 yemekleri:');
    final araOgun2Ornekleri = yemekBox.values
        .where((y) => y.toEntity().ogun.toString() == 'OgunTipi.araOgun2')
        .take(3);
    
    for (final yemek in araOgun2Ornekleri) {
      final entity = yemek.toEntity();
      print('   • ${entity.ad}');
      print('     Kalori: ${entity.kalori.toInt()} kcal | '
            'P: ${entity.protein.toInt()}g | '
            'K: ${entity.karbonhidrat.toInt()}g | '
            'Y: ${entity.yag.toInt()}g');
    }
    
    // Box'ları kapat
    await yemekBox.close();
    await kullaniciBox.close();
    await planlBox.close();
    await tamamlananBox.close();
    
    print('\n✅ İŞLEM TAMAMLANDI!');
    print('🚀 Şimdi uygulamayı başlatabilirsin: flutter run');
    print('\n');
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print(stackTrace);
  }
}
