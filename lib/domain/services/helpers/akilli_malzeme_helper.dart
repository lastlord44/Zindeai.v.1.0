// ============================================================================
// lib/domain/services/helpers/akilli_malzeme_helper.dart
// GELİŞTİRİLMİŞ AKILLI MALZEME ÜRETİCİ - SAÇMA MALZEME SORUNUNU ÇÖZER
// ============================================================================

import '../../../core/utils/app_logger.dart';

/// Geliştirilmiş akıllı malzeme üretici
/// 
/// "Uskumru + Pilav" → Uskumru fileto, Pirinç, Tuz, Tereyağı gibi SPESİFİK malzemeler
/// "Falafel Wrap" → Falafel, Wrap, Humus, Marul gibi SPESİFİK malzemeler
/// 
/// Artık "Ana protein kaynağı", "Karbonhidrat" gibi GENERIC malzemeler YOK!
class AkilliMalzemeHelper {
  
  /// 🧠 Yemek adından spesifik malzemeler üret
  static List<String> malzemeUret(String yemekAdi) {
    final adLower = yemekAdi.toLowerCase();
    
    AppLogger.debug('🔍 Akıllı malzeme üretiliyor: $yemekAdi');
    
    // ================================================================
    // 🐟 BALIK YEMEKLERİ
    // ================================================================
    
    // Uskumru
    if (adLower.contains('uskumru')) {
      if (adLower.contains('pilav') || adLower.contains('pirinç')) {
        return [
          'Uskumru fileto 150g',
          'Pirinç 80g',
          'Tuz 1 tsp',
          'Tereyağı 1 YK',
          'Limon 1/2 adet'
        ];
      }
      return [
        'Uskumru 200g',
        'Soğan 60g',
        'Zeytinyağı 1 YK',
        'Limon 1/2 adet',
        'Tuz 1 tsp'
      ];
    }
    
    // Somon
    if (adLower.contains('somon')) {
      return [
        'Somon fileto 180g',
        'Brokoli 150g',
        'Patates 120g',
        'Zeytinyağı 10g',
        'Limon 1/2 adet'
      ];
    }
    
    // Hamsi
    if (adLower.contains('hamsi')) {
      return [
        'Hamsi 220g',
        'Mısır unu 20g',
        'Yumurta 1 adet',
        'Soğan 40g',
        'Zeytinyağı 8g'
      ];
    }
    
    // Levrek
    if (adLower.contains('levrek')) {
      return [
        'Levrek 200g',
        'Soğan 60g',
        'Domates 120g',
        'Zeytinyağı 8g',
        'Esmer pirinç 60g'
      ];
    }
    
    // ================================================================
    // 🥙 WRAP & DÜRÜM YEMEKLERİ
    // ================================================================
    
    if (adLower.contains('wrap') || adLower.contains('dürüm')) {
      // Falafel Wrap
      if (adLower.contains('falafel')) {
        return [
          'Falafel 4 adet',
          'Tam buğday wrap 1 adet',
          'Humus 50g',
          'Marul 50g',
          'Domates 1 adet',
          'Limon suyu 1 YK'
        ];
      }
      
      // Tavuk Wrap
      if (adLower.contains('tavuk')) {
        return [
          'Tavuk göğsü 120g',
          'Tam buğday wrap 1 adet',
          'Marul 50g',
          'Domates 1 adet',
          'Yoğurt sos 2 YK'
        ];
      }
      
      // Generic wrap
      return [
        'Tam buğday wrap 1 adet',
        'Protein 100g',
        'Taze sebze 100g',
        'Sos 2 YK'
      ];
    }
    
    // ================================================================
    // 🥗 BOWL YEMEKLERİ
    // ================================================================
    
    if (adLower.contains('bowl')) {
      // Buddha/Sebze Bowl
      if (adLower.contains('buddha') || adLower.contains('sebze')) {
        return [
          'Kinoa 80g',
          'Nohut 100g',
          'Tatlı patates 150g',
          'Brokoli 100g',
          'Havuç 1 adet',
          'Tahini sos 2 YK',
          'Zeytinyağı 1 tsp'
        ];
      }
      
      // Protein/Tavuk Bowl
      if (adLower.contains('protein') || adLower.contains('tavuk')) {
        return [
          'Tavuk göğsü 150g',
          'Pirinç 80g',
          'Brokoli 100g',
          'Avokado 1/2 adet',
          'Soya sosu 1 YK'
        ];
      }
      
      // Poke Bowl
      if (adLower.contains('poke')) {
        return [
          'Sushi pirinci 100g',
          'Somon 120g',
          'Avokado 1/2 adet',
          'Edamame 50g',
          'Havuç 1 adet',
          'Nori 1 yaprak',
          'Soya sosu 1 YK'
        ];
      }
    }
    
    // ================================================================
    // 🍛 ASYA YEMEKLERİ
    // ================================================================
    
    // Teriyaki
    if (adLower.contains('teriyaki')) {
      return [
        'Tavuk göğsü 150g',
        'Teriyaki sos 3 YK',
        'Brokoli 100g',
        'Havuç 1 adet',
        'Pirinç 100g',
        'Susam 1 tsp'
      ];
    }
    
    // Curry
    if (adLower.contains('curry')) {
      if (adLower.contains('nohut')) {
        return [
          'Nohut 200g',
          'Hindistan cevizi sütü 150ml',
          'Curry baharatı 1 YK',
          'Soğan 1 adet',
          'Domates 2 adet',
          'Pirinç 100g'
        ];
      }
      return [
        'Protein 150g',
        'Curry sos 100ml',
        'Sebze 150g',
        'Pirinç 100g',
        'Baharat'
      ];
    }
    
    // ================================================================
    // 🌮 MEKSİKA YEMEKLERİ
    // ================================================================
    
    // Taco
    if (adLower.contains('taco')) {
      return [
        'Taco kabuğu 2 adet',
        'Kıyma/Tavuk 100g',
        'Meksika baharatı 1 tsp',
        'Marul 50g',
        'Domates 1 adet',
        'Avokado 1/2 adet',
        'Salsa sos 2 YK'
      ];
    }
    
    // Burrito
    if (adLower.contains('burrito')) {
      return [
        'Tortilla 1 büyük',
        'Tavuk/Dana 120g',
        'Pirinç 80g',
        'Fasulye 100g',
        'Avokado 1/2 adet',
        'Salsa 2 YK',
        'Kaşar rendesi 30g'
      ];
    }
    
    // ================================================================
    // 🍔 BURGER & SANDVIÇ
    // ================================================================
    
    if (adLower.contains('burger')) {
      return [
        'Köfte/Burger 120g',
        'Hamburger ekmeği 1 adet',
        'Marul 2 yaprak',
        'Domates 2 dilim',
        'Soğan 2 halka',
        'Sos 1 YK'
      ];
    }
    
    // ================================================================
    // 🍞 EKMEK BAZLIclassName YEMEKLERİ
    // ================================================================
    
    // Tam Buğday Ekmek + Fıstık Ezmesi (DÜZELT!)
    if (adLower.contains('tam buğday') && adLower.contains('fıstık')) {
      return [
        'Tam buğday ekmek 2 dilim',
        'Fıstık ezmesi 2 YK',
        'Bal 1 tsp (opsiyonel)'
      ];
    }
    
    // ================================================================
    // 🐔 TAVUK YEMEKLERİ
    // ================================================================
    
    if (adLower.contains('tavuk')) {
      // Tavuk + Pilav
      if (adLower.contains('pilav') || adLower.contains('pirinç')) {
        return [
          'Tavuk göğsü 150g',
          'Pirinç 80g',
          'Zeytinyağı 1 tsp',
          'Sebze 100g',
          'Baharat'
        ];
      }
      
      // Tavuk + Bulgur
      if (adLower.contains('bulgur')) {
        return [
          'Tavuk göğsü 150g',
          'Bulgur 60g',
          'Zeytinyağı 1 tsp',
          'Sebze 100g',
          'Baharat'
        ];
      }
      
      // Generic tavuk
      return [
        'Tavuk göğsü 150g',
        'Sebze 150g',
        'Zeytinyağı 1 tsp',
        'Baharat',
        'Garnitür'
      ];
    }
    
    // ================================================================
    // 🥩 ET YEMEKLERİ
    // ================================================================
    
    if (adLower.contains('dana') || adLower.contains('et ') || adLower.contains('kuzu')) {
      return [
        'Dana/Et 150g',
        'Sebze 150g',
        'Tahıl (pirinç/bulgur) 80g',
        'Zeytinyağı 1 tsp',
        'Baharat'
      ];
    }
    
    // ================================================================
    // 🥗 SALATA
    // ================================================================
    
    if (adLower.contains('salata')) {
      return [
        'Karışık yeşillik 100g',
        'Domates 1 adet',
        'Salatalık 1/2 adet',
        'Protein 100g',
        'Zeytinyağı 1 YK',
        'Limon suyu 1 YK'
      ];
    }
    
    // ================================================================
    // 🌱 SEBZE & BAKLAGIL YEMEKLERİ
    // ================================================================
    
    if (adLower.contains('nohut') || adLower.contains('mercimek') || adLower.contains('fasulye')) {
      return [
        'Baklagil 180g',
        'Sebze 150g',
        'Tahıl 80g',
        'Zeytinyağı 1 YK',
        'Baharat'
      ];
    }
    
    // ================================================================
    // 🥤 SMOOTHIE
    // ================================================================
    
    if (adLower.contains('smoothie')) {
      return [
        'Dondurulmuş meyve 200g',
        'Süt/Yoğurt 150ml',
        'Protein tozu 1 ölçek (opsiyonel)',
        'Bal 1 YK',
        'Chia tohumu 1 tsp'
      ];
    }
    
    // ================================================================
    // ⚠️ FALLBACK (En son çare!)
    // ================================================================
    
    AppLogger.warning('⚠️ Bilinmeyen yemek için generic malzeme: $yemekAdi');
    
    // Protein bazlı
    if (adLower.contains('protein') || adLower.contains('et') || adLower.contains('tavuk') || adLower.contains('balık')) {
      return [
        'Protein kaynağı 120g (tavuk/et/balık)',
        'Kompleks karb 80g (bulgur/pirinç/kinoa)',
        'Taze sebze 150g',
        'Zeytinyağı 1 tsp',
        'Baharat ve tuz'
      ];
    }
    
    // Gerçekten bilinmeyen
    return [
      'Ana malzeme 150g',
      'Yan malzeme 100g',
      'Sebze 100g',
      'Yağ 1 tsp',
      'Baharat ve tuz'
    ];
  }
}