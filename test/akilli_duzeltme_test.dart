import 'package:flutter_test/flutter_test.dart';
import '../lib/core/utils/app_logger.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/entities/makro_hedefleri.dart';
import '../lib/domain/entities/yemek.dart';
import '../lib/domain/services/diyetisyen_duzeltme_servisi.dart';
import '../lib/domain/entities/hedef.dart';

void main() {
  // AppLogger.init(isTest: true); // Test ortamında genellikle özel başlatma gerekmez.

  group('DiyetisyenDuzeltmeServisi - Gelişmiş Düzeltme Testleri', () {
    late DiyetisyenDuzeltmeServisi duzeltmeServisi;

    setUp(() {
      duzeltmeServisi = DiyetisyenDuzeltmeServisi();
    });

    test(
        'Bileşik isimli ("Börülce + Bulgur") ve listede olmayan yemeklerde anahtar kelime tespiti çalışmalı',
        () async {
      // ARRANGE
      final sorunluYemek = Yemek(
        id: 'aksam_1',
        ad: 'Börülce + Bulgur',
        ogun: OgunTipi.aksam,
        kalori: 2800, // Hedefi aşıyor
        protein: 220, // Hedefi aşıyor
        karbonhidrat: 150,
        yag: 90,
        malzemeler: ['Soğan (50g)', 'Salça (10g)'], // Börülce ve Bulgur eksik
        hazirlamaSuresi: 45,
        zorluk: Zorluk.orta,
        etiketler: ['bakliyat', 'tahıl'],
      );

      final makroHedefleri = MakroHedefleri(
        gunlukKalori: 2200,
        gunlukProtein: 160,
        gunlukKarbonhidrat: 200,
        gunlukYag: 80,
      );

      final plan = GunlukPlan(
        id: 'test_plan_1',
        tarih: DateTime.now(),
        makroHedefleri: makroHedefleri,
        aksamYemegi: sorunluYemek,
        kahvalti: null, ogleYemegi: null, araOgun1: null, araOgun2: null, geceAtistirma: null,
      );

      // ACT
      final duzeltilmisPlan = await duzeltmeServisi.planiDuzelt(plan, Hedef.kiloVermek);

      // ASSERT
      final duzeltilmisYemek = duzeltilmisPlan.aksamYemegi!;
      final malzemeler = duzeltilmisYemek.malzemeler.map((m) => m.toLowerCase()).toList();

      expect(duzeltilmisYemek.kalori, lessThan(2800), reason: 'Kalori azaltılmalıydı.');
      expect(malzemeler.any((m) => m.contains('börülce')), isTrue, reason: 'Börülce eklenmeliydi.');
      expect(malzemeler.any((m) => m.contains('bulgur')), isTrue, reason: 'Bulgur eklenmeliydi.');
      AppLogger.success('✅ Bileşik isimli yemekte anahtar kelimeler başarıyla eklendi.');
    });

    test('Eksik makroları tamamlarken en dengeli atıştırmalığı seçmeli', () async {
      // ARRANGE
      // Özellikle protein ve karb açığı olan bir plan
      final makroHedefleri = MakroHedefleri(
        gunlukKalori: 2500,
        gunlukProtein: 180,
        gunlukKarbonhidrat: 250,
        gunlukYag: 90,
      );

      final eksikPlan = GunlukPlan(
        id: 'test_plan_2',
        tarih: DateTime.now(),
        makroHedefleri: makroHedefleri,
        kahvalti: Yemek(id: 'k1', ad: 'Yulaf Ezmesi', ogun: OgunTipi.kahvalti, kalori: 400, protein: 20, karbonhidrat: 60, yag: 10, malzemeler: [], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
        ogleYemegi: Yemek(id: 'o1', ad: 'Tavuk Salata', ogun: OgunTipi.ogle, kalori: 500, protein: 40, karbonhidrat: 20, yag: 30, malzemeler: [], hazirlamaSuresi: 15, zorluk: Zorluk.kolay),
        aksamYemegi: Yemek(id: 'a1', ad: 'Somon Izgara', ogun: OgunTipi.aksam, kalori: 600, protein: 50, karbonhidrat: 10, yag: 40, malzemeler: [], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
        araOgun1: null, araOgun2: null, geceAtistirma: null,
      );
      
      // Toplam: 1500 kcal, 110p, 90k, 80y
      // Eksik: 1000 kcal, 70p, 160k, 10y -> En büyük açık karb ve kalori

      // ACT
      final duzeltilmisPlan = await duzeltmeServisi.planiDuzelt(eksikPlan, Hedef.kiloAlmak);

      // ASSERT
      // Eklenen yemeğin hem karb hem de protein açısından zengin olması beklenir.
      // 'Protein Bar + Muz' (21p, 35k, 274kcal) veya 'Yoğurt + Meyve + Badem' (12p, 20k, 220kcal) gibi
      // skorlamaya göre en uygun olanı seçecektir.
      expect(duzeltilmisPlan.toplamKalori, greaterThan(1500));
      expect(duzeltilmisPlan.toplamKarbonhidrat, greaterThan(90));
      expect(duzeltilmisPlan.araOgun2, isNotNull, reason: 'Eksik makroları tamamlamak için ara öğün eklenmeliydi.');
      AppLogger.success('✅ Eksik makrolar için en dengeli atıştırmalık başarıyla eklendi: ${duzeltilmisPlan.araOgun2?.ad}');
    });

    test(
        'Miktar belirtilmemiş malzemeler ("Roka", "Yumurta") için varsayılan miktar atanmalı ve ölçeklenmeli',
        () async {
      // ARRANGE
      final sorunluYemek = Yemek(
        id: 'kahvalti_1',
        ad: 'Peynirli Omlet ve Roka Salatası',
        ogun: OgunTipi.kahvalti,
        kalori: 1500, // Aşırı yüksek kalori
        protein: 80,
        karbonhidrat: 10,
        yag: 120,
        malzemeler: [
          'Yumurta', // Miktar yok
          'Beyaz Peynir (100g)',
          'Roka', // Miktar yok
          'Zeytinyağı (3 YK)'
        ],
        hazirlamaSuresi: 15,
        zorluk: Zorluk.kolay,
      );

      final makroHedefleri = MakroHedefleri(
        gunlukKalori: 500, // Düşük hedef
        gunlukProtein: 40,
        gunlukKarbonhidrat: 20,
        gunlukYag: 30,
      );

      final plan = GunlukPlan(
        id: 'test_plan_3',
        tarih: DateTime.now(),
        makroHedefleri: makroHedefleri,
        kahvalti: sorunluYemek,
        ogleYemegi: null, araOgun1: null, araOgun2: null, geceAtistirma: null, aksamYemegi: null,
      );

      // ACT
      final duzeltilmisPlan = await duzeltmeServisi.planiDuzelt(plan, Hedef.kiloVermek);

      // ASSERT
      final duzeltilmisYemek = duzeltilmisPlan.kahvalti!;
      final malzemeler = duzeltilmisYemek.malzemeler;

      // 1. Kalorinin önemli ölçüde azaltıldığını kontrol et
      expect(duzeltilmisYemek.kalori, lessThan(1500));

      // 2. "Yumurta" için miktar eklendiğini ve ölçeklendiğini kontrol et
      final yumurtaMalzemesi = malzemeler.firstWhere((m) => m.toLowerCase().contains('yumurta'));
      expect(yumurtaMalzemesi, matches(RegExp(r'\((\d+(?:\.\d+)?)\s*adet\)')), reason: 'Yumurta için "(X adet)" formatında miktar eklenmeliydi.');

      // 3. "Roka" için miktar eklendiğini ve ölçeklendiğini kontrol et
      final rokaMalzemesi = malzemeler.firstWhere((m) => m.toLowerCase().contains('roka'));
      expect(rokaMalzemesi, matches(RegExp(r'\((\d+)\s*g\)')), reason: 'Roka için "(X g)" formatında miktar eklenmeliydi.');
      
      AppLogger.success('✅ Miktar belirtilmemiş malzemelere başarıyla varsayılan değerler atandı ve ölçeklendi.');
    });
  });
}
