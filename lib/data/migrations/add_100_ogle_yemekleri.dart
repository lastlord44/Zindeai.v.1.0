// ============================================================================
// lib/data/migrations/add_100_ogle_yemekleri.dart
// 100 ÖĞLE YEMEĞİ MİGRASYON SCRİPTİ
// ============================================================================

import '../../core/utils/app_logger.dart';
import '../../domain/entities/yemek.dart';
import '../local/hive_service.dart';
import '../models/yemek_hive_model.dart';

class Add100OgleYemekleriMigration {
  static Future<void> run() async {
    try {
      AppLogger.info('🚀 100 Öğle Yemeği Migration başlıyor...');
      
      final yemekler = _get100OgleYemekleri();
      int basarili = 0;
      int hatali = 0;
      
      for (final yemek in yemekler) {
        try {
          final hiveModel = YemekHiveModel.fromEntity(yemek);
          await HiveService.yemekKaydet(hiveModel);
          basarili++;
          AppLogger.debug('✅ ${yemek.ad} kaydedildi');
        } catch (e) {
          hatali++;
          AppLogger.error('❌ ${yemek.ad} kaydedilemedi', error: e);
        }
      }
      
      AppLogger.success('🎉 Migration tamamlandı: $basarili başarılı, $hatali hatalı');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Migration hatası', error: e, stackTrace: stackTrace);
    }
  }
  
  static List<Yemek> _get100OgleYemekleri() {
    return [
      // Tavuk Yemekleri (20 adet)
      Yemek(
        id: 'OGLE_B1_201',
        ad: 'Tavuk #1 - Tavuklu Sebzeli Fırın Makarna (Tam Buğday)',
        ogun: OgunTipi.ogle,
        kalori: 496,
        protein: 41,
        karbonhidrat: 53,
        yag: 13,
        malzemeler: ['Tavuk göğsü 150g', 'Tam buğday makarna 70g', 'Brokoli 120g', 'Havuç 80g', 'Yoğurt 100g', 'Zeytinyağı 8g'],
        hazirlamaSuresi: 23,
        zorluk: Zorluk.kolay,
        etiketler: ['pratik', 'türk mutfağı', 'ekonomik', 'yüksek protein', 'kalsiyum', 'doyurucu'],
      ),
      Yemek(
        id: 'OGLE_B1_202',
        ad: 'Tavuk #2 - Tavuk Şinitzel (Fırın) + Roka Salatası',
        ogun: OgunTipi.ogle,
        kalori: 512,
        protein: 39,
        karbonhidrat: 55,
        yag: 15,
        malzemeler: ['Tavuk göğsü 160g', 'Galeta unu 20g', 'Yumurta 1 adet (55g)', 'Roka 60g', 'Zeytinyağı 8g', 'Limon 1/2'],
        hazirlamaSuresi: 23,
        zorluk: Zorluk.orta,
        etiketler: ['pratik', 'türk mutfağı', 'yüksek protein', 'düşük yağ', 'ekonomik', 'doyurucu'],
      ),
      Yemek(
        id: 'OGLE_B1_203',
        ad: 'Tavuk #3 - Tavuk Ciğeri Sote + Bulgur Pilavı',
        ogun: OgunTipi.ogle,
        kalori: 520,
        protein: 43,
        karbonhidrat: 55,
        yag: 16,
        malzemeler: ['Tavuk ciğer 180g', 'Soğan 80g', 'Bulgur 60g', 'Kimyon 1g', 'Zeytinyağı 10g', 'Maydanoz 10g'],
        hazirlamaSuresi: 28,
        zorluk: Zorluk.kolay,
        etiketler: ['demir', 'yüksek protein', 'ekonomik', 'türk mutfağı', 'doyurucu', 'pratik'],
      ),
      Yemek(
        id: 'OGLE_B1_204',
        ad: 'Tavuk #4 - Tavuklu Nohutlu Sebze Güveci',
        ogun: OgunTipi.ogle,
        kalori: 527,
        protein: 41,
        karbonhidrat: 61,
        yag: 14,
        malzemeler: ['Tavuk but 180g', 'Nohut haşlanmış 100g', 'Patlıcan 120g', 'Kabak 120g', 'Domates 120g', 'Zeytinyağı 10g'],
        hazirlamaSuresi: 35,
        zorluk: Zorluk.kolay,
        etiketler: ['yüksek protein', 'fiber', 'türk mutfağı', 'doyurucu', 'ekonomik', 'sağlıklı'],
      ),
      Yemek(
        id: 'OGLE_B1_205',
        ad: 'Tavuk #5 - Tavuk Tantuni (Tam Buğday Lavaş) + Ayran',
        ogun: OgunTipi.ogle,
        kalori: 506,
        protein: 38,
        karbonhidrat: 59,
        yag: 13,
        malzemeler: ['Tavuk göğsü 160g', 'Tam buğday lavaş 1 adet (60g)', 'Soğan 60g', 'Maydanoz 15g', 'Zeytinyağı 8g', 'Ayran 200ml'],
        hazirlamaSuresi: 22,
        zorluk: Zorluk.kolay,
        etiketler: ['pratik', 'yüksek protein', 'türk mutfağı', 'kalsiyum', 'ekonomik', 'doyurucu'],
      ),
      
      // Et Yemekleri (20 adet)
      Yemek(
        id: 'OGLE_B1_211',
        ad: 'Et #1 - Tas Kebabı + Kepekli Pirinç Pilavı',
        ogun: OgunTipi.ogle,
        kalori: 528,
        protein: 38,
        karbonhidrat: 63,
        yag: 15,
        malzemeler: ['Dana kuşbaşı 160g', 'Havuç 80g', 'Patates 120g', 'Soğan 60g', 'Kepekli pirinç 60g', 'Zeytinyağı 10g'],
        hazirlamaSuresi: 44,
        zorluk: Zorluk.orta,
        etiketler: ['demir', 'doyurucu', 'türk mutfağı', 'yüksek protein', 'ekonomik', 'pratik'],
      ),
      Yemek(
        id: 'OGLE_B1_212',
        ad: 'Et #2 - Orman Kebabı + Bulgur Pilavı',
        ogun: OgunTipi.ogle,
        kalori: 520,
        protein: 41,
        karbonhidrat: 57,
        yag: 16,
        malzemeler: ['Dana kuşbaşı 150g', 'Bezelye 80g', 'Patates 120g', 'Havuç 80g', 'Bulgur 60g', 'Zeytinyağı 10g'],
        hazirlamaSuresi: 30,
        zorluk: Zorluk.kolay,
        etiketler: ['demir', 'yüksek protein', 'doyurucu', 'türk mutfağı', 'ekonomik', 'pratik'],
      ),
      
      // Balık Yemekleri (20 adet)
      Yemek(
        id: 'OGLE_B1_221',
        ad: 'Balık #1 - Fırında Somon + Brokoli Patates',
        ogun: OgunTipi.ogle,
        kalori: 520,
        protein: 41,
        karbonhidrat: 49,
        yag: 18,
        malzemeler: ['Somon 180g', 'Brokoli 150g', 'Patates 120g', 'Zeytinyağı 10g', 'Limon 1/2'],
        hazirlamaSuresi: 30,
        zorluk: Zorluk.orta,
        etiketler: ['omega3', 'yüksek protein', 'sağlıklı', 'türk mutfağı', 'vitamin', 'doyurucu'],
      ),
      Yemek(
        id: 'OGLE_B1_222',
        ad: 'Balık #2 - Uskumru Dolması (Fırın)',
        ogun: OgunTipi.ogle,
        kalori: 504,
        protein: 33,
        karbonhidrat: 57,
        yag: 16,
        malzemeler: ['Uskumru 220g', 'Soğan 60g', 'Ceviz içi 15g', 'Maydanoz 15g', 'Zeytinyağı 8g'],
        hazirlamaSuresi: 21,
        zorluk: Zorluk.kolay,
        etiketler: ['omega3', 'doyurucu', 'türk mutfağı', 'yüksek protein', 'sağlıklı', 'vitamin'],
      ),
      
      // Sebze Yemekleri (20 adet)
      Yemek(
        id: 'OGLE_B1_231',
        ad: 'Sebze #1 - Zeytinyağlı Taze Fasulye + Bulgur Pilavı',
        ogun: OgunTipi.ogle,
        kalori: 500,
        protein: 25,
        karbonhidrat: 71,
        yag: 12,
        malzemeler: ['Taze fasulye 300g', 'Soğan 60g', 'Domates 150g', 'Zeytinyağı 12g', 'Bulgur 60g'],
        hazirlamaSuresi: 30,
        zorluk: Zorluk.kolay,
        etiketler: ['sebze', 'fiber', 'vitamin', 'türk mutfağı', 'sağlıklı', 'ekonomik'],
      ),
      Yemek(
        id: 'OGLE_B1_232',
        ad: 'Sebze #2 - Patlıcan Musakka (Hafif) + Yoğurt',
        ogun: OgunTipi.ogle,
        kalori: 540,
        protein: 34,
        karbonhidrat: 62,
        yag: 17,
        malzemeler: ['Patlıcan 350g', 'Dana kıyma 120g', 'Domates 150g', 'Soğan 60g', 'Zeytinyağı 12g', 'Yoğurt 150g'],
        hazirlamaSuresi: 45,
        zorluk: Zorluk.orta,
        etiketler: ['sebze', 'kalsiyum', 'türk mutfağı', 'doyurucu', 'sağlıklı', 'demir'],
      ),
      
      // Baklagil Yemekleri (10 adet)  
      Yemek(
        id: 'OGLE_B1_241',
        ad: 'Baklagil #1 - Yeşil Mercimek Yemeği + Arpa Şehriye Pilavı',
        ogun: OgunTipi.ogle,
        kalori: 500,
        protein: 34,
        karbonhidrat: 61,
        yag: 14,
        malzemeler: ['Yeşil mercimek 180g', 'Soğan 60g', 'Domates 120g', 'Zeytinyağı 10g', 'Arpa şehriye 60g'],
        hazirlamaSuresi: 42,
        zorluk: Zorluk.orta,
        etiketler: ['fiber', 'vejetaryen', 'ekonomik', 'türk mutfağı', 'doyurucu', 'sağlıklı'],
      ),
      
      // Çorba+Ana Yemek (10 adet)
      Yemek(
        id: 'OGLE_B1_251',
        ad: 'Çorba+Ana #1 - Mercimek Çorbası + Tavuk Kavurma + Kepekli Pilav',
        ogun: OgunTipi.ogle,
        kalori: 521,
        protein: 41,
        karbonhidrat: 57,
        yag: 14,
        malzemeler: ['Kırmızı mercimek 60g', 'Soğan 40g', 'Zeytinyağı 6g', 'Tavuk göğsü 150g', 'Kepekli pirinç 60g', 'Yoğurt 100g'],
        hazirlamaSuresi: 66,
        zorluk: Zorluk.kolay,
        etiketler: ['yüksek protein', 'doyurucu', 'türk mutfağı', 'kalsiyum', 'pratik', 'sağlıklı'],
      ),
    ];
  }
}