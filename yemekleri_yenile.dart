import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n🔄 Yemek Veritabanını Yenileme Başlıyor...\n');
  
  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());
  Hive.registerAdapter(KullaniciHiveModelAdapter());
  Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  
  try {
    // 1. Box'ları aç
    print('📦 Box\'lar açılıyor...');
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemek_box');
    final planBox = await Hive.openBox<GunlukPlanHiveModel>('planlar_box');
    
    print('✅ Box\'lar açıldı');
    print('   - Mevcut yemek sayısı: ${yemekBox.length}');
    print('   - Mevcut plan sayısı: ${planBox.length}');
    
    // 2. SADECE YEMEK BOX'INI TEMİZLE (planları ve kullanıcıyı koru!)
    print('\n🧹 Sadece yemek veritabanı temizleniyor...');
    await yemekBox.clear();
    print('✅ ${yemekBox.length} yemek kaldı (temizlendi)');
    
    // 3. YENİDEN YÜKLE (GÜNCELLENMİŞ MİGRATİON İLE)
    print('\n📥 Yeni yemekler yükleniyor...');
    print('   (Bu işlem 30-60 saniye sürebilir...)\n');
    
    await YemekMigration.jsonToHiveMigration();
    
    print('\n✅ Migration tamamlandı!');
    print('   - Yeni yemek sayısı: ${yemekBox.length}');
    
    // 4. ARA ÖĞÜN 2 KONTROLÜ
    print('\n📋 Ara Öğün 2 kontrol ediliyor...');
    final araOgun2Sayisi = yemekBox.values.where((y) => 
      y.toEntity().ogun.toString() == 'OgunTipi.araOgun2'
    ).length;
    print('   - Ara Öğün 2 sayısı: $araOgun2Sayisi');
    
    // İlk birkaç Ara Öğün 2'yi göster
    final araOgun2Ornekleri = yemekBox.values
        .where((y) => y.toEntity().ogun.toString() == 'OgunTipi.araOgun2')
        .take(3);
    
    print('\n📋 Örnek Ara Öğün 2 yemekleri:');
    for (final yemek in araOgun2Ornekleri) {
      final entity = yemek.toEntity();
      print('   • ${entity.ad}');
      print('     Kalori: ${entity.kalori.toInt()} kcal | '
            'P: ${entity.protein.toInt()}g | '
            'K: ${entity.karbonhidrat.toInt()}g | '
            'Y: ${entity.yag.toInt()}g');
    }
    
    // 5. PLANLAR KALSIN (kullanıcı planlarını kaybetmemeli)
    print('\n📅 Mevcut planlar korundu: ${planBox.length} plan');
    
    // Box'ları kapat
    await yemekBox.close();
    await planBox.close();
    
    print('\n✅ İŞLEM TAMAMLANDI!');
    print('📝 Planlar silinmedi - sadece yemek veritabanı yenilendi');
    print('🚀 Şimdi uygulamayı başlatabilirsin: flutter run');
    print('\n');
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print(stackTrace);
  }
}
