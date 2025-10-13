# 🇹🇷 TÜRK MUTFAĞI YEMEK VERITABANI HAZIRLAMA TALİMATI

Bu talimatı ChatGPT'ye verip JSON'ları hazırlat.

---

## 👨‍⚕️ SEN KİMSİN?

Sen **20 yıllık dünya standardında profesyonel diyetisyensin**:
- ✅ En güncel diyet ve beslenme listelerine hakimsin
- ✅ Sağlıklı, dengeli, bilimsel temelli yemek tarifleri oluşturursun
- ✅ **Ekonomik, ucuz, bulunabilir, Türkiye'de kolay temin edilebilir malzemeler kullanırsın**
- ✅ **Basit, pratik, evde kolayca yapılabilen tarifler hazırlarsın**
- ✅ Makro dengeleri profesyonel düzeyde hesaplarsın (kilo alma, verme, kas yapma, form koruma)

---

## 📋 GENEL BİLGİLER

**Hedef:** 4000 adet Türk mutfağına özgü, profesyonel diyetisyen onaylı yemek tarifi

**Format:** JSON (Türkçe field isimleri)

**ÖNEMLİ:** Her seferinde **SADECE 200 YEMEK** ver (token limiti nedeniyle)

**Özellikler:**
- ✅ Türk mutfağı yemekleri (İngilizce isimler YOK!)
- ✅ Bilimsel, gerçekçi kalori ve makro değerleri
- ✅ **Ekonomik, UCUZ, bulunabilir malzemeler (gramaj ile)**
- ✅ **Basit, pratik, evde kolayca yapılabilen tarifler**
- ✅ Her öğün için uygun kalori aralıkları
- ✅ **5 farklı hedef için yemekler: Kilo Alma, Kilo Verme, Bulk (Kas+Kilo), Cut (Kas+Yağ Yakma), Form Koruma**
- ✅ Sağlıklı beslenme prensipleri

---

## 🎯 JSON FORMATI

Her yemek aşağıdaki formatta olmalı:

```json
{
  "id": "MEAL-1234567890123-45678",
  "kategori": "Kahvaltı",
  "isim": "Menemen",
  "kalori": 350,
  "protein": 18,
  "karbonhidrat": 25,
  "yag": 20,
  "hedef": "Cut",
  "zorluk": "kolay",
  "hazirlamaSuresi": 15,
  "malzemeler": [
    "2 adet yumurta",
    "1 adet domates (orta boy)",
    "1 adet sivri biber",
    "1 yemek kaşığı zeytinyağı",
    "Tuz, karabiber"
  ],
  "aciklama": "Domatesleri küp doğrayın. Biberleri ince ince kesin. Tavada zeytinyağını kızdırın, biberleri ekleyin. 2 dakika kavurun. Domatesleri ekleyip suyunu çekene kadar pişirin. Yumurtaları çırpıp ekleyin, karıştırarak pişirin. Tuz, karabiber ile servis edin.",
  "etiketler": ["kahvaltı", "protein", "sebze", "yumurta"],
  "alternatifler": [
    {
      "malzeme": "yumurta",
      "alternatifler": ["2 adet yumurta akı", "100g tofu"],
      "aciklama": "Protein kaynağı alternatifi"
    },
    {
      "malzeme": "zeytinyağı",
      "alternatifler": ["1 yemek kaşığı tereyağı", "Spray yağ"],
      "aciklama": "Yağ kaynağı alternatifi"
    }
  ]
}
```

**ÖNEMLİ: Her yemeğe EN AZ 2 ALTERNATİF ekle!** (Yukarıdaki örnekte 2 alternatif var)

---

## 🎯 HEDEF KATEGORİLERİ (Goal Tags)

Her yemek bir hedefe uygun olmalı:

| Hedef | Açıklama | Kalori Yaklaşımı | Protein | Karb | Yağ |
|-------|----------|------------------|---------|------|-----|
| **Bulk** | Kas yapma + Kilo alma | Yüksek kalori | Yüksek | Yüksek | Orta |
| **Definasyon** | Kas yapma + Yağ yakma (Cut) | Düşük kalori | Çok Yüksek | Düşük | Düşük |
| **Kilo Alma** | Sağlıklı kilo almak | Yüksek kalori | Orta | Yüksek | Orta-Yüksek |
| **Kilo Verme** | Sağlıklı kilo vermek | Düşük kalori | Yüksek | Düşük-Orta | Düşük |
| **Bakım** | Formunu korumak | Dengeli kalori | Dengeli | Dengeli | Dengeli |

### Makro Oranları:

- **Bulk:** Protein %30, Karb %45, Yağ %25
- **Definasyon:** Protein %40, Karb %30, Yağ %30
- **Kilo Alma:** Protein %25, Karb %50, Yağ %25
- **Kilo Verme:** Protein %35, Karb %35, Yağ %30
- **Bakım:** Protein %30, Karb %40, Yağ %30

---

## 📊 ÖĞÜN KATEGORİLERİ VE KALORİ ARALIKLARI

### 1️⃣ KAHVALTI (800 yemek - 200'er batch halinde)
**Kalori Aralığı:** 300-600 kcal  
**Protein:** 15-35g  
**Karbonhidrat:** 30-60g  
**Yağ:** 10-30g

**SAĞLIKLI SPORCU KAHVALTILARI:**
- Menemen (350 kcal, 18p, 25c, 20f)
- Çılbır (400 kcal, 22p, 30c, 22f)
- Peynirli Omlet (320 kcal, 24p, 8c, 22f)
- Haşlanmış Yumurta + Tam Buğday Ekmeği + Avokado (420 kcal, 20p, 35c, 22f)
- Beyaz Peynir + Zeytin + Domates + Tam Buğday Ekmeği (380 kcal, 18p, 45c, 15f)
- Yulaf Lapası + Muz + Ceviz + Bal (450 kcal, 12p, 65c, 16f)
- Protein Pancake (Yulaf + Yumurta + Protein Tozu) (420 kcal, 32p, 45c, 12f)
- Smoothie Bowl (Süzme Yoğurt + Meyve + Granola + Chia) (380 kcal, 22p, 48c, 12f)
- Fırında Yumurta + Sebzeler (300 kcal, 18p, 18c, 16f)
- Lor Peyniri + Salatalık + Tam Buğday Ekmek (320 kcal, 22p, 38c, 8f)
- Süzme Yoğurt + Yulaf + Meyveler (350 kcal, 18p, 48c, 8f)
- Avokado Toast (Tam Buğday + Avokado + Poşe Yumurta) (480 kcal, 20p, 42c, 26f)

### 2️⃣ ARA ÖĞÜN 1 (800 yemek - 200'er batch halinde)
**Kalori Aralığı:** 200-400 kcal  
**Protein:** 10-25g  
**Karbonhidrat:** 20-45g  
**Yağ:** 8-20g

**ÖNEMLİ: EN GÜNCEL BESLENME TRENDLERİNİ EKLE!**

**Klasik Örnekler:**
- Süzme Yoğurt + Bal + Ceviz (280 kcal, 15p, 35c, 12f)
- Fındık + Badem Karışımı (250 kcal, 8p, 12c, 20f)
- Elma Dilimi + Fıstık Ezmesi (220 kcal, 7p, 28c, 11f)
- Ayran + Peynirli Kraker (180 kcal, 10p, 22c, 6f)
- Yoğurt + Meyve (Çilek/Muz/Şeftali) (200 kcal, 12p, 32c, 4f)
- Kuru Üzüm + Ceviz (280 kcal, 6p, 42c, 12f)
- Humus + Havuç Çubukları (160 kcal, 6p, 18c, 8f)
- Lor Peyniri + Domates + Salatalık (150 kcal, 14p, 10c, 6f)
- Muz + Fıstık Ezmesi (300 kcal, 8p, 42c, 14f)

**Modern/Trend Örnekler (MUTLAKA EKLE!):**
- Karabuğday Patlağı (Buckwheat Popcorn) (120 kcal, 4p, 24c, 2f) - Definasyon/Kilo Verme için ideal
- Pirinç Patlağı + Hindistan Cevizi Yağı (180 kcal, 3p, 28c, 8f) - Bulk için
- Chia Pudding (Chia + Badem Sütü + Bal) (240 kcal, 6p, 32c, 10f)
- Protein Pancake (Yulaf + Yumurta + Protein Tozu) (280 kcal, 24p, 28c, 8f)
- Energy Balls (Hurma + Yulaf + Kakao + Fıstık Ezmesi) (220 kcal, 6p, 30c, 10f)
- Kinoa Patlağı (Quinoa Pop) (140 kcal, 5p, 26c, 3f)
- Süzme Yoğurt + Granola + Meyve (300 kcal, 18p, 38c, 10f)
- Protein Smoothie Bowl (Whey + Muz + Yulaf + Chia) (320 kcal, 28p, 42c, 8f)
- Yulaf Topları (Oat Balls: Yulaf + Bal + Fındık Ezmesi) (260 kcal, 8p, 36c, 12f)
- Lor Peyniri + Meyveler (180 kcal, 16p, 20c, 4f)

### 3️⃣ ÖĞLE YEMEĞİ (800 yemek - 200'er batch halinde)
**Kalori Aralığı:** 500-800 kcal  
**Protein:** 30-50g  
**Karbonhidrat:** 50-80g  
**Yağ:** 15-35g

**Örnekler:**
- Tavuk Şiş + Pilav + Salata (620 kcal, 42p, 65c, 20f)
- İskender Kebap (700 kcal, 45p, 55c, 32f)
- Kuru Fasulye + Pilav + Cacık (580 kcal, 28p, 82c, 14f)
- Mercimek Köfte + Salata (480 kcal, 18p, 72c, 14f)
- Mantı (Yoğurtlu) (650 kcal, 32p, 68c, 28f)
- İzmir Köfte + Pilav (720 kcal, 38p, 62c, 35f)
- Adana Kebap + Bulgur Pilavı (680 kcal, 40p, 58c, 32f)
- Patlıcan Musakka (520 kcal, 24p, 48c, 28f)
- Hünkar Beğendi (580 kcal, 35p, 42c, 30f)
- Etli Nohut (560 kcal, 32p, 62c, 20f)
- Tas Kebabı (640 kcal, 38p, 52c, 28f)
- Sulu Köfte (600 kcal, 34p, 58c, 24f)
- Tarhana Çorbası + Tavuklu Pilav (550 kcal, 36p, 68c, 16f)

### 4️⃣ ARA ÖĞÜN 2 (800 yemek - 200'er batch halinde)
**Kalori Aralığı:** 200-400 kcal  
**Protein:** 10-25g  
**Karbonhidrat:** 20-45g  
**Yağ:** 8-20g

**ÖNEMLİ: EN GÜNCEL BESLENME TRENDLERİNİ EKLE!**

**Klasik Örnekler:**
- Protein Smoothie (Süt + Muz + Yulaf + Fıstık Ezmesi) (320 kcal, 18p, 42c, 12f)
- Yumurta + Zeytinli Ekmek (280 kcal, 16p, 28c, 12f)
- Ballı Lor Peyniri (240 kcal, 18p, 32c, 6f)
- Çikolatalı Protein Bar (Ev Yapımı) (260 kcal, 12p, 32c, 10f)
- Kuru Erik + Ceviz (220 kcal, 5p, 38c, 8f)
- Haşlanmış Yumurta + Tam Buğday Galeta (200 kcal, 14p, 22c, 8f)
- Meyve Salatası + Süzme Yoğurt (180 kcal, 10p, 32c, 4f)

**Modern/Trend Örnekler (MUTLAKA EKLE!):**
- Karabuğday Patlağı + Hindistan Cevizi Yağı (150 kcal, 4p, 24c, 6f)
- Pirinç Patlağı + Badem Ezmesi (220 kcal, 6p, 30c, 10f)
- Protein Balls (Whey + Yulaf + Hurma) (240 kcal, 18p, 28c, 8f)
- Avokado Toast (Tam Buğday + Avokado + Chia) (280 kcal, 8p, 32c, 14f)
- Casein Pudding (Gece Proteini) (200 kcal, 24p, 18c, 4f)
- Yulaf + Protein Tozu + Muz (Pre-workout) (300 kcal, 22p, 42c, 6f)
- Rice Cake + Fıstık Ezmesi (180 kcal, 6p, 24c, 8f)

### 5️⃣ AKŞAM YEMEĞİ (800 yemek - 200'er batch halinde)
**Kalori Aralığı:** 400-700 kcal  
**Protein:** 30-50g  
**Karbonhidrat:** 40-70g  
**Yağ:** 12-30g

**Örnekler:**
- Izgara Somon + Zeytinyağlı Sebze (520 kcal, 42p, 28c, 28f)
- Tavuk Göğsü Izgara + Salata + Bulgur Pilavı (480 kcal, 45p, 48c, 14f)
- Zeytinyağlı Enginar + Cacık (320 kcal, 12p, 42c, 14f)
- Balık (Levrek/Çupra) Izgara + Yeşillik (420 kcal, 48p, 12c, 20f)
- Köfte + Közlenmiş Patlıcan Salata (560 kcal, 38p, 32c, 32f)
- Tavuk Sote + Bulgur Pilavı (520 kcal, 40p, 52c, 16f)
- İmam Bayıldı (380 kcal, 8p, 48c, 18f)
- Karnıyarık (520 kcal, 28p, 48c, 24f)
- Sebzeli Tavuk Güveç (440 kcal, 38p, 42c, 14f)
- Patlıcan Kebabı (500 kcal, 32p, 38c, 24f)
- Tavuklu Bezelye (420 kcal, 36p, 48c, 12f)

---

## ⚙️ ALAN AÇIKLAMALARI

| Alan | Açıklama | Örnek |
|------|----------|-------|
| `id` | Benzersiz ID (MEAL-timestamp-random) | `"MEAL-1234567890123-45678"` |
| `kategori` | Öğün tipi | `"Kahvaltı"`, `"Ara Öğün 1"`, `"Öğle"`, `"Ara Öğün 2"`, `"Akşam"` |
| `isim` | Yemeğin Türkçe adı | `"Menemen"` |
| `kalori` | Toplam kalori (kcal) | `350` |
| `protein` | Protein (gram) | `18` |
| `karbonhidrat` | Karbonhidrat (gram) | `25` |
| `yag` | Yağ (gram) | `20` |
| `hedef` | Hedef kategori | `"Bulk"`, `"Definasyon"`, `"Kilo Alma"`, `"Kilo Verme"`, `"Bakım"` |
| `zorluk` | Hazırlama zorluğu | `"kolay"`, `"orta"`, `"zor"` |
| `hazirlamaSuresi` | Hazırlama süresi (dakika) | `15` |
| `malzemeler` | Malzeme listesi (gramajlı) | `["2 adet yumurta", "1 domates"]` |
| `aciklama` | Kısa tarif (2-3 cümle) | `"Domatesleri doğrayın..."` |
| `etiketler` | Etiketler | `["kahvaltı", "protein", "yumurta"]` |
| `alternatifler` | **EN AZ 2 alternatif** (malzeme bazlı) | Aşağıdaki formatta |

### Alternatif Formatı:
```json
{
  "malzeme": "ana malzeme adı",
  "alternatifler": ["alternatif 1", "alternatif 2"],
  "aciklama": "kısa açıklama"
}
```

---

## ✅ ÖNEMLI KURALLAR

1. **SADECE TÜRK MUTFAĞI:** İngilizce yemek isimleri kullanma!
2. **EKONOMIK & UCUZ:** Bulunabilir, uygun fiyatlı malzemeler kullan
3. **BASIT & PRATİK:** Evde kolayca yapılabilir tarifler
4. **GERÇEKÇİ DEĞERLER:** Kalori ve makrolar gerçekçi olmalı
5. **DETAYLI MALZEME:** Gramaj/adet belirt (örn: "200g tavuk göğsü", "2 adet yumurta")
6. **BASIT TARİF:** 2-3 cümle yeterli, detaya girme
7. **ÇEŞİTLİLİK:** Aynı yemeği tekrarlama, varyasyonlar yap
8. **MAKRO DENGE:** Hedef kategorisine göre Protein/Karb/Yağ dengeli olsun
9. **EN AZ 2 ALTERNATİF:** Her yemeğe mutlaka en az 2 malzeme alternatifi ekle!
10. **KARBONHIDRAT DENGESİZLİĞİ YASAK:** Bir yemekte sadece TEK karbonhidrat kaynağı olmalı!

💡 **ALTERNATİF KURALLARI:**
- Alternatifler **BENZERİ MAKRO DEĞERLERİ** olmalı (aynı kalori, protein, karb, yağ aralığında)
- **MANTIKLI, GERÇEKÇİ** alternatifler sun (saçmalama!)
- **TÜRKİYE'DE BULUNABİLİR** malzemeler (İngilizce isim YOK!)
- Örnek: "200g tavuk göğsü" → "200g hindi göğsü" (DOĞRU ✅)
- Örnek: "2 adet yumurta" → "500ml süt" (YANLIŞ ❌ - makrolar uyumsuz!)

⛔ **KARBONHIDRAT DENGESİ KURALLARI:**
- Bir yemekte **SADECE BİR** ana karbonhidrat kaynağı kullan!
- **YANLIŞ ❌:** Hem pirinç pilavı hem haşlanmış patates
- **YANLIŞ ❌:** Hem bulgur hem pirinç
- **YANLIŞ ❌:** Hem makarna hem ekmek
- **DOĞRU ✅:** Tavuk + Sadece pirinç pilavı + Salata
- **DOĞRU ✅:** Köfte + Sadece bulgur + Sebze
- **DOĞRU ✅:** Balık + Sadece patates + Yeşillik

---

## 📦 DOSYA YAPISI

**ÖNEMLİ: Her seferinde sadece 200 yemek ver! Yoksa token bitiyor!**

Batch sistemi kullan (toplam 4000 yemek):

```
# KAHVALTI (800 yemek)
turk_kahvalti_batch_1.json   → 200 kahvaltı
turk_kahvalti_batch_2.json   → 200 kahvaltı
turk_kahvalti_batch_3.json   → 200 kahvaltı
turk_kahvalti_batch_4.json   → 200 kahvaltı

# ARA ÖĞÜN 1 (800 yemek)
turk_ara_ogun_1_batch_1.json → 200 ara öğün
turk_ara_ogun_1_batch_2.json → 200 ara öğün
turk_ara_ogun_1_batch_3.json → 200 ara öğün
turk_ara_ogun_1_batch_4.json → 200 ara öğün

# ÖĞLE (800 yemek)
turk_ogle_batch_1.json       → 200 öğle yemeği
turk_ogle_batch_2.json       → 200 öğle yemeği
turk_ogle_batch_3.json       → 200 öğle yemeği
turk_ogle_batch_4.json       → 200 öğle yemeği

# ARA ÖĞÜN 2 (800 yemek)
turk_ara_ogun_2_batch_1.json → 200 ara öğün
turk_ara_ogun_2_batch_2.json → 200 ara öğün
turk_ara_ogun_2_batch_3.json → 200 ara öğün
turk_ara_ogun_2_batch_4.json → 200 ara öğün

# AKŞAM (800 yemek)
turk_aksam_batch_1.json      → 200 akşam yemeği
turk_aksam_batch_2.json      → 200 akşam yemeği
turk_aksam_batch_3.json      → 200 akşam yemeği
turk_aksam_batch_4.json      → 200 akşam yemeği
```

Her dosya bir array olmalı:

```json
[
  {
    "id": "MEAL-1234567890123-00001",
    "kategori": "Kahvaltı",
    "isim": "Menemen",
    ...
  },
  {
    "id": "MEAL-1234567890123-00002",
    "kategori": "Kahvaltı",
    "isim": "Çılbır",
    ...
  }
]
```

---

## 🎯 ÖRNEK TAM YEMEK

```json
{
  "id": "MEAL-1699000000000-12345",
  "kategori": "Öğle",
  "isim": "Tavuk Şiş + Bulgur Pilavı + Salata",
  "kalori": 620,
  "protein": 42,
  "karbonhidrat": 65,
  "yag": 20,
  "hedef": "Definasyon",
  "zorluk": "orta",
  "hazirlamaSuresi": 30,
  "malzemeler": [
    "200g tavuk göğsü (küp doğranmış)",
    "1 su bardağı bulgur",
    "2 su bardağı su",
    "1 yemek kaşığı zeytinyağı",
    "1 kase karışık yeşil salata",
    "Limon, tuz, karabiber, kimyon"
  ],
  "aciklama": "Tavuk küplerini baharatlarla marine edin, şişe dizin ve ızgara yapın. Bulguru zeytinyağında kavurun, sıcak su ekleyip piştirin. Salatayı limon ve zeytinyağı ile servis edin.",
  "etiketler": ["öğle", "protein", "bulgur", "ızgara", "tavuk", "sağlıklı"],
  "alternatifler": [
    {
      "malzeme": "tavuk göğsü",
      "alternatifler": ["200g hindi göğsü", "200g köfte (yağsız kıyma)", "150g ton balığı"],
      "aciklama": "Yüksek protein kaynağı alternatifi"
    },
    {
      "malzeme": "bulgur",
      "alternatifler": ["1 su bardağı pirinç", "1 su bardağı kinoa", "150g makarna"],
      "aciklama": "Karbonhidrat kaynağı alternatifi"
    },
    {
      "malzeme": "zeytinyağı",
      "alternatifler": ["1 yemek kaşığı tereyağı", "Spray yağ (cut için)", "1 çay kaşığı hindistan cevizi yağı"],
      "aciklama": "Sağlıklı yağ kaynağı"
    }
  ]
}
```

**NOT:** Yukarıdaki örnekte 3 alternatif var. Her yemek EN AZ 2 alternatif içermeli!

---

## 🚀 HAZIRLIK ADIMLARI

1. **ChatGPT'ye bu talimatı ver**
2. **Her kategori için JSON iste** (kahvaltı, ara öğün 1, öğle, ara öğün 2, akşam)
3. **JSON'ları indir** (.json dosyaları)
4. **Bana gönder** (ben yükleyeceğim)

---

## ❓ ULTRA GÜÇLÜ GPT PROMPT

```
🎯 ROL & KİMLİK:
Sen 20 yıllık dünya standardında PROFESYONEL DİYETİSYENsin.
- Sports Nutrition uzmanısın
- En güncel beslenme trendlerine hakimsin (2024-2025)
- Makro hesaplama konusunda dahi sayılırsın
- Türk mutfağını modern bilimle harmanlarsın

🚀 GÖREV:
4000 adet Türk mutfağı yemek veritabanı oluştur.

⚠️ KRİTİK KURAL:
Her seferinde SADECE 200 YEMEK ver! (Token limiti)

📋 İLK ADIM:
turk_kahvalti_batch_1.json → 200 Türk kahvaltısı

🎯 5 HEDEF KATEGORİSİ (Her yemek birini seçmeli):
1. **Bulk** (Kas Yapma + Kilo Alma): Yüksek kalori, P30% K45% Y25%
2. **Definasyon** (Kas Yapma + Yağ Yakma): Düşük kalori, P40% K30% Y30%
3. **Kilo Alma**: Sağlıklı kilo, P25% K50% Y25%
4. **Kilo Verme**: Sağlıklı zayıflama, P35% K35% Y30%
5. **Bakım** (Maintenance): Dengeli, P30% K40% Y30%

✅ ZORUNLU ÖZELLİKLER:
1. **SADECE TÜRK MUTFAĞI** (İngilizce isim YOK!)
2. **UCUZ, EKONOMİK, BULUNABİLİR** malzemeler
3. **BASİT, PRATİK, evde kolayca yapılabilir**
4. **GERÇEKÇİ kalori ve makrolar** (hedef kategorisine uygun)
5. **GRAMAJLI malzeme listesi** (örn: "200g tavuk", "2 adet yumurta")
6. **Basit tarif** (2-3 cümle, kısa)
7. **Kalori aralığı**: 300-600 kcal (kahvaltı için)
8. **Her yemeğe EN AZ 2 malzeme alternatifi** (zorunlu!)

⛔ YASAK YEMEKLER (SAĞLIKSIZ, SPORCULARA UYGUN DEĞİL):
- Hamur işleri: Poğaça, simit, pide, börek, açma, katmer
- İşlenmiş etler: Sucuk, salam, pastırma, sosis
- Kızartmalar: Kızarmış ekmek, patates kızartması
- Yüksek şekerli: Reçel, pekmez, nutella
- Fast food: Pizza, hamburger, dürüm (dışarıdan)

⛔ KARBONHIDRAT DENGESİZLİĞİ (YANLIŞ KOMBINASYONLAR):
- Hem pirinç hem patates aynı yemekte ❌
- Hem bulgur hem pirinç aynı yemekte ❌
- Hem makarna hem ekmek aynı yemekte ❌
- Hem pilav hem yufka/börek aynı yemekte ❌
- **KURAL:** Bir öğünde **SADECE 1** ana karbonhidrat kaynağı!

🔥 MODERN BESLENME TRENDLERİ (MUTLAKA EKLE!):
Ara öğünlerde şunları kullan:
- Karabuğday patlağı (buckwheat popcorn)
- Pirinç patlağı + hindistan cevizi yağı
- Kinoa patlağı (quinoa pop)
- Chia pudding (chia + badem sütü)
- Protein pancake (yulaf + yumurta + whey)
- Energy balls (hurma + yulaf + kakao)
- Protein smoothie bowl
- Yulaf topları (ev yapımı)
- Lor peyniri + meyveler
- Süzme yoğurt + granola
- Casein pudding (gece proteini)
- Avokado toast + chia
- Rice cake + fıstık ezmesi

💪 ÖRNEK YEMEK YAPISI:
```json
{
  "id": "MEAL-1234567890-12345",
  "kategori": "Kahvaltı",
  "isim": "Protein Pancake (Yulaf + Yumurta)",
  "kalori": 420,
  "protein": 32,
  "karbonhidrat": 45,
  "yag": 12,
  "hedef": "Definasyon",
  "zorluk": "kolay",
  "hazirlamaSuresi": 15,
  "malzemeler": [
    "60g yulaf unu",
    "2 adet yumurta",
    "1 scoop whey protein (30g)",
    "100ml süt",
    "1 çay kaşığı kabartma tozu",
    "Tarçın, bal (opsiyonel)"
  ],
  "aciklama": "Tüm malzemeleri blenderda karıştır. Yapışmaz tavada orta ateşte pankek şeklinde pişir. Her tarafı 2-3 dakika pişir. Bal veya meyve ile servis et.",
  "etiketler": ["protein", "kahvaltı", "yulaf", "pratik", "definasyon"],
  "alternatifler": [
    {
      "malzeme": "whey protein",
      "alternatifler": ["3 adet yumurta akı", "50g lor peyniri"],
      "aciklama": "Protein kaynağı alternatifi"
    },
    {
      "malzeme": "yulaf unu",
      "alternatifler": ["60g kepek", "50g tam buğday unu"],
      "aciklama": "Karbonhidrat kaynağı alternatifi"
    }
  ]
}
```

🎯 ŞİMDİ YAP:
Batch 1'i hazırla (200 farklı kahvaltı).
Her yemek yukarıdaki formatta olmalı.
Bitince "Batch 1 tamamlandı" de, batch 2'yi isteyeceğim.

BAŞLA! 🚀
```

---

## 🎯 BATCH SİSTEMİ (ÖNEMLİ!)

GPT her seferinde **SADECE 200 YEMEK** verecek, yoksa token bitiyor!

**Sıralama:**
1. Kahvaltı Batch 1 (200) → iste
2. Kahvaltı Batch 2 (200) → iste
3. Kahvaltı Batch 3 (200) → iste
4. Kahvaltı Batch 4 (200) → iste
5. Ara Öğün 1 Batch 1 (200) → iste
6. Ara Öğün 1 Batch 2 (200) → iste
7. Ara Öğün 1 Batch 3 (200) → iste
8. Ara Öğün 1 Batch 4 (200) → iste
9. Öğle Batch 1 (200) → iste
10. Öğle Batch 2 (200) → iste
11. Öğle Batch 3 (200) → iste
12. Öğle Batch 4 (200) → iste
13. Ara Öğün 2 Batch 1 (200) → iste
14. Ara Öğün 2 Batch 2 (200) → iste
15. Ara Öğün 2 Batch 3 (200) → iste
16. Ara Öğün 2 Batch 4 (200) → iste
17. Akşam Batch 1 (200) → iste
18. Akşam Batch 2 (200) → iste
19. Akşam Batch 3 (200) → iste
20. Akşam Batch 4 (200) → iste

**Toplam: 4000 kaliteli, profesyonel, modern yemek! 🎉**

**HAZIRLADIĞIN JSON'LARI BANA AT, BEN YÜKLEYECEĞİM! 🚀**
