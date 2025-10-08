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
import '../services/karbonhidrat_validator.dart';
import '../../core/services/cesitlilik_gecmis_servisi.dart';

class OgunPlanlayici {
  final YemekHiveDataSource dataSource;
  final Random _random = Random();

  // 🎯 ÇEŞİTLİLİK MEKANİZMASI: Kalici gecmis (Hive'da saklanir)
  static const int _cokYakindaKullanilanSinir =
      3; // Son 3 günde kullanılanları azalt
  static const int _yakindaKullanilanSinir =
      7; // Son 7 günde kullanılanları biraz azalt

  OgunPlanlayici({required this.dataSource});

  /// Günlük plan oluştur (SESSIZ MOD - log spam önlendi)
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
  }) async {
    try {
      // Yemekleri yükle ve filtrele (sessiz)
      final tumYemekler = await dataSource.tumYemekleriYukle();
      final uygunYemekler = _kisitlamalariFiltrele(tumYemekler, kisitlamalar);

      // Boş kategori kontrolü
      final bosKategoriler =
          uygunYemekler.entries.where((e) => e.value.isEmpty).toList();
      if (bosKategoriler.isNotEmpty) {
        final bosKategoriIsimleri = bosKategoriler
            .map((e) => e.key.toString().split('.').last)
            .join(', ');
        AppLogger.error(
            '❌ HATA: Şu kategorilerde uygun yemek yok: $bosKategoriIsimleri');
        throw Exception(
            'Plan oluşturulamadı: $bosKategoriIsimleri kategorilerinde uygun yemek bulunamadı. Lütfen kısıtlamalarınızı kontrol edin.');
      }

      // Genetik algoritma (sessiz)
      final plan = _genetikAlgoritmaIleEslestir(
        yemekler: uygunYemekler,
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
      );

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

  /// Kısıtlamalara göre filtrele + Karbonhidrat validasyonu
  Map<OgunTipi, List<Yemek>> _kisitlamalariFiltrele(
    Map<OgunTipi, List<Yemek>> tumYemekler,
    List<String> kisitlamalar,
  ) {
    return tumYemekler.map((ogun, yemekler) {
      var filtrelenmis = yemekler;

      // 1. Kısıtlamalara göre filtrele
      if (kisitlamalar.isNotEmpty) {
        filtrelenmis = filtrelenmis
            .where((y) => y.kisitlamayaUygunMu(kisitlamalar))
            .toList();
      }

      // 2. Karbonhidrat validasyonu (Ogle ve Aksam icin)
      if (ogun == OgunTipi.ogle || ogun == OgunTipi.aksam) {
        final oncekiSayi = filtrelenmis.length;
        filtrelenmis = KarbonhidratValidator.yemekleriFiltrele(filtrelenmis);
        final sonrakiSayi = filtrelenmis.length;

        // Karbonhidrat filtreleme sessiz çalışır
      }

      return MapEntry(ogun, filtrelenmis);
    });
  }

  /// Genetik algoritma (ÇEŞİTLİLİK OPTİMİZE EDİLMİŞ + PERFORMANS İYİLEŞTİRMESİ V2)
  GunlukPlan _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    // 🎯 PERFORMANS OPTİMİZASYONU V2: UI donması tamamen önlendi
    const populasyonBoyutu = 15; // 30 → 15 (2x hızlı)
    const jenerasyonSayisi = 10; // 20 → 10 (2x hızlı)
    const elitOrani = 0.2; // En iyi bireyleri koru

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
    final enIyiPlan = populasyon.first;

    // Çeşitlilik geçmişine kaydet (sessiz)
    for (final yemek in enIyiPlan.ogunler) {
      if (yemek != null) {
        _yemekSecildiKaydet(yemek.ogun, yemek.id);
      }
    }

    return enIyiPlan;
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
    final ogleYemegi =
        _cesitliYemekSec(yemekler[OgunTipi.ogle]!, OgunTipi.ogle);

    // Akşam yemeğini seçerken öğle yemeği ile aynı olmamasını sağla
    final aksamYemegi = _aksamYemegiSec(
      yemekler[OgunTipi.aksam]!,
      ogleYemegi,
      DateTime.now(),
    );

    return GunlukPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: DateTime.now(),
      kahvalti:
          _cesitliYemekSec(yemekler[OgunTipi.kahvalti]!, OgunTipi.kahvalti),
      araOgun1:
          _cesitliYemekSec(yemekler[OgunTipi.araOgun1]!, OgunTipi.araOgun1),
      ogleYemegi: ogleYemegi,
      araOgun2:
          _cesitliYemekSec(yemekler[OgunTipi.araOgun2]!, OgunTipi.araOgun2),
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

    // 🚫 ANA MALZEMELERİ BELİRLE (somon, tavuk, et, balık vb.)
    final ogleAnaMalzeme = _anaMalzemeyiBul(ogleYemegi.ad);

    // Hafta sonu kontrolü (Cumartesi=6, Pazar=7)
    final haftaSonuMu =
        tarih.weekday == DateTime.saturday || tarih.weekday == DateTime.sunday;

    // Hafta sonu İSTİSNASI: Nohut/fasulye gibi yemekler aynı olabilir
    final haftaSonuIstisnaYemekler = [
      'nohut',
      'fasulye',
      'barbunya',
      'kuru fasulye',
      'mercimek'
    ];

    if (haftaSonuMu && ogleAnaMalzeme != null) {
      final istisnaGecerliMi =
          haftaSonuIstisnaYemekler.contains(ogleAnaMalzeme);

      if (istisnaGecerliMi) {
        // Hafta sonu + istisna yemek: Aynı yemeği seçebilir (sessiz)
        return _cesitliYemekSec(aksamYemekleri, OgunTipi.aksam);
      }
    }

    // 🔥 KRİTİK: Öğle ile akşam FARKLI ana malzeme olmalı!
    final uygunAksamYemekleri = aksamYemekleri.where((y) {
      // 1. ID farklı olmalı
      if (y.id == ogleYemegi.id) return false;

      // 2. ANA MALZEME farklı olmalı (somon != somon, tavuk != tavuk)
      final aksamAnaMalzeme = _anaMalzemeyiBul(y.ad);
      if (ogleAnaMalzeme != null && aksamAnaMalzeme != null) {
        if (ogleAnaMalzeme == aksamAnaMalzeme) {
          return false; // Sessiz filtreleme
        }
      }

      return true;
    }).toList();

    if (uygunAksamYemekleri.isEmpty) {
      // Çok nadir: Tüm akşam yemekleri öğle ile aynı ana malzemeden (sessiz)
      return aksamYemekleri.firstWhere(
        (y) => y.id != ogleYemegi.id,
        orElse: () => aksamYemekleri.first,
      );
    }

    // Çeşitlilik mekanizmasını kullanarak seç
    final secilen = _cesitliYemekSec(uygunAksamYemekleri, OgunTipi.aksam);

    // Double-check: Seçilen öğle ile aynı ana malzemeden mi? (sessiz kontrol)
    final secilenAnaMalzeme = _anaMalzemeyiBul(secilen.ad);
    if (ogleAnaMalzeme != null &&
        secilenAnaMalzeme != null &&
        ogleAnaMalzeme == secilenAnaMalzeme) {
      // Farklı ana malzemeli yemek seç (sessiz)
      final alternatif = uygunAksamYemekleri.firstWhere(
        (y) => _anaMalzemeyiBul(y.ad) != ogleAnaMalzeme,
        orElse: () => uygunAksamYemekleri.first,
      );
      return alternatif;
    }

    return secilen;
  }

  /// Ana malzemeyi bul (somon, tavuk, et, balık, vb.)
  String? _anaMalzemeyiBul(String yemekAdi) {
    final adLower = yemekAdi.toLowerCase();

    // Ana malzemeler listesi (alfabetik sırayla)
    const anaMalzemeler = [
      'alabalık',
      'balık',
      'barbunya',
      'bonfile',
      'böbrek',
      'ciğer',
      'dana',
      'deniz ürünleri',
      'enginar',
      'fasulye',
      'hamsi',
      'hindi',
      'ıspanak',
      'kalkan',
      'karides',
      'koyun',
      'köfte',
      'kuzu',
      'kıyma',
      'kuşbaşı',
      'levrek',
      'mantar',
      'mercimek',
      'midye',
      'nohut',
      'patlıcan',
      'paça',
      'pizza',
      'rosto',
      'salam',
      'sardalye',
      'sebze',
      'sığır',
      'somon',
      'sosisli',
      'sucuk',
      'tavuk',
      'ton balığı',
      'turbot',
      'uskumru',
      'yumurta',
    ];

    // En uzun eşleşmeyi bul (örn: "ton balığı" önce denenmeli, "balık"tan önce)
    String? enUzunEslesen;
    for (final malzeme in anaMalzemeler) {
      if (adLower.contains(malzeme)) {
        if (enUzunEslesen == null || malzeme.length > enUzunEslesen.length) {
          enUzunEslesen = malzeme;
        }
      }
    }

    return enUzunEslesen;
  }

  /// Çeşitlilik sağlayan yemek seçimi (ağırlıklı rastgele) - KALICI GECMIS
  Yemek _cesitliYemekSec(List<Yemek> yemekler, OgunTipi ogunTipi) {
    if (yemekler.isEmpty) {
      AppLogger.error('❌ HATA: _cesitliYemekSec - Yemek listesi boş!');
      throw Exception('Yemek listesi boş! Genetik algoritma çalışamıyor.');
    }

    // 🔥 GÜVENLİK KONTROLÜ: Yemeklerin doğru kategoride olup olmadığını kontrol et (SESSIZ)
    final yanlisKategoriler =
        yemekler.where((y) => y.ogun != ogunTipi).toList();
    if (yanlisKategoriler.isNotEmpty) {
      // Sadece doğru kategorideki yemekleri kullan (log spam önlemek için sessiz)
      final dogruYemekler = yemekler.where((y) => y.ogun == ogunTipi).toList();
      if (dogruYemekler.isEmpty) {
        // Sadece kritik durumlarda log bas
        AppLogger.error(
            '❌ KRİTİK: ${ogunTipi.toString().split('.').last} için hiç doğru kategoride yemek yok!');
        throw Exception(
            '${ogunTipi.toString().split('.').last} kategorisinde uygun yemek bulunamadı! Lütfen migration\'ı kontrol edin.');
      }

      // Doğru yemeklerle devam et (sessizce)
      return _cesitliYemekSec(dogruYemekler, ogunTipi);
    }

    // Hive'dan kalici gecmisi al
    final sonSecilenler = CesitlilikGecmisServisi.gecmisiGetir(ogunTipi);

    // 🔥 KRİTİK: Son 3 günde kullanılan yemekleri DİREKT FİLTRELE
    // (Fitness skoruna bırakmayın, süzme yoğurt gibi makro uygun yemekler her gün gelmesin!)
    var uygunYemekler = yemekler;
    if (sonSecilenler.isNotEmpty) {
      // Son 3 yemeği al
      final yassakYemekler = sonSecilenler.length > 3
          ? sonSecilenler.sublist(sonSecilenler.length - 3)
          : sonSecilenler;

      // Son 3 günde kullanılan yemekleri FİLTRELE
      uygunYemekler =
          yemekler.where((y) => !yassakYemekler.contains(y.id)).toList();

      // Eğer tüm yemekler yasak ise (çok nadir), en azından en eski kullanılanları al (sessiz)
      if (uygunYemekler.isEmpty) {
        // Son 7 günde kullanılan yemekleri filtrele (daha yumuşak)
        final son7Yemek = sonSecilenler.length > 7
            ? sonSecilenler.sublist(sonSecilenler.length - 7)
            : sonSecilenler;
        uygunYemekler =
            yemekler.where((y) => !son7Yemek.contains(y.id)).toList();

        // Hala boşsa, tüm yemekleri kullan (son çare)
        if (uygunYemekler.isEmpty) {
          uygunYemekler = yemekler;
        }
      }
    }

    // Eğer hiç yemek seçilmemişse, normal rastgele seçim yap
    if (sonSecilenler.isEmpty) {
      return uygunYemekler[_random.nextInt(uygunYemekler.length)];
    }

    // Ağırlıklı seçim için ağırlıkları hesapla (7+ gün önceki yemekler için)
    final agirliklar = <double>[];
    for (final yemek in uygunYemekler) {
      double agirlik = 100.0; // Hiç kullanılmayanlar için çok yüksek ağırlık

      // Son N günde kullanıldı mı kontrol et (7+ gün için)
      final kullanimIndex = sonSecilenler.indexOf(yemek.id);
      if (kullanimIndex != -1) {
        final kullanimSirasi = sonSecilenler.length - kullanimIndex;

        // Son 3 gün zaten filtrelendi, burada sadece 7+ gün kontrolü
        if (kullanimSirasi <= _yakindaKullanilanSinir) {
          // 3-7 gün arası: düşük ağırlık
          agirlik = 10.0;
        } else {
          // 7+ gün önce: orta ağırlık
          agirlik = 50.0;
        }
      }
      // Hiç kullanılmamışlar zaten 100 ağırlıkta

      agirliklar.add(agirlik);
    }

    // Toplam ağırlık
    final toplamAgirlik = agirliklar.reduce((a, b) => a + b);

    // Rastgele değer seç (0 ile toplamAgirlik arasında)
    final rastgeleDeger = _random.nextDouble() * toplamAgirlik;

    // Ağırlıklara göre yemek seç
    double kumulatifAgirlik = 0.0;
    for (int i = 0; i < uygunYemekler.length; i++) {
      kumulatifAgirlik += agirliklar[i];
      if (rastgeleDeger <= kumulatifAgirlik) {
        return uygunYemekler[i];
      }
    }

    // Fallback (normalde buraya gelmemeli)
    return uygunYemekler.last;
  }

  /// Seçilen yemeği kaydet (çeşitlilik için) - KALICI GECMIS
  void _yemekSecildiKaydet(OgunTipi ogunTipi, String yemekId) {
    // Hive'a kaydet - boylece uygulama kapansa bile gecmis korunur
    CesitlilikGecmisServisi.yemekSecildi(ogunTipi, yemekId);
  }

  /// Çeşitlilik geçmişini temizle (yeni haftalık plan başlarken)
  Future<void> cesitlilikGecmisiniTemizle() async {
    await CesitlilikGecmisServisi.gecmisiTemizle();
  }

  /// Çaprazlama (crossover)
  GunlukPlan _caprazla(
    GunlukPlan parent1,
    GunlukPlan parent2,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    final kesimNoktasi = _random.nextInt(5);

    final ogleYemegi =
        kesimNoktasi > 2 ? parent1.ogleYemegi : parent2.ogleYemegi;
    var aksamYemegi =
        kesimNoktasi > 4 ? parent1.aksamYemegi : parent2.aksamYemegi;

    // 🔒 VALİDASYON: Akşam-öğle aynı olmamalı (crossover sonrası kontrol)
    // Null safety: Her iki yemeğin de null olmadığından emin ol
    if (aksamYemegi != null &&
        ogleYemegi != null &&
        ogleYemegi.id == aksamYemegi.id) {
      // Ebeveynlerden gelen akşam yemeği öğle ile aynı! Yeni akşam seç
      aksamYemegi = _aksamYemegiSec(
        yemekler[OgunTipi.aksam]!,
        ogleYemegi, // Artık null olmadığı garanti
        DateTime.now(),
      );
      // Crossover validasyonu sessiz çalışır
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

  /// Mutasyon (Dengeli mutasyon oranı)
  GunlukPlan _mutasyonUygula(
    GunlukPlan plan,
    Map<OgunTipi, List<Yemek>> yemekler,
  ) {
    const mutasyonOrani = 0.4; // Dengeli mutasyon oranı

    if (_random.nextDouble() > mutasyonOrani) {
      return plan;
    }

    final ogunIndex = _random.nextInt(5);

    switch (ogunIndex) {
      case 0:
        return plan.copyWith(
          kahvalti:
              _cesitliYemekSec(yemekler[OgunTipi.kahvalti]!, OgunTipi.kahvalti),
        );
      case 1:
        return plan.copyWith(
          araOgun1:
              _cesitliYemekSec(yemekler[OgunTipi.araOgun1]!, OgunTipi.araOgun1),
        );
      case 2:
        // Öğle yemeği değişince, akşam yemeğini de kontrol et
        final yeniOgleYemegi =
            _cesitliYemekSec(yemekler[OgunTipi.ogle]!, OgunTipi.ogle);
        // Null safety: Local variable ile flow analysis'i netleştir
        final mevcutAksam = plan.aksamYemegi;
        final yeniAksamYemegi =
            mevcutAksam != null && mevcutAksam.id == yeniOgleYemegi.id
                ? _aksamYemegiSec(
                    yemekler[OgunTipi.aksam]!, yeniOgleYemegi, plan.tarih)
                : plan.aksamYemegi;
        return plan.copyWith(
          ogleYemegi: yeniOgleYemegi,
          aksamYemegi: yeniAksamYemegi,
        );
      case 3:
        return plan.copyWith(
          araOgun2:
              _cesitliYemekSec(yemekler[OgunTipi.araOgun2]!, OgunTipi.araOgun2),
        );
      default:
        // Akşam yemeği değişirken öğle ile aynı olmamasını sağla
        // Null safety: Local variable ile flow analysis'i netleştir
        final mevcutOgle = plan.ogleYemegi;
        if (mevcutOgle != null) {
          return plan.copyWith(
            aksamYemegi: _aksamYemegiSec(
                yemekler[OgunTipi.aksam]!, mevcutOgle, plan.tarih),
          );
        }
        return plan.copyWith(
          aksamYemegi:
              _cesitliYemekSec(yemekler[OgunTipi.aksam]!, OgunTipi.aksam),
        );
    }
  }

  /// Fitness fonksiyonu - 4 MAKRO EŞİT AĞIRLIKLI (Her makro 25 puan = 100)
  double _fitnessHesapla(
    GunlukPlan plan,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    // 🎯 4 MAKRO KONTROLÜ - HER MAKRO 25 PUAN (Toplam 100)
    final kaloriSapma =
        ((plan.toplamKalori - hedefKalori).abs() / hedefKalori) * 100;
    final proteinSapma =
        ((plan.toplamProtein - hedefProtein).abs() / hedefProtein) * 100;
    final karbSapma =
        ((plan.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb) * 100;
    final yagSapma = ((plan.toplamYag - hedefYag).abs() / hedefYag) * 100;

    // Her makro için skor hesapla (0-25 puan)
    double makroSkoru(double sapmaYuzdesi) {
      if (sapmaYuzdesi <= 10.0) {
        // ±10% tolerans içinde: 22.5-25 puan
        return 25.0 - (sapmaYuzdesi * 0.25);
      } else if (sapmaYuzdesi <= 20.0) {
        // %10-20 arası: 7.5-22.5 puan (ceza)
        return 22.5 - ((sapmaYuzdesi - 10.0) * 1.5);
      } else if (sapmaYuzdesi <= 30.0) {
        // %20-30 arası: 2.5-7.5 puan (ağır ceza)
        return 7.5 - ((sapmaYuzdesi - 20.0) * 0.5);
      } else {
        // %30+ sapma: 0-2.5 puan (kabul edilemez)
        return (2.5 - (sapmaYuzdesi - 30.0) * 0.1).clamp(0.0, 2.5);
      }
    }

    final kaloriSkoru = makroSkoru(kaloriSapma);
    final proteinSkoru = makroSkoru(proteinSapma);
    final karbSkoru = makroSkoru(karbSapma);
    final yagSkoru = makroSkoru(yagSapma);

    // Toplam fitness (0-100)
    final toplamFitness = kaloriSkoru + proteinSkoru + karbSkoru + yagSkoru;

    return toplamFitness.clamp(0.0, 100.0);
  }

  /// 4 MAKRONUN DETAYLI SAPMA RAPORUNU LOGLA (KALDIRILDI - sessiz çalış)
  void _makroSapmalariniLogla(GunlukPlan plan, double hedefKalori,
      double hedefProtein, double hedefKarb, double hedefYag) {
    // Sessiz çalış - log spam önlendi
  }

  // ========================================================================
  // HAFTALIK PLAN OLUŞTURMA
  // ========================================================================

  /// Haftalık plan oluştur (7 günlük) - SESSIZ MOD
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
      final haftalikPlanlar = <GunlukPlan>[];

      // 7 gün için plan oluştur (sessiz)
      for (int gun = 0; gun < 7; gun++) {
        final planTarihi = DateTime(
          baslangic.year,
          baslangic.month,
          baslangic.day + gun,
        );

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
      }

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
