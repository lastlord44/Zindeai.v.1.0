// ============================================================================
// DEBUG: Karbonhidrat Havuzu Analizi
// Neden karbonhidrat hedefine ulaşılamıyor?
// ============================================================================

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/domain/services/karbonhidrat_validator.dart';

void main() {
  testWidgets('Karbonhidrat Havuzu Analizi', (WidgetTester tester) async {
    // ========================================================================
    // TEST ORTAMI İÇİN KURULUM
    // ========================================================================
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('hive_test_karb_analizi');
    Hive.init(tempDir.path);

    // Adaptörleri manuel olarak kaydet
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

    print('🔍 KARBONHİDRAT HAVUZU ANALİZİ\n');
    print('=' * 80);

    // Tüm yemekleri yükle
    final tumYemekler = await HiveService.tumYemekleriGetir();
    
    // Kategorilere göre analiz
    final kategoriler = <OgunTipi, List<Yemek>>{};
    for (final yemek in tumYemekler) {
      kategoriler.putIfAbsent(yemek.ogun, () => []).add(yemek);
    }

    // Her kategori için karbonhidrat analizi
    for (final entry in kategoriler.entries) {
      final ogun = entry.key;
      final yemekler = entry.value;

      print('\n📊 ${ogun.ad.toUpperCase()}');
      print('-' * 80);
      print('Toplam yemek: ${yemekler.length}');

      // Karbonhidrat miktarına göre sırala
      yemekler.sort((a, b) => b.karbonhidrat.compareTo(a.karbonhidrat));

      // İstatistikler
      final ortalamaKarb = yemekler.isEmpty
          ? 0.0
          : yemekler.map((y) => y.karbonhidrat).reduce((a, b) => a + b) /
              yemekler.length;

      final yuksekKarbYemekler =
          yemekler.where((y) => y.karbonhidrat >= 50).toList();
      final ortaKarbYemekler = yemekler
          .where((y) => y.karbonhidrat >= 30 && y.karbonhidrat < 50)
          .toList();
      final dusukKarbYemekler =
          yemekler.where((y) => y.karbonhidrat < 30).toList();

      print('Ortalama karbonhidrat: ${ortalamaKarb.toStringAsFixed(1)}g');
      print('Yüksek karb (≥50g): ${yuksekKarbYemekler.length} yemek');
      print('Orta karb (30-50g): ${ortaKarbYemekler.length} yemek');
      print('Düşük karb (<30g): ${dusukKarbYemekler.length} yemek');

      // En yüksek karbonhidratlı 10 yemek
      print('\n🏆 EN YÜKSEK KARBONHİDRATLI 10 YEMEK:');
      for (int i = 0; i < 10 && i < yemekler.length; i++) {
        final y = yemekler[i];
        print(
            '   ${i + 1}. ${y.ad} → ${y.karbonhidrat.toStringAsFixed(1)}g karb (${y.kalori.toStringAsFixed(0)} kcal)');
      }

      // Karbonhidrat validator kontrolü (sadece öğle ve akşam için)
      if (ogun == OgunTipi.ogle || ogun == OgunTipi.aksam) {
        final gecerliYemekler = KarbonhidratValidator.yemekleriFiltrele(yemekler);
        final elenenSayi = yemekler.length - gecerliYemekler.length;
        print(
            '\n⚠️ KARBONHIDRAT VALİDATÖR: ${elenenSayi} yemek elendi (çoklu karb)');

        if (elenenSayi > 0) {
          print('   Elenen yemek örnekleri (ilk 5):');
          final elenenler =
              yemekler.where((y) => !gecerliYemekler.contains(y)).take(5);
          for (final y in elenenler) {
            final karbKaynaklari = KarbonhidratValidator.findKarbonhidratlar(y);
            print('      ❌ ${y.ad} → ${karbKaynaklari.join(", ")}');
          }
        }
      }

      // Türk mutfağı filtresi analizi
      final yasakKelimeler = [
        'börek',
        'simit',
        'pide',
        'lahmacun',
        'tost',
        'wrap',
        'burger',
        'pizza',
        'smoothie',
        'protein tozu',
      ];

      int turkMutfagiElenenSayi = 0;
      for (final yemek in yemekler) {
        final adLower = yemek.ad.toLowerCase();
        if (yasakKelimeler.any((yasak) => adLower.contains(yasak))) {
          turkMutfagiElenenSayi++;
        }
      }

      if (turkMutfagiElenenSayi > 0) {
        print(
            '\n⚠️ TÜRK MUTFAĞI FİLTRESİ: ~${turkMutfagiElenenSayi} yemek elendi (yasak kelimeler)');
      }
    }

    // Özel analiz: Kahvaltı için karbonhidrat stratejisi
    print('\n' + '=' * 80);
    print('🎯 KAHVALTI İÇİN KARBONHİDRAT STRATEJİSİ');
    print('=' * 80);

    final kahvaltilar = kategoriler[OgunTipi.kahvalti] ?? [];
    if (kahvaltilar.isNotEmpty) {
      // Hedef: 246g karb → Kahvaltı %20 = ~49g karb
      const hedefKarbKahvalti = 49.0;

      final uygunYemekler = kahvaltilar
          .where((y) =>
              y.karbonhidrat >= hedefKarbKahvalti * 0.8 &&
              y.karbonhidrat <= hedefKarbKahvalti * 1.2)
          .toList();

      print(
          'Hedef karbonhidrat: ${hedefKarbKahvalti.toStringAsFixed(0)}g (±20%)');
      print('Uygun yemek sayısı: ${uygunYemekler.length}');

      if (uygunYemekler.isEmpty) {
        print('\n❌ SORUN: Hedef karbonhidrata uygun kahvaltı yok!');
        print('   Çözüm: Kahvaltı hedefi yeniden ayarlanmalı veya yeni yemekler eklenmeli.');
      } else {
        print('\n✅ Uygun kahvaltılar (ilk 10):');
        uygunYemekler.sort((a, b) => b.karbonhidrat.compareTo(a.karbonhidrat));
        for (int i = 0; i < 10 && i < uygunYemekler.length; i++) {
          final y = uygunYemekler[i];
          print(
              '   ${i + 1}. ${y.ad} → ${y.karbonhidrat.toStringAsFixed(1)}g karb, ${y.kalori.toStringAsFixed(0)} kcal');
        }
      }
    }

    print('\n' + '=' * 80);
    print('ANALİZ TAMAMLANDI\n');

    // Test ortamı için Hive'ı kapat
    await Hive.close();
    await tempDir.delete(recursive: true);
  });
}