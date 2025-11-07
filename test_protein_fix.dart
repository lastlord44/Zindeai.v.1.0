// 🔥 PROTEİN SORUNU TEST SCRIPT
// Kahvaltı protein değerlerini test et

import 'dart:math';
import 'lib/domain/services/ai_beslenme_servisi.dart';
import 'lib/domain/entities/gunluk_plan.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('🔥 PROTEİN SORUNU TEST BAŞLADI');
  
  // Test parametreleri (kullanıcının profili)
  final hedefKalori = 2000.0;
  final hedefProtein = 100.0; // 100g protein hedef
  final hedefKarb = 250.0;
  final hedefYag = 67.0;
  
  final aiService = AIBeslenmeServisi();
  
  // 5 farklı günlük plan oluştur ve protein değerlerini kontrol et
  for (int i = 1; i <= 5; i++) {
    print('\n--- TEST $i ---');
    
    final testTarihi = DateTime.now().add(Duration(days: i));
    
    try {
      final plan = await aiService.gunlukPlanOlustur(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: testTarihi,
      );
      
      print('✅ Plan ${i} oluşturuldu:');
      print('   Kahvaltı: ${plan.kahvalti?.ad ?? "YOK"}');
      print('   Kahvaltı Protein: ${plan.kahvalti?.protein.toStringAsFixed(1) ?? "0"}g');
      print('   Toplam Protein: ${plan.toplamProtein.toStringAsFixed(1)}g');
      print('   Protein Sapma: ${plan.proteinSapmaYuzdesi.toStringAsFixed(1)}%');
      
      // Kritik kontrol: Kahvaltı protein normalliği
      if (plan.kahvalti != null) {
        if (plan.kahvalti!.protein > 30) {
          print('❌ PROTEİN BOMBASI TESPİT EDİLDİ!');
          print('   Kahvaltı malzemeleri:');
          for (final malzeme in plan.kahvalti!.malzemeler) {
            print('     - $malzeme');
          }
        } else if (plan.kahvalti!.protein >= 15 && plan.kahvalti!.protein <= 25) {
          print('✅ Kahvaltı protein değeri NORMAL aralıkta');
        } else if (plan.kahvalti!.protein < 15) {
          print('⚠️ Kahvaltı protein değeri düşük');
        }
      }
      
    } catch (e) {
      print('❌ Test $i başarısız: $e');
    }
  }
  
  print('\n🎯 PROTEİN SORUNU TEST TAMAMLANDI');
}