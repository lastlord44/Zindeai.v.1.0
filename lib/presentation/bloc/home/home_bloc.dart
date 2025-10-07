// lib/presentation/bloc/home/home_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/ogun_planlayici.dart';
import '../../../domain/usecases/makro_hesapla.dart';
import '../../../data/local/hive_service.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/yemek.dart';
import '../../../domain/services/malzeme_parser_servisi.dart';
import '../../../domain/services/alternatif_oneri_servisi.dart';
import '../../../core/utils/app_logger.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final OgunPlanlayici planlayici;
  final MakroHesapla makroHesaplama;

  HomeBloc({
    required this.planlayici,
    required this.makroHesaplama,
  }) : super(HomeInitial()) {
    on<LoadHomePage>(_onLoadHomePage);
    on<RefreshDailyPlan>(_onRefreshDailyPlan);
    on<ToggleMealCompletion>(_onToggleMealCompletion);
    on<ReplaceMeal>(_onReplaceMeal);
    on<LoadPlanByDate>(_onLoadPlanByDate);
    on<GenerateWeeklyPlan>(_onGenerateWeeklyPlan);
    on<GenerateAlternativeMeals>(_onGenerateAlternativeMeals);
    on<ReplaceMealWith>(_onReplaceMealWith);
    on<GenerateIngredientAlternatives>(_onGenerateIngredientAlternatives);
    on<ReplaceIngredientWith>(_onReplaceIngredientWith);
  }

  /// Ana sayfayı yükle
  Future<void> _onLoadHomePage(
    LoadHomePage event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading(message: 'Plan yükleniyor...'));

      // Kullanıcıyı getir
      final kullanici = await HiveService.kullaniciGetir();
      if (kullanici == null) {
        emit(const HomeError(
          message: 'Kullanıcı profili bulunamadı. Lütfen profil oluşturun.',
        ));
        return;
      }

      // Hedef tarihi belirle
      final targetDate = event.targetDate ?? DateTime.now();
      final today = DateTime(targetDate.year, targetDate.month, targetDate.day);

      // Makro hedeflerini hesapla
      final hedefler = makroHesaplama.tamHesaplama(kullanici);

      // Planı kontrol et
      var plan = await HiveService.planGetir(today);
      Map<String, bool> tamamlananOgunler = {};

      if (plan != null) {
        // Tamamlanan öğünleri yükle
        tamamlananOgunler = await HiveService.tamamlananOgunleriGetir(today);
      } else {
        // Plan yoksa yeni oluştur
        emit(const HomeLoading(message: 'Yeni plan oluşturuluyor...'));

        AppLogger.info('📋 Yeni günlük plan oluşturuluyor...');
        AppLogger.debug('Hedefler: Kalori=${hedefler.gunlukKalori}, Protein=${hedefler.gunlukProtein}, Karb=${hedefler.gunlukKarbonhidrat}, Yağ=${hedefler.gunlukYag}');
        
        plan = await planlayici.gunlukPlanOlustur(
          hedefKalori: hedefler.gunlukKalori,
          hedefProtein: hedefler.gunlukProtein,
          hedefKarb: hedefler.gunlukKarbonhidrat,
          hedefYag: hedefler.gunlukYag,
          kisitlamalar: kullanici.tumKisitlamalar,
        );

        AppLogger.success('✅ Plan başarıyla oluşturuldu: ${plan.ogunler.length} öğün');
        
        // Planı kaydet
        await HiveService.planKaydet(plan);
        AppLogger.info('💾 Plan Hive\'a kaydedildi');
      }

      emit(HomeLoaded(
        plan: plan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: today,
        tamamlananOgunler: tamamlananOgunler,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Plan yüklenirken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Plan yüklenirken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Planı yenile
  Future<void> _onRefreshDailyPlan(
    RefreshDailyPlan event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: 'Plan yenileniyor...'));

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

      // Eğer force regenerate ise, tamamlananları sıfırla
      final tamamlananlar = event.forceRegenerate
          ? <String, bool>{}
          : currentState.tamamlananOgunler;

      if (event.forceRegenerate) {
        await HiveService.tamamlananOgunleriKaydet(
          currentState.currentDate,
          {},
        );
      }

      emit(currentState.copyWith(
        plan: yeniPlan,
        tamamlananOgunler: tamamlananlar,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Plan yenilenirken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Plan yenilenirken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Öğün tamamlama durumunu değiştir
  Future<void> _onToggleMealCompletion(
    ToggleMealCompletion event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      // Yeni tamamlanma durumunu oluştur
      final yeniDurum = Map<String, bool>.from(currentState.tamamlananOgunler);
      final mevcutDurum = yeniDurum[event.yemekId] ?? false;
      yeniDurum[event.yemekId] = !mevcutDurum;

      // Kaydet
      await HiveService.tamamlananOgunleriKaydet(
        currentState.currentDate,
        yeniDurum,
      );

      // State'i güncelle
      emit(currentState.copyWith(tamamlananOgunler: yeniDurum));
    } catch (e) {
      // Hata durumunda sessizce devam et, kullanıcıyı rahatsız etme
      print('Öğün tamamlama kaydedilemedi: $e');
    }
  }

  /// Öğünü değiştir
  Future<void> _onReplaceMeal(
    ReplaceMeal event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: 'Yeni öğün aranıyor...'));

      // Yeni plan oluştur (öğün değiştirmek için tüm planı yeniden oluştur)
      final yeniPlan = await planlayici.gunlukPlanOlustur(
        hedefKalori: currentState.hedefler.gunlukKalori,
        hedefProtein: currentState.hedefler.gunlukProtein,
        hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
        hedefYag: currentState.hedefler.gunlukYag,
        kisitlamalar: currentState.kullanici.tumKisitlamalar,
      );

      // Kaydet
      await HiveService.planKaydet(yeniPlan);

      emit(currentState.copyWith(plan: yeniPlan));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Öğün değiştirilirken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Öğün değiştirilirken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Tarihe göre plan yükle
  Future<void> _onLoadPlanByDate(
    LoadPlanByDate event,
    Emitter<HomeState> emit,
  ) async {
    add(LoadHomePage(targetDate: event.date));
  }

  /// Haftalık plan oluştur (7 günlük)
  Future<void> _onGenerateWeeklyPlan(
    GenerateWeeklyPlan event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading(
          message: '7 günlük haftalık plan oluşturuluyor...'));

      // Kullanıcıyı getir
      final kullanici = await HiveService.kullaniciGetir();
      if (kullanici == null) {
        emit(const HomeError(
          message: 'Kullanıcı profili bulunamadı. Lütfen profil oluşturun.',
        ));
        return;
      }

      // Başlangıç tarihini belirle
      final baslangicTarihi = event.startDate ?? DateTime.now();
      final baslangic = DateTime(
        baslangicTarihi.year,
        baslangicTarihi.month,
        baslangicTarihi.day,
      );

      // Makro hedeflerini hesapla
      final hedefler = makroHesaplama.tamHesaplama(kullanici);

      // Eğer force regenerate değilse, mevcut planları kontrol et
      if (!event.forceRegenerate) {
        final mevcutPlan = await HiveService.planGetir(baslangic);
        if (mevcutPlan != null) {
          emit(const HomeError(
            message:
                'Bu tarih için zaten plan mevcut. Yeniden oluşturmak için force regenerate kullanın.',
          ));
          return;
        }
      }

      // Haftalık plan oluştur
      final haftalikPlanlar = await planlayici.haftalikPlanOlustur(
        hedefKalori: hedefler.gunlukKalori,
        hedefProtein: hedefler.gunlukProtein,
        hedefKarb: hedefler.gunlukKarbonhidrat,
        hedefYag: hedefler.gunlukYag,
        kisitlamalar: kullanici.tumKisitlamalar,
        baslangicTarihi: baslangic,
      );

      // Tüm planları Hive'a kaydet
      int basariliKayit = 0;
      for (final plan in haftalikPlanlar) {
        try {
          await HiveService.planKaydet(plan);
          basariliKayit++;
        } catch (e) {
          print('❌ Plan kaydetme hatası (${plan.tarih}): $e');
        }
      }

      // İlk günün planını yükle
      final ilkGun = haftalikPlanlar.first;
      final tamamlananOgunler =
          await HiveService.tamamlananOgunleriGetir(ilkGun.tarih);

      emit(HomeLoaded(
        plan: ilkGun,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: baslangic,
        tamamlananOgunler: tamamlananOgunler,
      ));

      print(
          '✅ Haftalık plan başarıyla oluşturuldu: $basariliKayit/${haftalikPlanlar.length} gün');
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Haftalık plan oluşturulurken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Haftalık plan oluşturulurken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Alternatif yemekler oluştur
  Future<void> _onGenerateAlternativeMeals(
    GenerateAlternativeMeals event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: 'Alternatif yemekler aranıyor...'));

      // Aynı öğün tipinde alternatif yemekler oluştur
      final alternatifler = <Yemek>[];

      for (int i = 0; i < event.sayi; i++) {
        final yeniPlan = await planlayici.gunlukPlanOlustur(
          hedefKalori: currentState.hedefler.gunlukKalori,
          hedefProtein: currentState.hedefler.gunlukProtein,
          hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
          hedefYag: currentState.hedefler.gunlukYag,
          kisitlamalar: currentState.kullanici.tumKisitlamalar,
        );

        // Aynı öğün tipindeki yemeği bul
        final alternatifYemek = yeniPlan.ogunler.firstWhere(
          (y) => y.ogun == event.mevcutYemek.ogun,
          orElse: () => yeniPlan.ogunler.first,
        );

        // Eğer farklı bir yemekse ekle
        if (alternatifYemek.id != event.mevcutYemek.id &&
            !alternatifler.any((y) => y.id == alternatifYemek.id)) {
          alternatifler.add(alternatifYemek);
        }
      }

      // Alternatifler state'ini emit et
      emit(AlternativeMealsLoaded(
        mevcutYemek: event.mevcutYemek,
        alternatifYemekler: alternatifler,
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Alternatif yemekler oluşturulurken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Alternatif yemekler oluşturulurken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Yemeği belirli bir yemekle değiştir
  Future<void> _onReplaceMealWith(
    ReplaceMealWith event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded && state is! AlternativeMealsLoaded) return;

    // Mevcut state'i al
    GunlukPlan currentPlan;
    Map<String, bool> tamamlananOgunler;
    var hedefler;
    var kullanici;
    DateTime currentDate;

    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      currentPlan = currentState.plan;
      tamamlananOgunler = currentState.tamamlananOgunler;
      hedefler = currentState.hedefler;
      kullanici = currentState.kullanici;
      currentDate = currentState.currentDate;
    } else {
      final currentState = state as AlternativeMealsLoaded;
      currentPlan = currentState.plan;
      tamamlananOgunler = currentState.tamamlananOgunler;
      hedefler = currentState.hedefler;
      kullanici = currentState.kullanici;
      currentDate = currentState.currentDate;
    }

    try {
      // Yeni öğün listesini oluştur ve öğün tiplerine göre ayır
      final yeniOgunler = currentPlan.ogunler.map((yemek) {
        if (yemek.id == event.eskiYemek.id) {
          return event.yeniYemek;
        }
        return yemek;
      }).toList();

      // Öğünleri tiplere göre ayır
      Yemek? kahvalti;
      Yemek? araOgun1;
      Yemek? ogleYemegi;
      Yemek? araOgun2;
      Yemek? aksamYemegi;
      Yemek? geceAtistirma;

      for (final yemek in yeniOgunler) {
        switch (yemek.ogun) {
          case OgunTipi.kahvalti:
            kahvalti = yemek;
            break;
          case OgunTipi.araOgun1:
            araOgun1 = yemek;
            break;
          case OgunTipi.ogle:
            ogleYemegi = yemek;
            break;
          case OgunTipi.araOgun2:
            araOgun2 = yemek;
            break;
          case OgunTipi.aksam:
            aksamYemegi = yemek;
            break;
          case OgunTipi.geceAtistirma:
            geceAtistirma = yemek;
            break;
          case OgunTipi.cheatMeal:
            // Cheat meal'i ilk boş slota yerleştir
            if (kahvalti == null) kahvalti = yemek;
            else if (araOgun1 == null) araOgun1 = yemek;
            else if (ogleYemegi == null) ogleYemegi = yemek;
            else if (araOgun2 == null) araOgun2 = yemek;
            else if (aksamYemegi == null) aksamYemegi = yemek;
            else geceAtistirma = yemek;
            break;
        }
      }

      // Yeni plan oluştur
      final yeniPlan = GunlukPlan(
        id: currentPlan.id,
        tarih: currentPlan.tarih,
        kahvalti: kahvalti,
        araOgun1: araOgun1,
        ogleYemegi: ogleYemegi,
        araOgun2: araOgun2,
        aksamYemegi: aksamYemegi,
        geceAtistirma: geceAtistirma,
        makroHedefleri: currentPlan.makroHedefleri,
        fitnessSkoru: currentPlan.fitnessSkoru,
      );

      // Planı kaydet
      await HiveService.planKaydet(yeniPlan);

      // State'i güncelle
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: currentDate,
        tamamlananOgunler: tamamlananOgunler,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Yemek değiştirilirken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Yemek değiştirilirken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Malzeme için alternatif besinler oluştur
  Future<void> _onGenerateIngredientAlternatives(
    GenerateIngredientAlternatives event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: 'Alternatif malzemeler aranıyor...'));

      // Malzemeyi parse et
      final parsedMalzeme = MalzemeParserServisi.parse(event.malzemeMetni);

      if (parsedMalzeme == null) {
        AppLogger.warning('⚠️ Malzeme parse edilemedi: "${event.malzemeMetni}"');
        emit(HomeError(
          message: 'Malzeme formatı anlaşılamadı: "${event.malzemeMetni}"',
        ));
        return;
      }

      // Alternatif besinleri oluştur
      final alternatifler = AlternatifOneriServisi.otomatikAlternatifUret(
        besinAdi: parsedMalzeme.besinAdi,
        miktar: parsedMalzeme.miktar,
        birim: parsedMalzeme.birim,
      );

      // Alternatif bulunamasa bile bottom sheet açılsın (kullanıcı geri dönebilsin)
      if (alternatifler.isEmpty) {
        AppLogger.warning('⚠️ Alternatif besin bulunamadı: "${parsedMalzeme.besinAdi}"');
      }

      // Alternatifler state'ini emit et (boş liste bile olsa)
      emit(AlternativeIngredientsLoaded(
        yemek: event.yemek,
        malzemeIndex: event.malzemeIndex,
        orijinalMalzemeMetni: event.malzemeMetni,
        alternatifBesinler: alternatifler,
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Alternatif malzemeler oluşturulurken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Alternatif malzemeler oluşturulurken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Malzemeyi alternatifiyle değiştir
  Future<void> _onReplaceIngredientWith(
    ReplaceIngredientWith event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded && state is! AlternativeIngredientsLoaded) return;

    // Mevcut state'i al
    GunlukPlan currentPlan;
    Map<String, bool> tamamlananOgunler;
    var hedefler;
    var kullanici;
    DateTime currentDate;

    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      currentPlan = currentState.plan;
      tamamlananOgunler = currentState.tamamlananOgunler;
      hedefler = currentState.hedefler;
      kullanici = currentState.kullanici;
      currentDate = currentState.currentDate;
    } else {
      final currentState = state as AlternativeIngredientsLoaded;
      currentPlan = currentState.plan;
      tamamlananOgunler = currentState.tamamlananOgunler;
      hedefler = currentState.hedefler;
      kullanici = currentState.kullanici;
      currentDate = currentState.currentDate;
    }

    try {
      // Yeni malzeme listesini oluştur
      final yeniMalzemeler = List<String>.from(event.yemek.malzemeler);
      yeniMalzemeler[event.malzemeIndex] = event.yeniMalzemeMetni;

      // Yeni yemek oluştur (malzeme değişmiş)
      final yeniYemek = event.yemek.copyWith(malzemeler: yeniMalzemeler);

      // Plandaki yemekleri güncelle
      final yeniOgunler = currentPlan.ogunler.map((yemek) {
        if (yemek.id == event.yemek.id) {
          return yeniYemek;
        }
        return yemek;
      }).toList();

      // Öğünleri tiplere göre ayır
      Yemek? kahvalti;
      Yemek? araOgun1;
      Yemek? ogleYemegi;
      Yemek? araOgun2;
      Yemek? aksamYemegi;
      Yemek? geceAtistirma;

      for (final yemek in yeniOgunler) {
        switch (yemek.ogun) {
          case OgunTipi.kahvalti:
            kahvalti = yemek;
            break;
          case OgunTipi.araOgun1:
            araOgun1 = yemek;
            break;
          case OgunTipi.ogle:
            ogleYemegi = yemek;
            break;
          case OgunTipi.araOgun2:
            araOgun2 = yemek;
            break;
          case OgunTipi.aksam:
            aksamYemegi = yemek;
            break;
          case OgunTipi.geceAtistirma:
            geceAtistirma = yemek;
            break;
          case OgunTipi.cheatMeal:
            // Cheat meal'i ilk boş slota yerleştir
            if (kahvalti == null) kahvalti = yemek;
            else if (araOgun1 == null) araOgun1 = yemek;
            else if (ogleYemegi == null) ogleYemegi = yemek;
            else if (araOgun2 == null) araOgun2 = yemek;
            else if (aksamYemegi == null) aksamYemegi = yemek;
            else geceAtistirma = yemek;
            break;
        }
      }

      // Yeni plan oluştur
      final yeniPlan = GunlukPlan(
        id: currentPlan.id,
        tarih: currentPlan.tarih,
        kahvalti: kahvalti,
        araOgun1: araOgun1,
        ogleYemegi: ogleYemegi,
        araOgun2: araOgun2,
        aksamYemegi: aksamYemegi,
        geceAtistirma: geceAtistirma,
        makroHedefleri: currentPlan.makroHedefleri,
        fitnessSkoru: currentPlan.fitnessSkoru,
      );

      // Planı kaydet
      await HiveService.planKaydet(yeniPlan);

      // State'i güncelle
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: currentDate,
        tamamlananOgunler: tamamlananOgunler,
      ));
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Malzeme değiştirilirken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(HomeError(
        message: 'Malzeme değiştirilirken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
