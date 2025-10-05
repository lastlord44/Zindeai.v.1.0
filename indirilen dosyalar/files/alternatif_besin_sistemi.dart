// ============================================================================
// ALTERNATİF BESİN SİSTEMİ
// ============================================================================

import 'package:equatable/equatable.dart';

// ============================================================================
// ALTERNATİF BESİN MODELİ
// ============================================================================

class AlternatifBesin extends Equatable {
  final String ad;
  final double miktar;
  final String birim;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final String neden; // Neden alternatif (örn: "Benzer protein profili")
  
  const AlternatifBesin({
    required this.ad,
    required this.miktar,
    required this.birim,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.neden,
  });

  @override
  List<Object?> get props => [ad, miktar, birim, kalori, protein, karbonhidrat, yag, neden];

  factory AlternatifBesin.fromJson(Map<String, dynamic> json) {
    return AlternatifBesin(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      neden: json['neden'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'miktar': miktar,
      'birim': birim,
      'kalori': kalori,
      'protein': protein,
      'karbonhidrat': karbonhidrat,
      'yag': yag,
      'neden': neden,
    };
  }
}

// ============================================================================
// BESİN İÇERİĞİ (Meal model'e eklenecek)
// ============================================================================

class BesinIcerigi extends Equatable {
  final String ad;
  final double miktar;
  final String birim;
  final List<AlternatifBesin> alternatifler;

  const BesinIcerigi({
    required this.ad,
    required this.miktar,
    required this.birim,
    this.alternatifler = const [],
  });

  @override
  List<Object?> get props => [ad, miktar, birim, alternatifler];

  factory BesinIcerigi.fromJson(Map<String, dynamic> json) {
    final alternatiflerJson = json['alternatifler'] as List<dynamic>?;
    final alternatifler = alternatiflerJson
        ?.map((a) => AlternatifBesin.fromJson(a as Map<String, dynamic>))
        .toList() ?? [];

    return BesinIcerigi(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      alternatifler: alternatifler,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'miktar': miktar,
      'birim': birim,
      'alternatifler': alternatifler.map((a) => a.toJson()).toList(),
    };
  }
}

// ============================================================================
// ALTERNATİF ÖNERİ SERVİSİ
// ============================================================================

class AlternatifOneriServisi {
  /// Belirli bir besine otomatik alternatif üret
  static List<AlternatifBesin> otomatikAlternatifUret(
    String besinAdi,
    double miktar,
    String birim,
  ) {
    final alternatives = <AlternatifBesin>[];
    final besinKucuk = besinAdi.toLowerCase();

    // KURUYEMIŞLER
    if (besinKucuk.contains('badem')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Fındık',
          miktar: miktar * 1.3,
          birim: birim,
          kalori: 180,
          protein: 4.2,
          karbonhidrat: 5.0,
          yag: 17.0,
          neden: 'Benzer yağ ve protein profili',
        ),
        AlternatifBesin(
          ad: 'Ceviz',
          miktar: miktar * 0.6,
          birim: birim,
          kalori: 185,
          protein: 4.3,
          karbonhidrat: 3.9,
          yag: 18.5,
          neden: 'Yüksek Omega-3 içeriği',
        ),
        AlternatifBesin(
          ad: 'Antep Fıstığı',
          miktar: miktar * 1.5,
          birim: birim,
          kalori: 160,
          protein: 6.0,
          karbonhidrat: 8.0,
          yag: 13.0,
          neden: 'Daha yüksek protein',
        ),
      ]);
    } else if (besinKucuk.contains('ceviz')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Badem',
          miktar: miktar * 1.7,
          birim: birim,
          kalori: 170,
          protein: 6.0,
          karbonhidrat: 6.0,
          yag: 15.0,
          neden: 'Benzer besin değeri',
        ),
        AlternatifBesin(
          ad: 'Pekan Cevizi',
          miktar: miktar * 0.9,
          birim: birim,
          kalori: 195,
          protein: 2.6,
          karbonhidrat: 4.0,
          yag: 20.0,
          neden: 'Ceviz ailesinden',
        ),
      ]);
    } else if (besinKucuk.contains('fındık')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Badem',
          miktar: miktar * 0.8,
          birim: birim,
          kalori: 170,
          protein: 6.0,
          karbonhidrat: 6.0,
          yag: 15.0,
          neden: 'Benzer yağ profili',
        ),
        AlternatifBesin(
          ad: 'Kaju',
          miktar: miktar * 1.2,
          birim: birim,
          kalori: 155,
          protein: 5.2,
          karbonhidrat: 9.0,
          yag: 12.0,
          neden: 'Daha yumuşak tat',
        ),
      ]);
    }

    // MEYVELER
    else if (besinKucuk.contains('elma')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Armut',
          miktar: miktar,
          birim: birim,
          kalori: 57,
          protein: 0.4,
          karbonhidrat: 15.0,
          yag: 0.1,
          neden: 'Benzer lif içeriği',
        ),
        AlternatifBesin(
          ad: 'Portakal',
          miktar: miktar,
          birim: birim,
          kalori: 47,
          protein: 0.9,
          karbonhidrat: 12.0,
          yag: 0.1,
          neden: 'Yüksek C vitamini',
        ),
      ]);
    } else if (besinKucuk.contains('muz')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Hurma',
          miktar: miktar * 0.3,
          birim: 'adet',
          kalori: 66,
          protein: 0.4,
          karbonhidrat: 18.0,
          yag: 0.0,
          neden: 'Benzer enerji değeri',
        ),
        AlternatifBesin(
          ad: 'İncir (Kuru)',
          miktar: miktar * 0.4,
          birim: 'adet',
          kalori: 74,
          protein: 0.8,
          karbonhidrat: 19.0,
          yag: 0.3,
          neden: 'Yüksek lif',
        ),
      ]);
    }

    // SÜT ÜRÜNLERİ
    else if (besinKucuk.contains('yoğurt')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Kefir',
          miktar: miktar,
          birim: birim,
          kalori: 60,
          protein: 3.3,
          karbonhidrat: 4.5,
          yag: 3.5,
          neden: 'Probiyotik açısından zengin',
        ),
        AlternatifBesin(
          ad: 'Ayran',
          miktar: miktar * 1.5,
          birim: birim,
          kalori: 40,
          protein: 1.5,
          karbonhidrat: 3.0,
          yag: 2.0,
          neden: 'Daha hafif seçenek',
        ),
      ]);
    } else if (besinKucuk.contains('süt')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Badem Sütü',
          miktar: miktar,
          birim: birim,
          kalori: 17,
          protein: 0.4,
          karbonhidrat: 1.5,
          yag: 1.1,
          neden: 'Laktozsuz alternatif',
        ),
        AlternatifBesin(
          ad: 'Yulaf Sütü',
          miktar: miktar,
          birim: birim,
          kalori: 48,
          protein: 1.0,
          karbonhidrat: 9.0,
          yag: 1.0,
          neden: 'Veganlar için',
        ),
      ]);
    }

    // PROTEİN KAYNAKLARI
    else if (besinKucuk.contains('tavuk')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Hindi',
          miktar: miktar,
          birim: birim,
          kalori: 110,
          protein: 24.0,
          karbonhidrat: 0.0,
          yag: 1.5,
          neden: 'Daha az yağlı',
        ),
        AlternatifBesin(
          ad: 'Tofu',
          miktar: miktar * 1.2,
          birim: birim,
          kalori: 76,
          protein: 8.0,
          karbonhidrat: 1.9,
          yag: 4.8,
          neden: 'Vejetaryen protein',
        ),
      ]);
    } else if (besinKucuk.contains('yumurta')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Lor Peyniri',
          miktar: miktar * 50,
          birim: 'gram',
          kalori: 98,
          protein: 11.0,
          karbonhidrat: 3.4,
          yag: 4.3,
          neden: 'Benzer protein',
        ),
        AlternatifBesin(
          ad: 'Tofu Scramble',
          miktar: miktar * 80,
          birim: 'gram',
          kalori: 76,
          protein: 8.0,
          karbonhidrat: 1.9,
          yag: 4.8,
          neden: 'Vegan alternatif',
        ),
      ]);
    }

    // KARBONHIDRAT KAYNAKLARI
    else if (besinKucuk.contains('ekmek')) {
      alternatives.addAll([
        AlternatifBesin(
          ad: 'Ezine Ekmeği',
          miktar: miktar,
          birim: birim,
          kalori: 245,
          protein: 8.0,
          karbonhidrat: 49.0,
          yag: 1.2,
          neden: 'Daha besleyici',
        ),
        AlternatifBesin(
          ad: 'Yulaf Ekmeği',
          miktar: miktar,
          birim: birim,
          kalori: 250,
          protein: 8.5,
          karbonhidrat: 48.0,
          yag: 2.5,
          neden: 'Yüksek lif',
        ),
      ]);
    }

    return alternatives;
  }

  /// Alternatifi orijinal besinle karşılaştır
  static String karsilastir(
    double orijinalKalori,
    double alternatifKalori,
    double orijinalProtein,
    double alternatifProtein,
  ) {
    final kaloriFark = ((alternatifKalori - orijinalKalori) / orijinalKalori * 100).abs();
    final proteinFark = ((alternatifProtein - orijinalProtein) / orijinalProtein * 100).abs();

    if (kaloriFark < 10 && proteinFark < 10) {
      return '✅ Çok benzer besin değeri';
    } else if (kaloriFark < 20 && proteinFark < 20) {
      return '🔄 Benzer besin değeri';
    } else if (alternatifProtein > orijinalProtein) {
      return '💪 Daha yüksek protein';
    } else if (alternatifKalori < orijinalKalori) {
      return '🔥 Daha düşük kalori';
    } else {
      return '⚖️ Farklı besin profili';
    }
  }
}

// ============================================================================
// ÖRNEK KULLANIM
// ============================================================================

void main() {
  print('🔄 ALTERNATİF ÖNERİ SİSTEMİ TEST\n');
  print('=' * 60);

  // Test 1: Badem alternatifi
  print('\n📋 TEST 1: BADEM ALTERNATİFİ');
  print('-' * 60);
  final bademAlternatifleri = AlternatifOneriServisi.otomatikAlternatifUret(
    'Badem',
    10,
    'adet',
  );

  print('❌ Orijinal: 10 Badem (Alerjiniz var!)');
  print('\n🔄 Alternatifler:');
  for (final alt in bademAlternatifleri) {
    print('   ✅ ${alt.miktar.toStringAsFixed(0)} ${alt.birim} ${alt.ad}');
    print('      ${alt.neden}');
    print('      ${alt.kalori.toStringAsFixed(0)} kcal | P: ${alt.protein}g | K: ${alt.karbonhidrat}g | Y: ${alt.yag}g');
    print('');
  }

  // Test 2: Elma alternatifi
  print('\n📋 TEST 2: ELMA ALTERNATİFİ');
  print('-' * 60);
  final elmaAlternatifleri = AlternatifOneriServisi.otomatikAlternatifUret(
    'Elma',
    1,
    'adet',
  );

  print('❌ Orijinal: 1 Elma (Bulamıyorum!)');
  print('\n🔄 Alternatifler:');
  for (final alt in elmaAlternatifleri) {
    print('   ✅ ${alt.miktar.toStringAsFixed(0)} ${alt.birim} ${alt.ad}');
    print('      ${alt.neden}');
    print('      ${alt.kalori.toStringAsFixed(0)} kcal | P: ${alt.protein}g');
    print('');
  }

  // Test 3: Tavuk alternatifi
  print('\n📋 TEST 3: TAVUK ALTERNATİFİ');
  print('-' * 60);
  final tavukAlternatifleri = AlternatifOneriServisi.otomatikAlternatifUret(
    'Tavuk Göğsü',
    150,
    'gram',
  );

  print('❌ Orijinal: 150 gram Tavuk Göğsü (Vegan!)');
  print('\n🔄 Alternatifler:');
  for (final alt in tavukAlternatifleri) {
    print('   ✅ ${alt.miktar.toStringAsFixed(0)} ${alt.birim} ${alt.ad}');
    print('      ${alt.neden}');
    print('      ${alt.kalori.toStringAsFixed(0)} kcal | P: ${alt.protein}g');
    print('');
  }

  print('=' * 60);
  print('✅ TÜM TESTLER TAMAMLANDI!');
}
