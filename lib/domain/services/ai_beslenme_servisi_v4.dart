// ============================================================================
// lib/domain/services/ai_beslenme_servisi_v4.dart
// DİYETİSYEN STANDARDI HIVE DESTEKLİ BESLENME SERVİSİ (v4.0)
// 🎯 PROFESYONEL DİYETİSYEN DÜZELTMELERİ İLE
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

class AIBeslenmeServisiV4 {
  Random _random = Random();
  final Set<String> _haftalikSecilenYemekler = {};
  final Set<String> _gunlukSecilenAnaMalzemeler = {};
  final DiyetisyenDuzeltmeServisi _diyetisyenServisi = DiyetisyenDuzeltmeServisi();
  
  void _cesitlilikDurumuLogla() {
    AppLogger.info('🔍 ÇEŞİTLİLİK DURUMU:');
    AppLogger.info('   📅 Haftalık seçilenler: ${_haftalikSecilenYemekler.length} adet');
    AppLogger.info('   🥩 Günlük protein kaynakları: ${_gunlukSecilenAnaMalzemeler.length} adet');
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
      AppLogger.info('🎯 Plan oluşturuluyor: ${hedefKalori.toInt()} kcal | P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
      
      _cesitlilikDurumuLogla();

      GunlukPlan gunlukPlan = await _mockAIPlan(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: planTarihi,
        kisitlamalar: kisitlamalar,
      );

      AppLogger.success('✅ Plan oluşturuldu: ${gunlukPlan.kahvalti?.ad} | ${gunlukPlan.ogleYemegi?.ad} | ${gunlukPlan.aksamYemegi?.ad}');
      
      final toleransKontrol = _toleransKontrolEt(gunlukPlan);
      AppLogger.info('📊 Final Tolerans Kontrolü: $toleransKontrol');
      return gunlukPlan;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Beslenme Servisi Hatası', error: e, stackTrace: stackTrace);
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
        AppLogger.error('❌ ARKA PLAN - Gün ${gun + 1} planı oluşturulamadı: $e');
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
    final benzersizSeed = tarih.year * 10000 + tarih.month * 100 + tarih.day + tarih.hour;
    _random = Random(benzersizSeed);

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

    // 🎯 DİYETİSYEN STANDARDI: TOLERANS ODAKLI ESNETİLEBİLİR KALORI DAĞILIMI
    final bool yuksekKaloriModu = hedefKalori >= 2500;
    final bool bulkModu = hedefKalori >= 3000; // 🏋️ YÜKSEK KALORİ BULK MOD
    
    // 🔥 ULTRA DENGELI DAĞILIM - MAKRO ODAKLI
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

    // 🥞 KAHVALTI: Günün güçlü başlangıcı
    final kahvalti = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.kahvalti] ?? [], OgunTipi.kahvalti, kahvaltiKalori, hedefProtein * 0.25, hedefKarb * 0.25, hedefYag * 0.25);
    kalanProtein -= kahvalti.protein; kalanKarb -= kahvalti.karbonhidrat; kalanYag -= kahvalti.yag;

    // 🍎 ARA ÖĞÜN 1: PROTEİN ODAKLI (minimum 8-12g protein garantisi)
    final araOgun1MinProtein = yuksekKaloriModu ? 12.0 : 8.0; // 🎯 DİYETİSYEN STANDARDI
    final araOgun1HedefProtein = (hedefProtein * 0.12).clamp(araOgun1MinProtein, hedefProtein * 0.15);
    final araOgun1 = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.araOgun1] ?? [], OgunTipi.araOgun1, araOgun1Kalori, araOgun1HedefProtein, hedefKarb * 0.08, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun1.protein; kalanKarb -= araOgun1.karbonhidrat; kalanYag -= araOgun1.yag;

    // 🍽️ ÖĞLE YEMEĞİ: Günün ana öğünü
    final ogleYemegi = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.ogle] ?? [], OgunTipi.ogle, ogleKalori, kalanProtein * 0.42, kalanKarb * 0.40, kalanYag * 0.40, isAnaOgun: true);
    kalanProtein -= ogleYemegi.protein; kalanKarb -= ogleYemegi.karbonhidrat; kalanYag -= ogleYemegi.yag;

    // 🥜 ARA ÖĞÜN 2: PROTEİN ODAKLI (minimum 8-12g protein garantisi)  
    final araOgun2MinProtein = yuksekKaloriModu ? 12.0 : 8.0; // 🎯 DİYETİSYEN STANDARDI
    final araOgun2HedefProtein = (hedefProtein * 0.12).clamp(araOgun2MinProtein, hedefProtein * 0.15);
    final araOgun2 = _enUygunYemekSecHive(ogunYemekleri[OgunTipi.araOgun2] ?? [], OgunTipi.araOgun2, araOgun2Kalori, araOgun2HedefProtein, hedefKarb * 0.07, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun2.protein; kalanKarb -= araOgun2.karbonhidrat; kalanYag -= araOgun2.yag;

    // 🌙 AKŞAM YEMEĞİ: %25 oranında güçlü son öğün
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

  Yemek _yemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) {
    if (bazYemek.kalori <= 0) {
      return bazYemek.copyWith(id: 'plan_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}');
    }

    final olcek = hedefKalori / bazYemek.kalori;
    final guvenliOlcek = olcek.clamp(0.9, 1.1); // 🔥 ULTRA SIKI KONTROL: ±10% max

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

    return bazYemek.copyWith(
      id: 'plan_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}',
      kalori: bazYemek.kalori * guvenliOlcek,
      protein: bazYemek.protein * guvenliOlcek,
      karbonhidrat: bazYemek.karbonhidrat * guvenliOlcek,
      yag: bazYemek.yag * guvenliOlcek,
      malzemeler: yeniMalzemeler,
    );
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
    bool isAraOgun = false, // 🎯 ARA ÖĞÜN KONTROLÜ
  }) {
    if (yemekler.isEmpty) {
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }

    // 🔥 KRİTİK FİX: BOZUK VERİLERİ FİLTRELE!
    var filtrelenmisYemekler = yemekler.where((yemek) {
      // KALORI = 0 olan yemekleri eleme
      if (yemek.kalori <= 0) {
        AppLogger.warning('🚨 BOZUK VERİ ELENDİ: "${yemek.ad}" - Kalori: ${yemek.kalori}');
        return false;
      }
      // Minimum makro kontrolü
      if (yemek.protein < 0.5 && yemek.karbonhidrat < 1.0 && yemek.yag < 0.2) {
        AppLogger.warning('🚨 BOZUK MAKRO ELENDİ: "${yemek.ad}" - P:${yemek.protein} C:${yemek.karbonhidrat} Y:${yemek.yag}');
        return false;
      }
      return true;
    }).toList();
    
    if (filtrelenmisYemekler.isEmpty) {
      AppLogger.error('🚨 TÜM YEMEKLER BOZUK! Fallback kullanılıyor');
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }
    // 🔥 MEGA OVERHAUL: PROTEİN FİLTRESİ RADİKAL GEVŞETİLDİ - 5749 YEMEĞİN HEPSI KULLANILSIN!
    if (isAnaOgun && _gunlukSecilenAnaMalzemeler.length >= 5) { // 5 protein kaynağı kullanılana kadar filtre YOK
      filtrelenmisYemekler = yemekler.where((yemek) {
        return yemek.proteinKaynagi == null || !_gunlukSecilenAnaMalzemeler.contains(yemek.proteinKaynagi);
      }).toList();
      if (filtrelenmisYemekler.length < (yemekler.length * 0.1)) { // %10'dan az kaldıysa filtreleme yapma
        AppLogger.warning('🚨 PROTEİN FİLTRESİ TAM GEVŞETİLDİ: MAKSİMUM ÇEŞİTLİLİK MOD AKTIF!');
        filtrelenmisYemekler = yemekler;
      }
    }

    // 🔥 TOLERANS KONTROLÜ: İlk filtrele, sonra skorla
    final toleransliYemekler = <Yemek>[];
    final toleransDisiYemekler = <Yemek>[];
    
    for (final yemek in filtrelenmisYemekler) {
      final olcek = hedefKalori / (yemek.kalori > 0 ? yemek.kalori : hedefKalori);
      final guvenliOlcek = olcek.clamp(0.9, 1.1); // Ultra sıkı ölçek kontrolü
      
      final pFark = ((yemek.protein * guvenliOlcek - hedefProtein) / (hedefProtein > 0 ? hedefProtein : 1)).abs() * 100;
      final cFark = ((yemek.karbonhidrat * guvenliOlcek - hedefKarb) / (hedefKarb > 0 ? hedefKarb : 1)).abs() * 100;
      final yFark = ((yemek.yag * guvenliOlcek - hedefYag) / (hedefYag > 0 ? hedefYag : 1)).abs() * 100;
      
      // 🔥 MEGA OVERHAUL TOLERANSLAR - MAKSİMUM ÇEŞİTLİLİK İÇİN ULTRA GENİŞ!
      final toleranstaMi = pFark <= 25 && cFark <= 30 && yFark <= 25; // RADIKAL geniş tolerans - 5749 yemek kullan!
      
      if (toleranstaMi) {
        toleransliYemekler.add(yemek);
      } else {
        toleransDisiYemekler.add(yemek);
      }
    }
    
    // 🔥 ÖNCELİK: Tolerans içindeki yemekleri tercih et
    final secimHavuzu = toleransliYemekler.isNotEmpty ? toleransliYemekler : toleransDisiYemekler;
    
    final skorluYemekler = <_SkorluYemek>[];
    for (final yemek in secimHavuzu) {
      final olcek = hedefKalori / (yemek.kalori > 0 ? yemek.kalori : hedefKalori);
      final guvenliOlcek = olcek.clamp(0.9, 1.1);
      
      final pFark = ((yemek.protein * guvenliOlcek - hedefProtein) / (hedefProtein > 0 ? hedefProtein : 1)).abs() * 100;
      final cFark = ((yemek.karbonhidrat * guvenliOlcek - hedefKarb) / (hedefKarb > 0 ? hedefKarb : 1)).abs() * 100;
      final yFark = ((yemek.yag * guvenliOlcek - hedefYag) / (hedefYag > 0 ? hedefYag : 1)).abs() * 100;
      
      // 🔥 MEGA OVERHAUL SKORLAMA - KARBONHIDRAT HEDEFLEMESİ ULTRA HASSAS!
      double skor = isAraOgun
        ? (pFark * 2.5) + (cFark * 8.0) + (yFark * 1.5)  // Karbonhidrat MUTLAK KRİTİK!
        : (pFark * 2.0) + (cFark * 10.0) + (yFark * 1.8); // Karbonhidrat ULTRA KRİTİK!
      
      // 🔥 ABSOLUTE TOLERANS BONUSU: Tolerans içinde olanlar mutlak öncelik
      if (toleransliYemekler.contains(yemek)) {
        skor *= 0.01; // %99 bonus - garantili seçim
      }

      double cezaPuani = 1.0;
      if (_haftalikSecilenYemekler.contains(yemek.id)) {
        cezaPuani *= 1.8; // 🔥 MEGA OVERHAUL: MİNİMUM TEKRAR CEZASI - 5749 YEMEĞİ KULLAN!
      }
      
      final anaOgunler = [OgunTipi.kahvalti, OgunTipi.ogle, OgunTipi.aksam];
      if (anaOgunler.contains(ogunTipi) != anaOgunler.contains(yemek.ogun)) {
        cezaPuani *= 15.0; // Daha az ceza
      }

      skor *= cezaPuani;
      skorluYemekler.add(_SkorluYemek(yemek, skor));
    }

    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    
    // 🔥 MEGA OVERHAUL: MAKSİMUM ÇEŞİTLİLİK HAVUZU %90 - 5749 YEMEĞİN HEPSI KULLANILSIN!
    final topSecimler = skorluYemekler.take(max(1, (secimHavuzu.length * 0.90).round())).toList();
    final secilenYemek = topSecimler[_random.nextInt(topSecimler.length)].yemek;

    // 🔍 DETAYLI YEMEK SEÇİM LOGLAMA
    AppLogger.info('🍽️ ${ogunTipi.name.toUpperCase()} SEÇİLDİ: ${secilenYemek.ad}');
    AppLogger.info('   📊 Hedef: K:${hedefKalori.toInt()} P:${hedefProtein.toInt()}g C:${hedefKarb.toInt()}g Y:${hedefYag.toInt()}g');
    AppLogger.info('   📊 Yemek: K:${secilenYemek.kalori.toInt()} P:${secilenYemek.protein.toInt()}g C:${secilenYemek.karbonhidrat.toInt()}g Y:${secilenYemek.yag.toInt()}g');
    AppLogger.info('   🍳 Malzemeler: ${secilenYemek.malzemeler.join(', ')}');
    AppLogger.info('   ⭐ Skor: ${skorluYemekler.firstWhere((s) => s.yemek.id == secilenYemek.id).skor.toStringAsFixed(1)}');
    
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
    final kahvalti = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.kahvalti, gunIndex), OgunTipi.kahvalti, hedefKalori * 0.25);
    final araOgun1 = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.araOgun1, gunIndex), OgunTipi.araOgun1, hedefKalori * 0.10);
    final ogleYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.ogle, gunIndex), OgunTipi.ogle, hedefKalori * 0.30);
    final araOgun2 = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.araOgun2, gunIndex), OgunTipi.araOgun2, hedefKalori * 0.10);
    final aksamYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.aksam, gunIndex), OgunTipi.aksam, hedefKalori * 0.25);
    
    return GunlukPlan(
      id: 'fallback_${tarih.millisecondsSinceEpoch}',
      tarih: tarih,
      kahvalti: kahvalti,
      araOgun1: araOgun1,
      ogleYemegi: ogleYemegi,
      araOgun2: araOgun2,
      aksamYemegi: aksamYemegi,
      makroHedefleri: MakroHedefleri(gunlukKalori: hedefKalori, gunlukProtein: hedefProtein, gunlukKarbonhidrat: hedefKarb, gunlukYag: hedefYag),
      fitnessSkoru: 85,
    );
  }

  Yemek _fallbackYemekHavuzundanSec(OgunTipi ogun, int gunIndex) {
    final havuz = _fallbackYemekHavuzu.where((y) => y.ogun == ogun).toList();
    if (havuz.isEmpty) {
      return Yemek(id: 'acil_fallback', ad: 'Izgara Tavuk', ogun: ogun, kalori: 400, protein: 40, karbonhidrat: 5, yag: 20, malzemeler: ['Tavuk Göğsü (150g)'], hazirlamaSuresi: 20, zorluk: Zorluk.kolay);
    }
    return havuz[gunIndex % havuz.length];
  }

  static final List<Yemek> _fallbackYemekHavuzu = [
    Yemek(id: 'fb_k_1', ad: 'Peynirli Omlet', ogun: OgunTipi.kahvalti, kalori: 420, protein: 25, karbonhidrat: 30, yag: 22, malzemeler: ['Yumurta (2 adet)', 'Tam Buğday Ekmeği (2 dilim)', 'Beyaz Peynir (50g)', 'Domates (1 adet)', 'Salatalık (1 adet)'], hazirlamaSuresi: 10, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_2', ad: 'Ballı Yulaf', ogun: OgunTipi.kahvalti, kalori: 480, protein: 20, karbonhidrat: 75, yag: 15, malzemeler: ['Yulaf Ezmesi (80g)', 'Süt (200ml)', 'Muz (1 adet)', 'Badem (10 adet)', 'Bal (1 YK)'], hazirlamaSuresi: 5, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_k_3', ad: 'Menemen', ogun: OgunTipi.kahvalti, kalori: 450, protein: 22, karbonhidrat: 35, yag: 25, malzemeler: ['Yumurta (2 adet)', 'Domates (2 adet)', 'Biber (1 adet)', 'Esmer Ekmek (2 dilim)', 'Avokado (1/2 adet)'], hazirlamaSuresi: 15, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_1', ad: 'Tavuklu Pilav', ogun: OgunTipi.ogle, kalori: 550, protein: 45, karbonhidrat: 55, yag: 15, malzemeler: ['Tavuk Göğsü (150g)', 'Pirinç Pilavı (150g)', 'Salata (1 porsiyon)', 'Zeytinyağı (1 YK)'], hazirlamaSuresi: 25, zorluk: Zorluk.orta),
    Yemek(id: 'fb_o_2', ad: 'Somon Bulgur', ogun: OgunTipi.ogle, kalori: 620, protein: 40, karbonhidrat: 60, yag: 25, malzemeler: ['Somon Fileto (150g)', 'Bulgur Pilavı (150g)', 'Brokoli (150g)', 'Limon (1/2 adet)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_ak_1', ad: 'Izgara Somon', ogun: OgunTipi.aksam, kalori: 450, protein: 40, karbonhidrat: 20, yag: 25, malzemeler: ['Izgara Somon (150g)', 'Sebze Sote (200g)', 'Bulgur (50g)', 'Zeytinyağı (1 tatlı kaşığı)'], hazirlamaSuresi: 20, zorluk: Zorluk.orta),
    Yemek(id: 'fb_a1_1', ad: 'Elma & Badem', ogun: OgunTipi.araOgun1, kalori: 170, protein: 4, karbonhidrat: 25, yag: 7, malzemeler: ['Elma (1 orta)', 'Badem (10 adet)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
    Yemek(id: 'fb_a2_1', ad: 'Ballı Yoğurt', ogun: OgunTipi.araOgun2, kalori: 180, protein: 15, karbonhidrat: 20, yag: 4, malzemeler: ['Süzme Yoğurt (150g)', 'Bal (1 tatlı kaşığı)'], hazirlamaSuresi: 2, zorluk: Zorluk.kolay),
  ];
}

class _SkorluYemek {
  final Yemek yemek;
  final double skor;
  _SkorluYemek(this.yemek, this.skor);
}

// Testler için public erişim noktaları
extension AIBeslenmeServisiV4TestExtension on AIBeslenmeServisiV4 {
  dynamic testParseMalzeme(String s) => _parseMalzeme(s);
  Yemek testYemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) => _yemekOlustur(bazYemek, ogunTipi, hedefKalori);
}