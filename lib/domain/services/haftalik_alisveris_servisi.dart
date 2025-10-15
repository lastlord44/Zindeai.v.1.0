// ============================================================================
// lib/domain/services/haftalik_alisveris_servisi.dart
// HAFTALİK ALIŞVERİŞ LİSTESİ SERVİSİ (Beslenme Planına Göre)
// ============================================================================

import '../../data/local/hive_service.dart';
import '../entities/alisveris_listesi.dart';
import '../entities/kullanici_profili.dart';
import '../entities/hedef.dart';
import '../../core/utils/app_logger.dart';

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

  /// Yemek malzemelerini listeye ekle
  static Future<void> _yemekMalzemeleriniEkle(
    dynamic yemek,
    Map<String, MalzemeDetayi> malzemeler,
  ) async {
    try {
      // Yemek malzemelerini parse et
      final malzemeListesi = yemek.malzemeler ?? <String>[];

      for (final malzeme in malzemeListesi) {
        final temizMalzeme = malzeme.trim();
        if (temizMalzeme.isEmpty) continue;

        // Mevcut malzeme varsa miktarını artır
        if (malzemeler.containsKey(temizMalzeme)) {
          final mevcut = malzemeler[temizMalzeme]!;
          malzemeler[temizMalzeme] = mevcut.copyWith(
            miktar: mevcut.miktar + 1,
          );
        } else {
          // Yeni malzeme ekle
          malzemeler[temizMalzeme] = MalzemeDetayi(
            ad: temizMalzeme,
            miktar: 1,
            birim: _malzemeBirimi(temizMalzeme),
            kategori: _malzemeKategorisi(temizMalzeme),
            oncelik: _malzemeOnceligi(temizMalzeme),
            tahminiMaliyet: _malzemeMaliyeti(temizMalzeme),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Yemek malzemesi parse hatası: $e');
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
    if (kullanici.hedef == Hedef.kasKazanKiloAl) {
      oneriler.add(
          '💪 Kas gelişimi için yüksek protein içerikli ürünleri tercih edin.');
    } else if (kullanici.hedef == Hedef.kiloVer) {
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

  /// Malzeme kategorisi belirle
  static String _malzemeKategorisi(String malzeme) {
    final malzemeKucuk = malzeme.toLowerCase();

    if (malzemeKucuk.contains('tavuk') ||
        malzemeKucuk.contains('et') ||
        malzemeKucuk.contains('balık') ||
        malzemeKucuk.contains('köfte')) {
      return 'Et Ürünleri';
    } else if (malzemeKucuk.contains('süt') ||
        malzemeKucuk.contains('peynir') ||
        malzemeKucuk.contains('yoğurt')) {
      return 'Süt Ürünleri';
    } else if (malzemeKucuk.contains('domates') ||
        malzemeKucuk.contains('salata') ||
        malzemeKucuk.contains('sebze')) {
      return 'Sebzeler';
    } else if (malzemeKucuk.contains('elma') ||
        malzemeKucuk.contains('muz') ||
        malzemeKucuk.contains('meyve')) {
      return 'Meyveler';
    } else if (malzemeKucuk.contains('ekmek') ||
        malzemeKucuk.contains('pirinç') ||
        malzemeKucuk.contains('bulgur')) {
      return 'Tahıllar';
    } else if (malzemeKucuk.contains('mercimek') ||
        malzemeKucuk.contains('nohut') ||
        malzemeKucuk.contains('fasulye')) {
      return 'Bakliyat';
    } else if (malzemeKucuk.contains('tuz') ||
        malzemeKucuk.contains('baharat') ||
        malzemeKucuk.contains('karabiber')) {
      return 'Baharat';
    } else {
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
}
