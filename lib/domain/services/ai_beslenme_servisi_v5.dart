// ============================================================================
// lib/domain/services/ai_beslenme_servisi_v5.dart
// TÜRK KAHVALTISI ODAKLI + ÇEŞİTLİLİK MASTER BESLENME SERVİSİ (v5.0)
// 🇹🇷 TÜRK KÜLTÜRÜ STANDARTLARI + GÜNLÜK ÇEŞİTLİLİK GARANTİSİ
// ============================================================================

import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/hedef.dart';
import '../entities/makro_hedefleri.dart';
import '../../core/utils/app_logger.dart';
import 'diyetisyen_duzeltme_servisi.dart';
import '../../data/local/hive_service.dart';

// ============================================================================
// PARSE VE ÖLÇEKLEME YARDIMCI FONKSİYONLARI (TOP-LEVEL)
// ============================================================================

class _MalzemeDetay {
  final String ad;
  final double? miktar;
  final String? birim;
  _MalzemeDetay(this.ad, this.miktar, this.birim);
}

final Set<String> _olceklenmeyecekBirimler = {
  'yk','tk','kaşık','tutam','dal','dilim','bardak','fincan','kup','kase'
};

String _normalizeUnit(String u) {
  final x = u.toLowerCase().trim();
  if (x == 'gr' || x == 'gram') return 'g';
  if (x == 'mililitre' || x == 'cc') return 'ml';
  if (x == 'ad' || x == 'pcs' || x == 'porsiyon' || x == 'pkt' || x == 'paket') return 'adet';
  if (x == 'kg') return 'kg';
  if (x == 'l' || x == 'lt' || x == 'litre') return 'l';
  return x;
}

double? _parseNumberTr(String s) {
  final t = s.replaceAll(RegExp(r'\.(?=\d{3})'), '').replaceAll(',', '.');
  return double.tryParse(t);
}

_MalzemeDetay _parseMalzeme(String malzemeStr) {
  // Önce parantezli format dene: "Malzeme (150 g)"
  final lastOpen = malzemeStr.lastIndexOf('(');
  final lastClose = malzemeStr.lastIndexOf(')');
  if (lastOpen != -1 && lastClose != -1 && lastClose > lastOpen) {
    final ad = malzemeStr.substring(0, lastOpen).trim();
    final ic = malzemeStr.substring(lastOpen + 1, lastClose).trim();
    final m = RegExp(r'^([\d.,]+)\s*([A-Za-zğüşıöçĞÜŞIÖÇ]+)?$').firstMatch(ic);
    if (m != null) {
      final miktar = _parseNumberTr(m.group(1)!);
      final birimRaw = (m.group(2) ?? '').trim();
      final birim = birimRaw.isEmpty ? null : _normalizeUnit(birimRaw);
      if (miktar != null && birim != null) {
        return _MalzemeDetay(ad, miktar, birim);
      }
    }
  }
  
  // Parantez yoksa, sondan sayı+birim dene: "Malzeme 150g" veya "Malzeme 150 g"
  final noParenMatch = RegExp(r'^(.+?)\s+([\d.,]+)\s*([A-Za-zğüşıöçĞÜŞIÖÇ]+)$').firstMatch(malzemeStr);
  if (noParenMatch != null) {
    final ad = noParenMatch.group(1)!.trim();
    final miktar = _parseNumberTr(noParenMatch.group(2)!);
    final birimRaw = noParenMatch.group(3)!.trim();
    final birim = _normalizeUnit(birimRaw);
    if (miktar != null && birim.isNotEmpty) {
      return _MalzemeDetay(ad, miktar, birim);
    }
  }
  
  return _MalzemeDetay(malzemeStr.trim(), null, null);
}

double _roundTo(double value, double step) => (value / step).round() * step;

double _minFor(String ad, String birim) {
  final a = ad.toLowerCase();
  if (birim == 'ml') {
    if (a.contains('zeytinyağı') || a.contains('ayçiçek') || a.contains('yağ')) return 5;
    if (a.contains('limon suyu')) return 5;
    return 10;
  }
  if (birim == 'g') {
    if (a.contains('peynir')) return 10;
    if (a.contains('yulaf')) return 20;
    if (a.contains('ton balığı')) return 30;
    return 10;
  }
  if (birim == 'adet') return 0.5;
  return 0;
}

class AIBeslenmeServisiV5 {
  Random _random = Random();
  final Set<String> _haftalikSecilenYemekler = {};
  final Set<String> _gunlukSecilenAnaMalzemeler = {};
  final Map<String, DateTime> _gunlukCesitlilikGecmisi = {}; // YENİ: Günlük çeşitlilik takibi
  final DiyetisyenDuzeltmeServisi _diyetisyenServisi = DiyetisyenDuzeltmeServisi();
  
  // 🇹🇷 TÜRK KAHVALTISI KÜLTÜRÜ STANDARTLARI
  final Set<String> _turkKahvaltiUygunOlmayanlar = {
    'ton balığı', 'somon', 'levrek', 'balık', 'fish', 'tuna', 'salmon',
    'tavuk göğsü', 'tavuk but', 'et', 'biftek', 'kıyma', 'kebap', 'dana',
    'hamburger', 'pizza', 'makarna', 'pilav', 'bulgur', 'noodle'
  };
  
  final Set<String> _turkKahvaltiUygunu = {
    'yumurta', 'peynir', 'sucuk', 'salam', 'pastırma', 'zeytin', 'domates',
    'salatalık', 'ekmek', 'simit', 'çay', 'bal', 'reçel', 'tereyağı',
    'yoğurt', 'süt', 'omlet', 'menemen', 'börek', 'poğaça', 'muz', 'elma'
  };
  
  void _cesitlilikDurumuLogla() {
    AppLogger.info('🔍 V5 ÇEŞİTLİLİK DURUMU:');
    AppLogger.info('   📅 Haftalık seçilenler: ${_haftalikSecilenYemekler.length} adet');
    AppLogger.info('   🥩 Günlük protein kaynakları: ${_gunlukSecilenAnaMalzemeler.length} adet');
    AppLogger.info('   🌟 Günlük çeşitlilik geçmişi: ${_gunlukCesitlilikGecmisi.length} adet');
  }

  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
    bool haftalikPlanModu = false,
  }) async {
    try {
      final planTarihi = tarih ?? DateTime.now();
      AppLogger.info('🇹🇷 V5 TÜRK KÜLTÜRÜ plan oluşturuluyor: ${hedefKalori.toInt()} kcal | P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
      
      _cesitlilikDurumuLogla();

      GunlukPlan gunlukPlan = await _mockAIPlan(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: planTarihi,
        kisitlamalar: kisitlamalar,
      );

      // 🍽️ FINAL PLAN DETAYLARI
      AppLogger.success('✅ V5 Plan oluşturuldu:');
      if (gunlukPlan.kahvalti != null) {
        AppLogger.info('   🥞 Kahvaltı: ${gunlukPlan.kahvalti!.ad} (${gunlukPlan.kahvalti!.kalori.toInt()} kcal)');
      }
      if (gunlukPlan.araOgun1 != null) {
        AppLogger.info('   🍎 Ara Öğün 1: ${gunlukPlan.araOgun1!.ad} (${gunlukPlan.araOgun1!.kalori.toInt()} kcal)');
      }
      if (gunlukPlan.ogleYemegi != null) {
        AppLogger.info('   🍽️ Öğle: ${gunlukPlan.ogleYemegi!.ad} (${gunlukPlan.ogleYemegi!.kalori.toInt()} kcal)');
      }
      if (gunlukPlan.araOgun2 != null) {
        AppLogger.info('   🥜 Ara Öğün 2: ${gunlukPlan.araOgun2!.ad} (${gunlukPlan.araOgun2!.kalori.toInt()} kcal)');
      }
      if (gunlukPlan.aksamYemegi != null) {
        AppLogger.info('   🌙 Akşam: ${gunlukPlan.aksamYemegi!.ad} (${gunlukPlan.aksamYemegi!.kalori.toInt()} kcal)');
      }
      if (gunlukPlan.geceAtistirma != null) {
        AppLogger.info('   🌃 Gece: ${gunlukPlan.geceAtistirma!.ad} (${gunlukPlan.geceAtistirma!.kalori.toInt()} kcal)');
      }
      
      // 📊 TOPLAM MAKRO ÖZET
      AppLogger.info('📊 TOPLAM MAKROLAR:');
      AppLogger.info('   🔥 Kalori: ${gunlukPlan.toplamKalori.toInt()}/${hedefKalori.toInt()} (${(gunlukPlan.toplamKalori/hedefKalori*100).toStringAsFixed(1)}%)');
      AppLogger.info('   🥩 Protein: ${gunlukPlan.toplamProtein.toInt()}g/${hedefProtein.toInt()}g (${(gunlukPlan.toplamProtein/hedefProtein*100).toStringAsFixed(1)}%)');
      AppLogger.info('   🍞 Karb: ${gunlukPlan.toplamKarbonhidrat.toInt()}g/${hedefKarb.toInt()}g (${(gunlukPlan.toplamKarbonhidrat/hedefKarb*100).toStringAsFixed(1)}%)');
      AppLogger.info('   🧈 Yağ: ${gunlukPlan.toplamYag.toInt()}g/${hedefYag.toInt()}g (${(gunlukPlan.toplamYag/hedefYag*100).toStringAsFixed(1)}%)');
      
      final toleransKontrol = _toleransKontrolEt(gunlukPlan);
      AppLogger.info('📊 V5 Final Tolerans Kontrolü: $toleransKontrol');
      return gunlukPlan;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Beslenme V5 Servisi Hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<GunlukPlan>> haftalikPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef,
    List<String> kisitlamalar = const [],
    required DateTime baslangicTarihi,
    Function(GunlukPlan)? onGunlukPlanOlusturuldu,
  }) async {
    _haftalikSecilenYemekler.clear();
    _gunlukCesitlilikGecmisi.clear(); // YENİ: Haftalık başında temizle
    final planlar = <GunlukPlan>[];
    final ilkGunTarihi = DateTime(baslangicTarihi.year, baslangicTarihi.month, baslangicTarihi.day);
    
    final ilkGunPlan = await gunlukPlanOlustur(
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
      hedef: hedef,
      kisitlamalar: kisitlamalar,
      tarih: ilkGunTarihi,
      haftalikPlanModu: true,
    );

    planlar.add(ilkGunPlan);
    onGunlukPlanOlusturuldu?.call(ilkGunPlan);

    _arkaPlandan6GunOlustur(
      baslangicTarihi: baslangicTarihi,
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
      hedef: hedef,
      kisitlamalar: kisitlamalar,
      onGunlukPlanOlusturuldu: onGunlukPlanOlusturuldu,
    );
    return planlar;
  }

  Future<void> _arkaPlandan6GunOlustur({
    required DateTime baslangicTarihi,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required Hedef hedef,
    required List<String> kisitlamalar,
    Function(GunlukPlan)? onGunlukPlanOlusturuldu,
  }) async {
    for (int gun = 1; gun < 7; gun++) {
      try {
        final planTarihi = DateTime(baslangicTarihi.year, baslangicTarihi.month, baslangicTarihi.day + gun);
        
        // 🔥 HER GÜN FARKLI SEED - MÜKEMMEr ÇEŞİTLİLİK GARANTİSİ
        _gunlukSecilenAnaMalzemeler.clear();
        
        final gunlukPlan = await gunlukPlanOlustur(
          hedefKalori: hedefKalori,
          hedefProtein: hedefProtein,
          hedefKarb: hedefKarb,
          hedefYag: hedefYag,
          hedef: hedef,
          kisitlamalar: kisitlamalar,
          tarih: planTarihi,
          haftalikPlanModu: true,
        );
        onGunlukPlanOlusturuldu?.call(gunlukPlan);
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        AppLogger.error('❌ V5 ARKA PLAN - Gün ${gun + 1} planı oluşturulamadı: $e');
      }
    }
  }

  Future<GunlukPlan> _mockAIPlan({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    required DateTime tarih,
    required List<String> kisitlamalar,
  }) async {
    _gunlukSecilenAnaMalzemeler.clear();
    
    // 🔥 MÜKEMMEL ÇEŞİTLİLİK SEED - her gün, her saat farklı
    final benzersizSeed = tarih.year * 100000 + 
                         tarih.month * 10000 + 
                         tarih.day * 1000 + 
                         tarih.hour * 100 +
                         tarih.minute * 10 +
                         _haftalikSecilenYemekler.length; // Extra çeşitlilik faktörü
    _random = Random(benzersizSeed);
    
    AppLogger.info('🎲 V5 ÇEŞİTLİLİK SEED: $benzersizSeed (${tarih.day}/${tarih.month})');

    final tumYemekler = await HiveService.tumYemekleriGetir();
    if (tumYemekler.isEmpty) {
      return await _guvenilFallbackPlan(hedefKalori, hedefProtein, hedefKarb, hedefYag, tarih);
    }
    
    final Map<OgunTipi, List<Yemek>> ogunYemekleri = {};
    for (var yemek in tumYemekler) {
      if (yemek.kisitlamayaUygunMu(kisitlamalar)) {
        (ogunYemekleri[yemek.ogun] ??= []).add(yemek);
      }
    }

    // 🎯 DİYETİSYEN STANDARDI: TÜRK KÜLTÜRÜ UYUMLU KALORI DAĞILIMI
    final bool yuksekKaloriModu = hedefKalori >= 2500;
    final bool bulkModu = hedefKalori >= 3000;
    
    double kahvaltiOran = yuksekKaloriModu ? 0.25 : 0.25;
    double araOgun1Oran = yuksekKaloriModu ? 0.12 : 0.15;
    double ogleOran = yuksekKaloriModu ? 0.22 : 0.25;
    double araOgun2Oran = yuksekKaloriModu ? 0.12 : 0.15;
    double aksamOran = yuksekKaloriModu ? 0.17 : 0.20;
    double geceOran = yuksekKaloriModu ? 0.12 : 0.0;
    
    final kahvaltiKalori = hedefKalori * kahvaltiOran;
    final araOgun1Kalori = hedefKalori * araOgun1Oran;
    final ogleKalori = hedefKalori * ogleOran;
    final araOgun2Kalori = hedefKalori * araOgun2Oran;
    final aksamKalori = hedefKalori * aksamOran;
    final geceAtistirmaKalori = hedefKalori * geceOran;

    double kalanProtein = hedefProtein, kalanKarb = hedefKarb, kalanYag = hedefYag;

    // 🥞 TÜRK KAHVALTISI: Kültürel uyumluluk garantisi
    final kahvalti = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.kahvalti] ?? [], OgunTipi.kahvalti, kahvaltiKalori, hedefProtein * 0.25, hedefKarb * 0.25, hedefYag * 0.25);
    kalanProtein -= kahvalti.protein; kalanKarb -= kahvalti.karbonhidrat; kalanYag -= kahvalti.yag;

    // 🍎 ARA ÖĞÜN 1: PROTEİN ODAKLI 
    final araOgun1MinProtein = yuksekKaloriModu ? 12.0 : 8.0;
    final araOgun1HedefProtein = (hedefProtein * 0.12).clamp(araOgun1MinProtein, hedefProtein * 0.15);
    final araOgun1 = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.araOgun1] ?? [], OgunTipi.araOgun1, araOgun1Kalori, araOgun1HedefProtein, hedefKarb * 0.08, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun1.protein; kalanKarb -= araOgun1.karbonhidrat; kalanYag -= araOgun1.yag;

    // 🍽️ ÖĞLE YEMEĞİ: Günün ana öğünü
    final ogleYemegi = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.ogle] ?? [], OgunTipi.ogle, ogleKalori, kalanProtein * 0.42, kalanKarb * 0.40, kalanYag * 0.40, isAnaOgun: true);
    kalanProtein -= ogleYemegi.protein; kalanKarb -= ogleYemegi.karbonhidrat; kalanYag -= ogleYemegi.yag;

    // 🥜 ARA ÖĞÜN 2: PROTEİN ODAKLI  
    final araOgun2MinProtein = yuksekKaloriModu ? 12.0 : 8.0;
    final araOgun2HedefProtein = (hedefProtein * 0.12).clamp(araOgun2MinProtein, hedefProtein * 0.15);
    final araOgun2 = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.araOgun2] ?? [], OgunTipi.araOgun2, araOgun2Kalori, araOgun2HedefProtein, hedefKarb * 0.07, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun2.protein; kalanKarb -= araOgun2.karbonhidrat; kalanYag -= araOgun2.yag;

    // 🌙 AKŞAM YEMEĞİ: Son güçlü öğün
    final aksamYemegi = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.aksam] ?? [], OgunTipi.aksam, aksamKalori, kalanProtein * 0.85, kalanKarb * 0.85, kalanYag * 0.85, isAnaOgun: true);
    
    Yemek? geceAtistirma;
    if (yuksekKaloriModu) {
      geceAtistirma = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.geceAtistirma] ?? [], OgunTipi.geceAtistirma, geceAtistirmaKalori, kalanProtein, kalanKarb, kalanYag);
    }

    return GunlukPlan(
      id: '${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: _yemekOlustur(kahvalti, OgunTipi.kahvalti, kahvaltiKalori),
      araOgun1: _yemekOlustur(araOgun1, OgunTipi.araOgun1, araOgun1Kalori),
      ogleYemegi: _yemekOlustur(ogleYemegi, OgunTipi.ogle, ogleKalori),
      araOgun2: _yemekOlustur(araOgun2, OgunTipi.araOgun2, araOgun2Kalori),
      aksamYemegi: _yemekOlustur(aksamYemegi, OgunTipi.aksam, aksamKalori),
      geceAtistirma: geceAtistirma != null ? _yemekOlustur(geceAtistirma, OgunTipi.geceAtistirma, geceAtistirmaKalori) : null,
      makroHedefleri: MakroHedefleri(gunlukKalori: hedefKalori, gunlukProtein: hedefProtein, gunlukKarbonhidrat: hedefKarb, gunlukYag: hedefYag),
      fitnessSkoru: 0,
    );
  }

  bool _turkKahvaltisinaUygunMu(Yemek yemek) {
    final yemekAdiLower = yemek.ad.toLowerCase();
    final malzemelerText = yemek.malzemeler.join(' ').toLowerCase();
    final tumText = '$yemekAdiLower $malzemelerText';
    
    // 🚫 KESIN YASAK: Türk kahvaltısında olmayanlar
    for (final yasak in _turkKahvaltiUygunOlmayanlar) {
      if (tumText.contains(yasak)) {
        AppLogger.warning('🇹🇷 TÜRK KAHVALTISI FİLTRESİ: "${yemek.ad}" UYGUN DEĞİL - İçerik: $yasak');
        return false;
      }
    }
    
    // ✅ BONUS: Türk kahvaltısına uygun olanlar
    for (final uygun in _turkKahvaltiUygunu) {
      if (tumText.contains(uygun)) {
        AppLogger.info('🇹🇷 TÜRK KAHVALTISI BONUS: "${yemek.ad}" MÜKEMMEL UYGUN - İçerik: $uygun');
        return true;
      }
    }
    
    return true; // Neutral durumlar geçebilir
  }

  Yemek _yemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) {
    if (bazYemek.kalori <= 0) {
      return bazYemek.copyWith(id: 'plan_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}');
    }

    final olcek = hedefKalori / bazYemek.kalori;
    final guvenliOlcek = olcek.clamp(0.9, 1.1);

    final List<String> yeniMalzemeler = [];

    for (final malzemeStr in bazYemek.malzemeler) {
      final d = _parseMalzeme(malzemeStr);

      if (d.miktar == null || d.birim == null || _olceklenmeyecekBirimler.contains(d.birim!)) {
        yeniMalzemeler.add(malzemeStr);
        continue;
      }

      // YUMURTA GÜVENLİK VE OTOMATİK DÖNÜŞTÜRME
      if (d.ad.toLowerCase().contains('yumurta')) {
        if (d.birim == 'g') {
          double adetSayisi = d.miktar! / 55.0;
          adetSayisi = _roundTo(adetSayisi, 0.5);
          adetSayisi = adetSayisi.clamp(0.5, 8.0);
          AppLogger.warning('🛡️ YUMURTA OTO-DÖNÜŞÜm: "${d.ad}" ${d.miktar}g → ${adetSayisi} adet');
          yeniMalzemeler.add('${d.ad} (${adetSayisi.toStringAsFixed(1).replaceAll('.0', '')} adet)');
          continue;
        } else if (d.birim != 'adet') {
          AppLogger.warning('🛡️ YUMURTA GÜVENLİK: "${d.ad}" bilinmeyen birim (${d.birim}), ölçek dışı bırakıldı.');
          yeniMalzemeler.add(malzemeStr);
          continue;
        }
      }

      double yeni = d.miktar! * guvenliOlcek;

      switch (d.birim) {
        case 'adet':
          yeni = _roundTo(yeni, 0.5);
          yeni = yeni.clamp(0.5, 8.0);
          yeniMalzemeler.add('${d.ad} (${yeni.toStringAsFixed(1).replaceAll('.0', '')} adet)');
          break;
        case 'g':
          yeni = _roundTo(yeni, 5);
          yeni = max(yeni, _minFor(d.ad, 'g'));
          yeniMalzemeler.add('${d.ad} (${yeni.round()} g)');
          break;
        case 'ml':
          yeni = _roundTo(yeni, 10);
          yeni = max(yeni, _minFor(d.ad, 'ml'));
          yeniMalzemeler.add('${d.ad} (${yeni.round()} ml)');
          break;
        case 'kg':
          double g = yeni * 1000;
          g = _roundTo(g, 10);
          g = max(g, _minFor(d.ad, 'g'));
          yeniMalzemeler.add('${d.ad} (${g.round()} g)');
          break;
        case 'l':
          double ml = yeni * 1000;
          ml = _roundTo(ml, 10);
          ml = max(ml, _minFor(d.ad, 'ml'));
          yeniMalzemeler.add('${d.ad} (${ml.round()} ml)');
          break;
        default:
          yeniMalzemeler.add(malzemeStr);
          break;
      }
    }

    final olcekliYemek = bazYemek.copyWith(
      id: 'plan_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}',
      kalori: bazYemek.kalori * guvenliOlcek,
      protein: bazYemek.protein * guvenliOlcek,
      karbonhidrat: bazYemek.karbonhidrat * guvenliOlcek,
      yag: bazYemek.yag * guvenliOlcek,
      malzemeler: yeniMalzemeler,
    );
    
    // 📏 ÖLÇEKLEME DETAYLARI LOGLAMA
    if (guvenliOlcek != 1.0) {
      AppLogger.info('📏 ÖLÇEKLEME UYGULAND: ${bazYemek.ad} - Çarpan: ${guvenliOlcek.toStringAsFixed(2)}');
      AppLogger.info('   📊 Orjinal: K:${bazYemek.kalori.toInt()} → Ölçekli: K:${olcekliYemek.kalori.toInt()}');
      AppLogger.info('   🥘 Ölçeklenmiş malzemeler (${yeniMalzemeler.length} adet):');
      for (int i = 0; i < yeniMalzemeler.length; i++) {
        if (i < bazYemek.malzemeler.length && yeniMalzemeler[i] != bazYemek.malzemeler[i]) {
          AppLogger.info('      ${i+1}. ${bazYemek.malzemeler[i]} → ${yeniMalzemeler[i]}');
        } else {
          AppLogger.info('      ${i+1}. ${yeniMalzemeler[i]}');
        }
      }
    }
    
    return olcekliYemek;
  }

  String _toleransKontrolEt(GunlukPlan plan) {
    final toleranslar = <String>[];
    if (!plan.kaloriToleranstaMi) toleranslar.add('Kalori (${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.proteinToleranstaMi) toleranslar.add('Protein (${plan.proteinSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.karbonhidratToleranstaMi) toleranslar.add('Karbonhidrat (${plan.karbonhidratSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.yagToleranstaMi) toleranslar.add('Yağ (${plan.yagSapmaYuzdesi.toStringAsFixed(1)}%)');
    return toleranslar.isEmpty ? '✅ Tüm makrolar ±15% tolerans içinde' : '⚠️ Tolerans aşan makrolar: ${toleranslar.join(', ')}';
  }

  Yemek _enUygunYemekSecHive(
    List<Yemek> yemekler,
    OgunTipi ogunTipi,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag, {
    bool isAnaOgun = false,
    bool isAraOgun = false,
  }) {
    if (yemekler.isEmpty) {
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }

    // 🔥 YUMUŞATILMIŞ BOZUK VERİ FİLTRESİ (V5.1)
    AppLogger.info('🔍 V5 FİLTRELEME BAŞLADI: ${yemekler.length} yemek → ${ogunTipi.name}');
    
    var filtrelenmisYemekler = yemekler.where((yemek) {
      // Sadece çok ciddi bozuklukları filtrele
      if (yemek.kalori < 0) {
        AppLogger.warning('🚨 NEGATİF KALORİ ELENDİ: "${yemek.ad}" - Kalori: ${yemek.kalori}');
        return false;
      }
      // Çok düşük kalori kontrolü (10 kalori altı)
      if (yemek.kalori > 0 && yemek.kalori < 10) {
        AppLogger.warning('🚨 ÇOK DÜŞÜK KALORİ ELENDİ: "${yemek.ad}" - Kalori: ${yemek.kalori}');
        return false;
      }
      return true;
    }).toList();
    
    AppLogger.info('📊 BOZUK VERİ FİLTRESİ SONRASI: ${filtrelenmisYemekler.length}/${yemekler.length} yemek kaldı');
    
    if (filtrelenmisYemekler.isEmpty) {
      AppLogger.error('🚨 TÜM YEMEKLER ELENDİ! Fallback kullanılıyor');
      AppLogger.error('📋 Orjinal yemek örnekleri:');
      for (int i = 0; i < min(3, yemekler.length); i++) {
        final y = yemekler[i];
        AppLogger.error('   ${i+1}. ${y.ad} - K:${y.kalori} P:${y.protein} C:${y.karbonhidrat} Y:${y.yag}');
      }
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }

    // 🇹🇷 TÜRK KAHVALTISI KÜLTÜR FİLTRESİ
    if (ogunTipi == OgunTipi.kahvalti) {
      final turkKahvaltisiUygunlar = filtrelenmisYemekler.where(_turkKahvaltisinaUygunMu).toList();
      if (turkKahvaltisiUygunlar.isNotEmpty) {
        filtrelenmisYemekler = turkKahvaltisiUygunlar;
        AppLogger.success('🇹🇷 TÜRK KAHVALTISI FİLTRESİ UYGULAND: ${turkKahvaltisiUygunlar.length}/${yemekler.length} yemek uygun');
      }
    }
    
    // 🔥 YUMUŞATILMIŞ GÜNLÜK ÇEŞİTLİLİK FİLTRESİ (V5.1)
    final bugun = DateTime.now();
    final bugunkuAnahtar = '${bugun.day}/${bugun.month}/${bugun.year}';
    
    // Bugün daha önce seçilmiş yemekleri filtrele
    final bugunSecilenler = _gunlukCesitlilikGecmisi.keys.where((key) => key.startsWith(bugunkuAnahtar)).toSet();
    final gunlukFiltreliYemekler = filtrelenmisYemekler.where((yemek) {
      final yemekKey = '$bugunkuAnahtar-${yemek.id}';
      return !bugunSecilenler.contains(yemekKey);
    }).toList();
    
    AppLogger.info('📅 GÜNLÜK ÇEŞİTLİLİK: Bugün seçilmiş ${bugunSecilenler.length} yemek var');
    AppLogger.info('🔍 ÇEŞİTLİLİK FİLTRESİ: ${gunlukFiltreliYemekler.length}/${filtrelenmisYemekler.length} benzersiz yemek');
    
    // Daha esnek eşik: %20'den fazla yemek kalıyorsa çeşitlilik filtresini uygula
    if (gunlukFiltreliYemekler.length >= (filtrelenmisYemekler.length * 0.2) || bugunSecilenler.isEmpty) {
      filtrelenmisYemekler = gunlukFiltreliYemekler;
      AppLogger.success('🌟 GÜNLÜK ÇEŞİTLİLİK FİLTRESİ UYGULAND: ${gunlukFiltreliYemekler.length} benzersiz yemek');
    } else {
      AppLogger.warning('⚠️ ÇEŞİTLİLİK FİLTRESİ ATLAND: Çok az yemek kalacaktı (${gunlukFiltreliYemekler.length})');
    }

    // 🔥 YUMUŞATILMIŞ PROTEİN FİLTRESİ (V5.1) - Ana öğünlerde çeşitlilik
    if (isAnaOgun && _gunlukSecilenAnaMalzemeler.length >= 6) { // 4 → 6 daha esnek
      final proteinFiltreliYemekler = filtrelenmisYemekler.where((yemek) {
        return yemek.proteinKaynagi == null || !_gunlukSecilenAnaMalzemeler.contains(yemek.proteinKaynagi);
      }).toList();
      AppLogger.info('🥩 PROTEİN FİLTRESİ: ${_gunlukSecilenAnaMalzemeler.length} kullanılmış, ${proteinFiltreliYemekler.length}/${filtrelenmisYemekler.length} uygun');
      
      if (proteinFiltreliYemekler.length >= (filtrelenmisYemekler.length * 0.15)) { // 0.2 → 0.15 daha esnek
        filtrelenmisYemekler = proteinFiltreliYemekler;
        AppLogger.success('🥩 PROTEİN ÇEŞİTLİLİK FİLTRESİ UYGULAND');
      } else {
        AppLogger.warning('⚠️ PROTEİN FİLTRESİ ATLAND: Çok az yemek kalacaktı');
      }
    }

    final skorluYemekler = <_SkorluYemek>[];
    for (final yemek in filtrelenmisYemekler) {
      final olcek = hedefKalori / (yemek.kalori > 0 ? yemek.kalori : hedefKalori);
      final guvenliOlcek = olcek.clamp(0.9, 1.1);
      
      final pFark = ((yemek.protein * guvenliOlcek - hedefProtein) / (hedefProtein > 0 ? hedefProtein : 1)).abs() * 100;
      final cFark = ((yemek.karbonhidrat * guvenliOlcek - hedefKarb) / (hedefKarb > 0 ? hedefKarb : 1)).abs() * 100;
      final yFark = ((yemek.yag * guvenliOlcek - hedefYag) / (hedefYag > 0 ? hedefYag : 1)).abs() * 100;
      
      // 🔥 ULTRA HASSAS SKORLAMA SİSTEMİ
      double skor = isAraOgun
        ? (pFark * 2.5) + (cFark * 8.0) + (yFark * 1.5)
        : (pFark * 2.0) + (cFark * 10.0) + (yFark * 1.8);

      double cezaPuani = 1.0;
      
      // 🔥 ÇEŞİTLİLİK BONUS SİSTEMİ
      if (_haftalikSecilenYemekler.contains(yemek.id)) {
        cezaPuani *= 2.5; // Haftalık tekrar cezası
      }
      
      // 🇹🇷 TÜRK KAHVALTISI BONUS
      if (ogunTipi == OgunTipi.kahvalti && _turkKahvaltisinaUygunMu(yemek)) {
        cezaPuani *= 0.5; // %50 bonus
      }
      
      final anaOgunler = [OgunTipi.kahvalti, OgunTipi.ogle, OgunTipi.aksam];
      if (anaOgunler.contains(ogunTipi) != anaOgunler.contains(yemek.ogun)) {
        cezaPuani *= 20.0;
      }

      skor *= cezaPuani;
      skorluYemekler.add(_SkorluYemek(yemek, skor));
    }

    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    
    // 🔥 ULTRA GENİŞ SEÇİM HAVUZU - MAKSİMUM ÇEŞİTLİLİK
    final topSecimler = skorluYemekler.take(max(1, (filtrelenmisYemekler.length * 0.60).round())).toList();
    final secilenYemek = topSecimler[_random.nextInt(topSecimler.length)].yemek;

    // 🔍 DETAYLI V5 LOGLAMA
    AppLogger.info('🍽️ V5 ${ogunTipi.name.toUpperCase()} SEÇİLDİ: ${secilenYemek.ad}');
    AppLogger.info('   📊 Hedef: K:${hedefKalori.toInt()} P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
    AppLogger.info('   📊 Yemek: K:${secilenYemek.kalori.toInt()} P:${secilenYemek.protein.toInt()}g C:${secilenYemek.karbonhidrat.toInt()}g Y:${secilenYemek.yag.toInt()}g');
    
    // 🥘 MALZEME DETAYLARI LOGLAMA
    AppLogger.info('   🥘 Malzemeler (${secilenYemek.malzemeler.length} adet):');
    for (int i = 0; i < secilenYemek.malzemeler.length; i++) {
      AppLogger.info('      ${i+1}. ${secilenYemek.malzemeler[i]}');
    }
    
    if (ogunTipi == OgunTipi.kahvalti) {
      AppLogger.info('   🇹🇷 Türk Kahvaltısı Uyumu: ${_turkKahvaltisinaUygunMu(secilenYemek) ? "✅ UYGUN" : "⚠️ NEUTRAL"}');
    }
    
    // 🔥 ÇEŞİTLİLİK KAYDI
    final kayitTarihi = DateTime.now();
    final kayitAnahtari = '${kayitTarihi.day}/${kayitTarihi.month}/${kayitTarihi.year}';
    final yemekKey = '$kayitAnahtari-${secilenYemek.id}';
    _gunlukCesitlilikGecmisi[yemekKey] = DateTime.now();
    
    if (secilenYemek.proteinKaynagi != null) {
      _gunlukSecilenAnaMalzemeler.add(secilenYemek.proteinKaynagi!);
      AppLogger.info('   🥩 Protein Kaynağı: ${secilenYemek.proteinKaynagi}');
    }
    if (isAnaOgun) {
      _haftalikSecilenYemekler.add(secilenYemek.id);
      AppLogger.info('   📅 Haftalık çeşitliliğe eklendi');
    }

    return secilenYemek;
  }
  
  Future<GunlukPlan> _guvenilFallbackPlan(
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
    DateTime tarih,
  ) async {
    final gunIndex = (tarih.day % 7);
    
    // 🔥 DİYETİSYEN STANDARDI KALORI DAĞILIMI - YÜKSEK KALORİ DESTEĞİ
    final bool yuksekKaloriModu = hedefKalori >= 2500;
    final bool bulkModu = hedefKalori >= 3000;
    
    double kahvaltiOran = yuksekKaloriModu ? 0.25 : 0.25;
    double araOgun1Oran = yuksekKaloriModu ? 0.12 : 0.15;
    double ogleOran = yuksekKaloriModu ? 0.22 : 0.25;
    double araOgun2Oran = yuksekKaloriModu ? 0.12 : 0.15;
    double aksamOran = yuksekKaloriModu ? 0.17 : 0.20;
    double geceOran = yuksekKaloriModu ? 0.12 : 0.0;
    
    final kahvalti = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.kahvalti, gunIndex), OgunTipi.kahvalti, hedefKalori * kahvaltiOran);
    final araOgun1 = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.araOgun1, gunIndex), OgunTipi.araOgun1, hedefKalori * araOgun1Oran);
    final ogleYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.ogle, gunIndex), OgunTipi.ogle, hedefKalori * ogleOran);
    final araOgun2 = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.araOgun2, gunIndex), OgunTipi.araOgun2, hedefKalori * araOgun2Oran);
    final aksamYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.aksam, gunIndex), OgunTipi.aksam, hedefKalori * aksamOran);
    
    // 🌃 GECE ATIŞTIRMA - YÜKSEK KALORİ PROFİLLERİ İÇİN
    Yemek? geceAtistirma;
    if (yuksekKaloriModu) {
      geceAtistirma = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.geceAtistirma, gunIndex), OgunTipi.geceAtistirma, hedefKalori * geceOran);
      AppLogger.info('🌃 FALLBACK GECE ATIŞTIRMA EKLENDI: ${geceAtistirma.ad} (${geceAtistirma.kalori.toInt()} kcal)');
    }
    
    AppLogger.info('🛡️ FALLBACK PLAN DAĞILIMI:');
    AppLogger.info('   🥞 Kahvaltı: ${kahvalti.kalori.toInt()} kcal (${(kahvaltiOran*100).toInt()}%)');
    AppLogger.info('   🍎 Ara 1: ${araOgun1.kalori.toInt()} kcal (${(araOgun1Oran*100).toInt()}%)');
    AppLogger.info('   🍽️ Öğle: ${ogleYemegi.kalori.toInt()} kcal (${(ogleOran*100).toInt()}%)');
    AppLogger.info('   🥜 Ara 2: ${araOgun2.kalori.toInt()} kcal (${(araOgun2Oran*100).toInt()}%)');
    AppLogger.info('   🌙 Akşam: ${aksamYemegi.kalori.toInt()} kcal (${(aksamOran*100).toInt()}%)');
    if (geceAtistirma != null) {
      AppLogger.info('   🌃 Gece: ${geceAtistirma.kalori.toInt()} kcal (${(geceOran*100).toInt()}%)');
    }
    
    return GunlukPlan(
      id: 'fallback_${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: araOgun2,
      aksamYemegi: aksamYemegi,
      geceAtistirma: geceAtistirma,
      makroHedefleri: MakroHedefleri(gunlukKalori: hedefKalori, gunlukProtein: hedefProtein, gunlukKarbonhidrat: hedefKarb, gunlukYag: hedefYag),
      fitnessSkoru: 90, // Genişletilmiş havuz için daha yüksek skor
    );
  }

  Yemek _fallbackYemekHavuzundanSec(OgunTipi ogun, int gunIndex) {
    final havuz = _fallbackYemekHavuzu.where((y) => y.ogun == ogun).toList();
    if (havuz.isEmpty) {
      return Yemek(id: 'acil_fallback', ad: 'Izgara Tavuk', ogun: ogun, kalori: 400, protein: 40, karbonhidrat: 5, yag: 20, malzemeler: ['Tavuk Göğsü (150g)'], hazirlamaSuresi: 20, zorluk: Zorluk.kolay);
    }
    return havuz[gunIndex % havuz.length];
  }

  // 🇹🇷 TÜRK KÜLTÜRÜ ODAKLI FALLBACK HAVUZU - GENİŞLETİLMİŞ VERSİYON
  static final List<Yemek> _fallbackYemekHavuzu = [
    // TÜRK KAHVALTILARI - ÇEŞİTLİ KALORİ SEVİYELERİ
    Yemek(id: 'fb_k_1', ad: 'Peynirli Omlet', ogun: OgunTipi.kahvalti, kalori: 420, protein: 25, karbonhidrat: 30, yag: 22, malzemeler: ['Yumurta (2 adet)', 'Tam Buğday Ekmeği (2 dilim)', 'Beyaz Peynir (50g)', 'Domates (1 adet)', 'Salatalık (1 adet)'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_2', ad: 'Bal Kaymak', ogun: OgunTipi.kahvalti, kalori: 580, protein: 22, karbonhidrat: 75, yag: 22, malzemeler: ['Ekmek (3 dilim)', 'Kaymak (45g)', 'Bal (2.5 YK)', 'Çay (1 bardak)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_3', ad: 'Menemen', ogun: OgunTipi.kahvalti, kalori: 520, protein: 26, karbonhidrat: 42, yag: 28, malzemeler: ['Yumurta (3 adet)', 'Domates (2 adet)', 'Biber (1 adet)', 'Esmer Ekmek (2 dilim)', 'Zeytin (8 adet)'], hazirlamaSuresi: 15, zorluk: Zorluk.orta),
    Yemek(id: 'fb_k_4', ad: 'Sucuklu Yumurta', ogun: OgunTipi.kahvalti, kalori: 620, protein: 32, karbonhidrat: 48, yag: 32, malzemeler: ['Yumurta (3 adet)', 'Sucuk (80g)', 'Ekmek (2 dilim)', 'Domates (1 adet)', 'Çay (1 bardak)'], hazirlamaSuresi: 12, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_5', ad: 'Börek Kahvaltı', ogun: OgunTipi.kahvalti, kalori: 680, protein: 28, karbonhidrat: 65, yag: 38, malzemeler: ['Su Böreği (3 dilim)', 'Beyaz Peynir (75g)', 'Çay (1 bardak)', 'Zeytin (10 adet)', 'Domates (1 adet)'], hazirlamaSuresi: 8, zorluk: Zorluk.kolay),
    
    // ÖĞLE YEMEKLERİ - YÜKSEK KALORİ SEÇENEKLERİ
    Yemek(id: 'fb_o_1', ad: 'Tavuklu Pilav', ogun: OgunTipi.ogle, kalori: 750, protein: 55, karbonhidrat: 85, yag: 20, malzemeler: ['Tavuk Göğsü (200g)', 'Pirinç Pilavı (200g)', 'Salata (1 büyük porsiyon)', 'Zeytinyağı (1.5 YK)'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_2', ad: 'Köfte Patates', ogun: OgunTipi.ogle, kalori: 820, protein: 45, karbonhidrat: 90, yag: 32, malzemeler: ['Köfte (6 adet)', 'Patates (250g)', 'Salata (1 büyük porsiyon)', 'Yogurt (150g)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_3', ad: 'Etli Fasulye', ogun: OgunTipi.ogle, kalori: 780, protein: 50, karbonhidrat: 85, yag: 26, malzemeler: ['Etli Fasulye (350g)', 'Pirinç Pilavı (180g)', 'Yogurt (100g)', 'Salata (1 porsiyon)', 'Ekmek (1 dilim)'], hazirlamaSuresi: 30, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_4', ad: 'Tavuk Şiş Bulgur', ogun: OgunTipi.ogle, kalori: 850, protein: 58, karbonhidrat: 95, yag: 28, malzemeler: ['Tavuk Şiş (250g)', 'Bulgur Pilavı (200g)', 'Salata (1 büyük porsiyon)', 'Zeytinyağı (1.5 YK)', 'Ekmek (1 dilim)'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
    
    // AKŞAM YEMEKLERİ - ÇEŞİTLİ SEÇENEKLER
    Yemek(id: 'fb_ak_1', ad: 'Sebzeli Tavuk', ogun: OgunTipi.aksam, kalori: 620, protein: 52, karbonhidrat: 45, yag: 28, malzemeler: ['Tavuk Göğsü (200g)', 'Sebze Sote (250g)', 'Bulgur (100g)', 'Zeytinyağı (1.5 YK)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_ak_2', ad: 'Balık Salata', ogun: OgunTipi.aksam, kalori: 580, protein: 48, karbonhidrat: 35, yag: 32, malzemeler: ['Levrek Fırında (200g)', 'Yeşil Salata (200g)', 'Zeytinyağı (2 YK)', 'Bulgur (75g)'], hazirlamaSuresi: 30, zorluk: Zorluk.orta),
    Yemek(id: 'fb_ak_3', ad: 'Et Sote', ogun: OgunTipi.aksam, kalori: 680, protein: 55, karbonhidrat: 45, yag: 38, malzemeler: ['Dana Eti (180g)', 'Sebze Karışımı (200g)', 'Pirinç (100g)', 'Zeytinyağı (1.5 YK)'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
    
    // ARA ÖĞÜNLER - PROTEIN ODAKLI YÜKSEK KALORİ
    Yemek(id: 'fb_a1_1', ad: 'Elma Ceviz', ogun: OgunTipi.araOgun1, kalori: 280, protein: 8, karbonhidrat: 35, yag: 15, malzemeler: ['Elma (1 büyük)', 'Ceviz (10 adet)', 'Bal (1 tk)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a1_2', ad: 'Protein Smoothie', ogun: OgunTipi.araOgun1, kalori: 350, protein: 28, karbonhidrat: 42, yag: 10, malzemeler: ['Süt (300ml)', 'Muz (1 adet)', 'Yulaf (40g)', 'Bal (1.5 YK)'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a1_3', ad: 'Yumurta Sandwich', ogun: OgunTipi.araOgun1, kalori: 420, protein: 22, karbonhidrat: 45, yag: 18, malzemeler: ['Haşlanmış Yumurta (2 adet)', 'Tam Buğday Ekmeği (3 dilim)', 'Avokado (75g)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
    
    Yemek(id: 'fb_a2_1', ad: 'Ballı Yoğurt', ogun: OgunTipi.araOgun2, kalori: 320, protein: 24, karbonhidrat: 38, yag: 8, malzemeler: ['Süzme Yoğurt (250g)', 'Bal (2 YK)', 'Ceviz (6 adet)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a2_2', ad: 'Kuruyemiş Karışımı', ogun: OgunTipi.araOgun2, kalori: 380, protein: 15, karbonhidrat: 32, yag: 25, malzemeler: ['Badem (20 adet)', 'Ceviz (8 adet)', 'Kuru Üzüm (40g)', 'Kaju (12 adet)'], hazirlamaSuresi: 1, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a2_3', ad: 'Peynir Meyve', ogun: OgunTipi.araOgun2, kalori: 350, protein: 20, karbonhidrat: 38, yag: 15, malzemeler: ['Cottage Peyniri (200g)', 'Üzüm (120g)', 'Badem (10 adet)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    
    // GECE ATIŞTIRMASI - YÜKSEK KALORİ PROFİLLERİ İÇİN
    Yemek(id: 'fb_gece_1', ad: 'Protein Atıştırma', ogun: OgunTipi.geceAtistirma, kalori: 420, protein: 35, karbonhidrat: 28, yag: 18, malzemeler: ['Süzme Yoğurt (250g)', 'Protein Tozu (25g)', 'Muz (0.5 adet)', 'Badem (8 adet)'], hazirlamaSuresi: 3, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_gece_2', ad: 'Sıcak Süt Bal', ogun: OgunTipi.geceAtistirma, kalori: 380, protein: 16, karbonhidrat: 45, yag: 14, malzemeler: ['Süt (400ml)', 'Bal (2.5 YK)', 'Tarçın (1 çimdik)', 'Badem (8 adet)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_gece_3', ad: 'Peynir Kraker', ogun: OgunTipi.geceAtistirma, kalori: 350, protein: 20, karbonhidrat: 28, yag: 18, malzemeler: ['Tam Buğday Kraker (8 adet)', 'Beyaz Peynir (100g)', 'Domates (1 orta)', 'Zeytinyağı (0.5 tk)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
  ];
}

class _SkorluYemek {
  final Yemek yemek;
  final double skor;
  _SkorluYemek(this.yemek, this.skor);
}

// Testler için public erişim noktaları
extension AIBeslenmeServisiV5TestExtension on AIBeslenmeServisiV5 {
  dynamic testParseMalzeme(String s) => _parseMalzeme(s);
  Yemek testYemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) => _yemekOlustur(bazYemek, ogunTipi, hedefKalori);
  bool testTurkKahvaltisinaUygunMu(Yemek yemek) => _turkKahvaltisinaUygunMu(yemek);
}