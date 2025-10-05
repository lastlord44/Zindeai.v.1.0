// ============================================================================
// lib/domain/usecases/ogun_planlayici.dart
// FAZ 5: AKILLI ÖĞÜN PLANLAYICI (GENETİK ALGORİTMA)
// ============================================================================

import 'dart:math';
import '../../data/datasources/yemek_local_data_source.dart';
import '../entities/yemek.dart';
import '../entities/gunluk_plan.dart';
import '../entities/makro_hedefleri.dart';

class OgunPlanlayici {
  final YemekLocalDataSource dataSource;
  final Random _random = Random();

  OgunPlanlayici({required this.dataSource});

  /// Günlük plan oluştur
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
  }) async {
    print('🤖 AKILLI ÖĞÜN PLANLAYICI BAŞLATILDI');
    print('═' * 70);
    print('Hedef Kalori: ${hedefKalori.toStringAsFixed(0)} kcal');
    print('Hedef Protein: ${hedefProtein.toStringAsFixed(0)} g');
    print('Kısıtlamalar: ${kisitlamalar.isEmpty ? "Yok" : kisitlamalar.join(", ")}');
    print('═' * 70);

    // 1. Tüm yemekleri yükle
    print('📦 Yemekler yükleniyor...');
    final tumYemekler = await dataSource.tumYemekleriYukle();

    // 2. Kısıtlamalara göre filtrele
    print('🔍 Kısıtlamalar filtreleniyor...');
    final uygunYemekler = _kisitlamalariFiltrele(tumYemekler, kisitlamalar);

    print('   Kahvaltı: ${uygunYemekler[OgunTipi.kahvalti]?.length ?? 0} seçenek');
    print('   Ara Öğün 1: ${uygunYemekler[OgunTipi.araOgun1]?.length ?? 0} seçenek');
    print('   Öğle: ${uygunYemekler[OgunTipi.ogle]?.length ?? 0} seçenek');
    print('   Ara Öğün 2: ${uygunYemekler[OgunTipi.araOgun2]?.length ?? 0} seçenek');
    print('   Akşam: ${uygunYemekler[OgunTipi.aksam]?.length ?? 0} seçenek');

    // 3. Genetik algoritma ile en iyi kombinasyonu bul
    print('🧬 Genetik algoritma başlatılıyor...');
    final plan = _genetikAlgoritmaIleEslestir(
      yemekler: uygunYemekler,
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
    );

    print('✅ PLAN OLUŞTURULDU!');
    print(plan);

    return plan;
  }

  /// Kısıtlamalara göre filtrele
  Map<OgunTipi, List<Yemek>> _kisitlamalariFiltrele(
    Map<OgunTipi, List<Yemek>> tumYemekler,
    List<String> kisitlamalar,
  ) {
    if (kisitlamalar.isEmpty) return tumYemekler;

    return tumYemekler.map((ogun, yemekler) {
      final filtrelenmis =
          yemekler.where((y) => y.kisitlamayaUygunMu(kisitlamalar)).toList();
      return MapEntry(ogun, filtrelenmis);
    });
  }

  /// Genetik algoritma
  GunlukPlan _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    const populasyonBoyutu = 100;
    const jenerasyonSayisi = 50;
    const elitOrani = 0.2;

    // 1. Rastgele popülasyon oluştur
    List<GunlukPlan> populasyon = List.generate(populasyonBoyutu, (_) {
      return _rastgelePlanOlustur(
          yemekler, hedefKalori, hedefProtein, hedefKarb, hedefYag);
    });

    print('   İlk popülasyon: $populasyonBoyutu birey');

    // 2. Evrim döngüsü
    for (int jenerasyon = 0; jenerasyon < jenerasyonSayisi; jenerasyon++) {
      // Fitness hesapla ve sırala
      for (int i = 0; i < populasyon.length; i++) {
        final fitness = _fitnessHesapla(
          populasyon[i],
          hedefKalori,
          hedefProtein,
          hedefKarb,
          hedefYag,
        );
        populasyon[i] = populasyon[i].copyWith(fitnessSkoru: fitness);
      }

      populasyon.sort((a, b) => b.fitnessSkoru.compareTo(a.fitnessSkoru));

      if (jenerasyon % 10 == 0) {
        print('   Jenerasyon $jenerasyon: En iyi skor = ${populasyon.first.fitnessSkoru.toStringAsFixed(1)}');
      }

      // En iyi bireyleri seç
      final elitSayisi = (populasyonBoyutu * elitOrani).round();
      final elitler = populasyon.take(elitSayisi).toList();

      // Yeni nesil oluştur
      final yeniNesil = <GunlukPlan>[];
      yeniNesil.addAll(elitler);

      while (yeniNesil.length < populasyonBoyutu) {
        final parent1 = elitler[_random.nextInt(elitler.length)];
        final parent2 = elitler[_random.nextInt(elitler.length)];

        final cocuk = _caprazla(parent1, parent2, yemekler);
        final mutasyonlu = _mutasyonUygula(cocuk, yemekler);

        yeniNesil.add(mutasyonlu);
      }

      populasyon = yeniNesil;
    }

    // En iyi planı döndür
    populasyon.sort((a, b) => b.fitnessSkoru.compareTo(a.fitnessSkoru));
    return populasyon.first;
  }

  /// Rastgele plan oluştur
  GunlukPlan _rastgelePlanOlustur(
    Map<OgunTipi, List<Yemek>> yemekler,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    // Makro hedefleri oluştur
    final makroHedefleri = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: hedefProtein,
      gunlukKarbonhidrat: hedefKarb,
      gunlukYag: hedefYag,
    );

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: _rastgeleYemekSec(yemekler[OgunTipi.kahvalti]!),
      araOgun1: _rastgeleYemekSec(yemekler[OgunTipi.araOgun1]!),
      ogleYemegi: _rastgeleYemekSec(yemekler[OgunTipi.ogle]!),
      araOgun2: _rastgeleYemekSec(yemekler[OgunTipi.araOgun2]!),
      aksamYemegi: _rastgeleYemekSec(yemekler[OgunTipi.aksam]!),
      makroHedefleri: makroHedefleri,
      fitnessSkoru: 0,
    );
  }

  /// Rastgele yemek seç
  Yemek _rastgeleYemekSec(List<Yemek> yemekler) {
    if (yemekler.isEmpty) {
      throw Exception('Yemek listesi boş!');
    }
    return yemekler[_random.nextInt(yemekler.length)];
  }

  /// Çaprazlama (crossover)
  GunlukPlan _caprazla(
    GunlukPlan parent1,
    GunlukPlan parent2,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    final kesimNoktasi = _random.nextInt(5);

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: kesimNoktasi > 0 ? parent1.kahvalti : parent2.kahvalti,
      araOgun1: kesimNoktasi > 1 ? parent1.araOgun1 : parent2.araOgun1,
      ogleYemegi: kesimNoktasi > 2 ? parent1.ogleYemegi : parent2.ogleYemegi,
      araOgun2: kesimNoktasi > 3 ? parent1.araOgun2 : parent2.araOgun2,
      aksamYemegi: kesimNoktasi > 4 ? parent1.aksamYemegi : parent2.aksamYemegi,
      makroHedefleri: parent1.makroHedefleri,
      fitnessSkoru: 0,
    );
  }

  /// Mutasyon
  GunlukPlan _mutasyonUygula(
    GunlukPlan plan,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    const mutasyonOrani = 0.2;

    if (_random.nextDouble() > mutasyonOrani) {
      return plan;
    }

    final ogunIndex = _random.nextInt(5);

    switch (ogunIndex) {
      case 0:
        return plan.copyWith(
          kahvalti: _rastgeleYemekSec(yemekler[OgunTipi.kahvalti]!),
        );
      case 1:
        return plan.copyWith(
          araOgun1: _rastgeleYemekSec(yemekler[OgunTipi.araOgun1]!),
        );
      case 2:
        return plan.copyWith(
          ogleYemegi: _rastgeleYemekSec(yemekler[OgunTipi.ogle]!),
        );
      case 3:
        return plan.copyWith(
          araOgun2: _rastgeleYemekSec(yemekler[OgunTipi.araOgun2]!),
        );
      default:
        return plan.copyWith(
          aksamYemegi: _rastgeleYemekSec(yemekler[OgunTipi.aksam]!),
        );
    }
  }

  /// Fitness fonksiyonu (0-100 arası skor)
  double _fitnessHesapla(
    GunlukPlan plan,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    final kaloriSapma = (plan.toplamKalori - hedefKalori).abs() / hedefKalori;
    final proteinSapma =
        (plan.toplamProtein - hedefProtein).abs() / hedefProtein;
    final karbSapma = (plan.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb;
    final yagSapma = (plan.toplamYag - hedefYag).abs() / hedefYag;

    final toplamSapma = (kaloriSapma * 0.4 +
            proteinSapma * 0.35 +
            karbSapma * 0.15 +
            yagSapma * 0.1)
        .clamp(0.0, 1.0);

    return (1 - toplamSapma) * 100;
  }
}
