// lib/presentation/bloc/home/home_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/ogun_planlayici.dart';
import '../../../domain/usecases/malzeme_bazli_ogun_planlayici.dart';
import '../../../domain/usecases/makro_hesapla.dart';
import '../../../data/local/hive_service.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/yemek.dart';
import '../../../domain/services/malzeme_parser_servisi.dart';
import '../../../domain/services/ai_beslenme_servisi.dart'; // 🤖 AI IMPORT
import '../../../domain/services/yemek_onay_servisi.dart'; // ✅ YENİ ONAY SİSTEMİ
import '../../../core/utils/app_logger.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final OgunPlanlayici planlayici;
  final MalzemeBazliOgunPlanlayici? malzemeBazliPlanlayici;
  final MakroHesapla makroHesaplama;
  final AIBeslenmeServisi aiServisi; // 🤖 AI SERVİSİ

  HomeBloc({
    required this.planlayici,
    this.malzemeBazliPlanlayici,
    required this.makroHesaplama,
    AIBeslenmeServisi? aiServisi, // 🤖 OPTIONAL AI SERVİS
  }) : aiServisi = aiServisi ?? AIBeslenmeServisi(), // 🤖 DEFAULT AI SERVİS
        super(HomeInitial()) {
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
    on<CancelAlternativeSelection>(_onCancelAlternativeSelection);
    on<CancelAlternativeMealSelection>(_onCancelAlternativeMealSelection);
    // ✅ YENİ ONAY SİSTEMİ EVENT'LERİ
    on<MarkMealAsEaten>(_onMarkMealAsEaten);
    on<ConfirmMealEaten>(_onConfirmMealEaten);
    on<SkipMeal>(_onSkipMeal);
    on<ResetMealStatus>(_onResetMealStatus);
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
        // Tamamlanan öğünleri yükle (legacy)
        tamamlananOgunler = await HiveService.tamamlananOgunleriGetir(today);
      } else {
        // Plan yoksa yeni oluştur
        emit(const HomeLoading(message: 'Yeni plan oluşturuluyor...'));

        AppLogger.info('📋 Yeni günlük plan oluşturuluyor...');
        AppLogger.debug(
            'Hedefler: Kalori=${hedefler.gunlukKalori}, Protein=${hedefler.gunlukProtein}, Karb=${hedefler.gunlukKarbonhidrat}, Yağ=${hedefler.gunlukYag}');

        // 🔥 YENİ SİSTEM: Malzeme bazlı genetik algoritma (0.7% sapma!)
        if (malzemeBazliPlanlayici != null) {
          AppLogger.success(
              '🚀 Malzeme bazlı genetik algoritma aktif! (50x daha iyi performans)');
          plan = await malzemeBazliPlanlayici!.gunlukPlanOlustur(
            hedefKalori: hedefler.gunlukKalori,
            hedefProtein: hedefler.gunlukProtein,
            hedefKarb: hedefler.gunlukKarbonhidrat,
            hedefYag: hedefler.gunlukYag,
            kisitlamalar: kullanici.tumKisitlamalar,
            tarih: today,
          );
        } else {
          plan = await planlayici.gunlukPlanOlustur(
            hedefKalori: hedefler.gunlukKalori,
            hedefProtein: hedefler.gunlukProtein,
            hedefKarb: hedefler.gunlukKarbonhidrat,
            hedefYag: hedefler.gunlukYag,
            kisitlamalar: kullanici.tumKisitlamalar,
            tarih: today,
          );
        }

        AppLogger.success(
            '✅ Plan başarıyla oluşturuldu: ${plan.ogunler.length} öğün');

        // 📋 GÜNLÜK PLAN DETAYLARI - Kullanıcı görebilsin diye log
        AppLogger.info('');
        AppLogger.info(
            '📅 ═══════════════════════════════════════════════════');
        AppLogger.info(
            '   ${plan.tarih.day}.${plan.tarih.month}.${plan.tarih.year} - GÜNLÜK PLAN');
        AppLogger.info('═══════════════════════════════════════════════════');

        for (final yemek in plan.ogunler) {
          if (yemek != null) {
            final kategori =
                yemek.ogun.toString().split('.').last.toUpperCase();
            AppLogger.info('🍽️  $kategori: ${yemek.ad}');
            AppLogger.info(
                '    Kalori: ${yemek.kalori.toStringAsFixed(0)} kcal | Protein: ${yemek.protein.toStringAsFixed(0)}g | Karb: ${yemek.karbonhidrat.toStringAsFixed(0)}g | Yağ: ${yemek.yag.toStringAsFixed(0)}g');
            // 🔥 MALZEMELER - Kullanıcı görsün diye
            if (yemek.malzemeler.isNotEmpty) {
              AppLogger.info(
                  '    📋 Malzemeler: ${yemek.malzemeler.join(", ")}');
            }
          }
        }

        AppLogger.info('');
        AppLogger.info('📊 TOPLAM MAKROLAR:');
        AppLogger.info(
            '    Kalori: ${plan.toplamKalori.toStringAsFixed(0)} / ${hedefler.gunlukKalori.toStringAsFixed(0)} kcal');
        AppLogger.info(
            '    Protein: ${plan.toplamProtein.toStringAsFixed(0)} / ${hedefler.gunlukProtein.toStringAsFixed(0)}g');
        AppLogger.info(
            '    Karb: ${plan.toplamKarbonhidrat.toStringAsFixed(0)} / ${hedefler.gunlukKarbonhidrat.toStringAsFixed(0)}g');
        AppLogger.info(
            '    Yağ: ${plan.toplamYag.toStringAsFixed(0)} / ${hedefler.gunlukYag.toStringAsFixed(0)}g');
        AppLogger.info('');
        AppLogger.info('📈 PLAN KALİTESİ:');
        AppLogger.info(
            '    Fitness Skoru: ${plan.fitnessSkoru.toStringAsFixed(1)}/100');
        AppLogger.info(
            '    Kalite Skoru: ${plan.makroKaliteSkoru.toStringAsFixed(1)}/100');

        // 🎯 TOLERANS KONTROLÜ (±5%)
        if (plan.tumMakrolarToleranstaMi) {
          AppLogger.success('    ✅ Tüm makrolar ±5% tolerans içinde');
        } else {
          AppLogger.warning('    ⚠️  TOLERANS AŞILDI! (±5% limit)');
          for (final makro in plan.toleransAsanMakrolar) {
            AppLogger.warning('       ❌ $makro');
          }
        }

        AppLogger.info('═══════════════════════════════════════════════════');
        AppLogger.info('');

        // Planı kaydet
        await HiveService.planKaydet(plan);
        AppLogger.info('💾 Plan Hive\'a kaydedildi');
      }

      // ✅ YENİ ONAY SİSTEMİ: Günlük onay durumunu getir
      final gunlukOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(today);

      emit(HomeLoaded(
        plan: plan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: today,
        tamamlananOgunler: tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu, // ✅ YENİ ONAY SİSTEMİ
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

      // 🔥 YENİ SİSTEM: Malzeme bazlı genetik algoritma
      final yeniPlan = malzemeBazliPlanlayici != null
          ? await malzemeBazliPlanlayici!.gunlukPlanOlustur(
              hedefKalori: currentState.hedefler.gunlukKalori,
              hedefProtein: currentState.hedefler.gunlukProtein,
              hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
              hedefYag: currentState.hedefler.gunlukYag,
              kisitlamalar: currentState.kullanici.tumKisitlamalar,
              tarih: currentState.currentDate,
            )
          : await planlayici.gunlukPlanOlustur(
              hedefKalori: currentState.hedefler.gunlukKalori,
              hedefProtein: currentState.hedefler.gunlukProtein,
              hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
              hedefYag: currentState.hedefler.gunlukYag,
              kisitlamalar: currentState.kullanici.tumKisitlamalar,
              tarih: currentState.currentDate,
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

      // 🔥 YENİ SİSTEM: Malzeme bazlı genetik algoritma
      final yeniPlan = malzemeBazliPlanlayici != null
          ? await malzemeBazliPlanlayici!.gunlukPlanOlustur(
              hedefKalori: currentState.hedefler.gunlukKalori,
              hedefProtein: currentState.hedefler.gunlukProtein,
              hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
              hedefYag: currentState.hedefler.gunlukYag,
              kisitlamalar: currentState.kullanici.tumKisitlamalar,
              tarih: currentState.currentDate,
            )
          : await planlayici.gunlukPlanOlustur(
              hedefKalori: currentState.hedefler.gunlukKalori,
              hedefProtein: currentState.hedefler.gunlukProtein,
              hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
              hedefYag: currentState.hedefler.gunlukYag,
              kisitlamalar: currentState.kullanici.tumKisitlamalar,
              tarih: currentState.currentDate,
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

      // Haftalık plan oluştur - 🔥 YENİ SİSTEM: Malzeme bazlı genetik algoritma
      final haftalikPlanlar = malzemeBazliPlanlayici != null
          ? await malzemeBazliPlanlayici!.haftalikPlanOlustur(
              hedefKalori: hedefler.gunlukKalori,
              hedefProtein: hedefler.gunlukProtein,
              hedefKarb: hedefler.gunlukKarbonhidrat,
              hedefYag: hedefler.gunlukYag,
              kisitlamalar: kullanici.tumKisitlamalar,
              baslangicTarihi: baslangic,
            )
          : await planlayici.haftalikPlanOlustur(
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
        message:
            'Haftalık plan oluşturulurken bir hata oluştu: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 🤖 AI ALTERNATİF YEMEKLER - YENİ SİSTEM
  /// AI ile alternatif yemekler üret (DB boş olsa bile çalışır)
  Future<void> _onGenerateAlternativeMeals(
    GenerateAlternativeMeals event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: '🤖 AI alternatif yemekler üretiliyor...'));

      AppLogger.info('🤖 AI Alternatif Sistemi: ${event.mevcutYemek.ad} için alternatifler üretiliyor...');

      // 🤖 AI SERVİSİ İLE ALTERNATİF ÜRET
      final alternatifler = await aiServisi.alternatifleriGetir(event.mevcutYemek);

      AppLogger.success(
          '✅ ${event.mevcutYemek.ad} için ${alternatifler.length} AI alternatifi üretildi');

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
        '❌ HATA: AI alternatif yemekler oluşturulurken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );

      emit(HomeError(
        message:
            'AI alternatif yemekler oluşturulurken bir hata oluştu: ${e.toString()}',
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
            if (kahvalti == null)
              kahvalti = yemek;
            else if (araOgun1 == null)
              araOgun1 = yemek;
            else if (ogleYemegi == null)
              ogleYemegi = yemek;
            else if (araOgun2 == null)
              araOgun2 = yemek;
            else if (aksamYemegi == null)
              aksamYemegi = yemek;
            else
              geceAtistirma = yemek;
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

  /// 🤖 AI Malzeme için alternatif besinler oluştur - YENİ SİSTEM
  /// AI ile alternatif malzemeler üret (Legacy sistemin yerine)
  Future<void> _onGenerateIngredientAlternatives(
    GenerateIngredientAlternatives event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: '🤖 AI alternatif malzemeler üretiliyor...'));

      // Malzemeyi parse et
      final parsedMalzeme = MalzemeParserServisi.parse(event.malzemeMetni);

      if (parsedMalzeme == null) {
        AppLogger.warning(
            '⚠️ Malzeme parse edilemedi: "${event.malzemeMetni}"');
        
        // 🔥 FIX: Parse hatası olsa bile state'e geri dön (boş ekran kalmasın)
        emit(currentState);
        return;
      }

      AppLogger.info('🤖 AI Malzeme Alternatif Sistemi: "${parsedMalzeme.besinAdi}" için alternatifler üretiliyor...');

      // 🤖 AI SERVİSİ İLE MALZEME ALTERNATİFİ ÜRET - ÖĞÜN TİPİNE UYGUN!
      final alternatifler = await aiServisi.malzemeAlternatifleriGetir(
        besinAdi: parsedMalzeme.besinAdi,
        miktar: parsedMalzeme.miktar,
        birim: parsedMalzeme.birim,
        ogunTipi: event.yemek.ogun, // 🔥 ÖĞÜN TİPİNİ GÖNDER!
      );
      
      AppLogger.info('🎯 AI Öğün Filtresi: ${event.yemek.ogun.name} -> Uygun alternatifler üretildi');

      AppLogger.success(
          '✅ "${parsedMalzeme.besinAdi}" için ${alternatifler.length} AI alternatifi üretildi');

      // ✅ Alternatifler state'ini emit et (AI sisteminden dönen alternatiflerle)
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
        '❌ HATA: AI alternatif malzemeler oluşturulurken kritik hata oluştu',
        error: e,
        stackTrace: stackTrace,
      );

      // 🔥 FIX: Hata olsa bile ana state'e geri dön (boş ekran kalmasın)
      emit(currentState);
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
            if (kahvalti == null)
              kahvalti = yemek;
            else if (araOgun1 == null)
              araOgun1 = yemek;
            else if (ogleYemegi == null)
              ogleYemegi = yemek;
            else if (araOgun2 == null)
              araOgun2 = yemek;
            else if (aksamYemegi == null)
              aksamYemegi = yemek;
            else
              geceAtistirma = yemek;
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

  /// 🔥 Alternatif malzeme seçimini iptal et ve ana sayfaya dön
  Future<void> _onCancelAlternativeSelection(
    CancelAlternativeSelection event,
    Emitter<HomeState> emit,
  ) async {
    if (state is AlternativeIngredientsLoaded) {
      final currentState = state as AlternativeIngredientsLoaded;
      
      // Ana HomeLoaded state'ine geri dön (hiçbir şey sıfırlanmasın)
      emit(HomeLoaded(
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
      ));
      
      AppLogger.info('🔙 Alternatif malzeme seçimi iptal edildi - ana sayfaya dönüldü');
    }
  }

  /// 🔥 Alternatif yemek seçimini iptal et ve ana sayfaya dön
  Future<void> _onCancelAlternativeMealSelection(
    CancelAlternativeMealSelection event,
    Emitter<HomeState> emit,
  ) async {
    if (state is AlternativeMealsLoaded) {
      final currentState = state as AlternativeMealsLoaded;
      
      // Ana HomeLoaded state'ine geri dön (hiçbir şey sıfırlanmasın)
      emit(HomeLoaded(
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
      ));
      
      AppLogger.info('🔙 Alternatif yemek seçimi iptal edildi - ana sayfaya dönüldü');
    }
  }

  /// ✅ YENİ ONAY SİSTEMİ: Yemeği yedi olarak işaretle
  Future<void> _onMarkMealAsEaten(
    MarkMealAsEaten event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      AppLogger.info('🍽️ Yemek yedi olarak işaretleniyor: ${event.yemekId}');

      // Yemek onay servisi ile işaretle
      final basarili = await YemekOnayServisi.yemekYedi(
        yemekId: event.yemekId,
        tarih: currentState.currentDate,
        notlar: event.notlar,
      );

      if (basarili) {
        // Güncellenmiş onay durumunu al
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('✅ Yemek yedi olarak işaretlendi');
      } else {
        AppLogger.error('❌ Yemek işaretlenemedi');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek işaretleme hatası', error: e, stackTrace: stackTrace);
    }
  }

  /// ✅ YENİ ONAY SİSTEMİ: Yemeği onayla (artık değiştirilemez)
  Future<void> _onConfirmMealEaten(
    ConfirmMealEaten event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      AppLogger.info('✅ Yemek onaylanıyor: ${event.yemekId}');

      // Yemek onay servisi ile onayla
      final basarili = await YemekOnayServisi.yemekOnayla(
        yemekId: event.yemekId,
        tarih: currentState.currentDate,
        notlar: event.notlar,
      );

      if (basarili) {
        // Güncellenmiş onay durumunu al
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('🔒 Yemek onaylandı - artık değiştirilmez!');
      } else {
        AppLogger.error('❌ Yemek onaylanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek onaylama hatası', error: e, stackTrace: stackTrace);
    }
  }

  /// ✅ YENİ ONAY SİSTEMİ: Yemeği atla
  Future<void> _onSkipMeal(
    SkipMeal event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      AppLogger.info('⏭️ Yemek atlanıyor: ${event.yemekId}');

      // Yemek onay servisi ile atla
      final basarili = await YemekOnayServisi.yemekAtla(
        yemekId: event.yemekId,
        tarih: currentState.currentDate,
        notlar: event.notlar,
      );

      if (basarili) {
        // Güncellenmiş onay durumunu al
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('⏭️ Yemek atlandı');
      } else {
        AppLogger.error('❌ Yemek atlanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek atlama hatası', error: e, stackTrace: stackTrace);
    }
  }

  /// ✅ YENİ ONAY SİSTEMİ: Yemek durumunu sıfırla
  Future<void> _onResetMealStatus(
    ResetMealStatus event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      AppLogger.info('🔄 Yemek durumu sıfırlanıyor: ${event.yemekId}');

      // Yemek onay servisi ile sıfırla
      final basarili = await YemekOnayServisi.yemekDurumunuSifirla(
        yemekId: event.yemekId,
        tarih: currentState.currentDate,
      );

      if (basarili) {
        // Güncellenmiş onay durumunu al
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('🔄 Yemek durumu sıfırlandı');
      } else {
        AppLogger.error('❌ Yemek durumu sıfırlanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek durumu sıfırlama hatası', error: e, stackTrace: stackTrace);
    }
  }
}
