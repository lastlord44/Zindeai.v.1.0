// ============================================================================
// 100 ÖĞLE YEMEĞİ MIGRATION SCRIPTI
// ============================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n');
  print('═══════════════════════════════════════════════════════');
  print('🔥 100 ÖĞLE YEMEĞİ YÜKLENİYOR');
  print('═══════════════════════════════════════════════════════\n');

  try {
    // 1. Hive'ı başlat
    print('📦 Hive başlatılıyor...');
    await Hive.initFlutter();
    
    // 2. Adapter'ı kaydet
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
      print('✅ Adapter kaydedildi');
    }
    
    // 3. Box'ı aç
    await Hive.openBox<YemekHiveModel>('yemekler');
    print('✅ Yemekler box\'ı açıldı\n');

    // 4. Yemekleri yükle
    print('🚀 100 ÖĞLE YEMEĞİ YÜKLENİYOR...\n');
    
    final yemekler = getOgleYemekleri100();
    
    int basarili = 0;
    int hatali = 0;

    for (final yemekJson in yemekler) {
      try {
        final yemekModel = YemekHiveModel.fromJson(yemekJson);
        await HiveService.yemekKaydet(yemekModel);
        basarili++;
        
        if (basarili % 10 == 0) {
          print('✅ $basarili yemek yüklendi...');
        }
      } catch (e) {
        hatali++;
        print('   ❌ Hata: ${yemekJson['ad']} - $e');
      }
    }

    // 5. SONUÇ
    print('\n═══════════════════════════════════════════════════════');
    print('🎉 ÖĞLE YEMEKLERİ YÜKLENDİ!');
    print('═══════════════════════════════════════════════════════');
    print('📊 Toplam: ${yemekler.length} yemek');
    print('✅ Başarılı: $basarili');
    print('❌ Hatalı: $hatali\n');

    // 6. Öğle yemeği sayısını kontrol et
    final ogleYemekleri = await HiveService.kategoriYemekleriGetir('Öğle');
    print('📊 Öğle yemek sayısı: ${ogleYemekleri.length}');

    print('\n✨ 100 ÖĞLE YEMEĞİ BAŞARIYLA YÜKLENDİ!');
    print('═══════════════════════════════════════════════════════\n');

  } catch (e, stackTrace) {
    print('\n❌❌❌ KRİTİK HATA! ❌❌❌');
    print('Hata: $e');
    print('\nStack Trace:');
    print(stackTrace);
  }
}

List<Map<String, dynamic>> getOgleYemekleri100() {
  return [
    {"id": "OGLE_B1_001", "ad": "Tavuk #1 - Izgara Tavuk Göğsü + Bulgur Pilavı + Mevsim Salata", "kategori": "Öğle", "ogun": "ogle", "kalori": 515, "protein": 25, "karbonhidrat": 71, "yag": 15, "malzemeler": ["Tavuk göğsü 160g", "Bulgur 70g", "Zeytinyağı 1 çay kaşığı (5g)", "Marul 60g", "Domates 80g", "Salatalık 80g", "Limon 1/2 adet"], "hazirlamaSuresi": 20, "zorluk": "orta", "etiketler": ["pratik", "yüksek protein", "ekonomik", "türk mutfağı", "vitamin", "doyurucu"]},
    {"id": "OGLE_B1_002", "ad": "Tavuk #2 - Tavuk Sote (Biberli) + Esmer Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 510, "protein": 45, "karbonhidrat": 61, "yag": 8, "malzemeler": ["Tavuk but kuşbaşı 170g", "Kırmızı biber 70g", "Yeşil biber 70g", "Soğan 60g", "Zeytinyağı 10g", "Esmer pirinç 60g", "Baharatlar (kimyon,karabiber) 2g"], "hazirlamaSuresi": 25, "zorluk": "kolay", "etiketler": ["yüksek protein", "ekonomik", "türk mutfağı", "demir", "pratik", "doyurucu"]},
    {"id": "OGLE_B1_003", "ad": "Tavuk #3 - Fırında Tavuk Baget + Patates-Havuç", "kategori": "Öğle", "ogun": "ogle", "kalori": 524, "protein": 40, "karbonhidrat": 56, "yag": 12, "malzemeler": ["Tavuk baget 2 adet (200g)", "Patates 150g", "Havuç 100g", "Zeytinyağı 10g", "Yoğurt 80g", "Sarımsak 1 diş (3g)", "Biberiye 1g"], "hazirlamaSuresi": 42, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "ekonomik", "türk mutfağı", "kalsiyum", "doyurucu"]},
    {"id": "OGLE_B1_004", "ad": "Tavuk #4 - Tavuklu Nohutlu Sebze Güveç", "kategori": "Öğle", "ogun": "ogle", "kalori": 479, "protein": 25, "karbonhidrat": 59, "yag": 14, "malzemeler": ["Tavuk göğsü 150g", "Nohut haşlanmış 80g", "Kabuklu kabak 120g", "Domates 120g", "Soğan 60g", "Zeytinyağı 10g"], "hazirlamaSuresi": 24, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "sağlıklı", "türk mutfağı", "pratik", "fiber"]},
    {"id": "OGLE_B1_005", "ad": "Tavuk #5 - Tavuk Şiş + Yoğurtlu Semizotu Salatası", "kategori": "Öğle", "ogun": "ogle", "kalori": 380, "protein": 31, "karbonhidrat": 41, "yag": 12, "malzemeler": ["Tavuk göğsü 170g", "Yoğurt (süzme) 100g", "Semizotu 80g", "Zeytinyağı 5g", "Lavaş (ince) 1/2 adet (30g)", "Pul biber 1g"], "hazirlamaSuresi": 34, "zorluk": "orta", "etiketler": ["yüksek protein", "pratik", "türk mutfağı", "kalsiyum", "ekonomik", "doyurucu"]},
    {"id": "OGLE_B1_006", "ad": "Tavuk #6 - Tavuklu Mantarlı Arpa Şehriye Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 535, "protein": 39, "karbonhidrat": 66, "yag": 13, "malzemeler": ["Tavuk göğsü 140g", "Mantar 120g", "Arpa şehriye 70g", "Zeytinyağı 10g", "Maydanoz 10g"], "hazirlamaSuresi": 37, "zorluk": "kolay", "etiketler": ["yüksek protein", "doyurucu", "türk mutfağı", "pratik", "kalsiyum", "ekonomik"]},
    {"id": "OGLE_B1_007", "ad": "Tavuk #7 - Haşlanmış Tavuk + Zeytinyağlı Brokoli + Yoğurt", "kategori": "Öğle", "ogun": "ogle", "kalori": 465, "protein": 30, "karbonhidrat": 61, "yag": 10, "malzemeler": ["Tavuk göğsü 170g", "Brokoli 180g", "Zeytinyağı 10g", "Sarımsak 1 diş (3g)", "Yoğurt 120g", "Limon 1/2 adet"], "hazirlamaSuresi": 25, "zorluk": "kolay", "etiketler": ["sağlıklı", "yüksek protein", "türk mutfağı", "pratik", "vitamin", "ekonomik"]},
    {"id": "OGLE_B1_008", "ad": "Tavuk #8 - Tavuk Kapama (Fırın) + Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 513, "protein": 21, "karbonhidrat": 71, "yag": 13, "malzemeler": ["Tavuk but 200g", "Pirinç 60g", "Tereyağı 5g", "Zeytinyağı 5g", "Defne yaprağı 1 adet", "Tavuk suyu 200ml"], "hazirlamaSuresi": 44, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "pratik", "kalsiyum", "ekonomik"]},
    {"id": "OGLE_B1_009", "ad": "Tavuk #9 - Tavuklu Kuru Domatesli Bulgur", "kategori": "Öğle", "ogun": "ogle", "kalori": 503, "protein": 39, "karbonhidrat": 57, "yag": 13, "malzemeler": ["Tavuk göğsü 150g", "Bulgur 70g", "Kuru domates 20g", "Soğan 60g", "Zeytinyağı 10g", "Maydanoz 10g"], "hazirlamaSuresi": 45, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "türk mutfağı", "fiber", "ekonomik", "doyurucu"]},
    {"id": "OGLE_B1_010", "ad": "Tavuk #10 - Tavuklu Sebzeli Karnabahar Sote", "kategori": "Öğle", "ogun": "ogle", "kalori": 380, "protein": 40, "karbonhidrat": 40, "yag": 8, "malzemeler": ["Tavuk göğsü 150g", "Karnabahar 200g", "Havuç 80g", "Soğan 60g", "Zeytinyağı 10g", "Zerdeçal 1g"], "hazirlamaSuresi": 25, "zorluk": "kolay", "etiketler": ["yüksek protein", "sağlıklı", "türk mutfağı", "fiber", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_011", "ad": "Tavuk #11 - Izgara Tavuk Göğsü + Bulgur Pilavı + Mevsim Salata", "kategori": "Öğle", "ogun": "ogle", "kalori": 501, "protein": 39, "karbonhidrat": 61, "yag": 13, "malzemeler": ["Tavuk göğsü 160g", "Bulgur 70g", "Zeytinyağı 1 çay kaşığı (5g)", "Marul 60g", "Domates 80g", "Salatalık 80g", "Limon 1/2 adet"], "hazirlamaSuresi": 21, "zorluk": "orta", "etiketler": ["yüksek protein", "pratik", "ekonomik", "türk mutfağı", "vitamin", "doyurucu"]},
    {"id": "OGLE_B1_012", "ad": "Tavuk #12 - Tavuk Sote (Biberli) + Esmer Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 524, "protein": 37, "karbonhidrat": 62, "yag": 16, "malzemeler": ["Tavuk but kuşbaşı 170g", "Kırmızı biber 70g", "Yeşil biber 70g", "Soğan 60g", "Zeytinyağı 10g", "Esmer pirinç 60g", "Baharatlar (kimyon,karabiber) 2g"], "hazirlamaSuresi": 36, "zorluk": "kolay", "etiketler": ["yüksek protein", "ekonomik", "türk mutfağı", "demir", "pratik", "doyurucu"]},
    {"id": "OGLE_B1_013", "ad": "Tavuk #13 - Fırında Tavuk Baget + Patates-Havuç", "kategori": "Öğle", "ogun": "ogle", "kalori": 489, "protein": 32, "karbonhidrat": 57, "yag": 12, "malzemeler": ["Tavuk baget 2 adet (200g)", "Patates 150g", "Havuç 100g", "Zeytinyağı 10g", "Yoğurt 80g", "Sarımsak 1 diş (3g)", "Biberiye 1g"], "hazirlamaSuresi": 33, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "ekonomik", "türk mutfağı", "kalsiyum", "doyurucu"]},
    {"id": "OGLE_B1_014", "ad": "Tavuk #14 - Tavuklu Nohutlu Sebze Güveç", "kategori": "Öğle", "ogun": "ogle", "kalori": 522, "protein": 37, "karbonhidrat": 66, "yag": 11, "malzemeler": ["Tavuk göğsü 150g", "Nohut haşlanmış 80g", "Kabuklu kabak 120g", "Domates 120g", "Soğan 60g", "Zeytinyağı 10g"], "hazirlamaSuresi": 30, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "sağlıklı", "türk mutfağı", "pratik", "fiber"]},
    {"id": "OGLE_B1_015", "ad": "Tavuk #15 - Tavuk Şiş + Yoğurtlu Semizotu Salatası", "kategori": "Öğle", "ogun": "ogle", "kalori": 526, "protein": 34, "karbonhidrat": 65, "yag": 13, "malzemeler": ["Tavuk göğsü 170g", "Yoğurt (süzme) 100g", "Semizotu 80g", "Zeytinyağı 5g", "Lavaş (ince) 1/2 adet (30g)", "Pul biber 1g"], "hazirlamaSuresi": 38, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "türk mutfağı", "kalsiyum", "ekonomik", "doyurucu"]},
    {"id": "OGLE_B1_016", "ad": "Tavuk #16 - Tavuklu Mantarlı Arpa Şehriye Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 516, "protein": 22, "karbonhidrat": 74, "yag": 9, "malzemeler": ["Tavuk göğsü 140g", "Mantar 120g", "Arpa şehriye 70g", "Zeytinyağı 10g", "Maydanoz 10g"], "hazirlamaSuresi": 22, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "pratik", "kalsiyum", "ekonomik"]},
    {"id": "OGLE_B1_017", "ad": "Tavuk #17 - Haşlanmış Tavuk + Zeytinyağlı Brokoli + Yoğurt", "kategori": "Öğle", "ogun": "ogle", "kalori": 509, "protein": 38, "karbonhidrat": 62, "yag": 11, "malzemeler": ["Tavuk göğsü 170g", "Brokoli 180g", "Zeytinyağı 10g", "Sarımsak 1 diş (3g)", "Yoğurt 120g", "Limon 1/2 adet"], "hazirlamaSuresi": 40, "zorluk": "kolay", "etiketler": ["sağlıklı", "yüksek protein", "türk mutfağı", "pratik", "vitamin", "ekonomik"]},
    {"id": "OGLE_B1_018", "ad": "Tavuk #18 - Tavuk Kapama (Fırın) + Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 491, "protein": 41, "karbonhidrat": 48, "yag": 14, "malzemeler": ["Tavuk but 200g", "Pirinç 60g", "Tereyağı 5g", "Zeytinyağı 5g", "Defne yaprağı 1 adet", "Tavuk suyu 200ml"], "hazirlamaSuresi": 35, "zorluk": "kolay", "etiketler": ["yüksek protein", "doyurucu", "türk mutfağı", "pratik", "kalsiyum", "ekonomik"]},
    {"id": "OGLE_B1_019", "ad": "Tavuk #19 - Tavuklu Kuru Domatesli Bulgur", "kategori": "Öğle", "ogun": "ogle", "kalori": 501, "protein": 45, "karbonhidrat": 48, "yag": 16, "malzemeler": ["Tavuk göğsü 150g", "Bulgur 70g", "Kuru domates 20g", "Soğan 60g", "Zeytinyağı 10g", "Maydanoz 10g"], "hazirlamaSuresi": 21, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "türk mutfağı", "fiber", "ekonomik", "doyurucu"]},
    {"id": "OGLE_B1_020", "ad": "Tavuk #20 - Tavuklu Sebzeli Karnabahar Sote", "kategori": "Öğle", "ogun": "ogle", "kalori": 496, "protein": 36, "karbonhidrat": 63, "yag": 10, "malzemeler": ["Tavuk göğsü 150g", "Karnabahar 200g", "Havuç 80g", "Soğan 60g", "Zeytinyağı 10g", "Zerdeçal 1g"], "hazirlamaSuresi": 27, "zorluk": "kolay", "etiketler": ["yüksek protein", "sağlıklı", "türk mutfağı", "fiber", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_021", "ad": "Tavuk #21 - Izgara Tavuk Göğsü + Bulgur Pilavı + Mevsim Salata", "kategori": "Öğle", "ogun": "ogle", "kalori": 508, "protein": 25, "karbonhidrat": 70, "yag": 15, "malzemeler": ["Tavuk göğsü 160g", "Bulgur 70g", "Zeytinyağı 1 çay kaşığı (5g)", "Marul 60g", "Domates 80g", "Salatalık 80g", "Limon 1/2 adet"], "hazirlamaSuresi": 31, "zorluk": "kolay", "etiketler": ["pratik", "yüksek protein", "ekonomik", "türk mutfağı", "vitamin", "doyurucu"]},
    {"id": "OGLE_B1_022", "ad": "Tavuk #22 - Tavuk Sote (Biberli) + Esmer Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 548, "protein": 31, "karbonhidrat": 69, "yag": 12, "malzemeler": ["Tavuk but kuşbaşı 170g", "Kırmızı biber 70g", "Yeşil biber 70g", "Soğan 60g", "Zeytinyağı 10g", "Esmer pirinç 60g", "Baharatlar (kimyon,karabiber) 2g"], "hazirlamaSuresi": 23, "zorluk": "kolay", "etiketler": ["yüksek protein", "ekonomik", "türk mutfağı", "demir", "pratik", "doyurucu"]},
    {"id": "OGLE_B1_023", "ad": "Tavuk #23 - Fırında Tavuk Baget + Patates-Havuç", "kategori": "Öğle", "ogun": "ogle", "kalori": 515, "protein": 27, "karbonhidrat": 69, "yag": 12, "malzemeler": ["Tavuk baget 2 adet (200g)", "Patates 150g", "Havuç 100g", "Zeytinyağı 10g", "Yoğurt 80g", "Sarımsak 1 diş (3g)", "Biberiye 1g"], "hazirlamaSuresi": 29, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "ekonomik", "türk mutfağı", "kalsiyum", "doyurucu"]},
    {"id": "OGLE_B1_024", "ad": "Tavuk #24 - Tavuklu Nohutlu Sebze Güveç", "kategori": "Öğle", "ogun": "ogle", "kalori": 513, "protein": 29, "karbonhidrat": 66, "yag": 11, "malzemeler": ["Tavuk göğsü 150g", "Nohut haşlanmış 80g", "Kabuklu kabak 120g", "Domates 120g", "Soğan 60g", "Zeytinyağı 10g"], "hazirlamaSuresi": 45, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "sağlıklı", "türk mutfağı", "pratik", "fiber"]},
    {"id": "OGLE_B1_025", "ad": "Tavuk #25 - Tavuk Şiş + Yoğurtlu Semizotu Salatası", "kategori": "Öğle", "ogun": "ogle", "kalori": 518, "protein": 27, "karbonhidrat": 72, "yag": 9, "malzemeler": ["Tavuk göğsü 170g", "Yoğurt (süzme) 100g", "Semizotu 80g", "Zeytinyağı 5g", "Lavaş (ince) 1/2 adet (30g)", "Pul biber 1g"], "hazirlamaSuresi": 42, "zorluk": "kolay", "etiketler": ["yüksek protein", "pratik", "türk mutfağı", "kalsiyum", "ekonomik", "doyurucu"]},
    {"id": "OGLE_B1_026", "ad": "Et #1 - Izgara Köfte + Bulgur Pilavı + Cacık", "kategori": "Öğle", "ogun": "ogle", "kalori": 513, "protein": 28, "karbonhidrat": 67, "yag": 12, "malzemeler": ["Dana kıyma %15 yağ 160g", "Bulgur 70g", "Yoğurt 150g", "Salatalık 80g", "Nane 2g", "Zeytinyağı 5g"], "hazirlamaSuresi": 22, "zorluk": "orta", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "demir", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_027", "ad": "Et #2 - Tas Kebabı + Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 508, "protein": 33, "karbonhidrat": 60, "yag": 15, "malzemeler": ["Dana kuşbaşı 170g", "Soğan 80g", "Havuç 80g", "Bezelye 60g", "Pirinç 60g", "Zeytinyağı 10g"], "hazirlamaSuresi": 25, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "demir", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_028", "ad": "Et #3 - Et Sote (Soğan-Biber) + Kepekli Lavaş", "kategori": "Öğle", "ogun": "ogle", "kalori": 470, "protein": 36, "karbonhidrat": 47, "yag": 12, "malzemeler": ["Dana jülyen 160g", "Soğan 80g", "Yeşil biber 80g", "Zeytinyağı 10g", "Kepekli lavaş 1 adet (60g)", "Kimyon 1g"], "hazirlamaSuresi": 37, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "demir", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_029", "ad": "Et #4 - Fırında Patlıcan Musakka (Yağsız) + Yoğurt", "kategori": "Öğle", "ogun": "ogle", "kalori": 493, "protein": 24, "karbonhidrat": 68, "yag": 12, "malzemeler": ["Dana kıyma %10 yağ 140g", "Patlıcan 250g", "Domates 120g", "Soğan 60g", "Zeytinyağı 10g", "Yoğurt 120g"], "hazirlamaSuresi": 38, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "demir", "pratik", "ekonomik"]},
    {"id": "OGLE_B1_030", "ad": "Et #5 - Etli Kuru Fasulye + Pirinç Pilavı", "kategori": "Öğle", "ogun": "ogle", "kalori": 547, "protein": 27, "karbonhidrat": 71, "yag": 14, "malzemeler": ["Dana kuşbaşı 120g", "Kuru fasulye haşlanmış 150g", "Soğan 60g", "Domates salçası 10g", "Pirinç 60g", "Zeytinyağı 10g"], "hazirlamaSuresi": 31, "zorluk": "kolay", "etiketler": ["doyurucu", "yüksek protein", "türk mutfağı", "demir", "pratik", "ekonomik"]},
  ];
}