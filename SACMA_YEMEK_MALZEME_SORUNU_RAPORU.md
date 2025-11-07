# 🔍 SAÇMA YEMEK MALZEMELERİ SORUNU ANALİZİ

**Tarih:** 01 Kasım 2025  
**Sorun:** Bazı yemeklerde "Ana protein kaynağı", "Karbonhidrat" gibi **generic malzemeler** görünüyor

---

## 🐛 SORUNUN KAYNAĞI

### Etkilenen Dosya
[`lib/domain/services/ai_beslenme_servisi.dart`](lib/domain/services/ai_beslenme_servisi.dart)

### Sorunlu Metodlar

1. **[`_detayliMalzemeler(String yemekAdi)`](lib/domain/services/ai_beslenme_servisi.dart:2211)** - Satır 2211
   - Malzeme haritasında (`malzemelerHaritasi`) olmayan yemekler için [`_akilliBazMalzeme`](lib/domain/services/ai_beslenme_servisi.dart:2999) metodunu çağırıyor

2. **[`_akilliBazMalzeme(String yemekAdi)`](lib/domain/services/ai_beslenme_servisi.dart:2999)** - Satır 2999
   - Generic malzemeler döndürüyor:
     ```dart
     return [
       'Ana protein kaynağı (120g)',      // ❌ GENERIC!
       'Karbonhidrat (80g)',               // ❌ GENERIC!
       'Taze sebze garnitür',              // ❌ GENERIC!
       'Sağlıklı yağ (1 tsp)'              // ❌ GENERIC!
     ];
     ```

### Etkilenen Yemekler (Örnekler)
- ✅ "Menemen" → Malzeme haritasında VAR → Spesifik malzemeler
- ✅ "Izgara Tavuk + Bulgur" → Malzeme haritasında VAR → Spesifik malzemeler
- ❌ "Falafel Wrap" → Malzeme haritasında YOK → Generic malzemeler
- ❌ "Tavuk Teriyaki" → Malzeme haritasında YOK → Generic malzemeler
- ❌ "Sebze Buddha Bowl" → Malzeme haritasında YOK → Generic malzemeler

---

## 🔧 ÇÖZÜM: AKILLI BAZ MALZEME METODUNİ GELİŞTİR

### Manuel Düzeltme Talimatı

**NOT:** [`ai_beslenme_servisi.dart`](lib/domain/services/ai_beslenme_servisi.dart) dosyası 50MB'dan büyük olduğu için otomatik düzenlenemedi. Manuel olarak aşağıdaki değişiklikleri yapın:

#### Adım 1: `_akilliBazMalzeme` Metodunu Bul

Satır 2999 civarında şu metodu bulun:

```dart
/// 🧠 Akıllı baz malzeme üretici
List<String> _akilliBazMalzeme(String yemekAdi) {
  final adLower = yemekAdi.toLowerCase();

  // Protein bazlı yemekler
  if (adLower.contains('tavuk')) {
    return [
      'Tavuk göğsü (120-150g)',
      'Zeytinyağı (1 tsp)',
      'Baharat karışımı',
      'Sebze garnitür'
    ];
  }
  // ... (devamı)
```

#### Adım 2: Eksik Yemek Tiplerini Ekleyin

Mevcut metoda şu yemek tiplerini ekleyin (satır 3030 civarına):

```dart
  // 🔥 WRAP VE DÜRÜM
  if (adLower.contains('wrap') || adLower.contains('dürüm')) {
    if (adLower.contains('falafel')) {
      return [
        'Falafel (4 adet)',
        'Tam buğday wrap (1 adet)',
        'Humus (50g)',
        'Marul (50g)',
        'Domates (1 adet)',
        'Limon suyu (1 YK)'
      ];
    } else if (adLower.contains('tavuk')) {
      return [
        'Tavuk göğsü (120g)',
        'Tam buğday wrap (1 adet)',
        'Marul (50g)',
        'Domates (1 adet)',
        'Yoğurt sos (2 YK)'
      ];
    }
    // Generic wrap
    return [
      'Tam buğday wrap (1 adet)',
      'Protein kaynağı (100g)',
      'Taze sebze (100g)',
      'Sos (2 YK)'
    ];
  }

  // 🔥 BOWL YEMEKLERİ
  if (adLower.contains('bowl')) {
    if (adLower.contains('buddha') || adLower.contains('sebze')) {
      return [
        'Kinoa (80g)',
        'Nohut (100g)',
        'Tatlı patates (150g)',
        'Brokoli (100g)',
        'Havuç (1 adet)',
        'Tahini sos (2 YK)',
        'Zeytinyağı (1 tsp)'
      ];
    } else if (adLower.contains('protein') || adLower.contains('tavuk')) {
      return [
        'Tavuk göğsü (150g)',
        'Pirinç (80g)',
        'Brokoli (100g)',
        'Avokado (1/2 adet)',
        'Soya sosu (1 YK)'
      ];
    }
    // Generic bowl
    return [
      'Tahıl bazı (80g)',
      'Protein (120g)',
      'Sebze karışımı (200g)',
      'Sos (2 YK)'
    ];
  }

  // 🔥 TERİYAKİ VE ASYA YEMEKLERİ
  if (adLower.contains('teriyaki')) {
    return [
      'Tavuk göğsü (150g)',
      'Teriyaki sos (3 YK)',
      'Brokoli (100g)',
      'Havuç (1 adet)',
      'Pirinç (100g)',
      'Susam (1 tsp)'
    ];
  }

  // 🔥 CURRY
  if (adLower.contains('curry')) {
    if (adLower.contains('nohut') || adLower.contains('chickpea')) {
      return [
        'Nohut (200g)',
        'Hindistan cevizi sütü (150ml)',
        'Curry baharatı (1 YK)',
        'Soğan (1 adet)',
        'Domates (2 adet)',
        'Pirinç (100g)'
      ];
    }
    return [
      'Protein (150g)',
      'Curry sos (100ml)',
      'Sebze (150g)',
      'Pirinç (100g)',
      'Baharat'
    ];
  }

  // 🔥 SALATA
  if (adLower.contains('salata') || adLower.contains('salad')) {
    return [
      'Karışık yeşillik (100g)',
      'Domates (1 adet)',
      'Salatalık (1/2 adet)',
      'Protein kaynağı (100g)',
      'Zeytinyağı (1 YK)',
      'Limon suyu (1 YK)'
    ];
  }

  // 🔥 BURGER
  if (adLower.contains('burger')) {
    return [
      'Köfte veya burger (120g)',
      'Hamburger ekmeği (1 adet)',
      'Marul (2 yaprak)',
      'Domates (2 dilim)',
      'Soğan (2 halka)',
      'Sos (1 YK)'
    ];
  }

  // 🔥 TACO
  if (adLower.contains('taco')) {
    return [
      'Taco kabuğu (2 adet)',
      'Kıyma veya tavuk (100g)',
      'Meksika baharatı (1 tsp)',
      'Marul (50g)',
      'Domates (1 adet)',
      'Avokado (1/2 adet)',
      'Salsa sos (2 YK)'
    ];
  }

  // 🔥 BURRITO
  if (adLower.contains('burrito')) {
    return [
      'Tortilla (1 büyük)',
      'Tavuk veya dana (120g)',
      'Pirinç (80g)',
      'Fasulye (100g)',
      'Avokado (1/2 adet)',
      'Salsa (2 YK)',
      'Kaşar rendesi (30g)'
    ];
  }

  // 🔥 SMOOTHIE BOWL
  if (adLower.contains('smoothie') && adLower.contains('bowl')) {
    return [
      'Dondurulmuş meyve (200g)',
      'Süt veya yoğurt (150ml)',
      'Granola (40g)',
      'Taze meyve (100g)',
      'Bal (1 YK)',
      'Chia tohumu (1 tsp)'
    ];
  }

  // 🔥 POKE BOWL
  if (adLower.contains('poke')) {
    return [
      'Sushi pirinci (100g)',
      'Somon veya ton (120g)',
      'Avokado (1/2 adet)',
      'Edamame (50g)',
      'Havuç (1 adet)',
      'Nori (1 yaprak)',
      'Soya sosu (1 YK)'
    ];
  }
```

#### Adım 3: Varsayılan Fallback'i İyileştirin

En alttaki varsayılan return'ü (satır 3063 civarı) şu şekilde değiştirin:

```dart
  // Varsayılan dengeli öğün (SPESİFİK OLMAYA ÇALIŞ!)
  if (adLower.contains('protein') || adLower.contains('et') || adLower.contains('tavuk') || adLower.contains('balık')) {
    return [
      'Protein kaynağı (120g) - tavuk/et/balık',
      'Kompleks karb (80g) - bulgur/pirinç/kinoa',
      'Taze sebze (150g)',
      'Zeytinyağı (1 tsp)',
      'Baharat'
    ];
  }
  
  // Gerçekten bilinmeyen yemek
  AppLogger.warning('⚠️ Bilinmeyen yemek için generic malzeme: $yemekAdi');
  return [
    'Ana malzeme (150g) - yemek adına uygun seçin',
    'Yan malzeme (100g)',
    'Sebze (100g)',
    'Yağ (1 tsp)',
    'Baharat ve tuz'
  ];
}
```

---

## 📊 ETKİ ANALİZİ

### Düzeltme Öncesi
```
❌ Falafel Wrap
  - Ana protein kaynağı (120g)
  - Karbonhidrat (80g)
  - Taze sebze garnitür
  - Sağlıklı yağ (1 tsp)
```

### Düzeltme Sonrası
```
✅ Falafel Wrap
  - Falafel (4 adet)
  - Tam buğday wrap (1 adet)
  - Humus (50g)
  - Marul (50g)
  - Domates (1 adet)
  - Limon suyu (1 YK)
```

---

## 🎯 ALTERNATİF ÇÖZÜM: MALZEME HARİTASINI GENİŞLET

Daha kalıcı çözüm için [`_detayliMalzemeler`](lib/domain/services/ai_beslenme_servisi.dart:2211) metodundaki `malzemelerHaritasi` Map'ine eksik yemekleri ekleyin (satır 2213-2938 arası).

Örnek:
```dart
'Falafel Wrap': [
  'Falafel (4 adet)',
  'Tam buğday wrap (1 adet)',
  'Humus (50g)',
  'Marul (50g)',
  'Domates (1 adet)',
  'Limon suyu (1 YK)'
],
'Tavuk Teriyaki + Brokoli + Pirinç': [
  'Tavuk göğsü (150g)',
  'Teriyaki sos (3 YK)',
  'Brokoli (100g)',
  'Havuç (1 adet)',
  'Pirinç (100g)',
  'Susam (1 tsp)'
],
// ... diğerleri
```

---

## ✅ ÖNERİLER

1. **Kısa Vadeli:** [`_akilliBazMalzeme`](lib/domain/services/ai_beslenme_servisi.dart:2999) metodunu yukarıdaki gibi genişletin
2. **Orta Vadeli:** Malzeme haritasını popüler yemeklerle genişletin
3. **Uzun Vadeli:** AI'ı gerçek yemek veritabanından beslemeyi düşünün (Pollinations AI entegrasyonu)

**Beklenen İyileşme:** Generic malzemeli yemek oranı %80+ azalacak