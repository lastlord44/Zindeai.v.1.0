// ============================================================================
// test_alisveris_listesi_debug.dart
// ALIŞVERİŞ LİSTESİ DEBUG TESTİ
// ============================================================================

import 'lib/domain/services/haftalik_alisveris_servisi.dart';
import 'lib/domain/services/malzeme_parser_servisi.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('🛒 ALIŞVERİŞ LİSTESİ DEBUG TESTİ BAŞLATILIYOR...');
  
  try {
    // 1. Hive'i başlat
    await HiveService.init();
    print('✅ Hive başlatıldı');
    
    // 2. Bugünün planını al
    final bugun = DateTime.now();
    final plan = await HiveService.planGetir(bugun);
    
    if (plan == null) {
      print('❌ Bugün için plan bulunamadı!');
      print('💡 Önce plan oluşturun: flutter run && plan oluştur');
      return;
    }
    
    print('✅ Bugün için plan bulundu: ${plan.ogunler.length} öğün');
    
    // 3. Malzeme parser testi
    print('\n🔍 MALZEME PARSER TESTİ:');
    final testMalzemeler = [
      '2 yumurta',
      '100 gram tavuk göğsü',
      '1 dilim peynir',
      '1/2 su bardağı yoğurt',
      'tuz',
      'karabiber',
      '200ml süt',
    ];
    
    for (final malzeme in testMalzemeler) {
      final parsed = MalzemeParserServisi.parse(malzeme);
      if (parsed != null) {
        print('✅ "$malzeme" → ${parsed.besinAdi} (${parsed.miktar} ${parsed.birim})');
      } else {
        print('❌ "$malzeme" → Parse edilemedi');
      }
    }
    
    // 4. Plan malzemelerini kontrol et
    print('\n📋 PLAN MALZEMELERİ:');
    int toplamMalzeme = 0;
    
    for (final yemek in plan.ogunler) {
      print('\n🍽️ Yemek: ${yemek.ad}');
      print('   Malzemeler: ${yemek.malzemeler.length}');
      toplamMalzeme += yemek.malzemeler.length;
      
      if (yemek.malzemeler.isNotEmpty) {
        for (int i = 0; i < yemek.malzemeler.length; i++) {
          final malzeme = yemek.malzemeler[i];
          print('   $i. "$malzeme"');
          
          // Parse test
          final parsed = MalzemeParserServisi.parse(malzeme);
          if (parsed != null) {
            print('      ✅ Parse: ${parsed.besinAdi} (${parsed.miktar} ${parsed.birim})');
          } else {
            print('      ❌ Parse edilemedi');
          }
        }
      } else {
        print('   ⚠️ Bu yemeğin malzemeleri BOŞ!');
      }
    }
    
    print('\n📊 ÖZET:');
    print('Toplam yemek: ${plan.ogunler.length}');
    print('Toplam malzeme: $toplamMalzeme');
    
    // 5. Haftalık alışveriş listesi testi
    print('\n🛒 HAFTALIK ALIŞVERİŞ LİSTESİ TESTİ:');
    final haftaBaslangici = bugun.subtract(Duration(days: bugun.weekday - 1));
    
    try {
      final kullanici = await HiveService.kullaniciGetir();
      if (kullanici == null) {
        print('❌ Kullanıcı profili bulunamadı!');
        return;
      }
      
      final alisverisListesi = await HaftalikAlisverisServisi.haftalikAlisverisListesiOlustur(
        baslangicTarihi: haftaBaslangici,
        kullanici: kullanici,
      );
      
      print('✅ Alışveriş listesi oluşturuldu!');
      print('Toplam malzeme: ${alisverisListesi.toplamMalzemeSayisi}');
      print('Tahmini maliyet: ${alisverisListesi.toplamMaliyetTahmini.toStringAsFixed(0)}₺');
      print('Planlı gün: ${alisverisListesi.planliGunSayisi}');
      
      if (alisverisListesi.toplamMalzemeSayisi == 0) {
        print('❌ KRİTİK HATA: Alışveriş listesi BOŞ!');
        print('🔍 Bu sorunun nedenleri:');
        print('   1. Haftanın 7 gününde plan bulunmuyor');
        print('   2. Planların malzemeleri boş');
        print('   3. Malzeme parser çalışmıyor');
        print('   4. Hive box\'ları boş');
      } else {
        print('✅ Alışveriş listesi dolu!');
        
        // İlk 5 malzemeyi göster
        print('\n📋 İlk 5 malzeme:');
        int sayac = 0;
        for (final bolum in alisverisListesi.marketBolumleri.values) {
          for (final malzeme in bolum) {
            if (sayac < 5) {
              print('   ${sayac + 1}. ${malzeme.ad} (${malzeme.miktar} ${malzeme.birim}) - ${malzeme.toplamMaliyet.toStringAsFixed(1)}₺');
              sayac++;
            }
          }
          if (sayac >= 5) break;
        }
      }
      
    } catch (e, stackTrace) {
      print('❌ Alışveriş listesi oluşturma hatası: $e');
      print('Stack trace: $stackTrace');
    }
    
  } catch (e, stackTrace) {
    print('❌ Genel hata: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n🏁 TEST BİTTİ');
}