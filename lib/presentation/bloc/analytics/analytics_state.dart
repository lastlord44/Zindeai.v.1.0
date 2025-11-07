// ============================================================================
// ANALYTICS STATES - FAZ 10
// ============================================================================

import 'package:equatable/equatable.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/antrenman.dart';

/// Analytics veri modeli
class AnalyticsData {
  final List<GunlukPlan> planlar;
  final List<TamamlananAntrenman> antrenmanlar;
  final Map<DateTime, MacroValues> gunlukMakrolar;
  final Map<String, int> enCokYenilenYemekler;
  final HedefTutturmaIstatistikleri hedefTutturma;
  final IlerlemeTrendi trend;

  const AnalyticsData({
    required this.planlar,
    required this.antrenmanlar,
    required this.gunlukMakrolar,
    required this.enCokYenilenYemekler,
    required this.hedefTutturma,
    required this.trend,
  });
}

/// Günlük makro değerleri
class MacroValues {
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final DateTime tarih;

  const MacroValues({
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.tarih,
  });

  /// Hedef değerlere göre uyum yüzdesi
  double uyumYuzdesi(MacroValues hedef) {
    final kaloriUyum = 100 - ((kalori - hedef.kalori).abs() / hedef.kalori * 100);
    final proteinUyum = 100 - ((protein - hedef.protein).abs() / hedef.protein * 100);
    final karbUyum = 100 - ((karbonhidrat - hedef.karbonhidrat).abs() / hedef.karbonhidrat * 100);
    final yagUyum = 100 - ((yag - hedef.yag).abs() / hedef.yag * 100);
    
    return (kaloriUyum + proteinUyum + karbUyum + yagUyum) / 4;
  }
}

/// Hedef tutturma istatistikleri
class HedefTutturmaIstatistikleri {
  final double ortalamaTutturmaYuzdesi;
  final int basariliGunSayisi;
  final int toplamGunSayisi;
  final Map<String, double> makroBazindaTutturma;

  const HedefTutturmaIstatistikleri({
    required this.ortalamaTutturmaYuzdesi,
    required this.basariliGunSayisi,
    required this.toplamGunSayisi,
    required this.makroBazindaTutturma,
  });

  double get basariOrani => toplamGunSayisi > 0 
      ? (basariliGunSayisi / toplamGunSayisi) * 100 
      : 0;
}

/// İlerleme trendi
class IlerlemeTrendi {
  final TrendYonu kaloriTrendi;
  final TrendYonu proteinTrendi;
  final TrendYonu karbonhidratTrendi;
  final TrendYonu yagTrendi;
  final TrendYonu antrenmanTrendi;
  final double trendGucu; // -100 ile +100 arası

  const IlerlemeTrendi({
    required this.kaloriTrendi,
    required this.proteinTrendi,
    required this.karbonhidratTrendi,
    required this.yagTrendi,
    required this.antrenmanTrendi,
    required this.trendGucu,
  });
}

enum TrendYonu {
  yukseliyor, // Artış var
  dusuyor,    // Azalış var
  sabit,      // Değişim yok
  yetersizVeri; // Henüz yeterli veri yok

  String get displayName {
    switch (this) {
      case TrendYonu.yukseliyor:
        return 'Yükseliyor';
      case TrendYonu.dusuyor:
        return 'Düşüyor';
      case TrendYonu.sabit:
        return 'Sabit';
      case TrendYonu.yetersizVeri:
        return 'Yetersiz Veri';
    }
  }

  String get emoji {
    switch (this) {
      case TrendYonu.yukseliyor:
        return '📈';
      case TrendYonu.dusuyor:
        return '📉';
      case TrendYonu.sabit:
        return '➡️';
      case TrendYonu.yetersizVeri:
        return '❓';
    }
  }
}

// ============================================================================
// STATES
// ============================================================================

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// İlk durum
class AnalyticsInitial extends AnalyticsState {}

/// Yükleniyor
class AnalyticsLoading extends AnalyticsState {
  final String? mesaj;

  AnalyticsLoading({this.mesaj});

  @override
  List<Object?> get props => [mesaj];
}

/// Haftalık analytics yüklendi
class WeeklyAnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  final DateTime baslangicTarihi;
  final DateTime bitisTarihi;

  WeeklyAnalyticsLoaded({
    required this.data,
    required this.baslangicTarihi,
    required this.bitisTarihi,
  });

  int get gunSayisi => bitisTarihi.difference(baslangicTarihi).inDays + 1;

  /// Ortalama günlük kalori
  double get ortalamaKalori {
    if (data.gunlukMakrolar.isEmpty) return 0;
    final toplam = data.gunlukMakrolar.values
        .fold<double>(0, (sum, makro) => sum + makro.kalori);
    return toplam / data.gunlukMakrolar.length;
  }

  /// Ortalama günlük protein
  double get ortalamaProtein {
    if (data.gunlukMakrolar.isEmpty) return 0;
    final toplam = data.gunlukMakrolar.values
        .fold<double>(0, (sum, makro) => sum + makro.protein);
    return toplam / data.gunlukMakrolar.length;
  }

  /// Ortalama günlük karbonhidrat
  double get ortalamaKarbonhidrat {
    if (data.gunlukMakrolar.isEmpty) return 0;
    final toplam = data.gunlukMakrolar.values
        .fold<double>(0, (sum, makro) => sum + makro.karbonhidrat);
    return toplam / data.gunlukMakrolar.length;
  }

  /// Ortalama günlük yağ
  double get ortalamaYag {
    if (data.gunlukMakrolar.isEmpty) return 0;
    final toplam = data.gunlukMakrolar.values
        .fold<double>(0, (sum, makro) => sum + makro.yag);
    return toplam / data.gunlukMakrolar.length;
  }

  @override
  List<Object?> get props => [data, baslangicTarihi, bitisTarihi];
}

/// Aylık analytics yüklendi
class MonthlyAnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  final DateTime baslangicTarihi;
  final DateTime bitisTarihi;

  MonthlyAnalyticsLoaded({
    required this.data,
    required this.baslangicTarihi,
    required this.bitisTarihi,
  });

  int get gunSayisi => bitisTarihi.difference(baslangicTarihi).inDays + 1;

  @override
  List<Object?> get props => [data, baslangicTarihi, bitisTarihi];
}

/// Özel tarih aralığı analytics yüklendi
class CustomRangeAnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  final DateTime baslangic;
  final DateTime bitis;

  CustomRangeAnalyticsLoaded({
    required this.data,
    required this.baslangic,
    required this.bitis,
  });

  int get gunSayisi => bitis.difference(baslangic).inDays + 1;

  @override
  List<Object?> get props => [data, baslangic, bitis];
}

/// Makro trend verileri yüklendi
class MacroTrendsLoaded extends AnalyticsState {
  final Map<DateTime, MacroValues> trendVerileri;
  final IlerlemeTrendi genelTrend;

  MacroTrendsLoaded({
    required this.trendVerileri,
    required this.genelTrend,
  });

  @override
  List<Object?> get props => [trendVerileri, genelTrend];
}

/// Antrenman istatistikleri yüklendi
class WorkoutStatsLoaded extends AnalyticsState {
  final List<TamamlananAntrenman> antrenmanlar;
  final int toplamAntrenmanSayisi;
  final int toplamYakilanKalori;
  final int ortalamaSure; // Saniye
  final Map<String, int> programBazindaSayilar;

  WorkoutStatsLoaded({
    required this.antrenmanlar,
    required this.toplamAntrenmanSayisi,
    required this.toplamYakilanKalori,
    required this.ortalamaSure,
    required this.programBazindaSayilar,
  });

  /// Ortalama günlük antrenman (son N günde)
  double ortalamaGunlukAntrenman(int gunSayisi) {
    return gunSayisi > 0 ? toplamAntrenmanSayisi / gunSayisi : 0;
  }

  @override
  List<Object?> get props => [
        antrenmanlar,
        toplamAntrenmanSayisi,
        toplamYakilanKalori,
        ortalamaSure,
        programBazindaSayilar,
      ];
}

/// Favori yemekler yüklendi
class FavoriteMealsLoaded extends AnalyticsState {
  final Map<String, int> yemekSayilari; // Yemek adı -> Kaç kez yendiği
  final List<MapEntry<String, int>> siraliFavoriler;

  FavoriteMealsLoaded({
    required this.yemekSayilari,
  }) : siraliFavoriler = yemekSayilari.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

  /// En çok yenilen N yemek
  List<MapEntry<String, int>> topN(int n) {
    return siraliFavoriler.take(n).toList();
  }

  @override
  List<Object?> get props => [yemekSayilari];
}

/// Hedef tutturma hesaplandı
class GoalAdherenceCalculated extends AnalyticsState {
  final HedefTutturmaIstatistikleri istatistikler;
  final Map<DateTime, double> gunlukTutturma;

  GoalAdherenceCalculated({
    required this.istatistikler,
    required this.gunlukTutturma,
  });

  @override
  List<Object?> get props => [istatistikler, gunlukTutturma];
}

/// İlerleme karşılaştırması yüklendi
class ProgressComparisonLoaded extends AnalyticsState {
  final MacroValues oncekiDonemOrtalama;
  final MacroValues sonrakiDonemOrtalama;
  final Map<String, double> degisimYuzdeleri;
  final bool ilerlemVarMi;

  ProgressComparisonLoaded({
    required this.oncekiDonemOrtalama,
    required this.sonrakiDonemOrtalama,
    required this.degisimYuzdeleri,
    required this.ilerlemVarMi,
  });

  @override
  List<Object?> get props => [
        oncekiDonemOrtalama,
        sonrakiDonemOrtalama,
        degisimYuzdeleri,
        ilerlemVarMi,
      ];
}

/// Hata durumu
class AnalyticsError extends AnalyticsState {
  final String mesaj;
  final Object? error;

  AnalyticsError(this.mesaj, {this.error});

  @override
  List<Object?> get props => [mesaj, error];
}