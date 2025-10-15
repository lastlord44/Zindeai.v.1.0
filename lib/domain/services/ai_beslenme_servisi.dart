// ============================================================================
// lib/domain/services/ai_beslenme_servisi.dart
// AI TABANLI BESLENME VE ANTRENMAN PLANI SERVİSİ
// ============================================================================

import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/makro_hedefleri.dart';
import '../entities/alternatif_besin_legacy.dart';
import '../../core/utils/app_logger.dart';

class AIBeslenmeServisi {
  final Random _random = Random();
  
  /// AI tabanlı günlük plan oluştur
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
  }) async {
    try {
      AppLogger.info('🤖 AI Beslenme Servisi: Plan oluşturuluyor...');
      
      // Şimdilik mock plan, sonra gerçek AI entegrasyonu
      final gunlukPlan = await _mockAIPlan(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: tarih ?? DateTime.now(),
      );
      
      final toleransKontrol = _toleransKontrolEt(gunlukPlan);
      AppLogger.info('📊 Tolerans Kontrolü: $toleransKontrol');
      
      return gunlukPlan;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Beslenme Servisi Hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Haftalık plan oluştur (7 günlük)
  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    required DateTime baslangicTarihi,
  }) async {
    try {
      AppLogger.info('🤖 AI Haftalık Plan: 7 günlük plan oluşturuluyor...');
      
      final planlar = <GunlukPlan>[];
      
      for (int gun = 0; gun < 7; gun++) {
        final planTarihi = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );
        
        final gunlukPlan = await gunlukPlanOlustur(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          kisitlamalar: kisitlamalar,
          tarih: planTarihi,
        );
        
        planlar.add(gunlukPlan);
      }
      
      AppLogger.success('✅ AI Haftalık Plan: 7 günlük plan tamamlandı');
      return planlar;
      
    } catch (e) {
      AppLogger.error('❌ AI haftalık plan hatası: $e');
      rethrow;
    }
  }

  /// 🔥 YENİ: Her besin için EN AZ 3 alternatif üret
  Future<List<Yemek>> alternatifleriGetir(Yemek yemek) async {
    try {
      AppLogger.info('🤖 AI Alternatif: ${yemek.ad} için EN AZ 3 alternatif üretiliyor...');
      
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
      AppLogger.info('🤖 AI Malzeme Alternatifi: "$besinAdi" (${miktar.toStringAsFixed(0)}$birim) için EN AZ 3 alternatif üretiliyor...');
      
      // 🔥 DİYETİSYEN ANALİZİ: Besin kategorisi belirle
      final kategori = _besinKategorisiBelirle(besinAdi);
      AppLogger.info('🔍 DİYETİSYEN ANALİZİ: ${miktar.toStringAsFixed(0)} ${birim} ${besinAdi}');
      AppLogger.info('✅ Kategori: $kategori');

      await Future.delayed(Duration(milliseconds: 300)); // Simülasyon

      final alternatifler = <AlternatifBesinLegacy>[];
      
      // 🔥 ÖĞÜN TİPİNE GÖRE AKILLI ALTERNATİFLER ÜRET
      final besinAlternatifleri = ogunTipi != null
          ? _ogunTipineGoreAlternatifListesi(ogunTipi)
          : _besinTipineGoreAlternatifler(besinAdi, kategori);
      
      AppLogger.info('🎯 Öğün Tipi Filtresi: ${ogunTipi?.name ?? "YOK"} -> ${besinAlternatifleri.length} alternatif');
      
      for (int i = 0; i < besinAlternatifleri.length && i < 4; i++) {
        final alternatifAdi = besinAlternatifleri[i];
        
        // Kalori ve makroları hesapla
        final besinVerisi = _besinVerileriniHesapla(alternatifAdi, miktar, birim);
        
        AppLogger.info('  📊 $besinAdi: ${besinVerisi['kalori'].toStringAsFixed(1)} kcal');
        AppLogger.info('  ✅ → ${besinVerisi['yeniMiktar'].toStringAsFixed(0)} ${besinVerisi['yeniBirim']} $alternatifAdi (${besinVerisi['kalori'].toStringAsFixed(1)} kcal)');
        
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
      
      AppLogger.success('✅ ${alternatifler.length} AI malzeme alternatifi oluşturuldu');
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
    if (adLower.contains('dana') || adLower.contains('kuzu') || adLower.contains('koyun')) {
      return 'ana_ogun_et_kirmizi';
    }
    if (adLower.contains('tavuk') || adLower.contains('hindi')) {
      return 'ana_ogun_et_beyaz';
    }
    if (adLower.contains('balık') || adLower.contains('somon') || adLower.contains('levrek') || adLower.contains('çupra')) {
      return 'ana_ogun_balik_yagsiz';
    }
    if (adLower.contains('köfte') || adLower.contains('kıyma')) {
      return 'ana_ogun_et_islenmis';
    }
    
    // Süt ürünleri
    if (adLower.contains('yumurta')) {
      return 'kahvalti_protein_yumurta';
    }
    if (adLower.contains('peynir') || adLower.contains('lor') || adLower.contains('labne')) {
      return 'kahvalti_sut_urunleri';
    }
    if (adLower.contains('yoğurt') || adLower.contains('kefir')) {
      return 'ara_ogun_sut_urunleri';
    }
    
    // Tahıllar
    if (adLower.contains('bulgur') || adLower.contains('pirinç') || adLower.contains('kinoa')) {
      return 'ana_ogun_tahil_karb';
    }
    if (adLower.contains('ekmek') || adLower.contains('pide')) {
      return 'kahvalti_tahil_ekmek';
    }
    
    // Sebzeler
    if (adLower.contains('domates') || adLower.contains('salatalık') || adLower.contains('biber')) {
      return 'ara_ogun_sebze_taze';
    }
    
    // Meyveler
    if (adLower.contains('elma') || adLower.contains('muz') || adLower.contains('portakal')) {
      return 'ara_ogun_meyve_taze';
    }
    
    // Kuruyemişler
    if (adLower.contains('ceviz') || adLower.contains('badem') || adLower.contains('fındık')) {
      return 'ara_ogun_kuruyemis';
    }
    
    return 'genel_besin';
  }

  /// Besin tipine göre alternatifler üret
  List<String> _besinTipineGoreAlternatifler(String besinAdi, String kategori) {
    final alternatifMap = {
      'ana_ogun_et_kirmizi': ['Kuzu pirzola', 'Dana bonfile', 'Kuzu kuşbaşı', 'Dana antrikot'],
      'ana_ogun_et_beyaz': ['Hindi göğsü', 'Tavuk but', 'Hindi schnitzel', 'Tavuk kanat'],
      'ana_ogun_balik_yagsiz': ['Çipura', 'Hamsi', 'Barbunya', 'Palamut'],
      'ana_ogun_et_islenmis': ['Hindi köfte', 'Tavuk köfte', 'Sebze köfte', 'Balık köfte'],
      
      'kahvalti_protein_yumurta': ['Bıldırcın yumurta', 'Organik yumurta', 'Köy yumurtası', 'Hindi yumurtası'],
      'kahvalti_sut_urunleri': ['Beyaz peynir', 'Kaşar', 'Cottage cheese', 'Ricotta'],
      'ara_ogun_sut_urunleri': ['Kefir', 'Ayran', 'Süzme yoğurt', 'Probiyotik yoğurt'],
      
      'ana_ogun_tahil_karb': ['Kinoa', 'Arpa', 'Yulaf', 'Tam buğday'],
      'kahvalti_tahil_ekmek': ['Çavdar ekmeği', 'Yulaf ekmeği', 'Tam buğday ekmeği', 'Lavash'],
      
      'ara_ogun_sebze_taze': ['Havuç', 'Turp', 'Roka', 'Marul'],
      'ara_ogun_meyve_taze': ['Armut', 'Kivi', 'Çilek', 'Üzüm'],
      'ara_ogun_kuruyemis': ['Fındık', 'Antep fıstığı', 'Kaju', 'Ay çekirdeği'],
      
      'genel_besin': ['Organik alternatif', 'Taze seçenek', 'Yerel ürün', 'Premium kalite'],
    };
    
    return alternatifMap[kategori] ?? alternatifMap['genel_besin']!;
  }

  /// 🔥 ÖĞÜN TİPİNE GÖRE UYGUN ALTERNATİFLER - YENİ METOT!
  /// Kahvaltıda balık önermesin, ara öğünde et önermesin vs.
  List<String> _ogunTipineGoreAlternatifListesi(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return [
          'Menemen', 'Omlet', 'Haşlanmış yumurta', 'Çırpılmış yumurta',
          'Beyaz peynir', 'Kaşar peyniri', 'Lor peyniri', 'Labne',
          'Süzme yoğurt', 'Kefir', 'Ayran',
          'Tam buğday ekmeği', 'Çavdar ekmeği', 'Yulaf ezmesi',
          'Bal', 'Reçel', 'Tereyağı', 'Zeytinyağı',
          'Domates', 'Salatalık', 'Roka', 'Maydanoz'
        ];
        
      case OgunTipi.ogle:
        return [
          'Izgara tavuk', 'Dana rosto', 'Köfte', 'Hindi schnitzel',
          'Balık fileto', 'Somon', 'Levrek', 'Çupra',
          'Bulgur pilavı', 'Pirinç pilavı', 'Makarna', 'Kinoa',
          'Mercimek çorbası', 'Şehriye çorbası', 'Ezogelin çorba',
          'Sebze güveç', 'Salata', 'Cacık', 'Yoğurt'
        ];
        
      case OgunTipi.aksam:
        return [
          'Fırında somon', 'Izgara balık', 'Dana et', 'Tavuk sote',
          'Hindi rosto', 'Sebze güveç', 'Et güveç',
          'Bulgur', 'Pirinç', 'Kinoa',
          'Brokoli', 'Karışık sebze', 'Salata',
          'Yoğurt', 'Cacık'
        ];
        
      case OgunTipi.araOgun1:
        return [
          'Yoğurt', 'Süzme yoğurt', 'Kefir',
          'Muz', 'Elma', 'Armut', 'Portakal', 'Kivi', 'Çilek',
          'Ceviz', 'Badem', 'Fındık', 'Antep fıstığı',
          'Bal', 'Granola'
        ];
        
      case OgunTipi.araOgun2:
        return [
          'Elma', 'Armut', 'Havuç', 'Salatalık', 'Domates',
          'Ceviz', 'Badem', 'Fındık', 'Kuruyemiş',
          'Yoğurt', 'Labne', 'Humus',
          'Çilek', 'Portakal'
        ];
        
      case OgunTipi.geceAtistirma:
        return [
          'Elma', 'Armut', 'Yoğurt', 'Badem', 'Ceviz',
          'Çilek', 'Havuç', 'Salatalık', 'Kuruyemiş',
          'Labne', 'Kefir', 'Çay', 'Bitki çayı'
        ];
        
      case OgunTipi.cheatMeal:
        return [
          'Pizza', 'Hamburger', 'Döner', 'Lahmacun', 'Pide',
          'Makarna', 'Pasta', 'Tatlı', 'Dondurma',
          'Kızarmış patates', 'Çikolata', 'Kurabiye'
        ];
    }
  }

  /// Besin verilerini hesapla
  Map<String, dynamic> _besinVerileriniHesapla(String besinAdi, double orijinalMiktar, String orijinalBirim) {
    // Besin değerlerini yaklaşık olarak hesapla (100g bazında)
    final besinDegerleri = _besin100gDegerleri(besinAdi);
    
    // Kalori eşdeğeri hesapla (aynı kalori için ne kadar gerekli)
    final orijinalBesinKaloriTahmini = besinDegerleri['kalori'] as double;
    final yeniKalori = besinDegerleri['kalori'] as double;
    
    final kaloriCarpani = orijinalBesinKaloriTahmini / yeniKalori;
    final yeniMiktar = (orijinalMiktar * kaloriCarpani).clamp(50.0, 200.0); // 50-200g arası
    
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

  /// Besin değerleri tablosu (100g bazında)
  Map<String, double> _besin100gDegerleri(String besinAdi) {
    final adLower = besinAdi.toLowerCase();
    
    // Et ve protein kaynakları
    if (adLower.contains('dana') || adLower.contains('kuzu')) {
      return {'kalori': 120, 'protein': 22, 'karb': 0, 'yag': 3.5};
    }
    if (adLower.contains('tavuk') || adLower.contains('hindi')) {
      return {'kalori': 110, 'protein': 23, 'karb': 0, 'yag': 2.5};
    }
    if (adLower.contains('balık') || adLower.contains('somon') || adLower.contains('çupra')) {
      return {'kalori': 115, 'protein': 20, 'karb': 0, 'yag': 4.0};
    }
    if (adLower.contains('köfte')) {
      return {'kalori': 140, 'protein': 18, 'karb': 3, 'yag': 6};
    }
    
    // Süt ürünleri
    if (adLower.contains('yumurta')) {
      return {'kalori': 155, 'protein': 13, 'karb': 1, 'yag': 11};
    }
    if (adLower.contains('peynir')) {
      return {'kalori': 270, 'protein': 18, 'karb': 3, 'yag': 20};
    }
    if (adLower.contains('yoğurt')) {
      return {'kalori': 60, 'protein': 10, 'karb': 4, 'yag': 1.5};
    }
    
    // Tahıllar
    if (adLower.contains('bulgur') || adLower.contains('pirinç')) {
      return {'kalori': 342, 'protein': 8, 'karb': 75, 'yag': 1};
    }
    if (adLower.contains('ekmek')) {
      return {'kalori': 265, 'protein': 9, 'karb': 49, 'yag': 3.2};
    }
    
    // Sebze ve meyveler
    if (adLower.contains('domates') || adLower.contains('salatalık')) {
      return {'kalori': 20, 'protein': 1, 'karb': 4, 'yag': 0.2};
    }
    if (adLower.contains('elma') || adLower.contains('muz')) {
      return {'kalori': 60, 'protein': 0.3, 'karb': 15, 'yag': 0.2};
    }
    
    // Kuruyemiş
    if (adLower.contains('ceviz') || adLower.contains('badem')) {
      return {'kalori': 600, 'protein': 15, 'karb': 7, 'yag': 60};
    }
    
    // Varsayılan (orta düzey protein kaynağı)
    return {'kalori': 120, 'protein': 20, 'karb': 2, 'yag': 4};
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

  /// Alternatif yemek oluştur helper
  Yemek _createAlternatif(
    Yemek orijinal,
    int index,
    String tip,
    double kaloriCarpan,
    double makroCarpan,
  ) {
    final turkYemekleri = [
      'İzgara Tavuk', 'Bulgur Pilavı', 'Mercimek Çorbası', 'Yoğurt',
      'Omlet', 'Sebze Sote', 'Balık Izgara', 'Pilav', 'Salata',
      'Şehriye Çorbası', 'Köfte', 'Fasulye', 'Nohut', 'Ezogelin',
    ];
    
    final rastgeleAd = turkYemekleri[_random.nextInt(turkYemekleri.length)];
    
    // 🔥 MALZEME DETAYLARINı ÇÖZÜLDÜ: Orijinalin malzemelerini dönüştür
    final alternatifMalzemeler = _orijinalMalzemeleriDonustur(
      orijinal.malzemeler,
      rastgeleAd,
      kaloriCarpan,
      index
    );
    
    return Yemek(
      id: '${orijinal.id}_alt$index',
      ad: '$rastgeleAd - $tip',
      ogun: orijinal.ogun,
      kalori: orijinal.kalori * kaloriCarpan,
      protein: orijinal.protein * makroCarpan,
      karbonhidrat: orijinal.karbonhidrat * (makroCarpan * 0.9),
      yag: orijinal.yag * (makroCarpan * 1.1),
      malzemeler: alternatifMalzemeler, // 🔥 GERÇEK MALZEMELER!
      hazirlamaSuresi: orijinal.hazirlamaSuresi + (index * 2),
      zorluk: orijinal.zorluk,
      etiketler: ['ai-alternatif', tip.toLowerCase(), 'pollinations-ready'],
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
      alternatifMalzemeler.addAll([
        'Baharat karışımı',
        'Zeytinyağı (1 YK)',
        'Tuz ve karabiber'
      ]);
    }
    
    return alternatifMalzemeler.take(6).toList(); // Max 6 malzeme
  }
  
  /// 🔥 Besin adını alternatife uygun şekilde dönüştür
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
      'tereyağı': ['zeytinyağı', 'hindistan cevizi yağı', 'badem yağı', 'avokado'],
      
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
    
    // Bulunamadıysa, orijinali geri döndür ama "alternatif" eki ekle
    final alternatifEkler = ['organik', 'taze', 'yerel', 'özel'];
    final ek = alternatifEkler[(alternatifIndex - 1) % alternatifEkler.length];
    return '$ek $orijinalBesin';
  }

  /// Mock AI plan (geliştirme amaçlı)
  Future<GunlukPlan> _mockAIPlan({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime tarih,
  }) async {
    
    // Makro dağılımı hesapla (öğün bazlı)
    final kahvaltiKalori = hedefKalori * 0.20; // %20
    final araOgun1Kalori = hedefKalori * 0.15; // %15  
    final ogleKalori = hedefKalori * 0.35; // %35
    final araOgun2Kalori = hedefKalori * 0.10; // %10
    final aksamKalori = hedefKalori * 0.20; // %20
    
    // 🔥 MEGA ÇEŞİTLİLİK HAVUZU - Her öğün için onlarca seçenek!
    final turkYemekleriKahvalti = [
      'Menemen + Tam Buğday Ekmek',
      'Yumurtalı Omlet + Beyaz Peynir',
      'Haşlanmış Yumurta + Domates + Salatalık',
      'Süzme Yoğurt + Bal + Ceviz + Muz',
      'Peynirli Omlet + Roka + Domates',
      'Çırpılmış Yumurta + Avokado + Ekmek',
      'Lor Peyniri + Domates + Maydanoz',
      'Labne + Zeytinyağı + Roka',
      'Sahanda Yumurta + Turşu + Peynir',
      'Yoğurt + Granola + Çilek',
      'Tereyağlı Omlet + Ispanak',
      'Peynir Tabağı + Bal + Ceviz',
    ];
    
    final turkYemekleriOgle = [
      'Izgara Tavuk + Bulgur Pilavı + Salata',
      'Köfte + Pirinç Pilavı + Cacık',
      'Balık Izgara + Sebze Güveci + Bulgur',
      'Mercimek Çorbası + Et Sote + Pilav',
      'Tavuk Şiş + Pirinç + Közlenmiş Biber',
      'Izgara Somon + Kinoa + Brokoli',
      'Dana Rosto + Bulgur + Mevsim Salatası',
      'Köfte + Sebzeli Pilav + Yoğurt',
      'Balık Fileto + Fırın Patates + Salata',
      'Hindi Schnitzel + Bulgur + Turp Salatası',
      'Izgara Et + Sebze + Pirinç',
      'Tavuk Sote + Makarna + Domates Salata',
    ];

    final turkYemekleriAksam = [
      'Fırında Somon + Sebze Güveci',
      'Izgara Tavuk + Bulgur + Salata',
      'Et Sote + Pirinç + Cacık',
      'Balık Fileto + Sebze + Bulgur',
      'Köfte + Patates Püresi + Turşu',
      'Hindi Rosto + Sebzeli Pilav',
      'Izgara Somon + Brokoli + Kinoa',
      'Tavuk Sote + Sebze + Bulgur',
      'Dana Et + Sebze Güveci + Pilav',
      'Balık Izgara + Fırın Sebze',
      'Et Güveci + Bulgur + Yoğurt',
      'Tavuk Fileto + Sebze + Pirinç',
    ];
    
    final araOgunSecenekleri1 = [
      'Yoğurt + Muz + Badem',
      'Elma + Ceviz + Bal',
      'Süzme Yoğurt + Çilek + Fındık',
      'Armut + Badem + Tarçın',
      'Kivi + Yoğurt + Granola',
      'Portakal + Ceviz + Bal',
      'Muz + Fıstık Ezmesi + Yulaf',
      'Üzüm + Peynir + Ceviz',
    ];
    
    final araOgunSecenekleri2 = [
      'Elma + Ceviz',
      'Havuç + Humus',
      'Salatalık + Labne',
      'Domates + Peynir',
      'Kuruyemiş Karışımı',
      'Yoğurt + Meyve',
      'Çilek + Badem',
      'Portakal + Fındık',
    ];
    
    final random = Random();
    
    // 🔥 HER ÇAĞRIDA FARKLI YEMEK ÜRET - MEGA ÇEŞİTLİLİK!
    final secilenKahvalti = turkYemekleriKahvalti[random.nextInt(turkYemekleriKahvalti.length)];
    final kahvalti = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_kahvalti',
      ad: secilenKahvalti,
      ogun: OgunTipi.kahvalti,
      kalori: kahvaltiKalori,
      protein: hedefProtein * 0.20,
      karbonhidrat: hedefKarb * 0.20,
      yag: hedefYag * 0.20,
      malzemeler: _detayliMalzemeler(secilenKahvalti),
      hazirlamaSuresi: 10 + random.nextInt(15),
      zorluk: Zorluk.kolay,
      etiketler: ['kahvaltı', 'protein', 'sağlıklı'],
    );
    
    final secilenAraOgun1 = araOgunSecenekleri1[random.nextInt(araOgunSecenekleri1.length)];
    final araOgun1 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_araogun1',
      ad: secilenAraOgun1,
      ogun: OgunTipi.araOgun1,
      kalori: araOgun1Kalori,
      protein: hedefProtein * 0.15,
      karbonhidrat: hedefKarb * 0.15,
      yag: hedefYag * 0.15,
      malzemeler: _detayliMalzemeler(secilenAraOgun1),
      hazirlamaSuresi: 3 + random.nextInt(7),
      zorluk: Zorluk.kolay,
      etiketler: ['ara-öğün', 'pratik', 'sağlıklı'],
    );
    
    final secilenOgle = turkYemekleriOgle[random.nextInt(turkYemekleriOgle.length)];
    final ogleYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_ogle',
      ad: secilenOgle,
      ogun: OgunTipi.ogle,
      kalori: ogleKalori,
      protein: hedefProtein * 0.35,
      karbonhidrat: hedefKarb * 0.35,
      yag: hedefYag * 0.35,
      malzemeler: _detayliMalzemeler(secilenOgle),
      hazirlamaSuresi: 25 + random.nextInt(20),
      zorluk: Zorluk.orta,
      etiketler: ['öğle', 'ana-yemek', 'doyurucu'],
    );
    
    final secilenAraOgun2 = araOgunSecenekleri2[random.nextInt(araOgunSecenekleri2.length)];
    final araOgun2 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_araogun2',
      ad: secilenAraOgun2,
      ogun: OgunTipi.araOgun2,
      kalori: araOgun2Kalori,
      protein: hedefProtein * 0.10,
      karbonhidrat: hedefKarb * 0.10,
      yag: hedefYag * 0.10,
      malzemeler: _detayliMalzemeler(secilenAraOgun2),
      hazirlamaSuresi: 2 + random.nextInt(5),
      zorluk: Zorluk.kolay,
      etiketler: ['ara-öğün', 'hafif', 'doğal'],
    );
    
    final secilenAksam = turkYemekleriAksam[random.nextInt(turkYemekleriAksam.length)];
    final aksamYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}_aksam',
      ad: secilenAksam,
      ogun: OgunTipi.aksam,
      kalori: aksamKalori,
      protein: hedefProtein * 0.20,
      karbonhidrat: hedefKarb * 0.20,
      yag: hedefYag * 0.20,
      malzemeler: _detayliMalzemeler(secilenAksam),
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
      toleranslar.add('Kalori (${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%)');
    }
    if (!plan.proteinToleranstaMi) {
      toleranslar.add('Protein (${plan.proteinSapmaYuzdesi.toStringAsFixed(1)}%)');
    }
    if (!plan.karbonhidratToleranstaMi) {
      toleranslar.add('Karbonhidrat (${plan.karbonhidratSapmaYuzdesi.toStringAsFixed(1)}%)');
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
      'Menemen + Tam Buğday Ekmek': ['Yumurta (2 adet)', 'Domates (1 adet)', 'Biber (1 adet)', 'Soğan (1/2 adet)', 'Tam buğday ekmek (2 dilim)'],
      'Yumurtalı Omlet + Beyaz Peynir': ['Yumurta (2 adet)', 'Beyaz peynir (50g)', 'Tereyağı (1 tsp)', 'Maydanoz'],
      'Haşlanmış Yumurta + Domates + Salatalık': ['Yumurta (2 adet)', 'Domates (1 orta)', 'Salatalık (1/2 adet)', 'Zeytinyağı (1 tsp)', 'Tuz', 'Maydanoz'],
      'Süzme Yoğurt + Bal + Ceviz + Muz': ['Süzme yoğurt (200g)', 'Bal (1 YK)', 'Ceviz (8 adet)', 'Muz (1 adet)'],
      'Peynirli Omlet + Roka + Domates': ['Yumurta (2 adet)', 'Kaşar peynir (30g)', 'Roka (1 demet)', 'Domates (1 adet)'],
      'Çırpılmış Yumurta + Avokado + Ekmek': ['Yumurta (2 adet)', 'Avokado (1/2 adet)', 'Tam buğday ekmek (2 dilim)', 'Tereyağı'],
      'Lor Peyniri + Domates + Maydanoz': ['Lor peyniri (100g)', 'Domates (1 adet)', 'Maydanoz (1 demet)', 'Zeytinyağı'],
      'Labne + Zeytinyağı + Roka': ['Labne (150g)', 'Roka (1 demet)', 'Zeytinyağı (1 YK)', 'Siyah zeytin (5 adet)'],
      'Sahanda Yumurta + Turşu + Peynir': ['Yumurta (2 adet)', 'Beyaz peynir (50g)', 'Karışık turşu', 'Tereyağı'],
      'Yoğurt + Granola + Çilek': ['Süzme yoğurt (150g)', 'Granola (30g)', 'Çilek (100g)', 'Bal (1 tsp)'],
      'Tereyağlı Omlet + Ispanak': ['Yumurta (2 adet)', 'Baby ıspanak (50g)', 'Tereyağı (1 YK)', 'Kaşar rendesi'],
      'Peynir Tabağı + Bal + Ceviz': ['Beyaz peynir (60g)', 'Kaşar (40g)', 'Ceviz (6 adet)', 'Bal (1 tsp)', 'Domates'],

      // 🍽️ ÖĞLE YEMEKLERİ - TÜM VARİASYONLAR
      'Izgara Tavuk + Bulgur Pilavı + Salata': ['Tavuk göğsü (150g)', 'Bulgur (80g)', 'Karışık yeşillik', 'Zeytinyağı (1 YK)', 'Limon'],
      'Köfte + Pirinç Pilavı + Cacık': ['Dana köfte (4 adet)', 'Pirinç (100g)', 'Yoğurt (150g)', 'Salatalık (1 adet)', 'Nane', 'Sarımsak'],
      'Balık Izgara + Sebze Güveci + Bulgur': ['Somon (120g)', 'Patlıcan (1 adet)', 'Kabak (1 adet)', 'Bulgur (60g)', 'Zeytinyağı'],
      'Mercimek Çorbası + Et Sote + Pilav': ['Kırmızı mercimek (100g)', 'Dana et (120g)', 'Pirinç (80g)', 'Soğan', 'Havuç', 'Baharat'],
      'Tavuk Şiş + Pirinç + Közlenmiş Biber': ['Tavuk but (150g)', 'Pirinç (80g)', 'Kırmızı biber (2 adet)', 'Patlıcan (1 adet)', 'Baharat'],
      'Izgara Somon + Kinoa + Brokoli': ['Somon fileto (130g)', 'Kinoa (70g)', 'Brokoli (150g)', 'Zeytinyağı', 'Limon'],
      'Dana Rosto + Bulgur + Mevsim Salatası': ['Dana rosto (120g)', 'Bulgur (80g)', 'Karışık salata', 'Domates', 'Salatalık'],
      'Köfte + Sebzeli Pilav + Yoğurt': ['Dana köfte (4 adet)', 'Pirinç (80g)', 'Havuç (1 adet)', 'Bezelye', 'Yoğurt (100g)'],
      'Balık Fileto + Fırın Patates + Salata': ['Levrek fileto (130g)', 'Patates (2 orta)', 'Yeşil salata', 'Zeytinyağı', 'Kekik'],
      'Hindi Schnitzel + Bulgur + Turp Salatası': ['Hindi göğsü (130g)', 'Bulgur (70g)', 'Turp (3 adet)', 'Maydanoz', 'Limon'],
      'Izgara Et + Sebze + Pirinç': ['Dana bonfile (120g)', 'Karışık sebze', 'Pirinç (80g)', 'Zeytinyağı', 'Baharat'],
      'Tavuk Sote + Makarna + Domates Salata': ['Tavuk göğsü (140g)', 'Tam buğday makarna (80g)', 'Domates (2 adet)', 'Fesleğen'],

      // 🌅 AKŞAM YEMEKLERİ - TÜM VARİASYONLAR
      'Fırında Somon + Sebze Güveci': ['Somon fileto (120g)', 'Patlıcan (1 adet)', 'Kabak (1 adet)', 'Domates (2 adet)', 'Zeytinyağı'],
      'Izgara Tavuk + Bulgur + Salata': ['Tavuk göğsü (120g)', 'Bulgur (60g)', 'Yeşil salata', 'Domates', 'Limon'],
      'Et Sote + Pirinç + Cacık': ['Dana et (100g)', 'Pirinç (80g)', 'Yoğurt (100g)', 'Salatalık', 'Nane', 'Sarımsak'],
      'Balık Fileto + Sebze + Bulgur': ['Çupra fileto (120g)', 'Karışık sebze (200g)', 'Bulgur (60g)', 'Zeytinyağı', 'Kekik'],
      'Köfte + Patates Püresi + Turşu': ['Dana köfte (3 adet)', 'Patates (3 orta)', 'Süt (50ml)', 'Tereyağı', 'Karışık turşu'],
      'Hindi Rosto + Sebzeli Pilav': ['Hindi göğsü (120g)', 'Pirinç (70g)', 'Havuç (1 adet)', 'Bezelye', 'Soğan'],
      'Izgara Somon + Brokoli + Kinoa': ['Somon (120g)', 'Brokoli (150g)', 'Kinoa (60g)', 'Zeytinyağı', 'Limon'],
      'Tavuk Sote + Sebze + Bulgur': ['Tavuk göğsü (120g)', 'Patlıcan (1 adet)', 'Biber (1 adet)', 'Bulgur (60g)', 'Zeytinyağı'],
      'Dana Et + Sebze Güveci + Pilav': ['Dana kuşbaşı (100g)', 'Karışık sebze (200g)', 'Pirinç (70g)', 'Zeytinyağı'],
      'Balık Izgara + Fırın Sebze': ['Levrek (120g)', 'Kabak (1 adet)', 'Patlıcan (1 adet)', 'Biber (1 adet)', 'Kekik'],
      'Et Güveci + Bulgur + Yoğurt': ['Dana et (100g)', 'Soğan (1 adet)', 'Bulgur (60g)', 'Yoğurt (100g)', 'Baharat'],
      'Tavuk Fileto + Sebze + Pirinç': ['Tavuk fileto (120g)', 'Brokoli (100g)', 'Havuç (1 adet)', 'Pirinç (70g)'],

      // 🍎 ARA ÖĞÜN 1 - TÜM VARİASYONLAR
      'Yoğurt + Muz + Badem': ['Süzme yoğurt (150g)', 'Muz (1 adet)', 'Badem (10 adet)'],
      'Elma + Ceviz + Bal': ['Elma (1 orta)', 'Ceviz (6 adet)', 'Bal (1 tsp)'],
      'Süzme Yoğurt + Çilek + Fındık': ['Süzme yoğurt (150g)', 'Çilek (100g)', 'Fındık (15 adet)'],
      'Armut + Badem + Tarçın': ['Armut (1 orta)', 'Badem (12 adet)', 'Tarçın (1 tsp)'],
      'Kivi + Yoğurt + Granola': ['Kivi (2 adet)', 'Yoğurt (100g)', 'Granola (20g)'],
      'Portakal + Ceviz + Bal': ['Portakal (1 orta)', 'Ceviz (8 adet)', 'Bal (1 tsp)'],
      'Muz + Fıstık Ezmesi + Yulaf': ['Muz (1 adet)', 'Fıstık ezmesi (1 YK)', 'Yulaf ezmesi (20g)'],
      'Üzüm + Peynir + Ceviz': ['Üzüm (100g)', 'Beyaz peynir (40g)', 'Ceviz (5 adet)'],

      // 🥕 ARA ÖĞÜN 2 - TÜM VARİASYONLAR
      'Elma + Ceviz': ['Elma (1 orta)', 'Ceviz (5 adet)'],
      'Havuç + Humus': ['Havuç (1 büyük)', 'Humus (50g)', 'Limon suyu'],
      'Salatalık + Labne': ['Salatalık (1 adet)', 'Labne (60g)', 'Nane'],
      'Domates + Peynir': ['Domates (1 büyük)', 'Beyaz peynir (50g)', 'Fesleğen'],
      'Kuruyemiş Karışımı': ['Badem (5 adet)', 'Ceviz (3 adet)', 'Fındık (8 adet)', 'Kuru üzüm (1 YK)'],
      'Yoğurt + Meyve': ['Yoğurt (150g)', 'Çilek (50g)', 'Muz (1/2 adet)'],
      'Çilek + Badem': ['Çilek (100g)', 'Badem (10 adet)'],
      'Portakal + Fındık': ['Portakal (1 orta)', 'Fındık (12 adet)'],
    };
    
    // AKILLI EŞLEŞTİRME: Tam eşleşme yoksa benzer olanı bul
    String eslesenAnahtar = '';
    
    // Tam eşleşme kontrolü
    if (malzemelerHaritasi.containsKey(yemekAdi)) {
      eslesenAnahtar = yemekAdi;
    } else {
      // Kısmi eşleşme ara (ilk kelime bazında)
      final yemekKelimeler = yemekAdi.toLowerCase().split(' ');
      for (final anahtar in malzemelerHaritasi.keys) {
        final anahtarKelimeler = anahtar.toLowerCase().split(' ');
        if (yemekKelimeler.any((kelime) => anahtarKelimeler.contains(kelime))) {
          eslesenAnahtar = anahtar;
          break;
        }
      }
    }
    
    if (eslesenAnahtar.isNotEmpty) {
      return malzemelerHaritasi[eslesenAnahtar]!;
    }
    
    // Son çare: Yemek tipine göre akıllı malzeme üret
    return _akilliBazMalzeme(yemekAdi);
  }
  
  /// 🧠 Akıllı baz malzeme üretici
  List<String> _akilliBazMalzeme(String yemekAdi) {
    final adLower = yemekAdi.toLowerCase();
    
    // Protein bazlı yemekler
    if (adLower.contains('tavuk')) {
      return ['Tavuk göğsü (120-150g)', 'Zeytinyağı (1 tsp)', 'Baharat karışımı', 'Sebze garnitür'];
    }
    if (adLower.contains('balık') || adLower.contains('somon')) {
      return ['Balık fileto (120g)', 'Limon (1/2 adet)', 'Zeytinyağı (1 tsp)', 'Kekik'];
    }
    if (adLower.contains('köfte') || adLower.contains('et')) {
      return ['Dana eti (100-120g)', 'Soğan (1/2 adet)', 'Baharat', 'Zeytinyağı'];
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
    if (adLower.contains('meyve') || adLower.contains('çilek') || adLower.contains('elma')) {
      return ['Taze meyve (100-150g)', 'Kuruyemiş (5-10 adet)', 'Bal (isteğe bağlı)'];
    }
    
    // Varsayılan dengeli öğün
    return [
      'Ana protein kaynağı (120g)',
      'Karbonhidrat (80g)',
      'Taze sebze garnitür',
      'Sağlıklı yağ (1 tsp)'
    ];
  }
}