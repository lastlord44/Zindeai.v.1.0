// ============================================================================
// ANALYTICS BLOC - FAZ 10
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../data/local/hive_service.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class AnalyticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// İstatistikleri yükle
class LoadAnalytics extends AnalyticsEvent {
  final int gunSayisi;

  LoadAnalytics({this.gunSayisi = 30});

  @override
  List<Object?> get props => [gunSayisi];
}

/// Haftalık istatistikleri yükle
class LoadWeeklyAnalytics extends AnalyticsEvent {}

/// Aylık istatistikleri yükle
class LoadMonthlyAnalytics extends AnalyticsEvent {}

// ============================================================================
// STATES
// ============================================================================

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

/// İstatistikler yüklendi
class AnalyticsLoaded extends AnalyticsState {
  final List<GunlukPlan> planlar;
  final int gunSayisi;
  final double ortalamaKalori;
  final double ortalamaProtein;
  final double ortalamaKarbonhidrat;
  final double ortalamaYag;
  final double ortalamaFitnessSkoru;

  AnalyticsLoaded({
    required this.planlar,
    required this.gunSayisi,
    required this.ortalamaKalori,
    required this.ortalamaProtein,
    required this.ortalamaKarbonhidrat,
    required this.ortalamaYag,
    required this.ortalamaFitnessSkoru,
  });

  /// Toplam plan sayısı
  int get toplamPlanSayisi => planlar.length;

  /// En yüksek kalori günü
  GunlukPlan? get enYuksekKaloriGunu {
    if (planlar.isEmpty) return null;
    return planlar.reduce((a, b) => a.toplamKalori > b.toplamKalori ? a : b);
  }

  /// En düşük kalori günü
  GunlukPlan? get enDusukKaloriGunu {
    if (planlar.isEmpty) return null;
    return planlar.reduce((a, b) => a.toplamKalori < b.toplamKalori ? a : b);
  }

  /// Günlük kalori dağılımı (grafikler için)
  List<double> get gunlukKaloriDagilimi {
    return planlar.map((p) => p.toplamKalori).toList();
  }

  /// Günlük protein dağılımı (grafikler için)
  List<double> get gunlukProteinDagilimi {
    return planlar.map((p) => p.toplamProtein).toList();
  }

  /// Günlük karbonhidrat dağılımı (grafikler için)
  List<double> get gunlukKarbonhidratDagilimi {
    return planlar.map((p) => p.toplamKarbonhidrat).toList();
  }

  /// Günlük yağ dağılımı (grafikler için)
  List<double> get gunlukYagDagilimi {
    return planlar.map((p) => p.toplamYag).toList();
  }

  /// Günlük fitness skoru dağılımı (grafikler için)
  List<double> get gunlukFitnessSkoruDagilimi {
    return planlar.map((p) => p.fitnessSkoru).toList();
  }

  /// Tarihler (X ekseni için)
  List<DateTime> get tarihler {
    return planlar.map((p) => p.tarih).toList();
  }

  /// Hedef tutturma oranı (%)
  double hedefTutturmaOrani(double hedefKalori) {
    if (planlar.isEmpty || hedefKalori == 0) return 0;

    final hedefTutturalanlar = planlar.where((plan) {
      final fark = (plan.toplamKalori - hedefKalori).abs();
      final tolerans = hedefKalori * 0.05; // 🔥 FIX: %5 tolerans (GunlukPlan ile tutarlı)
      return fark <= tolerans;
    }).length;

    return (hedefTutturalanlar / planlar.length) * 100;
  }

  @override
  List<Object?> get props => [
        planlar,
        gunSayisi,
        ortalamaKalori,
        ortalamaProtein,
        ortalamaKarbonhidrat,
        ortalamaYag,
        ortalamaFitnessSkoru,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String mesaj;

  AnalyticsError(this.mesaj);

  @override
  List<Object?> get props => [mesaj];
}

// ============================================================================
// BLOC
// ============================================================================

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadWeeklyAnalytics>(_onLoadWeeklyAnalytics);
    on<LoadMonthlyAnalytics>(_onLoadMonthlyAnalytics);
  }

  /// İstatistikleri yükle
  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    try {
      // Son N günün planlarını al
      final planlar = await HiveService.sonPlanlariGetir(gun: event.gunSayisi);

      if (planlar.isEmpty) {
        emit(AnalyticsError(
            'Henüz analiz yapılacak veri yok. Lütfen önce günlük planlar oluşturun.'));
        return;
      }

      // İstatistikleri hesapla
      final ortalamaKalori =
          await HiveService.ortalamaGunlukKalori(gun: event.gunSayisi);
      final ortalamaProtein =
          await HiveService.ortalamaGunlukProtein(gun: event.gunSayisi);
      final ortalamaKarbonhidrat =
          await HiveService.ortalamaGunlukKarbonhidrat(gun: event.gunSayisi);
      final ortalamaYag =
          await HiveService.ortalamaGunlukYag(gun: event.gunSayisi);
      final ortalamaFitnessSkoru =
          await HiveService.ortalamaFitnessSkoru(gun: event.gunSayisi);

      emit(AnalyticsLoaded(
        planlar: planlar,
        gunSayisi: event.gunSayisi,
        ortalamaKalori: ortalamaKalori,
        ortalamaProtein: ortalamaProtein,
        ortalamaKarbonhidrat: ortalamaKarbonhidrat,
        ortalamaYag: ortalamaYag,
        ortalamaFitnessSkoru: ortalamaFitnessSkoru,
      ));
    } catch (e) {
      emit(AnalyticsError('İstatistikler yüklenirken hata: $e'));
    }
  }

  /// Haftalık istatistikleri yükle (son 7 gün)
  Future<void> _onLoadWeeklyAnalytics(
    LoadWeeklyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    add(LoadAnalytics(gunSayisi: 7));
  }

  /// Aylık istatistikleri yükle (son 30 gün)
  Future<void> _onLoadMonthlyAnalytics(
    LoadMonthlyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    add(LoadAnalytics(gunSayisi: 30));
  }
}
