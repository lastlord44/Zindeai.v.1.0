// ============================================================================
// lib/domain/services/haftalik_rapor_servisi.dart
// HAFTALİK BESLENME UYUM RAPORU SERVİSİ
// ============================================================================

import 'dart:math';
import '../../data/local/hive_service.dart';
import '../entities/gunluk_plan.dart';
import '../entities/haftalik_rapor.dart';
import '../../core/utils/app_logger.dart';

class HaftalikRaporServisi {
  
  /// Haftalık uyum raporu oluştur
  static Future<HaftalikRapor> haftalikRaporOlustur({
    required DateTime baslangicTarihi,
  }) async {
    try {
      AppLogger.info('📊 Haftalık rapor oluşturuluyor: ${baslangicTarihi.toString()}');
      
      final raporVeri = <DateTime, GunlukUyumVerisi>{};
      double toplamUyumYuzdesi = 0.0;
      int toplamOgun = 0;
      int tamamlananOgun = 0;
      
      // 7 günlük veri topla
      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );
        
        final plan = await HiveService.planGetir(tarih);
        if (plan != null) {
          final tamamlananOgunler = await HiveService.tamamlananOgunleriGetir(tarih);
          
          // Günlük uyum hesapla
          final gunlukUyum = _gunlukUyumHesapla(plan, tamamlananOgunler);
          raporVeri[tarih] = gunlukUyum;
          
          toplamUyumYuzdesi += gunlukUyum.uyumYuzdesi;
          toplamOgun += plan.ogunler.length;
          tamamlananOgun += gunlukUyum.tamamlananOgunSayisi;
        } else {
          // Plan yoksa boş veri ekle
          raporVeri[tarih] = GunlukUyumVerisi(
            tarih: tarih,
            planVarMi: false,
            uyumYuzdesi: 0.0,
            tamamlananOgunSayisi: 0,
            toplamOgunSayisi: 0,
            tamamlananKalori: 0.0,
            hedefKalori: 0.0,
            makroUyum: MakroUyumVerisi(
              proteinUyum: 0.0,
              karbUyum: 0.0,
              yagUyum: 0.0,
            ),
          );
        }
      }
      
      // Haftalık ortalamalar hesapla
      final ortalamaUyum = raporVeri.isNotEmpty ? toplamUyumYuzdesi / raporVeri.length : 0.0;
      final genelUyumYuzdesi = toplamOgun > 0 ? (tamamlananOgun / toplamOgun) * 100 : 0.0;
      
      // Hedef analizi
      final hedefAnalizi = _hedefAnaliziYap(raporVeri);
      
      // Su tüketimi analizi
      final suAnalizi = _suTuketimiAnalizi(raporVeri);
      
      // Tavsiyeler üret
      final tavsiyeler = _haftalikTavsiyelerUret(ortalamaUyum, hedefAnalizi);
      
      AppLogger.success('✅ Haftalık rapor oluşturuldu: %${ortalamaUyum.toStringAsFixed(1)} uyum');
      
      return HaftalikRapor(
        baslangicTarihi: baslangicTarihi,
        bitisTarihi: DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + 6,
        ),
        gunlukVeriler: raporVeri,
        ortalamaUyumYuzdesi: ortalamaUyum,
        genelUyumYuzdesi: genelUyumYuzdesi,
        toplamTamamlananOgun: tamamlananOgun,
        toplamOgunSayisi: toplamOgun,
        hedefAnalizi: hedefAnalizi,
        suAnalizi: suAnalizi,
        tavsiyeler: tavsiyeler,
        olusturulmaTarihi: DateTime.now(),
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Haftalık rapor oluşturma hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Günlük uyum hesapla
  static GunlukUyumVerisi _gunlukUyumHesapla(
    GunlukPlan plan,
    Map<String, bool> tamamlananOgunler,
  ) {
    final tamamlananSayisi = tamamlananOgunler.values.where((v) => v == true).length;
    final toplamSayi = plan.ogunler.length;
    final uyumYuzdesi = toplamSayi > 0 ? (tamamlananSayisi / toplamSayi) * 100 : 0.0;
    
    // Tamamlanan kaloriyi hesapla
    double tamamlananKalori = 0.0;
    for (final yemek in plan.ogunler) {
      if (tamamlananOgunler[yemek.id] == true) {
        tamamlananKalori += yemek.kalori;
      }
    }
    
    // Makro uyum analizi
    final makroUyum = _makroUyumAnalizi(plan, tamamlananOgunler);
    
    return GunlukUyumVerisi(
      tarih: plan.tarih,
      planVarMi: true,
      uyumYuzdesi: uyumYuzdesi,
      tamamlananOgunSayisi: tamamlananSayisi,
      toplamOgunSayisi: toplamSayi,
      tamamlananKalori: tamamlananKalori,
      hedefKalori: plan.makroHedefleri.gunlukKalori,
      makroUyum: makroUyum,
    );
  }
  
  /// Makro uyum analizi
  static MakroUyumVerisi _makroUyumAnalizi(
    GunlukPlan plan,
    Map<String, bool> tamamlananOgunler,
  ) {
    double tamamlananProtein = 0.0;
    double tamamlananKarb = 0.0;
    double tamamlananYag = 0.0;
    
    for (final yemek in plan.ogunler) {
      if (tamamlananOgunler[yemek.id] == true) {
        tamamlananProtein += yemek.protein;
        tamamlananKarb += yemek.karbonhidrat;
        tamamlananYag += yemek.yag;
      }
    }
    
    final proteinUyum = plan.makroHedefleri.gunlukProtein > 0
        ? (tamamlananProtein / plan.makroHedefleri.gunlukProtein) * 100
        : 0.0;
    final karbUyum = plan.makroHedefleri.gunlukKarbonhidrat > 0
        ? (tamamlananKarb / plan.makroHedefleri.gunlukKarbonhidrat) * 100
        : 0.0;
    final yagUyum = plan.makroHedefleri.gunlukYag > 0
        ? (tamamlananYag / plan.makroHedefleri.gunlukYag) * 100
        : 0.0;
    
    return MakroUyumVerisi(
      proteinUyum: proteinUyum,
      karbUyum: karbUyum,
      yagUyum: yagUyum,
    );
  }
  
  /// Hedef analizi yap
  static HedefAnalizi _hedefAnaliziYap(Map<DateTime, GunlukUyumVerisi> veriler) {
    final planliGunler = veriler.values.where((v) => v.planVarMi).toList();
    
    if (planliGunler.isEmpty) {
      return HedefAnalizi(
        enIyiGun: null,
        enKotuGun: null,
        ortalamaUyum: 0.0,
        tutarlilikSkoru: 0.0,
        gelismeTrendi: 'Veri yok',
      );
    }
    
    // En iyi ve en kötü günleri bul
    planliGunler.sort((a, b) => b.uyumYuzdesi.compareTo(a.uyumYuzdesi));
    final enIyiGun = planliGunler.first;
    final enKotuGun = planliGunler.last;
    
    // Ortalama uyum
    final ortalamaUyum = planliGunler.fold<double>(0.0, (sum, v) => sum + v.uyumYuzdesi) / planliGunler.length;
    
    // Tutarlılık skoru (standart sapma bazlı)
    final varyans = planliGunler.fold<double>(0.0, (sum, v) => sum + pow(v.uyumYuzdesi - ortalamaUyum, 2)) / planliGunler.length;
    final tutarlilikSkoru = max(0.0, 100 - sqrt(varyans));
    
    // Gelişme trendi
    String gelismeTrendi = 'Stabil';
    if (planliGunler.length >= 3) {
      final ilkYari = planliGunler.take(planliGunler.length ~/ 2).fold<double>(0.0, (sum, v) => sum + v.uyumYuzdesi);
      final sonYari = planliGunler.skip(planliGunler.length ~/ 2).fold<double>(0.0, (sum, v) => sum + v.uyumYuzdesi);
      
      if (sonYari > ilkYari) {
        gelismeTrendi = 'Gelişiyor 📈';
      } else if (sonYari < ilkYari) {
        gelismeTrendi = 'Azalıyor 📉';
      }
    }
    
    return HedefAnalizi(
      enIyiGun: enIyiGun,
      enKotuGun: enKotuGun,
      ortalamaUyum: ortalamaUyum,
      tutarlilikSkoru: tutarlilikSkoru,
      gelismeTrendi: gelismeTrendi,
    );
  }
  
  /// Su tüketimi analizi
  static SuAnalizi _suTuketimiAnalizi(Map<DateTime, GunlukUyumVerisi> veriler) {
    double toplamOnerilen = 0.0;
    int gunSayisi = 0;
    
    for (final veri in veriler.values) {
      if (veri.planVarMi) {
        // Su ihtiyacı hesapla (makrolara göre)
        final onerilen = _gunlukSuIhtiyaciHesapla(veri.hedefKalori, veri.makroUyum);
        toplamOnerilen += onerilen;
        gunSayisi++;
      }
    }
    
    final ortalamaOnerilen = gunSayisi > 0 ? toplamOnerilen / gunSayisi : 2.5;
    
    return SuAnalizi(
      gunlukOnerilen: ortalamaOnerilen,
      haftalikOnerilen: ortalamaOnerilen * 7,
      aciklama: _suOneriAciklamasi(ortalamaOnerilen),
    );
  }
  
  /// Günlük su ihtiyacı hesapla
  static double _gunlukSuIhtiyaciHesapla(double kalori, MakroUyumVerisi makroUyum) {
    // Temel su ihtiyacı: 35ml/kg vücut ağırlığı (ortalama 75kg = 2.6L)
    double temelSu = 2.6;
    
    // Kalori bazlı ek ihtiyaç: her 100 kcal için +100ml
    double kaloriBazliEk = kalori / 1000; // 1000 kcal için 1L ek
    
    // Protein bazlı ek: yüksek protein daha fazla su gerektirir
    double proteinEk = makroUyum.proteinUyum > 100 ? 0.5 : 0.0;
    
    return temelSu + kaloriBazliEk + proteinEk;
  }
  
  /// Su önerisi açıklaması
  static String _suOneriAciklamasi(double litre) {
    if (litre < 2.0) {
      return 'Su tüketiminizi artırmanız öneriliyor. Minimum 2 litre hedefleyin.';
    } else if (litre < 3.0) {
      return 'İyi bir hidrasyon seviyesi. Bu düzeyi korumaya devam edin.';
    } else {
      return 'Yüksek aktivite seviyeniz için uygun su miktarı. Mükemmel!';
    }
  }
  
  /// Haftalık tavsiyeler üret
  static List<String> _haftalikTavsiyelerUret(double ortalamaUyum, HedefAnalizi analiz) {
    final tavsiyeler = <String>[];
    
    if (ortalamaUyum < 50) {
      tavsiyeler.add('🚨 Uyum oranınız düşük. Günlük planlarınızı daha düzenli takip etmeye odaklanın.');
      tavsiyeler.add('📱 Hatırlatıcı kurarak öğün vakitlerinde bildirim alabilirsiniz.');
    } else if (ortalamaUyum < 75) {
      tavsiyeler.add('📈 İyi gidiyorsunuz! Uyum oranınızı %80\'in üzerine çıkarmaya odaklanın.');
      tavsiyeler.add('🎯 En çok atladığınız öğünleri tespit edin ve onlara özel dikkat gösterin.');
    } else {
      tavsiyeler.add('🎉 Harika! Yüksek uyum oranınızı korumaya devam edin.');
      tavsiyeler.add('💪 Bu disiplinle hedeflerinize ulaşacaksınız!');
    }
    
    if (analiz.tutarlilikSkoru < 60) {
      tavsiyeler.add('⚖️ Günler arası tutarlılığınızı artırabilirsiniz. Düzenli rutinler oluşturun.');
    }
    
    if (analiz.gelismeTrendi.contains('📉')) {
      tavsiyeler.add('🔄 Son günlerde düşüş var. Motivasyonunuzu yeniden kazanmak için küçük hedefler belirleyin.');
    } else if (analiz.gelismeTrendi.contains('📈')) {
      tavsiyeler.add('🚀 Harika bir gelişim trendi! Bu momentumunuzu koruyun.');
    }
    
    return tavsiyeler;
  }
}