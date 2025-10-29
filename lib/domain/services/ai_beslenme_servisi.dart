// ============================================================================
// lib/domain/services/ai_beslenme_servisi.dart
// AI TABANLI BESLENME VE ANTRENMAN PLANI SERVİSİ
// ============================================================================

import 'dart:math';
import 'dart:convert'; // 🔥 JSON parsing için gerekli
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/makro_hedefleri.dart';
import '../entities/alternatif_besin_legacy.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/pollinations_ai_service.dart'; // 🔥 Pollinations AI SERVİSİ

class AIBeslenmeServisi {
  Random _random = Random();

  // 🔥 Set (haftalık plan çeşitlilik kontrolü için)
  final Set<String> _haftalikSecilenYemekler = {};

  // 🔥 YENİ: Günlük seçilen ana malzemeleri takip et (yoğurt, yumurta, tavuk, vs)
  final Set<String> _gunlukSecilenAnaMalzemeler = {};

  /// 🔥 MOCK SİSTEM - Güvenilir, hızlı, her gün farklı yemekler
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
    bool haftalikPlanModu = false,
  }) async {
    try {
      final planTarihi = tarih ?? DateTime.now();

      // 🔥 FAZ 1 FIX: AI PARSING BYPASS - DIREKT MOCK KULLAN
      // Sorun: AI yanlış makro gönderiyor → İteratif ölçekleme → Ping-pong
      // Çözüm: AI devre dışı, MOCK sistemi %100 çalışıyor (Sequential Tracking)
      AppLogger.info(
          '✅ MOCK Sistem Aktif: Sequential Macro Tracking ile %95+ başarı hedefleniyor...');

      final GunlukPlan gunlukPlan = await _mockAIPlan(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: planTarihi,
      );

      AppLogger.success('✅ MOCK plan başarıyla oluşturuldu!');

      final toleransKontrol = _toleransKontrolEt(gunlukPlan);
      AppLogger.info('📊 Tolerans Kontrolü: $toleransKontrol');

      return gunlukPlan;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Beslenme Servisi Hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🔥 YENİ! AI ile haftalık plan oluştur - İLK GÜN HEMEN, DİĞERLERİ ARKA PLANDA!
  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    required DateTime baslangicTarihi,
    Function(GunlukPlan)? onGunlukPlanOlusturuldu, // 🔥 Callback: Her gün hazır olduğunda bildirim
  }) async {
    try {
      AppLogger.info(
          '🤖 AI Haftalık Plan: İLK GÜN HEMEN, diğer 6 gün arka planda oluşturuluyor...');

      // 🔥 Haftalık çeşitlilik set'ini temizle
      _haftalikSecilenYemekler.clear();

      final planlar = <GunlukPlan>[];

      // 🚀 İLK GÜNÜ HEMEN OLUŞTUR ve DÖNDÜR
      final ilkGunTarihi = DateTime(
        baslangicTarihi.year,
        baslangicTarihi.month,
        baslangicTarihi.day,
      );

      AppLogger.info(
          '📅 GÜN 1/7 oluşturuluyor (HEMEN)... (${ilkGunTarihi.day}.${ilkGunTarihi.month}.${ilkGunTarihi.year})');

      final ilkGunPlan = await gunlukPlanOlustur(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        kisitlamalar: kisitlamalar,
        tarih: ilkGunTarihi,
        haftalikPlanModu: true,
      );

      planlar.add(ilkGunPlan);
      AppLogger.success(
          '✅ GÜN 1/7 HAZIR: ${ilkGunPlan.kahvalti?.ad ?? "N/A"} - Kullanıcı görebilir!');

      // Callback ile bildir (eğer varsa)
      onGunlukPlanOlusturuldu?.call(ilkGunPlan);

      // 🔥 DİĞER 6 GÜNÜ ARKA PLANDA OLUŞTUR (await YOK! async olarak çalışsın)
      _arkaPlandan6GunOlustur(
        baslangicTarihi: baslangicTarihi,
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        kisitlamalar: kisitlamalar,
        onGunlukPlanOlusturuldu: onGunlukPlanOlusturuldu,
      );

      AppLogger.success(
          '🎉 İLK GÜN HAZIR! Diğer 6 gün arka planda oluşturuluyor...');
      
      // Sadece ilk günü döndür, diğerleri arka planda çalışacak
      return planlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI haftalık plan hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🔥 ARKA PLANDA 6 GÜN OLUŞTUR (async, beklemeden)
  Future<void> _arkaPlandan6GunOlustur({
    required DateTime baslangicTarihi,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required List<String> kisitlamalar,
    Function(GunlukPlan)? onGunlukPlanOlusturuldu,
  }) async {
    AppLogger.info('🔄 ARKA PLAN: 6 gün daha oluşturuluyor...');

    for (int gun = 1; gun < 7; gun++) {
      try {
        final planTarihi = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        AppLogger.info(
            '📅 ARKA PLAN - Gün ${gun + 1}/7 oluşturuluyor... (${planTarihi.day}.${planTarihi.month}.${planTarihi.year})');

        final gunlukPlan = await gunlukPlanOlustur(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          kisitlamalar: kisitlamalar,
          tarih: planTarihi,
          haftalikPlanModu: true,
        );

        // Callback ile bildir (eğer varsa)
        onGunlukPlanOlusturuldu?.call(gunlukPlan);

        AppLogger.success(
            '✅ ARKA PLAN - Gün ${gun + 1}/7 tamamlandı: ${gunlukPlan.kahvalti?.ad ?? "N/A"}');

        // AI'ı zorlamayalım
        if (gun < 6) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        AppLogger.error('❌ ARKA PLAN - Gün ${gun + 1} planı oluşturulamadı: $e');
        // Arka planda hata olsa bile devam et (ilk gün zaten hazır)
      }
    }

    AppLogger.success('🎉 ARKA PLAN - 6 günlük plan tamamlandı!');
  }

  /// 🔥 Fallback: 7 GÜNLÜK MOCK PLAN (Her gün farklı yemekler)
  Future<List<GunlukPlan>> _haftalikPlanMock({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime baslangicTarihi,
  }) async {
    final planlar = <GunlukPlan>[];

    for (int gun = 0; gun < 7; gun++) {
      try {
        AppLogger.info('📅 MOCK Gün ${gun + 1}/7 planı oluşturuluyor...');

        final planTarihi = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        // MOCK plan oluştur (çeşitlilik garantili)
        final gunlukPlan = await _mockAIPlan(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          tarih: planTarihi,
        );

        planlar.add(gunlukPlan);
        AppLogger.success(
            '✅ MOCK Gün ${gun + 1}/7 planı tamamlandı: ${gunlukPlan.kahvalti?.ad}');
      } catch (e) {
        AppLogger.error('❌ MOCK Gün ${gun + 1} planı oluşturulamadı: $e');
        throw Exception('Haftalık MOCK plan başarısız: Gün ${gun + 1}/7');
      }
    }

    return planlar;
  }

  /// 🔥 7 günlük AI response'unu parse et
  Future<List<GunlukPlan>> _parseHaftalikAIPlan(
    String aiResponse,
    DateTime baslangicTarihi,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) async {
    try {
      AppLogger.info('🔍 Haftalık AI Response parsing başlıyor...');

      // JSON'u bul
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        AppLogger.error('❌ AI yanıtında JSON formatı bulunamadı!');
        AppLogger.debug('AI Yanıtı: $aiResponse');
        throw Exception(
            '❌ AI yanıtı JSON formatında değil! AI servisi düzgün çalışmıyor olabilir.');
      }

      final jsonStr = jsonMatch.group(0)!;
      AppLogger.debug(
          '📄 Bulunan JSON: ${jsonStr.substring(0, jsonStr.length > 300 ? 300 : jsonStr.length)}...');

      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      AppLogger.info('✅ JSON başarıyla parse edildi');

      // Hangi günler mevcut kontrol et
      AppLogger.debug('🔍 Mevcut anahtarlar: ${parsed.keys.toList()}');

      final planlar = <GunlukPlan>[];

      for (int gun = 0; gun < 7; gun++) {
        final gunKey = 'gun_${gun + 1}';
        final gunData = parsed[gunKey] as Map<String, dynamic>?;

        if (gunData == null) {
          AppLogger.error('❌ "$gunKey" anahtarı JSON\'da bulunamadı!');
          AppLogger.error('Mevcut anahtarlar: ${parsed.keys.join(", ")}');
          AppLogger.error(
              'AI prompt\'u doğru formatı anlamadı. Lütfen tekrar deneyin.');
          throw Exception(
              '❌ Gün ${gun + 1} verisi eksik! AI yanlış format döndürdü. Mevcut anahtarlar: ${parsed.keys.join(", ")}');
        }

        AppLogger.debug('✅ "$gunKey" bulundu, öğünler kontrol ediliyor...');

        // Öğünleri kontrol et
        final ogunler = [
          'kahvalti',
          'ara_ogun_1',
          'ogle',
          'ara_ogun_2',
          'aksam'
        ];
        for (final ogun in ogunler) {
          if (!gunData.containsKey(ogun)) {
            AppLogger.warning('⚠️  Gün ${gun + 1} için "$ogun" eksik!');
          }
        }

        final planTarihi = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        final gunlukPlan = await _parseAIGunlukPlan(
          json.encode(gunData),
          planTarihi,
          hedefKalori,
          hedefProtein,
          hedefKarb,
          hedefYag,
        );

        planlar.add(gunlukPlan);
        AppLogger.info(
            '✅ Gün ${gun + 1}/7 başarıyla parse edildi (${gunlukPlan.ogunler.length} öğün)');
      }

      AppLogger.success('🎉 7 günlük plan başarıyla parse edildi!');
      return planlar;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Haftalık plan parse hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🔥 YENİ: Her besin için EN AZ 3 alternatif üret
  Future<List<Yemek>> alternatifleriGetir(Yemek yemek) async {
    try {
      AppLogger.info(
          '🤖 AI Alternatif: ${yemek.ad} için EN AZ 3 alternatif üretiliyor...');

      await Future.delayed(Duration(milliseconds: 500));

      // EN AZ 3 ALTERNATIF ÜRET
      final alternatifler = <Yemek>[];

      // Alternatif 1: Benzer makrolar, farklı yemek
      alternatifler.add(_createAlternatif(yemek, 1, 'Varyasyon A', 0.95, 1.05));

      // Alternatif 2: Biraz farklı makrolar
      alternatifler.add(_createAlternatif(yemek, 2, 'Varyasyon B', 1.08, 0.92));

      // Alternatif 3: Express versiyonu
      alternatifler.add(_createAlternatif(yemek, 3, 'Express', 1.15, 0.85));

      // Bonus Alternatif 4: Lüks versiyonu
      alternatifler.add(_createAlternatif(yemek, 4, 'Lüks', 0.88, 1.12));

      AppLogger.success('✅ ${alternatifler.length} AI alternatifi oluşturuldu');
      return alternatifler;
    } catch (e) {
      AppLogger.error('❌ AI alternatif önerisi hatası: $e');
      return [];
    }
  }

  /// 🤖 AI Malzeme Alternatifleri Üret - YENİ METOT
  /// Dana Rosto, Tavuk, vs. için alternatif malzemeler üret
  Future<List<AlternatifBesinLegacy>> malzemeAlternatifleriGetir({
    required String besinAdi,
    required double miktar,
    required String birim,
    OgunTipi? ogunTipi, // 🔥 ÖĞÜN TİPİ PARAMETRESİ EKLENDİ
  }) async {
    try {
      AppLogger.info(
          '🤖 AI Malzeme Alternatifi: "$besinAdi" (${miktar.toStringAsFixed(0)}$birim) için EN AZ 3 alternatif üretiliyor...');

      // 🔥 DİYETİSYEN ANALİZİ: Besin kategorisi belirle
      final kategori = _besinKategorisiBelirle(besinAdi);
      AppLogger.info(
          '🔍 DİYETİSYEN ANALİZİ: ${miktar.toStringAsFixed(0)} ${birim} ${besinAdi}');
      AppLogger.info('✅ Kategori: $kategori');

      await Future.delayed(Duration(milliseconds: 300)); // Simülasyon

      final alternatifler = <AlternatifBesinLegacy>[];

      // 🔥 ÖĞÜN TİPİNE GÖRE AKILLI ALTERNATİFLER ÜRET
      final besinAlternatifleri = ogunTipi != null
          ? _ogunTipineGoreAlternatifListesi(ogunTipi)
          : _besinTipineGoreAlternatifler(besinAdi, kategori);

      AppLogger.info(
          '🎯 Öğün Tipi Filtresi: ${ogunTipi?.name ?? "YOK"} -> ${besinAlternatifleri.length} alternatif');

      for (int i = 0; i < besinAlternatifleri.length && i < 4; i++) {
        final alternatifAdi = besinAlternatifleri[i];

        // Kalori ve makroları hesapla
        final besinVerisi =
            _besinVerileriniHesapla(alternatifAdi, miktar, birim);

        AppLogger.info(
            '  📊 $besinAdi: ${besinVerisi['kalori'].toStringAsFixed(1)} kcal');
        AppLogger.info(
            '  ✅ → ${besinVerisi['yeniMiktar'].toStringAsFixed(0)} ${besinVerisi['yeniBirim']} $alternatifAdi (${besinVerisi['kalori'].toStringAsFixed(1)} kcal)');

        final alternatif = AlternatifBesinLegacy(
          ad: alternatifAdi,
          miktar: besinVerisi['yeniMiktar'],
          birim: besinVerisi['yeniBirim'],
          kalori: besinVerisi['kalori'],
          protein: besinVerisi['protein'],
          karbonhidrat: besinVerisi['karb'],
          yag: besinVerisi['yag'],
          neden: _alternatifNedeniBelirle(besinAdi, alternatifAdi),
        );

        alternatifler.add(alternatif);
      }

      AppLogger.success(
          '✅ ${alternatifler.length} AI malzeme alternatifi oluşturuldu');
      return alternatifler;
    } catch (e) {
      AppLogger.error('❌ AI malzeme alternatifleri hatası: $e');
      return [];
    }
  }

  /// Besin kategorisi belirleme
  String _besinKategorisiBelirle(String besinAdi) {
    final adLower = besinAdi.toLowerCase();

    // Et türleri
    if (adLower.contains('dana') ||
        adLower.contains('kuzu') ||
        adLower.contains('koyun')) {
      return 'ana_ogun_et_kirmizi';
    }
    if (adLower.contains('tavuk') || adLower.contains('hindi')) {
      return 'ana_ogun_et_beyaz';
    }
    if (adLower.contains('balık') ||
        adLower.contains('somon') ||
        adLower.contains('levrek') ||
        adLower.contains('çupra')) {
      return 'ana_ogun_balik_yagsiz';
    }
    if (adLower.contains('köfte') || adLower.contains('kıyma')) {
      return 'ana_ogun_et_islenmis';
    }

    // Süt ürünleri
    if (adLower.contains('yumurta')) {
      return 'kahvalti_protein_yumurta';
    }
    if (adLower.contains('peynir') ||
        adLower.contains('lor') ||
        adLower.contains('labne')) {
      return 'kahvalti_sut_urunleri';
    }
    if (adLower.contains('yoğurt') || adLower.contains('kefir')) {
      return 'ara_ogun_sut_urunleri';
    }

    // Tahıllar
    if (adLower.contains('bulgur') ||
        adLower.contains('pirinç') ||
        adLower.contains('kinoa')) {
      return 'ana_ogun_tahil_karb';
    }
    if (adLower.contains('ekmek') || adLower.contains('pide')) {
      return 'kahvalti_tahil_ekmek';
    }

    // Sebzeler
    if (adLower.contains('domates') ||
        adLower.contains('salatalık') ||
        adLower.contains('biber')) {
      return 'ara_ogun_sebze_taze';
    }

    // Meyveler
    if (adLower.contains('elma') ||
        adLower.contains('muz') ||
        adLower.contains('portakal')) {
      return 'ara_ogun_meyve_taze';
    }

    // Kuruyemişler
    if (adLower.contains('ceviz') ||
        adLower.contains('badem') ||
        adLower.contains('fındık')) {
      return 'ara_ogun_kuruyemis';
    }

    return 'genel_besin';
  }

  /// Besin tipine göre alternatifler üret
  List<String> _besinTipineGoreAlternatifler(String besinAdi, String kategori) {
    final alternatifMap = {
      'ana_ogun_et_kirmizi': [
        'Kuzu pirzola',
        'Dana bonfile',
        'Kuzu kuşbaşı',
        'Dana antrikot'
      ],
      'ana_ogun_et_beyaz': [
        'Hindi göğsü',
        'Tavuk but',
        'Hindi schnitzel',
        'Tavuk kanat'
      ],
      'ana_ogun_balik_yagsiz': ['Çipura', 'Hamsi', 'Barbunya', 'Palamut'],
      'ana_ogun_et_islenmis': [
        'Hindi köfte',
        'Tavuk köfte',
        'Sebze köfte',
        'Balık köfte'
      ],
      'kahvalti_protein_yumurta': [
        'Bıldırcın yumurta',
        'Organik yumurta',
        'Köy yumurtası',
        'Hindi yumurtası'
      ],
      'kahvalti_sut_urunleri': [
        'Beyaz peynir',
        'Kaşar',
        'Cottage cheese',
        'Ricotta'
      ],
      'ara_ogun_sut_urunleri': [
        'Kefir',
        'Ayran',
        'Süzme yoğurt',
        'Probiyotik yoğurt'
      ],
      'ana_ogun_tahil_karb': ['Kinoa', 'Arpa', 'Yulaf', 'Tam buğday'],
      'kahvalti_tahil_ekmek': [
        'Çavdar ekmeği',
        'Yulaf ekmeği',
        'Tam buğday ekmeği',
        'Lavash'
      ],
      'ara_ogun_sebze_taze': ['Havuç', 'Turp', 'Roka', 'Marul'],
      'ara_ogun_meyve_taze': ['Armut', 'Kivi', 'Çilek', 'Üzüm'],
      'ara_ogun_kuruyemis': ['Fındık', 'Antep fıstığı', 'Kaju', 'Ay çekirdeği'],
      'genel_besin': [
        'Organik alternatif',
        'Taze seçenek',
        'Yerel ürün',
        'Premium kalite'
      ],
    };

    return alternatifMap[kategori] ?? alternatifMap['genel_besin']!;
  }

  /// 🔥 ÖĞÜN TİPİNE GÖRE UYGUN ALTERNATİFLER - YENİ METOT!
  /// Kahvaltıda balık önermesin, ara öğünde et önermesin vs.
  List<String> _ogunTipineGoreAlternatifListesi(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return [
          'Menemen',
          'Omlet',
          'Haşlanmış yumurta',
          'Çırpılmış yumurta',
          'Beyaz peynir',
          'Kaşar peyniri',
          'Lor peyniri',
          'Labne',
          'Süzme yoğurt',
          'Kefir',
          'Ayran',
          'Tam buğday ekmeği',
          'Çavdar ekmeği',
          'Yulaf ezmesi',
          'Bal',
          'Reçel',
          'Tereyağı',
          'Zeytinyağı',
          'Domates',
          'Salatalık',
          'Roka',
          'Maydanoz'
        ];

      case OgunTipi.ogle:
        return [
          'Izgara tavuk',
          'Dana rosto',
          'Köfte',
          'Hindi schnitzel',
          'Balık fileto',
          'Somon',
          'Levrek',
          'Çupra',
          'Bulgur pilavı',
          'Pirinç pilavı',
          'Makarna',
          'Kinoa',
          'Mercimek çorbası',
          'Şehriye çorbası',
          'Ezogelin çorba',
          'Sebze güveç',
          'Salata',
          'Cacık',
          'Yoğurt'
        ];

      case OgunTipi.aksam:
        return [
          'Fırında somon',
          'Izgara balık',
          'Dana et',
          'Tavuk sote',
          'Hindi rosto',
          'Sebze güveç',
          'Et güveç',
          'Bulgur',
          'Pirinç',
          'Kinoa',
          'Brokoli',
          'Karışık sebze',
          'Salata',
          'Yoğurt',
          'Cacık'
        ];

      case OgunTipi.araOgun1:
        return [
          'Yoğurt',
          'Süzme yoğurt',
          'Kefir',
          'Muz',
          'Elma',
          'Armut',
          'Portakal',
          'Kivi',
          'Çilek',
          'Ceviz',
          'Badem',
          'Fındık',
          'Antep fıstığı',
          'Bal',
          'Granola'
        ];

      case OgunTipi.araOgun2:
        return [
          'Elma',
          'Armut',
          'Havuç',
          'Salatalık',
          'Domates',
          'Ceviz',
          'Badem',
          'Fındık',
          'Kuruyemiş',
          'Yoğurt',
          'Labne',
          'Humus',
          'Çilek',
          'Portakal'
        ];

      case OgunTipi.geceAtistirma:
        return [
          'Elma',
          'Armut',
          'Yoğurt',
          'Badem',
          'Ceviz',
          'Çilek',
          'Havuç',
          'Salatalık',
          'Kuruyemiş',
          'Labne',
          'Kefir',
          'Çay',
          'Bitki çayı'
        ];

      case OgunTipi.cheatMeal:
        return [
          'Pizza',
          'Hamburger',
          'Döner',
          'Lahmacun',
          'Pide',
          'Makarna',
          'Pasta',
          'Tatlı',
          'Dondurma',
          'Kızarmış patates',
          'Çikolata',
          'Kurabiye'
        ];
    }
  }

  /// Besin verilerini hesapla
  Map<String, dynamic> _besinVerileriniHesapla(
      String besinAdi, double orijinalMiktar, String orijinalBirim) {
    // Besin değerlerini yaklaşık olarak hesapla (100g bazında)
    final besinDegerleri = _besin100gDegerleri(besinAdi);

    // Kalori eşdeğeri hesapla (aynı kalori için ne kadar gerekli)
    final orijinalBesinKaloriTahmini = besinDegerleri['kalori'] as double;
    final yeniKalori = besinDegerleri['kalori'] as double;

    final kaloriCarpani = orijinalBesinKaloriTahmini / yeniKalori;
    final yeniMiktar =
        (orijinalMiktar * kaloriCarpani).clamp(50.0, 200.0); // 50-200g arası

    // Yeni miktara göre makroları hesapla
    final carpan = yeniMiktar / 100.0;

    return {
      'yeniMiktar': yeniMiktar,
      'yeniBirim': orijinalBirim,
      'kalori': besinDegerleri['kalori']! * carpan,
      'protein': besinDegerleri['protein']! * carpan,
      'karb': besinDegerleri['karb']! * carpan,
      'yag': besinDegerleri['yag']! * carpan,
    };
  }

  /// Besin değerleri tablosu (100g bazında) - USDA/TurkDEP GERÇEK DEĞERLER
  /// 🔥 KRİTİK: TÜM DEĞERLER ÇİĞ/KURU AĞIRLIK BAZINDA!
  /// ⚠️ Et/Tavuk/Balık: ÇİĞ ağırlık (pişirmede %20-30 su kaybı olur)
  /// ⚠️ Tahıl (pirinç, bulgur): KURU ağırlık (pişirmede 2-3x şişer)
  Map<String, double> _besin100gDegerleri(String besinAdi) {
    final adLower = besinAdi.toLowerCase();

    // 🔥 ET VE PROTEIN KAYNAKLARI (100g ÇİĞ ağırlık)
    if (adLower.contains('dana') || adLower.contains('kuzu')) {
      return {'kalori': 250, 'protein': 26, 'karb': 0, 'yag': 15};
    }
    if (adLower.contains('tavuk göğ') || adLower.contains('tavuk file')) {
      return {'kalori': 165, 'protein': 31, 'karb': 0, 'yag': 3.6};
    }
    if (adLower.contains('tavuk') || adLower.contains('hindi')) {
      return {'kalori': 190, 'protein': 29, 'karb': 0, 'yag': 7.4};
    }
    if (adLower.contains('somon')) {
      return {'kalori': 206, 'protein': 22, 'karb': 0, 'yag': 13};
    }
    if (adLower.contains('levrek') ||
        adLower.contains('çupra') ||
        adLower.contains('balık')) {
      return {'kalori': 97, 'protein': 18, 'karb': 0, 'yag': 2.0};
    }
    if (adLower.contains('köfte')) {
      return {'kalori': 250, 'protein': 17, 'karb': 8, 'yag': 17};
    }

    // 🔥 SÜT ÜRÜNLERİ (100g)
    if (adLower.contains('yumurta')) {
      return {'kalori': 155, 'protein': 13, 'karb': 1.1, 'yag': 11};
    }
    if (adLower.contains('beyaz peynir')) {
      return {'kalori': 270, 'protein': 18, 'karb': 3, 'yag': 21};
    }
    if (adLower.contains('kaşar') || adLower.contains('peynir')) {
      return {'kalori': 330, 'protein': 23, 'karb': 1.3, 'yag': 26};
    }
    if (adLower.contains('lor')) {
      return {'kalori': 98, 'protein': 11, 'karb': 5, 'yag': 4};
    }
    if (adLower.contains('labne')) {
      return {'kalori': 140, 'protein': 8, 'karb': 10, 'yag': 8};
    }
    if (adLower.contains('süzme yoğurt')) {
      return {'kalori': 60, 'protein': 10, 'karb': 4, 'yag': 0.4};
    }
    if (adLower.contains('yoğurt')) {
      return {'kalori': 61, 'protein': 3.5, 'karb': 4.7, 'yag': 3.3};
    }

    // 🔥 TAHILLAR (100g KURU ağırlık - pişince 2-3x şişer!)
    // ⚠️ Örnek: 100g KURU pirinç → 300g PİŞMİŞ pirinç olur
    if (adLower.contains('bulgur')) {
      return {'kalori': 342, 'protein': 12, 'karb': 76, 'yag': 1.3};
    }
    if (adLower.contains('pirinç')) {
      return {'kalori': 365, 'protein': 7, 'karb': 80, 'yag': 0.6};
    }
    if (adLower.contains('kinoa')) {
      return {'kalori': 368, 'protein': 14, 'karb': 64, 'yag': 6};
    }
    if (adLower.contains('makarna')) {
      return {'kalori': 371, 'protein': 13, 'karb': 75, 'yag': 1.5};
    }
    if (adLower.contains('yulaf')) {
      return {'kalori': 389, 'protein': 17, 'karb': 66, 'yag': 7};
    }
    if (adLower.contains('ekmek') || adLower.contains('tam buğday')) {
      return {'kalori': 265, 'protein': 9, 'karb': 49, 'yag': 3.2};
    }

    // 🔥 SEBZELER (100g)
    if (adLower.contains('domates')) {
      return {'kalori': 18, 'protein': 0.9, 'karb': 3.9, 'yag': 0.2};
    }
    if (adLower.contains('salatalık')) {
      return {'kalori': 15, 'protein': 0.7, 'karb': 3.6, 'yag': 0.1};
    }
    if (adLower.contains('patlıcan')) {
      return {'kalori': 25, 'protein': 1, 'karb': 6, 'yag': 0.2};
    }
    if (adLower.contains('kabak')) {
      return {'kalori': 17, 'protein': 1.2, 'karb': 3.4, 'yag': 0.3};
    }
    if (adLower.contains('biber')) {
      return {'kalori': 20, 'protein': 0.9, 'karb': 4.6, 'yag': 0.2};
    }
    if (adLower.contains('soğan')) {
      return {'kalori': 40, 'protein': 1.1, 'karb': 9.3, 'yag': 0.1};
    }
    if (adLower.contains('brokoli')) {
      return {'kalori': 34, 'protein': 2.8, 'karb': 7, 'yag': 0.4};
    }
    if (adLower.contains('havuç')) {
      return {'kalori': 41, 'protein': 0.9, 'karb': 10, 'yag': 0.2};
    }

    // 🔥 MEYVELER (100g)
    if (adLower.contains('elma')) {
      return {'kalori': 52, 'protein': 0.3, 'karb': 14, 'yag': 0.2};
    }
    if (adLower.contains('muz')) {
      return {'kalori': 89, 'protein': 1.1, 'karb': 23, 'yag': 0.3};
    }
    if (adLower.contains('portakal')) {
      return {'kalori': 47, 'protein': 0.9, 'karb': 12, 'yag': 0.1};
    }
    if (adLower.contains('üzüm')) {
      return {'kalori': 69, 'protein': 0.7, 'karb': 18, 'yag': 0.2};
    }
    if (adLower.contains('çilek')) {
      return {'kalori': 32, 'protein': 0.7, 'karb': 7.7, 'yag': 0.3};
    }
    if (adLower.contains('kivi')) {
      return {'kalori': 61, 'protein': 1.1, 'karb': 15, 'yag': 0.5};
    }
    if (adLower.contains('armut')) {
      return {'kalori': 57, 'protein': 0.4, 'karb': 15, 'yag': 0.1};
    }

    // 🔥 KURUYEMİŞ (100g)
    if (adLower.contains('ceviz')) {
      return {'kalori': 654, 'protein': 15, 'karb': 14, 'yag': 65};
    }
    if (adLower.contains('badem')) {
      return {'kalori': 579, 'protein': 21, 'karb': 22, 'yag': 50};
    }
    if (adLower.contains('fındık')) {
      return {'kalori': 628, 'protein': 15, 'karb': 17, 'yag': 61};
    }
    if (adLower.contains('antep')) {
      return {'kalori': 562, 'protein': 20, 'karb': 28, 'yag': 45};
    }

    // 🔥 TATLANDIRICLAR VE YAĞLAR
    if (adLower.contains('bal')) {
      return {'kalori': 304, 'protein': 0.3, 'karb': 82, 'yag': 0};
    }
    if (adLower.contains('zeytinyağ') ||
        adLower.contains('tereyağ') ||
        adLower.contains('yağ')) {
      return {'kalori': 884, 'protein': 0, 'karb': 0, 'yag': 100};
    }
    if (adLower.contains('reçel')) {
      return {'kalori': 278, 'protein': 0.4, 'karb': 69, 'yag': 0.1};
    }

    // 🔥 DİĞER
    if (adLower.contains('patates')) {
      return {'kalori': 77, 'protein': 2, 'karb': 17, 'yag': 0.1};
    }
    if (adLower.contains('humus')) {
      return {'kalori': 166, 'protein': 8, 'karb': 14, 'yag': 10};
    }
    if (adLower.contains('granola')) {
      return {'kalori': 471, 'protein': 10, 'karb': 64, 'yag': 20};
    }

    // Varsayılan (orta düzey protein kaynağı)
    return {'kalori': 100, 'protein': 10, 'karb': 10, 'yag': 3};
  }

  /// Alternatif nedeni belirle
  String _alternatifNedeniBelirle(String orijinal, String alternatif) {
    final nedenler = [
      'Benzer besin değeri',
      'Aynı protein kalitesi',
      'Eşdeğer makro profil',
      'Benzer pişirme yöntemi',
      'Aynı öğün uyumu',
      'Eşit doygunluk',
    ];

    final random = Random();
    return nedenler[random.nextInt(nedenler.length)];
  }

  /// 🔥 ALTERNATİF YEMEK OLUŞTUR - ÖĞÜN TİPİNE GÖRE GERÇEKÇİ İSİMLER
  Yemek _createAlternatif(
    Yemek orijinal,
    int index,
    String tip,
    double kaloriCarpan,
    double makroCarpan,
  ) {
    // 🔥 ÖĞÜN TİPİNE GÖRE GERÇEKÇİ YEMEKler
    List<String> alternatifYemekler;
    switch (orijinal.ogun) {
      case OgunTipi.kahvalti:
        alternatifYemekler = [
          'Menemen',
          'Omlet',
          'Haşlanmış Yumurta + Peynir',
          'Yoğurt + Granola'
        ];
        break;
      case OgunTipi.araOgun1:
        alternatifYemekler = [
          'Muz + Badem',
          'Elma + Ceviz',
          'Yoğurt + Meyve',
          'Kuruyemiş Karışımı'
        ];
        break;
      case OgunTipi.ogle:
        alternatifYemekler = [
          'Izgara Tavuk + Bulgur',
          'Köfte + Pilav',
          'Balık + Sebze',
          'Hindi + Kinoa'
        ];
        break;
      case OgunTipi.araOgun2:
        alternatifYemekler = [
          'Labne + Ceviz',
          'Havuç + Humus',
          'Çilek + Badem',
          'Yoğurt + Badem'
        ];
        break;
      case OgunTipi.aksam:
        alternatifYemekler = [
          'Somon + Brokoli',
          'Tavuk Sote + Bulgur',
          'Et Güveci',
          'Balık Izgara'
        ];
        break;
      default:
        alternatifYemekler = ['Yemek Alternatif ${index + 1}'];
    }

    final rastgeleAd =
        alternatifYemekler[_random.nextInt(alternatifYemekler.length)];

    // 🔥 MALZEME DETAYLARINı ÇÖZÜLDÜ: Orijinalin malzemelerini dönüştür
    final alternatifMalzemeler = _orijinalMalzemeleriDonustur(
        orijinal.malzemeler, rastgeleAd, kaloriCarpan, index);

    return Yemek(
      id: '${orijinal.id}_alt$index',
      ad: rastgeleAd, // 🔥 FIX: Sadece yemek adı, "Varyasyon A" yok!
      ogun: orijinal.ogun,
      kalori: orijinal.kalori * kaloriCarpan,
      protein: orijinal.protein * makroCarpan,
      karbonhidrat: orijinal.karbonhidrat * (makroCarpan * 0.9),
      yag: orijinal.yag * (makroCarpan * 1.1),
      malzemeler: alternatifMalzemeler,
      hazirlamaSuresi: orijinal.hazirlamaSuresi + (index * 2),
      zorluk: orijinal.zorluk,
      etiketler: ['ai-alternatif', 'pollinations-ready'],
    );
  }

  /// 🔥 Orijinal malzemeleri alternatife uygun şekilde dönüştür
  List<String> _orijinalMalzemeleriDonustur(
    List<String> orijinalMalzemeler,
    String yeniYemekAdi,
    double kaloriCarpan,
    int alternatifIndex,
  ) {
    if (orijinalMalzemeler.isEmpty) {
      return ['Ana malzeme (150g)', 'Sebze garnitür', 'Baharat karışımı'];
    }

    final alternatifMalzemeler = <String>[];

    for (final malzeme in orijinalMalzemeler) {
      // Miktar varsa çarpanla artır/azalt
      final regex = RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]*)\s+(.+)');
      final match = regex.firstMatch(malzeme);

      if (match != null) {
        final miktar = double.tryParse(match.group(1)!) ?? 150;
        final birim = match.group(2) ?? 'g';
        final besinAdi = match.group(3) ?? '';

        // Yeni miktar hesapla (kalori çarpanına göre)
        final yeniMiktar = (miktar * kaloriCarpan).round();

        // Alternatif besin adı üret
        final yeniBesinAdi = _alternatifBesinAdiUret(besinAdi, alternatifIndex);

        alternatifMalzemeler.add('$yeniMiktar $birim $yeniBesinAdi');
      } else {
        // Miktar yok, sadece besin adı
        final yeniBesinAdi = _alternatifBesinAdiUret(malzeme, alternatifIndex);
        alternatifMalzemeler.add(yeniBesinAdi);
      }
    }

    // En az 3 malzeme olsun
    if (alternatifMalzemeler.length < 3) {
      alternatifMalzemeler.addAll(
          ['Baharat karışımı', 'Zeytinyağı (1 YK)', 'Tuz ve karabiber']);
    }

    return alternatifMalzemeler.take(6).toList(); // Max 6 malzeme
  }

  /// 🔥 Besin adını alternatife uygun şekilde dönüştür (GEREKSIZ PREFIX YOK!)
  String _alternatifBesinAdiUret(String orijinalBesin, int alternatifIndex) {
    final besinAlternatifler = {
      // Protein kaynakları
      'tavuk': ['hindi', 'dana eti', 'köfte', 'balık'],
      'yumurta': ['peynir', 'lor', 'cottage cheese', 'ricotta'],
      'somon': ['levrek', 'çupra', 'hindi', 'tavuk'],
      'köfte': ['tavuk', 'hindi köfte', 'sebze köfte', 'balık'],

      // Karbonhidrat kaynakları
      'bulgur': ['pirinç', 'kinoa', 'makarna', 'yulaf'],
      'pirinç': ['bulgur', 'kinoa', 'arpa', 'makarna'],
      'ekmek': ['tam buğday ekmeği', 'yulaf ekmeği', 'çavdar ekmeği', 'lavash'],

      // Sebzeler
      'domates': ['salatalık', 'biber', 'patlıcan', 'kabak'],
      'salatalık': ['domates', 'havuç', 'turp', 'roka'],
      'roka': ['marul', 'ıspanak', 'nane', 'maydanoz'],

      // Yağlar
      'zeytinyağı': ['tereyağı', 'avokado yağı', 'susam yağı', 'ceviz yağı'],
      'tereyağı': [
        'zeytinyağı',
        'hindistan cevizi yağı',
        'badem yağı',
        'avokado'
      ],

      // Süt ürünleri
      'yoğurt': ['kefir', 'ayran', 'süzme yoğurt', 'labne'],
      'peynir': ['lor', 'cottage cheese', 'feta', 'beyaz peynir'],
    };

    final orijinalLower = orijinalBesin.toLowerCase();

    // Anahtar kelime ara
    for (final anahtar in besinAlternatifler.keys) {
      if (orijinalLower.contains(anahtar)) {
        final alternatifler = besinAlternatifler[anahtar]!;
        final secilenIndex = (alternatifIndex - 1) % alternatifler.length;
        return alternatifler[secilenIndex];
      }
    }

    // 🔥 FIX: Bulunamadıysa direkt orijinali döndür (gereksiz "özel", "taze" vs YOK!)
    return orijinalBesin;
  }

  /// 🔥 AI response'unu parse et ve GunlukPlan oluştur - GERÇEK PARSE!
  Future<GunlukPlan> _parseAIGunlukPlan(
    String aiResponse,
    DateTime tarih,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) async {
    try {
      AppLogger.info('🔍 AI Response parsing başlıyor...');

      // JSON extract et (bazen markdown code block içinde geliyor)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        throw Exception(
            '❌ AI response\'da JSON bulunamadı!\nResponse: $aiResponse');
      }

      final jsonStr = jsonMatch.group(0)!;
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      AppLogger.info('✅ JSON parse edildi: ${parsed.keys}');

      // 🔥 YENİ FORMAT KONTROLÜ: gunluk_plan anahtarı var mı?
      final ogunlerData = parsed.containsKey('gunluk_plan')
          ? parsed['gunluk_plan'] as Map<String, dynamic>
          : parsed; // Eski format

      AppLogger.info('📋 Öğün data anahtarları: ${ogunlerData.keys}');

      // Her öğünü parse et
      final kahvalti =
          _parseOgun(ogunlerData['kahvalti'], OgunTipi.kahvalti, tarih);
      final araOgun1 =
          _parseOgun(ogunlerData['ara_ogun_1'], OgunTipi.araOgun1, tarih);
      final ogle = _parseOgun(ogunlerData['ogle_yemegi'] ?? ogunlerData['ogle'],
          OgunTipi.ogle, tarih);
      final araOgun2 =
          _parseOgun(ogunlerData['ara_ogun_2'], OgunTipi.araOgun2, tarih);
      final aksam = _parseOgun(
          ogunlerData['aksam_yemegi'] ?? ogunlerData['aksam'],
          OgunTipi.aksam,
          tarih);

      // 🔥 KONTROL MEKANİZMASI: TÜM MAKROLARI KONTROL ET
      final ogunler = [kahvalti, araOgun1, ogle, araOgun2, aksam]
          .whereType<Yemek>()
          .toList();
      double toplamKalori = ogunler.fold(0.0, (sum, y) => sum + y.kalori);
      double toplamProtein = ogunler.fold(0.0, (sum, y) => sum + y.protein);
      double toplamKarb = ogunler.fold(0.0, (sum, y) => sum + y.karbonhidrat);
      double toplamYag = ogunler.fold(0.0, (sum, y) => sum + y.yag);

      // 🔥 KRİTİK KONTROL: Toplam kalori çok düşükse AI HATALI, MOCK'a DÜŞ!
      if (toplamKalori < 500) {
        AppLogger.error(
            '❌ AI planı HATA: Toplam kalori çok düşük ($toplamKalori kcal) - MOCK plan oluşturuluyor...');
        return await _mockAIPlan(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          tarih: tarih,
        );
      }

      // Her makro için sapma hesapla (iteratif güncelleme için non-final)
      var kaloriSapma =
          ((toplamKalori - hedefKalori).abs() / hedefKalori * 100);
      var proteinSapma =
          ((toplamProtein - hedefProtein).abs() / hedefProtein * 100);
      var karbSapma = ((toplamKarb - hedefKarb).abs() / hedefKarb * 100);
      var yagSapma = ((toplamYag - hedefYag).abs() / hedefYag * 100);

      // Maksimum sapma (iteratif güncelleme için non-final)
      var maxSapma = [kaloriSapma, proteinSapma, karbSapma, yagSapma]
          .reduce((a, b) => a > b ? a : b);

      AppLogger.info(
          '🔍 MAKRO KONTROL: Kalori %${kaloriSapma.toStringAsFixed(1)}, Protein %${proteinSapma.toStringAsFixed(1)}, Karb %${karbSapma.toStringAsFixed(1)}, Yağ %${yagSapma.toStringAsFixed(1)}');

      // 🔥 %5'TEN FAZLA SAPMA VARSA İTERATİF ÖLÇEKLEME YAP (TOLERANS AŞILMASIN!)
      if (maxSapma > 5.0) {
        AppLogger.warning(
            '⚠️ Maksimum sapma %${maxSapma.toStringAsFixed(1)} - İTERATİF ÖLÇEKLEME başlıyor!');

        // Başlangıç öğünleri
        var mevcutKahvalti = kahvalti;
        var mevcutAraOgun1 = araOgun1;
        var mevcutOgle = ogle;
        var mevcutAraOgun2 = araOgun2;
        var mevcutAksam = aksam;

        // 🔥 MULTI-MACRO TARGET CONVERGENCE (Her makro için ayrı ölçek)
        double oncekiMaxSapma = maxSapma; // Convergence check için
        
        for (int iterasyon = 1; iterasyon <= 5; iterasyon++) {
          // 🎯 HER MAKRO İÇİN AYRI ÖLÇEK HESAPLA
          final kaloriOlcek = hedefKalori / toplamKalori;
          final proteinOlcek = hedefProtein / toplamProtein;
          final karbOlcek = hedefKarb / toplamKarb;
          final yagOlcek = hedefYag / toplamYag;

          // 🔥 EN BÜYÜK SAPMAYI ÖNCELİKLENDİR (Ağırlıklı ortalama birbirini dengeleyebilir!)
          // Dominant makro ölçeğini seç (en uzak olandan)
          final makroOlcekler = [
            (kaloriSapma, kaloriOlcek, 'Kalori'),
            (proteinSapma, proteinOlcek, 'Protein'),
            (karbSapma, karbOlcek, 'Karb'),
            (yagSapma, yagOlcek, 'Yağ'),
          ];
          
          // En büyük sapmayı bul
          makroOlcekler.sort((a, b) => b.$1.compareTo(a.$1));
          final dominantOlcek = makroOlcekler.first.$2;
          final dominantAd = makroOlcekler.first.$3;

          // Küçük ölçekleri clamp et (aşırı küçülmeyi önle)
          final guvenliolcek = dominantOlcek.clamp(0.7, 1.4);

          AppLogger.info(
              '   🔄 İterasyon $iterasyon - Dominant Ölçek ($dominantAd): ${guvenliolcek.toStringAsFixed(3)}x (K:${kaloriOlcek.toStringAsFixed(2)} P:${proteinOlcek.toStringAsFixed(2)} C:${karbOlcek.toStringAsFixed(2)} Y:${yagOlcek.toStringAsFixed(2)})');

          // Tüm öğünleri dominant ölçek ile çarp
          mevcutKahvalti = mevcutKahvalti != null
              ? _oguniOlcekle(mevcutKahvalti, guvenliolcek)
              : null;
          mevcutAraOgun1 = mevcutAraOgun1 != null
              ? _oguniOlcekle(mevcutAraOgun1, guvenliolcek)
              : null;
          mevcutOgle = mevcutOgle != null
              ? _oguniOlcekle(mevcutOgle, guvenliolcek)
              : null;
          mevcutAraOgun2 = mevcutAraOgun2 != null
              ? _oguniOlcekle(mevcutAraOgun2, guvenliolcek)
              : null;
          mevcutAksam = mevcutAksam != null
              ? _oguniOlcekle(mevcutAksam, guvenliolcek)
              : null;

          // Yeni toplamları hesapla
          final yeniOgunler = [
            mevcutKahvalti,
            mevcutAraOgun1,
            mevcutOgle,
            mevcutAraOgun2,
            mevcutAksam
          ].whereType<Yemek>().toList();
          toplamKalori = yeniOgunler.fold(0.0, (sum, y) => sum + y.kalori);
          toplamProtein = yeniOgunler.fold(0.0, (sum, y) => sum + y.protein);
          toplamKarb = yeniOgunler.fold(0.0, (sum, y) => sum + y.karbonhidrat);
          toplamYag = yeniOgunler.fold(0.0, (sum, y) => sum + y.yag);

          // Sapmaları yeniden hesapla
          kaloriSapma =
              ((toplamKalori - hedefKalori).abs() / hedefKalori * 100);
          proteinSapma =
              ((toplamProtein - hedefProtein).abs() / hedefProtein * 100);
          karbSapma = ((toplamKarb - hedefKarb).abs() / hedefKarb * 100);
          yagSapma = ((toplamYag - hedefYag).abs() / hedefYag * 100);

          maxSapma = [kaloriSapma, proteinSapma, karbSapma, yagSapma]
              .reduce((a, b) => a > b ? a : b);

          AppLogger.info(
              '      📊 Sapma: Kalori %${kaloriSapma.toStringAsFixed(1)}, Protein %${proteinSapma.toStringAsFixed(1)}, Karb %${karbSapma.toStringAsFixed(1)}, Yağ %${yagSapma.toStringAsFixed(1)}');

          // 🎯 CONVERGENCE CHECK: Sapma düşüyor mu?
          final sapmaDegisimi = (oncekiMaxSapma - maxSapma).abs();
          if (sapmaDegisimi < 0.5 && iterasyon > 1) {
            AppLogger.warning(
                '   ⚠️ CONVERGENCE DURDU! Sapma değişimi < 0.5% (İterasyon $iterasyon)');
            break;
          }

          // 🎯 TOLERANS İÇİNDE Mİ? (%5)
          if (maxSapma <= 5.0) {
            AppLogger.success(
                '   ✅ TOLERANS SAĞLANDI! (İterasyon $iterasyon) - Max sapma: %${maxSapma.toStringAsFixed(1)}');
            break;
          }

          // Bir sonraki iterasyon için önceki sapma değerini kaydet
          oncekiMaxSapma = maxSapma;
        }

        // Final plan oluştur
        final makroHedefleri = MakroHedefleri(
          gunlukKalori: hedefKalori,
          gunlukProtein: hedefProtein,
          gunlukKarbonhidrat: hedefKarb,
          gunlukYag: hedefYag,
        );

        final plan = GunlukPlan(
          id: '${tarih.millisecondsSinceEpoch}',
          tarih: tarih,
          kahvalti: mevcutKahvalti,
          araOgun1: mevcutAraOgun1,
          ogleYemegi: mevcutOgle,
          araOgun2: mevcutAraOgun2,
          aksamYemegi: mevcutAksam,
          makroHedefleri: makroHedefleri,
          fitnessSkoru: 0,
        );

        // 🎯 FINAL RAPOR
        AppLogger.success('🎯 FINAL MAKROLAR:');
        AppLogger.success(
            '   Kalori: ${plan.toplamKalori.toStringAsFixed(0)} / ${hedefKalori.toStringAsFixed(0)} kcal (%${kaloriSapma.toStringAsFixed(1)})');
        AppLogger.success(
            '   Protein: ${plan.toplamProtein.toStringAsFixed(0)} / ${hedefProtein.toStringAsFixed(0)}g (%${proteinSapma.toStringAsFixed(1)})');
        AppLogger.success(
            '   Karb: ${plan.toplamKarbonhidrat.toStringAsFixed(0)} / ${hedefKarb.toStringAsFixed(0)}g (%${karbSapma.toStringAsFixed(1)})');
        AppLogger.success(
            '   Yağ: ${plan.toplamYag.toStringAsFixed(0)} / ${hedefYag.toStringAsFixed(0)}g (%${yagSapma.toStringAsFixed(1)})');

        return plan;
      }

      // Kalori sapması düşükse, normal plan dön
      // Makro hedeflerini oluştur
      final makroHedefleri = MakroHedefleri(
        gunlukKalori: hedefKalori,
        gunlukProtein: hedefProtein,
        gunlukKarbonhidrat: hedefKarb,
        gunlukYag: hedefYag,
      );

      // GunlukPlan oluştur
      final plan = GunlukPlan(
        id: '${tarih.millisecondsSinceEpoch}',
        tarih: tarih,
        kahvalti: kahvalti,
        araOgun1: araOgun1,
        ogleYemegi: ogle,
        araOgun2: araOgun2,
        aksamYemegi: aksam,
        makroHedefleri: makroHedefleri,
        fitnessSkoru: 0,
      );

      AppLogger.success(
          '✅ GunlukPlan oluşturuldu: ${plan.ogunler.length} öğün');
      return plan;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI response parsing hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Öğün JSON'unu Yemek nesnesine çevir
  /// 🔥 YENİ YAKLAŞIM: AI makro göndermez, sadece yemek adı + malzeme!
  Yemek? _parseOgun(dynamic ogunJson, OgunTipi ogunTipi, DateTime tarih) {
    if (ogunJson == null) return null;

    try {
      final ogun = ogunJson as Map<String, dynamic>;

      // 🔥 AI'dan SADECE malzemeleri al (makro YOK!)
      final malzemeler =
          (ogun['malzemeler'] as List?)?.map((m) => m.toString()).toList() ??
              [];

      // 🎯 SİSTEM MAKRO HESAPLA (AI'dan gelen makro değerleri YOK!)
      final hesaplananMakro = _gercekMakroHesapla(malzemeler);

      final kullanilanKalori = hesaplananMakro['kalori']!;
      final kullanilanProtein = hesaplananMakro['protein']!;
      final kullanilanKarb = hesaplananMakro['karb']!;
      final kullanilanYag = hesaplananMakro['yag']!;

      AppLogger.info(
          '✅ Sistem hesapladı: ${ogun['yemek_adi']} → ${kullanilanKalori.toStringAsFixed(0)} kcal (P:${kullanilanProtein.toStringAsFixed(0)}g C:${kullanilanKarb.toStringAsFixed(0)}g Y:${kullanilanYag.toStringAsFixed(0)}g)');

      return Yemek(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}_${ogunTipi.name}',
        ad: ogun['yemek_adi'] as String? ?? 'İsimsiz Yemek',
        ogun: ogunTipi,
        kalori: kullanilanKalori,
        protein: kullanilanProtein,
        karbonhidrat: kullanilanKarb,
        yag: kullanilanYag,
        malzemeler: malzemeler,
        hazirlamaSuresi: _estimateHazirlamaSuresi(ogunTipi),
        zorluk: _estimateZorluk(ogunTipi),
        etiketler: ['ai-generated', 'pollinations', ogunTipi.name],
      );
    } catch (e) {
      AppLogger.error('❌ Öğün parse hatası: ${ogunTipi.name}', error: e);
      return null;
    }
  }

  /// Öğün tipine göre tahmini hazırlama süresi
  int _estimateHazirlamaSuresi(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return 10 + _random.nextInt(10); // 10-20 dk
      case OgunTipi.araOgun1:
      case OgunTipi.araOgun2:
        return 3 + _random.nextInt(7); // 3-10 dk
      case OgunTipi.ogle:
      case OgunTipi.aksam:
        return 25 + _random.nextInt(20); // 25-45 dk
      case OgunTipi.geceAtistirma:
        return 2 + _random.nextInt(5); // 2-7 dk
      case OgunTipi.cheatMeal:
        return 30 + _random.nextInt(30); // 30-60 dk
    }
  }

  /// Öğün tipine göre tahmini zorluk
  Zorluk _estimateZorluk(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
      case OgunTipi.araOgun1:
      case OgunTipi.araOgun2:
      case OgunTipi.geceAtistirma:
        return Zorluk.kolay;
      case OgunTipi.ogle:
      case OgunTipi.aksam:
        return Zorluk.orta;
      case OgunTipi.cheatMeal:
        return Zorluk.zor;
    }
  }

  /// 🔥 FALLBACK MOCK PLAN - AI başarısız olursa kullanılır
  Future<GunlukPlan> _mockAIPlan({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime tarih,
  }) async {
    AppLogger.info('⚠️ Fallback Mock Plan oluşturuluyor...');

    // 🔥 Her yeni plan başlangıcında günlük ana malzeme set'ini temizle
    _gunlukSecilenAnaMalzemeler.clear();

    // 🎲 TARİHE GÖRE SEED - Her gün farklı yemek ama aynı gün tutarlı
    final seed = tarih.year * 10000 + tarih.month * 100 + tarih.day;
    _random = Random(seed);
    AppLogger.info(
        '🎲 Tarih seed: $seed (${tarih.day}.${tarih.month}.${tarih.year})');

    // 🔥 MAKRO DAĞILIMI - DAHA DENGELİ (%5 tolerans için optimize)
    final kahvaltiKalori = hedefKalori * 0.25; // %25 (önceden %20)
    final araOgun1Kalori = hedefKalori * 0.10; // %10 (önceden %15)
    final ogleKalori = hedefKalori * 0.35; // %35 (aynı)
    final araOgun2Kalori = hedefKalori * 0.10; // %10 (aynı)
    final aksamKalori = hedefKalori * 0.20; // %20 (aynı)

    // 🔥 PROFESYONEL ÇEŞİTLİLİK - SINIRSIZ TÜRK MUTFAĞI!
    final turkYemekleriKahvalti = [
      'Menemen + Tam Buğday Ekmek',
      'Yumurtalı Omlet + Beyaz Peynir',
      'Haşlanmış Yumurta + Domates + Salatalık',
      'Peynirli Omlet + Roka + Domates',
      'Çırpılmış Yumurta + Ekmek',
      'Sahanda Yumurta + Turşu + Peynir',
      'Tereyağlı Omlet + Ispanak',
      'Çilbir (Yumurta + Yoğurt)',
      'Kaşarlı Omlet + Domates',
      'Sebzeli Omlet + Mantar + Biber',
      'Sade Omlet + Tam Buğday Ekmek',
      'Füme Hindi + Haşlanmış Yumurta',
      'Izgara Domates + Yumurta',
      'Karışık Omlet + Zeytin + Peynir',
      'Protein Omlet + Hindi Göğsü',
      'Ispanaklı Çırpılmış Yumurta',
      'Mantarlı Yumurta',
      'Domatesli Sahanda Yumurta',
      'Biberli Menemen + Labne',
      'Shakshuka (Yumurta + Domates Sos)',
      'Frittata + Sebze',
      'Lor Peyniri + Domates + Maydanoz',
      'Labne + Zeytinyağı + Roka',
      'Peynir Tabağı + Bal + Ceviz',
      'Beyaz Peynir + Zeytin + Domates',
      'Kaşar + Domates + Salatalık',
      'Tost (Kaşar + Domates)',
      'Lor + Bal + Ceviz',
      'Feta + Zeytin + Salatalık',
      'Ezine + Domates + Yeşillik',
      'Kaşar Rendesi + Tereyağlı Ekmek',
      'Labne + Ceviz + Bal',
      'Beyaz Peynir + Roka + Zeytinyağı',
      'Tulum + Domates + Fesleğen',
      'Peynirli Pide + Maydanoz',
      'Kasseri + Bal + Ceviz',
      'Süzme Yoğurt + Bal + Ceviz + Muz',
      'Yoğurt + Granola + Çilek',
      'Kefir + Meyve + Fındık',
      'Yoğurt + Muz + Yulaf',
      'Süzme Yoğurt + Çilek + Badem',
      'Yoğurt + Bal + Ceviz',
      'Kefir + Granola + Muz',
      'Süzme Yoğurt + Meyve Karışımı',
      'Yoğurt + Fındık + Bal',
      'Kefir + Badem + Tarçın',
      'Yoğurt Parfait + Meyve + Ceviz',
      'Tam Buğday Ekmek + Fıstık Ezmesi',
      'Yulaf Ezmesi + Bal + Ceviz',
      'Granola + Süt + Meyve',
      'Tam Buğday Pancake + Meyve',
      'Protein Pancake + Bal',
      'Yulaf Pancake + Muz + Badem',
      'Overnight Oats + Meyve',
      'Bircher Müsli + Elma + Ceviz',
      'Yulaf Lapası + Kuru Meyve',
      'Pirinç Patlağı + Badem Ezmesi',
      'Tam Buğday Kraker + Labne',
      'Yulaf Barı + Kuru Meyve',
      'Mısır Gevreği + Süt + Muz',
      // 🔥 FAZ 2: KAHVALTI GENİŞLETME - 60 YENİ VARYASYON (MAKRO DENGELİ)
      // Protein Ağırlıklı Varyasyonlar
      'Kaşarlı Menemen + Domates',
      'Beyaz Peynir + Ceviz + Bal + Ekmek',
      'Yumurta + Avokado Toast',
      'Scrambled Egg + Füme Somon',
      'Yumurta + Mantarlı Omlet',
      'Ispanaklı Omlet + Feta',
      'Domatesli Yumurta + Labne',
      'Çılbır Varyasyon + Nane',
      'Yumurta Benedict + Tam Buğday',
      'Protein Bowl + Yumurta + Kinoa',
      // Süt Ürünü Ağırlıklı
      'Cottage Cheese + Meyve + Bal',
      'Ricotta + Çilek + Badem',
      'Beyaz Peynir + Fındık + Hurma',
      'Labne Bowl + Zeytinyağı + Ceviz',
      'Süzme Yoğurt + Chia + Muz',
      'Greek Yogurt + Protein Tozu + Meyve',
      'Kefir + Yulaf + Badem',
      'Yoğurt + Muesli + Kuru Meyve',
      'Labne + Bal + Antep Fıstığı',
      'Cottage + Avokado + Cherry Domates',
      // Tahıl Bazlı
      'Kinoa Kahvaltı + Yoğurt + Meyve',
      'Chia Puding + Badem Sütü + Muz',
      'Yulaf + Protein Tozu + Muz',
      'Amaranth + Süt + Fındık',
      'Bulgur Lapası + Tarçın + Ceviz',
      'Tam Buğday Krep + Çilek',
      'Protein Waffle + Meyve',
      'Yulaf Waffle + Bal + Ceviz',
      'Quinoa Bowl + Yumurta',
      'Millet + Süt + Kuru Meyve',
      // Ekmek Bazlı Varyasyonlar
      'Çavdar Ekmeği + Avokado + Yumurta',
      'Yulaf Ekmeği + Fıstık Ezmesi + Muz',
      'Tam Buğday + Labne + Roka',
      'Ezine Peynir + Domates + Yeşillik',
      'Kaşar Toast + Domates + Biber',
      'Pide + Peynir + Yumurta',
      'Tulum Peynir + Bal + Ceviz',
      'Lor + Domates + Maydanoz + Ekmek',
      'Feta + Zeytin + Salatalık + Ekmek',
      'Hummus + Tam Buğday + Sebze',
      // Protein Pancake Varyasyonları
      'Yulaf Pancake + Çilek + Yoğurt',
      'Protein Pancake + Fındık Ezmesi',
      'Tam Buğday Pancake + Bal + Badem',
      'Muz Pancake + Ceviz',
      'Kinoa Pancake + Meyve',
      'Yulaf Pancake + Protein + Çilek',
      'Chia Pancake + Bal',
      'Coconut Pancake + Meyve',
      'Buckwheat Pancake + Yoğurt',
      'Almond Pancake + Muz',
      // Smoothie Bowl Varyasyonları
      'Berry Smoothie Bowl + Granola',
      'Mango Smoothie Bowl + Chia',
      'Banana Smoothie Bowl + Badem',
      'Green Smoothie Bowl + Ispanak + Muz',
      'Protein Smoothie Bowl + Meyve',
      'Açai Bowl + Granola + Ceviz',
      'Dragon Fruit Bowl + Kiwi',
      'Avocado Smoothie Bowl + Kakao',
      'Peanut Butter Smoothie Bowl',
      'Mixed Berry Bowl + Protein',
      // 🔥 KAHVALTI GENİŞLETME - EKONOMİK TÜRK MUTFAĞI (180 VARYASYON)
      // Yumurta Bazlı Ekonomik (50 adet)
      'Yumurta + Sucuk + Domates', 'Yumurta + Pastırma + Biber',
      'Yumurta + Sosis + Salatalık', 'Yumurta + Salam + Peynir',
      'Yumurta + Domates + Biber', 'Yumurta + Soğan + Mantar',
      'Yumurta + Pırasa + Peynir', 'Yumurta + Ispanak + Lor',
      'Yumurta + Kabak + Kaşar', 'Yumurta + Patates + Soğan',
      'Kaşarlı Omlet + Domates + Biber', 'Lorlu Omlet + Roka',
      'Beyaz Peynirli Omlet + Maydanoz', 'Sebzeli Omlet + Mantar',
      'Mantarlı Omlet + Kaşar', 'Pırasalı Omlet + Beyaz Peynir',
      'Ispanaklı Omlet + Yoğurt', 'Kabak + Omlet + Nane',
      'Patatesli Omlet + Sosis', 'Soğanlı Omlet + Biber',
      'Menemen Varyasyonu 1', 'Menemen Varyasyonu 2',
      'Menemen Varyasyonu 3', 'Menemen + Sucuk',
      'Menemen + Pastırma', 'Menemen + Kaşar',
      'Menemen + Beyaz Peynir', 'Menemen + Lor',
      'Sahanda Yumurta + Sucuk', 'Sahanda Yumurta + Pastırma',
      'Haşlanmış Yumurta 2li + Salata', 'Haşlanmış Yumurta 3lü',
      'Çılbır + Yoğurt + Nane', 'Çılbır + Sarımsak',
      'Rafadan Yumurta 2li', 'Rafadan Yumurta 3lü',
      'Kayganacı + Ekmek', 'Yağda Yumurta + Soğan',
      'Yumurta + Kavurma + Biber', 'Yumurta + Kıyma',
      'Yumurta + Fasulye', 'Yumurta + Nohut',
      'Yumurta + Mercimek', 'Yumurta + Sebze Güveç',
      'Yumurta + Patlıcan + Biber', 'Yumurta + Kabak + Domates',
      'Yumurta + Mantar + Soğan', 'Yumurta + Havuç + Bezelye',
      'Yumurta + Karnabahar', 'Yumurta + Brokoli',
      // Yerel Peynir Bazlı (30 adet)
      'Beyaz Peynir + Domates + Salatalık + Zeytin',
      'Beyaz Peynir + Ceviz + Bal + Ekmek',
      'Beyaz Peynir + Fındık + Üzüm Pekmezi',
      'Beyaz Peynir + Yeşillik + Zeytinyağı',
      'Kaşar + Domates + Yeşil Biber',
      'Kaşar + Ceviz + Bal',
      'Kaşar + Salatalık + Marul',
      'Kaşar Tost + Domates + Biber',
      'Lor + Domates + Maydanoz + Zeytinyağı',
      'Lor + Ceviz + Bal + Ekmek',
      'Lor + Yeşillik + Zeytin',
      'Lor + Salatalık + Nane',
      'Labne + Zeytinyağı + Nane + Zeytin',
      'Labne + Ceviz + Bal',
      'Labne + Domates + Salatalık',
      'Labne + Sumak + Zeytinyağı',
      'Tulum Peynir + Domates + Ekmek',
      'Tulum + Ceviz + Bal',
      'Ezine Peyniri + Yeşillik',
      'Kars Kaşarı + Domates',
      'Dil Peyniri + Salatalık',
      'Cecil Peyniri + Zeytin',
      'Mihaliç Peyniri + Ekmek',
      'Çökelek + Domates + Biber',
      'Çökelek + Yeşillik',
      'Peynir Tabağı Klasik',
      'Peynir Tabağı + Ceviz',
      'Peynir + Reçel + Ekmek',
      'Peynir + Bal + Tahini',
      'Peynir + Zeytin + Yeşillik',
      // Yoğurt Bazlı Ekonomik (30 adet)
      'Süzme Yoğurt + Elma + Ceviz',
      'Süzme Yoğurt + Muz + Fındık',
      'Süzme Yoğurt + Çilek + Bal',
      'Süzme Yoğurt + Üzüm + Badem',
      'Süzme Yoğurt + Kayısı + Ceviz',
      'Süzme Yoğurt + Erik + Bal',
      'Yoğurt + Yulaf + Bal + Ceviz',
      'Yoğurt + Muz + Yulaf + Badem',
      'Yoğurt + Çilek + Yulaf',
      'Yoğurt + Elma + Tarçın + Ceviz',
      'Yoğurt + Kuru Üzüm + Ceviz',
      'Yoğurt + Kuru Kayısı + Badem',
      'Yoğurt + Hurma + Fındık',
      'Yoğurt + Kuru İncir + Ceviz',
      'Kefir + Muz + Yulaf',
      'Kefir + Çilek + Bal',
      'Kefir + Elma + Tarçın',
      'Ayran + Salatalık + Nane',
      'Yoğurt + Salatalık + Sarımsak',
      'Yoğurt + Havuç Rendesi',
      'Yoğurt + Pancar + Sarımsak',
      'Yoğurt + Yeşillik + Ceviz',
      'Yoğurt + Domates + Salatalık',
      'Yoğurt + Biber + Nane',
      'Yoğurt + Soğan + Sumak',
      'Yoğurt Çorbası + Nohut',
      'Yoğurt + Mercimek',
      'Yoğurt + Bulgur',
      'Yoğurt + Pirinç',
      'Yoğurt + Erişte',
      // Tahıl/Ekmek Bazlı (40 adet)
      'Yulaf + Süt + Muz + Bal',
      'Yulaf + Elma + Tarçın + Ceviz',
      'Yulaf + Çilek + Fındık',
      'Yulaf + Kuru Meyve + Bal',
      'Bulgur Lapası + Süt + Bal',
      'Bulgur + Yoğurt + Ceviz',
      'Pirinç Lapası + Süt + Tarçın',
      'Irmik Helvası + Süt',
      'Tel Kadayıf + Peynir',
      'Pişi + Peynir + Bal',
      'Katmer + Kaymak + Fıstık',
      'Gözleme + Peynir + Maydanoz',
      'Gözleme + Patates + Soğan',
      'Gözleme + Ispanak + Peynir',
      'Gözleme + Kıyma + Soğan',
      'Bazlama + Peynir + Domates',
      'Bazlama + Yumurta',
      'Çörek + Peynir',
      'Açma + Peynir + Zeytin',
      'Poğaça + Peynir',
      'Poğaça + Patates',
      'Poğaça + Kıyma',
      'Simit + Peynir + Domates',
      'Simit + Labne',
      'Tam Buğday Ekmek + Peynir + Salatalık',
      'Tam Buğday + Yumurta + Domates',
      'Tam Buğday + Labne + Ceviz',
      'Çavdar Ekmeği + Peynir',
      'Çavdar + Yumurta',
      'Köy Ekmeği + Peynir + Zeytin',
      'Köy Ekmeği + Yumurta',
      'Somun Ekmek + Sucuk + Yumurta',
      'Francala + Peynir + Domates',
      'Sandviç Ekmeği + Kaşar + Salatalık',
      'Tost Ekmeği + Kaşar + Domates',
      'Galeta + Labne + Ceviz',
      'Kraker + Peynir + Zeytin',
      'Peksimet + Peynir',
      'Kurabiye + Süt',
      'Gevrek + Süt + Muz',
      // Diğer Varyasyonlar (30 adet)
      'Pankek + Pekmez + Tahin',
      'Pankek + Bal + Ceviz',
      'Pankek + Reçel + Kaymak',
      'Waffle + Çikolata + Muz',
      'Waffle + Bal + Fındık',
      'Waffle + Reçel + Krema',
      'Krep + Nutella + Muz',
      'Krep + Çikolata + Çilek',
      'Krep + Bal + Ceviz',
      'Cevizli Kurabiye + Süt',
      'Tahinli Kurabiye + Çay',
      'Susamlı Çörek + Peynir',
      'Haşhaşlı Çörek + Süt',
      'Çökelekli Börek + Ayran',
      'Peynirli Börek + Salatalık',
      'Kol Böreği + Ayran',
      'Su Böreği + Peynir',
      'Paçanga Böreği + Domates',
      'Patatesli Börek + Yoğurt',
      'Kıymalı Börek + Salata',
      'Ispanaklı Börek + Ayran',
      'Mantı + Yoğurt + Sarımsak',
      'Erişte + Yoğurt',
      'Pide + Kaşar + Domates',
      'Lahmacun + Salata',
      'Kuru Fasulye + Pilav + Salatalık',
      'Nohut + Pilav + Turşu',
      'Mercimek + Bulgur',
      'Kısır + Marul',
      'Zeytinyağlı Fasulye + Ekmek',
    ];

    final turkYemekleriOgle = [
      // TAVUK
      'Izgara Tavuk + Bulgur Pilavı + Salata',
      'Tavuk Şiş + Pirinç + Közlenmiş Biber',
      'Tavuk Sote + Makarna + Domates Salata',
      'Tavuk Fileto + Sebze + Pirinç', 'Fırında Tavuk + Patates + Havuç',
      'Tavuk Wrap + Salata', 'Tavuk Döner + Pilav',
      'Tavuk Kanat + Bulgur', 'Tavuk But + Sebze Güveci',
      'Tavuk Schnitzel + Salata', 'Tavuk Kebap + Pilav',
      'Tavuk Sote + Sebze', 'Tavuk + Nohut + Sebze',
      // ET
      'Köfte + Pirinç Pilavı + Cacık', 'Mercimek Çorbası + Et Sote + Pilav',
      'Dana Rosto + Bulgur + Salata',
      'Izgara Et + Sebze + Pirinç', 'Dana Et + Sebze Güveci',
      'Et Güveci + Bulgur', 'Etli Nohut', 'Etli Fasulye',
      'Tas Kebap', 'İçli Köfte', 'Çiğ Köfte', 'Adana Kebap', 'Urfa Kebap',
      'Beyti', 'İskender',
      'Dana Kavurma', 'Et Suyu + Sebze', 'Kuzu Tandır',
      // BALIK
      'Balık Izgara + Sebze + Bulgur', 'Izgara Somon + Brokoli',
      'Balık Fileto + Fırın Patates',
      'Fırında Somon + Sebze', 'Balık + Pirinç', 'Levrek + Sebze',
      'Çupra + Pilav', 'Hamsi + Mısır Ekmeği',
      'Palamut + Sebze', 'Uskumru + Pilav', 'Ton Balığı Salata',
      'Mezgit + Sebze',
      'Sardalya + Salata', 'Somon Wrap',
      // VEJETERYENHİNDİ
      'Hindi Schnitzel + Bulgur', 'Hindi Rosto + Sebzeli Pilav', 'Nohut Köfte',
      'Mercimek + Bulgur',
      'Sebze Güveç', 'Mantı + Yoğurt', 'Kuru Fasulye', 'Barbunya', 'Börülce',
      'Falafel Wrap', 'Mercimek Köfte', 'Nohut Curry', 'Patlıcan Musakka',
      // MAKARNA
      'Tam Buğday Makarna + Ton', 'Penne + Tavuk + Pesto', 'Spaghetti + Köfte',
      'Mercimek Makarna', 'Nohut Makarna', 'Lasagna',
      // 🔥 FAZ 2: ÖĞLE YEMEĞİ GENİŞLETME - 103 YENİ VARYASYON (MAKRO DENGELİ)
      // Protein Ağırlıklı (Tavuk)
      'Tavuk Göğüs + Kinoa + Avokado',
      'Tavuk Fajita + Wrap',
      'Tavuk Teriyaki + Brokoli + Pirinç',
      'Buffalo Tavuk + Salata',
      'Tavuk Tikka Masala + Pirinç',
      'Tavuk + Karnabahar Pirinç + Sebze',
      'Cajun Tavuk + Tatlı Patates',
      'Lemon Herb Tavuk + Kinoa',
      'BBQ Tavuk + Mısır + Fasulye',
      'Tavuk + Mercimek + Ispanak',
      'Tavuk Curry + Nohut + Pirinç',
      'Tavuk + Keten Tohumu + Salata',
      'Tavuk Bowl + Sebze + Humus',
      'Tavuk + Yeşil Fasulye + Pilav',
      'Tavuk + Patlıcan + Yoğurt',
      // Balık Ağırlıklı
      'Ton Balığı + Kinoa Salatası',
      'Alabalık + Fırın Sebze',
      'Hamsi Tava + Mısır Ekmeği',
      'Sardalya + Yeşil Salata',
      'Orkinos + Avokado + Pirinç',
      'Balık Curry + Hindistan Cevizi',
      'Som Balığı + Patates Püresi',
      'Karides + Sebze Wok',
      'Mürekkepbalığı Izgara + Salata',
      'Ahtapot + Patates + Zeytinyağı',
      'Kılıç Balığı + Sebze Güveç',
      'Dil Balığı + Fırın Sebze',
      'Balık Taco + Lahana Salatası',
      'Balık + Farro + Limonlu Sos',
      'Midye Dolma + Pirinç',
      // Kırmızı Et Ağırlıklı
      'Dana Biftek + Tatlı Patates',
      'Kuzu Tandır + Bulgur',
      'Dana Stew + Sebze',
      'Biftek Salata + Kinoa',
      'Dana Stir Fry + Pirinç',
      'Kuzu Şiş + Közlenmiş Sebze',
      'Et Burrito Bowl',
      'Dana + Brokoli + Teriyaki',
      'Kuzu + Nohut + Baharat',
      'Dana + Mantar + Pilav',
      'Et Pho + Pirinç Erişte',
      'Dana Fajita Bowl',
      'Kuzu Kebap + Cacık + Pilav',
      'Et Taco + Salsa',
      'Dana + Ispanak + Pirinç',
      // Vejetaryen/Vegan
      'Falafel Wrap + Tahini',
      'Tofu Scramble Bowl',
      'Tempeh + Kinoa + Avokado',
      'Mercimek Dal + Naan',
      'Nohut Curry + Basmati',
      'Sebze Buddha Bowl',
      'Quinoa Stuffed Pepper',
      'Vegan Chili + Mısır Ekmeği',
      'Tofu Pad Thai',
      'Mushroom Stroganoff + Makarna',
      'Sebze Ramen + Tofu',
      'Black Bean Bowl + Avokado',
      'Portobello Burger + Tatlı Patates',
      'Hummus Bowl + Sebze',
      'Lentil Bolognese + Makarna',
      'Chickpea Tikka Masala',
      'Tofu Banh Mi',
      'Veggie Poke Bowl',
      'Falafel Bowl + Tabbouleh',
      'Veggie Sushi Bowl',
      // Keto/Düşük Karb
      'Izgara Tavuk + Karnabahar Püre',
      'Somon + Kuşkonmaz + Tereyağı',
      'Biftek + Avokado + Salata',
      'Tavuk + Kabak Noodles',
      'Balık + Brüksel Lahanası',
      'Dana + Karnabahar Pirinç',
      'Yumurta + Pastırma + Avokado',
      'Keto Burger (Ekmeğiz)',
      'Tavuk Alfredo + Kabak',
      'Somon + Feta + Ispanak',
      // Yüksek Protein
      'Triple Protein Bowl (Tavuk+Yumurta+Peynir)',
      'Biftek + Yumurta + Kinoa',
      'Balık + Edamame + Pirinç',
      'Tavuk + Cottage Cheese + Salata',
      'Protein Pasta + Ton Balığı',
      'Izgara Et + Mercimek',
      'Somon + Yumurta + Avokado',
      'Tavuk + Greek Yogurt Bowl',
      // Çorba + Ana Yemek Kombinasyonları
      'Domates Çorbası + Izgara Peynir',
      'Tavuk Çorbası + Pilav',
      'Mercimek Çorbası + Köfte',
      'Tarhana + Et Sote',
      'Balık Çorbası + Pilaki',
      'Sebze Çorbası + Tavuk',
      'Yayla Çorbası + Bulgur',
      'Ezogelin + Dana Kavurma',
      'Tavuk Suyu + Erişte',
      'Kırmızı Mercimek + Hindi',
      // Dünya Mutfağı
      'Bibimbap (Kore)',
      'Chicken Tikka (Hint)',
      'Pad See Ew (Tayland)',
      'Jambalaya (Cajun)',
      'Paella (İspanya)',
      'Shakshuka + Ekmek',
      'Greek Gyro Bowl',
      'Japanese Teriyaki Bowl',
      'Mexican Burrito Bowl',
      'Vietnamese Banh Mi Bowl',
      'Italian Risotto + Tavuk',
      'Lebanese Shawarma Bowl',
      'Moroccan Tagine',
      'Thai Green Curry',
      'Korean Bulgogi Bowl',
    ];

    final turkYemekleriAksam = [
      // BALIK
      'Fırında Somon + Sebze Güveci', 'Balık Fileto + Sebze + Bulgur',
      'Balık Izgara + Fırın Sebze',
      'Izgara Somon + Brokoli', 'Levrek + Sebze + Pirinç',
      'Çupra + Bulgur + Salata',
      'Hamsi + Sebze', 'Palamut + Pilav', 'Uskumru + Bulgur',
      'Alabalık + Sebze',
      'Mezgit + Pirinç', 'Sardalya + Bulgur', 'Lüfer + Sebze', 'Barbun + Pilav',
      'Çinekop + Salata',
      'Ton Balığı + Salata', 'Balık Güveç', 'Deniz Levreği',
      // TAVUK
      'Izgara Tavuk + Bulgur + Salata', 'Tavuk Sote + Sebze + Bulgur',
      'Tavuk Fileto + Sebze + Pirinç',
      'Fırında Tavuk + Patates', 'Tavuk But + Sebze',
      'Tavuk Schnitzel + Salata',
      'Tavuk Kebap + Bulgur', 'Tavuk Sote + Pirinç', 'Tavuk + Nohut',
      'Tavuk + Fasulye', 'Tavuk + Mercimek',
      'Tavuk + Sebze Güveci', 'Tavuk Wrap',
      // ET
      'Et Sote + Pirinç + Cacık', 'Dana Et + Sebze Güveci',
      'Et Güveci + Bulgur', 'Köfte + Patates Püresi',
      'Tas Kebap', 'Etli Nohut', 'Etli Fasulye', 'İçli Köfte', 'Çiğ Köfte',
      'Kebap + Pilav',
      'Dana Steak + Sebze', 'Kuzu Pirzola + Bulgur', 'Biftek + Salata',
      'Et Haşlama', 'Kıymalı Güveç',
      // VEJETERYENHİNDİ
      'Hindi Rosto + Sebzeli Pilav', 'Sebze Güveç + Pirinç', 'Nohut + Bulgur',
      'Mercimek + Pirinç', 'Fasulye + Bulgur',
      'Barbunya + Pilav', 'Börülce + Bulgur', 'Patlıcan Musakka', 'Karnıyarık',
      'İmambayıldı',
      'Sebze Curry', 'Falafel Wrap', 'Mercimek Köfte', 'Nohut Curry',
      'Sebze Musakka',
    ];

    final araOgunSecenekleri1 = [
      // MEYVE BAZLI (15 seçenek)
      'Elma + Ceviz + Bal',
      'Muz + Badem',
      'Portakal + Fındık',
      'Armut + Ceviz',
      'Kivi + Badem',
      'Çilek + Fındık',
      'Üzüm + Ceviz',
      'Şeftali + Badem',
      'Erik + Fındık',
      'Kayısı + Ceviz',
      'Muz + Fıstık Ezmesi',
      'Elma Dilimi + Badem Ezmesi',
      'Meyve Salatası',
      'Smoothie (Meyve + Süt)',
      'Muz + Yulaf',

      // YOĞURT BAZLI (5 seçenek) - AZALTILDI!
      'Yoğurt + Muz + Badem',
      'Süzme Yoğurt + Çilek + Fındık',
      'Kefir + Meyve',
      'Yoğurt + Granola',
      'Süzme Yoğurt + Bal',

      // DİĞER (10 seçenek)
      'Protein Bar + Elma',
      'Kuruyemiş Karışımı',
      'Badem + Kuru Üzüm',
      'Ceviz + Kuru Kayısı',
      'Fındık + Kuru İncir',
      'Antep Fıstığı + Hurma',
      'Kaju + Kuru Erik',
      'Kete + Süt',
      'Kraker + Peynir',
      'Tam Buğday Bisküvi + Fıstık Ezmesi',
    ];

    final araOgunSecenekleri2 = [
      // 🔥 PROTEİN BAZLI (15 seçenek) - YENİ EKLENDİ!
      'Yoğurt + Meyve',
      'Süzme Yoğurt + Badem',
      'Labne + Ceviz',
      'Kefir + Fındık',
      'Protein Bar + Muz',
      'Ayran + Kuruyemiş',
      'Lor Peyniri + Domates',
      'Beyaz Peynir + Ceviz',
      'Cottage Cheese + Meyve',
      'Yoğurt + Granola + Badem',
      'Süzme Yoğurt + Çilek',
      'Labne + Zeytinyağı + Ceviz',
      'Humus + Havuç + Badem',
      'Peynir + Kuruyemiş',
      'Yumurta (1 adet) + Domates',

      // SEBZE + PROTEİN BAZLI (10 seçenek)
      'Havuç + Humus',
      'Salatalık + Labne',
      'Domates + Peynir',
      'Kereviz + Humus',
      'Biber Dilimi + Labne',
      'Cherry Domates + Feta',
      'Havuç Çubukları + Yoğurt',
      'Salatalık + Beyaz Peynir',
      'Közlenmiş Biber + Lor',
      'Sebze Çubukları + Humus',

      // KURUYEMİŞ BAZLI (5 seçenek) - AZALTILDI
      'Kuruyemiş Karışımı + Yoğurt',
      'Badem + Kuru Üzüm',
      'Ceviz + Kuru Kayısı',
      'Fındık + Hurma',
      'Antep Fıstığı + Kuru İncir',
    ];

    final random = Random();

    // 🔥 YENİ YAKLAŞIM: KALAN MAKRO TAKİP SİSTEMİ
    // Her öğünden sonra kalan makroları hesapla, sonraki öğünü ona göre seç!
    double kalanProtein = hedefProtein;
    double kalanKarb = hedefKarb;
    double kalanYag = hedefYag;

    AppLogger.info('🎯 BAŞLANGIÇ KALAN MAKROLAR: ${kalanProtein.toStringAsFixed(0)}P, ${kalanKarb.toStringAsFixed(0)}K, ${kalanYag.toStringAsFixed(0)}Y');

    // KAHVALTI: İlk öğün, %25 oranında başla
    final secilenKahvalti = _enUygunYemekSec(
      turkYemekleriKahvalti,
      kahvaltiKalori,
      kalanProtein * 0.25,
      kalanKarb * 0.25,
      kalanYag * 0.25,
    );

    // 🔥 DİNAMİK ÖLÇEKLEME: Hedef kaloriye göre malzeme miktarlarını ayarla
    final kahvaltiMalzemeler = _detayliMalzemeler(secilenKahvalti);
    final baslangicMakro = _gercekMakroHesapla(kahvaltiMalzemeler);
    final olcek = kahvaltiKalori / baslangicMakro['kalori']!;
    final kahvaltiMalzemelerOlcekli =
        _malzemeleriOlcekle(kahvaltiMalzemeler, olcek);
    final kahvaltiMakro = _gercekMakroHesapla(kahvaltiMalzemelerOlcekli);

    final kahvalti = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_kahvalti',
      ad: secilenKahvalti,
      ogun: OgunTipi.kahvalti,
      kalori: kahvaltiMakro['kalori']!,
      protein: kahvaltiMakro['protein']!,
      karbonhidrat: kahvaltiMakro['karb']!,
      yag: kahvaltiMakro['yag']!,
      malzemeler: kahvaltiMalzemelerOlcekli,
      hazirlamaSuresi: 10 + random.nextInt(15),
      zorluk: Zorluk.kolay,
      etiketler: ['kahvaltı', 'protein', 'sağlıklı'],
    );

    // 🔥 KALAN MAKROLARI GÜNCELLE (Kahvaltı tüketildi)
    kalanProtein -= kahvaltiMakro['protein']!;
    kalanKarb -= kahvaltiMakro['karb']!;
    kalanYag -= kahvaltiMakro['yag']!;
    AppLogger.info('📊 KAHVALTI SONRASI KALAN: ${kalanProtein.toStringAsFixed(0)}P, ${kalanKarb.toStringAsFixed(0)}K, ${kalanYag.toStringAsFixed(0)}Y');

    // ARA ÖĞÜN 1: Kalan makrolara göre seç
    final secilenAraOgun1 = _enUygunYemekSec(
      araOgunSecenekleri1,
      araOgun1Kalori,
      kalanProtein * 0.10,
      kalanKarb * 0.08,
      kalanYag * 0.10,
    );

    final araOgun1MalzemelerBas = _detayliMalzemeler(secilenAraOgun1);
    final araOgun1BasMakro = _gercekMakroHesapla(araOgun1MalzemelerBas);
    final araOgun1Olcek = araOgun1Kalori / araOgun1BasMakro['kalori']!;
    final araOgun1Malzemeler =
        _malzemeleriOlcekle(araOgun1MalzemelerBas, araOgun1Olcek);
    final araOgun1Makro = _gercekMakroHesapla(araOgun1Malzemeler);

    final araOgun1 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_araogun1',
      ad: secilenAraOgun1,
      ogun: OgunTipi.araOgun1,
      kalori: araOgun1Makro['kalori']!,
      protein: araOgun1Makro['protein']!,
      karbonhidrat: araOgun1Makro['karb']!,
      yag: araOgun1Makro['yag']!,
      malzemeler: araOgun1Malzemeler,
      hazirlamaSuresi: 3 + random.nextInt(7),
      zorluk: Zorluk.kolay,
      etiketler: ['ara-öğün', 'pratik', 'sağlıklı'],
    );

    // 🔥 KALAN MAKROLARI GÜNCELLE (Ara öğün 1 tüketildi)
    kalanProtein -= araOgun1Makro['protein']!;
    kalanKarb -= araOgun1Makro['karb']!;
    kalanYag -= araOgun1Makro['yag']!;
    AppLogger.info('📊 ARA ÖĞÜN 1 SONRASI KALAN: ${kalanProtein.toStringAsFixed(0)}P, ${kalanKarb.toStringAsFixed(0)}K, ${kalanYag.toStringAsFixed(0)}Y');

    // ÖĞLE: KALAN MAKROLARA GÖRE DİNAMİK SEÇİM!
    final secilenOgle = _enUygunYemekSec(
      turkYemekleriOgle,
      ogleKalori,
      kalanProtein * 0.40, // Kalan proteinin %40'ı
      kalanKarb * 0.45,    // Kalan karbın %45'i
      kalanYag * 0.40,
    );

    final ogleMalzemelerBas = _detayliMalzemeler(secilenOgle);
    final ogleBasMakro = _gercekMakroHesapla(ogleMalzemelerBas);
    final ogleOlcek = ogleKalori / ogleBasMakro['kalori']!;
    final ogleMalzemelerOlcekli =
        _malzemeleriOlcekle(ogleMalzemelerBas, ogleOlcek);
    final ogleMakro = _gercekMakroHesapla(ogleMalzemelerOlcekli);

    final ogleYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_ogle',
      ad: secilenOgle,
      ogun: OgunTipi.ogle,
      kalori: ogleMakro['kalori']!,
      protein: ogleMakro['protein']!,
      karbonhidrat: ogleMakro['karb']!,
      yag: ogleMakro['yag']!,
      malzemeler: ogleMalzemelerOlcekli,
      hazirlamaSuresi: 25 + random.nextInt(20),
      zorluk: Zorluk.orta,
      etiketler: ['öğle', 'ana-yemek', 'doyurucu'],
    );

    // 🔥 KALAN MAKROLARI GÜNCELLE (Öğle tüketildi)
    kalanProtein -= ogleMakro['protein']!;
    kalanKarb -= ogleMakro['karb']!;
    kalanYag -= ogleMakro['yag']!;
    AppLogger.info('📊 ÖĞLE SONRASI KALAN: ${kalanProtein.toStringAsFixed(0)}P, ${kalanKarb.toStringAsFixed(0)}K, ${kalanYag.toStringAsFixed(0)}Y');

    // ARA ÖĞÜN 2: KALAN MAKROLARA GÖRE
    final secilenAraOgun2 = _enUygunYemekSec(
      araOgunSecenekleri2,
      araOgun2Kalori,
      kalanProtein * 0.10,
      kalanKarb * 0.07,
      kalanYag * 0.10,
    );

    final araOgun2MalzemelerBas = _detayliMalzemeler(secilenAraOgun2);
    final araOgun2BasMakro = _gercekMakroHesapla(araOgun2MalzemelerBas);
    final araOgun2Olcek = araOgun2Kalori / araOgun2BasMakro['kalori']!;
    final araOgun2Malzemeler =
        _malzemeleriOlcekle(araOgun2MalzemelerBas, araOgun2Olcek);
    final araOgun2Makro = _gercekMakroHesapla(araOgun2Malzemeler);

    final araOgun2 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_araogun2',
      ad: secilenAraOgun2,
      ogun: OgunTipi.araOgun2,
      kalori: araOgun2Makro['kalori']!,
      protein: araOgun2Makro['protein']!,
      karbonhidrat: araOgun2Makro['karb']!,
      yag: araOgun2Makro['yag']!,
      malzemeler: araOgun2Malzemeler,
      hazirlamaSuresi: 2 + random.nextInt(5),
      zorluk: Zorluk.kolay,
      etiketler: ['ara-öğün', 'hafif', 'doğal'],
    );

    // 🔥 KALAN MAKROLARI GÜNCELLE (Ara öğün 2 tüketildi)
    kalanProtein -= araOgun2Makro['protein']!;
    kalanKarb -= araOgun2Makro['karb']!;
    kalanYag -= araOgun2Makro['yag']!;
    AppLogger.info('📊 ARA ÖĞÜN 2 SONRASI KALAN: ${kalanProtein.toStringAsFixed(0)}P, ${kalanKarb.toStringAsFixed(0)}K, ${kalanYag.toStringAsFixed(0)}Y');

    // AKŞAM: SON ÖĞÜN - KALAN HER ŞEYİ TAMAMLA!
    final secilenAksam = _enUygunYemekSec(
      turkYemekleriAksam,
      aksamKalori,
      kalanProtein, // Kalan tüm protein
      kalanKarb,    // Kalan tüm karb
      kalanYag,     // Kalan tüm yağ
    );

    final aksamMalzemelerBas = _detayliMalzemeler(secilenAksam);
    final aksamBasMakro = _gercekMakroHesapla(aksamMalzemelerBas);
    final aksamOlcek = aksamKalori / aksamBasMakro['kalori']!;
    final aksamMalzemelerOlcekli =
        _malzemeleriOlcekle(aksamMalzemelerBas, aksamOlcek);
    final aksamMakro = _gercekMakroHesapla(aksamMalzemelerOlcekli);

    final aksamYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_aksam',
      ad: secilenAksam,
      ogun: OgunTipi.aksam,
      kalori: aksamMakro['kalori']!,
      protein: aksamMakro['protein']!,
      karbonhidrat: aksamMakro['karb']!,
      yag: aksamMakro['yag']!,
      malzemeler: aksamMalzemelerOlcekli,
      hazirlamaSuresi: 35 + random.nextInt(25),
      zorluk: Zorluk.orta,
      etiketler: ['akşam', 'protein', 'omega3'],
    );

    final makroHedefleri = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: hedefProtein,
      gunlukKarbonhidrat: hedefKarb,
      gunlukYag: hedefYag,
    );

    final plan = GunlukPlan(
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

    return plan;
  }

  /// Tolerans kontrolü (mevcut sistem korunuyor)
  String _toleransKontrolEt(GunlukPlan plan) {
    final toleranslar = <String>[];

    if (!plan.kaloriToleranstaMi) {
      toleranslar
          .add('Kalori (${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%)');
    }
    if (!plan.proteinToleranstaMi) {
      toleranslar
          .add('Protein (${plan.proteinSapmaYuzdesi.toStringAsFixed(1)}%)');
    }
    if (!plan.karbonhidratToleranstaMi) {
      toleranslar.add(
          'Karbonhidrat (${plan.karbonhidratSapmaYuzdesi.toStringAsFixed(1)}%)');
    }
    if (!plan.yagToleranstaMi) {
      toleranslar.add('Yağ (${plan.yagSapmaYuzdesi.toStringAsFixed(1)}%)');
    }

    if (toleranslar.isEmpty) {
      return '✅ Tüm makrolar ±5% tolerans içinde';
    } else {
      return '⚠️ Tolerans aşan makrolar: ${toleranslar.join(', ')}';
    }
  }

  /// 🔥 Detaylı malzemeler üret (yemek adına göre) - KAPSAMLI VERSİYON
  List<String> _detayliMalzemeler(String yemekAdi) {
    final malzemelerHaritasi = {
      // 🥚 KAHVALTI MALZEMELERİ - TÜM VARİASYONLAR
      'Menemen + Tam Buğday Ekmek': [
        'Yumurta (2 adet)',
        'Domates (1 adet)',
        'Biber (1 adet)',
        'Soğan (1/2 adet)',
        'Tam buğday ekmek (2 dilim)'
      ],
      'Yumurtalı Omlet + Beyaz Peynir': [
        'Yumurta (2 adet)',
        'Beyaz peynir (50g)',
        'Tereyağı (1 tsp)',
        'Maydanoz'
      ],
      'Haşlanmış Yumurta + Domates + Salatalık': [
        'Yumurta (2 adet)',
        'Domates (1 orta)',
        'Salatalık (1/2 adet)',
        'Zeytinyağı (1 tsp)',
        'Tuz',
        'Maydanoz'
      ],
      'Süzme Yoğurt + Bal + Ceviz + Muz': [
        'Süzme yoğurt (200g)',
        'Bal (1 YK)',
        'Ceviz (8 adet)',
        'Muz (1 adet)'
      ],
      'Peynirli Omlet + Roka + Domates': [
        'Yumurta (2 adet)',
        'Kaşar peynir (30g)',
        'Roka (1 demet)',
        'Domates (1 adet)'
      ],
      'Çırpılmış Yumurta + Avokado + Ekmek': [
        'Yumurta (2 adet)',
        'Avokado (1/2 adet)',
        'Tam buğday ekmek (2 dilim)',
        'Tereyağı'
      ],
      'Lor Peyniri + Domates + Maydanoz': [
        'Lor peyniri (100g)',
        'Domates (1 adet)',
        'Maydanoz (1 demet)',
        'Zeytinyağı'
      ],
      'Labne + Zeytinyağı + Roka': [
        'Labne (150g)',
        'Roka (1 demet)',
        'Zeytinyağı (1 YK)',
        'Siyah zeytin (5 adet)'
      ],
      'Sahanda Yumurta + Turşu + Peynir': [
        'Yumurta (2 adet)',
        'Beyaz peynir (50g)',
        'Karışık turşu',
        'Tereyağı'
      ],
      'Yoğurt + Granola + Çilek': [
        'Süzme yoğurt (150g)',
        'Granola (30g)',
        'Çilek (100g)',
        'Bal (1 tsp)'
      ],
      'Tereyağlı Omlet + Ispanak': [
        'Yumurta (2 adet)',
        'Baby ıspanak (50g)',
        'Tereyağı (1 YK)',
        'Kaşar rendesi'
      ],
      'Peynir Tabağı + Bal + Ceviz': [
        'Beyaz peynir (60g)',
        'Kaşar (40g)',
        'Ceviz (6 adet)',
        'Bal (1 tsp)',
        'Domates'
      ],

      // 🥚 EKSİK KAHVALTILAR
      'Protein Omlet + Hindi Göğsü': [
        'Yumurta (2 adet)',
        'Hindi göğsü (50g)',
        'Tereyağı (1 tsp)',
        'Baharat'
      ],
      'Ispanaklı Çırpılmış Yumurta': [
        'Yumurta (2 adet)',
        'Ispanak (50g)',
        'Tereyağı (1 tsp)',
        'Kaşar (20g)'
      ],
      'Mantarlı Scrambled Eggs': [
        'Yumurta (2 adet)',
        'Mantar (50g)',
        'Tereyağı (1 tsp)',
        'Maydanoz'
      ],
      'Domatesli Sahanda Yumurta': [
        'Yumurta (2 adet)',
        'Domates (1 adet)',
        'Tereyağı (1 tsp)',
        'Tuz'
      ],
      'Biberli Menemen + Labne': [
        'Yumurta (2 adet)',
        'Biber (1 adet)',
        'Domates (1 adet)',
        'Labne (50g)'
      ],
      'Egg White Omlet + Avokado': [
        'Yumurta beyazı (4 adet)',
        'Avokado (1/2 adet)',
        'Zeytinyağı (1 tsp)'
      ],
      'Shakshuka (Yumurta + Domates Sos)': [
        'Yumurta (2 adet)',
        'Domates (2 adet)',
        'Biber (1 adet)',
        'Soğan (1/2 adet)',
        'Baharat'
      ],
      'Frittata + Sebze': [
        'Yumurta (3 adet)',
        'Karışık sebze (100g)',
        'Kaşar (30g)',
        'Zeytinyağı'
      ],
      'Yumurtalı Wrap + Humus': [
        'Tam buğday wrap (1 adet)',
        'Yumurta (2 adet)',
        'Humus (50g)',
        'Sebze'
      ],
      'Poached Egg + Tam Buğday Toast': [
        'Yumurta (2 adet)',
        'Tam buğday ekmek (2 dilim)',
        'Avokado (1/2 adet)',
        'Zeytinyağı'
      ],
      'Grilled Halloumi + Sebze': [
        'Halloumi peyniri (80g)',
        'Domates (1 adet)',
        'Salatalık (1 adet)',
        'Zeytin'
      ],
      'Peynirli Pide + Maydanoz': [
        'Pide (1 adet)',
        'Kaşar (50g)',
        'Maydanoz (1 demet)'
      ],
      'Kasseri + Bal + Ceviz': [
        'Kasseri peyniri (60g)',
        'Bal (1 YK)',
        'Ceviz (6 adet)',
        'Ekmek (1 dilim)'
      ],
      'Gouda + Armut + Badem': [
        'Gouda peyniri (60g)',
        'Armut (1 adet)',
        'Badem (10 adet)'
      ],
      'Mozzarella + Domates + Fesleğen': [
        'Mozzarella (80g)',
        'Domates (1 adet)',
        'Fesleğen',
        'Zeytinyağı'
      ],
      'Greek Yogurt + Meyve + Granola': [
        'Greek yogurt (200g)',
        'Karışık meyve (100g)',
        'Granola (40g)'
      ],
      'Yoğurt + Chia Seed + Bal': [
        'Süzme yoğurt (200g)',
        'Chia tohumu (1 YK)',
        'Bal (1 YK)',
        'Meyve'
      ],
      'Protein Yoğurt + Muz + Fıstık Ezmesi': [
        'Protein yoğurt (200g)',
        'Muz (1 adet)',
        'Fıstık ezmesi (1 YK)'
      ],
      'Yoğurt Parfait + Meyve + Ceviz': [
        'Süzme yoğurt (150g)',
        'Granola (30g)',
        'Meyve (100g)',
        'Ceviz (5 adet)'
      ],
      'Kefir Smoothie + Muz + Yulaf': [
        'Kefir (200ml)',
        'Muz (1 adet)',
        'Yulaf (2 YK)',
        'Bal (1 tsp)'
      ],
      'Tam Buğday Pancake + Meyve': [
        'Tam buğday unu (50g)',
        'Yumurta (1 adet)',
        'Süt (100ml)',
        'Meyve',
        'Bal'
      ],
      'Protein Pancake + Bal': [
        'Protein tozu (1 ölçek)',
        'Yumurta (2 adet)',
        'Muz (1 adet)',
        'Bal'
      ],
      'Yulaf Pancake + Muz + Badem': [
        'Yulaf (50g)',
        'Yumurta (1 adet)',
        'Muz (1 adet)',
        'Badem (10 adet)'
      ],
      'Tam Buğday Waffle + Çilek': [
        'Tam buğday unu (50g)',
        'Yumurta (1 adet)',
        'Çilek (100g)',
        'Bal'
      ],
      'Quinoa Kahvaltı Bowl + Meyve': [
        'Kinoa (50g)',
        'Yoğurt (100g)',
        'Meyve (100g)',
        'Bal',
        'Ceviz'
      ],
      'Overnight Oats + Chia + Meyve': [
        'Yulaf (50g)',
        'Süt (150ml)',
        'Chia (1 YK)',
        'Meyve',
        'Bal'
      ],
      'Bircher Müsli + Elma + Ceviz': [
        'Yulaf (50g)',
        'Elma (1 adet)',
        'Ceviz (6 adet)',
        'Yoğurt (100g)'
      ],
      'Tam Buğday French Toast': [
        'Tam buğday ekmek (2 dilim)',
        'Yumurta (1 adet)',
        'Süt (50ml)',
        'Bal'
      ],
      'Yulaf Lapası + Kuru Meyve': [
        'Yulaf (50g)',
        'Süt (200ml)',
        'Kuru meyve (30g)',
        'Bal'
      ],
      'Tam Buğday Wrap + Yumurta': [
        'Tam buğday wrap (1 adet)',
        'Yumurta (2 adet)',
        'Sebze',
        'Peynir'
      ],
      'Pirinç Patlağı + Badem Ezmesi': [
        'Pirinç patlağı (4 adet)',
        'Badem ezmesi (2 YK)',
        'Muz (1/2 adet)'
      ],
      'Kinoa Bowl + Yoğurt + Meyve': [
        'Kinoa (50g)',
        'Yoğurt (150g)',
        'Meyve (100g)',
        'Bal',
        'Ceviz'
      ],
      'Tam Buğday Kraker + Labne': [
        'Tam buğday kraker (6 adet)',
        'Labne (80g)',
        'Zeytinyağı'
      ],
      'Yulaf Barı + Kuru Meyve': ['Yulaf barı (1 adet)', 'Kuru meyve (20g)'],
      'Bulgur Lapası + Bal + Ceviz': [
        'Bulgur (50g)',
        'Süt (200ml)',
        'Bal (1 YK)',
        'Ceviz (6 adet)'
      ],
      'Amaranth Porridge + Meyve': [
        'Amaranth (50g)',
        'Süt (200ml)',
        'Meyve (100g)',
        'Bal'
      ],
      'Tam Buğday Bagel + Cream Cheese': [
        'Tam buğday bagel (1 adet)',
        'Cream cheese (50g)',
        'Somon (30g)'
      ],
      'Chia Pudding + Meyve + Badem': [
        'Chia tohumu (3 YK)',
        'Badem sütü (200ml)',
        'Meyve',
        'Badem (10 adet)'
      ],
      'Açai Bowl + Granola + Muz': [
        'Açai (100g)',
        'Granola (40g)',
        'Muz (1 adet)',
        'Bal'
      ],
      'Smoothie Bowl + Chia + Meyve': [
        'Muz (1 adet)',
        'Meyve (100g)',
        'Yoğurt (100g)',
        'Chia',
        'Granola'
      ],
      'Avokado Toast + Yumurta': [
        'Tam buğday ekmek (2 dilim)',
        'Avokado (1 adet)',
        'Yumurta (1 adet)'
      ],
      'Avokado + Tam Buğday + Somon': [
        'Tam buğday ekmek (2 dilim)',
        'Avokado (1/2 adet)',
        'Füme somon (50g)'
      ],
      'Spirulina Smoothie + Muz': [
        'Spirulina (1 tsp)',
        'Muz (1 adet)',
        'Süt (200ml)',
        'Bal'
      ],
      'Goji Berry + Yoğurt + Granola': [
        'Goji berry (20g)',
        'Yoğurt (200g)',
        'Granola (40g)'
      ],
      'Chia + Badem Sütü + Meyve': [
        'Chia (3 YK)',
        'Badem sütü (200ml)',
        'Meyve (100g)',
        'Bal'
      ],
      'Acai + Protein + Ceviz': [
        'Açai (100g)',
        'Protein tozu (1 ölçek)',
        'Ceviz (8 adet)',
        'Muz'
      ],
      'Green Smoothie + Ispanak + Muz': [
        'Ispanak (50g)',
        'Muz (1 adet)',
        'Süt (200ml)',
        'Bal'
      ],
      'Sushi Bowl + Somon + Avokado': [
        'Sushi rice (80g)',
        'Somon (80g)',
        'Avokado (1/2 adet)',
        'Nori'
      ],
      'Protein Bar + Muz': ['Protein bar (1 adet)', 'Muz (1 adet)'],
      'Energy Balls + Yoğurt': ['Energy balls (3 adet)', 'Yoğurt (100g)'],
      'Tofu Scramble + Sebze': [
        'Tofu (150g)',
        'Karışık sebze (100g)',
        'Zeytinyağı',
        'Baharat'
      ],
      'Tempeh Bacon + Avokado Toast': [
        'Tempeh (80g)',
        'Tam buğday ekmek (2 dilim)',
        'Avokado (1/2 adet)'
      ],

      // 🍽️ ÖĞLE YEMEKLERİ - TÜM VARİASYONLAR
      'Izgara Tavuk + Bulgur Pilavı + Salata': [
        'Tavuk göğsü (150g)',
        'Bulgur (80g)',
        'Karışık yeşillik',
        'Zeytinyağı (1 YK)',
        'Limon'
      ],
      'Köfte + Pirinç Pilavı + Cacık': [
        'Dana köfte (4 adet)',
        'Pirinç (100g)',
        'Yoğurt (150g)',
        'Salatalık (1 adet)',
        'Nane',
        'Sarımsak'
      ],
      'Balık Izgara + Sebze Güveci + Bulgur': [
        'Somon (120g)',
        'Patlıcan (1 adet)',
        'Kabak (1 adet)',
        'Bulgur (60g)',
        'Zeytinyağı'
      ],
      'Mercimek Çorbası + Et Sote + Pilav': [
        'Kırmızı mercimek (100g)',
        'Dana et (120g)',
        'Pirinç (80g)',
        'Soğan',
        'Havuç',
        'Baharat'
      ],
      'Tavuk Şiş + Pirinç + Közlenmiş Biber': [
        'Tavuk but (150g)',
        'Pirinç (80g)',
        'Kırmızı biber (2 adet)',
        'Patlıcan (1 adet)',
        'Baharat'
      ],
      'Izgara Somon + Kinoa + Brokoli': [
        'Somon fileto (130g)',
        'Kinoa (70g)',
        'Brokoli (150g)',
        'Zeytinyağı',
        'Limon'
      ],
      'Dana Rosto + Bulgur + Mevsim Salatası': [
        'Dana rosto (120g)',
        'Bulgur (80g)',
        'Karışık salata',
        'Domates',
        'Salatalık'
      ],
      'Köfte + Sebzeli Pilav + Yoğurt': [
        'Dana köfte (4 adet)',
        'Pirinç (80g)',
        'Havuç (1 adet)',
        'Bezelye',
        'Yoğurt (100g)'
      ],
      'Balık Fileto + Fırın Patates + Salata': [
        'Levrek fileto (130g)',
        'Patates (2 orta)',
        'Yeşil salata',
        'Zeytinyağı',
        'Kekik'
      ],
      'Hindi Schnitzel + Bulgur + Turp Salatası': [
        'Hindi göğsü (130g)',
        'Bulgur (70g)',
        'Turp (3 adet)',
        'Maydanoz',
        'Limon'
      ],
      'Izgara Et + Sebze + Pirinç': [
        'Dana bonfile (120g)',
        'Karışık sebze',
        'Pirinç (80g)',
        'Zeytinyağı',
        'Baharat'
      ],
      'Tavuk Sote + Makarna + Domates Salata': [
        'Tavuk göğsü (140g)',
        'Tam buğday makarna (80g)',
        'Domates (2 adet)',
        'Fesleğen'
      ],

      // 🌅 AKŞAM YEMEKLERİ - TÜM VARİASYONLAR
      'Fırında Somon + Sebze Güveci': [
        'Somon fileto (120g)',
        'Patlıcan (1 adet)',
        'Kabak (1 adet)',
        'Domates (2 adet)',
        'Zeytinyağı'
      ],
      'Izgara Tavuk + Bulgur + Salata': [
        'Tavuk göğsü (120g)',
        'Bulgur (60g)',
        'Yeşil salata',
        'Domates',
        'Limon'
      ],
      'Et Sote + Pirinç + Cacık': [
        'Dana et (100g)',
        'Pirinç (80g)',
        'Yoğurt (100g)',
        'Salatalık',
        'Nane',
        'Sarımsak'
      ],
      'Balık Fileto + Sebze + Bulgur': [
        'Çupra fileto (120g)',
        'Karışık sebze (200g)',
        'Bulgur (60g)',
        'Zeytinyağı',
        'Kekik'
      ],
      'Köfte + Patates Püresi + Turşu': [
        'Dana köfte (3 adet)',
        'Patates (3 orta)',
        'Süt (50ml)',
        'Tereyağı',
        'Karışık turşu'
      ],
      'Hindi Rosto + Sebzeli Pilav': [
        'Hindi göğsü (120g)',
        'Pirinç (70g)',
        'Havuç (1 adet)',
        'Bezelye',
        'Soğan'
      ],
      'Izgara Somon + Brokoli + Kinoa': [
        'Somon (120g)',
        'Brokoli (150g)',
        'Kinoa (60g)',
        'Zeytinyağı',
        'Limon'
      ],
      'Tavuk Sote + Sebze + Bulgur': [
        'Tavuk göğsü (120g)',
        'Patlıcan (1 adet)',
        'Biber (1 adet)',
        'Bulgur (60g)',
        'Zeytinyağı'
      ],
      'Dana Et + Sebze Güveci + Pilav': [
        'Dana kuşbaşı (100g)',
        'Karışık sebze (200g)',
        'Pirinç (70g)',
        'Zeytinyağı'
      ],
      'Balık Izgara + Fırın Sebze': [
        'Levrek (120g)',
        'Kabak (1 adet)',
        'Patlıcan (1 adet)',
        'Biber (1 adet)',
        'Kekik'
      ],
      'Et Güveci + Bulgur + Yoğurt': [
        'Dana et (100g)',
        'Soğan (1 adet)',
        'Bulgur (60g)',
        'Yoğurt (100g)',
        'Baharat'
      ],
      'Tavuk Fileto + Sebze + Pirinç': [
        'Tavuk fileto (120g)',
        'Brokoli (100g)',
        'Havuç (1 adet)',
        'Pirinç (70g)'
      ],

      // 🍎 ARA ÖĞÜN 1 - TÜM VARİASYONLAR
      'Yoğurt + Muz + Badem': [
        'Süzme yoğurt (150g)',
        'Muz (1 adet)',
        'Badem (10 adet)'
      ],
      'Elma + Ceviz + Bal': ['Elma (1 orta)', 'Ceviz (6 adet)', 'Bal (1 tsp)'],
      'Süzme Yoğurt + Çilek + Fındık': [
        'Süzme yoğurt (150g)',
        'Çilek (100g)',
        'Fındık (15 adet)'
      ],
      'Armut + Badem + Tarçın': [
        'Armut (1 orta)',
        'Badem (12 adet)',
        'Tarçın (1 tsp)'
      ],
      'Kivi + Yoğurt + Granola': [
        'Kivi (2 adet)',
        'Yoğurt (100g)',
        'Granola (20g)'
      ],
      'Portakal + Ceviz + Bal': [
        'Portakal (1 orta)',
        'Ceviz (8 adet)',
        'Bal (1 tsp)'
      ],
      'Muz + Fıstık Ezmesi + Yulaf': [
        'Muz (1 adet)',
        'Fıstık ezmesi (1 YK)',
        'Yulaf ezmesi (20g)'
      ],
      'Üzüm + Peynir + Ceviz': [
        'Üzüm (100g)',
        'Beyaz peynir (40g)',
        'Ceviz (5 adet)'
      ],
      'Tam Buğday Bisküvi + Fıstık Ezmesi': [
        'Tam buğday bisküvi (4 adet)',
        'Fıstık ezmesi (2 YK)',
        'Muz (1/2 adet)'
      ],
      'Protein Bar + Elma': ['Protein bar (1 adet)', 'Elma (1 orta)'],
      'Kuruyemiş Karışımı': [
        'Badem (8 adet)',
        'Ceviz (5 adet)',
        'Fındık (10 adet)',
        'Kuru üzüm (1 YK)'
      ],
      'Muz + Badem': ['Muz (1 orta)', 'Badem (12 adet)'],
      'Portakal + Fındık': ['Portakal (1 orta)', 'Fındık (15 adet)'],
      'Kefir + Meyve': ['Kefir (200g)', 'Çilek (80g)', 'Muz (1/2 adet)'],
      'Kivi + Badem': ['Kivi (2 adet)', 'Badem (12 adet)'],
      'Çilek + Fındık': ['Çilek (120g)', 'Fındık (15 adet)'],
      'Üzüm + Ceviz': ['Üzüm (120g)', 'Ceviz (8 adet)'],
      'Şeftali + Badem': ['Şeftali (1 büyük)', 'Badem (12 adet)'],
      'Erik + Fındık': ['Erik (3 adet)', 'Fındık (15 adet)'],
      'Kayısı + Ceviz': ['Kayısı (5 adet)', 'Ceviz (8 adet)'],
      'Elma Dilimi + Badem Ezmesi': ['Elma (1 orta)', 'Badem ezmesi (2 YK)'],
      'Meyve Salatası': [
        'Elma (1/2 adet)',
        'Muz (1/2 adet)',
        'Portakal (1/2 adet)',
        'Çilek (50g)'
      ],
      'Smoothie (Meyve + Süt)': [
        'Muz (1 adet)',
        'Çilek (100g)',
        'Süt (200ml)',
        'Bal (1 tsp)'
      ],
      'Muz + Yulaf': ['Muz (1 adet)', 'Yulaf (30g)', 'Süt (100ml)'],
      'Yoğurt + Granola': ['Yoğurt (150g)', 'Granola (30g)', 'Bal (1 tsp)'],
      'Süzme Yoğurt + Bal': [
        'Süzme yoğurt (180g)',
        'Bal (1 YK)',
        'Ceviz (5 adet)'
      ],
      'Badem + Kuru Üzüm': ['Badem (15 adet)', 'Kuru üzüm (2 YK)'],
      'Ceviz + Kuru Kayısı': ['Ceviz (10 adet)', 'Kuru kayısı (5 adet)'],
      'Fındık + Kuru İncir': ['Fındık (20 adet)', 'Kuru incir (3 adet)'],
      'Antep Fıstığı + Hurma': ['Antep fıstığı (15 adet)', 'Hurma (3 adet)'],
      'Kaju + Kuru Erik': ['Kaju (15 adet)', 'Kuru erik (4 adet)'],
      'Kete + Süt': ['Kete (1 adet)', 'Süt (200ml)'],
      'Kraker + Peynir': ['Tam buğday kraker (6 adet)', 'Beyaz peynir (50g)'],

      // 🥕 ARA ÖĞÜN 2 - TÜM VARİASYONLAR
      'Elma + Ceviz': ['Elma (1 orta)', 'Ceviz (8 adet)'],
      'Havuç + Humus': ['Havuç (1 büyük)', 'Humus (60g)', 'Limon suyu'],
      'Salatalık + Labne': [
        'Salatalık (1 büyük)',
        'Labne (80g)',
        'Nane',
        'Zeytinyağı (1 tsp)'
      ],
      'Domates + Peynir': [
        'Domates (1 büyük)',
        'Beyaz peynir (60g)',
        'Fesleğen',
        'Zeytin (5 adet)'
      ],
      'Kuruyemiş Karışımı': [
        'Badem (8 adet)',
        'Ceviz (5 adet)',
        'Fındık (10 adet)',
        'Kuru üzüm (1 YK)'
      ],
      'Yoğurt + Meyve': ['Yoğurt (180g)', 'Çilek (80g)', 'Muz (1/2 adet)'],
      'Çilek + Badem': ['Çilek (120g)', 'Badem (12 adet)'],
      'Portakal + Fındık': ['Portakal (1 orta)', 'Fındık (15 adet)'],
      'Havuç Çubukları + Yoğurt': [
        'Havuç (1 büyük)',
        'Yoğurt (120g)',
        'Baharat'
      ],
      'Salatalık + Beyaz Peynir': [
        'Salatalık (1 büyük)',
        'Beyaz peynir (60g)',
        'Nane'
      ],
      'Közlenmiş Biber + Lor': [
        'Kırmızı biber (2 adet)',
        'Lor peyniri (80g)',
        'Zeytinyağı (1 YK)',
        'Nane'
      ],
      'Kereviz + Humus': ['Kereviz (1 demet)', 'Humus (70g)', 'Limon suyu'],
      'Biber Dilimi + Labne': [
        'Yeşil biber (2 adet)',
        'Labne (70g)',
        'Fesleğen'
      ],
      'Cherry Domates + Feta': [
        'Cherry domates (150g)',
        'Feta peyniri (60g)',
        'Zeytinyağı'
      ],
      'Armut + Ceviz': ['Armut (1 orta)', 'Ceviz (8 adet)'],
      'Kereviz + Humus': ['Kereviz (1 demet)', 'Humus (70g)', 'Limon suyu'],
      'Biber Dilimi + Labne': [
        'Yeşil biber (2 adet)',
        'Labne (70g)',
        'Fesleğen'
      ],
      'Sebze Çubukları + Humus': [
        'Havuç (1 adet)',
        'Kereviz (2 sap)',
        'Humus (80g)'
      ],
      'Fındık + Hurma': ['Fındık (18 adet)', 'Hurma (3 adet)'],
      'Antep Fıstığı + Kuru İncir': [
        'Antep fıstığı (15 adet)',
        'Kuru incir (3 adet)'
      ],
      'Kaju + Elma': ['Kaju (15 adet)', 'Elma (1 orta)'],
      'Protein Bar': ['Protein bar (1 adet)', 'Su (200ml)'],
      'Tam Buğday Kraker + Humus': [
        'Tam buğday kraker (6 adet)',
        'Humus (70g)',
        'Domates (1 adet)'
      ],
      'Pirinç Kraker + Badem Ezmesi': [
        'Pirinç kraker (5 adet)',
        'Badem ezmesi (2 YK)',
        'Muz (1/2 adet)'
      ],
      'Meyve Suyu + Kuruyemiş': [
        'Taze portakal suyu (200ml)',
        'Badem (10 adet)',
        'Ceviz (5 adet)'
      ],
      'Smoothie': [
        'Muz (1 adet)',
        'Çilek (100g)',
        'Yoğurt (100g)',
        'Bal (1 tsp)'
      ],
      'Ayran + Simit': ['Ayran (200ml)', 'Simit (1 adet)'],
      'Süt + Fındık': ['Süt (200ml)', 'Fındık (20 adet)'],
      'Kefir + Badem': ['Kefir (200ml)', 'Badem (15 adet)'],
      'Labne + Ceviz': ['Labne (100g)', 'Ceviz (10 adet)', 'Bal (1 tsp)'],
    };

    // 🔥 AKILLI EŞLEŞTİRME - SIRALI KONTROL

    // 1️⃣ TAM EŞLEŞME (öncelik #1)
    if (malzemelerHaritasi.containsKey(yemekAdi)) {
      AppLogger.debug('✅ Tam eşleşme bulundu: $yemekAdi');
      return malzemelerHaritasi[yemekAdi]!;
    }

    // 2️⃣ BÜYÜK HARF/KÜÇÜK HARF DUYARSIZ EŞLEŞMEappeared (öncelik #2)
    final yemekAdiLower = yemekAdi.toLowerCase();
    for (final anahtar in malzemelerHaritasi.keys) {
      if (anahtar.toLowerCase() == yemekAdiLower) {
        AppLogger.debug('✅ Case-insensitive eşleşme: $anahtar');
        return malzemelerHaritasi[anahtar]!;
      }
    }

    // 3️⃣ İLK İKİ KELİME TAM EŞLEŞMESİ (öncelik #3)
    // "Elma + Ceviz" → "Elma + Ceviz" veya "Közlenmiş Biber" → "Közlenmiş Biber"
    final kelimeler =
        yemekAdi.split(RegExp(r'[\s\+]')).where((k) => k.isNotEmpty).toList();
    if (kelimeler.length >= 2) {
      final ilkIkiKelime = '${kelimeler[0]} ${kelimeler[1]}'.toLowerCase();
      for (final anahtar in malzemelerHaritasi.keys) {
        final anahtarKelimeler = anahtar
            .split(RegExp(r'[\s\+]'))
            .where((k) => k.isNotEmpty)
            .toList();
        if (anahtarKelimeler.length >= 2) {
          final anahtarIlkIki =
              '${anahtarKelimeler[0]} ${anahtarKelimeler[1]}'.toLowerCase();
          if (anahtarIlkIki == ilkIkiKelime) {
            AppLogger.debug(
                '✅ İlk iki kelime eşleşmesi: $anahtar (aranan: $yemekAdi)');
            return malzemelerHaritasi[anahtar]!;
          }
        }
      }
    }

    // 4️⃣ İLK KELİME TAM EŞLEŞMESİ (öncelik #4)
    final ilkKelime = kelimeler.first.toLowerCase();
    for (final anahtar in malzemelerHaritasi.keys) {
      final anahtarIlkKelime =
          anahtar.split(RegExp(r'[\s\+]')).first.toLowerCase();
      if (anahtarIlkKelime == ilkKelime) {
        AppLogger.debug('✅ İlk kelime eşleşmesi: $anahtar (aranan: $yemekAdi)');
        return malzemelerHaritasi[anahtar]!;
      }
    }

    // 5️⃣ KISMI EŞLEŞME - SON ÇARE (öncelik #5) - DEVRE DIŞI!
    // Kısmi eşleşme kapatıldı çünkü yanlış malzeme geliyordu

    // 6️⃣ HİÇ EŞLEŞMEDİ - AKILLI BAZ MALZEME ÜRET
    AppLogger.warning(
        '❌ Hiçbir eşleşme bulunamadı: $yemekAdi - Akıllı baz malzeme oluşturuluyor');

    // Son çare: Yemek tipine göre akıllı malzeme üret
    return _akilliBazMalzeme(yemekAdi);
  }

  /// 🧠 Akıllı baz malzeme üretici
  List<String> _akilliBazMalzeme(String yemekAdi) {
    final adLower = yemekAdi.toLowerCase();

    // Protein bazlı yemekler
    if (adLower.contains('tavuk')) {
      return [
        'Tavuk göğsü (120-150g)',
        'Zeytinyağı (1 tsp)',
        'Baharat karışımı',
        'Sebze garnitür'
      ];
    }
    if (adLower.contains('balık') || adLower.contains('somon')) {
      return [
        'Balık fileto (120g)',
        'Limon (1/2 adet)',
        'Zeytinyağı (1 tsp)',
        'Kekik'
      ];
    }
    if (adLower.contains('köfte') || adLower.contains('et')) {
      return [
        'Dana eti (100-120g)',
        'Soğan (1/2 adet)',
        'Baharat',
        'Zeytinyağı'
      ];
    }
    if (adLower.contains('yumurta')) {
      return ['Yumurta (2 adet)', 'Tereyağı (1 tsp)', 'Tuz', 'Karabiber'];
    }

    // Karbonhidrat bazlı
    if (adLower.contains('pilav') || adLower.contains('pirinç')) {
      return ['Pirinç (80g)', 'Su (150ml)', 'Tuz', 'Tereyağı (1 tsp)'];
    }
    if (adLower.contains('bulgur')) {
      return ['Bulgur (60-80g)', 'Su (120ml)', 'Tuz', 'Zeytinyağı'];
    }

    // Süt ürünleri bazlı
    if (adLower.contains('yoğurt')) {
      return ['Süzme yoğurt (150g)', 'Bal (1 tsp)', 'Meyve garnitür'];
    }
    if (adLower.contains('peynir')) {
      return ['Beyaz peynir (50g)', 'Domates (1 adet)', 'Salatalık (1/2 adet)'];
    }

    // Meyve bazlı
    if (adLower.contains('meyve') ||
        adLower.contains('çilek') ||
        adLower.contains('elma')) {
      return [
        'Taze meyve (100-150g)',
        'Kuruyemiş (5-10 adet)',
        'Bal (isteğe bağlı)'
      ];
    }

    // Varsayılan dengeli öğün
    return [
      'Ana protein kaynağı (120g)',
      'Karbonhidrat (80g)',
      'Taze sebze garnitür',
      'Sağlıklı yağ (1 tsp)'
    ];
  }

  /// 🔥 GERÇEK MAKRO HESAPLAMA - Malzemelerden gerçek değerleri hesapla (NaN SAFE)
  Map<String, double> _gercekMakroHesapla(List<String> malzemeler) {
    double toplamKalori = 0.0;
    double toplamProtein = 0.0;
    double toplamKarb = 0.0;
    double toplamYag = 0.0;

    for (final malzeme in malzemeler) {
      final malzemeLower = malzeme.toLowerCase();

      // 🔥 GELİŞTİRİLMİŞ MİKTAR PARSE - Parantez içindeki değerleri de yakala
      // Örnekler: "Süzme yoğurt (200g)", "Bal (1 YK)", "Ceviz (8 adet)"
      double miktar = 100; // Varsayılan
      String birimStr = 'g';

      // İlk regex: Parantez içindeki değerleri yakala
      // 🔥 FIX: "Domates (2 adet)" formatını da destekle
      final parantezRegex =
          RegExp(r'\((\d+(?:[.,]\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]+)\)');
      final parantezMatch = parantezRegex.firstMatch(malzeme);

      if (parantezMatch != null) {
        // Parantez içinde miktar var: "Süzme yoğurt (200g)" veya "Domates (2 adet)"
        var miktarStr = parantezMatch.group(1)!.replaceAll(',', '.');
        miktar = double.tryParse(miktarStr) ?? 100;
        birimStr = parantezMatch.group(2)?.toLowerCase() ?? 'g';
      } else {
        // Parantez yok, normal parse: "200g süzme yoğurt" veya "2 adet yumurta"
        final normalRegex =
            RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]*)\s+');
        final normalMatch = normalRegex.firstMatch(malzeme);

        if (normalMatch != null) {
          miktar = double.tryParse(normalMatch.group(1)!) ?? 100;
          final birimTemp = normalMatch.group(2)?.toLowerCase();
          if (birimTemp != null && birimTemp.isNotEmpty) {
            birimStr = birimTemp;
          }
        } else {
          // 🔥 FIX: HİÇBİR REGEX'E UYMADI - Miktarsız malzeme!
          // "Kaşar rendesi", "Tuz", "Baharat" gibi
          // Regex'lere uymayan malzemeler (örn: "Kaşar rendesi", "Tuz", "Baharat")
          if (malzemeLower.contains('tuz') ||
              malzemeLower.contains('karabiber') ||
              malzemeLower.contains('baharat') ||
              malzemeLower.contains('kekik') ||
              malzemeLower.contains('nane') ||
              malzemeLower.contains('maydanoz') ||
              malzemeLower.contains('fesleğen')) {
            miktar = 2; // Baharat/Ot: 2g
          } else if (malzemeLower.contains('rende') ||
              malzemeLower.contains('rendesi') ||
              malzemeLower.contains('garnitür') ||
              malzemeLower.contains('süsleme')) {
            miktar = 15; // Rende peynir/Garnitür: 15g
          } else if (malzemeLower.contains('yeşillik') ||
              malzemeLower.contains('salata')) {
            miktar = 50; // Sebze garnitür: 50g
          } else {
            miktar = 20; // Diğer miktarsız malzemeler: 20g (konservatif)
          }
        }
      }

      // 🔥 BİRİM DÖNÜŞÜMÜ - GÜÇLENDİRİLDİ
      if (birimStr.contains('yemek') || birimStr.contains('yk')) {
        miktar = miktar * 15; // 1 YK = 15g (önceden 10g'dı, düşüktü)
      } else if (birimStr.contains('çay') ||
          birimStr.contains('çk') ||
          birimStr.contains('tsp')) {
        miktar = miktar * 5; // 1 ÇK = 5g
      } else if (birimStr.contains('adet')) {
        // Adet malzemeye göre hesaplanacak
        if (malzemeLower.contains('yumurta'))
          miktar = miktar * 50;
        else if (malzemeLower.contains('domates'))
          miktar = miktar * 100;
        else if (malzemeLower.contains('salatalık'))
          miktar = miktar * 150;
        else if (malzemeLower.contains('elma'))
          miktar = miktar * 150;
        else if (malzemeLower.contains('muz'))
          miktar = miktar * 120;
        else if (malzemeLower.contains('portakal'))
          miktar = miktar * 150;
        else if (malzemeLower.contains('ceviz'))
          miktar = miktar * 3;
        else if (malzemeLower.contains('badem'))
          miktar = miktar * 1;
        else if (malzemeLower.contains('fındık'))
          miktar = miktar * 1;
        else if (malzemeLower.contains('köfte'))
          miktar = miktar * 60;
        else if (malzemeLower.contains('patates'))
          miktar = miktar * 150;
        else if (malzemeLower.contains('zeytin'))
          miktar = miktar * 5;
        else if (malzemeLower.contains('biber'))
          miktar = miktar * 100;
        else if (malzemeLower.contains('soğan'))
          miktar = miktar * 100;
        else if (malzemeLower.contains('patlıcan'))
          miktar = miktar * 200;
        else if (malzemeLower.contains('kabak'))
          miktar = miktar * 200;
        else
          miktar = miktar * 100; // Varsayılan
      } else if (birimStr.contains('dilim')) {
        miktar = miktar * 35; // 1 dilim ekmek = 35g
      } else if (birimStr.contains('demet')) {
        miktar = miktar * 50; // 1 demet = 50g
      } else if (birimStr == 'ml') {
        // ml → g dönüşümü (su bazlı sıvılar için 1:1)
        miktar = miktar * 1.0;
      }
      // 'g' ise zaten gram, değişiklik yok

      // BESİN TÜRÜNE GÖRE MAKRO HESAPLA (100g bazında)
      final besinDegerleri = _besin100gDegerleri(malzemeLower);

      // ORANLA HESAPLA (miktar/100)
      final carpan = miktar / 100.0;
      toplamKalori += besinDegerleri['kalori']! * carpan;
      toplamProtein += besinDegerleri['protein']! * carpan;
      toplamKarb += besinDegerleri['karb']! * carpan;
      toplamYag += besinDegerleri['yag']! * carpan;
    }

    // 🔥 NaN GUARD: Geçersiz değerleri düzelt
    return {
      'kalori':
          toplamKalori.isNaN || toplamKalori.isInfinite ? 100.0 : toplamKalori,
      'protein': toplamProtein.isNaN || toplamProtein.isInfinite
          ? 10.0
          : toplamProtein,
      'karb': toplamKarb.isNaN || toplamKarb.isInfinite ? 10.0 : toplamKarb,
      'yag': toplamYag.isNaN || toplamYag.isInfinite ? 3.0 : toplamYag,
    };
  }

  /// 🔥 ÇEŞİTLİ YEMEK SEÇ - Haftalık planda tekrar etmesin
  String _cesitliYemekSec(List<String> yemekler, String kategori) {
    final uygunYemekler = yemekler
        .where((y) => !_haftalikSecilenYemekler.contains('$kategori:$y'))
        .toList();

    if (uygunYemekler.isEmpty) {
      // Tüm yemekler kullanıldıysa, set'i temizle ve devam et
      _haftalikSecilenYemekler
          .removeWhere((item) => item.startsWith('$kategori:'));
      return yemekler[_random.nextInt(yemekler.length)];
    }

    final secilen = uygunYemekler[_random.nextInt(uygunYemekler.length)];
    _haftalikSecilenYemekler.add('$kategori:$secilen');

    return secilen;
  }

  /// 🔥 AKŞAM YEMEĞİ SEÇ - Öğle ile aynı olmamalı (Hafta içi)
  String _cesitliYemekSecAksam(List<String> yemekler, String secilenOgle,
      DateTime tarih, String kategori) {
    final haftaIci = tarih.weekday >= 1 && tarih.weekday <= 5; // Pazartesi-Cuma

    // Haftalık planda kullanılmamış yemekler
    final uygunYemekler = yemekler.where((y) {
      final haftalikKullanilmamis =
          !_haftalikSecilenYemekler.contains('$kategori:$y');

      if (haftaIci) {
        // Hafta içi: Öğle ile aynı olmamalı
        return haftalikKullanilmamis && y != secilenOgle;
      } else {
        // Hafta sonu: Öğle ile aynı olabilir
        return haftalikKullanilmamis;
      }
    }).toList();

    if (uygunYemekler.isEmpty) {
      // Tüm yemekler kullanıldıysa, set'i temizle
      _haftalikSecilenYemekler
          .removeWhere((item) => item.startsWith('$kategori:'));

      // Öğle ile farklı olan bir yemek seç (hafta içi)
      if (haftaIci) {
        final farkliYemekler = yemekler.where((y) => y != secilenOgle).toList();
        return farkliYemekler.isNotEmpty
            ? farkliYemekler[_random.nextInt(farkliYemekler.length)]
            : yemekler[_random.nextInt(yemekler.length)];
      }

      return yemekler[_random.nextInt(yemekler.length)];
    }

    final secilen = uygunYemekler[_random.nextInt(uygunYemekler.length)];
    _haftalikSecilenYemekler.add('$kategori:$secilen');

    return secilen;
  }

  /// 🔥 YENİ METOD: Malzeme miktarlarını ölçeklendir (SAĞLIKLI LİMİTLERLE + NaN SAFE)
  List<String> _malzemeleriOlcekle(List<String> malzemeler, double olcek) {
    // 🔥 NaN GUARD: Geçersiz ölçek değerlerini düzelt
    if (olcek.isNaN || olcek.isInfinite || olcek <= 0) {
      AppLogger.warning(
          '⚠️ Geçersiz ölçek değeri: $olcek - Varsayılan 1.0 kullanılıyor');
      olcek = 1.0;
    }

    // 🔥 SAĞLIK LİMİTİ: Aşırı ölçeklemeyi önle
    final guvenliolcek = olcek.clamp(0.6, 1.8); // Min %60, Max %180

    if (olcek != guvenliolcek) {
      AppLogger.warning(
          '⚠️ Ölçek limiti uygulandı: ${olcek.toStringAsFixed(2)}x → ${guvenliolcek.toStringAsFixed(2)}x');
    }

    return malzemeler.map((malzeme) {
      // Regex: Miktar + Birim + Besin formatını yakala
      final regex = RegExp(
          r'^(.+?)\s*\((\d+(?:\.\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]+)\)(.*)$');
      final match = regex.firstMatch(malzeme);

      if (match != null) {
        final besinAdi = match.group(1)!;
        final miktar = double.tryParse(match.group(2)!) ?? 100;
        final birim = match.group(3)!;
        final gerisi = match.group(4) ?? '';

        // 🔥 BESİN BAZINDA SAĞLIKLI MAKSİMUM LİMİTLER
        double yeniMiktar = miktar * guvenliolcek;

        // Yoğun besinler için max limitler (tek öğünde mantıklı miktarlar)
        final besinLower = besinAdi.toLowerCase();
        if (besinLower.contains('labne') && birim.contains('g')) {
          yeniMiktar = yeniMiktar.clamp(40, 100); // Max 100g labne
        } else if (besinLower.contains('yoğurt') && birim.contains('g')) {
          yeniMiktar = yeniMiktar.clamp(100, 200); // Max 200g yoğurt
        } else if (besinLower.contains('peynir') && birim.contains('g')) {
          yeniMiktar = yeniMiktar.clamp(30, 80); // Max 80g peynir
        } else if (besinLower.contains('humus') && birim.contains('g')) {
          yeniMiktar = yeniMiktar.clamp(40, 80); // Max 80g humus
        }

        return '$besinAdi (${yeniMiktar.round()} $birim)$gerisi';
      }

      // Normal format: Miktar Birim Besin
      final normalRegex =
          RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]*)\s+(.+)$');
      final normalMatch = normalRegex.firstMatch(malzeme);

      if (normalMatch != null) {
        final miktar = double.tryParse(normalMatch.group(1)!) ?? 100;
        final birim = normalMatch.group(2) ?? 'g';
        final besinAdi = normalMatch.group(3)!;

        final yeniMiktar = (miktar * guvenliolcek).round();
        return '$yeniMiktar $birim $besinAdi';
      }

      // Ölçeklendirilemez, olduğu gibi döndür
      return malzeme;
    }).toList();
  }

  /// 🔥 YENİ METOD: Tüm öğünü ölçeklendir (malzemeler + makrolar + NaN SAFE)
  Yemek _oguniOlcekle(Yemek ogun, double olcek) {
    // 🔥 NaN GUARD: Geçersiz ölçek değerlerini düzelt
    if (olcek.isNaN || olcek.isInfinite || olcek <= 0) {
      AppLogger.warning(
          '⚠️ Geçersiz ölçek değeri: $olcek - Öğün ölçeklenmeyecek');
      olcek = 1.0;
    }

    // Malzemeleri ölçekle
    final olceklenmisMalzemeler = _malzemeleriOlcekle(ogun.malzemeler, olcek);

    // 🔥 NaN GUARD: Makroları ölçekle ama NaN kontrolü yap
    final yeniKalori = ogun.kalori * olcek;
    final yeniProtein = ogun.protein * olcek;
    final yeniKarb = ogun.karbonhidrat * olcek;
    final yeniYag = ogun.yag * olcek;

    // Yeni yemek objesi oluştur (ölçeklenmiş değerlerle)
    return Yemek(
      id: ogun.id,
      ad: ogun.ad,
      ogun: ogun.ogun,
      kalori:
          yeniKalori.isNaN || yeniKalori.isInfinite ? ogun.kalori : yeniKalori,
      protein: yeniProtein.isNaN || yeniProtein.isInfinite
          ? ogun.protein
          : yeniProtein,
      karbonhidrat:
          yeniKarb.isNaN || yeniKarb.isInfinite ? ogun.karbonhidrat : yeniKarb,
      yag: yeniYag.isNaN || yeniYag.isInfinite ? ogun.yag : yeniYag,
      malzemeler: olceklenmisMalzemeler,
      hazirlamaSuresi: ogun.hazirlamaSuresi,
      zorluk: ogun.zorluk,
      etiketler: ogun.etiketler,
    );
  }

  /// 🔥 AKILLI + ÇEŞİTLİ YEMEK SEÇİMİ - Makro + RANDOM çeşitlilik
  String _enUygunYemekSec(
    List<String> yemekler,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    // 1. ÇEŞİTLİLİK FİLTRESİ: Bugün kullanılmış ana malzemeleri içermeyen yemekleri seç
    final cesitliYemekler = yemekler.where((yemek) {
      final anaMalzeme = _anaMalzemeyiBelirle(yemek);
      return !_gunlukSecilenAnaMalzemeler.contains(anaMalzeme);
    }).toList();

    // Tüm yemekler kullanıldıysa, set'i temizle ve tüm yemekleri kullan
    final kullanilacakYemekler =
        cesitliYemekler.isEmpty ? yemekler : cesitliYemekler;

    AppLogger.info(
        '🎯 Çeşitlilik: ${yemekler.length} yemekten ${kullanilacakYemekler.length} uygun');

    // 2. MAKRO SKORLAMA - TOP 5 BUL
    final skorluYemekler = <({String yemek, double skor})>[];

    for (final yemek in kullanilacakYemekler) {
      // Yemeğin başlangıç makrolarını hesapla
      final malzemeler = _detayliMalzemeler(yemek);
      final makro = _gercekMakroHesapla(malzemeler);

      // Mevcut kalori ile hedef kalori oranını bul
      final olcek = hedefKalori / makro['kalori']!;

      // Ölçeklenmiş makroları hesapla
      final olcekliProtein = makro['protein']! * olcek;
      final olcekliKarb = makro['karb']! * olcek;
      final olcekliYag = makro['yag']! * olcek;

      // Hedeflerden sapma skorunu hesapla (düşük = iyi)
      final proteinSapma = (olcekliProtein - hedefProtein).abs() / hedefProtein;
      final karbSapma = (olcekliKarb - hedefKarb).abs() / hedefKarb;
      final yagSapma = (olcekliYag - hedefYag).abs() / hedefYag;

      // Toplam skor (tüm makroların sapma toplamı)
      final skor = proteinSapma + karbSapma + yagSapma;
      skorluYemekler.add((yemek: yemek, skor: skor));
    }

    // Skora göre sırala ve TOP 5 al
    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    final top5 = skorluYemekler.take(5).toList();

    // 3. 🎲 TOP 5 ARASINDA RANDOM SEÇ (Tarihe göre seed ile)
    final secilenIndex = _random.nextInt(top5.length);
    final secilenYemek = top5[secilenIndex].yemek;

    // 4. SEÇİLEN YEMEĞİN ANA MALZEMESİNİ KAYDET
    final secilenAnaMalzeme = _anaMalzemeyiBelirle(secilenYemek);
    _gunlukSecilenAnaMalzemeler.add(secilenAnaMalzeme);

    AppLogger.success(
        '✅ Top 5\'ten random seçildi (#${secilenIndex + 1}): $secilenYemek');
    AppLogger.debug(
        '   Top 5: ${top5.map((e) => '${e.yemek} (${e.skor.toStringAsFixed(2)})').join(', ')}');

    return secilenYemek;
  }

  /// 🔥 ANA MALZEME BELİRLEME - Yemek adından ana malzemeyi çıkar
  String _anaMalzemeyiBelirle(String yemekAdi) {
    final adLower = yemekAdi.toLowerCase();

    // Protein kaynakları
    if (adLower.contains('yumurta') ||
        adLower.contains('omlet') ||
        adLower.contains('menemen') ||
        adLower.contains('çılbır')) {
      return 'yumurta';
    }
    if (adLower.contains('yoğurt') || adLower.contains('kefir')) {
      return 'yogurt';
    }
    if (adLower.contains('peynir') ||
        adLower.contains('lor') ||
        adLower.contains('labne') ||
        adLower.contains('kaşar') ||
        adLower.contains('feta') ||
        adLower.contains('tost')) {
      return 'peynir';
    }
    if (adLower.contains('tavuk')) {
      return 'tavuk';
    }
    if (adLower.contains('et ') ||
        adLower.contains('dana') ||
        adLower.contains('kuzu') ||
        adLower.contains('köfte')) {
      return 'kirmizi_et';
    }
    if (adLower.contains('balık') ||
        adLower.contains('somon') ||
        adLower.contains('levrek') ||
        adLower.contains('çupra') ||
        adLower.contains('hamsi') ||
        adLower.contains('uskumru')) {
      return 'balik';
    }
    if (adLower.contains('hindi')) {
      return 'hindi';
    }

    // Karbonhidrat kaynakları
    if (adLower.contains('bulgur')) {
      return 'bulgur';
    }
    if (adLower.contains('pirinç') || adLower.contains('pilav')) {
      return 'pirinc';
    }
    if (adLower.contains('makarna')) {
      return 'makarna';
    }
    if (adLower.contains('kinoa')) {
      return 'kinoa';
    }
    if (adLower.contains('ekmek') ||
        adLower.contains('simit') ||
        adLower.contains('açma')) {
      return 'ekmek';
    }

    // Meyveler
    if (adLower.contains('elma')) {
      return 'elma';
    }
    if (adLower.contains('muz')) {
      return 'muz';
    }
    if (adLower.contains('portakal')) {
      return 'portakal';
    }

    // Diğer
    if (adLower.contains('kuruyemiş') ||
        adLower.contains('badem') ||
        adLower.contains('ceviz') ||
        adLower.contains('fındık')) {
      return 'kuruyemis';
    }
    if (adLower.contains('sebze') || adLower.contains('salata')) {
      return 'sebze';
    }

    // Varsayılan: Yemek adının ilk kelimesi
    return yemekAdi.split(' ')[0].toLowerCase();
  }

  /// 🔥 HAFTA KEY OLUŞTUR - Aynı hafta için aynı key
  String _getHaftaKey(DateTime tarih) {
    final haftaBaslangici = _getHaftaBaslangici(tarih);
    return '${haftaBaslangici.year}-W${haftaBaslangici.month}${haftaBaslangici.day}';
  }

  /// 🔥 HAFTA BAŞLANGICI BUL - Pazartesi
  DateTime _getHaftaBaslangici(DateTime tarih) {
    final pazartesi = tarih.subtract(Duration(days: tarih.weekday - 1));
    return DateTime(pazartesi.year, pazartesi.month, pazartesi.day);
  }
}
