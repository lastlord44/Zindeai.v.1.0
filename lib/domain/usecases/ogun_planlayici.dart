// ============================================================================
// lib/domain/usecases/ogun_planlayici.dart  
// AI TABANLI ÖĞÜN PLANLAYICI - Basit ve Hızlı
// ============================================================================

import 'dart:math';
import '../services/ai_beslenme_servisi.dart';
import '../../core/utils/app_logger.dart';
import '../entities/yemek.dart';
import '../entities/gunluk_plan.dart';
import '../entities/makro_hedefleri.dart';

class OgunPlanlayici {
  final AIBeslenmeServisi _aiServisi = AIBeslenmeServisi();
  final Random _random = Random();

  OgunPlanlayici({dataSource}); // Geriye uyumluluk için parametre kabul et ama kullanma

  /// 🤖 AI ile günlük plan oluştur - HIZLI ve BASIT!
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
  }) async {
    try {
      final planTarihi = tarih ?? DateTime.now();
      
      AppLogger.info('🤖 AI ile günlük plan oluşturuluyor...');
      
      // AI servisi ile plan oluştur
      final aiPlan = await _aiServisi.gunlukPlanOlustur(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        kisitlamalar: kisitlamalar,
        tarih: planTarihi,
      );
      
      AppLogger.success('✅ AI günlük plan başarıyla oluşturuldu');
      return aiPlan;
      
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ AI günlük plan oluşturma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Hata durumunda mock plan döndür (uygulama crash olmasın)
      return _mockPlanOlustur(hedefKalori, hedefProtein, hedefKarb, hedefYag, tarih ?? DateTime.now());
    }
  }

  /// 🤖 AI ile haftalık plan oluştur - 7 günlük 
  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? baslangicTarihi,
  }) async {
    try {
      final baslangic = baslangicTarihi ?? DateTime.now();
      
      AppLogger.info('🤖 AI ile haftalık plan oluşturuluyor...');
      
      // AI servisi ile haftalık plan oluştur
      final haftalikPlan = await _aiServisi.haftalikPlanOlustur(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        kisitlamalar: kisitlamalar,
        baslangicTarihi: baslangic,
      );
      
      AppLogger.success('✅ AI haftalık plan başarıyla oluşturuldu');
      return haftalikPlan;
      
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ AI haftalık plan oluşturma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Hata durumunda 7 günlük mock plan döndür
      final baslangic = baslangicTarihi ?? DateTime.now();
      return List.generate(7, (index) {
        final planTarihi = DateTime(
          baslangic.year,
          baslangic.month,
          baslangic.day + index,
        );
        return _mockPlanOlustur(hedefKalori, hedefProtein, hedefKarb, hedefYag, planTarihi);
      });
    }
  }

  /// 📋 Mock plan oluştur - AI çalışmazsa fallback
  GunlukPlan _mockPlanOlustur(
    double hedefKalori,
    double hedefProtein, 
    double hedefKarb,
    double hedefYag,
    DateTime tarih,
  ) {
    // Makro hedefleri oluştur
    final makroHedefleri = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: hedefProtein,
      gunlukKarbonhidrat: hedefKarb,
      gunlukYag: hedefYag,
    );

    // Basit mock yemekler oluştur
    final kahvalti = _mockYemekOlustur('Kahvaltı Menüsü', OgunTipi.kahvalti, hedefKalori * 0.20);
    final araOgun1 = _mockYemekOlustur('Ara Öğün 1', OgunTipi.araOgun1, hedefKalori * 0.15);
    final ogleYemegi = _mockYemekOlustur('Öğle Menüsü', OgunTipi.ogle, hedefKalori * 0.35);
    final araOgun2 = _mockYemekOlustur('Ara Öğün 2', OgunTipi.araOgun2, hedefKalori * 0.10);
    final aksamYemegi = _mockYemekOlustur('Akşam Menüsü', OgunTipi.aksam, hedefKalori * 0.20);

    return GunlukPlan(
      id: '${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: araOgun2,
      aksamYemegi: aksamYemegi,
      makroHedefleri: makroHedefleri,
      fitnessSkoru: 85.0,
    );
  }

  /// Mock yemek oluştur
  Yemek _mockYemekOlustur(String ad, OgunTipi ogun, double hedefKalori) {
    // Makroları orantısal dağıt
    final protein = hedefKalori * 0.25 / 4; // %25 protein (4 kcal/g)
    final karb = hedefKalori * 0.45 / 4; // %45 karb (4 kcal/g)  
    final yag = hedefKalori * 0.30 / 9; // %30 yağ (9 kcal/g)

    return Yemek(
      id: '${ogun.name}_${_random.nextInt(1000)}',
      ad: ad,
      kalori: hedefKalori,
      protein: protein,
      karbonhidrat: karb,
      yag: yag,
      ogun: ogun,
      hazirlamaSuresi: 15,
      zorluk: Zorluk.kolay,
      malzemeler: ['AI servisi aktif değil - Mock plan'],
      etiketler: ['ai-mock', 'geçici'],
      tarif: 'AI tarafından oluşturulan mock plan',
    );
  }

  /// Çeşitlilik geçmişini temizle - AI sisteminde gerek yok ama uyumluluk için
  Future<void> cesitlilikGecmisiniTemizle() async {
    AppLogger.info('🤖 AI sisteminde çeşitlilik geçmişi temizleme gerekmez');
  }

  /// Alternatif yemek öner - AI tabanlı
  Future<List<Yemek>> alternatifleriGetir(Yemek yemek) async {
    try {
      return await _aiServisi.alternatifleriGetir(yemek);
    } catch (e) {
      AppLogger.warning('⚠️ AI alternatif öneri hatası: $e');
      return [];
    }
  }
}
