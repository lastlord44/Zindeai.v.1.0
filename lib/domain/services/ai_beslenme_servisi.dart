// ============================================================================
// lib/domain/services/ai_beslenme_servisi.dart
// AI TABANLI BESLENME VE ANTRENMAN PLANI SERVİSİ
// ============================================================================

import 'dart:convert';
import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../entities/makro_hedefleri.dart';
import '../../core/utils/app_logger.dart';

class AIBeslenmeServisi {
  static const String _apiKey = 'YOUR_API_KEY_HERE'; // API key buraya
  
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
      
      // Şimdilik mock data ile çalış, sonra gerçek AI entegrasyonu yapılacak
      final gunlukPlan = await _mockAIPlan(
        hedefKalori: hedefKalori,
        hedefProtein: hedefProtein,
        hedefKarb: hedefKarb,
        hedefYag: hedefYag,
        tarih: tarih ?? DateTime.now(),
      );
      
      // Tolerans kontrolü yap
      final toleransKontrol = _toleransKontrolEt(gunlukPlan);
      AppLogger.info('📊 Tolerans Kontrolü: $toleransKontrol');
      
      return gunlukPlan;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Beslenme Servisi Hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
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
    
    // Örnek yemekler (AI yerine geçici)
    final kahvalti = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_kahvalti',
      ad: 'Yumurtalı Omlet + Tam Buğday Ekmek + Avokado',
      ogun: OgunTipi.kahvalti,
      kalori: kahvaltiKalori,
      protein: hedefProtein * 0.20,
      karbonhidrat: hedefKarb * 0.20,
      yag: hedefYag * 0.20,
      malzemeler: ['Yumurta (2 adet)', 'Tam buğday ekmeği (2 dilim)', 'Avokado (1/2 adet)', 'Zeytinyağı (1 tsp)'],
      hazirlamaSuresi: 15,
      zorluk: Zorluk.kolay,
      etiketler: ['protein', 'sağlıklı'],
    );
    
    final araOgun1 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_araogun1',
      ad: 'Yoğurt + Muz + Badem',
      ogun: OgunTipi.araOgun1,
      kalori: araOgun1Kalori,
      protein: hedefProtein * 0.15,
      karbonhidrat: hedefKarb * 0.15,
      yag: hedefYag * 0.15,
      malzemeler: ['Süzme yoğurt (150g)', 'Muz (1 adet)', 'Badem (10 adet)'],
      hazirlamaSuresi: 5,
      zorluk: Zorluk.kolay,
      etiketler: ['pratik', 'sağlıklı'],
    );
    
    final ogleYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_ogle',
      ad: 'Izgara Tavuk + Bulgur Pilavı + Mevsim Salatası',
      ogun: OgunTipi.ogle,
      kalori: ogleKalori,
      protein: hedefProtein * 0.35,
      karbonhidrat: hedefKarb * 0.35,
      yag: hedefYag * 0.35,
      malzemeler: ['Tavuk göğsü (150g)', 'Bulgur (80g)', 'Salata sebzeleri', 'Zeytinyağı (1 YK)'],
      hazirlamaSuresi: 30,
      zorluk: Zorluk.orta,
      etiketler: ['protein', 'doyurucu'],
    );
    
    final araOgun2 = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_araogun2',
      ad: 'Elma + Ceviz',
      ogun: OgunTipi.araOgun2,
      kalori: araOgun2Kalori,
      protein: hedefProtein * 0.10,
      karbonhidrat: hedefKarb * 0.10,
      yag: hedefYag * 0.10,
      malzemeler: ['Elma (1 orta boy)', 'Ceviz (5 adet)'],
      hazirlamaSuresi: 2,
      zorluk: Zorluk.kolay,
      etiketler: ['pratik', 'doğal'],
    );
    
    final aksamYemegi = Yemek(
      id: '${DateTime.now().millisecondsSinceEpoch}_aksam',
      ad: 'Fırında Somon + Sebze Güveci',
      ogun: OgunTipi.aksam,
      kalori: aksamKalori,
      protein: hedefProtein * 0.20,
      karbonhidrat: hedefKarb * 0.20,
      yag: hedefYag * 0.20,
      malzemeler: ['Somon fileto (120g)', 'Patlıcan', 'Kabak', 'Domates', 'Soğan'],
      hazirlamaSuresi: 45,
      zorluk: Zorluk.orta,
      etiketler: ['protein', 'omega3'],
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
      return '✅ Tüm makrolar tolerans içinde';
    } else {
      return '⚠️ Tolerans aşan makrolar: ${toleranslar.join(', ')}';
    }
  }
  
  /// Gerçek AI API çağrısı (sonra implement edilecek)
  Future<Map<String, dynamic>> _callAI(String prompt) async {
    // TODO: OpenAI/Claude API entegrasyonu
    throw UnimplementedError('AI API entegrasyonu sonra yapılacak');
  }
  
  /// AI Prompt oluştur
  String _createPrompt({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
  }) {
    return '''
Sen profesyonel Türk diyetisyensin. Günlük beslenme planı oluştur.

HEDEFLER:
- Kalori: ${hedefKalori.toInt()} kcal
- Protein: ${hedefProtein.toInt()}g
- Karbonhidrat: ${hedefKarb.toInt()}g
- Yağ: ${hedefYag.toInt()}g

TOLERANS LİMİTLERİ:
- Kalori: ±15%
- Protein: ±10%
- Karbonhidrat: ±10%
- Yağ: ±10%

KURALLAR:
- ASLA balık/et/tavuk kahvaltıda olmasın!
- Türk mutfağı odaklı yemekler
- Gerçekçi porsiyonlar
- Tolerans aşılmasın
- Malzemeler detaylı belirt

${kisitlamalar.isNotEmpty ? 'KISITLAMALAR: ${kisitlamalar.join(', ')}' : ''}

JSON formatında çıktı ver:
{
  "kahvalti": {"ad": "yemek adı", "kalori": 0, "protein": 0, "karbonhidrat": 0, "yag": 0, "malzemeler": []},
  "araOgun1": {...},
  "ogleYemegi": {...},
  "araOgun2": {...},
  "aksamYemegi": {...}
}
''';
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
      
      // 7 günlük plan oluştur
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

  /// Alternatif yemek önerileri
  Future<List<Yemek>> alternatifleriGetir(Yemek yemek) async {
    try {
      AppLogger.info('🤖 AI Alternatif: ${yemek.ad} için alternatifler üretiliyor...');
      
      // AI API call - gerçek implementasyon sonra gelecek
      await Future.delayed(Duration(milliseconds: 300));

      // Mock alternatif yemekler (aynı öğün tipi ve benzer makrolar)
      final alternatiflter = <Yemek>[
        Yemek(
          id: '${yemek.id}_alt1',
          ad: '${yemek.ad} - AI Alternatifi 1',
          ogun: yemek.ogun,
          kalori: yemek.kalori * 0.95,
          protein: yemek.protein * 1.05,
          karbonhidrat: yemek.karbonhidrat * 0.9,
          yag: yemek.yag * 1.1,
          malzemeler: ['AI önerisi - Benzer besin değerleri'],
          hazirlamaSuresi: yemek.hazirlamaSuresi,
          zorluk: yemek.zorluk,
          etiketler: ['ai-onerisi', 'alternatif'],
        ),
        Yemek(
          id: '${yemek.id}_alt2',
          ad: '${yemek.ad} - AI Alternatifi 2',
          ogun: yemek.ogun,
          kalori: yemek.kalori * 1.05,
          protein: yemek.protein * 0.95,
          karbonhidrat: yemek.karbonhidrat * 1.1,
          yag: yemek.yag * 0.9,
          malzemeler: ['AI önerisi - Varyasyon'],
          hazirlamaSuresi: yemek.hazirlamaSuresi + 5,
          zorluk: yemek.zorluk,
          etiketler: ['ai-onerisi', 'varyasyon'],
        ),
      ];
      
      AppLogger.success('✅ ${alternatiflter.length} AI alternatifi oluşturuldu');
      return alternatiflter;
      
    } catch (e) {
      AppLogger.error('❌ AI alternatif önerisi hatası: $e');
      return [];
    }
  }
}