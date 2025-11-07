// ============================================================================
// lib/domain/services/haftalik_alisveris_servisi.dart
// HAFTALİK ALIŞVERİŞ LİSTESİ SERVİSİ (Beslenme Planına Göre)
// ============================================================================

import '../../data/local/hive_service.dart';
import '../entities/alisveris_listesi.dart';
import '../entities/kullanici_profili.dart';
import '../entities/hedef.dart';
import '../../core/utils/app_logger.dart';
import 'malzeme_parser_servisi.dart';

class HaftalikAlisverisServisi {
  /// Haftalık alışveriş listesi oluştur
  static Future<AlisverisListesi> haftalikAlisverisListesiOlustur({
    required DateTime baslangicTarihi,
    required KullaniciProfili kullanici,
  }) async {
    try {
      AppLogger.info(
          '🛒 Haftalık alışveriş listesi oluşturuluyor: ${baslangicTarihi.toString()}');

      final tumMalzemeler = <String, MalzemeDetayi>{};
      final planSayisi = <DateTime, int>{};
      int toplamYemekSayisi = 0;

      // 7 günlük planları topla
      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        final plan = await HiveService.planGetir(tarih);
        if (plan != null) {
          planSayisi[tarih] = plan.ogunler.length;
          toplamYemekSayisi += plan.ogunler.length;

          // Her yemeğin malzemelerini topla
          for (final yemek in plan.ogunler) {
            await _yemekMalzemeleriniEkle(yemek, tumMalzemeler);
          }
        }
      }

      // Malzemeleri kategorilere ayır
      final kategoriler = _malzemeleriKategorilereAyir(tumMalzemeler);

      // Akıllı öneriler üret
      final oneriler = _akilliBudjetOneriler(tumMalzemeler, kullanici);

      // Market kategorilerine göre organize et
      final marketBolumleri = _marketBolumlerineOrganizeEt(kategoriler);

      // Toplam maliyet hesapla (yaklaşık)
      final toplamMaliyet = _toplamMaliyetHesapla(tumMalzemeler);

      AppLogger.success(
          '✅ Alışveriş listesi oluşturuldu: ${tumMalzemeler.length} malzeme, ~${toplamMaliyet.toStringAsFixed(0)}₺');

      return AlisverisListesi(
        baslangicTarihi: baslangicTarihi,
        bitisTarihi: DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + 6,
        ),
        malzemeler: tumMalzemeler,
        kategoriler: kategoriler,
        marketBolumleri: marketBolumleri,
        toplamMaliyetTahmini: toplamMaliyet,
        toplamMalzemeSayisi: tumMalzemeler.length,
        planliGunSayisi: planSayisi.length,
        toplamYemekSayisi: toplamYemekSayisi,
        oneriler: oneriler,
        olusturulmaTarihi: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('❌ Alışveriş listesi oluşturma hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Yemek malzemelerini listeye ekle (PARSE EDİLMİŞ VERSİYON)
  static Future<void> _yemekMalzemeleriniEkle(
    dynamic yemek,
    Map<String, MalzemeDetayi> malzemeler,
  ) async {
    try {
      // Yemek malzemelerini al
      final malzemeListesi = yemek.malzemeler ?? <String>[];
      
      // 🔍 DEBUG: Yemek bilgilerini log'la
      AppLogger.debug('🛒 Yemek: ${yemek.ad} - ${malzemeListesi.length} malzeme');
      
      if (malzemeListesi.isEmpty) {
        AppLogger.warning('⚠️ ${yemek.ad} yemeğinin malzemeleri boş!');
        return;
      }

      for (final malzemeMetni in malzemeListesi) {
        final temizMalzeme = malzemeMetni.trim();
        if (temizMalzeme.isEmpty) continue;

        // 🔍 MALZEME PARSE ET
        AppLogger.debug('   📋 Parse ediliyor: "$temizMalzeme"');
        final parsedMalzeme = MalzemeParserServisi.parse(temizMalzeme);

        if (parsedMalzeme != null) {
          // Parse edilen malzeme - besin adına göre grupla
          final besinAdi = parsedMalzeme.besinAdi.toLowerCase();
          final anahtar = besinAdi; // Besin adı anahtardır
          
          AppLogger.debug('   ✅ Parse başarılı: ${parsedMalzeme.besinAdi} (${parsedMalzeme.miktar} ${parsedMalzeme.birim})');

          if (malzemeler.containsKey(anahtar)) {
            // Mevcut malzeme - miktarı topla (double → int çevir)
            final mevcut = malzemeler[anahtar]!;
            final yeniMiktar = (mevcut.miktar + parsedMalzeme.miktar).round();

            malzemeler[anahtar] = mevcut.copyWith(
              miktar: yeniMiktar,
            );
            AppLogger.debug('   🔄 Miktar güncellendi: $yeniMiktar ${parsedMalzeme.birim}');
          } else {
            // Yeni malzeme ekle (double → int çevir)
            malzemeler[anahtar] = MalzemeDetayi(
              ad: parsedMalzeme.besinAdi,
              miktar: parsedMalzeme.miktar.round(),
              birim: parsedMalzeme.birim,
              kategori: _malzemeKategorisi(parsedMalzeme.besinAdi),
              oncelik: _malzemeOnceligi(parsedMalzeme.besinAdi),
              tahminiMaliyet: _malzemeMaliyeti(parsedMalzeme.besinAdi),
            );
            AppLogger.debug('   ➕ Yeni malzeme eklendi');
          }
        } else {
          // Parse edilemeyen malzeme (tuz, baharat vb.) - olduğu gibi ekle
          AppLogger.warning('   ⚠️ Parse edilemedi: "$temizMalzeme" - olduğu gibi ekleniyor');
          final anahtar = temizMalzeme.toLowerCase();

          if (!malzemeler.containsKey(anahtar)) {
            malzemeler[anahtar] = MalzemeDetayi(
              ad: temizMalzeme,
              miktar: 1,
              birim: 'adet',
              kategori: _malzemeKategorisi(temizMalzeme),
              oncelik: _malzemeOnceligi(temizMalzeme),
              tahminiMaliyet: _malzemeMaliyeti(temizMalzeme),
            );
            AppLogger.debug('   ➕ Parse edilmemiş malzeme eklendi');
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek malzemesi parse hatası: ${yemek.ad}',
        error: e, stackTrace: stackTrace);
    }
  }

  /// Malzeme kategorilerini ayır
  static Map<String, List<MalzemeDetayi>> _malzemeleriKategorilereAyir(
    Map<String, MalzemeDetayi> malzemeler,
  ) {
    final kategoriler = <String, List<MalzemeDetayi>>{
      'Et Ürünleri': [],
      'Süt Ürünleri': [],
      'Sebzeler': [],
      'Meyveler': [],
      'Tahıllar': [],
      'Bakliyat': [],
      'Baharat': [],
      'Diğer': [],
    };

    for (final malzeme in malzemeler.values) {
      final kategori = malzeme.kategori;
      if (kategoriler.containsKey(kategori)) {
        kategoriler[kategori]!.add(malzeme);
      } else {
        kategoriler['Diğer']!.add(malzeme);
      }
    }

    // Boş kategorileri kaldır
    kategoriler.removeWhere((key, value) => value.isEmpty);

    // Her kategoriyi öncelik ve alfabetik sıraya göre sırala
    for (final kategori in kategoriler.keys) {
      kategoriler[kategori]!.sort((a, b) {
        final onccelikKarsilastirma = b.oncelik.compareTo(a.oncelik);
        return onccelikKarsilastirma != 0
            ? onccelikKarsilastirma
            : a.ad.compareTo(b.ad);
      });
    }

    return kategoriler;
  }

  /// Market bölümlerine organize et
  static Map<String, List<MalzemeDetayi>> _marketBolumlerineOrganizeEt(
    Map<String, List<MalzemeDetayi>> kategoriler,
  ) {
    return {
      '🥩 Et & Balık Reyonu': [
        ...kategoriler['Et Ürünleri'] ?? [],
      ],
      '🥛 Süt Ürünleri Reyonu': [
        ...kategoriler['Süt Ürünleri'] ?? [],
      ],
      '🥬 Sebze & Meyve Reyonu': [
        ...kategoriler['Sebzeler'] ?? [],
        ...kategoriler['Meyveler'] ?? [],
      ],
      '🌾 Tahıl & Bakliyat Reyonu': [
        ...kategoriler['Tahıllar'] ?? [],
        ...kategoriler['Bakliyat'] ?? [],
      ],
      '🧂 Baharat & Soslar': [
        ...kategoriler['Baharat'] ?? [],
      ],
      '🛒 Diğer Ürünler': [
        ...kategoriler['Diğer'] ?? [],
      ],
    }..removeWhere((key, value) => value.isEmpty);
  }

  /// Akıllı bütçe önerileri
  static List<String> _akilliBudjetOneriler(
    Map<String, MalzemeDetayi> malzemeler,
    KullaniciProfili kullanici,
  ) {
    final oneriler = <String>[];
    final toplamMaliyet = _toplamMaliyetHesapla(malzemeler);

    // Bütçe analizi
    if (toplamMaliyet > 500) {
      oneriler.add(
          '💰 Haftalık bütçeniz yüksek görünüyor. Ekonomik alternatifleri değerlendirin.');
    } else if (toplamMaliyet < 200) {
      oneriler.add(
          '✨ Uygun fiyatlı bir haftalık menu! Kalite için organik seçenekleri deneyin.');
    }

    // Sezonsal öneriler
    final mevsim = _mevsimBelirle(DateTime.now());
    oneriler.add(
        '🍃 $mevsim mevsimi için taze ve uygun fiyatlı ürünleri tercih edin.');

    // Akıllı alışveriş tavsiyeleri
    oneriler.add(
        '🛒 Market alışverişinde önce et reyonundan başlayın, sonra soğuk zincir ürünlerini alın.');
    oneriler.add('📱 Market indirimleri için uygulamaları kontrol edin.');

    // Depolama tavsiyeleri
    if (malzemeler.length > 30) {
      oneriler.add('🏠 Fazla malzeme var - depolama koşullarına dikkat edin.');
    }

    // Diyet bazlı öneriler
    if (kullanici.diyetTipi == DiyetTipi.vegan) {
      oneriler.add(
          '🌱 Vegan ürünler için doğal beslenme marketlerini kontrol edin.');
    } else if (kullanici.diyetTipi == DiyetTipi.vejetaryen) {
      oneriler.add(
          '🥗 Vejetaryen protein kaynakları için bakliyat reyonunu gözden geçirin.');
    }

    // Hedef bazlı öneriler
    if (kullanici.hedef == Hedef.kasKazanKiloAl || kullanici.hedef == Hedef.kasKazanKiloVer) {
      oneriler.add(
          '💪 Kas gelişimi için yüksek protein içerikli ürünleri tercih edin.');
    } else if (kullanici.hedef == Hedef.kiloVermek) {
      oneriler.add(
          '🔥 Düşük kalorili, doğal ürünleri tercih ederek kilo verme sürecinizi destekleyin.');
    }

    return oneriler.take(6).toList(); // Maksimum 6 öneri
  }

  /// Malzeme birimi belirle
  static String _malzemeBirimi(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    if (malzemeKucuk.contains('tavuk') ||
        malzemeKucuk.contains('et') ||
        malzemeKucuk.contains('balık')) {
      return 'gram';
    } else if (malzemeKucuk.contains('yumurta')) {
      return 'adet';
    } else if (malzemeKucuk.contains('süt') ||
        malzemeKucuk.contains('yoğurt')) {
      return 'ml';
    } else if (malzemeKucuk.contains('peynir')) {
      return 'gram';
    } else if (malzemeKucuk.contains('ekmek')) {
      return 'dilim';
    } else if (malzemeKucuk.contains('meyve') ||
        malzemeKucuk.contains('sebze')) {
      return 'adet';
    } else {
      return 'gram';
    }
  }

  /// Malzeme kategorisi belirle - SADECE ANA BESİNLER
  static String _malzemeKategorisi(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    // 🥩 ET ÜRÜNLERİ - SADECE ET, TAVUK, BALIK (sebze/kuruyemiş YOK!)
    if (malzemeKucuk.contains('tavuk') ||
        malzemeKucuk.contains('hindi') ||
        malzemeKucuk.contains('dana') ||
        malzemeKucuk.contains('koyun') ||
        malzemeKucuk.contains('kuzu') ||
        malzemeKucuk.contains('balık') ||
        malzemeKucuk.contains('somon') ||
        malzemeKucuk.contains('ton balığı') ||
        malzemeKucuk.contains('köfte') ||
        malzemeKucuk.contains('kıyma')) {
      return 'Et Ürünleri';
    }
    
    // 🥛 SÜT ÜRÜNLERİ
    else if (malzemeKucuk.contains('süt') ||
        malzemeKucuk.contains('peynir') ||
        malzemeKucuk.contains('yoğurt') ||
        malzemeKucuk.contains('lor') ||
        malzemeKucuk.contains('yumurta')) {
      return 'Süt Ürünleri';
    }
    
    // 🌾 TAHILLAR
    else if (malzemeKucuk.contains('ekmek') ||
        malzemeKucuk.contains('pirinç') ||
        malzemeKucuk.contains('bulgur') ||
        malzemeKucuk.contains('kinoa') ||
        malzemeKucuk.contains('yulaf') ||
        malzemeKucuk.contains('makarna')) {
      return 'Tahıllar';
    }
    
    // 🫘 BAKLİYAT
    else if (malzemeKucuk.contains('mercimek') ||
        malzemeKucuk.contains('nohut') ||
        malzemeKucuk.contains('fasulye') ||
        malzemeKucuk.contains('bakla')) {
      return 'Bakliyat';
    }
    
    // ❌ DİĞER - Sebze, meyve, baharat, kuruyemiş buraya düşer (filtrelenecek)
    else {
      return 'Diğer';
    }
  }

  /// Malzeme önceliği belirle (1-5 arası, 5 en önemli)
  static int _malzemeOnceligi(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    // Ana besinler (et, süt ürünleri) en yüksek öncelik
    if (malzemeKucuk.contains('tavuk') ||
        malzemeKucuk.contains('et') ||
        malzemeKucuk.contains('balık')) {
      return 5;
    } else if (malzemeKucuk.contains('süt') ||
        malzemeKucuk.contains('peynir') ||
        malzemeKucuk.contains('yumurta')) {
      return 4;
    } else if (malzemeKucuk.contains('ekmek') ||
        malzemeKucuk.contains('pirinç')) {
      return 4;
    } else if (malzemeKucuk.contains('sebze') ||
        malzemeKucuk.contains('meyve')) {
      return 3;
    } else if (malzemeKucuk.contains('baharat') ||
        malzemeKucuk.contains('tuz')) {
      return 1; // En düşük öncelik
    } else {
      return 2;
    }
  }

  /// Malzeme maliyeti tahmini (₺)
  static double _malzemeMaliyeti(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    if (malzemeKucuk.contains('tavuk')) {
      return 35.0; // kg başına
    } else if (malzemeKucuk.contains('et')) {
      return 120.0;
    } else if (malzemeKucuk.contains('balık')) {
      return 80.0;
    } else if (malzemeKucuk.contains('peynir')) {
      return 60.0;
    } else if (malzemeKucuk.contains('süt')) {
      return 8.0; // litre
    } else if (malzemeKucuk.contains('yumurta')) {
      return 2.0; // adet
    } else if (malzemeKucuk.contains('ekmek')) {
      return 4.0;
    } else if (malzemeKucuk.contains('pirinç')) {
      return 15.0;
    } else if (malzemeKucuk.contains('sebze')) {
      return 10.0;
    } else if (malzemeKucuk.contains('meyve')) {
      return 15.0;
    } else {
      return 5.0; // Varsayılan
    }
  }

  /// Toplam maliyet hesapla
  static double _toplamMaliyetHesapla(Map<String, MalzemeDetayi> malzemeler) {
    double toplam = 0.0;

    for (final malzeme in malzemeler.values) {
      // Miktar çarpanı (haftalık tüketim için)
      double miktar = malzeme.miktar.toDouble();

      // Birime göre maliyet hesapla
      double birimMaliyet = malzeme.tahminiMaliyet;
      if (malzeme.birim == 'gram' && malzeme.miktar > 1) {
        birimMaliyet = birimMaliyet * (miktar * 0.1); // 100g porsiyon varsayımı
      } else if (malzeme.birim == 'ml' && malzeme.miktar > 1) {
        birimMaliyet = birimMaliyet * (miktar * 0.25); // 250ml porsiyon
      } else {
        birimMaliyet = birimMaliyet * miktar;
      }

      toplam += birimMaliyet;
    }

    return toplam;
  }

  /// Mevsim belirle
  static String _mevsimBelirle(DateTime tarih) {
    final ay = tarih.month;

    if (ay >= 12 || ay <= 2) return 'kış';
    if (ay >= 3 && ay <= 5) return 'ilkbahar';
    if (ay >= 6 && ay <= 8) return 'yaz';
    return 'sonbahar';
  }

  /// Hızlı alışveriş listesi (sadece malzeme isimleri)
  static Future<List<String>> hizliAlisverisListesi({
    required DateTime baslangicTarihi,
  }) async {
    try {
      final tumMalzemeler = <String>{};

      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        final plan = await HiveService.planGetir(tarih);
        if (plan != null) {
          for (final yemek in plan.ogunler) {
            final malzemeListesi = yemek.malzemeler ?? <String>[];
            tumMalzemeler.addAll(
                malzemeListesi.map((m) => m.trim()).where((m) => m.isNotEmpty));
          }
        }
      }

      final liste = tumMalzemeler.toList();
      liste.sort();
      return liste;
    } catch (e) {
      AppLogger.error('Hızlı alışveriş listesi hatası: $e');
      return [];
    }
  }

  // ========================================================================
  // 🔥 GELİŞMİŞ MALZEME TOPLAMA ÖZELLİKLERİ
  // ========================================================================

  /// 🔥 YENİ: Tarif field'ından malzemeleri parse et
  static List<String> _parseMalzemelerFromTarif(String tarif) {
    // "lor peyniri (120 g), kinoa (80 g), roka (60 g)" formatını parse et
    final malzemeler = tarif
        .split(',')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    
    AppLogger.debug('📋 Tariften ${malzemeler.length} malzeme parse edildi');
    return malzemeler;
  }

  /// 🔥 YENİ: Gelişmiş malzeme maliyeti (gram/ml bazında)
  static double _gelismisMaliyetHesapla(String malzemeAdi, double miktar, String birim) {
    final malzemeKucuk = malzemeAdi.toLowerCase();
    
    // Birimi gr/ml'ye çevir
    double gramMlMiktar = 0;
    
    if (birim == 'gram' || birim == 'g' || birim == 'gr') {
      gramMlMiktar = miktar;
    } else if (birim == 'ml') {
      gramMlMiktar = miktar;
    } else if (birim == 'litre' || birim == 'l' || birim == 'lt') {
      gramMlMiktar = miktar * 1000;
    } else if (birim == 'su bardağı') {
      gramMlMiktar = miktar * 200;
    } else if (birim == 'çay bardağı') {
      gramMlMiktar = miktar * 100;
    } else if (birim == 'yemek kaşığı') {
      gramMlMiktar = miktar * 15;
    } else if (birim == 'tatlı kaşığı') {
      gramMlMiktar = miktar * 5;
    } else {
      // Adet, dilim vb. için varsayılan ağırlık
      gramMlMiktar = _varsayilanAgirlik(malzemeAdi) * miktar;
    }

    // Kategori bazında birim fiyat (₺/gram veya ₺/ml)
    double birimFiyat = 0;

    if (malzemeKucuk.contains('tavuk') || malzemeKucuk.contains('hindi')) {
      birimFiyat = 0.12; // 120₺/kg
    } else if (malzemeKucuk.contains('dana') || malzemeKucuk.contains('koyun')) {
      birimFiyat = 0.35; // 350₺/kg
    } else if (malzemeKucuk.contains('balık') || malzemeKucuk.contains('somon')) {
      birimFiyat = 0.25; // 250₺/kg
    } else if (malzemeKucuk.contains('peynir')) {
      birimFiyat = 0.25; // 250₺/kg
    } else if (malzemeKucuk.contains('süt')) {
      birimFiyat = 0.008; // 8₺/litre = 0.008₺/ml
    } else if (malzemeKucuk.contains('yoğurt')) {
      birimFiyat = 0.03; // 30₺/kg
    } else if (malzemeKucuk.contains('yumurta')) {
      birimFiyat = 2.0; // 2₺/adet
    } else if (malzemeKucuk.contains('ekmek')) {
      birimFiyat = 0.25; // 2.5₺/dilim
    } else if (malzemeKucuk.contains('pirinç') || malzemeKucuk.contains('bulgur')) {
      birimFiyat = 0.04; // 40₺/kg
    } else if (malzemeKucuk.contains('makarna')) {
      birimFiyat = 0.03; // 30₺/kg
    } else if (malzemeKucuk.contains('mercimek') || malzemeKucuk.contains('nohut') || malzemeKucuk.contains('fasulye')) {
      birimFiyat = 0.03; // 30₺/kg
    } else if (malzemeKucuk.contains('sebze') || malzemeKucuk.contains('domates') || malzemeKucuk.contains('salatalık')) {
      birimFiyat = 0.02; // 20₺/kg
    } else if (malzemeKucuk.contains('meyve') || malzemeKucuk.contains('elma') || malzemeKucuk.contains('muz')) {
      birimFiyat = 0.03; // 30₺/kg
    } else if (malzemeKucuk.contains('ceviz') || malzemeKucuk.contains('badem') || malzemeKucuk.contains('fındık')) {
      birimFiyat = 0.25; // 250₺/kg
    } else if (malzemeKucuk.contains('zeytinyağı') || malzemeKucuk.contains('yağ')) {
      birimFiyat = 0.08; // 80₺/litre
    } else if (malzemeKucuk.contains('tuz') || malzemeKucuk.contains('baharat')) {
      birimFiyat = 0.001; // 1₺/kg
    } else {
      birimFiyat = 0.02; // Varsayılan 20₺/kg
    }

    return gramMlMiktar * birimFiyat;
  }

  /// 🔥 YENİ: Varsayılan ağırlık (adet için)
  static double _varsayilanAgirlik(String malzemeAdi) {
    final malzemeKucuk = malzemeAdi.toLowerCase();

    if (malzemeKucuk.contains('yumurta')) return 60; // 60g yumurta
    if (malzemeKucuk.contains('dilim')) return 30; // 30g dilim ekmet
    if (malzemeKucuk.contains('porsiyon')) return 200; // 200g porsiyon
    if (malzemeKucuk.contains('adet')) return 100; // 100g varsayılan

    return 100; // Varsayılan 100g
  }

  /// 🔥 YENİ: Gelişmiş malzeme kategorisi (daha detaylı)
  static String _gelismisMalzemeKategorisi(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    if (malzemeKucuk.contains('tavuk') || malzemeKucuk.contains('hindi') ||
        malzemeKucuk.contains('dana') || malzemeKucuk.contains('koyun') ||
        malzemeKucuk.contains('balık') || malzemeKucuk.contains('köfte') ||
        malzemeKucuk.contains('kıyma')) {
      return 'Et Ürünleri';
    } else if (malzemeKucuk.contains('süt') || malzemeKucuk.contains('peynir') ||
        malzemeKucuk.contains('yoğurt') || malzemeKucuk.contains('tereyağı') ||
        malzemeKucuk.contains('lor')) {
      return 'Süt Ürünleri';
    } else if (malzemeKucuk.contains('domates') || malzemeKucuk.contains('salata') ||
        malzemeKucuk.contains('salatalık') || malzemeKucuk.contains('biber') ||
        malzemeKucuk.contains('soğan') || malzemeKucuk.contains('sarımsak') ||
        malzemeKucuk.contains('roka') || malzemeKucuk.contains('marul') ||
        malzemeKucuk.contains('sebze')) {
      return 'Sebzeler';
    } else if (malzemeKucuk.contains('elma') || malzemeKucuk.contains('muz') ||
        malzemeKucuk.contains('portakal') || malzemeKucuk.contains('çilek') ||
        malzemeKucuk.contains('meyve')) {
      return 'Meyveler';
    } else if (malzemeKucuk.contains('ekmek') || malzemeKucuk.contains('pirinç') ||
        malzemeKucuk.contains('bulgur') || malzemeKucuk.contains('makarna') ||
        malzemeKucuk.contains('kinoa') || malzemeKucuk.contains('yulaf')) {
      return 'Tahıllar';
    } else if (malzemeKucuk.contains('mercimek') || malzemeKucuk.contains('nohut') ||
        malzemeKucuk.contains('fasulye') || malzemeKucuk.contains('bakla')) {
      return 'Bakliyat';
    } else if (malzemeKucuk.contains('ceviz') || malzemeKucuk.contains('badem') ||
        malzemeKucuk.contains('fındık') || malzemeKucuk.contains('fıstık')) {
      return 'Kuruyemişler';
    } else if (malzemeKucuk.contains('tuz') || malzemeKucuk.contains('karabiber') ||
        malzemeKucuk.contains('pul biber') || malzemeKucuk.contains('kekik') ||
        malzemeKucuk.contains('baharat')) {
      return 'Baharatlar';
    } else if (malzemeKucuk.contains('zeytinyağı') || malzemeKucuk.contains('yağ') ||
        malzemeKucuk.contains('sirke') || malzemeKucuk.contains('limon')) {
      return 'Soslar & Yağlar';
    } else {
      return 'Diğer';
    }
  }

  /// 🔥 YENİ: Gelişmiş malzeme önceliği (miktar bazında)
  static int _gelismisMalzemeOnceligi(String malzeme, double miktar) {
    final malzemeKucuk = malzeme.toLowerCase();

    // Ana protein kaynakları (miktarına göre öncelik)
    if (malzemeKucuk.contains('tavuk') || malzemeKucuk.contains('hindi') ||
        malzemeKucuk.contains('dana') || malzemeKucuk.contains('balık')) {
      return miktar >= 150 ? 5 : 4; // 150g+ çok önemli
    } else if (malzemeKucuk.contains('yumurta')) {
      return miktar >= 2 ? 4 : 3; // 2+ yumurta önemli
    } else if (malzemeKucuk.contains('süt') || malzemeKucuk.contains('peynir') ||
        malzemeKucuk.contains('yoğurt')) {
      return miktar >= 200 ? 4 : 3; // 200ml+ önemli
    } else if (malzemeKucuk.contains('ekmek') || malzemeKucuk.contains('pirinç')) {
      return miktar >= 100 ? 4 : 3; // 100g+ önemli
    } else if (malzemeKucuk.contains('sebze') || malzemeKucuk.contains('meyve')) {
      return miktar >= 200 ? 3 : 2; // Sebze/meyve orta öncelik
    } else if (malzemeKucuk.contains('kuruyemiş')) {
      return miktar >= 50 ? 3 : 2; // 50g+ orta öncelik
    } else if (malzemeKucuk.contains('bakliyat')) {
      return miktar >= 100 ? 3 : 2; // 100g+ orta öncelik
    } else if (malzemeKucuk.contains('baharat') || malzemeKucuk.contains('tuz')) {
      return 1; // En düşük öncelik
    } else if (malzemeKucuk.contains('sos') || malzemeKucuk.contains('yağ')) {
      return 2; // Düşük öncelik
    } else {
      return 2; // Varsayılan düşük öncelik
    }
  }
}
