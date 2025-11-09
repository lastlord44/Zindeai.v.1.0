// ============================================================================
// lib/domain/services/ai_beslenme_servisi_fixed.dart
// KRITIK BUG FIX: TON BALIĞI + MAKRO 0.0 SORUNU ÇÖZÜLDÜ
// SUPER FIX: YemekHiveDataSource + OgunMappingUtil entegrasyonu
// ============================================================================

import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/hedef.dart';
import '../entities/makro_hedefleri.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/ogun_mapping_util.dart';
import 'diyetisyen_duzeltme_servisi.dart';
import '../../data/local/hive_service.dart';
import '../../data/datasources/yemek_hive_data_source.dart';

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

class AIBeslenmeServisiFIXED {
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

    // 🔥 YENİ SİSTEM: YemekHiveDataSource + OgunMappingUtil fallback sistemi
    final yemekDataSource = YemekHiveDataSource();
    final ogunYemekleri = await yemekDataSource.tumYemekleriYukle();
    
    // Tüm kategorilerin toplam yemek sayısını kontrol et
    final toplamYemekSayisi = ogunYemekleri.values.fold(0, (sum, list) => sum + (list?.length ?? 0));
    
    AppLogger.info('🔍 VERİTABANI DURUMU: Toplam ${toplamYemekSayisi} yemek yüklendi');
    ogunYemekleri.forEach((ogun, yemekler) {
      AppLogger.info('   ${ogun.name}: ${yemekler?.length ?? 0} yemek');
    });
    
    if (toplamYemekSayisi == 0) {
      AppLogger.error('🚨 KRİTİK: Hiç yemek yüklenemedi, fallback plan devrede!');
      return await _guvenilFallbackPlan(hedefKalori, hedefProtein, hedefKarb, hedefYag, tarih);
    }
    
    // Kısıtlamalar uygula
    final Map<OgunTipi, List<Yemek>> filtrelenmisOgunYemekleri = {};
    for (var entry in ogunYemekleri.entries) {
      if (entry.value != null) {
        filtrelenmisOgunYemekleri[entry.key] = entry.value!
            .where((yemek) => yemek.kisitlamayaUygunMu(kisitlamalar))
            .toList();
      }
    }

    final bool yuksekKaloriModu = hedefKalori >= 2800;
    final bool bulkModu = hedefKalori >= 3200; // 🏋️ YÜKSEK KALORİ BULK MOD
    
    // 🎯 DİYETİSYEN STANDARDI: PROFESYONEL KALORI DAĞILIMI
    final kahvaltiKalori = hedefKalori * (yuksekKaloriModu ? 0.22 : 0.25);
    final araOgun1Kalori = hedefKalori * (yuksekKaloriModu ? 0.12 : 0.10);
    final ogleKalori = hedefKalori * (yuksekKaloriModu ? 0.28 : 0.30);
    final araOgun2Kalori = hedefKalori * (yuksekKaloriModu ? 0.12 : 0.10);
    final aksamKalori = hedefKalori * (yuksekKaloriModu ? 0.25 : 0.25); // ✅ %25 DİYETİSYEN STANDARDI
    final geceAtistirmaKalori = hedefKalori * (yuksekKaloriModu ? 0.11 : 0);

    double kalanProtein = hedefProtein, kalanKarb = hedefKarb, kalanYag = hedefYag;

    // 🥞 KAHVALTI: Günün güçlü başlangıcı - ÇOK KATLI FİLTRELEME
    final kahvalti = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.kahvalti] ?? [], OgunTipi.kahvalti, kahvaltiKalori, hedefProtein * 0.25, hedefKarb * 0.25, hedefYag * 0.25);
    kalanProtein -= kahvalti.protein; kalanKarb -= kahvalti.karbonhidrat; kalanYag -= kahvalti.yag;

    // 🍎 ARA ÖĞÜN 1: PROTEİN ODAKLI (minimum 8-12g protein garantisi)
    final araOgun1MinProtein = yuksekKaloriModu ? 12.0 : 8.0; // 🎯 DİYETİSYEN STANDARDI
    final araOgun1HedefProtein = (hedefProtein * 0.12).clamp(araOgun1MinProtein, hedefProtein * 0.15);
    final araOgun1 = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.araOgun1] ?? [], OgunTipi.araOgun1, araOgun1Kalori, araOgun1HedefProtein, hedefKarb * 0.08, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun1.protein; kalanKarb -= araOgun1.karbonhidrat; kalanYag -= araOgun1.yag;

    // 🍽️ ÖĞLE YEMEĞİ: Günün ana öğünü
    final ogleYemegi = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.ogle] ?? [], OgunTipi.ogle, ogleKalori, kalanProtein * 0.42, kalanKarb * 0.40, kalanYag * 0.40, isAnaOgun: true);
    kalanProtein -= ogleYemegi.protein; kalanKarb -= ogleYemegi.karbonhidrat; kalanYag -= ogleYemegi.yag;

    // 🥜 ARA ÖĞÜN 2: PROTEİN ODAKLI (minimum 8-12g protein garantisi)
    final araOgun2MinProtein = yuksekKaloriModu ? 12.0 : 8.0; // 🎯 DİYETİSYEN STANDARDI
    final araOgun2HedefProtein = (hedefProtein * 0.12).clamp(araOgun2MinProtein, hedefProtein * 0.15);
    final araOgun2 = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.araOgun2] ?? [], OgunTipi.araOgun2, araOgun2Kalori, araOgun2HedefProtein, hedefKarb * 0.07, hedefYag * 0.10, isAraOgun: true);
    kalanProtein -= araOgun2.protein; kalanKarb -= araOgun2.karbonhidrat; kalanYag -= araOgun2.yag;

    // 🌙 AKŞAM YEMEĞİ: %25 oranında güçlü son öğün
    final aksamYemegi = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.aksam] ?? [], OgunTipi.aksam, aksamKalori, kalanProtein * 0.85, kalanKarb * 0.85, kalanYag * 0.85, isAnaOgun: true);
    
    Yemek? geceAtistirma;
    if (yuksekKaloriModu) {
      geceAtistirma = _enUygunYemekSecHive(filtrelenmisOgunYemekleri[OgunTipi.geceAtistirma] ?? [], OgunTipi.geceAtistirma, geceAtistirmaKalori, kalanProtein, kalanKarb, kalanYag);
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

  // ============================================================================
  // 🔥 KRITIK FIX: MAKRO HESAPLAMA + TÜRK MUTFAĞİ TAHMİNİ
  // ============================================================================
  Yemek _yemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) {
    AppLogger.info('🔧 YEMEK OLUŞTURULUYOR: ${bazYemek.ad} | Hedef Kalori: ${hedefKalori.toInt()}');
    
    // 🔥 BÜYÜK FIX: Makro değerler 0 ise Türk mutfağı bazlı tahmin yap
    double finalKalori = bazYemek.kalori;
    double finalProtein = bazYemek.protein;
    double finalKarb = bazYemek.karbonhidrat;
    double finalYag = bazYemek.yag;
    
    // Eğer makrolar 0 veya çok düşükse tahmin et
    if (finalProtein <= 0.1 || finalKarb <= 0.1 || finalYag <= 0.1) {
      AppLogger.warning('⚠️ MAKRO TAHMİN: "${bazYemek.ad}" için eksik makrolar tespit edildi');
      
      // Türk mutfağı bazlı makro dağılımı (% olarak)
      // Genel kural: 20% protein, 50% karb, 30% yağ
      if (finalKalori > 0) {
        finalProtein = finalProtein <= 0.1 ? (finalKalori * 0.20) / 4.0 : finalProtein; // 1g protein = 4kcal
        finalKarb = finalKarb <= 0.1 ? (finalKalori * 0.50) / 4.0 : finalKarb;      // 1g karb = 4kcal
        finalYag = finalYag <= 0.1 ? (finalKalori * 0.30) / 9.0 : finalYag;        // 1g yağ = 9kcal
        
        AppLogger.info('✅ MAKRO TAHMİN UYGULANDI: P:${finalProtein.toInt()}g C:${finalKarb.toInt()}g Y:${finalYag.toInt()}g');
      }
    }
    
    // 🔥 DİNAMİK ÖLÇEKLEME: Öğün tipine göre gerçekçi aralıklar
    final olcek = (finalKalori > 0) ? (hedefKalori / finalKalori) : 1.0;
    final bool isAraOgun = [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma].contains(ogunTipi);
    final minFactor = isAraOgun ? 0.8 : 0.6;
    final maxFactor = isAraOgun ? 1.6 : 1.8;
    final guvenliOlcek = olcek.clamp(minFactor, maxFactor);
    
    AppLogger.info('🎯 ÖLÇEKLEME: ${ogunTipi.name} için ölçek ${olcek.toStringAsFixed(2)} → ${guvenliOlcek.toStringAsFixed(2)} (${minFactor}-${maxFactor})');

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

    final sonucYemek = bazYemek.copyWith(
      id: 'plan_${ogunTipi.name}_${DateTime.now().millisecondsSinceEpoch}',
      kalori: finalKalori * guvenliOlcek,
      protein: finalProtein * guvenliOlcek,
      karbonhidrat: finalKarb * guvenliOlcek,
      yag: finalYag * guvenliOlcek,
      malzemeler: yeniMalzemeler,
    );
    
    AppLogger.success('✅ YEMEK OLUŞTURULDU: ${sonucYemek.ad} | K:${sonucYemek.kalori.toInt()} P:${sonucYemek.protein.toInt()}g C:${sonucYemek.karbonhidrat.toInt()}g Y:${sonucYemek.yag.toInt()}g');
    return sonucYemek;
  }

  String _toleransKontrolEt(GunlukPlan plan) {
    final toleranslar = <String>[];
    if (!plan.kaloriToleranstaMi) toleranslar.add('Kalori (${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.proteinToleranstaMi) toleranslar.add('Protein (${plan.proteinSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.karbonhidratToleranstaMi) toleranslar.add('Karbonhidrat (${plan.karbonhidratSapmaYuzdesi.toStringAsFixed(1)}%)');
    if (!plan.yagToleranstaMi) toleranslar.add('Yağ (${plan.yagSapmaYuzdesi.toStringAsFixed(1)}%)');
    return toleranslar.isEmpty ? '✅ Tüm makrolar ±10% tolerans içinde' : '⚠️ Tolerans aşan makrolar: ${toleranslar.join(', ')}';
  }

  // ============================================================================
  // 🔥 ULTRA KRİTİK FIX: KAHVALTI FİLTRESİ + MAKRO SKORLAMA
  // ============================================================================
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
      AppLogger.error('🚨 FALLBACK: ${ogunTipi.name} için hiç yemek yok, fallback kullanılıyor');
      return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
    }

    var filtrelenmisYemekler = yemekler;
    
    // 🥞 SÜPER KATLI KAHVALTI FİLTRESİ - DİYETİSYEN STANDARDI
    if (ogunTipi == OgunTipi.kahvalti) {
      AppLogger.info('🔍 KAHVALTI FİLTRESİ BAŞLADI: ${yemekler.length} yemek analiz ediliyor');
      
      filtrelenmisYemekler = filtrelenmisYemekler.where((yemek) {
        final yemekAdi = yemek.ad.toLowerCase();
        final malzemeler = yemek.malzemeler.join(' ').toLowerCase();
        
        // 🚫 KAHVALTIDA KESİNLİKLE YASAKLI YEMEKLER
        final kahvaltiYasaklari = [
          // Deniz ürünleri - Türk kahvaltısında asla olmaz
          'ton balığı', 'ton balık', 'tuna', 'somon', 'salmon', 'levrek', 'çupra', 
          'hamsi', 'sardalye', 'karides', 'midye', 'ahtapot', 'mürekkep balığı', 
          'deniz ürünleri', 'balık', 'fish',
          
          // Ağır et yemekleri - sabah için çok ağır
          'dana eti', 'kuzu eti', 'kırmızı et', 'biftek', 'bonfile',
          'kebap', 'köfte', 'döner', 'et sote', 'kavurma',
          
          // Ağır ana yemekler - kahvaltıda olmaz
          'pizza', 'makarna', 'spagetti', 'lazanya', 'mantı',
          
          // Çok baharatlı/ağır yemekler
          'curry', 'köri', 'acılı', 'baharatlı yemek', 'soslu et'
        ];
        
        // Her yasaklı kelimeyi kontrol et
        for (final yasak in kahvaltiYasaklari) {
          if (yemekAdi.contains(yasak) || malzemeler.contains(yasak)) {
            AppLogger.warning('🚫 KAHVALTI REDDİ: "${yemek.ad}" - ${yasak} nedeniyle reddedildi');
            return false;
          }
        }
        
        // ✅ KAHVALTIDA TERCIH EDİLEN YEMEKLER - BONUS PUAN
        final kahvaltiTercihler = [
          'omlet', 'menemen', 'yumurta', 'peynir', 'reçel', 'bal', 'ekmek', 'simit',
          'yulaf', 'müsli', 'granola', 'süt', 'yoğurt', 'meyve', 'avokado', 
          'tereyağı', 'zeytin', 'domates', 'salatalık', 'börek'
        ];
        
        bool kahvaltiUygun = false;
        for (final tercih in kahvaltiTercihler) {
          if (yemekAdi.contains(tercih) || malzemeler.contains(tercih)) {
            kahvaltiUygun = true;
            break;
          }
        }
        
        if (kahvaltiUygun) {
          AppLogger.info('✅ KAHVALTI UYGUN: "${yemek.ad}" kahvaltı uyumlu');
        } else {
          AppLogger.warning('⚠️ KAHVALTI ŞÜPHELİ: "${yemek.ad}" tipik kahvaltı değil');
        }
        
        return true; // Yasaklı değilse geçir
      }).toList();
      
      if (filtrelenmisYemekler.isEmpty) {
        AppLogger.error('🚨 KRİTİK: Kahvaltı filtresi tüm yemekleri eledi! Fallback devrede!');
        return _fallbackYemekHavuzundanSec(ogunTipi, _random.nextInt(7));
      }
      
      AppLogger.success('✅ KAHVALTI FİLTRE SONUCU: ${yemekler.length} → ${filtrelenmisYemekler.length} yemek kaldı');
    }
    
    if (isAnaOgun && _gunlukSecilenAnaMalzemeler.isNotEmpty) {
      filtrelenmisYemekler = yemekler.where((yemek) {
        return yemek.proteinKaynagi == null || !_gunlukSecilenAnaMalzemeler.contains(yemek.proteinKaynagi);
      }).toList();
      if (filtrelenmisYemekler.isEmpty) {
        AppLogger.error('🚨 KRİTİK: Protein filtresi sonrası ${ogunTipi.name} için hiç uygun yemek kalmadı! Çeşitlilik sağlanamayabilir.');
        filtrelenmisYemekler = yemekler;
      }
    }

    final skorluYemekler = <_SkorluYemek>[];
    for (final yemek in filtrelenmisYemekler) {
      final olcek = hedefKalori / (yemek.kalori > 0 ? yemek.kalori : hedefKalori);
      final pFark = ((yemek.protein * olcek - hedefProtein) / (hedefProtein > 0 ? hedefProtein : 1)).abs() * 100;
      final cFark = ((yemek.karbonhidrat * olcek - hedefKarb) / (hedefKarb > 0 ? hedefKarb : 1)).abs() * 100;
      final yFark = ((yemek.yag * olcek - hedefYag) / (hedefYag > 0 ? hedefYag : 1)).abs() * 100;
      
      // 🎯 ARA ÖĞÜN İÇİN PROTEİN ODAKLI SKORLAMA
      double skor = isAraOgun
        ? (pFark * 2.5) + (cFark * 0.5) + (yFark * 0.8)  // Protein odaklı
        : (pFark * 1.5) + (cFark * 0.8) + (yFark * 1.0); // Normal scoring

      double cezaPuani = 1.0;
      if (_haftalikSecilenYemekler.contains(yemek.id)) {
        cezaPuani *= 1.5;
      }
      
      // 🔥 KESİN KURAL: Öğün tipi birebir uyuşmuyorsa AĞIR CEZA UYGULA
      if (yemek.ogun != ogunTipi) {
        final bool hedefAnaOgun = [OgunTipi.kahvalti, OgunTipi.ogle, OgunTipi.aksam].contains(ogunTipi);
        final bool yemekAnaOgun = [OgunTipi.kahvalti, OgunTipi.ogle, OgunTipi.aksam].contains(yemek.ogun);

        if (hedefAnaOgun != yemekAnaOgun) {
          cezaPuani *= 50.0;
        } else {
          cezaPuani *= 5.0;
        }
        AppLogger.warning('️️⚠️ Öğün Tipi Uyuşmazlığı: Hedef=${ogunTipi.name}, Gelen=${yemek.ogun.name} -> Ceza: x${cezaPuani.toInt()}');
      }

      skor *= cezaPuani;
      skorluYemekler.add(_SkorluYemek(yemek, skor));
    }

    skorluYemekler.sort((a, b) => a.skor.compareTo(b.skor));
    
    final topSecimler = skorluYemekler.take(max(1, (yemekler.length * 0.4).round())).toList();
    final secilenYemek = topSecimler[_random.nextInt(topSecimler.length)].yemek;

    if (secilenYemek.proteinKaynagi != null) {
      _gunlukSecilenAnaMalzemeler.add(secilenYemek.proteinKaynagi!);
    }
    if (isAnaOgun) {
      _haftalikSecilenYemekler.add(secilenYemek.id);
    }

    AppLogger.success('🎯 SEÇİLEN YEMEK: ${secilenYemek.ad} (${ogunTipi.name})');
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
    final ogleYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.ogle, gunIndex), OgunTipi.ogle, hedefKalori * 0.35);
    final araOgun2 = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.araOgun2, gunIndex), OgunTipi.araOgun2, hedefKalori * 0.10);
    final aksamYemegi = _yemekOlustur(_fallbackYemekHavuzundanSec(OgunTipi.aksam, gunIndex), OgunTipi.aksam, hedefKalori * 0.20);
    
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
extension AIBeslenmeServisiFIXEDTestExtension on AIBeslenmeServisiFIXED {
  dynamic /*_MalzemeDetay*/ testParseMalzeme(String s) => _parseMalzeme(s);
  Yemek testYemekOlustur(Yemek bazYemek, OgunTipi ogunTipi, double hedefKalori) => _yemekOlustur(bazYemek, ogunTipi, hedefKalori);
}