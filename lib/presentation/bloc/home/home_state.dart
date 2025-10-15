// lib/presentation/bloc/home/home_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/makro_hedefleri.dart';
import '../../../domain/entities/kullanici_profili.dart';
import '../../../domain/entities/yemek.dart';
import '../../../domain/entities/alternatif_besin_legacy.dart';
import '../../../domain/entities/yemek_onay_sistemi.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// İlk yükleme durumu
class HomeInitial extends HomeState {}

/// Yükleniyor durumu
class HomeLoading extends HomeState {
  final String? message;

  const HomeLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Başarıyla yüklendi
class HomeLoaded extends HomeState {
  final GunlukPlan plan;
  final MakroHedefleri hedefler;
  final KullaniciProfili kullanici;
  final DateTime currentDate;
  final Map<String, bool> tamamlananOgunler; // yemekId -> tamamlandı mı? (LEGACY)
  final GunlukOnayDurumu? gunlukOnayDurumu; // ✅ YENİ ONAY SİSTEMİ

  const HomeLoaded({
    required this.plan,
    required this.hedefler,
    required this.kullanici,
    required this.currentDate,
    this.tamamlananOgunler = const {},
    this.gunlukOnayDurumu, // ✅ YENİ ONAY SİSTEMİ
  });

  /// Tamamlanan öğün sayısı
  int get tamamlananSayisi => tamamlananOgunler.values.where((t) => t).length;

  /// Tamamlanma yüzdesi
  double get tamamlanmaYuzdesi {
    if (plan.ogunler.isEmpty) return 0;
    return (tamamlananSayisi / plan.ogunler.length) * 100;
  }

  /// Tamamlanan makrolar
  double get tamamlananKalori {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.kalori);
  }

  double get tamamlananProtein {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.protein);
  }

  double get tamamlananKarb {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.karbonhidrat);
  }

  double get tamamlananYag {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.yag);
  }

  /// State'i kopyala
  HomeLoaded copyWith({
    GunlukPlan? plan,
    MakroHedefleri? hedefler,
    KullaniciProfili? kullanici,
    DateTime? currentDate,
    Map<String, bool>? tamamlananOgunler,
    GunlukOnayDurumu? gunlukOnayDurumu,
  }) {
    return HomeLoaded(
      plan: plan ?? this.plan,
      hedefler: hedefler ?? this.hedefler,
      kullanici: kullanici ?? this.kullanici,
      currentDate: currentDate ?? this.currentDate,
      tamamlananOgunler: tamamlananOgunler ?? this.tamamlananOgunler,
      gunlukOnayDurumu: gunlukOnayDurumu ?? this.gunlukOnayDurumu,
    );
  }

  @override
  List<Object?> get props => [
        plan,
        hedefler,
        kullanici,
        currentDate,
        tamamlananOgunler,
        gunlukOnayDurumu,
      ];
}

/// Alternatif yemekler yüklendi
class AlternativeMealsLoaded extends HomeState {
  final Yemek mevcutYemek;
  final List<Yemek> alternatifYemekler;
  final GunlukPlan plan;
  final MakroHedefleri hedefler;
  final KullaniciProfili kullanici;
  final DateTime currentDate;
  final Map<String, bool> tamamlananOgunler;

  const AlternativeMealsLoaded({
    required this.mevcutYemek,
    required this.alternatifYemekler,
    required this.plan,
    required this.hedefler,
    required this.kullanici,
    required this.currentDate,
    this.tamamlananOgunler = const {},
  });

  @override
  List<Object?> get props => [
        mevcutYemek,
        alternatifYemekler,
        plan,
        hedefler,
        kullanici,
        currentDate,
        tamamlananOgunler,
      ];
}

/// Alternatif malzemeler yüklendi (malzeme bazlı alternatif sistemi)
class AlternativeIngredientsLoaded extends HomeState {
  final Yemek yemek;
  final int malzemeIndex;
  final String orijinalMalzemeMetni;
  final List<AlternatifBesinLegacy> alternatifBesinler;
  final GunlukPlan plan;
  final MakroHedefleri hedefler;
  final KullaniciProfili kullanici;
  final DateTime currentDate;
  final Map<String, bool> tamamlananOgunler;

  const AlternativeIngredientsLoaded({
    required this.yemek,
    required this.malzemeIndex,
    required this.orijinalMalzemeMetni,
    required this.alternatifBesinler,
    required this.plan,
    required this.hedefler,
    required this.kullanici,
    required this.currentDate,
    this.tamamlananOgunler = const {},
  });

  @override
  List<Object?> get props => [
        yemek,
        malzemeIndex,
        orijinalMalzemeMetni,
        alternatifBesinler,
        plan,
        hedefler,
        kullanici,
        currentDate,
        tamamlananOgunler,
      ];
}

/// Hata durumu
class HomeError extends HomeState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const HomeError({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, error, stackTrace];
}
