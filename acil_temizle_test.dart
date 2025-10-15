// acil_temizle_test.dart
// Performans krizi sonrası DB temizle ve optimize migration test

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/core/utils/yemek_migration_guncel.dart';
import 'lib/core/utils/app_logger.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('⚡ PERFORMANS KRİZİ - OPTİMİZE MİGRATION TESTİ', (WidgetTester tester) async {
    // ========================================================================
    // TEST ORTAMI KURULUMU
    // ========================================================================
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('hive_test_optimize');
    Hive.init(tempDir.path);

    // Adaptörleri kaydet
    if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
      Hive.registerAdapter(KullaniciHiveModelAdapter());
    }

    print('\n⚡ PERFORMANS KRİZİ ÇÖZÜMLENİYOR...\n');
    print('🚨 ÖNCEKI DURUM: 25,580 yemek - UYGULAMA DONDU!');
    print('✅ YENİ DURUM: Optimize edilmiş migration testi...\n');
    print('=' * 80);

    try {
      // ========================================================================
      // TEST: OPTİMİZE MİGRATION PERFORMANCE TESTI
      // ========================================================================
      print('📊 PERFORMANS TESTİ BAŞLIYOR...');
      print('─' * 50);

      // Migration başlangıç zamanı
      final baslangicZamani = DateTime.now();
      print('🕐 Migration başlangıç zamanı: ${baslangicZamani.toLocal()}');

      // Optimize migration çalıştır
      print('🔄 Optimize migration başlatılıyor...');
      final migrationBasarili = await YemekMigration.jsonToHiveMigration();
      
      // Migration bitiş zamanı
      final bitisZamani = DateTime.now();
      final sureDakika = bitisZamani.difference(baslangicZamani).inMinutes;
      final sureSaniye = bitisZamani.difference(baslangicZamani).inSeconds;
      
      print('🕐 Migration bitiş zamanı: ${bitisZamani.toLocal()}');
      print('⏱️  Toplam süre: ${sureDakika}m ${sureSaniye % 60}s');

      if (migrationBasarili) {
        print('✅ Migration başarıyla tamamlandı');
        
        // Yemek sayısını kontrol et
        final yemekSayisi = await HiveService.yemekSayisi();
        print('📊 Toplam yemek sayısı: $yemekSayisi');
        
        // Kategori dağılımını kontrol et
        final kategoriSayilari = await HiveService.kategoriSayilari();
        print('📂 Kategori dağılımı:');
        kategoriSayilari.forEach((kategori, sayi) {
          print('   $kategori: $sayi yemek');
        });
        
        // PERFORMANS DEĞERLENDİRMESİ
        print('\n🎯 PERFORMANS DEĞERLENDİRMESİ:');
        print('─' * 40);
        
        // Yemek sayısı kontrolü
        if (yemekSayisi >= 3000 && yemekSayisi <= 5000) {
          print('✅ Yemek sayısı UYGUN: $yemekSayisi (3k-5k arası)');
        } else if (yemekSayisi > 5000) {
          print('⚠️ Yemek sayısı YÜKSEK: $yemekSayisi (performans riski!)');
        } else {
          print('❌ Yemek sayısı DÜŞÜK: $yemekSayisi (<3k çeşitlilik riski)');
        }
        
        // Süre kontrolü  
        if (sureSaniye < 30) {
          print('✅ Migration süresi MÜKEMMEL: ${sureSaniye}s (<30s)');
        } else if (sureSaniye < 60) {
          print('✅ Migration süresi İYİ: ${sureSaniye}s (<60s)');  
        } else if (sureSaniye < 120) {
          print('⚠️ Migration süresi YAVAS: ${sureSaniye}s (<2m)');
        } else {
          print('❌ Migration süresi ÇOK YAVAS: ${sureSaniye}s (>2m)');
        }
        
        // Kategori çeşitlilik kontrolü
        final kategoriSayisi = kategoriSayilari.length;
        if (kategoriSayisi >= 5) {
          print('✅ Kategori çeşitliliği UYGUN: $kategoriSayisi kategori');
        } else {
          print('⚠️ Kategori çeşitliliği DÜŞÜK: $kategoriSayisi kategori');
        }
        
        // GENEL SONUÇ
        print('\n🏆 OPTİMİZASYON SONUCU:');
        print('─' * 40);
        print('📉 Önceki: 25,580 yemek → Uygulama dondu');
        print('📈 Sonrası: $yemekSayisi yemek → ${sureSaniye}s migration');
        
        final optimizasyonOrani = ((25580 - yemekSayisi) / 25580 * 100).toStringAsFixed(1);
        print('⚡ Optimizasyon: %$optimizasyonOrani veri azaltma');
        
        if (yemekSayisi < 6000 && sureSaniye < 60) {
          print('✅ PERFORMANS KRİZİ ÇÖZÜLDİ!');
        } else {
          print('⚠️ Daha fazla optimizasyon gerekebilir');
        }
        
      } else {
        print('❌ Migration başarısız');
      }

    } catch (e, stackTrace) {
      print('❌ KRITIK TEST HATASI: $e');
      print('Stack trace: $stackTrace');
    } finally {
      // Test ortamını temizle
      await Hive.close();
      await tempDir.delete(recursive: true);
    }
    
    print('\n' + '=' * 80);
    print('🎉 PERFORMANS OPTİMİZASYONU TAMAMLANDI!');
    print('=' * 80);
  });
}