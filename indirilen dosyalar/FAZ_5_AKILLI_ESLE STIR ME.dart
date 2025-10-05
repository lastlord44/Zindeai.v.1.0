// ============================================================================
// FAZ 5: AKILLI ÖĞÜN EŞLEŞTİRME ALGORİTMASI
// ============================================================================

import 'dart:math';
import 'package:equatable/equatable.dart';

// ============================================================================
// GÜNLÜK PLAN ENTITY
// ============================================================================

class GunlukPlan extends Equatable {
  final String id;
  final DateTime tarih;
  final Yemek kahvalti;
  final Yemek araOgun1;
  final Yemek ogle;
  final Yemek araOgun2;
  final Yemek aksam;
  final Yemek? geceAtistirma;
  final double fitnessSkor; // 0-100 arası

  const GunlukPlan({
    required this.id,
    required this.tarih,
    required this.kahvalti,
    required this.araOgun1,
    required this.ogle,
    required this.araOgun2,
    required this.aksam,
    this.geceAtistirma,
    required this.fitnessSkor,
  });

  // Toplam makrolar
  double get toplamKalori =>
      kahvalti.kalori +
      araOgun1.kalori +
      ogle.kalori +
      araOgun2.kalori +
      aksam.kalori +
      (geceAtistirma?.kalori ?? 0);

  double get toplamProtein =>
      kahvalti.protein +
      araOgun1.protein +
      ogle.protein +
      araOgun2.protein +
      aksam.protein +
      (geceAtistirma?.protein ?? 0);

  double get toplamKarbonhidrat =>
      kahvalti.karbonhidrat +
      araOgun1.karbonhidrat +
      ogle.karbonhidrat +
      araOgun2.karbonhidrat +
      aksam.karbonhidrat +
      (geceAtistirma?.karbonhidrat ?? 0);

  double get toplamYag =>
      kahvalti.yag +
      araOgun1.yag +
      ogle.yag +
      araOgun2.yag +
      aksam.yag +
      (geceAtistirma?.yag ?? 0);

  List<Yemek> get tumOgunler => [
        kahvalti,
        araOgun1,
        ogle,
        araOgun2,
        aksam,
        if (geceAtistirma != null) geceAtistirma!,
      ];

  @override
  List<Object?> get props => [
        id,
        tarih,
        kahvalti,
        araOgun1,
        ogle,
        araOgun2,
        aksam,
        geceAtistirma,
        fitnessSkor,
      ];

  @override
  String toString() {
    return '''
📅 Günlük Plan (${tarih.day}/${tarih.month}/${tarih.year})
🏆 Fitness Skoru: ${fitnessSkor.toStringAsFixed(1)}/100

🍳 Kahvaltı: ${kahvalti.ad}
🍎 Ara Öğün 1: ${araOgun1.ad}
🍽️  Öğle: ${ogle.ad}
🥤 Ara Öğün 2: ${araOgun2.ad}
🌙 Akşam: ${aksam.ad}
${geceAtistirma != null ? '🌃 Gece: ${geceAtistirma!.ad}' : ''}

📊 TOPLAM MAKROLAR:
   🔥 Kalori: ${toplamKalori.toStringAsFixed(0)} kcal
   💪 Protein: ${toplamProtein.toStringAsFixed(1)} g
   🍚 Karbonhidrat: ${toplamKarbonhidrat.toStringAsFixed(1)} g
   🥑 Yağ: ${toplamYag.toStringAsFixed(1)} g
''';
  }
}

// ============================================================================
// AKILLI ÖĞÜN PLANLAYICI
// ============================================================================

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
    List<String> tercihler = const [],
  }) async {
    print('\n🤖 AKILLI ÖĞÜN PLANLAYICI BAŞLATILDI');
    print('═' * 70);
    print('Hedef Kalori: ${hedefKalori.toStringAsFixed(0)} kcal');
    print('Hedef Protein: ${hedefProtein.toStringAsFixed(0)} g');
    print('Kısıtlamalar: ${kisitlamalar.isEmpty ? "Yok" : kisitlamalar.join(", ")}');
    print('═' * 70);

    // 1. Tüm yemekleri yükle
    print('\n📦 Yemekler yükleniyor...');
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
    print('\n🧬 Genetik algoritma başlatılıyor...');
    final plan = await _genetikAlgoritmaIleEslestir(
      yemekler: uygunYemekler,
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
    );

    print('\n✅ PLAN OLUŞTURULDU!');
    print(plan);

    return plan;
  }

  /// Kısıtlamalara göre yemekleri filtrele
  Map<OgunTipi, List<Yemek>> _kisitlamalariFiltrele(
    Map<OgunTipi, List<Yemek>> tumYemekler,
    List<String> kisitlamalar,
  ) {
    if (kisitlamalar.isEmpty) return tumYemekler;

    return tumYemekler.map((ogun, yemekler) {
      final filtrelenmis = yemekler
          .where((y) => y.kisitlamayaUygunMu(kisitlamalar))
          .toList();
      return MapEntry(ogun, filtrelenmis);
    });
  }

  /// Genetik algoritma ile eşleştirme
  Future<GunlukPlan> _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) async {
    const populasyonBoyutu = 100;
    const jenerasyonSayisi = 50;
    const elitOrani = 0.2; // En iyi %20'yi koru

    // 1. Rastgele popülasyon oluştur
    List<GunlukPlan> populasyon = List.generate(populasyonBoyutu, (_) {
      return _rastgelePlanOlustur(yemekler);
    });

    print('   İlk popülasyon: $populasyonBoyutu birey');

    // 2. Evrim döngüsü
    for (int jenerasyon = 0; jenerasyon < jenerasyonSayisi; jenerasyon++) {
      // Fitness hesapla ve sırala
      populasyon.sort((a, b) => b.fitnessSkor.compareTo(a.fitnessSkor));

      if (jenerasyon % 10 == 0) {
        print('   Jenerasyon $jenerasyon: En iyi skor = ${populasyon.first.fitnessSkor.toStringAsFixed(1)}');
      }

      // En iyi bireyleri seç
      final elitSayisi = (populasyonBoyutu * elitOrani).round();
      final elitler = populasyon.take(elitSayisi).toList();

      // Yeni nesil oluştur
      final yeniNesil = <GunlukPlan>[];

      // Elitleri koru
      yeniNesil.addAll(elitler);

      // Geri kalanı çaprazlama ve mutasyon ile oluştur
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
    populasyon.sort((a, b) => b.fitnessSkor.compareTo(a.fitnessSkor));
    return populasyon.first;
  }

  /// Rastgele plan oluştur
  GunlukPlan _rastgelePlanOlustur(Map<OgunTipi, List<Yemek>> yemekler) {
    final kahvalti = _rastgeleYemekSec(yemekler[OgunTipi.kahvalti]!);
    final araOgun1 = _rastgeleYemekSec(yemekler[OgunTipi.araOgun1]!);
    final ogle = _rastgeleYemekSec(yemekler[OgunTipi.ogle]!);
    final araOgun2 = _rastgeleYemekSec(yemekler[OgunTipi.araOgun2]!);
    final aksam = _rastgeleYemekSec(yemekler[OgunTipi.aksam]!);

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogle: ogle,
      araOgun2: araOgun2,
      aksam: aksam,
      fitnessSkor: 0, // Sonra hesaplanacak
    );
  }

  /// Rastgele yemek seç
  Yemek _rastgeleYemekSec(List<Yemek> yemekler) {
    return yemekler[_random.nextInt(yemekler.length)];
  }

  /// İki planı çaprazla (crossover)
  GunlukPlan _caprazla(
    GunlukPlan parent1,
    GunlukPlan parent2,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    // Rastgele kesim noktası
    final kesimNoktasi = _random.nextInt(5);

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: kesimNoktasi > 0 ? parent1.kahvalti : parent2.kahvalti,
      araOgun1: kesimNoktasi > 1 ? parent1.araOgun1 : parent2.araOgun1,
      ogle: kesimNoktasi > 2 ? parent1.ogle : parent2.ogle,
      araOgun2: kesimNoktasi > 3 ? parent1.araOgun2 : parent2.araOgun2,
      aksam: kesimNoktasi > 4 ? parent1.aksam : parent2.aksam,
      fitnessSkor: 0, // Sonra hesaplanacak
    );
  }

  /// Mutasyon uygula
  GunlukPlan _mutasyonUygula(
    GunlukPlan plan,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    const mutasyonOrani = 0.2; // %20 mutasyon şansı

    if (_random.nextDouble() > mutasyonOrani) {
      return plan; // Mutasyon olma
    }

    // Rastgele bir öğünü değiştir
    final ogunIndex = _random.nextInt(5);

    switch (ogunIndex) {
      case 0:
        return GunlukPlan(
          id: plan.id,
          tarih: plan.tarih,
          kahvalti: _rastgeleYemekSec(yemekler[OgunTipi.kahvalti]!),
          araOgun1: plan.araOgun1,
          ogle: plan.ogle,
          araOgun2: plan.araOgun2,
          aksam: plan.aksam,
          fitnessSkor: 0,
        );
      case 1:
        return GunlukPlan(
          id: plan.id,
          tarih: plan.tarih,
          kahvalti: plan.kahvalti,
          araOgun1: _rastgeleYemekSec(yemekler[OgunTipi.araOgun1]!),
          ogle: plan.ogle,
          araOgun2: plan.araOgun2,
          aksam: plan.aksam,
          fitnessSkor: 0,
        );
      case 2:
        return GunlukPlan(
          id: plan.id,
          tarih: plan.tarih,
          kahvalti: plan.kahvalti,
          araOgun1: plan.araOgun1,
          ogle: _rastgeleYemekSec(yemekler[OgunTipi.ogle]!),
          araOgun2: plan.araOgun2,
          aksam: plan.aksam,
          fitnessSkor: 0,
        );
      case 3:
        return GunlukPlan(
          id: plan.id,
          tarih: plan.tarih,
          kahvalti: plan.kahvalti,
          araOgun1: plan.araOgun1,
          ogle: plan.ogle,
          araOgun2: _rastgeleYemekSec(yemekler[OgunTipi.araOgun2]!),
          aksam: plan.aksam,
          fitnessSkor: 0,
        );
      default:
        return GunlukPlan(
          id: plan.id,
          tarih: plan.tarih,
          kahvalti: plan.kahvalti,
          araOgun1: plan.araOgun1,
          ogle: plan.ogle,
          araOgun2: plan.araOgun2,
          aksam: _rastgeleYemekSec(yemekler[OgunTipi.aksam]!),
          fitnessSkor: 0,
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
    // Sapmaları hesapla
    final kaloriSapma = (plan.toplamKalori - hedefKalori).abs() / hedefKalori;
    final proteinSapma = (plan.toplamProtein - hedefProtein).abs() / hedefProtein;
    final karbSapma = (plan.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb;
    final yagSapma = (plan.toplamYag - hedefYag).abs() / hedefYag;

    // Ağırlıklı ortalama (protein en önemli)
    final toplamSapma = (kaloriSapma * 0.4 +
            proteinSapma * 0.35 +
            karbSapma * 0.15 +
            yagSapma * 0.1)
        .clamp(0.0, 1.0);

    // Fitness: 0 sapma = 100 skor
    return (1 - toplamSapma) * 100;
  }
}

// ============================================================================
// TEST KODLARI
// ============================================================================

void main() async {
  print('\n🧪 FAZ 5 TEST: AKILLI ÖĞÜN EŞLEŞTİRME');
  print('=' * 70);

  // Mock data source oluştur
  final dataSource = YemekLocalDataSource();
  final planlayici = OgunPlanlayici(dataSource: dataSource);

  // Hedefler
  final hedefKalori = 2500.0;
  final hedefProtein = 150.0;
  final hedefKarb = 300.0;
  final hedefYag = 80.0;

  // Plan oluştur
  final plan = await planlayici.gunlukPlanOlustur(
    hedefKalori: hedefKalori,
    hedefProtein: hedefProtein,
    hedefKarb: hedefKarb,
    hedefYag: hedefYag,
    kisitlamalar: ['Süt', 'Yumurta'], // Vegan
  );

  print('\n' + '=' * 70);
  print('✅ FAZ 5 TAMAMLANDI!');
  print('=' * 70);
  print('\nSONRAKİ ADIM: FAZ 6 - Local Storage (Hive)');
}
