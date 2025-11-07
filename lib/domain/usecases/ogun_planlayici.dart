// ============================================================================
// lib/domain/usecases/ogun_planlayici.dart  
// AI TABANLI ÖĞÜN PLANLAYICI - Basit ve Hızlı
// ============================================================================

import 'dart:math';
import '../services/ai_beslenme_servisi_v5.dart';
import '../services/alternatif_yemek_servisi.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';
import '../entities/yemek.dart';
import '../entities/gunluk_plan.dart';
import '../entities/makro_hedefleri.dart';
import '../entities/kullanici_profili.dart';
import '../entities/hedef.dart'; // Hedef enum'ı için import

class OgunPlanlayici {
  final AIBeslenmeServisiV5 _aiServisi = AIBeslenmeServisiV5();
  final Random _random = Random();

  OgunPlanlayici({dataSource}); // Geriye uyumluluk için parametre kabul et ama kullanma

  /// 🤖 AI ile günlük plan oluştur - HIZLI ve BASIT!
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef, // 🔥 HEDEF PARAMETRESİ EKLENDİ
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
        hedef: hedef, // 🔥 HEDEF İLETİLİYOR
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
      
      // ❌ MOCK FALLBACK KALDIRILDI - Hata varsa exception fırlat, UI'de gösterelim
      rethrow;
    }
  }

  /// 🤖 AI ile haftalık plan oluştur - İLK GÜN HEMEN, DİĞERLERİ ARKA PLANDA
  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required KullaniciProfili profil,
    List<String> kisitlamalar = const [],
    DateTime? baslangicTarihi,
    Function(GunlukPlan)? onGunlukPlanOlusturuldu, // 🔥 Callback parametresi
  }) async {
    try {
      final baslangic = baslangicTarihi ?? DateTime.now();
      
      AppLogger.info('🤖 AI ile haftalık plan oluşturuluyor...');
      
      // AI servisi ile haftalık plan oluştur
      final haftalikPlanlar = await _aiServisi.haftalikPlanOlustur(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        hedef: profil.hedef,
        kisitlamalar: kisitlamalar,
        baslangicTarihi: baslangic,
        onGunlukPlanOlusturuldu: onGunlukPlanOlusturuldu,
      );
      
      AppLogger.success('✅ AI haftalık plan başarıyla oluşturuldu');
      return haftalikPlanlar;
      
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ AI haftalık plan oluşturma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      
      // ❌ MOCK FALLBACK KALDIRILDI - Hata varsa exception fırlat
      rethrow;
    }
  }

  // ❌ MOCK SİSTEMLER TAMAMEN KALDIRILDI
  // Artık sadece GERÇEK AI kullanılıyor - Pollinations.AI

  /// Çeşitlilik geçmişini temizle - AI sisteminde gerek yok ama uyumluluk için
  Future<void> cesitlilikGecmisiniTemizle() async {
    AppLogger.info('🤖 AI sisteminde çeşitlilik geçmişi temizleme gerekmez');
  }

  /// Alternatif yemek öner - Hive tabanlı
  Future<List<Yemek>> alternatifleriGetir(Yemek yemek) async {
    try {
      AppLogger.info('🍲 ${yemek.ad} için alternatifler aranıyor...');
      
      // İlgili öğündeki tüm yemekleri çek
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final yemekHavuzu =
          tumYemekler.where((y) => y.ogun == yemek.ogun).toList();

      // Alternatif yemekleri bul
      final alternatifler = AlternatifYemekServisi.alternatifYemekleriBul(
        orijinalYemek: yemek,
        yemekHavuzu: yemekHavuzu,
        adet: 5,
      );

      AppLogger.success(
          '✅ ${yemek.ad} için ${alternatifler.length} alternatif bulundu');
      return alternatifler;
    } catch (e) {
      AppLogger.warning('⚠️ Alternatif öneri hatası: $e');
      return [];
    }
  }
}
