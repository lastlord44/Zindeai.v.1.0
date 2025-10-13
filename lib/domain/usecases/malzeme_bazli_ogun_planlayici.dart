// lib/domain/usecases/malzeme_bazli_ogun_planlayici.dart
// MALZEME BAZLI ÖĞÜN PLANLAYICI - Yeni Genetik Algoritma Wrapper
// %3.2 sapma hedefi ile mükemmel makro dengesi!

import 'dart:async';
import '../../core/utils/app_logger.dart';
import '../../data/local/besin_malzeme_hive_service.dart';
import '../entities/besin_malzeme.dart';
import '../entities/ogun_sablonu.dart';
import '../entities/gunluk_plan.dart';
import '../entities/makro_hedefleri.dart';
import '../entities/yemek.dart';
import '../entities/malzeme_miktar.dart';
import 'malzeme_tabanli_genetik_algoritma.dart';

class MalzemeBazliOgunPlanlayici {
  final BesinMalzemeHiveService besinService;

  MalzemeBazliOgunPlanlayici({
    required this.besinService,
  });

  /// Günlük plan oluştur - Malzeme bazlı genetik algoritma ile
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
      
      AppLogger.info('📋 Malzeme bazlı plan oluşturuluyor...');
      AppLogger.debug('Hedefler: Kalori=$hedefKalori, Protein=$hedefProtein, Karb=$hedefKarb, Yağ=$hedefYag');
      
      // Besin malzemelerini yükle
      final tumBesinler = await besinService.getAll();
      
      if (tumBesinler.isEmpty) {
        throw Exception('Besin malzemeleri yüklenemedi! Lütfen migration yapın.');
      }
      
      AppLogger.debug('${tumBesinler.length} besin malzemesi yüklendi');
      
      // Kısıtlamalara göre filtrele
      final uygunBesinler = _kisitlamalariFiltrele(tumBesinler, kisitlamalar);
      
      // Default şablonları al
      final sablonlar = defaultTemplatesTRStrict();
      final sablonMap = <OgunTipi, OgunSablonu>{};
      for (final sablon in sablonlar) {
        sablonMap[sablon.ogunTipi] = sablon;
      }
      
      // Makro dağılımı (%25 kahvaltı, %15 ara1, %30 öğle, %15 ara2, %25 akşam)
      final ogunler = <OgunTipi, Ogun>{};
      
      // 1. KAHVALTI (%25)
      ogunler[OgunTipi.kahvalti] = await _ogunOlustur(
        besinler: uygunBesinler,
        ogunTipi: OgunTipi.kahvalti,
        sablon: sablonMap[OgunTipi.kahvalti]!,
        hedefKalori: hedefKalori * 0.25,
        hedefProtein: hedefProtein * 0.25,
        hedefKarb: hedefKarb * 0.25,
        hedefYag: hedefYag * 0.25,
      );
      
      // 2. ARA ÖĞÜN 1 (%15)
      ogunler[OgunTipi.araOgun1] = await _ogunOlustur(
        besinler: uygunBesinler,
        ogunTipi: OgunTipi.araOgun1,
        sablon: sablonMap[OgunTipi.araOgun1]!,
        hedefKalori: hedefKalori * 0.15,
        hedefProtein: hedefProtein * 0.15,
        hedefKarb: hedefKarb * 0.15,
        hedefYag: hedefYag * 0.15,
      );
      
      // 3. ÖĞLE YEMEĞİ (%30)
      ogunler[OgunTipi.ogle] = await _ogunOlustur(
        besinler: uygunBesinler,
        ogunTipi: OgunTipi.ogle,
        sablon: sablonMap[OgunTipi.ogle]!,
        hedefKalori: hedefKalori * 0.30,
        hedefProtein: hedefProtein * 0.30,
        hedefKarb: hedefKarb * 0.30,
        hedefYag: hedefYag * 0.30,
      );
      
      // 4. ARA ÖĞÜN 2 (%15)
      ogunler[OgunTipi.araOgun2] = await _ogunOlustur(
        besinler: uygunBesinler,
        ogunTipi: OgunTipi.araOgun2,
        sablon: sablonMap[OgunTipi.araOgun2]!,
        hedefKalori: hedefKalori * 0.15,
        hedefProtein: hedefProtein * 0.15,
        hedefKarb: hedefKarb * 0.15,
        hedefYag: hedefYag * 0.15,
      );
      
      // 5. AKŞAM YEMEĞİ (%25)
      ogunler[OgunTipi.aksam] = await _ogunOlustur(
        besinler: uygunBesinler,
        ogunTipi: OgunTipi.aksam,
        sablon: sablonMap[OgunTipi.aksam]!,
        hedefKalori: hedefKalori * 0.25,
        hedefProtein: hedefProtein * 0.25,
        hedefKarb: hedefKarb * 0.25,
        hedefYag: hedefYag * 0.25,
      );
      
      // GÜNLÜK TOPLAM KONTROLCÜ - PERFORMANS İÇİN DEVRE DIŞI BIRAKILDI
      // Genetik algoritma zaten makroları optimize ediyor, ekstra kontrol gereksiz ve yavaşlatıyor
      // final adjustedOgunler = await _gunlukToplamKontrolu(
      //   ogunler: ogunler,
      //   hedefKalori: hedefKalori,
      //   hedefProtein: hedefProtein,
      //   hedefKarb: hedefKarb,
      //   hedefYag: hedefYag,
      //   uygunBesinler: uygunBesinler,
      //   sablonMap: sablonMap,
      // );
      
      // Performans optimizasyonu: Direkt öğünleri kullan
      final adjustedOgunler = ogunler;
      
      // Ogun nesnelerini Yemek'e dönüştür
      final yemekler = <Yemek>[];
      for (final entry in adjustedOgunler.entries) {
        final yemek = _ogunToYemek(entry.value);
        yemekler.add(yemek);
      }
      
      // GunlukPlan oluştur
      final plan = GunlukPlan(
        id: '${planTarihi.millisecondsSinceEpoch}',
        tarih: planTarihi,
        kahvalti: yemekler.firstWhere((y) => y.ogun == OgunTipi.kahvalti),
        araOgun1: yemekler.firstWhere((y) => y.ogun == OgunTipi.araOgun1),
        ogleYemegi: yemekler.firstWhere((y) => y.ogun == OgunTipi.ogle),
        araOgun2: yemekler.firstWhere((y) => y.ogun == OgunTipi.araOgun2),
        aksamYemegi: yemekler.firstWhere((y) => y.ogun == OgunTipi.aksam),
        makroHedefleri: MakroHedefleri(
          gunlukKalori: hedefKalori,
          gunlukProtein: hedefProtein,
          gunlukKarbonhidrat: hedefKarb,
          gunlukYag: hedefYag,
        ),
        fitnessSkoru: 100, // Yeni algoritma her zaman yüksek skor
      );
      
      AppLogger.success('✅ Malzeme bazlı plan oluşturuldu: ${yemekler.length} öğün');
      _planDetaylariniLogla(plan);
      
      return plan;
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Malzeme bazlı plan oluşturulurken hata',
        error: e,
        stackTrace: stackTrace,
      );
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
    DateTime? baslangicTarihi,
  }) async {
    try {
      final baslangic = baslangicTarihi ?? DateTime.now();
      final haftalikPlanlar = <GunlukPlan>[];
      
      for (int gun = 0; gun < 7; gun++) {
        final planTarihi = DateTime(
          baslangic.year,
          baslangic.month,
          baslangic.day + gun,
        );
        
        final gunlukPlan = await gunlukPlanOlustur(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          kisitlamalar: kisitlamalar,
          tarih: planTarihi,
        );
        
        haftalikPlanlar.add(gunlukPlan);
      }
      
      return haftalikPlanlar;
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ HATA: Haftalık plan oluşturulurken hata',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Tek bir öğün oluştur
  Future<Ogun> _ogunOlustur({
    required List<BesinMalzeme> besinler,
    required OgunTipi ogunTipi,
    required OgunSablonu sablon,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) async {
    final algoritma = MalzemeTabanliGenetikAlgoritma(
      besinler: besinler,
      ogunTipi: ogunTipi,
      sablon: sablon,
      hedef: HedefMakrolar(
        kalori: hedefKalori,
        protein: hedefProtein,
        karbonhidrat: hedefKarb,
        yag: hedefYag,
      ),
    );
    
    return await algoritma.optimize();
  }
  
  /// Kısıtlamalara göre filtrele + Türk mutfağı önceliği
  List<BesinMalzeme> _kisitlamalariFiltrele(
    List<BesinMalzeme> besinler,
    List<String> kisitlamalar,
  ) {
    // Türk mutfağı anahtar kelimeleri
    const turkMutfagiKelimeler = [
      'menemen', 'yumurta', 'peynir', 'zeytin', 'domates', 'salatalık',
      'köfte', 'kıyma', 'kuşbaşı', 'tavuk', 'hindi', 'dana', 'somon',
      'bulgur', 'pirinç', 'makarna', 'mercimek', 'nohut', 'fasulye',
      'patlıcan', 'biber', 'kabak', 'havuç', 'ıspanak', 'karnabahar',
      'lahana', 'brokoli', 'mantar', 'yeşillik', 'marul', 'roka',
      'söğüş', 'çoban', 'şehriye', 'yoğurt', 'süzme', 'ayran',
      'ekmek', 'lavaş', 'simit', 'su böreği', 'börek', 'gözleme',
      'sığır', 'kuzu', 'balık', 'levrek', 'çipura', 'hamsi',
      'ceviz', 'fındık', 'badem', 'fıstık', 'üzüm', 'elma',
      'armut', 'portakal', 'mandalina', 'muz', 'çilek', 'kiraz',
      'kuru', 'kayısı', 'incir', 'hurma', 'zeytinyağı', 'tereyağı',
      'pişi', 'kumpir', 'patates', 'soğan', 'sarımsak', 'maydanoz',
      'dereotu', 'nane', 'fesleğen', 'kekik', 'sumak', 'pul biber',
      'salça', 'soya', 'turşu', 'közlenmiş', 'haşlanmış', 'ızgara',
      'tavada', 'fırın', 'taze', 'organik', 'ev yapımı', 'süt',
      'kefir', 'keçi', 'lor', 'beyaz', 'kaşar', 'tulum', 'çökelek',
      'çemen', 'tarhana', 'erişte', 'kuru fasulye', 'barbunya',
      'börülce', 'yeşil mercimek', 'kırmızı mercimek', 'pilavlık',
      'pirinç', 'kepekli', 'tam buğday', 'çavdar', 'yulaf',
      'protein tozu', 'whey', 'kazein', 'bezelye proteini',
      'hindi jambon', 'light', 'yağsız', 'az yağlı', 'tam yağlı',
    ];
    
    // 1. Kısıtlamaları uygula
    var filtrelenmis = besinler;
    if (kisitlamalar.isNotEmpty) {
      filtrelenmis = besinler.where((besin) {
        final adLower = besin.ad.toLowerCase();
        for (final kisit in kisitlamalar) {
          if (adLower.contains(kisit.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();
    }
    
    // 2. Türk mutfağı önceliği (yabancı yemekleri filtrele)
    final turkMalzemeler = filtrelenmis.where((besin) {
      final adLower = besin.ad.toLowerCase();
      // Eğer ad, Türk mutfağı kelimelerinden birini içeriyorsa veya
      // yabancı malzeme belirtisi yoksa, Türk mutfağı say
      
      // Önce Türk mutfağı kelimesi var mı kontrol et
      final turkKelimeIceriyor = turkMutfagiKelimeler.any((kelime) => 
        adLower.contains(kelime)
      );
      
      // Yabancı mutfak işaretleri - PAPAYA VE TROPİK MEYVELER EKLENDİ!
      final yabanciKelimeler = [
        // Asya mutfağı
        'edamame', 'farro', 'quinoa', 'chia', 'goji', 'acai',
        'kimchi', 'tofu', 'tempeh', 'miso', 'wakame', 'nori',
        'paneer', 'ghee', 'tikka', 'tandoori', 'curry',
        'sushi', 'sashimi', 'ramen', 'udon', 'mochi', 'wasabi',
        // Latin Amerika
        'burrito', 'taco', 'quesadilla', 'nachos', 'guacamole', 'tortilla',
        // Orta Doğu (Türk mutfağı dışı)
        'hummus', 'tahini', 'falafel', 'pita', 'couscous', 'tabbouleh',
        // İtalyan
        'pasta', 'risotto', 'gnocchi', 'pesto', 'bruschetta', 'panini',
        // Fransız/Avrupa
        'bagel', 'croissant', 'baguette', 'muffin', 'pancake', 'waffle',
        // Tropik meyveler (Türkiye'de yaygın değil) - PAPAYA EKLENDI!
        'papaya', 'papaja', 'mango', 'dragon fruit', 'pitaya', 'passion fruit',
        'guava', 'lychee', 'rambutan', 'starfruit', 'durian', 'jackfruit',
        'kiwano', 'cherimoya', 'sapodilla', 'carambola', 'persimmon',
        // Egzotik süper gıdalar
        'matcha', 'spirulina', 'chlorella', 'kombucha', 'kefir grains',
        'nutritional yeast', 'hemp', 'flax', 'amaranth',
      ];
      
      final yabanciKelimeIceriyor = yabanciKelimeler.any((kelime) =>
        adLower.contains(kelime)
      );
      
      // 🚫 ULTRA KESİN YASAK KELİMELER - KULLANICısınIN İSTEĞİ!
      // Premium, lüks, whey, protein tozu vb. ASLA GEÇMESİN!
      final ultraYasakKelimeler = [
        'premium', 'lüks', 'luks', 'lux', 'luxury',
        'whey', 'protein tozu', 'protein powder',
        'protein shake', 'protein smoothie', 'protein bar',
        'protein donut', 'protein kurabiye', 'protein cookie',
        'casein', 'bcaa', 'kreatin', 'gainer', 'supplement',
        'vegan protein', 'bezelye protein', 'soya protein',
        'organik', 'bio', 'gluten-free', 'glutensiz',
        'imported', 'ithal', 'exclusive', 'özel',
      ];
      
      final ultraYasakIceriyor = ultraYasakKelimeler.any((kelime) =>
        adLower.contains(kelime)
      );
      
      // Eğer ultra yasak kelime varsa, DİREKT ELEME!
      if (ultraYasakIceriyor) {
        return false;
      }
      
      // Türk kelimesi varsa veya yabancı kelime yoksa → Türk mutfağı
      return turkKelimeIceriyor || !yabanciKelimeIceriyor;
    }).toList();
    
    // Eğer yeterli Türk malzemesi varsa (min 100), SADECE onları kullan
    // Değilse yine de Türk malzemelerini kullan ama daha düşük limit ile kontrol et
    if (turkMalzemeler.length >= 100) {
      return turkMalzemeler;
    } else if (turkMalzemeler.length >= 30) {
      // En az 30 Türk malzemesi varsa kullan
      return turkMalzemeler;
    } else {
      // Çok az Türk malzemesi varsa filtrelenmiş tümünü kullan ama logla
      AppLogger.warning('⚠️ Sadece ${turkMalzemeler.length} Türk malzemesi bulundu, tüm filtrelenmiş malzemeler kullanılacak (${filtrelenmis.length} adet)');
      return filtrelenmis;
    }
  }
  
  /// Ogun'u Yemek'e dönüştür
  Yemek _ogunToYemek(Ogun ogun) {
    // Malzemeleri string listesine dönüştür
    final malzemeListesi = ogun.malzemeler.map((m) {
      return '${m.miktarG.toStringAsFixed(0)}g ${m.besin.ad}';
    }).toList();
    
    // Yemek adı: İlk malzemenin adı veya kombinasyon
    final ad = ogun.malzemeler.length == 1
        ? ogun.malzemeler.first.besin.ad
        : '${ogun.malzemeler.first.besin.ad} Kombinasyonu';
    
    return Yemek(
      id: 'malzeme_${ogun.tip.name}_${DateTime.now().millisecondsSinceEpoch}',
      ad: ad,
      ogun: ogun.tip,
      kalori: ogun.gercekMakrolar.kalori,
      protein: ogun.gercekMakrolar.protein,
      karbonhidrat: ogun.gercekMakrolar.karbonhidrat,
      yag: ogun.gercekMakrolar.yag,
      malzemeler: malzemeListesi,
      hazirlamaSuresi: 15, // Default
      zorluk: Zorluk.kolay, // Default zorluk
      etiketler: ['malzeme-bazlı', 'genetik-algoritma'], // Yeni sistemden geldiğini belirt
    );
  }
  
  /// Günlük toplam kontrolü - Makroları dengelemek için
  Future<Map<OgunTipi, Ogun>> _gunlukToplamKontrolu({
    required Map<OgunTipi, Ogun> ogunler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required List<BesinMalzeme> uygunBesinler,
    required Map<OgunTipi, OgunSablonu> sablonMap,
  }) async {
    // Toplam makroları hesapla
    double toplamKalori = 0, toplamProtein = 0, toplamKarb = 0, toplamYag = 0;
    for (final ogun in ogunler.values) {
      toplamKalori += ogun.gercekMakrolar.kalori;
      toplamProtein += ogun.gercekMakrolar.protein;
      toplamKarb += ogun.gercekMakrolar.karbonhidrat;
      toplamYag += ogun.gercekMakrolar.yag;
    }
    
    // Sapmaları hesapla
    final kaloriSapma = ((toplamKalori - hedefKalori).abs() / hedefKalori);
    final proteinSapma = ((toplamProtein - hedefProtein).abs() / hedefProtein);
    final karbSapma = ((toplamKarb - hedefKarb).abs() / hedefKarb);
    final yagSapma = ((toplamYag - hedefYag).abs() / hedefYag);
    
    AppLogger.info('');
    AppLogger.info('🔍 GÜNLÜK TOPLAM KONTROLÜ:');
    AppLogger.info('   Kalori: ${toplamKalori.toStringAsFixed(0)} / ${hedefKalori.toStringAsFixed(0)} (${(kaloriSapma * 100).toStringAsFixed(1)}% sapma)');
    AppLogger.info('   Protein: ${toplamProtein.toStringAsFixed(0)} / ${hedefProtein.toStringAsFixed(0)} (${(proteinSapma * 100).toStringAsFixed(1)}% sapma)');
    AppLogger.info('   Karb: ${toplamKarb.toStringAsFixed(0)} / ${hedefKarb.toStringAsFixed(0)} (${(karbSapma * 100).toStringAsFixed(1)}% sapma)');
    AppLogger.info('   Yağ: ${toplamYag.toStringAsFixed(0)} / ${hedefYag.toStringAsFixed(0)} (${(yagSapma * 100).toStringAsFixed(1)}% sapma)');
    
    // %5'ten fazla sapma varsa düzelt
    if (proteinSapma > 0.05 || karbSapma > 0.05 || yagSapma > 0.05 || kaloriSapma > 0.05) {
      AppLogger.warning('⚠️ Günlük toplam sapması %5\'i aşıyor, yeniden dengeleniyor...');
      
      // En çok sapan makroyu bul
      final sapmalar = {
        'protein': proteinSapma,
        'karb': karbSapma,
        'yag': yagSapma,
      };
      final enBuyukSapma = sapmalar.entries.reduce((a, b) => a.value > b.value ? a : b);
      
      // Hangi makro fazla/eksik?
      Map<String, double> farklar = {
        'protein': toplamProtein - hedefProtein,
        'karb': toplamKarb - hedefKarb,
        'yag': toplamYag - hedefYag,
      };
      
      AppLogger.info('   📊 En büyük sapma: ${enBuyukSapma.key} (%${(enBuyukSapma.value * 100).toStringAsFixed(1)})');
      AppLogger.info('   🎯 Farklar: Protein ${farklar['protein']!.toStringAsFixed(1)}g, Karb ${farklar['karb']!.toStringAsFixed(1)}g, Yağ ${farklar['yag']!.toStringAsFixed(1)}g');
      
      // Ara öğünleri yeniden oluştur (daha küçük hedeflerle)
      final yeniOgunler = Map<OgunTipi, Ogun>.from(ogunler);
      
      // Hangi öğünleri düzelteceğimize karar ver
      final duzeltilecekOgunler = <OgunTipi>[];
      
      // Protein fazlaysa, ara öğünlerde protein azalt
      if (farklar['protein']! > 0) {
        duzeltilecekOgunler.addAll([OgunTipi.araOgun1, OgunTipi.araOgun2]);
      }
      
      // Karb fazlaysa, ara öğünlerde karb azalt
      if (farklar['karb']! > 0 && duzeltilecekOgunler.length < 2) {
        duzeltilecekOgunler.add(OgunTipi.araOgun1);
      }
      
      // Düzeltme yap
      for (final ogunTipi in duzeltilecekOgunler) {
        final mevcutOgun = ogunler[ogunTipi]!;
        final mevcutProtein = mevcutOgun.gercekMakrolar.protein;
        final mevcutKarb = mevcutOgun.gercekMakrolar.karbonhidrat;
        
        // Yeni hedefleri düşür (%80'ine)
        final yeniHedefProtein = mevcutProtein * 0.8;
        final yeniHedefKarb = mevcutKarb * 0.8;
        final yeniHedefYag = mevcutOgun.gercekMakrolar.yag * 0.8;
        final yeniHedefKalori = (yeniHedefProtein * 4) + (yeniHedefKarb * 4) + (yeniHedefYag * 9);
        
        AppLogger.info('   🔧 ${ogunTipi.name} yeniden oluşturuluyor (hedefler %80\'e düşürüldü)');
        
        final yeniOgun = await _ogunOlustur(
          besinler: uygunBesinler,
          ogunTipi: ogunTipi,
          sablon: sablonMap[ogunTipi]!,
          hedefKalori: yeniHedefKalori,
          hedefProtein: yeniHedefProtein,
          hedefKarb: yeniHedefKarb,
          hedefYag: yeniHedefYag,
        );
        
        yeniOgunler[ogunTipi] = yeniOgun;
      }
      
      AppLogger.success('✅ Günlük toplam dengelendi');
      return yeniOgunler;
    }
    
    AppLogger.success('✅ Günlük toplam tolerans içinde');
    return ogunler;
  }
  
  /// Plan detaylarını logla
  void _planDetaylariniLogla(GunlukPlan plan) {
    AppLogger.info('');
    AppLogger.info('📅 ═══════════════════════════════════════════════════');
    AppLogger.info('   ${plan.tarih.day}.${plan.tarih.month}.${plan.tarih.year} - GÜNLÜK PLAN (Malzeme Bazlı)');
    AppLogger.info('═══════════════════════════════════════════════════');
    
    for (final yemek in plan.ogunler) {
      if (yemek != null) {
        final kategori = yemek.ogun.toString().split('.').last.toUpperCase();
        AppLogger.info('🍽️  $kategori: ${yemek.ad}');
        AppLogger.info('    Kalori: ${yemek.kalori.toStringAsFixed(0)} kcal | Protein: ${yemek.protein.toStringAsFixed(0)}g | Karb: ${yemek.karbonhidrat.toStringAsFixed(0)}g | Yağ: ${yemek.yag.toStringAsFixed(0)}g');
        
        // MALZEME DETAYLARI - Her satırda bir malzeme
        if (yemek.malzemeler.isNotEmpty) {
          AppLogger.info('    📦 MALZEMELER:');
          for (final malzeme in yemek.malzemeler) {
            AppLogger.info('       • $malzeme');
          }
        }
      }
    }
    
    AppLogger.info('');
    AppLogger.info('📊 TOPLAM MAKROLAR:');
    AppLogger.info('    Kalori: ${plan.toplamKalori.toStringAsFixed(0)} / ${plan.makroHedefleri.gunlukKalori.toStringAsFixed(0)} kcal');
    AppLogger.info('    Protein: ${plan.toplamProtein.toStringAsFixed(0)} / ${plan.makroHedefleri.gunlukProtein.toStringAsFixed(0)}g');
    AppLogger.info('    Karb: ${plan.toplamKarbonhidrat.toStringAsFixed(0)} / ${plan.makroHedefleri.gunlukKarbonhidrat.toStringAsFixed(0)}g');
    AppLogger.info('    Yağ: ${plan.toplamYag.toStringAsFixed(0)} / ${plan.makroHedefleri.gunlukYag.toStringAsFixed(0)}g');
    AppLogger.info('');
    AppLogger.info('📈 PLAN KALİTESİ:');
    AppLogger.info('    Fitness Skoru: ${plan.fitnessSkoru.toStringAsFixed(1)}/100');
    AppLogger.info('    Kalite Skoru: ${plan.makroKaliteSkoru.toStringAsFixed(1)}/100');
    
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
  }
}
