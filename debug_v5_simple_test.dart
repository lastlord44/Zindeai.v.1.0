// V5.1 SIMPLE DEBUG TEST
import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/services/ai_beslenme_servisi_v5.dart';
import 'lib/domain/entities/hedef.dart';

Future<void> main() async {
  print('🎯 V5.1 SİMPLE DEBUG TEST BAŞLIYOR...\n');
  
  try {
    // Hive setup
    Hive.init('./hive_data');
    await Hive.openBox('yemekler');
    
    print('📊 DB DURUMU:');
    final yemekSayisi = await HiveService.yemekSayisi();
    print('   Toplam yemek: $yemekSayisi');
    
    final tumYemekler = await HiveService.tumYemekleriGetir();
    print('   Entity yemek: ${tumYemekler.length}');
    
    if (tumYemekler.isEmpty) {
      print('❌ DB BOŞ! Migration çalışmamış.');
      exit(1);
    }
    
    print('\n🔥 V5.1 AI SERVİS TESTİ:');
    final aiService = AIBeslenmeServisiV5();
    
    // Basit profil
    final plan = await aiService.gunlukPlanOlustur(
      hedefKalori: 1800.0,
      hedefProtein: 135.0,
      hedefKarb: 180.0,
      hedefYag: 80.0,
      hedef: Hedef.kiloVermek,
      tarih: DateTime.now(),
    );
    
    print('✅ PLAN OLUŞTURULDU:');
    print('   Kahvaltı: ${plan.kahvalti?.ad ?? "YOK"}');
    print('   Öğle: ${plan.ogleYemegi?.ad ?? "YOK"}');
    print('   Akşam: ${plan.aksamYemegi?.ad ?? "YOK"}');
    
    // Türk kahvaltı kontrolü
    final kahvalti = plan.kahvalti;
    if (kahvalti != null) {
      final problematikMi = 
        kahvalti.ad.toLowerCase().contains('ton balığı') ||
        kahvalti.ad.toLowerCase().contains('tavuk göğsü') ||
        kahvalti.ad.toLowerCase().contains('biftek') ||
        kahvalti.ad.toLowerCase().contains('somon');
        
      if (problematikMi) {
        print('🚨 TÜRK KAHVALTI SORUNU: ${kahvalti.ad}');
      } else {
        print('🇹🇷 TÜRK KAHVALTISI UYGUN: ${kahvalti.ad}');
      }
    }
    
    print('\n🎉 V5.1 TEST BAŞARILI!');
    
  } catch (e, stack) {
    print('❌ HATA: $e');
    print('Stack: $stack');
  } finally {
    await Hive.close();
  }
}