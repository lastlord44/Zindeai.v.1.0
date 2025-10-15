// migration_karb_yemekler_yukle.dart
// Yüksek karbonhidratlı Türk yemeklerini Hive DB'ye yükle

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/core/utils/app_logger.dart';

import 'package:flutter_test/flutter_test.dart'; // flutter_test import'u eklendi

void main() {
  testWidgets('Karbonhidrat Yemekleri Yükleme Testi', (WidgetTester tester) async {
    // ========================================================================
    // TEST ORTAMI İÇİN KURULUM
    // ========================================================================
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('hive_test_karb_yukle');
    Hive.init(tempDir.path); // Hive.initFlutter yerine Hive.init kullanıldı

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
    // ========================================================================

    print('🚀 KARBONHİDRAT YEMEKLERI YÜKLEME BAŞLIYOR...\n');
    
    try {
      // Box'ı aç
      final yemekBox = await Hive.openBox<YemekHiveModel>('yemek_box');
      
      print('📦 Yemek Box açıldı. Mevcut yemek sayısı: ${yemekBox.length}\n');
      
      // JSON dosyalarını yükle
      final jsonFiles = [
        'assets/data/kahvalti_yuksek_karb_50.json',
      ];
      
      int toplamYuklenen = 0;
      
      for (final jsonPath in jsonFiles) {
        final file = File(jsonPath);
        
        if (!await file.exists()) {
          print('⚠️  $jsonPath dosyası bulunamadı, atlanıyor...');
          continue;
        }
        
        print('📄 $jsonPath dosyası okunuyor...');
        
        final jsonString = await file.readAsString();
        final List<dynamic> yemekListesi = json.decode(jsonString);
        
        int yuklenenSayi = 0;
        
        for (final yemekJson in yemekListesi) {
          try {
            final yemekModel = YemekHiveModel.fromJson(yemekJson as Map<String, dynamic>);
            
            // ID'ye göre kaydet (duplicate önlemek için)
            await yemekBox.put(yemekModel.mealId!, yemekModel);
            yuklenenSayi++;
            
            if (yuklenenSayi % 10 == 0) {
              print('   ✅ $yuklenenSayi yemek yüklendi...');
            }
          } catch (e) {
            print('   ❌ Yemek yüklenirken hata: ${yemekJson['ad']} - $e');
          }
        }
        
        print('✅ $jsonPath: $yuklenenSayi yemek başarıyla yüklendi\n');
        toplamYuklenen += yuklenenSayi;
      }
      
      print('=' * 60);
      print('🎉 MİGRATION TAMAMLANDI!');
      print('   Toplam yüklenen yemek: $toplamYuklenen');
      print('   DB\'deki toplam yemek: ${yemekBox.length}');
      print('=' * 60);
      
      await yemekBox.close();
      
    } catch (e, stackTrace) {
      print('❌ KRITIK HATA: $e');
      print('Stack trace: $stackTrace');
    } finally {
      // Test ortamı için Hive'ı kapat ve geçici dizini sil
      await Hive.close();
      await tempDir.delete(recursive: true);
    }
  });
}