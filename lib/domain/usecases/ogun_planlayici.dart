// ============================================================================
// lib/domain/usecases/ogun_planlayici.dart
// FAZ 5: AKILLI ÖĞÜN PLANLAYICI (GENETİK ALGORİTMA)
// ============================================================================

import 'dart:math';
import '../../data/datasources/yemek_hive_data_source.dart';
import '../../core/utils/app_logger.dart';
import '../entities/yemek.dart';
import '../entities/gunluk_plan.dart';
import '../entities/makro_hedefleri.dart';

class OgunPlanlayici {
  final YemekHiveDataSource dataSource;
  final Random _random = Random();
  
  // 🎯 ÇEŞİTLİLİK MEKANİZMASI: Son seçilen yemekleri hatırla
  final Map<OgunTipi, List<String>> _sonSecilenYemekler = {};
  static const int _cokYakindaKullanilanSinir = 3; // Son 3 günde kullanılanları azalt
  static const int _yakindaKullanilanSinir = 7; // Son 7 günde kullanılanları biraz azalt

  OgunPlanlayici({required this.dataSource});

  /// Günlük plan oluştur
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
  }) async {
    try {
      AppLogger.info('🍽️ Günlük plan oluşturma başladı');
      AppLogger.debug('Hedefler: Kalori=$hedefKalori, Protein=$hedefProtein, Karb=$hedefKarb, Yağ=$hedefYag');
      AppLogger.debug('Kısıtlamalar: ${kisitlamalar.isEmpty ? "Yok" : kisitlamalar.join(", ")}');
      
      // 1. Tüm yemekleri yükle
      AppLogger.info('📂 Yemekler data source\'dan yükleniyor...');
      final tumYemekler = await dataSource.tumYemekleriYukle();
      
      // Yemek sayılarını logla
      int toplamYemek = 0;
      tumYemekler.forEach((ogun, yemekler) {
        toplamYemek += yemekler.length;
        AppLogger.debug('  ${ogun.toString().split('.').last}: ${yemekler.length} yemek');
      });
      AppLogger.success('✅ Toplam $toplamYemek yemek yüklendi (${tumYemekler.length} kategori)');

      // 2. Kısıtlamalara göre filtrele
      AppLogger.info('🔍 Kısıtlamalara göre filtreleme yapılıyor...');
      final uygunYemekler = _kisitlamalariFiltrele(tumYemekler, kisitlamalar);
      
      // Filtrelenmiş yemek sayılarını logla
      int filtrelenmisToplamYemek = 0;
      uygunYemekler.forEach((ogun, yemekler) {
        filtrelenmisToplamYemek += yemekler.length;
        AppLogger.debug('  ${ogun.toString().split('.').last}: ${yemekler.length} uygun yemek');
      });
      AppLogger.success('✅ Filtreleme tamamlandı: $filtrelenmisToplamYemek uygun yemek');

      // Boş kategori kontrolü
      final bosKategoriler = uygunYemekler.entries.where((e) => e.value.isEmpty).toList();
      if (bosKategoriler.isNotEmpty) {
        final bosKategoriIsimleri = bosKategoriler.map((e) => e.key.toString().split('.').last).join(', ');
        AppLogger.error('❌ HATA: Şu kategorilerde uygun yemek yok: $bosKategoriIsimleri');
        throw Exception('Plan oluşturulamadı: $bosKategoriIsimleri kategorilerinde uygun yemek bulunamadı. Lütfen kısıtlamalarınızı kontrol edin.');
      }

      // 3. Genetik algoritma ile en iyi kombinasyonu bul
      AppLogger.info('🧬 Genetik algoritma ile en iyi kombinasyon aranıyor...');
      final plan = _genetikAlgoritmaIleEslestir(
        yemekler: uygunYemekler,
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
      );

      AppLogger.success('✅ Plan başarıyla oluşturuldu! Fitness Skoru: ${plan.fitnessSkoru.toStringAsFixed(1)}');
      AppLogger.debug('Plan özeti: ${plan.ogunler.length} öğün, Toplam Kalori: ${plan.toplamKalori.toStringAsFixed(0)}');

      return plan;
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ KRITIK HATA: Günlük plan oluşturulurken hata',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Kısıtlamalara göre filtrele
  Map<OgunTipi, List<Yemek>> _kisitlamalariFiltrele(
    Map<OgunTipi, List<Yemek>> tumYemekler,
    List<String> kisitlamalar,
  ) {
    if (kisitlamalar.isEmpty) return tumYemekler;

    return tumYemekler.map((ogun, yemekler) {
      final filtrelenmis =
          yemekler.where((y) => y.kisitlamayaUygunMu(kisitlamalar)).toList();
      return MapEntry(ogun, filtrelenmis);
    });
  }

  /// Genetik algoritma (OPTIMIZE EDİLMİŞ)
  GunlukPlan _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    // ⚡ PERFORMANS OPTİMİZASYONU: Parametreleri azalttık
    const populasyonBoyutu = 30;  // 100 -> 30 (70% azalma)
    const jenerasyonSayisi = 20;  // 50 -> 20 (60% azalma)
    const elitOrani = 0.2;

    // 1. Rastgele popülasyon oluştur
    List<GunlukPlan> populasyon = List.generate(populasyonBoyutu, (_) {
      return _rastgelePlanOlustur(
          yemekler, hedefKalori, hedefProtein, hedefKarb, hedefYag);
    });

    // LOG REMOVED - Evrim döngüsü sessizce çalışsın
    
    // 2. Evrim döngüsü
    for (int jenerasyon = 0; jenerasyon < jenerasyonSayisi; jenerasyon++) {
      // Fitness hesapla ve sırala
      for (int i = 0; i < populasyon.length; i++) {
        final fitness = _fitnessHesapla(
          populasyon[i],
          hedefKalori,
          hedefProtein,
          hedefKarb,
          hedefYag,
        );
        populasyon[i] = populasyon[i].copyWith(fitnessSkoru: fitness);
      }

      populasyon.sort((a, b) => b.fitnessSkoru.compareTo(a.fitnessSkoru));

      // LOG REMOVED - Jenerasyon ilerlemesi gösterme

      // En iyi bireyleri seç
      final elitSayisi = (populasyonBoyutu * elitOrani).round();
      final elitler = populasyon.take(elitSayisi).toList();

      // Yeni nesil oluştur
      final yeniNesil = <GunlukPlan>[];
      yeniNesil.addAll(elitler);

      while (yeniNesil.length < populasyonBoyutu) {
        final parent1 = elitler[_random.nextInt(elitler.length)];
        final parent2 = elitler[_random.nextInt(elitler.length)];

        final cocuk = _caprazla(parent1, parent2, yemekler);
        final mutasyonlu = _mutasyonUygula(cocuk, yemekler);

        yeniNesil.add(mutasyonlu);
      }

      populasyon = yeniNesil;
    }

    // En iyi planı döndür
    populasyon.sort((a, b) => b.fitnessSkoru.compareTo(a.fitnessSkoru));
    return populasyon.first;
  }

  /// Rastgele plan oluştur
  GunlukPlan _rastgelePlanOlustur(
    Map<OgunTipi, List<Yemek>> yemekler,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    // Makro hedefleri oluştur
    final makroHedefleri = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: hedefProtein,
      gunlukKarbonhidrat: hedefKarb,
      gunlukYag: hedefYag,
    );

    // Önce öğle yemeğini seç
    final ogleYemegi = _cesitliYemekSec(yemekler[OgunTipi.ogle]!, OgunTipi.ogle);
    
    // Akşam yemeğini seçerken öğle yemeği ile aynı olmamasını sağla
    final aksamYemegi = _aksamYemegiSec(
      yemekler[OgunTipi.aksam]!,
      ogleYemegi,
      DateTime.now(),
    );

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: _cesitliYemekSec(yemekler[OgunTipi.kahvalti]!, OgunTipi.kahvalti),
      araOgun1: _cesitliYemekSec(yemekler[OgunTipi.araOgun1]!, OgunTipi.araOgun1),
      ogleYemegi: ogleYemegi,
      araOgun2: _cesitliYemekSec(yemekler[OgunTipi.araOgun2]!, OgunTipi.araOgun2),
      aksamYemegi: aksamYemegi,
      makroHedefleri: makroHedefleri,
      fitnessSkoru: 0,
    );
  }

  /// 🍽️ AKŞAM YEMEĞİ SEÇİMİ (Öğle ile aynı olmamalı!)
  Yemek _aksamYemegiSec(
    List<Yemek> aksamYemekleri,
    Yemek ogleYemegi,
    DateTime tarih,
  ) {
    if (aksamYemekleri.isEmpty) {
      throw Exception('Akşam yemeği listesi boş!');
    }

    // Hafta sonu kontrolü (Cumartesi=6, Pazar=7)
    final haftaSonuMu = tarih.weekday == DateTime.saturday || tarih.weekday == DateTime.sunday;
    
    // Hafta sonu İSTİSNASI: Nohut/fasulye gibi yemekler aynı olabilir
    final haftaSonuIstisnaYemekler = ['nohut', 'fasulye', 'barbunya', 'kuru fasulye', 'mercimek'];
    
    if (haftaSonuMu) {
      final ogleAdLower = ogleYemegi.ad.toLowerCase();
      final istisnaGecerliMi = haftaSonuIstisnaYemekler.any((kelime) => ogleAdLower.contains(kelime));
      
      if (istisnaGecerliMi) {
        // Hafta sonu + istisna yemek: Aynı yemeği seçebilir
        AppLogger.debug('🎉 Hafta sonu istisnası: ${ogleYemegi.ad} akşam da verilebilir');
        // Normal seçim yap, öğle kontrolü YAPMA
        return _cesitliYemekSec(aksamYemekleri, OgunTipi.aksam);
      }
    }

    // Normal durum: Öğle ile akşam FARKLI olmalı
    final uygunAksamYemekleri = aksamYemekleri.where((y) => y.id != ogleYemegi.id).toList();
    
    if (uygunAksamYemekleri.isEmpty) {
      // Çok nadir: Tüm akşam yemekleri öğle yemeği ile aynı
      AppLogger.warning('⚠️ Tüm akşam yemekleri öğle ile aynı! En azından farklı yemek seçiliyor...');
      return aksamYemekleri.firstWhere(
        (y) => y.id != ogleYemegi.id,
        orElse: () => aksamYemekleri.first,
      );
    }

    // Çeşitlilik mekanizmasını kullanarak seç
    final secilen = _cesitliYemekSec(uygunAksamYemekleri, OgunTipi.aksam);
    
    // Double-check: Seçilen öğle ile aynı mı?
    if (secilen.id == ogleYemegi.id) {
      AppLogger.error('❌ HATA: Akşam yemeği öğle ile aynı seçildi! ID: ${secilen.id}');
      // Farklı bir yemek seç
      final alternatif = uygunAksamYemekleri.firstWhere(
        (y) => y.id != ogleYemegi.id,
        orElse: () => aksamYemekleri.first,
      );
      AppLogger.info('✅ Alternatif akşam yemeği seçildi: ${alternatif.ad}');
      return alternatif;
    }

    return secilen;
  }

  /// Çeşitlilik sağlayan yemek seçimi (ağırlıklı rastgele)
  Yemek _cesitliYemekSec(List<Yemek> yemekler, OgunTipi ogunTipi) {
    if (yemekler.isEmpty) {
      AppLogger.error('❌ HATA: _cesitliYemekSec - Yemek listesi boş!');
      throw Exception('Yemek listesi boş! Genetik algoritma çalışamıyor.');
    }

    // Son seçilen yemekleri al
    final sonSecilenler = _sonSecilenYemekler[ogunTipi] ?? [];
    
    // Eğer hiç yemek seçilmemişse, normal rastgele seçim yap
    if (sonSecilenler.isEmpty) {
      final secilen = yemekler[_random.nextInt(yemekler.length)];
      _yemekSecildiKaydet(ogunTipi, secilen.id);
      return secilen;
    }

    // Ağırlıklı seçim için ağırlıkları hesapla
    final agirliklar = <double>[];
    for (final yemek in yemekler) {
      double agirlik = 1.0;
      
      // Son N günde kullanıldı mı kontrol et
      final kullanimIndex = sonSecilenler.indexOf(yemek.id);
      if (kullanimIndex != -1) {
        final kullanimSirasi = sonSecilenler.length - kullanimIndex;
        
        if (kullanimSirasi <= _cokYakindaKullanilanSinir) {
          // Çok yakın zamanda kullanıldı - çok düşük ağırlık (10%)
          agirlik = 0.1;
        } else if (kullanimSirasi <= _yakindaKullanilanSinir) {
          // Yakın zamanda kullanıldı - düşük ağırlık (40%)
          agirlik = 0.4;
        } else {
          // Uzun zaman önce kullanıldı - orta ağırlık (70%)
          agirlik = 0.7;
        }
      }
      // Hiç kullanılmadıysa ağırlık 1.0 kalır
      
      agirliklar.add(agirlik);
    }

    // Toplam ağırlık
    final toplamAgirlik = agirliklar.reduce((a, b) => a + b);
    
    // Rastgele değer seç (0 ile toplamAgirlik arasında)
    final rastgeleDeger = _random.nextDouble() * toplamAgirlik;
    
    // Ağırlıklara göre yemek seç
    double kumulatifAgirlik = 0.0;
    for (int i = 0; i < yemekler.length; i++) {
      kumulatifAgirlik += agirliklar[i];
      if (rastgeleDeger <= kumulatifAgirlik) {
        final secilen = yemekler[i];
        _yemekSecildiKaydet(ogunTipi, secilen.id);
        return secilen;
      }
    }
    
    // Fallback (normalde buraya gelmemeli)
    final secilen = yemekler.last;
    _yemekSecildiKaydet(ogunTipi, secilen.id);
    return secilen;
  }
  
  /// Seçilen yemeği kaydet (çeşitlilik için)
  void _yemekSecildiKaydet(OgunTipi ogunTipi, String yemekId) {
    if (!_sonSecilenYemekler.containsKey(ogunTipi)) {
      _sonSecilenYemekler[ogunTipi] = [];
    }
    
    final liste = _sonSecilenYemekler[ogunTipi]!;
    
    // Aynı yemek zaten listede varsa, eski kaydı sil
    liste.remove(yemekId);
    
    // Yeni kaydı en sona ekle
    liste.add(yemekId);
    
    // Maksimum 10 yemek hatırla (bellek optimizasyonu)
    if (liste.length > 10) {
      liste.removeAt(0);
    }
  }
  
  /// Çeşitlilik geçmişini temizle (yeni haftalık plan başlarken)
  void cesitlilikGecmisiniTemizle() {
    _sonSecilenYemekler.clear();
  }

  /// Çaprazlama (crossover)
  GunlukPlan _caprazla(
    GunlukPlan parent1,
    GunlukPlan parent2,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    final kesimNoktasi = _random.nextInt(5);

    final ogleYemegi = kesimNoktasi > 2 ? parent1.ogleYemegi : parent2.ogleYemegi;
    var aksamYemegi = kesimNoktasi > 4 ? parent1.aksamYemegi : parent2.aksamYemegi;

    // 🔒 VALİDASYON: Akşam-öğle aynı olmamalı (crossover sonrası kontrol)
    if (ogleYemegi != null && aksamYemegi != null && ogleYemegi.id == aksamYemegi.id) {
      // Ebeveynlerden gelen akşam yemeği öğle ile aynı! Yeni akşam seç
      aksamYemegi = _aksamYemegiSec(
        yemekler[OgunTipi.aksam]!,
        ogleYemegi,
        DateTime.now(),
      );
      AppLogger.debug('🔧 Crossover validasyonu: Akşam yemeği öğle ile aynıydı, değiştirildi');
    }

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti: kesimNoktasi > 0 ? parent1.kahvalti : parent2.kahvalti,
      araOgun1: kesimNoktasi > 1 ? parent1.araOgun1 : parent2.araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: kesimNoktasi > 3 ? parent1.araOgun2 : parent2.araOgun2,
      aksamYemegi: aksamYemegi,
      makroHedefleri: parent1.makroHedefleri,
      fitnessSkoru: 0,
    );
  }

  /// Mutasyon
  GunlukPlan _mutasyonUygula(
    GunlukPlan plan,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    const mutasyonOrani = 0.2;

    if (_random.nextDouble() > mutasyonOrani) {
      return plan;
    }

    final ogunIndex = _random.nextInt(5);

    switch (ogunIndex) {
      case 0:
        return plan.copyWith(
          kahvalti: _cesitliYemekSec(yemekler[OgunTipi.kahvalti]!, OgunTipi.kahvalti),
        );
      case 1:
        return plan.copyWith(
          araOgun1: _cesitliYemekSec(yemekler[OgunTipi.araOgun1]!, OgunTipi.araOgun1),
        );
      case 2:
        // Öğle yemeği değişince, akşam yemeğini de kontrol et
        final yeniOgleYemegi = _cesitliYemekSec(yemekler[OgunTipi.ogle]!, OgunTipi.ogle);
        final yeniAksamYemegi = plan.aksamYemegi != null && plan.aksamYemegi!.id == yeniOgleYemegi.id
          ? _aksamYemegiSec(yemekler[OgunTipi.aksam]!, yeniOgleYemegi, plan.tarih)
          : plan.aksamYemegi;
        return plan.copyWith(
          ogleYemegi: yeniOgleYemegi,
          aksamYemegi: yeniAksamYemegi,
        );
      case 3:
        return plan.copyWith(
          araOgun2: _cesitliYemekSec(yemekler[OgunTipi.araOgun2]!, OgunTipi.araOgun2),
        );
      default:
        // Akşam yemeği değişirken öğle ile aynı olmamasını sağla
        if (plan.ogleYemegi != null) {
          return plan.copyWith(
            aksamYemegi: _aksamYemegiSec(yemekler[OgunTipi.aksam]!, plan.ogleYemegi!, plan.tarih),
          );
        }
        return plan.copyWith(
          aksamYemegi: _cesitliYemekSec(yemekler[OgunTipi.aksam]!, OgunTipi.aksam),
        );
    }
  }

  /// Fitness fonksiyonu (0-100 arası skor)
  double _fitnessHesapla(
    GunlukPlan plan,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    final kaloriSapma = (plan.toplamKalori - hedefKalori).abs() / hedefKalori;
    final proteinSapma =
        (plan.toplamProtein - hedefProtein).abs() / hedefProtein;
    final karbSapma = (plan.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb;
    final yagSapma = (plan.toplamYag - hedefYag).abs() / hedefYag;

    final toplamSapma = (kaloriSapma * 0.4 +
            proteinSapma * 0.35 +
            karbSapma * 0.15 +
            yagSapma * 0.1)
        .clamp(0.0, 1.0);

    return (1 - toplamSapma) * 100;
  }

  // ========================================================================
  // HAFTALIK PLAN OLUŞTURMA
  // ========================================================================

  /// Haftalık plan oluştur (7 günlük)
  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? baslangicTarihi,
  }) async {
    try {
      AppLogger.info('📅 Haftalık plan oluşturma başladı (7 gün)');
      
      final baslangic = baslangicTarihi ?? DateTime.now();
      final haftalikPlanlar = <GunlukPlan>[];

      // 🎯 ÇEŞİTLİLİK İÇİN: Haftalık plan başında geçmişi temizle
      cesitlilikGecmisiniTemizle();
      AppLogger.info('🔄 Çeşitlilik geçmişi temizlendi - her gün farklı yemekler seçilecek');

      // 7 gün için plan oluştur
      for (int gun = 0; gun < 7; gun++) {
        final planTarihi = DateTime(
          baslangic.year,
          baslangic.month,
          baslangic.day + gun,
        );

        AppLogger.info('📋 ${gun + 1}. gün planı oluşturuluyor (${planTarihi.toString().split(' ')[0]})...');

        // Her gün için ayrı plan oluştur
        final gunlukPlan = await gunlukPlanOlustur(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          kisitlamalar: kisitlamalar,
        );

        // Tarihi güncelle
        final guncelPlan = gunlukPlan.copyWith(
          tarih: planTarihi,
          id: '${planTarihi.millisecondsSinceEpoch}',
        );

        haftalikPlanlar.add(guncelPlan);
        AppLogger.success('✅ ${gun + 1}. gün planı tamamlandı');
      }

      AppLogger.success('✅ Haftalık plan başarıyla oluşturuldu (7 gün)');
      return haftalikPlanlar;
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ KRITIK HATA: Haftalık plan oluşturulurken hata',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
