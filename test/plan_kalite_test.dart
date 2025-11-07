import 'package:flutter_test/flutter_test.dart';
import 'package:zinde_ai/domain/entities/yemek.dart';
import 'package:zinde_ai/domain/services/ai_beslenme_servisi.dart';

void main() {
  final aiService = AIBeslenmeServisi();

  group('Malzeme parse & ölçek', () {
    test('Virgüllü sayı ve bitişik birim', () {
      final d = aiService.testParseMalzeme('Ton Balığı (suda) (150,5g)');
      expect(d.miktar, closeTo(150.5, 0.001));
      expect(d.birim, 'g');
      expect(d.ad.toLowerCase(), contains('ton balığı'));
    });

    test('İç içe parantezli ad', () {
      final d = aiService.testParseMalzeme('Yoğurt (ev yapımı) (200 g)');
      expect(d.miktar, 200);
      expect(d.birim, 'g');
      expect(d.ad, 'Yoğurt (ev yapımı)');
    });

    test('Yumurta güvenlik kilidi', () {
      final baz = Yemek(id: 'test1', ad: 'Test Yumurta', ogun: OgunTipi.kahvalti, kalori: 100, protein: 10, karbonhidrat: 0, yag: 6, malzemeler: ['Yumurta (50 g)'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay);
      final y = aiService.testYemekOlustur(baz, OgunTipi.kahvalti, baz.kalori * 1.5);
      final satir = y.malzemeler.firstWhere((m) => m.toLowerCase().contains('yumurta'));
      // Gram olarak kalmasına izin verilmedi; orijinal satır dönmüş olmalı
      expect(satir.toLowerCase().contains('(50 g)'), true);
    });

    test('kg ve litre dönüşümü', () {
      final d1 = aiService.testParseMalzeme('Tavuk Göğüs (1 kg)');
      final d2 = aiService.testParseMalzeme('Süt (1 l)');
      expect(d1.birim, 'kg');
      expect(d2.birim, 'l');
    });

    test('Adet yuvarlama & sınır', () {
      final baz = Yemek(id: 'test2', ad: 'Test Ceviz', ogun: OgunTipi.araOgun1, kalori: 100, protein: 2, karbonhidrat: 2, yag: 9, malzemeler: ['Ceviz (1 adet)'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay);
      final y = aiService.testYemekOlustur(baz, OgunTipi.araOgun1, baz.kalori * 0.4);
      final ceviz = y.malzemeler.firstWhere((m)=>m.toLowerCase().contains('ceviz'));
      // 0.5 altına düşmesin
      expect(RegExp(r'\((0\.5|1|1\.5|2) adet\)').hasMatch(ceviz), true);
    });

    test('Spice/garnitür ölçeklenmesin (DB temizliği sonrası emniyet)', () {
      final d = aiService.testParseMalzeme('Tuz (2 g)'); // Varsayımsal kalıntı
      expect(d.birim, 'g');
    });
  });

  group('Plan kalitesi', () {
    test('Akıl dışı miktarları engelle', () {
      final baz = Yemek(id: 'test3', ad: 'Ton Balıklı Salata', ogun: OgunTipi.ogle, kalori: 300, protein: 25, karbonhidrat: 10, yag: 18, malzemeler: ['Ton Balığı (150 g)'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay);
      final y = aiService.testYemekOlustur(baz, OgunTipi.ogle, baz.kalori * 1.9);
      // 1550 g gibi uçuk değerler olmamalı
      final satirler = y.malzemeler.where((m)=>m.toLowerCase().contains('ton balığı'));
      for (final s in satirler) {
        final m = RegExp(r'\((\d+)\s*g\)').firstMatch(s);
        if (m != null) {
          final gr = int.parse(m.group(1)!);
          expect(gr < 400, true, reason: 'Ton balığı miktarı 400g\'dan az olmalıydı ama $gr g geldi.');
        }
      }
    });

    test('Makro sapmaları mantıklı sınırda', () {
      final baz = Yemek(id: 'test4', ad: 'Herhangi bir yemek', ogun: OgunTipi.aksam, kalori: 250, protein: 20, karbonhidrat: 20, yag: 10, malzemeler: ['Test Malzeme (100g)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay);
      final hedef = baz.kalori * 1.7;
      final y = aiService.testYemekOlustur(baz, OgunTipi.aksam, hedef);
      expect(y.kalori, closeTo(hedef.clamp(baz.kalori*0.5, baz.kalori*2.0), 1e-6));
    });
  });
}
