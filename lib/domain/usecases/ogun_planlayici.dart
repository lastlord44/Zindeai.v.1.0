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
    DateTime? tarih, // 🔥 Tarih parametresi eklendi
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
        tarih: tarih ?? DateTime.now(), // 🔥 Tarih parametresi geçildi
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

  /// Genetik algoritma (ÇEŞİTLİLİK OPTİMİZE EDİLMİŞ + PERFORMANS İYİLEŞTİRMESİ V4)
  GunlukPlan _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime tarih, // 🔥 Tarih parametresi eklendi
  }) {
    // 🎯 V6: OPTİMİZE EDİLMİŞ PERFORMANS + TOLERANS! (500 iterasyon)
    // ⚡ Performans: 900 → 500 iterasyon (%44 hız artışı!)
    // 🎯 Tolerans: Öğün bazlı akıllı dağılım ile ±5% hedefi
    const populasyonBoyutu = 25; // 30 → 25 (performans)
    const jenerasyonSayisi = 20; // 30 → 20 (performans)
    const elitOrani = 0.25; // En iyi bireyleri koru

    // 1. Rastgele popülasyon oluştur
    List<GunlukPlan> populasyon = List.generate(populasyonBoyutu, (_) {
      return _rastgelePlanOlustur(
          yemekler, hedefKalori, hedefProtein, hedefKarb, hedefYag, tarih);
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

        final cocuk = _caprazla(
            parent1, parent2, yemekler, tarih); // 🔥 Tarih parametresi eklendi
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

  /// Rastgele plan oluştur - ÖĞÜN BAZLI AKILLI DAĞILIM!
  GunlukPlan _rastgelePlanOlustur(
    Map<OgunTipi, List<Yemek>> yemekler,
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

    // 🎯 ÖĞÜN BAZLI AKILLI DAĞILIM (Kalori + Protein + Karb + Yağ)
    // Her öğün için hedef makrolar
    final kahvaltiHedef = _OgunHedefi(
      kalori: hedefKalori * 0.25,      // %25
      protein: hedefProtein * 0.25,
      karb: hedefKarb * 0.25,
      yag: hedefYag * 0.25,
    );
    
    final araOgun1Hedef = _OgunHedefi(
      kalori: hedefKalori * 0.10,      // %10 (ara öğünler daha büyük)
      protein: hedefProtein * 0.10,
      karb: hedefKarb * 0.10,
      yag: hedefYag * 0.10,
    );
    
    final ogleHedef = _OgunHedefi(
      kalori: hedefKalori * 0.30,      // %30
      protein: hedefProtein * 0.30,
      karb: hedefKarb * 0.30,
      yag: hedefYag * 0.30,
    );
    
    final araOgun2Hedef = _OgunHedefi(
      kalori: hedefKalori * 0.10,      // %10
      protein: hedefProtein * 0.10,
      karb: hedefKarb * 0.10,
      yag: hedefYag * 0.10,
    );
    
    final aksamHedef = _OgunHedefi(
      kalori: hedefKalori * 0.25,      // %25
      protein: hedefProtein * 0.25,
      karb: hedefKarb * 0.25,
      yag: hedefYag * 0.25,
    );

    // Öğünleri hedeflerine göre seç
    final kahvalti = _hedefliYemekSec(
      yemekler[OgunTipi.kahvalti]!,
      OgunTipi.kahvalti,
      kahvaltiHedef,
    );
    
    final araOgun1 = _hedefliYemekSec(
      yemekler[OgunTipi.araOgun1]!,
      OgunTipi.araOgun1,
      araOgun1Hedef,
    );
    
    final ogleYemegi = _hedefliYemekSec(
      yemekler[OgunTipi.ogle]!,
      OgunTipi.ogle,
      ogleHedef,
    );
    
    final araOgun2 = _hedefliYemekSec(
      yemekler[OgunTipi.araOgun2]!,
      OgunTipi.araOgun2,
      araOgun2Hedef,
    );
    
    // Akşam yemeğini seçerken öğle ile aynı olmamasını sağla
    final aksamYemegi = _hedefliAksamYemegiSec(
      yemekler[OgunTipi.aksam]!,
      ogleYemegi,
      aksamHedef,
      tarih,
    );

    return GunlukPlan(
      id: '${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: araOgun2,
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

    // 🚫 İSİM BAZLI KARA LİSTE (Ara Öğün 2 için)
    // DB yenilendiğinde ID'ler değişir ama isimler aynı kalır!
    // Süzme yoğurt makrolara çok iyi uyduğu için sürekli seçiliyor → YASAK ET!
    var uygunYemeklerIsimFiltreli = yemekler;
    if (ogunTipi == OgunTipi.araOgun2) {
      // Süzme yoğurt sayısını kontrol et
      final suzmeYogurtSayisi = yemekler
          .where((y) =>
              y.ad.toLowerCase().contains('süzme') ||
              y.ad.toLowerCase().contains('suzme'))
          .length;

      // Eğer DB'de en az 100 farklı yemek varsa, süzme yoğurtları çıkar
      if (yemekler.length >= 100) {
        uygunYemeklerIsimFiltreli = yemekler
            .where((y) =>
                !y.ad.toLowerCase().contains('süzme') &&
                !y.ad.toLowerCase().contains('suzme'))
            .toList();

        // Eğer tüm yemekler süzme yoğurt ise (çok nadir), en azından 1 tane bırak
        if (uygunYemeklerIsimFiltreli.isEmpty) {
          uygunYemeklerIsimFiltreli = yemekler;
        }
      }
    }

    // Hive'dan kalici gecmisi al
    final sonSecilenler = CesitlilikGecmisServisi.gecmisiGetir(ogunTipi);

    // 🔥 KRİTİK: Son 3 günde kullanılan yemekleri DİREKT FİLTRELE
    // (Fitness skoruna bırakmayın, süzme yoğurt gibi makro uygun yemekler her gün gelmesin!)
    var uygunYemekler =
        uygunYemeklerIsimFiltreli; // İsim filtresi uygulanmış liste
    if (sonSecilenler.isNotEmpty) {
      // Son 3 yemeği al
      final yassakYemekler = sonSecilenler.length > 3
          ? sonSecilenler.sublist(sonSecilenler.length - 3)
          : sonSecilenler;

      // Son 3 günde kullanılan yemekleri FİLTRELE
      // 🔥 DÜZELTİLDİ: İsim filtreli listeyi kullan!
      uygunYemekler = uygunYemeklerIsimFiltreli
          .where((y) => !yassakYemekler.contains(y.id))
          .toList();

      // Eğer tüm yemekler yasak ise (çok nadir), en azından en eski kullanılanları al (sessiz)
      if (uygunYemekler.isEmpty) {
        // Son 7 günde kullanılan yemekleri filtrele (daha yumuşak)
        final son7Yemek = sonSecilenler.length > 7
            ? sonSecilenler.sublist(sonSecilenler.length - 7)
            : sonSecilenler;
        // 🔥 DÜZELTİLDİ: İsim filtreli listeyi kullan!
        uygunYemekler = uygunYemeklerIsimFiltreli
            .where((y) => !son7Yemek.contains(y.id))
            .toList();

        // Hala boşsa, isim filtreli listeyi kullan (son çare)
        if (uygunYemekler.isEmpty) {
          uygunYemekler = uygunYemeklerIsimFiltreli;
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
    DateTime tarih, // 🔥 Tarih parametresi eklendi
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
        tarih, // 🔥 DateTime.now() yerine tarih parametresi kullanıldı
      );
      // Crossover validasyonu sessiz çalışır
    }

    return GunlukPlan(
      id: '${tarih.millisecondsSinceEpoch}', // 🔥 DateTime.now() yerine tarih kullanıldı
      tarih: tarih, // 🔥 DateTime.now() yerine tarih parametresi kullanıldı
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

  /// Fitness fonksiyonu - TOLERANCE-FOCUSED (±5% hedef, 4 makro eşit ağırlıklı)
  /// Her makro 25 puan = Toplam 100 puan
  /// 🎯 AMAÇ: 20,000+ yemek havuzundan ±5% tolerans içinde plan üretmek!
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

    // 🔥 YENİ: TOLERANCE-FOCUSED SKORLAMA (±5% odaklı)
    // Her makro için skor hesapla (0-25 puan)
    double makroSkoru(double sapmaYuzdesi) {
      if (sapmaYuzdesi <= 5.0) {
        // ±5% TOLERANS İÇİNDE: 20-25 puan (MÜKEMMEL! ✨)
        // Lineer azalma: 0% = 25 puan, 5% = 20 puan
        return 25.0 - (sapmaYuzdesi * 1.0);
      } else if (sapmaYuzdesi <= 10.0) {
        // %5-10 ARASI: 10-20 puan (ORTA - tolerans dışı ama kabul edilebilir)
        // Lineer azalma: 5% = 20 puan, 10% = 10 puan
        return 20.0 - ((sapmaYuzdesi - 5.0) * 2.0);
      } else if (sapmaYuzdesi <= 15.0) {
        // %10-15 ARASI: 3-10 puan (KÖTÜ - ağır ceza)
        // Lineer azalma: 10% = 10 puan, 15% = 3 puan
        return 10.0 - ((sapmaYuzdesi - 10.0) * 1.4);
      } else {
        // %15+ SAPMA: 0-3 puan (ÇOK KÖTÜ - neredeyse kabul edilemez!)
        // 15% = 3 puan, 20% = 1.5 puan, 25%+ = 0 puan
        return (3.0 - ((sapmaYuzdesi - 15.0) * 0.3)).clamp(0.0, 3.0);
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
          tarih:
              planTarihi, // 🔥 TARİH PARAMETRESİ EKLENDİ - Her gün için doğru tarih
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

  // ========================================================================
  // ÖĞÜN BAZLI HEDEFLİ SEÇİM SİSTEMİ
  // ========================================================================

  /// Hedefli yemek seçimi - Belirli makro hedeflerine en yakın yemeği seç
  Yemek _hedefliYemekSec(
    List<Yemek> yemekler,
    OgunTipi ogunTipi,
    _OgunHedefi hedef,
  ) {
    if (yemekler.isEmpty) {
      AppLogger.error('❌ HATA: _hedefliYemekSec - Yemek listesi boş!');
      throw Exception('Yemek listesi boş! Hedefli seçim yapılamıyor.');
    }

    // Çeşitlilik filtresi uygula
    final cesitliYemekler = _cesitlilikFiltresiUygula(yemekler, ogunTipi);

    // Her yemek için hedef uygunluk skoru hesapla
    final skorlar = <Yemek, double>{};
    for (final yemek in cesitliYemekler) {
      final skor = _hedefUygunlukSkoru(yemek, hedef);
      skorlar[yemek] = skor;
    }

    // En yüksek skora sahip yemekleri bul (tolerans içinde)
    final enIyiSkor = skorlar.values.reduce((a, b) => a > b ? a : b);
    final toleransliYemekler = cesitliYemekler.where((y) {
      final skor = skorlar[y]!;
      return skor >= enIyiSkor * 0.8; // En iyi skorun %80'i içinde
    }).toList();

    // Rastgele seç (çeşitlilik için)
    return toleransliYemekler[_random.nextInt(toleransliYemekler.length)];
  }

  /// Hedefli akşam yemeği seçimi - Öğle ile farklı + hedeflere yakın
  Yemek _hedefliAksamYemegiSec(
    List<Yemek> aksamYemekleri,
    Yemek ogleYemegi,
    _OgunHedefi hedef,
    DateTime tarih,
  ) {
    if (aksamYemekleri.isEmpty) {
      throw Exception('Akşam yemeği listesi boş!');
    }

    // Öğle ile farklı ana malzemeli yemekleri filtrele
    final ogleAnaMalzeme = _anaMalzemeyiBul(ogleYemegi.ad);
    var uygunYemekler = aksamYemekleri.where((y) {
      if (y.id == ogleYemegi.id) return false;
      
      final aksamAnaMalzeme = _anaMalzemeyiBul(y.ad);
      if (ogleAnaMalzeme != null && aksamAnaMalzeme != null) {
        return ogleAnaMalzeme != aksamAnaMalzeme;
      }
      return true;
    }).toList();

    if (uygunYemekler.isEmpty) {
      uygunYemekler = aksamYemekleri.where((y) => y.id != ogleYemegi.id).toList();
    }

    if (uygunYemekler.isEmpty) {
      uygunYemekler = aksamYemekleri;
    }

    // Hedefli seçim yap
    return _hedefliYemekSec(uygunYemekler, OgunTipi.aksam, hedef);
  }

  /// Çeşitlilik filtresi uygula (son 3 günde kullanılmayanları önceliklendir)
  List<Yemek> _cesitlilikFiltresiUygula(List<Yemek> yemekler, OgunTipi ogunTipi) {
    final sonSecilenler = CesitlilikGecmisServisi.gecmisiGetir(ogunTipi);
    
    if (sonSecilenler.isEmpty) {
      return yemekler;
    }

    // Son 3 günde kullanılmayanları filtrele
    final yassaklar = sonSecilenler.length > 3
        ? sonSecilenler.sublist(sonSecilenler.length - 3)
        : sonSecilenler;
    
    var filtrelenmis = yemekler.where((y) => !yassaklar.contains(y.id)).toList();
    
    // Eğer tüm yemekler yasak ise, son 7 gün kontrolü yap
    if (filtrelenmis.isEmpty) {
      final son7 = sonSecilenler.length > 7
          ? sonSecilenler.sublist(sonSecilenler.length - 7)
          : sonSecilenler;
      filtrelenmis = yemekler.where((y) => !son7.contains(y.id)).toList();
    }

    // Hala boşsa tüm yemekleri kullan
    return filtrelenmis.isEmpty ? yemekler : filtrelenmis;
  }

  /// Yemeğin hedef makrolara uygunluk skorunu hesapla (0-100)
  double _hedefUygunlukSkoru(Yemek yemek, _OgunHedefi hedef) {
    // Her makro için sapma yüzdesini hesapla
    final kaloriSapma = ((yemek.kalori - hedef.kalori).abs() / hedef.kalori) * 100;
    final proteinSapma = ((yemek.protein - hedef.protein).abs() / hedef.protein) * 100;
    final karbSapma = ((yemek.karbonhidrat - hedef.karb).abs() / hedef.karb) * 100;
    final yagSapma = ((yemek.yag - hedef.yag).abs() / hedef.yag) * 100;

    // Her makro için skor hesapla (sapma ne kadar az o kadar iyi)
    double makroSkoru(double sapma) {
      if (sapma <= 10.0) return 25.0 - (sapma * 1.5); // 0-10%: 25-10 puan
      if (sapma <= 20.0) return 10.0 - ((sapma - 10.0) * 0.8); // 10-20%: 10-2 puan
      if (sapma <= 30.0) return 2.0 - ((sapma - 20.0) * 0.15); // 20-30%: 2-0.5 puan
      return (1.0 - ((sapma - 30.0) * 0.02)).clamp(0.0, 1.0); // 30%+: <0.5 puan
    }

    final kaloriSkoru = makroSkoru(kaloriSapma);
    final proteinSkoru = makroSkoru(proteinSapma);
    final karbSkoru = makroSkoru(karbSapma);
    final yagSkoru = makroSkoru(yagSapma);

    // Toplam skor (0-100)
    return (kaloriSkoru + proteinSkoru + karbSkoru + yagSkoru).clamp(0.0, 100.0);
  }
}

/// Öğün hedefi helper sınıfı
class _OgunHedefi {
  final double kalori;
  final double protein;
  final double karb;
  final double yag;

  _OgunHedefi({
    required this.kalori,
    required this.protein,
    required this.karb,
    required this.yag,
  });
}
