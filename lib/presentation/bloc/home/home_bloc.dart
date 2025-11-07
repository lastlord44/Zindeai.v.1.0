// lib/presentation/bloc/home/home_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/ogun_planlayici.dart';
import '../../../domain/usecases/makro_hesapla.dart';
import '../../../data/local/hive_service.dart';
import '../../../domain/entities/gunluk_plan.dart';
import '../../../domain/entities/yemek.dart';
import '../../../domain/services/malzeme_parser_servisi.dart';
import '../../../domain/services/ai_beslenme_servisi.dart'; // 🤖 AI IMPORT
import '../../../domain/services/alternatif_yemek_servisi.dart'; // 🍲 ALTERNATİF YEMEK SERVİSİ
import '../../../domain/services/yemek_onay_servisi.dart'; // ✅ YENİ ONAY SİSTEMİ
import '../../../core/utils/app_logger.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final OgunPlanlayici planlayici;
  final MakroHesapla makroHesaplama;
  final AIBeslenmeServisi aiServisi; // 🤖 AI SERVİSİ

  HomeBloc({
    required this.planlayici,
    required this.makroHesaplama,
    AIBeslenmeServisi? aiServisi, // 🤖 OPTIONAL AI SERVİS
  })  : aiServisi = aiServisi ?? AIBeslenmeServisi(), // 🤖 DEFAULT AI SERVİS
        super(HomeInitial()) {
    on<LoadHomePage>(_onLoadHomePage);
    on<RefreshDailyPlan>(_onRefreshDailyPlan);
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
        
        // --- MEVCUT PLAN İÇİN DETAYLI LOGLAMA ---
        AppLogger.debug('--- 📋 MEVCUT PLAN LOGU (${plan.tarih.toIso8601String().substring(0, 10)}) ---');
        void logMeal(String mealName, Yemek? meal) {
          if (meal == null) {
            AppLogger.debug('$mealName: (Boş)');
            return;
          }
          AppLogger.debug('$mealName: ${meal.ad}');
          AppLogger.debug('  - Kalori: ${meal.kalori.toStringAsFixed(1)} kcal');
          AppLogger.debug('  - Protein: ${meal.protein.toStringAsFixed(1)} g');
          AppLogger.debug('  - Karbonhidrat: ${meal.karbonhidrat.toStringAsFixed(1)} g');
          AppLogger.debug('  - Yağ: ${meal.yag.toStringAsFixed(1)} g');
          AppLogger.debug('  - Malzemeler: ${meal.malzemeler.join(", ")}');
        }
        logMeal('🍳 Kahvaltı', plan.kahvalti);
        logMeal('🍎 Ara Öğün 1', plan.araOgun1);
        logMeal('🍽️ Öğle Yemeği', plan.ogleYemegi);
        logMeal('🥤 Ara Öğün 2', plan.araOgun2);
        logMeal('🌙 Akşam Yemeği', plan.aksamYemegi);
        logMeal('🌃 Gece Atıştırma', plan.geceAtistirma);
        AppLogger.debug('--- 📋 MEVCUT PLAN LOGU SONU ---');
        // --- MEVCUT PLAN İÇİN DETAYLI LOGLAMA SONU ---

      } else {
        // 🔥 İLK GÜNÜ HEMEN GÖSTER, DİĞER 6 GÜN ARKA PLANDA!
        emit(const HomeLoading(message: 'Bugünün planı oluşturuluyor...'));

        AppLogger.info('📋 İLK GÜN HEMEN, diğer 6 gün arka planda oluşturuluyor...');
        AppLogger.debug(
            'Hedefler: Kalori=${hedefler.gunlukKalori}, Protein=${hedefler.gunlukProtein}, Karb=${hedefler.gunlukKarbonhidrat}, Yağ=${hedefler.gunlukYag}');

        // 🔥 AI İLE HAFTALIK PLAN OLUŞTUR - Callback ile arka plan günleri kaydet
        final haftalikPlanlar = await planlayici.haftalikPlanOlustur(
          hedefKalori: hedefler.gunlukKalori,
          hedefProtein: hedefler.gunlukProtein,
          hedefKarb: hedefler.gunlukKarbonhidrat,
          hedefYag: hedefler.gunlukYag,
          profil: kullanici,
          kisitlamalar: kullanici.tumKisitlamalar,
          baslangicTarihi: today,
          onGunlukPlanOlusturuldu: (gunlukPlan) async {
            // 🔥 Her gün hazır olduğunda Hive'a kaydet (arka planda)
            await HiveService.planKaydet(gunlukPlan);
            AppLogger.info('💾 Gün ${gunlukPlan.tarih.day}.${gunlukPlan.tarih.month} Hive\'a kaydedildi (arka plan) | P: ${gunlukPlan.toplamProtein.toInt()}g K: ${gunlukPlan.toplamKarbonhidrat.toInt()}g Y: ${gunlukPlan.toplamYag.toInt()}g');
          },
        );

        // Bugünün planını al (ilk gün zaten döndü)
        plan = haftalikPlanlar.first;
        await HiveService.planKaydet(plan); // İlk günü de kaydet

        AppLogger.success(
            '✅ İLK GÜN HAZIR: ${plan.ogunler.length} öğün | Diğer 6 gün arka planda oluşturuluyor...');

        // 📋 GÜNLÜK PLAN ÖZETİ - UI ile tutarlı, tek satır log
        final kahvaltiAdi = plan.kahvalti?.ad ?? 'N/A';
        final ogleAdi = plan.ogleYemegi?.ad ?? 'N/A';
        final aksamAdi = plan.aksamYemegi?.ad ?? 'N/A';
        final tarihStr = '${plan.tarih.day}.${plan.tarih.month}.${plan.tarih.year}';
        final makroStr = 'TOPLAM: ${plan.toplamKalori.toInt()} kcal, P:${plan.toplamProtein.toInt()}g, K:${plan.toplamKarbonhidrat.toInt()}g, Y:${plan.toplamYag.toInt()}g';

        AppLogger.info('📅 GÜNLÜK PLAN ($tarihStr): Kahvaltı: $kahvaltiAdi, Öğle: $ogleAdi, Akşam: $aksamAdi | $makroStr');

        // --- DETAYLI PLAN LOGLAMA BAŞLANGICI ---
        AppLogger.debug('--- 📋 DETAYLI GÜNLÜK PLAN LOGU ---');
        void logMeal(String mealName, Yemek? meal) {
          if (meal == null) {
            AppLogger.debug('$mealName: (Boş)');
            return;
          }
          AppLogger.debug('$mealName: ${meal.ad}');
          AppLogger.debug('  - Kalori: ${meal.kalori.toStringAsFixed(1)} kcal');
          AppLogger.debug('  - Protein: ${meal.protein.toStringAsFixed(1)} g');
          AppLogger.debug('  - Karbonhidrat: ${meal.karbonhidrat.toStringAsFixed(1)} g');
          AppLogger.debug('  - Yağ: ${meal.yag.toStringAsFixed(1)} g');
          AppLogger.debug('  - Malzemeler: ${meal.malzemeler.join(", ")}');
        }
        logMeal('🍳 Kahvaltı', plan.kahvalti);
        logMeal('🍎 Ara Öğün 1', plan.araOgun1);
        logMeal('🍽️ Öğle Yemeği', plan.ogleYemegi);
        logMeal('🥤 Ara Öğün 2', plan.araOgun2);
        logMeal('🌙 Akşam Yemeği', plan.aksamYemegi);
        logMeal('🌃 Gece Atıştırma', plan.geceAtistirma);
        AppLogger.debug('--- 📋 DETAYLI GÜNLÜK PLAN LOGU SONU ---');
        // --- DETAYLI PLAN LOGLAMA SONU ---

        // Planı kaydet
        await HiveService.planKaydet(plan);
        AppLogger.info('💾 Plan Hive\'a kaydedildi');
      }

      // ✅ YENİ ONAY SİSTEMİ: Günlük onay durumunu getir
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(today);

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
      // ✅ FIX: forceRegenerate FALSE ise sadece mevcut planı yükle, YENİ OLUŞTURMA!
      if (!event.forceRegenerate) {
        AppLogger.info('🔄 Swipe refresh: Mevcut plan korunuyor (yeni oluşturulmuyor)');
        
        // Mevcut planı ve onay durumunu yükle
        final gunlukOnayDurumu =
            await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

        // State'i yenile ama AYNI PLAN ile
        emit(HomeLoaded(
          plan: currentState.plan, // ✅ MEVCUT PLAN KORUNUYOR!
          hedefler: currentState.hedefler,
          kullanici: currentState.kullanici,
          currentDate: currentState.currentDate,
          tamamlananOgunler: currentState.tamamlananOgunler,
          gunlukOnayDurumu: gunlukOnayDurumu,
        ));
        
        AppLogger.success('✅ Plan korundu - onay durumları yüklendi');
        return;
      }

      // forceRegenerate TRUE ise YENİ plan oluştur
      emit(const HomeLoading(message: 'Yeni plan oluşturuluyor...'));

      AppLogger.info('🔄 Force regenerate: Yeni plan oluşturuluyor...');

      // 🤖 AI İLE YENİ PLAN OLUŞTUR
      final yeniPlan = await planlayici.gunlukPlanOlustur(
        hedefKalori: currentState.hedefler.gunlukKalori,
        hedefProtein: currentState.hedefler.gunlukProtein,
        hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
        hedefYag: currentState.hedefler.gunlukYag,
        hedef: currentState.kullanici.hedef,
        kisitlamalar: currentState.kullanici.tumKisitlamalar,
        tarih: currentState.currentDate,
      );

      // Planı kaydet
      await HiveService.planKaydet(yeniPlan);

      // Tamamlananları sıfırla
      await HiveService.tamamlananOgunleriKaydet(
        currentState.currentDate,
        {},
      );

      // gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

      AppLogger.success('✅ Yeni plan oluşturuldu');

      // Yeni state oluştur
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: {}, // ✅ Sıfırlandı
        gunlukOnayDurumu: gunlukOnayDurumu,
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

  /// Öğünü değiştir
  Future<void> _onReplaceMeal(
    ReplaceMeal event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      emit(const HomeLoading(message: 'Yeni öğün aranıyor...'));

      // 🤖 AI İLE YENİ PLAN OLUŞTUR
      final yeniPlan = await planlayici.gunlukPlanOlustur(
        hedefKalori: currentState.hedefler.gunlukKalori,
        hedefProtein: currentState.hedefler.gunlukProtein,
        hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
        hedefYag: currentState.hedefler.gunlukYag,
        hedef: currentState.kullanici.hedef,
        kisitlamalar: currentState.kullanici.tumKisitlamalar,
        tarih: currentState.currentDate,
      );

      // Kaydet
      await HiveService.planKaydet(yeniPlan);

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

      // State'i güncelle
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
      ));
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

  /// Haftalık plan oluştur (7 günlük) - İLK GÜN HEMEN, DİĞERLERİ ARKA PLANDA
  Future<void> _onGenerateWeeklyPlan(
    GenerateWeeklyPlan event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading(
          message: 'Bugünün planı oluşturuluyor...'));

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

      // 🤖 AI İLE HAFTALIK PLAN OLUŞTUR - Callback ile arka plan günleri kaydet
      final haftalikPlanlar = await planlayici.haftalikPlanOlustur(
        hedefKalori: hedefler.gunlukKalori,
        hedefProtein: hedefler.gunlukProtein,
        hedefKarb: hedefler.gunlukKarbonhidrat,
        hedefYag: hedefler.gunlukYag,
        profil: kullanici,
        kisitlamalar: kullanici.tumKisitlamalar,
        baslangicTarihi: baslangic,
        onGunlukPlanOlusturuldu: (gunlukPlan) async {
          // 🔥 Her gün hazır olduğunda Hive'a kaydet (arka planda)
          await HiveService.planKaydet(gunlukPlan);
          AppLogger.info('💾 Gün ${gunlukPlan.tarih.day}.${gunlukPlan.tarih.month} Hive\'a kaydedildi (arka plan) | P: ${gunlukPlan.toplamProtein.toInt()}g K: ${gunlukPlan.toplamKarbonhidrat.toInt()}g Y: ${gunlukPlan.toplamYag.toInt()}g');
        },
      );

      // İlk günün planını yükle
      final ilkGun = haftalikPlanlar.first;
      await HiveService.planKaydet(ilkGun); // İlk günü de kaydet
      
      final tamamlananOgunler =
          await HiveService.tamamlananOgunleriGetir(ilkGun.tarih);

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(baslangic);

      emit(HomeLoaded(
        plan: ilkGun,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: baslangic,
        tamamlananOgunler: tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
      ));

      AppLogger.success(
          '✅ İLK GÜN HAZIR - Kullanıcı görebilir! Diğer 6 gün arka planda oluşturuluyor...');

      // 📋 GÜNLÜK PLAN ÖZETİ - UI ile tutarlı, tek satır log
      final kahvaltiAdi = ilkGun.kahvalti?.ad ?? 'N/A';
      final ogleAdi = ilkGun.ogleYemegi?.ad ?? 'N/A';
      final aksamAdi = ilkGun.aksamYemegi?.ad ?? 'N/A';
      final tarihStr = '${ilkGun.tarih.day}.${ilkGun.tarih.month}.${ilkGun.tarih.year}';
      final makroStr = 'TOPLAM: ${ilkGun.toplamKalori.toInt()} kcal, P:${ilkGun.toplamProtein.toInt()}g, K:${ilkGun.toplamKarbonhidrat.toInt()}g, Y:${ilkGun.toplamYag.toInt()}g';

      AppLogger.info('📅 GÜNLÜK PLAN ($tarihStr): Kahvaltı: $kahvaltiAdi, Öğle: $ogleAdi, Akşam: $aksamAdi | $makroStr');
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
      emit(const HomeLoading(
          message: '🤖 AI alternatif yemekler üretiliyor...'));

      AppLogger.info(
          '🍲 Alternatif Sistemi: ${event.mevcutYemek.ad} için alternatifler aranıyor...');

      // İlgili öğündeki tüm yemekleri çek
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final yemekHavuzu = tumYemekler
          .where((y) => y.ogun == event.mevcutYemek.ogun)
          .toList();

      // Alternatif yemekleri bul
      final alternatifler = AlternatifYemekServisi.alternatifYemekleriBul(
        orijinalYemek: event.mevcutYemek,
        yemekHavuzu: yemekHavuzu,
        adet: 5,
      );

      AppLogger.success(
          '✅ ${event.mevcutYemek.ad} için ${alternatifler.length} alternatif bulundu');

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

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentDate);

      // State'i güncelle
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: currentDate,
        tamamlananOgunler: tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
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
      emit(const HomeLoading(
          message: '🤖 AI alternatif malzemeler üretiliyor...'));

      // Malzemeyi parse et
      final parsedMalzeme = MalzemeParserServisi.parse(event.malzemeMetni);

      if (parsedMalzeme == null) {
        AppLogger.warning(
            '⚠️ Malzeme parse edilemedi: "${event.malzemeMetni}"');

        // 🔥 FIX: Parse hatası olsa bile state'e geri dön (boş ekran kalmasın)
        emit(currentState);
        return;
      }

      AppLogger.info(
          '🤖 AI Malzeme Alternatif Sistemi: "${parsedMalzeme.besinAdi}" için alternatifler üretiliyor...');

      // 🤖 AI SERVİSİ İLE MALZEME ALTERNATİFİ ÜRET - ÖĞÜN TİPİNE UYGUN!
      // İlgili öğündeki tüm yemekleri çek
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final yemekHavuzu =
          tumYemekler.where((y) => y.ogun == event.yemek.ogun).toList();

      // Alternatif yemekleri bul
      final alternatifYemekler = AlternatifYemekServisi.alternatifYemekleriBul(
        orijinalYemek: event.yemek,
        yemekHavuzu: yemekHavuzu,
        adet: 5,
      );

      // Alternatif yemeklerden malzeme listeleri oluştur
      final alternatifler = alternatifYemekler
          .map((yemek) => yemek.malzemeler.join(', '))
          .toList();

      AppLogger.info(
          '🎯 AI Öğün Filtresi: ${event.yemek.ogun.name} -> Uygun alternatifler üretildi');

      AppLogger.success(
          '✅ "${parsedMalzeme.besinAdi}" için ${alternatifler.length} AI alternatifi üretildi');

      // ✅ Alternatifler state'ini emit et (AI sisteminden dönen alternatiflerle)
      emit(AlternativeIngredientsLoaded(
        yemek: event.yemek,
        malzemeIndex: event.malzemeIndex,
        orijinalMalzemeMetni: event.malzemeMetni,
        alternatifBesinler: [], // TODO: Geçici olarak boş liste
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananKalori: currentState.tamamlananKalori,
        tamamlananProtein: currentState.tamamlananProtein,
        tamamlananKarb: currentState.tamamlananKarb,
        tamamlananYag: currentState.tamamlananYag,
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
      final yeniYemek = Yemek(
        id: event.yemek.id,
        ad: event.yemek.ad,
        kalori: event.yemek.kalori,
        protein: event.yemek.protein,
        karbonhidrat: event.yemek.karbonhidrat,
        yag: event.yemek.yag,
        malzemeler: yeniMalzemeler,
        ogun: event.yemek.ogun,
        hazirlamaSuresi: event.yemek.hazirlamaSuresi,
        zorluk: event.yemek.zorluk,
        etiketler: event.yemek.etiketler,
        tarif: event.yemek.tarif,
        gorselUrl: event.yemek.gorselUrl,
      );

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

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentDate);

      // State'i güncelle
      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: hedefler,
        kullanici: kullanici,
        currentDate: currentDate,
        tamamlananOgunler: tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
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

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

      // Ana HomeLoaded state'ine geri dön (hiçbir şey sıfırlanmasın)
      emit(HomeLoaded(
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
      ));

      AppLogger.info(
          '🔙 Alternatif malzeme seçimi iptal edildi - ana sayfaya dönüldü');
    }
  }

  /// 🔥 Alternatif yemek seçimini iptal et ve ana sayfaya dön
  Future<void> _onCancelAlternativeMealSelection(
    CancelAlternativeMealSelection event,
    Emitter<HomeState> emit,
  ) async {
    if (state is AlternativeMealsLoaded) {
      final currentState = state as AlternativeMealsLoaded;

      // ✅ FIX: gunlukOnayDurumu'nu yükle
      final gunlukOnayDurumu =
          await YemekOnayServisi.gunlukOnayDurumuGetir(currentState.currentDate);

      // Ana HomeLoaded state'ine geri dön (hiçbir şey sıfırlanmasın)
      emit(HomeLoaded(
        plan: currentState.plan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
        currentDate: currentState.currentDate,
        tamamlananOgunler: currentState.tamamlananOgunler,
        gunlukOnayDurumu: gunlukOnayDurumu,
      ));

      AppLogger.info(
          '🔙 Alternatif yemek seçimi iptal edildi - ana sayfaya dönüldü');
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
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(
            currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('✅ Yemek yedi olarak işaretlendi');
      } else {
        AppLogger.error('❌ Yemek işaretlenemedi');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek işaretleme hatası',
          error: e, stackTrace: stackTrace);
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
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(
            currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('🔒 Yemek onaylandı - artık değiştirilmez!');
      } else {
        AppLogger.error('❌ Yemek onaylanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek onaylama hatası',
          error: e, stackTrace: stackTrace);
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
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(
            currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('⏭️ Yemek atlandı');
      } else {
        AppLogger.error('❌ Yemek atlanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek atlama hatası',
          error: e, stackTrace: stackTrace);
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
        final yeniOnayDurumu = await YemekOnayServisi.gunlukOnayDurumuGetir(
            currentState.currentDate);

        emit(currentState.copyWith(gunlukOnayDurumu: yeniOnayDurumu));
        AppLogger.success('🔄 Yemek durumu sıfırlandı');
      } else {
        AppLogger.error('❌ Yemek durumu sıfırlanamadı');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek durumu sıfırlama hatası',
          error: e, stackTrace: stackTrace);
    }
  }
}
