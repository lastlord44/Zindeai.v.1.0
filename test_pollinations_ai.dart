// Test: Pollinations AI Servisi
// Gerçek AI response'unu test ediyoruz

import 'dart:io';
import 'lib/core/services/pollinations_ai_service.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('🔬 POLLINATIONS AI TEST BAŞLIYOR...\n');
  
  // Test parametreleri (gerçekçi değerler)
  final testKalori = 3000.0;
  final testProtein = 160.0;
  final testKarb = 400.0;
  final testYag = 85.0;
  
  print('📊 TEST PARAMETRELERİ:');
  print('   Kalori: ${testKalori.toInt()} kcal');
  print('   Protein: ${testProtein.toInt()}g');
  print('   Karbonhidrat: ${testKarb.toInt()}g');
  print('   Yağ: ${testYag.toInt()}g\n');
  
  print('🚀 Pollinations AI\'ye istek gönderiliyor...\n');
  
  try {
    final startTime = DateTime.now();
    
    // API çağrısı
    final response = await PollinationsAIService.getGunlukFullPlan(
      gunlukKalori: testKalori,
      gunlukProtein: testProtein,
      gunlukKarb: testKarb,
      gunlukYag: testYag,
    );
    
    final duration = DateTime.now().difference(startTime);
    
    print('⏱️  Süre: ${duration.inMilliseconds}ms\n');
    
    if (response == null) {
      print('❌ HATA: API null response döndürdü!');
      print('   Olası sebepler:');
      print('   - API limiti');
      print('   - Geçici downtime');
      print('   - Network hatası');
      exit(1);
    }
    
    print('✅ API RESPONSE ALINDI!\n');
    print('📝 RESPONSE (ilk 500 karakter):');
    print('─' * 60);
    print(response.substring(0, response.length > 500 ? 500 : response.length));
    print('─' * 60);
    print('\n📏 Toplam uzunluk: ${response.length} karakter\n');
    
    // JSON kontrolü
    if (response.contains('{') && response.contains('}')) {
      print('✅ JSON formatı tespit edildi');
      
      // Öğün kontrolü
      final ogunler = ['kahvalti', 'ara_ogun_1', 'ogle', 'ara_ogun_2', 'aksam'];
      for (final ogun in ogunler) {
        if (response.contains(ogun)) {
          print('   ✓ $ogun bulundu');
        } else {
          print('   ✗ $ogun BULUNAMADI!');
        }
      }
      
      // Makro kontrolü
      if (response.contains('kalori') && 
          response.contains('protein') &&
          response.contains('karbonhidrat') &&
          response.contains('yag')) {
        print('   ✓ Makro alanları mevcut');
      }
      
      // Yasaklı yemek kontrolü
      final yasaklilar = ['yulaflı smoothie', 'tavuklu pirinç', 'ton balıklı salata'];
      print('\n🚫 Yasaklı Yemek Kontrolü:');
      for (final yasak in yasaklilar) {
        if (response.toLowerCase().contains(yasak.toLowerCase())) {
          print('   ⚠️  UYARI: "$yasak" bulundu! (Yasaklı liste)');
        } else {
          print('   ✓ "$yasak" yok');
        }
      }
      
    } else {
      print('⚠️  JSON formatı tespit EDİLEMEDİ!');
      print('   Response metin formatında olabilir.');
    }
    
    print('\n' + '=' * 60);
    print('✅ TEST BAŞARILI!');
    print('=' * 60);
    
  } catch (e, stackTrace) {
    print('❌ TEST BAŞARISIZ!\n');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
    exit(1);
  }
}