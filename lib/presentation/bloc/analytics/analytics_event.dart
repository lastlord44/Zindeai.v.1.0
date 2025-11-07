// ============================================================================
// ANALYTICS EVENTS - FAZ 10
// ============================================================================

import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Haftalık istatistikleri yükle (7 gün)
class LoadWeeklyAnalytics extends AnalyticsEvent {
  final DateTime? baslangicTarihi;

  LoadWeeklyAnalytics({this.baslangicTarihi});

  @override
  List<Object?> get props => [baslangicTarihi];
}

/// Aylık istatistikleri yükle (30 gün)
class LoadMonthlyAnalytics extends AnalyticsEvent {
  final DateTime? baslangicTarihi;

  LoadMonthlyAnalytics({this.baslangicTarihi});

  @override
  List<Object?> get props => [baslangicTarihi];
}

/// Özel tarih aralığı istatistikleri yükle
class LoadCustomRangeAnalytics extends AnalyticsEvent {
  final DateTime baslangic;
  final DateTime bitis;

  LoadCustomRangeAnalytics({
    required this.baslangic,
    required this.bitis,
  });

  @override
  List<Object?> get props => [baslangic, bitis];
}

/// Makro trend verilerini yükle
class LoadMacroTrends extends AnalyticsEvent {}

/// Antrenman istatistiklerini yükle
class LoadWorkoutStats extends AnalyticsEvent {
  final int gunSayisi;

  LoadWorkoutStats({this.gunSayisi = 30});

  @override
  List<Object?> get props => [gunSayisi];
}

/// En çok yenilen yemekleri yükle
class LoadFavoriteMeals extends AnalyticsEvent {
  final int limit;

  LoadFavoriteMeals({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Hedef tutturma yüzdesini hesapla
class CalculateGoalAdherence extends AnalyticsEvent {
  final int gunSayisi;

  CalculateGoalAdherence({this.gunSayisi = 30});

  @override
  List<Object?> get props => [gunSayisi];
}

/// İlerleme karşılaştırması yükle
class LoadProgressComparison extends AnalyticsEvent {
  final DateTime oncekiTarih;
  final DateTime sonrakiTarih;

  LoadProgressComparison({
    required this.oncekiTarih,
    required this.sonrakiTarih,
  });

  @override
  List<Object?> get props => [oncekiTarih, sonrakiTarih];
}

/// Analytics verilerini yenile
class RefreshAnalytics extends AnalyticsEvent {}