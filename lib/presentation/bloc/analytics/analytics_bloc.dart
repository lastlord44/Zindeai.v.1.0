// ============================================================================
// ANALYTICS BLOC - FAZ 10
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../data/local/hive_service.dart';
import '../../../core/utils/app_logger.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<LoadWeeklyAnalytics>(_onLoadWeeklyAnalytics);
    on<LoadMonthlyAnalytics>(_onLoadMonthlyAnalytics);
    on<LoadCustomRangeAnalytics>(_onLoadCustomRangeAnalytics);
    on<LoadMacroTrends>(_onLoadMacroTrends);
    on<LoadWorkoutStats>(_onLoadWorkoutStats);
    on<LoadFavoriteMeals>(_onLoadFavoriteMeals);
    on<CalculateGoalAdherence>(_onCalculateGoalAdherence);
    on<LoadProgressComparison>(_onLoadProgressComparison);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  /// Haftalık analytics yükle
  Future<void> _onLoadWeeklyAnalytics(
    LoadWeeklyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Haftalık veriler yükleniyor...'));

    try {
      final baslangic = event.baslangicTarihi ?? 
          DateTime.now().subtract(const Duration(days: 6));
      final bitis = baslangic.add(const Duration(days: 6));

      final planlar = await HiveService.tarihAraligiPlanlariGetir(baslangic, bitis);
      final antrenmanlar = await HiveService.sonAntrenmanlar(gun: 7);

      final gunlukMakrolar = <DateTime, MacroValues>{};
      final enCokYenilenYemekler = <String, int>{};

      // Günlük makro verilerini hesapla
      for (final plan in planlar) {
        final tarihKey = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
        gunlukMakrolar[tarihKey] = MacroValues(
          kalori: plan.toplamKalori,
          protein: plan.toplamProtein,
          karbonhidrat: plan.toplamKarbonhidrat,
          yag: plan.toplamYag,
          tarih: plan.tarih,
        );

        // Yemekleri say
        for (final yemek in plan.ogunler) {
          final yemekAdi = yemek.ad;
          enCokYenilenYemekler[yemekAdi] =
              (enCokYenilenYemekler[yemekAdi] ?? 0) + 1;
        }
      }

      // Hedef tutturma istatistikleri
      final hedefTutturma = await _hedefTutturmaHesapla(planlar);

      // İlerleme trendi
      final trend = await _ilerlemeTrendiHesapla(planlar);

      final analyticsData = AnalyticsData(
        planlar: planlar,
        antrenmanlar: antrenmanlar,
        gunlukMakrolar: gunlukMakrolar,
        enCokYenilenYemekler: enCokYenilenYemekler,
        hedefTutturma: hedefTutturma,
        trend: trend,
      );

      emit(WeeklyAnalyticsLoaded(
        data: analyticsData,
        baslangicTarihi: baslangic,
        bitisTarihi: bitis,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Haftalık analytics yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Haftalık veriler yüklenemedi: $e'));
    }
  }

  /// Aylık analytics yükle
  Future<void> _onLoadMonthlyAnalytics(
    LoadMonthlyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Aylık veriler yükleniyor...'));

    try {
      final baslangic = event.baslangicTarihi ?? 
          DateTime.now().subtract(const Duration(days: 29));
      final bitis = baslangic.add(const Duration(days: 29));

      final planlar = await HiveService.tarihAraligiPlanlariGetir(baslangic, bitis);
      final antrenmanlar = await HiveService.sonAntrenmanlar(gun: 30);

      final gunlukMakrolar = <DateTime, MacroValues>{};
      final enCokYenilenYemekler = <String, int>{};

      // Günlük makro verilerini hesapla
      for (final plan in planlar) {
        final tarihKey = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
        gunlukMakrolar[tarihKey] = MacroValues(
          kalori: plan.toplamKalori,
          protein: plan.toplamProtein,
          karbonhidrat: plan.toplamKarbonhidrat,
          yag: plan.toplamYag,
          tarih: plan.tarih,
        );

        // Yemekleri say
        for (final yemek in plan.ogunler) {
          final yemekAdi = yemek.ad;
          enCokYenilenYemekler[yemekAdi] =
              (enCokYenilenYemekler[yemekAdi] ?? 0) + 1;
        }
      }

      // Hedef tutturma istatistikleri
      final hedefTutturma = await _hedefTutturmaHesapla(planlar);

      // İlerleme trendi
      final trend = await _ilerlemeTrendiHesapla(planlar);

      final analyticsData = AnalyticsData(
        planlar: planlar,
        antrenmanlar: antrenmanlar,
        gunlukMakrolar: gunlukMakrolar,
        enCokYenilenYemekler: enCokYenilenYemekler,
        hedefTutturma: hedefTutturma,
        trend: trend,
      );

      emit(MonthlyAnalyticsLoaded(
        data: analyticsData,
        baslangicTarihi: baslangic,
        bitisTarihi: bitis,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Aylık analytics yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Aylık veriler yüklenemedi: $e'));
    }
  }

  /// Özel tarih aralığı analytics yükle
  Future<void> _onLoadCustomRangeAnalytics(
    LoadCustomRangeAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Özel tarih aralığı verileri yükleniyor...'));

    try {
      final planlar = await HiveService.tarihAraligiPlanlariGetir(
        event.baslangic,
        event.bitis,
      );
      final antrenmanlar = await HiveService.sonAntrenmanlar(
        gun: event.bitis.difference(event.baslangic).inDays,
      );

      final gunlukMakrolar = <DateTime, MacroValues>{};
      final enCokYenilenYemekler = <String, int>{};

      // Günlük makro verilerini hesapla
      for (final plan in planlar) {
        final tarihKey = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
        gunlukMakrolar[tarihKey] = MacroValues(
          kalori: plan.toplamKalori,
          protein: plan.toplamProtein,
          karbonhidrat: plan.toplamKarbonhidrat,
          yag: plan.toplamYag,
          tarih: plan.tarih,
        );

        // Yemekleri say
        for (final yemek in plan.ogunler) {
          final yemekAdi = yemek.ad;
          enCokYenilenYemekler[yemekAdi] =
              (enCokYenilenYemekler[yemekAdi] ?? 0) + 1;
        }
      }

      // Hedef tutturma istatistikleri
      final hedefTutturma = await _hedefTutturmaHesapla(planlar);

      // İlerleme trendi
      final trend = await _ilerlemeTrendiHesapla(planlar);

      final analyticsData = AnalyticsData(
        planlar: planlar,
        antrenmanlar: antrenmanlar,
        gunlukMakrolar: gunlukMakrolar,
        enCokYenilenYemekler: enCokYenilenYemekler,
        hedefTutturma: hedefTutturma,
        trend: trend,
      );

      emit(CustomRangeAnalyticsLoaded(
        data: analyticsData,
        baslangic: event.baslangic,
        bitis: event.bitis,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Özel tarih aralığı analytics yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Özel tarih aralığı verileri yüklenemedi: $e'));
    }
  }

  /// Makro trend verilerini yükle
  Future<void> _onLoadMacroTrends(
    LoadMacroTrends event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Makro trendleri hesaplanıyor...'));

    try {
      final planlar = await HiveService.sonPlanlariGetir(gun: 30);
      
      final trendVerileri = <DateTime, MacroValues>{};
      
      for (final plan in planlar) {
        final tarihKey = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
        trendVerileri[tarihKey] = MacroValues(
          kalori: plan.toplamKalori,
          protein: plan.toplamProtein,
          karbonhidrat: plan.toplamKarbonhidrat,
          yag: plan.toplamYag,
          tarih: plan.tarih,
        );
      }

      final genelTrend = await _ilerlemeTrendiHesapla(planlar);

      emit(MacroTrendsLoaded(
        trendVerileri: trendVerileri,
        genelTrend: genelTrend,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Makro trendleri yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Makro trendleri yüklenemedi: $e'));
    }
  }

  /// Antrenman istatistiklerini yükle
  Future<void> _onLoadWorkoutStats(
    LoadWorkoutStats event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Antrenman istatistikleri yükleniyor...'));

    try {
      final antrenmanlar = await HiveService.sonAntrenmanlar(gun: event.gunSayisi);
      
      final toplamAntrenman = antrenmanlar.length;
      final toplamKalori = antrenmanlar.fold<int>(
        0,
        (sum, antrenman) => sum + antrenman.yakilanKalori,
      );
      
      final toplamSure = antrenmanlar.fold<int>(
        0,
        (sum, antrenman) => sum + antrenman.tamamlananSure,
      );
      
      final ortalamaSure = toplamAntrenman > 0 ? toplamSure ~/ toplamAntrenman : 0;

      final programBazindaSayilar = <String, int>{};
      for (final antrenman in antrenmanlar) {
        final programId = antrenman.antrenmanId;
        programBazindaSayilar[programId] = 
            (programBazindaSayilar[programId] ?? 0) + 1;
      }

      emit(WorkoutStatsLoaded(
        antrenmanlar: antrenmanlar,
        toplamAntrenmanSayisi: toplamAntrenman,
        toplamYakilanKalori: toplamKalori,
        ortalamaSure: ortalamaSure,
        programBazindaSayilar: programBazindaSayilar,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Antrenman istatistikleri yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Antrenman istatistikleri yüklenemedi: $e'));
    }
  }

  /// Favori yemekleri yükle
  Future<void> _onLoadFavoriteMeals(
    LoadFavoriteMeals event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Favori yemekler hesaplanıyor...'));

    try {
      final planlar = await HiveService.sonPlanlariGetir(gun: 30);
      final yemekSayilari = <String, int>{};

      for (final plan in planlar) {
        for (final yemek in plan.ogunler) {
          final yemekAdi = yemek.ad;
          yemekSayilari[yemekAdi] =
              (yemekSayilari[yemekAdi] ?? 0) + 1;
        }
      }

      emit(FavoriteMealsLoaded(yemekSayilari: yemekSayilari));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Favori yemekler yüklenemedi',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Favori yemekler yüklenemedi: $e'));
    }
  }

  /// Hedef tutturma yüzdesini hesapla
  Future<void> _onCalculateGoalAdherence(
    CalculateGoalAdherence event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'Hedef tutturma oranı hesaplanıyor...'));

    try {
      final planlar = await HiveService.sonPlanlariGetir(gun: event.gunSayisi);
      final hedefTutturma = await _hedefTutturmaHesapla(planlar);

      final gunlukTutturma = <DateTime, double>{};
      
      for (final plan in planlar) {
        final tarihKey = DateTime(plan.tarih.year, plan.tarih.month, plan.tarih.day);
        gunlukTutturma[tarihKey] = plan.fitnessSkoru;
      }

      emit(GoalAdherenceCalculated(
        istatistikler: hedefTutturma,
        gunlukTutturma: gunlukTutturma,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'Hedef tutturma oranı hesaplanamadı',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('Hedef tutturma oranı hesaplanamadı: $e'));
    }
  }

  /// İlerleme karşılaştırması yükle
  Future<void> _onLoadProgressComparison(
    LoadProgressComparison event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(mesaj: 'İlerleme karşılaştırması yapılıyor...'));

    try {
      final oncekiPlanlar = await HiveService.tarihAraligiPlanlariGetir(
        event.oncekiTarih,
        event.oncekiTarih.add(const Duration(days: 6)),
      );
      
      final sonrakiPlanlar = await HiveService.tarihAraligiPlanlariGetir(
        event.sonrakiTarih,
        event.sonrakiTarih.add(const Duration(days: 6)),
      );

      final oncekiOrtalama = _ortalamaMakroHesapla(oncekiPlanlar);
      final sonrakiOrtalama = _ortalamaMakroHesapla(sonrakiPlanlar);

      final degisimYuzdeleri = <String, double>{};
      
      if (oncekiOrtalama.kalori > 0) {
        degisimYuzdeleri['kalori'] = 
            ((sonrakiOrtalama.kalori - oncekiOrtalama.kalori) / oncekiOrtalama.kalori) * 100;
      }
      
      if (oncekiOrtalama.protein > 0) {
        degisimYuzdeleri['protein'] = 
            ((sonrakiOrtalama.protein - oncekiOrtalama.protein) / oncekiOrtalama.protein) * 100;
      }
      
      if (oncekiOrtalama.karbonhidrat > 0) {
        degisimYuzdeleri['karbonhidrat'] = 
            ((sonrakiOrtalama.karbonhidrat - oncekiOrtalama.karbonhidrat) / oncekiOrtalama.karbonhidrat) * 100;
      }
      
      if (oncekiOrtalama.yag > 0) {
        degisimYuzdeleri['yag'] = 
            ((sonrakiOrtalama.yag - oncekiOrtalama.yag) / oncekiOrtalama.yag) * 100;
      }

      final ilerlemVarMi = degisimYuzdeleri.values.any((yuzde) => yuzde.abs() > 5);

      emit(ProgressComparisonLoaded(
        oncekiDonemOrtalama: oncekiOrtalama,
        sonrakiDonemOrtalama: sonrakiOrtalama,
        degisimYuzdeleri: degisimYuzdeleri,
        ilerlemVarMi: ilerlemVarMi,
      ));

    } catch (e, stackTrace) {
      AppLogger.error(
        'İlerleme karşılaştırması yapılamadı',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AnalyticsError('İlerleme karşılaştırması yapılamadı: $e'));
    }
  }

  /// Analytics verilerini yenile
  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Son state'e göre yeniden yükle
    if (state is WeeklyAnalyticsLoaded) {
      add(LoadWeeklyAnalytics());
    } else if (state is MonthlyAnalyticsLoaded) {
      add(LoadMonthlyAnalytics());
    } else {
      add(LoadWeeklyAnalytics()); // Varsayılan olarak haftalık yükle
    }
  }

  // Yardımcı metotlar

  Future<HedefTutturmaIstatistikleri> _hedefTutturmaHesapla(
    List<GunlukPlan> planlar,
  ) async {
    if (planlar.isEmpty) {
      return const HedefTutturmaIstatistikleri(
        ortalamaTutturmaYuzdesi: 0,
        basariliGunSayisi: 0,
        toplamGunSayisi: 0,
        makroBazindaTutturma: {},
      );
    }

    final ortalamaSkor = planlar.fold<double>(
      0,
      (sum, plan) => sum + plan.fitnessSkoru,
    ) / planlar.length;

    final basariliGunlar = planlar.where((plan) => plan.fitnessSkoru >= 80).length;

    final makroBazindaTutturma = <String, double>{
      'kalori': ortalamaSkor,
      'protein': ortalamaSkor,
      'karbonhidrat': ortalamaSkor,
      'yag': ortalamaSkor,
    };

    return HedefTutturmaIstatistikleri(
      ortalamaTutturmaYuzdesi: ortalamaSkor,
      basariliGunSayisi: basariliGunlar,
      toplamGunSayisi: planlar.length,
      makroBazindaTutturma: makroBazindaTutturma,
    );
  }

  Future<IlerlemeTrendi> _ilerlemeTrendiHesapla(List<GunlukPlan> planlar) async {
    if (planlar.length < 3) {
      return const IlerlemeTrendi(
        kaloriTrendi: TrendYonu.yetersizVeri,
        proteinTrendi: TrendYonu.yetersizVeri,
        karbonhidratTrendi: TrendYonu.yetersizVeri,
        yagTrendi: TrendYonu.yetersizVeri,
        antrenmanTrendi: TrendYonu.yetersizVeri,
        trendGucu: 0,
      );
    }

    // İlk ve son 3 günün ortalamasını karşılaştır
    final ilkUc = planlar.sublist(0, planlar.length >= 3 ? 3 : planlar.length);
    final sonUc = planlar.sublist(planlar.length - 3);

    final ilkOrtalama = _ortalamaMakroHesapla(ilkUc);
    final sonOrtalama = _ortalamaMakroHesapla(sonUc);

    final kaloriTrendi = _trendHesapla(ilkOrtalama.kalori, sonOrtalama.kalori);
    final proteinTrendi = _trendHesapla(ilkOrtalama.protein, sonOrtalama.protein);
    final karbTrendi = _trendHesapla(ilkOrtalama.karbonhidrat, sonOrtalama.karbonhidrat);
    final yagTrendi = _trendHesapla(ilkOrtalama.yag, sonOrtalama.yag);

    // Antrenman trendi (Hive'den antrenman verilerini çekerek)
    final antrenmanlar = await HiveService.sonAntrenmanlar(gun: 30);
    final antrenmanTrendi = antrenmanlar.length >= 3 
        ? TrendYonu.yukseliyor // Varsayılan olarak artış
        : TrendYonu.yetersizVeri;

    // Genel trend gücü hesapla (-100 ile +100 arası)
    final trendPuanlari = [
      kaloriTrendi == TrendYonu.yukseliyor ? 20 : (kaloriTrendi == TrendYonu.dusuyor ? -20 : 0),
      proteinTrendi == TrendYonu.yukseliyor ? 20 : (proteinTrendi == TrendYonu.dusuyor ? -20 : 0),
      karbTrendi == TrendYonu.yukseliyor ? 20 : (karbTrendi == TrendYonu.dusuyor ? -20 : 0),
      yagTrendi == TrendYonu.yukseliyor ? 20 : (yagTrendi == TrendYonu.dusuyor ? -20 : 0),
      antrenmanTrendi == TrendYonu.yukseliyor ? 20 : (antrenmanTrendi == TrendYonu.dusuyor ? -20 : 0),
    ];

    final genelTrendGucu = trendPuanlari.reduce((a, b) => a + b);

    return IlerlemeTrendi(
      kaloriTrendi: kaloriTrendi,
      proteinTrendi: proteinTrendi,
      karbonhidratTrendi: karbTrendi,
      yagTrendi: yagTrendi,
      antrenmanTrendi: antrenmanTrendi,
      trendGucu: genelTrendGucu.toDouble(),
    );
  }

  MacroValues _ortalamaMakroHesapla(List<GunlukPlan> planlar) {
    if (planlar.isEmpty) {
      return MacroValues(
        kalori: 0,
        protein: 0,
        karbonhidrat: 0,
        yag: 0,
        tarih: DateTime.now(),
      );
    }

    final toplamKalori = planlar.fold<double>(0, (sum, plan) => sum + plan.toplamKalori);
    final toplamProtein = planlar.fold<double>(0, (sum, plan) => sum + plan.toplamProtein);
    final toplamKarb = planlar.fold<double>(0, (sum, plan) => sum + plan.toplamKarbonhidrat);
    final toplamYag = planlar.fold<double>(0, (sum, plan) => sum + plan.toplamYag);

    return MacroValues(
      kalori: toplamKalori / planlar.length,
      protein: toplamProtein / planlar.length,
      karbonhidrat: toplamKarb / planlar.length,
      yag: toplamYag / planlar.length,
      tarih: DateTime.now(),
    );
  }

  TrendYonu _trendHesapla(double ilkDeger, double sonDeger) {
    final fark = sonDeger - ilkDeger;
    final yuzde = ilkDeger != 0 ? (fark / ilkDeger) * 100 : 0;

    if (yuzde.abs() < 5) return TrendYonu.sabit;
    return yuzde > 0 ? TrendYonu.yukseliyor : TrendYonu.dusuyor;
  }
}
