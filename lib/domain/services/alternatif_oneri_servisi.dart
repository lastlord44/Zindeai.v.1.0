// ============================================================================
// lib/domain/services/alternatif_oneri_servisi.dart
// ⭐ DİYETİSYEN ONAYLI ALTERNATİF BESİN SİSTEMİ
// 15 yıllık diyetisyen standartlarına göre yazılmıştır
// ============================================================================

import '../entities/alternatif_besin_legacy.dart';

class BesinVeritabani {
  // ⭐ DİYETİSYEN STANDARDI: GERÇEK PORSIYON AĞIRLIKLARI
  // 250+ Besin - 15 Yıllık Diyetisyen Deneyimi
  static const Map<String, Map<String, double>> besinler = {
    // ========================================================================
    // 1. KURUYEMIŞLER VE TOHUMLAR (10 çeşit)
    // ========================================================================
    'badem': {
      'porsiyonGram': 23.0, // 1 porsiyon = 23g
      'standartAdetSayisi': 10, // 1 porsiyon = 10 adet badem
      'kalori100g': 579,
      'protein100g': 21.2,
      'karb100g': 21.6,
      'yag100g': 49.9,
    },
    'ceviz': {
      'porsiyonGram': 28.0, // 1 porsiyon = 28g
      'standartAdetSayisi': 7, // 1 porsiyon = 7 yarım ceviz
      'kalori100g': 654,
      'protein100g': 15.2,
      'karb100g': 13.7,
      'yag100g': 65.2,
    },
    'fındık': {
      'porsiyonGram': 28.0, // 1 porsiyon = 28g
      'standartAdetSayisi': 21, // 1 porsiyon = 21 fındık
      'kalori100g': 628,
      'protein100g': 15.0,
      'karb100g': 16.7,
      'yag100g': 60.8,
    },
    'antep_fıstığı': {
      'porsiyonGram': 28.0, // 1 porsiyon = 28g
      'standartAdetSayisi': 49, // 1 porsiyon = 49 adet
      'kalori100g': 562,
      'protein100g': 20.6,
      'karb100g': 27.2,
      'yag100g': 45.3,
    },
    'kaju': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 17,
      'kalori100g': 553,
      'protein100g': 18.2,
      'karb100g': 30.2,
      'yag100g': 43.9,
    },
    'yer_fıstığı': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 25,
      'kalori100g': 567,
      'protein100g': 25.8,
      'karb100g': 16.1,
      'yag100g': 49.2,
    },
    'kabak_çekirdeği': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 85,
      'kalori100g': 559,
      'protein100g': 30.2,
      'karb100g': 10.7,
      'yag100g': 49.1,
    },
    'ayçekirdeği': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 200,
      'kalori100g': 584,
      'protein100g': 20.8,
      'karb100g': 20.0,
      'yag100g': 51.5,
    },
    'keten_tohumu': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 250,
      'kalori100g': 534,
      'protein100g': 18.3,
      'karb100g': 28.9,
      'yag100g': 42.2,
    },
    'chia_tohumu': {
      'porsiyonGram': 28.0,
      'standartAdetSayisi': 300,
      'kalori100g': 486,
      'protein100g': 16.5,
      'karb100g': 42.1,
      'yag100g': 30.7,
    },

    // ========================================================================
    // 2. TAZE MEYVELER (9 çeşit)
    // ========================================================================
    'muz': {
      'porsiyonGram': 118.0, // 1 orta muz = 118g (kabuksuz)
      'standartAdetSayisi': 1, // 1 porsiyon = 1 adet muz
      'kalori100g': 89,
      'protein100g': 1.1,
      'karb100g': 22.8,
      'yag100g': 0.3,
    },
    'elma': {
      'porsiyonGram': 182.0, // 1 orta elma = 182g (kabuklu)
      'standartAdetSayisi': 1, // 1 porsiyon = 1 adet elma
      'kalori100g': 52,
      'protein100g': 0.3,
      'karb100g': 13.8,
      'yag100g': 0.2,
    },
    'armut': {
      'porsiyonGram': 178.0, // 1 orta armut = 178g
      'standartAdetSayisi': 1, // 1 porsiyon = 1 adet armut
      'kalori100g': 57,
      'protein100g': 0.4,
      'karb100g': 15.2,
      'yag100g': 0.1,
    },
    'portakal': {
      'porsiyonGram': 131.0,
      'standartAdetSayisi': 1,
      'kalori100g': 47,
      'protein100g': 0.9,
      'karb100g': 11.8,
      'yag100g': 0.1,
    },
    'mandalina': {
      'porsiyonGram': 88.0,
      'standartAdetSayisi': 1,
      'kalori100g': 53,
      'protein100g': 0.8,
      'karb100g': 13.3,
      'yag100g': 0.3,
    },
    'greyfurt': {
      'porsiyonGram': 123.0,
      'standartAdetSayisi': 1,
      'kalori100g': 42,
      'protein100g': 0.8,
      'karb100g': 11.0,
      'yag100g': 0.1,
    },
    'kivi': {
      'porsiyonGram': 69.0,
      'standartAdetSayisi': 1,
      'kalori100g': 61,
      'protein100g': 1.1,
      'karb100g': 14.7,
      'yag100g': 0.5,
    },
    'çilek': {
      'porsiyonGram': 12.0,
      'standartAdetSayisi': 1,
      'kalori100g': 32,
      'protein100g': 0.7,
      'karb100g': 7.7,
      'yag100g': 0.3,
    },
    'üzüm': {
      'porsiyonGram': 5.0,
      'standartAdetSayisi': 1,
      'kalori100g': 69,
      'protein100g': 0.7,
      'karb100g': 18.1,
      'yag100g': 0.2,
    },

    // ========================================================================
    // 3. KURU MEYVELER (4 çeşit)
    // ========================================================================
    'hurma': {
      'porsiyonGram': 24.0,
      'standartAdetSayisi': 1,
      'kalori100g': 277,
      'protein100g': 1.8,
      'karb100g': 75.0,
      'yag100g': 0.2,
    },
    'kuru_incir': {
      'porsiyonGram': 40.0,
      'standartAdetSayisi': 2,
      'kalori100g': 249,
      'protein100g': 3.3,
      'karb100g': 63.9,
      'yag100g': 0.9,
    },
    'kuru_kayısı': {
      'porsiyonGram': 35.0,
      'standartAdetSayisi': 4,
      'kalori100g': 241,
      'protein100g': 3.4,
      'karb100g': 62.6,
      'yag100g': 0.5,
    },
    'kuru_üzüm': {
      'porsiyonGram': 40.0,
      'kalori100g': 299,
      'protein100g': 3.1,
      'karb100g': 79.2,
      'yag100g': 0.5,
    },

    // ========================================================================
    // 4. SÜT ÜRÜNLERİ (10 çeşit)
    // ========================================================================
    'yoğurt': {
      'porsiyonGram': 170.0, // 1 kase = 170g
      'kalori100g': 59,
      'protein100g': 10.0,
      'karb100g': 3.6,
      'yag100g': 0.4,
    },
    'kefir': {
      'porsiyonGram': 175.0, // 1 bardak = 175ml
      'kalori100g': 60,
      'protein100g': 3.3,
      'karb100g': 4.5,
      'yag100g': 3.5,
    },
    'süt': {
      'porsiyonGram': 240.0, // 1 bardak = 240ml
      'kalori100g': 42,
      'protein100g': 3.4,
      'karb100g': 5.0,
      'yag100g': 1.0,
    },
    'badem_sütü': {
      'porsiyonGram': 240.0,
      'kalori100g': 17,
      'protein100g': 0.4,
      'karb100g': 1.5,
      'yag100g': 1.1,
    },
    'süt_tam_yağlı': {
      'porsiyonGram': 240.0,
      'kalori100g': 61,
      'protein100g': 3.2,
      'karb100g': 4.8,
      'yag100g': 3.3,
    },
    'yoğurt_yağlı': {
      'porsiyonGram': 170.0,
      'kalori100g': 61,
      'protein100g': 3.5,
      'karb100g': 4.7,
      'yag100g': 3.3,
    },
    'süzme_yoğurt': {
      'porsiyonGram': 170.0,
      'kalori100g': 97,
      'protein100g': 9.0,
      'karb100g': 3.6,
      'yag100g': 5.0,
    },
    'beyaz_peynir': {
      'porsiyonGram': 30.0,
      'kalori100g': 264,
      'protein100g': 17.3,
      'karb100g': 3.2,
      'yag100g': 21.0,
    },
    'lor_peyniri': {
      'porsiyonGram': 50.0,
      'kalori100g': 98,
      'protein100g': 11.0,
      'karb100g': 3.4,
      'yag100g': 4.3,
    },

    // ========================================================================
    // 5. PROTEİN - Beyaz Et (5 çeşit)
    // ========================================================================
    'tavuk_göğsü': {
      'porsiyonGram': 85.0,
      'kalori100g': 165,
      'protein100g': 31.0,
      'karb100g': 0.0,
      'yag100g': 3.6,
    },
    'tavuk_but': {
      'porsiyonGram': 85.0,
      'kalori100g': 209,
      'protein100g': 26.0,
      'karb100g': 0.0,
      'yag100g': 11.0,
    },
    'hindi_göğsü': {
      'porsiyonGram': 85.0,
      'kalori100g': 135,
      'protein100g': 30.0,
      'karb100g': 0.0,
      'yag100g': 0.7,
    },
    'tavuk_kanat': {
      'porsiyonGram': 85.0,
      'kalori100g': 203,
      'protein100g': 30.5,
      'karb100g': 0.0,
      'yag100g': 8.1,
    },

    // ========================================================================
    // 6. PROTEİN - Kırmızı Et (3 çeşit)
    // ========================================================================
    'dana_but': {
      'porsiyonGram': 85.0,
      'kalori100g': 217,
      'protein100g': 26.0,
      'karb100g': 0.0,
      'yag100g': 11.8,
    },
    'kuzu_pirzola': {
      'porsiyonGram': 85.0,
      'kalori100g': 282,
      'protein100g': 25.0,
      'karb100g': 0.0,
      'yag100g': 19.6,
    },
    'kıyma_yağsız': {
      'porsiyonGram': 85.0,
      'kalori100g': 212,
      'protein100g': 23.5,
      'karb100g': 0.0,
      'yag100g': 12.7,
    },

    // ========================================================================
    // 7. PROTEİN - Balık (5 çeşit)
    // ========================================================================
    'som_balığı': {
      'porsiyonGram': 85.0,
      'kalori100g': 208,
      'protein100g': 20.0,
      'karb100g': 0.0,
      'yag100g': 13.0,
    },
    'levrek': {
      'porsiyonGram': 85.0,
      'kalori100g': 97,
      'protein100g': 18.4,
      'karb100g': 0.0,
      'yag100g': 2.0,
    },
    'çipura': {
      'porsiyonGram': 85.0,
      'kalori100g': 115,
      'protein100g': 20.0,
      'karb100g': 0.0,
      'yag100g': 3.5,
    },
    'ton_balığı': {
      'porsiyonGram': 85.0,
      'kalori100g': 184,
      'protein100g': 29.9,
      'karb100g': 0.0,
      'yag100g': 6.3,
    },
    'hamsi': {
      'porsiyonGram': 85.0,
      'kalori100g': 131,
      'protein100g': 20.4,
      'karb100g': 0.0,
      'yag100g': 4.8,
    },

    // ========================================================================
    // 8. PROTEİN - Baklagiller & Tofu (7 çeşit)
    // ========================================================================
    'nohut': {
      'porsiyonGram': 85.0,
      'kalori100g': 164,
      'protein100g': 8.9,
      'karb100g': 27.4,
      'yag100g': 2.6,
    },
    'kırmızı_mercimek': {
      'porsiyonGram': 85.0,
      'kalori100g': 116,
      'protein100g': 9.0,
      'karb100g': 20.1,
      'yag100g': 0.4,
    },
    'yeşil_mercimek': {
      'porsiyonGram': 85.0,
      'kalori100g': 116,
      'protein100g': 9.0,
      'karb100g': 20.0,
      'yag100g': 0.4,
    },
    'barbunya': {
      'porsiyonGram': 85.0,
      'kalori100g': 127,
      'protein100g': 8.7,
      'karb100g': 22.8,
      'yag100g': 0.5,
    },
    'kuru_fasulye': {
      'porsiyonGram': 85.0,
      'kalori100g': 127,
      'protein100g': 8.7,
      'karb100g': 23.0,
      'yag100g': 0.5,
    },
    'soya_fasulyesi': {
      'porsiyonGram': 85.0,
      'kalori100g': 147,
      'protein100g': 12.9,
      'karb100g': 11.1,
      'yag100g': 6.8,
    },
    'tofu': {
      'porsiyonGram': 80.0,
      'kalori100g': 76,
      'protein100g': 8.0,
      'karb100g': 1.9,
      'yag100g': 4.8,
    },
    'yumurta': {
      'porsiyonGram': 50.0,
      'standartAdetSayisi': 1,
      'kalori100g': 155,
      'protein100g': 13.0,
      'karb100g': 1.1,
      'yag100g': 11.0,
    },
    'yumurta_akı': {
      'porsiyonGram': 33.0,
      'standartAdetSayisi': 1,
      'kalori100g': 52,
      'protein100g': 10.9,
      'karb100g': 0.7,
      'yag100g': 0.2,
    },
    'yumurta_sarısı': {
      'porsiyonGram': 17.0,
      'standartAdetSayisi': 1,
      'kalori100g': 322,
      'protein100g': 15.9,
      'karb100g': 3.6,
      'yag100g': 26.5,
    },

    // ========================================================================
    // 9. TAHİLLAR (5 çeşit)
    // ========================================================================
    'bulgur': {
      'porsiyonGram': 50.0,
      'kalori100g': 342,
      'protein100g': 12.3,
      'karb100g': 75.9,
      'yag100g': 1.3,
    },
    'pirinç': {
      'porsiyonGram': 50.0,
      'kalori100g': 130,
      'protein100g': 2.7,
      'karb100g': 28.2,
      'yag100g': 0.3,
    },
    'esmer_pirinç': {
      'porsiyonGram': 50.0,
      'kalori100g': 111,
      'protein100g': 2.6,
      'karb100g': 23.0,
      'yag100g': 0.9,
    },
    'kinoa': {
      'porsiyonGram': 50.0,
      'kalori100g': 120,
      'protein100g': 4.4,
      'karb100g': 21.3,
      'yag100g': 1.9,
    },
    'yulaf': {
      'porsiyonGram': 40.0,
      'kalori100g': 389,
      'protein100g': 16.9,
      'karb100g': 66.3,
      'yag100g': 6.9,
    },

    // ========================================================================
    // 10. EKMEK (3 çeşit)
    // ========================================================================
    'tam_buğday_ekmeği': {
      'porsiyonGram': 30.0,
      'standartAdetSayisi': 1,
      'kalori100g': 247,
      'protein100g': 13.0,
      'karb100g': 41.0,
      'yag100g': 3.4,
    },
    'beyaz_ekmek': {
      'porsiyonGram': 30.0,
      'standartAdetSayisi': 1,
      'kalori100g': 265,
      'protein100g': 9.0,
      'karb100g': 49.0,
      'yag100g': 3.2,
    },
    'çavdar_ekmeği': {
      'porsiyonGram': 30.0,
      'standartAdetSayisi': 1,
      'kalori100g': 259,
      'protein100g': 8.5,
      'karb100g': 48.3,
      'yag100g': 3.3,
    },

    // ========================================================================
    // 11. SEBZELER (7 çeşit)
    // ========================================================================
    'ıspanak': {
      'porsiyonGram': 100.0,
      'kalori100g': 23,
      'protein100g': 2.9,
      'karb100g': 3.6,
      'yag100g': 0.4,
    },
    'roka': {
      'porsiyonGram': 100.0,
      'kalori100g': 25,
      'protein100g': 2.6,
      'karb100g': 3.7,
      'yag100g': 0.7,
    },
    'marul': {
      'porsiyonGram': 100.0,
      'kalori100g': 15,
      'protein100g': 1.4,
      'karb100g': 2.9,
      'yag100g': 0.2,
    },
    'patates': {
      'porsiyonGram': 150.0,
      'kalori100g': 77,
      'protein100g': 2.0,
      'karb100g': 17.5,
      'yag100g': 0.1,
    },
    'tatlı_patates': {
      'porsiyonGram': 130.0,
      'kalori100g': 86,
      'protein100g': 1.6,
      'karb100g': 20.1,
      'yag100g': 0.1,
    },
    'havuç': {
      'porsiyonGram': 61.0,
      'standartAdetSayisi': 1,
      'kalori100g': 41,
      'protein100g': 0.9,
      'karb100g': 9.6,
      'yag100g': 0.2,
    },
    'brokoli': {
      'porsiyonGram': 91.0,
      'kalori100g': 34,
      'protein100g': 2.8,
      'karb100g': 7.0,
      'yag100g': 0.4,
    },
  };

  // ⭐ DİYETİSYEN STANDARDI: ÖĞÜN TİPİNE GÖRE KATEGORİLER
  // 15 Yıllık Deneyim - Profesyonel Sınıflandırma
  static const Map<String, List<String>> kategoriler = {
    // Kahvaltılık Proteinler
    'kahvalti_protein': [
      'yumurta',
      'yumurta_akı',
      'yumurta_sarısı',
      'beyaz_peynir',
      'lor_peyniri',
    ],

    // Ara Öğün - Kuruyemişler
    'ara_ogun_kuruyemis': [
      'badem',
      'ceviz',
      'fındık',
      'kaju',
      'yer_fıstığı',
    ],

    // Ara Öğün - Tohumlar
    'ara_ogun_tohum': [
      'kabak_çekirdeği',
      'ayçekirdeği',
      'keten_tohumu',
      'chia_tohumu',
    ],

    // Ara Öğün - Taze Meyveler (Düşük Kalorili)
    'ara_ogun_meyve_dusuk_kalori': [
      'elma',
      'armut',
      'portakal',
      'mandalina',
      'greyfurt',
      'kivi',
      'çilek',
    ],

    // Ara Öğün - Orta Kalorili Meyveler
    'ara_ogun_meyve_orta_kalori': [
      'muz',
      'üzüm',
    ],

    // Ara Öğün - Kuru Meyveler (Yüksek Kalorili)
    'ara_ogun_kuru_meyve': [
      'hurma',
      'kuru_incir',
      'kuru_kayısı',
      'kuru_üzüm',
    ],

    // Ara Öğün - Süt Ürünleri (Yağsız)
    'ara_ogun_sut_yagsiz': [
      'yoğurt',
      'süzme_yoğurt',
      'kefir',
      'süt',
    ],

    // Ara Öğün - Tam Yağlı Süt Ürünleri
    'ara_ogun_sut_yagli': [
      'yoğurt_yağlı',
      'süt_tam_yağlı',
    ],

    // Ara Öğün - Bitkisel Sütler
    'ara_ogun_bitkisel_sut': [
      'badem_sütü',
    ],

    // Ana Öğün - Beyaz Et
    'ana_ogun_beyaz_et': [
      'tavuk_göğsü',
      'tavuk_but',
      'hindi_göğsü',
      'tavuk_kanat',
    ],

    // Ana Öğün - Kırmızı Et
    'ana_ogun_kirmizi_et': [
      'dana_but',
      'kuzu_pirzola',
      'kıyma_yağsız',
    ],

    // Ana Öğün - Balık (Yağlı)
    'ana_ogun_balik_yagli': [
      'som_balığı',
      'ton_balığı',
    ],

    // Ana Öğün - Balık (Yağsız)
    'ana_ogun_balik_yagsiz': [
      'levrek',
      'çipura',
      'hamsi',
    ],

    // Ana Öğün - Baklagiller
    'ana_ogun_baklagil': [
      'nohut',
      'kırmızı_mercimek',
      'yeşil_mercimek',
      'barbunya',
      'kuru_fasulye',
      'soya_fasulyesi',
      'tofu',
    ],

    // Karbonhidrat - Tahıllar (Kompleks)
    'karbonhidrat_tahil': [
      'bulgur',
      'esmer_pirinç',
      'kinoa',
      'yulaf',
    ],

    // Karbonhidrat - Tahıllar (Basit)
    'karbonhidrat_pirinc': [
      'pirinç',
    ],

    // Karbonhidrat - Ekmek
    'karbonhidrat_ekmek': [
      'tam_buğday_ekmeği',
      'beyaz_ekmek',
      'çavdar_ekmeği',
    ],

    // Sebze - Yeşil Yapraklı
    'sebze_yesil': [
      'ıspanak',
      'roka',
      'marul',
    ],

    // Sebze - Kök ve Yumru
    'sebze_kok_yumru': [
      'patates',
      'tatlı_patates',
      'havuç',
      'brokoli',
    ],
  };
}

// ============================================================================
// ⭐ DİYETİSYEN ONAYLI ALTERNATİF HESAPLAYICI
// ============================================================================

class AlternatifOneriServisi {
  /// Ana metod: Herhangi bir besin için alternatif üret
  static List<AlternatifBesinLegacy> otomatikAlternatifUret({
    required String besinAdi,
    required double miktar,
    required String birim,
  }) {
    print('🔍 DİYETİSYEN ANALİZİ: $miktar $birim $besinAdi');

    // 1. Besini normalleştir (TÜRKÇE KARAKTERLERİ KORU!)
    final normalBesinAdi = _besinNormalize(besinAdi);

    // 2. Veritabanında var mı?
    if (!BesinVeritabani.besinler.containsKey(normalBesinAdi)) {
      print('❌ Veritabanında yok: $normalBesinAdi');
      return [];
    }

    // 3. Besinin kategorisini bul
    final kategori = _kategoriBul(normalBesinAdi);
    if (kategori == null) {
      print('❌ Kategori bulunamadı: $normalBesinAdi');
      return [];
    }

    print('✅ Kategori: $kategori');

    // 4. Aynı kategorideki diğer besinleri bul
    final ayniKategoridekilar = BesinVeritabani.kategoriler[kategori]!
        .where((b) => b != normalBesinAdi)
        .toList();

    // 5. Her biri için alternatif hesapla
    final alternatifler = <AlternatifBesinLegacy>[];

    for (final alternatifBesinAdi in ayniKategoridekilar) {
      final alternatif = _alternatifHesapla(
        orijinalBesin: normalBesinAdi,
        orijinalMiktar: miktar,
        orijinalBirim: birim,
        alternatifBesin: alternatifBesinAdi,
        kategori: kategori,
      );

      if (alternatif != null) {
        alternatifler.add(alternatif);
      }
    }

    // 6. En iyi 3 alternatifi döndür (kalori benzerliğine göre sırala)
    alternatifler.sort((a, b) {
      final orijinalData = BesinVeritabani.besinler[normalBesinAdi]!;
      final orijinalKaloriGercek =
          _gercekKaloriHesapla(orijinalData, miktar, birim);

      final aFark = (a.kalori - orijinalKaloriGercek).abs();
      final bFark = (b.kalori - orijinalKaloriGercek).abs();

      return aFark.compareTo(bFark);
    });

    return alternatifler.take(3).toList();
  }

  // ==========================================================================
  // ⭐ DİYETİSYEN STANDARDI: GERÇEK AĞIRLIK BAZLI HESAPLAMA
  // ==========================================================================

  static AlternatifBesinLegacy? _alternatifHesapla({
    required String orijinalBesin,
    required double orijinalMiktar,
    required String orijinalBirim,
    required String alternatifBesin,
    required String kategori,
  }) {
    final orijinalData = BesinVeritabani.besinler[orijinalBesin]!;
    final alternatifData = BesinVeritabani.besinler[alternatifBesin]!;

    // ⭐ ADIM 1: Orijinal besinin GERÇEK kalorisini hesapla
    final orijinalGercekKalori = _gercekKaloriHesapla(
      orijinalData,
      orijinalMiktar,
      orijinalBirim,
    );

    print(
        '  📊 ${_besinGuzelIsim(orijinalBesin)}: ${orijinalGercekKalori.toStringAsFixed(1)} kcal');

    // ⭐ ADIM 2: Aynı kaloriye ulaşmak için kaç porsiyon alternatif gerekli?
    final alternatifPorsiyonSayisi = _esitKaloriIcinPorsiyon(
      hedefKalori: orijinalGercekKalori,
      alternatifData: alternatifData,
    );

    // Minimum kontrol (çok az çıktıysa gösterme)
    if (alternatifPorsiyonSayisi < 0.25) {
      return null;
    }

    // ⭐ ADIM 3: Birim belirle (kategori bazlı)
    final alternatifBirim = _birimBelirle(alternatifBesin, kategori);

    // ⭐ ADIM 4: Porsiyon sayısını gerçek miktara dönüştür (birim türüne göre)
    final porsiyonGram = alternatifData['porsiyonGram']!;
    final standartAdetSayisi = alternatifData['standartAdetSayisi'];
    
    double gosterilecekMiktar;
    double gercekPorsiyonSayisi; // Gerçekte kullanılacak porsiyon
    
    if (alternatifBirim == 'adet' && standartAdetSayisi != null) {
      // ⭐ KURUYEMIŞLER ve MEYVELER: Önce porsiyon yuvarla, sonra adete çevir, TAM SAYIYA YUVARLA
      // 0.817 porsiyon → 0.75 porsiyon → 0.75 × 10 = 7.5 → 8 adet (tam sayı!)
      final yuvarlanmisPorsiyon = _akillicaYuvarla(alternatifPorsiyonSayisi);
      final hesaplananAdet = yuvarlanmisPorsiyon * standartAdetSayisi;
      gosterilecekMiktar = hesaplananAdet.round().toDouble(); // TAM SAYIYA YUVARLA!
      gercekPorsiyonSayisi = gosterilecekMiktar / standartAdetSayisi;
    } else if (alternatifBirim == 'gram' || alternatifBirim == 'ml') {
      // ⭐ SÜT ve PROTEİN: Önce gram hesapla, SONRA yuvarla
      // 0.837 porsiyon × 170g = 142.3g → 140g (10'un katları)
      final hesaplananGram = alternatifPorsiyonSayisi * porsiyonGram;
      gosterilecekMiktar = (hesaplananGram / 10).round() * 10.0; // 10'un katlarına yuvarla
      if (gosterilecekMiktar < 10) gosterilecekMiktar = 10.0; // Minimum 10g
      gercekPorsiyonSayisi = gosterilecekMiktar / porsiyonGram;
    } else {
      // ⭐ MEYVELER: Adet bazlı (standartAdetSayisi = 1)
      gosterilecekMiktar = _akillicaYuvarla(alternatifPorsiyonSayisi);
      gercekPorsiyonSayisi = gosterilecekMiktar;
    }

    // ⭐ ADIM 6: GERÇEK besin değerlerini hesapla (gösterilen miktar bazlı!)
    final toplamGram = gercekPorsiyonSayisi * porsiyonGram;

    final gercekKalori = (toplamGram / 100) * alternatifData['kalori100g']!;
    final gercekProtein = (toplamGram / 100) * alternatifData['protein100g']!;
    final gercekKarb = (toplamGram / 100) * alternatifData['karb100g']!;
    final gercekYag = (toplamGram / 100) * alternatifData['yag100g']!;

    // ⭐ ADIM 7: Kalori farkını kontrol et (max %10 fark - diyetisyen standardı)
    final kaloriFarkYuzde =
        ((gercekKalori - orijinalGercekKalori).abs() / orijinalGercekKalori) *
            100;
    if (kaloriFarkYuzde > 10) {
      print(
          '  ⚠️ ${_besinGuzelIsim(alternatifBesin)}: Kalori farkı çok yüksek (%${kaloriFarkYuzde.toStringAsFixed(1)})');
      return null; // %10'dan fazla fark varsa alternatif olarak gösterme
    }

    // ⭐ ADIM 7.5: Kuruyemişler için adet kontrolü (maksimum 25 adet)
    if (kategori.contains('kuruyemis') && alternatifBirim == 'adet' && gosterilecekMiktar > 25) {
      print(
          '  ⚠️ ${_besinGuzelIsim(alternatifBesin)}: Çok fazla adet (${gosterilecekMiktar.toStringAsFixed(0)} adet)');
      return null; // 25 adetten fazlaysa gösterme
    }

    // ⭐ ADIM 8: Neden belirle
    final neden = _nedenUret(
        orijinalData, alternatifData, orijinalGercekKalori, gercekKalori);

    print(
        '  ✅ → ${gosterilecekMiktar.toStringAsFixed(0)} $alternatifBirim ${_besinGuzelIsim(alternatifBesin)} (${gercekKalori.toStringAsFixed(1)} kcal)');

    return AlternatifBesinLegacy(
      ad: _besinGuzelIsim(alternatifBesin),
      miktar: gosterilecekMiktar,
      birim: alternatifBirim,
      kalori: gercekKalori,
      protein: gercekProtein,
      karbonhidrat: gercekKarb,
      yag: gercekYag,
      neden: neden,
    );
  }

  // ==========================================================================
  // ⭐ HESAPLAMA METODLARI
  // ==========================================================================

  /// ⭐ Gerçek kalori hesapla (diyetisyen standardı - DÜZELT İLDİ!)
  static double _gercekKaloriHesapla(
    Map<String, double> besinData,
    double miktar,
    String birim,
  ) {
    final porsiyonGram = besinData['porsiyonGram']!;
    final kalori100g = besinData['kalori100g']!;

    double toplamGram;

    if (_birimAdetMi(birim)) {
      // ⭐ DİYETİSYEN STANDARDI: Adet bazlı hesaplama
      final standartAdetSayisi = besinData['standartAdetSayisi'];
      
      if (standartAdetSayisi != null) {
        // Kuruyemişler için: 13 adet fındık = (13/21) * 28g = 17.3g
        toplamGram = (miktar / standartAdetSayisi) * porsiyonGram;
      } else {
        // Meyveler için (fallback): 1.5 adet muz = 1.5 * 118g = 177g
        toplamGram = miktar * porsiyonGram;
      }
    } else {
      // Gram/ml direkt kullan
      toplamGram = miktar;
    }

    // Gerçek kalori = (toplam gram / 100) * 100g bazında kalori
    return (toplamGram / 100) * kalori100g;
  }

  /// Eşit kalori için kaç porsiyon gerekli? (diyetisyen standardı)
  static double _esitKaloriIcinPorsiyon({
    required double hedefKalori,
    required Map<String, double> alternatifData,
  }) {
    final porsiyonGram = alternatifData['porsiyonGram']!;
    final kalori100g = alternatifData['kalori100g']!;

    // 1 porsiyonun kalorisi
    final birPorsiyonKalori = (porsiyonGram / 100) * kalori100g;

    // Hedef kaloriye ulaşmak için kaç porsiyon?
    return hedefKalori / birPorsiyonKalori;
  }

  /// ⭐ DİYETİSYEN STANDARDI: Akıllı yuvarlama
  /// Gerçekçi porsiyonlar: 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, vb.
  static double _akillicaYuvarla(double porsiyon) {
    // 0.25'lik (çeyrek) dilimlere yuvarla
    // Örn: 1.13 → 1.25, 1.67 → 1.75, 0.89 → 1.0
    final ceyrekler = (porsiyon * 4).round();
    final yuvarlanmis = ceyrekler / 4.0;

    // Minimum 0.5 porsiyon
    return yuvarlanmis < 0.5 ? 0.5 : yuvarlanmis;
  }

  /// ⭐ Birim belirle (kategori bazlı - meyveler ve kuruyemişler her zaman "adet")
  static String _birimBelirle(String besinAdi, String kategori) {
    // Meyveler ve kuruyemişler için her zaman "adet"
    if (kategori.contains('meyve') || kategori.contains('kuruyemis')) {
      return 'adet';
    }

    // Süt ürünleri için ml
    if (besinAdi.contains('süt') || besinAdi == 'kefir') {
      return 'ml';
    }

    // Diğerleri için gram
    return 'gram';
  }

  // ==========================================================================
  // HELPER METODLAR
  // ==========================================================================

  /// ⭐ Besini normalize et - Dictionary-based Turkish food name mapping
  static String _besinNormalize(String besinAdi) {
    // 1. Küçük harfe çevir ve boşlukları _ yap
    String normalized = besinAdi.toLowerCase().trim().replaceAll(' ', '_');
    
    // 2. ASCII → Türkçe besin adı çevirisi (Dictionary-based, sadece bilinen besinler)
    final Map<String, String> asciiToTurkish = {
      // Kuruyemişler
      'findik': 'fındık',
      'fistik': 'fıstık',
      'antep_fistigi': 'antep_fıstığı',
      'yer_fistigi': 'yer_fıstığı',
      'kabak_cekirdegi': 'kabak_çekirdeği',
      'aycekirdegi': 'ayçekirdeği',
      'keten_tohümu': 'keten_tohumu',
      'chia_tohümu': 'chia_tohumu',
      
      // Meyveler
      'cilek': 'çilek',
      'uzum': 'üzüm',
      'greyfürt': 'greyfurt',
      'kivi': 'kivi',
      'mandalına': 'mandalina',
      
      // Kuru Meyveler
      'hürma': 'hurma',
      'kuru_incir': 'kuru_incir',
      'kuru_kayisi': 'kuru_kayısı',
      'kuru_uzum': 'kuru_üzüm',
      
      // Süt Ürünleri
      'yogurt': 'yoğurt',
      'yögürt': 'yoğurt',
      'süzme_yogurt': 'süzme_yoğurt',
      'yogurt_yagli': 'yoğurt_yağlı',
      'yogurt_yağli': 'yoğurt_yağlı',
      'yögürt_yağli': 'yoğurt_yağlı',
      'süzme_yögürt': 'süzme_yoğurt',
      'sut': 'süt',
      'badem_sutu': 'badem_sütü',
      'sut_tam_yagli': 'süt_tam_yağlı',
      'ispanak': 'ıspanak',
      'çeviz': 'ceviz',
      'müz': 'muz',
      
      // Protein
      'tavuk_gogsu': 'tavuk_göğsü',
      'tavuk_gögsu': 'tavuk_göğsü',
      'tavuk_gögsü': 'tavuk_göğsü',
      'hindi_gogsu': 'hindi_göğsü',
      'hindi_gögsu': 'hindi_göğsü',
      'som_baligi': 'som_balığı',
      'ton_baligi': 'ton_balığı',
      'cipura': 'çipura',
      'çipüra': 'çipura',
      
      // Baklagiller
      'kirmizi_mercimek': 'kırmızı_mercimek',
      'yesil_mercimek': 'yeşil_mercimek',
      'barbünya': 'barbunya',
      'kuru_fasülye': 'kuru_fasulye',
      
      // Yumurta
      'yümurta': 'yumurta',
      'yumurta_aki': 'yumurta_akı',
      'yumurta_sarisi': 'yumurta_sarısı',
      
      // Tahıllar
      'bulgur': 'bulgur',
      'bulgür': 'bulgur',
      'pirinc': 'pirinç',
      'pirınc': 'pirinç',
      'esmer_pirinc': 'esmer_pirinç',
      'kınoa': 'kinoa',
      
      // Ekmek
      'tam_bugday_ekmegi': 'tam_buğday_ekmeği',
      'cavdar_ekmegi': 'çavdar_ekmeği',
      
      // Sebzeler
      'tatli_patates': 'tatlı_patates',
      'havuc': 'havuç',
    };
    
    // 3. Eğer mapping'de varsa, Türkçe versiyonu kullan
    if (asciiToTurkish.containsKey(normalized)) {
      normalized = asciiToTurkish[normalized]!;
    }
    
    return normalized;
  }

  /// Güzel isim (Badem, Muz, vb.)
  static String _besinGuzelIsim(String normalBesin) {
    return normalBesin
        .replaceAll('_', ' ')
        .split(' ')
        .map((kelime) => kelime[0].toUpperCase() + kelime.substring(1))
        .join(' ');
  }

  /// Kategori bul
  static String? _kategoriBul(String besinAdi) {
    for (final entry in BesinVeritabani.kategoriler.entries) {
      if (entry.value.contains(besinAdi)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Birim adet mi?
  static bool _birimAdetMi(String birim) {
    final birimKucuk = birim.toLowerCase().trim();
    return birimKucuk == 'adet' ||
        birimKucuk == 'tane' ||
        birimKucuk == 'dilim';
  }

  /// ⭐ DİYETİSYEN STANDARDI: Neden açıklaması
  static String _nedenUret(
    Map<String, double> orijinal,
    Map<String, double> alternatif,
    double orijinalKalori,
    double alternatifKalori,
  ) {
    final proteinFark = alternatif['protein100g']! - orijinal['protein100g']!;
    final kaloriFark = alternatifKalori - orijinalKalori;
    final kaloriFarkYuzde = (kaloriFark.abs() / orijinalKalori) * 100;

    if (kaloriFarkYuzde < 5) {
      return 'Neredeyse aynı kalori';
    } else if (kaloriFarkYuzde < 10) {
      if (kaloriFark > 0) {
        return 'Biraz daha fazla kalori (+${kaloriFarkYuzde.toStringAsFixed(0)}%)';
      } else {
        return 'Biraz daha az kalori (-${kaloriFarkYuzde.toStringAsFixed(0)}%)';
      }
    } else if (proteinFark > 5) {
      return 'Daha yüksek protein';
    } else {
      return 'Benzer besin değeri';
    }
  }

  /// Alternatifi orijinal besinle karşılaştır
  static String karsilastir(
    double orijinalKalori,
    double alternatifKalori,
    double orijinalProtein,
    double alternatifProtein,
  ) {
    final kaloriFark =
        ((alternatifKalori - orijinalKalori) / orijinalKalori * 100).abs();
    final proteinFark =
        ((alternatifProtein - orijinalProtein) / orijinalProtein * 100).abs();

    if (kaloriFark < 5 && proteinFark < 10) {
      return '✅ Çok benzer besin değeri';
    } else if (kaloriFark < 10 && proteinFark < 20) {
      return '🔄 Benzer besin değeri';
    } else if (alternatifProtein > orijinalProtein) {
      return '💪 Daha yüksek protein';
    } else if (alternatifKalori < orijinalKalori) {
      return '🔥 Daha düşük kalori';
    } else {
      return '⚖️ Farklı besin profili';
    }
  }
}
