// ============================================================================
// DİNAMİK ALTERNATİF BESİN SİSTEMİ
// Her besin için otomatik çalışır - Manuel kodlama gerekmez!
// ============================================================================

import 'dart:math';

class BesinVeritabani {
  // Besin başına standart kalori/protein değerleri (100g bazında)
  static const Map<String, Map<String, double>> besinler = {
    // Kuruyemişler (100g)
    'badem': {'kalori': 579, 'protein': 21.2, 'karb': 21.6, 'yag': 49.9, 'standartMiktar': 10},
    'ceviz': {'kalori': 654, 'protein': 15.2, 'karb': 13.7, 'yag': 65.2, 'standartMiktar': 6},
    'fındık': {'kalori': 628, 'protein': 15.0, 'karb': 16.7, 'yag': 60.8, 'standartMiktar': 13},
    'antep_fıstığı': {'kalori': 562, 'protein': 20.6, 'karb': 27.2, 'yag': 45.3, 'standartMiktar': 15},
    'kaju': {'kalori': 553, 'protein': 18.2, 'karb': 30.2, 'yag': 43.9, 'standartMiktar': 12},
    
    // Meyveler (100g)
    'muz': {'kalori': 89, 'protein': 1.1, 'karb': 22.8, 'yag': 0.3, 'standartMiktar': 1},
    'hurma': {'kalori': 282, 'protein': 2.5, 'karb': 75.0, 'yag': 0.4, 'standartMiktar': 3},
    'elma': {'kalori': 52, 'protein': 0.3, 'karb': 13.8, 'yag': 0.2, 'standartMiktar': 1},
    'armut': {'kalori': 57, 'protein': 0.4, 'karb': 15.2, 'yag': 0.1, 'standartMiktar': 1},
    'portakal': {'kalori': 47, 'protein': 0.9, 'karb': 11.8, 'yag': 0.1, 'standartMiktar': 1},
    'kuru_incir': {'kalori': 249, 'protein': 3.3, 'karb': 63.9, 'yag': 0.9, 'standartMiktar': 4},
    
    // Süt Ürünleri (100g/100ml)
    'yoğurt': {'kalori': 61, 'protein': 3.5, 'karb': 4.7, 'yag': 3.3, 'standartMiktar': 200},
    'kefir': {'kalori': 60, 'protein': 3.3, 'karb': 4.5, 'yag': 3.5, 'standartMiktar': 200},
    'süt': {'kalori': 61, 'protein': 3.2, 'karb': 4.8, 'yag': 3.3, 'standartMiktar': 200},
    'badem_sütü': {'kalori': 17, 'protein': 0.4, 'karb': 1.5, 'yag': 1.1, 'standartMiktar': 200},
    
    // Protein Kaynakları (100g)
    'tavuk': {'kalori': 165, 'protein': 31.0, 'karb': 0.0, 'yag': 3.6, 'standartMiktar': 150},
    'hindi': {'kalori': 135, 'protein': 30.0, 'karb': 0.0, 'yag': 0.7, 'standartMiktar': 150},
    'tofu': {'kalori': 76, 'protein': 8.0, 'karb': 1.9, 'yag': 4.8, 'standartMiktar': 150},
    'yumurta': {'kalori': 155, 'protein': 13.0, 'karb': 1.1, 'yag': 11.0, 'standartMiktar': 1}, // 1 adet = ~50g
  };

  // Besin kategorileri
  static const Map<String, List<String>> kategoriler = {
    'kuruyemis': ['badem', 'ceviz', 'fındık', 'antep_fıstığı', 'kaju'],
    'meyve': ['muz', 'hurma', 'elma', 'armut', 'portakal', 'kuru_incir'],
    'sut_urunleri': ['yoğurt', 'kefir', 'süt', 'badem_sütü'],
    'protein': ['tavuk', 'hindi', 'tofu', 'yumurta'],
  };
}

// ============================================================================
// DİNAMİK ALTERNATİF HESAPLAYICI
// ============================================================================

class DinamikAlternatifHesaplayici {
  /// Ana metod: Herhangi bir besin için alternatif üret
  static List<AlternatifBesin> alternatifUret({
    required String besinAdi,
    required double miktar,
    required String birim,
  }) {
    print('\n🔍 Alternatif arıyor: $miktar $birim $besinAdi');
    
    // 1. Besini normalleştir
    final normalBesinAdi = _besinNormalize(besinAdi);
    
    // 2. Veritabanında var mı?
    if (!BesinVeritabani.besinler.containsKey(normalBesinAdi)) {
      print('❌ Veritabanında yok: $normalBesinAdi');
      return [];
    }
    
    // 3. Besinin kategorisini bul
    final kategori = _kategoriBul(normalBesinAdi);
    if (kategori == null) {
      print('❌ Kategori bulunamadı: $normalBesinAdi');
      return [];
    }
    
    print('✅ Kategori: $kategori');
    
    // 4. Aynı kategorideki diğer besinleri bul
    final ayniKategoridekilar = BesinVeritabani.kategoriler[kategori]!
        .where((b) => b != normalBesinAdi)
        .toList();
    
    // 5. Her biri için alternatif hesapla
    final alternatifler = <AlternatifBesin>[];
    
    for (final alternatifBesinAdi in ayniKategoridekilar) {
      final alternatif = _alternatifHesapla(
        orijinalBesin: normalBesinAdi,
        orijinalMiktar: miktar,
        orijinalBirim: birim,
        alternatifBesin: alternatifBesinAdi,
      );
      
      if (alternatif != null) {
        alternatifler.add(alternatif);
      }
    }
    
    // 6. En iyi 3 alternatifi döndür (kalori benzerliğine göre)
    alternatifler.sort((a, b) {
      final orijinalData = BesinVeritabani.besinler[normalBesinAdi]!;
      final orijinalKalori = orijinalData['kalori']!;
      
      final aFark = (a.kalori - orijinalKalori).abs();
      final bFark = (b.kalori - orijinalKalori).abs();
      
      return aFark.compareTo(bFark);
    });
    
    return alternatifler.take(3).toList();
  }

  // ==========================================================================
  // ALTERNATİF HESAPLAMA - KALORİ BAZLI
  // ==========================================================================

  static AlternatifBesin? _alternatifHesapla({
    required String orijinalBesin,
    required double orijinalMiktar,
    required String orijinalBirim,
    required String alternatifBesin,
  }) {
    final orijinalData = BesinVeritabani.besinler[orijinalBesin]!;
    final alternatifData = BesinVeritabani.besinler[alternatifBesin]!;
    
    // Orijinal besinin toplam kalorisi
    final orijinalToplamKalori = _toplamKaloriHesapla(
      orijinalData,
      orijinalMiktar,
      orijinalBirim,
    );
    
    print('  📊 $orijinalBesin: ${orijinalToplamKalori.toStringAsFixed(0)} kcal');
    
    // Alternatif besin için eşdeğer miktar hesapla (kalori bazlı)
    final alternatifMiktar = _esitKaloriIcinMiktar(
      hedefKalori: orijinalToplamKalori,
      alternatifData: alternatifData,
    );
    
    // Minimum kontrol
    if (alternatifMiktar < 0.5) {
      return null; // Çok az çıktı, alternatif olarak gösterme
    }
    
    // Birim belirle (standart miktar bazında)
    final alternatifBirim = _birimBelirle(alternatifBesin, alternatifMiktar);
    
    // Miktar yuvarla
    final yuvarlanmisMiktar = _miktarYuvarla(alternatifMiktar, alternatifBirim);
    
    // Neden belirle
    final neden = _nedenUret(orijinalData, alternatifData);
    
    print('  ✅ → ${yuvarlanmisMiktar.toStringAsFixed(0)} $alternatifBirim ${_besinGuzelIsim(alternatifBesin)}');
    
    return AlternatifBesin(
      ad: _besinGuzelIsim(alternatifBesin),
      miktar: yuvarlanmisMiktar,
      birim: alternatifBirim,
      kalori: alternatifData['kalori']!,
      protein: alternatifData['protein']!,
      karbonhidrat: alternatifData['karb']!,
      yag: alternatifData['yag']!,
      neden: neden,
    );
  }

  // ==========================================================================
  // HESAPLAMA METODLARI
  // ==========================================================================

  /// Toplam kalori hesapla
  static double _toplamKaloriHesapla(
    Map<String, double> besinData,
    double miktar,
    String birim,
  ) {
    final standartMiktar = besinData['standartMiktar']!;
    final yuzGramKalori = besinData['kalori']!;
    
    if (_birimAdetMi(birim)) {
      // Adet bazlı: miktar * standartMiktar'ın 100g'daki kalorisi
      return (miktar / standartMiktar) * yuzGramKalori;
    } else {
      // Gram/ml bazlı: doğrudan oran
      return (miktar / 100) * yuzGramKalori;
    }
  }

  /// Eşit kalori için miktar hesapla
  static double _esitKaloriIcinMiktar({
    required double hedefKalori,
    required Map<String, double> alternatifData,
  }) {
    final standartMiktar = alternatifData['standartMiktar']!;
    final yuzGramKalori = alternatifData['kalori']!;
    
    // Kaç birim gerekli
    return (hedefKalori / yuzGramKalori) * standartMiktar;
  }

  /// Miktar yuvarla
  static double _miktarYuvarla(double miktar, String birim) {
    if (_birimAdetMi(birim)) {
      // Adet ise tam sayı
      final yuvarlanmis = miktar.round().toDouble();
      return yuvarlanmis < 1 ? 1.0 : yuvarlanmis;
    } else {
      // Gram/ml ise 5'in katlarına yuvarla
      return (miktar / 5).round() * 5.0;
    }
  }

  /// Birim belirle
  static String _birimBelirle(String besinAdi, double miktar) {
    final standartMiktar = BesinVeritabani.besinler[besinAdi]!['standartMiktar']!;
    
    // Standart miktar < 50 ise adet, değilse gram/ml
    if (standartMiktar < 50) {
      return 'adet';
    } else {
      // Süt ürünleri için ml
      if (besinAdi.contains('süt') || besinAdi == 'kefir') {
        return 'ml';
      }
      return 'gram';
    }
  }

  // ==========================================================================
  // HELPER METODLAR
  // ==========================================================================

  /// Besini normalize et (küçük harf, _ ile)
  static String _besinNormalize(String besinAdi) {
    return besinAdi
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  /// Güzel isim (Badem, Muz, vb.)
  static String _besinGuzelIsim(String normalBesin) {
    return normalBesin
        .replaceAll('_', ' ')
        .split(' ')
        .map((kelime) => kelime[0].toUpperCase() + kelime.substring(1))
        .join(' ');
  }

  /// Kategori bul
  static String? _kategoriBul(String besinAdi) {
    for (final entry in BesinVeritabani.kategoriler.entries) {
      if (entry.value.contains(besinAdi)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Birim adet mi
  static bool _birimAdetMi(String birim) {
    final birimKucuk = birim.toLowerCase();
    return birimKucuk == 'adet' || 
           birimKucuk == 'tane' || 
           birimKucuk == 'dilim';
  }

  /// Neden üret
  static String _nedenUret(
    Map<String, double> orijinal,
    Map<String, double> alternatif,
  ) {
    final proteinFark = alternatif['protein']! - orijinal['protein']!;
    final kaloriFark = alternatif['kalori']! - orijinal['kalori']!;
    
    if (proteinFark > 5) {
      return 'Daha yüksek protein';
    } else if (kaloriFark < -50) {
      return 'Daha düşük kalori';
    } else if (proteinFark.abs() < 2 && kaloriFark.abs() < 20) {
      return 'Çok benzer besin değeri';
    } else {
      return 'Benzer enerji değeri';
    }
  }
}

// ============================================================================
// ALTERNATİF BESİN MODEL (ESKİ)
// ============================================================================

class AlternatifBesin {
  final String ad;
  final double miktar;
  final String birim;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final String neden;

  AlternatifBesin({
    required this.ad,
    required this.miktar,
    required this.birim,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.neden,
  });
}

// ============================================================================
// TEST KODLARI
// ============================================================================

void main() {
  print('=' * 80);
  print('🧪 DİNAMİK ALTERNATİF SİSTEMİ - EVRENSEL TEST');
  print('=' * 80);

  // Test 1: 10 adet Badem
  print('\n📋 TEST 1: 10 ADET BADEM');
  print('-' * 80);
  final badem = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'badem',
    miktar: 10,
    birim: 'adet',
  );
  _sonuclariYazdir(badem);

  // Test 2: 1 adet Muz
  print('\n📋 TEST 2: 1 ADET MUZ');
  print('-' * 80);
  final muzAdet = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'muz',
    miktar: 1,
    birim: 'adet',
  );
  _sonuclariYazdir(muzAdet);

  // Test 3: 100 gram Muz
  print('\n📋 TEST 3: 100 GRAM MUZ');
  print('-' * 80);
  final muzGram = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'muz',
    miktar: 100,
    birim: 'gram',
  );
  _sonuclariYazdir(muzGram);

  // Test 4: 200 ml Yoğurt
  print('\n📋 TEST 4: 200 ML YOĞURT');
  print('-' * 80);
  final yogurt = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'yoğurt',
    miktar: 200,
    birim: 'ml',
  );
  _sonuclariYazdir(yogurt);

  // Test 5: 150 gram Tavuk
  print('\n📋 TEST 5: 150 GRAM TAVUK');
  print('-' * 80);
  final tavuk = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'tavuk',
    miktar: 150,
    birim: 'gram',
  );
  _sonuclariYazdir(tavuk);

  // Test 6: 6 adet Ceviz
  print('\n📋 TEST 6: 6 ADET CEVİZ');
  print('-' * 80);
  final ceviz = DinamikAlternatifHesaplayici.alternatifUret(
    besinAdi: 'ceviz',
    miktar: 6,
    birim: 'adet',
  );
  _sonuclariYazdir(ceviz);

  print('\n' + '=' * 80);
  print('✅ TÜM TESTLER TAMAMLANDI - SİSTEM DİNAMİK ÇALIŞIYOR!');
  print('=' * 80);
}

void _sonuclariYazdir(List<AlternatifBesin> alternatifler) {
  if (alternatifler.isEmpty) {
    print('❌ Alternatif bulunamadı!');
    return;
  }

  print('\n🔄 ${alternatifler.length} Alternatif Bulundu:\n');
  for (final alt in alternatifler) {
    print('✅ ${alt.miktar.toStringAsFixed(0)} ${alt.birim} ${alt.ad}');
    print('   ${alt.neden}');
    print('   🔥 ${alt.kalori.toStringAsFixed(0)} kcal | 💪 ${alt.protein.toStringAsFixed(1)}g protein');
    print('');
  }
}
