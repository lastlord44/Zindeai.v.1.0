// ============================================================================
// lib/presentation/bloc/home/home_bloc.dart
// FAZ 8: HOME BLOC (STATE MANAGEMENT)
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/makro_hedefleri.dart';
import '../../../domain/entities/kullanici_profili.dart';
import '../../../domain/usecases/ogun_planlayici.dart';
import '../../../domain/usecases/makro_hesapla.dart';
import '../../../data/local/hive_service.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDailyPlan extends HomeEvent {}

class RefreshPlan extends HomeEvent {}

class UpdateMeal extends HomeEvent {
  final String ogunTipi; // 'kahvalti', 'araOgun1', etc.
  final String yemekId;

  UpdateMeal({required this.ogunTipi, required this.yemekId});

  @override
  List<Object?> get props => [ogunTipi, yemekId];
}

// ============================================================================
// STATES
// ============================================================================

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final GunlukPlan plan;
  final MakroHedefleri hedefler;
  final KullaniciProfili kullanici;

  HomeLoaded({
    required this.plan,
    required this.hedefler,
    required this.kullanici,
  });

  @override
  List<Object?> get props => [plan, hedefler, kullanici];

  HomeLoaded copyWith({
    GunlukPlan? plan,
    MakroHedefleri? hedefler,
    KullaniciProfili? kullanici,
  }) {
    return HomeLoaded(
      plan: plan ?? this.plan,
      hedefler: hedefler ?? this.hedefler,
      kullanici: kullanici ?? this.kullanici,
    );
  }
}

class HomeError extends HomeState {
  final String mesaj;

  HomeError(this.mesaj);

  @override
  List<Object?> get props => [mesaj];
}

// ============================================================================
// BLOC
// ============================================================================

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final OgunPlanlayici planlayici;
  final MakroHesapla makroHesaplama;

  HomeBloc({
    required this.planlayici,
    required this.makroHesaplama,
  }) : super(HomeInitial()) {
    on<LoadDailyPlan>(_onLoadDailyPlan);
    on<RefreshPlan>(_onRefreshPlan);
    on<UpdateMeal>(_onUpdateMeal);
  }

  // ========================================================================
  // LOAD DAILY PLAN
  // ========================================================================

  Future<void> _onLoadDailyPlan(
    LoadDailyPlan event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Kullanıcıyı getir
      final kullanici = HiveService.kullaniciGetir();
      if (kullanici == null) {
        emit(HomeError('Kullanıcı bulunamadı. Lütfen profil oluşturun.'));
        return;
      }

      // Makro hedeflerini hesapla
      final hedefler = makroHesaplama.tamHesaplama(kullanici);

      // Bugünün planını kontrol et
      final bugun = DateTime.now();
      var plan = HiveService.planGetir(bugun);

      // Plan yoksa yeni oluştur
      if (plan == null) {
        print('📅 Bugün için plan yok, yeni plan oluşturuluyor...');
        
        plan = await planlayici.gunlukPlanOlustur(
          hedefKalori: hedefler.gunlukKalori,
          hedefProtein: hedefler.gunlukProtein,
          hedefKarb: hedefler.gunlukKarbonhidrat,
          hedefYag: hedefler.gunlukYag,
          kisitlamalar: kullanici.tumKisitlamalar,
        );

        // Planı kaydet
        await HiveService.planKaydet(plan);
      } else {
        print('📅 Bugünün planı bulundu!');
      }

      emit(HomeLoaded(
        plan: plan,
        hedefler: hedefler,
        kullanici: kullanici,
      ));
    } catch (e, stackTrace) {
      print('❌ Plan yüklenirken hata: $e');
      print(stackTrace);
      emit(HomeError('Plan yüklenirken hata: $e'));
    }
  }

  // ========================================================================
  // REFRESH PLAN
  // ========================================================================

  Future<void> _onRefreshPlan(
    RefreshPlan event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    emit(HomeLoading());

    try {
      print('🔄 Yeni plan oluşturuluyor...');

      // Yeni plan oluştur
      final yeniPlan = await planlayici.gunlukPlanOlustur(
        hedefKalori: currentState.hedefler.gunlukKalori,
        hedefProtein: currentState.hedefler.gunlukProtein,
        hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
        hedefYag: currentState.hedefler.gunlukYag,
        kisitlamalar: currentState.kullanici.tumKisitlamalar,
      );

      // Planı kaydet
      await HiveService.planKaydet(yeniPlan);

      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
      ));

      print('✅ Yeni plan oluşturuldu!');
    } catch (e) {
      print('❌ Plan yenilenirken hata: $e');
      emit(HomeError('Plan yenilenirken hata: $e'));
    }
  }

  // ========================================================================
  // UPDATE MEAL
  // ========================================================================

  Future<void> _onUpdateMeal(
    UpdateMeal event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    // TODO: Belirli bir öğünü değiştir
    // Bu özellik ileride eklenebilir
  }
}
