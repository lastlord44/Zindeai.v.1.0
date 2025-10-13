# 🎯 3000 YEMEK OLUŞTURMA TALİMATI - GENETİK ALGORİTMA UYUMLU

## 🚨 KRİTİK AMAÇ
Bu talimat, **genetik algoritmanın tolerans ihlallerini önlemek** için optimize edilmiştir. Her yemek **dar kalori/makro aralıklarında** olmalı ki algoritma dinamik kullanıcı profillerine göre doğru plan oluşturabilsin.

---

## 📊 HEDEF: 3000 YEMEK

### Besin Bazlı Dağılım

#### Protein Kaynakları (Ana Yemekler)
1. **tavuk_bazli_400.json** → 400 yemek
2. **dana_eti_bazli_300.json** → 300 yemek  
3. **kofte_kiyma_bazli_300.json** → 300 yemek
4. **balik_bazli_300.json** → 300 yemek (hamsi, uskumru, palamut, ton balığı - SADECE EKONOMİK BALIKLAR)
5. **hindi_bazli_200.json** → 200 yemek

#### Protein Kaynakları (Kahvaltı & Ara Öğün)
6. **yumurta_bazli_400.json** → 400 yemek
7. **suzme_yogurt_bazli_300.json** → 300 yemek
8. **peynir_bazli_200.json** → 200 yemek

#### Bitkisel Protein & Karbonhidrat
9. **baklagil_bazli_300.json** → 300 yemek (mercimek, nohut, fasulye, barbunya)

**TOPLAM: 3000 YEMEK**

---

## ⚡ GENETİK ALGORİTMA UYUMLULUĞU

### 🎯 Tolerans İhlalini Önleme Stratejisi

**PROBLEM**: Genetik algoritma geniş kalori aralıklarında yemek bulunca toleransı aşıyor.

**ÇÖZÜM**: Her öğün tipi için **DAR KALORI ARALIĞI** belirle!

### 📏 ÖĞÜN TİPİNE GÖRE KALORİ ARALIĞI (KATII!)

#### Kahvaltı
- **Kalori**: 350-450 kcal (100 kcal fark)
- **Protein**: 25-35g
- **Karbonhidrat**: 35-50g
- **Yağ**: 10-18g

#### Öğle Yemeği
- **Kalori**: 450-550 kcal (100 kcal fark)
- **Protein**: 40-55g
- **Karbonhidrat**: 40-55g
- **Yağ**: 12-20g

#### Akşam Yemeği
- **Kalori**: 400-500 kcal (100 kcal fark)
- **Protein**: 35-50g
- **Karbonhidrat**: 30-45g
- **Yağ**: 10-18g

#### Ara Öğün 1 (Sabah Ara Öğün)
- **Kalori**: 150-250 kcal (100 kcal fark)
- **Protein**: 15-25g
- **Karbonhidrat**: 15-25g
- **Yağ**: 5-10g

#### Ara Öğün 2 (Öğleden Sonra/Akşam)
- **Kalori**: 150-250 kcal (100 kcal fark)
- **Protein**: 15-25g
- **Karbonhidrat**: 10-20g
- **Yağ**: 5-10g

### ⚠️ NEDEN DAR ARALIK ÖNEMLİ?

**Örnek Senaryo:**
- Kullanıcı profili: 2000 kcal/gün, 150g protein, 180g carb, 60g fat
- Genetik algoritma: Her öğün için hedef hesaplar
- Eğer yemekler 300-700 kcal arasındaysa → Algoritma hatalı kombinasyon yapar → Tolerans aşılır!
- Eğer yemekler 450-550 kcal arasındaysa → Algoritma doğru kombinasyon yapar → Tolerans içinde kalır!

---

## 🇹🇷 SADECE TÜRK MUTFAĞI - KATII KURALLAR

### ✅ İZİN VERİLEN BESİNLER

#### Karbonhidrat Kaynakları
- Bulgur pilavı, pirinç pilavı, erişte, makarna
- Ekmek (tam buğday, çavdar, kepekli)
- Patates (haşlama, fırın), tatlı patates
- Yulaf ezmesi (sadece kahvaltıda)
- Mercimek, nohut, kuru fasulye, barbunya

#### Protein Kaynakları
- Tavuk (göğüs, but, bütün), hindi
- Dana eti (biftek, antrikot, kuşbaşı, kıyma)
- Köfte, ızgara köfte
- **Balık (SADECE EKONOMİK)**: Hamsi, uskumru, palamut, ton balığı
- Yumurta (haşlama, omlet, menemen, çılbır)
- Süzme yoğurt, Türk peyniri (beyaz, kaşar, lor)

#### Sebzeler
- Domates, salatalık, yeşillik, marul, roka
- Patlıcan, biber, kabak
- Brokoli, karnabahar, ıspanak, taze fasulye
- Havuç, turp, pancar
- Maydanoz, dereotu, nane

#### Yağ Kaynakları
- Zeytinyağı, tereyağı (az miktarda)
- **Hindistan cevizi yağı** (güncel trend, sağlıklı yağ)
- Ceviz, badem, fındık, fıstık (çiğ/kavrulmuş)
- Zeytin

#### 🔥 ARA ÖĞÜN TREND BESİNLERİ (ÇOK ÖNEMLİ!)

**Modern fitness trendlerine uygun besinler:**

1. **Kahve** (sade, şekersiz)
   - Türk kahvesi
   - Filtre kahve
   - Espresso
   - Hindistan cevizi yağı eklenebilir (bulletproof coffee)

2. **Meyveler**
   - Muz (enerji, karbonhidrat)
   - Elma (lif, düşük kalori)
   - Portakal, armut, şeftali

3. **Fıstık Ezmesi**
   - Şekersiz, doğal fıstık ezmesi
   - Badem ezmesi
   - Katıksız, katkısız

4. **Protein Bar**
   - Şekersiz, doğal içerikli
   - Yüksek protein (15-20g)
   - Düşük şeker (5g altı)

5. **Kuruyemiş**
   - Badem (10-15g)
   - Ceviz (10-15g)
   - Fındık, fıstık (çiğ veya kavrulmuş)

6. **Diğer Trend Besinler**
   - Hindistan cevizi yağı (1 yemek kaşığı)
   - Yulaf (1/2 su bardağı)
   - Bitter çikolata (%85 kakao, 10-20g)

### ❌ YASAK BESİNLER (YABANCI MUTFAK VE PAHALI BALIKLAR)

**ASLA KULLANMA:**

1. **Yabancı Mutfak**
   - Quinoa, chia seed, acai berry
   - Hummus, tahini (aşırı kalori)
   - Cottage cheese, ricotta (Türk mutfağında yok)
   - Avokado (pahalı, yabancı)
   - Protein tozu (whey, kazein) → Sadece doğal besinler
   - Sushi, poke bowl

2. **Pahalı Balıklar (YASAK!)**
   - ❌ Levrek
   - ❌ Çipura
   - ❌ Somon
   - **SADECE EKONOMİK BALIKLAR**: Hamsi, uskumru, palamut, ton balığı

3. **Fast Food & Sağlıksız**
   - Bagel, croissant, donuts
   - Pizza, hamburger, tost
   - Döner, kokoreç
   - Poğaça, börek, pişi, simit (un ürünleri - sağlıksız)

### 🚫 UNLU MAMUL KISITLAMASI
**ÇOK ÖNEMLİ**: Poğaça, börek, pişi, simit, açma gibi hamur işleri YASAK! Bunlar:
- Aşırı yağlı ve kalorili
- Makro dengesi kötü (çok carb, az protein)
- Genetik algoritmayı bozar

**İSTİSNA**: Sadece tam buğday ekmeği, çavdar ekmeği gibi sağlıklı ekmek türleri izinli.

---

## 🍳 PİŞİRME YÖNTEMLERİ VE ÖNERİLERİ

### Sağlıklı Pişirme Teknikleri

#### 1. IZGARA
- **Kullanım**: Tavuk, dana, köfte, balık
- **Avantaj**: Düşük yağ, yüksek lezzet
- **Örnek**: Izgara tavuk göğüs, ızgara köfte, ızgara hamsi

#### 2. FIRINDA PİŞİRME
- **Kullanım**: Tavuk, dana, balık, sebze
- **Avantaj**: Eşit pişme, az yağ
- **Örnek**: Fırında tavuk but, fırında somon, fırında patates
- **Sıcaklık**: 180-200°C, 25-40 dakika

#### 3. HAŞLAMA
- **Kullanım**: Tavuk, yumurta, sebze, bulgur, pirinç
- **Avantaj**: Sıfır yağ, sağlıklı
- **Örnek**: Haşlanmış tavuk, haşlanmış yumurta, haşlanmış brokoli
- **Süre**: Tavuk 30-40 dk, yumurta 8-10 dk, sebze 5-10 dk

#### 4. BUHARlama
- **Kullanım**: Sebzeler, balık
- **Avantaj**: Vitamin kaybı minimum
- **Örnek**: Buharda ıspanak, buharda brokoli, buharda hamsi

#### 5. SOTE
- **Kullanım**: Tavuk, sebze
- **Avantaj**: Hızlı, lezzetli
- **Yağ**: 1 yemek kaşığı zeytinyağı
- **Örnek**: Tavuk sote, karışık sebze sote

#### 6. TAVA (Dikkatli!)
- **Kullanım**: Sınırlı, az yağ ile
- **Yağ**: Maksimum 1 tatlı kaşığı zeytinyağı
- **Örnek**: Omlet, menemen
- **NOT**: Derin yağda kızartma YASAK!

### Pişirme Süreleri (Ortalama)

| Besin | Yöntem | Süre | Sıcaklık |
|-------|--------|------|----------|
| Tavuk göğüs (150g) | Izgara | 15-20 dk | Orta ateş |
| Tavuk göğüs (150g) | Fırın | 25-30 dk | 180°C |
| Tavuk göğüs (150g) | Haşlama | 30-35 dk | Kaynar su |
| Dana biftek (150g) | Izgara | 8-12 dk | Yüksek ateş |
| Köfte (100g) | Izgara | 10-15 dk | Orta-yüksek |
| Hamsi | Fırın | 15-20 dk | 200°C |
| Uskumru | Izgara | 10-15 dk | Orta ateş |
| Yumurta | Haşlama | 8-10 dk | Kaynar su |
| Brokoli | Haşlama | 5-7 dk | Kaynar su |
| Bulgur | Haşlama | 15-20 dk | Kaynar su |

### Porsiyonlama İpuçları

- **Et (tavuk, dana)**: 150g (avuç büyüklüğünde)
- **Balık**: 150-200g (el ayası büyüklüğünde)
- **Pirinç/Bulgur (pişmiş)**: 100-120g (1 çay bardağı)
- **Sebze**: 200-300g (bol miktarda)
- **Zeytinyağı**: 1 yemek kaşığı (15ml)
- **Yumurta**: 2-3 adet (orta boy)

---

## 📝 JSON YAPI FORMATI

Her JSON dosyası şu yapıda olmalı:

```json
[
  {
    "meal_name": "Izgara Tavuk Göğüs + Bulgur Pilavı + Yeşil Salata",
    "main_ingredient": "tavuk",
    "meal_type": "ogle",
    "calories": 480,
    "protein": 48,
    "carbs": 45,
    "fat": 12,
    "portion_info": "150g tavuk göğüs, 100g bulgur (pişmiş), bol yeşillik",
    "cooking_method": "Izgara, haşlama",
    "cooking_time": "15-20 dakika tavuk ızgara, 15 dakika bulgur haşlama",
    "ingredients": [
      "150g tavuk göğüs (ızgara, 15-20 dk)",
      "100g bulgur pilavı (haşlama, 15 dk)",
      "200g karışık yeşillik (marul, roka, maydanoz)",
      "1 yemek kaşığı zeytinyağı",
      "1 adet domates",
      "1 adet salatalık",
      "tuz, karabiber, limon"
    ]
  }
]
```

### 🔑 Alan Açıklamaları

- **meal_name**: Açıklayıcı isim (ana malzeme + garnitür + salata/sebze)
- **main_ingredient**: Dosya adıyla uyumlu (tavuk, dana_eti, kofte_kiyma, balik, hindi, yumurta, suzme_yogurt, peynir, baklagil)
- **meal_type**: kahvalti, ogle, aksam, ara_ogun_1, ara_ogun_2
- **calories**: Yukarıdaki aralıklara KATII uyum!
- **protein/carbs/fat**: Gram cinsinden, aralıklara uygun
- **portion_info**: Net porsiyon bilgisi (150g tavuk, 100g bulgur gibi)
- **cooking_method**: Pişirme yöntemi (ızgara, fırın, haşlama, buhar, sote)
- **cooking_time**: Toplam pişirme süresi veya malzeme bazında
- **ingredients**: Detaylı malzeme listesi (pişirme yöntemi ve süre dahil)

---

## 🎨 ÇEŞİTLİLİK STRATEJİSİ

### Her Besin İçin Minimum Çeşitlilik

Her ana besin için **EN AZ 3 FARKLI KOMBINASYON** olmalı:

#### Tavuk Bazlı Örnek (400 yemek → her biri farklı olmalı)
1. Izgara Tavuk + Bulgur + Yeşil Salata (ızgara, 15-20 dk)
2. Fırında Tavuk + Pirinç + Brokoli (fırın 180°C, 25-30 dk)
3. Haşlanmış Tavuk + Patates + Havuç (haşlama, 30-35 dk)
4. Tavuk Sote + Makarna + Domates Sosu (sote, 10-15 dk)
5. Tavuk Izgara + Mercimek + Közlenmiş Biber
6. Tavuk Haşlama + Sebze Haşlama + Zeytinyağı
7. Tavuk Fırın + Tatlı Patates + Ispanak
... (400 farklı kombinasyon)

#### Yumurta Bazlı Kahvaltı Örnek (400 yemek)
1. 3 Haşlanmış Yumurta + Tam Buğday Ekmeği + Domates/Salatalık (8-10 dk haşlama)
2. Omlet (3 yumurta) + Beyaz Peynir + Yeşillik (5-7 dk tavada)
3. Menemen + Tam Buğday Ekmeği + Zeytin (10 dk pişirme)
4. Çılbır (Yoğurtlu Yumurta) + Tam Buğday Ekmeği
5. Scrambled Eggs + Domates + Salatalık
6. 2 Haşlanmış Yumurta + Lor Peyniri + Ceviz
7. Yumurta + Süzme Yoğurt + Yulaf + Meyve
... (400 farklı kombinasyon)

#### Ara Öğün Örnekleri (Trend Besinler!)
1. Kahve (şekersiz) + Badem (15g)
2. Protein Bar (şekersiz) + Elma
3. Süzme Yoğurt + Fıstık Ezmesi (1 kaşık)
4. Muz + Ceviz (10g)
5. Bulletproof Coffee (kahve + hindistan cevizi yağı)
6. Protein Bar + Kahve
7. Elma + Badem Ezmesi
8. Süzme Yoğurt + Yulaf + Badem
9. Bitter Çikolata (%85) + Kahve
10. Muz + Fıstık Ezmesi
... (çeşitli kombinasyonlar)

### Garnitür Çeşitleri

**Karbonhidrat:**
- Bulgur pilavı (haşlama, 15-20 dk)
- Pirinç pilavı (haşlama, 15-20 dk)
- Makarna (haşlama, 8-10 dk)
- Patates (fırın 180°C 30 dk, veya haşlama 20 dk)
- Mercimek (haşlama, 25-30 dk)

**Sebze:**
- Yeşil salata (taze)
- Haşlanmış sebze (brokoli, karnabahar, 5-7 dk)
- Közlenmiş biber/patlıcan
- Zeytinyağlı sebze (ıspanak, 10 dk sote)

**Yağ/Sos:**
- Zeytinyağı (1-2 kaşık)
- Yoğurt (düşük yağlı)
- Tereyağı (az miktarda, 1 tatlı kaşığı)
- Ceviz, badem (10-15g, çiğ)
- Hindistan cevizi yağı (1 yemek kaşığı)

---

## 📋 ÖĞÜN TİPİ DAĞILIMI

Her JSON dosyasında öğün tipleri **dengeli** dağıtılmalı:

### Protein Bazlı Ana Yemekler (Tavuk, Dana, Köfte, Balık, Hindi)
- - **Öğle**: %35-40
- **Akşam**: %35-40
- **Ara Öğün 1**: %5-10
- **Ara Öğün 2**: %5-10

### Yumurta/Süzme Yoğurt/Peynir
- **Kahvaltı**: %40-50
- **Öğle**: %10-15
- **Akşam**: %10-15
- **Ara Öğün 1**: %15-20
- **Ara Öğün 2**: %15-20

### Baklagil Bazlı
- **Kahvaltı**: %5-10
- **Öğle**: %40-45
- **Akşam**: %40-45
- **Ara Öğün 1**: %0-5
- **Ara Öğün 2**: %0-5

---

## 🔥 KALİTE KONTROL KURALLARI

### Her Yemek İçin Kontrol Et:

1. ✅ **Kalori aralığı doğru mu?** (Öğün tipine göre ±100 kcal)
2. ✅ **Protein yeterli mi?** (Minimum değerlere uygun)
3. ✅ **Makro oranı dengeli mi?** (P:C:F = 30:40:30 civarı)
4. ✅ **Yabancı besin var mı?** (Quinoa, chia, whey → YASAK!)
5. ✅ **Pahalı balık var mı?** (Levrek, çipura, somon → YASAK!)
6. ✅ **Un mamulü var mı?** (Poğaça, börek → YASAK!)
7. ✅ **Porsiyon bilgisi net mi?** (150g tavuk, 100g bulgur gibi)
8. ✅ **Pişirme yöntemi belirtilmiş mi?** (Izgara, fırın, haşlama, vs.)
9. ✅ **Pişirme süresi var mı?** (15-20 dk gibi)
10. ✅ **Malzeme listesi detaylı mı?** (Pişirme yöntemi ve süre dahil)
11. ✅ **Aynı kombinasyon tekrar etmiş mi?** (Her yemek farklı olmalı!)

---

## 🚀 DOSYA OLUŞTURMA SÜRECİ

### Adım 1: Her Dosya İçin Plan Yap
- Kaç kahvaltı, kaç öğle, kaç akşam, kaç ara öğün olacağını hesapla
- Kalori aralığını belirle
- Kullanılacak garnitürleri listele
- Pişirme yöntemlerini çeşitlendir

### Adım 2: Kombinasyonları Oluştur
- Ana besini sabit tut (örn: tavuk)
- Farklı garnitürlerle eşleştir
- Farklı pişirme yöntemleri kullan (ızgara, fırın, haşlama)
- Her kombinasyonun Tamam, düzeltiyorum! kalorisini hesapla
- Şimdi:
1. **Ara Aralıklara öğünlerde trend uygunluğunu kontrol et

### besinler** Adım 3: ekleyeceğim
JSON 2. Formatına Dök
**Pahalı balıkları çıkaracağım** (levrek, çipura, somon - → Yukarıdaki sadece ekonomik balıklar)
3. JSON yapısını kullan
**Pişirme önerileri** ekleyeceğim

- Tüm <write_to_file>
alanları eksiksiz doldur (cooking_method, cooking_time dahil)
- Öğün tipi dağılımını dengele
- <path>BESIN_BAZLI_JSON_OLUSTURMA_TALIMATI.md</path>
Pişirme detaylarını ekle

### Adım 4: <content># Kalite Kontrol
- 🎯 11 maddelik 3000 kontrolü yap
- Tekrar YEMEK OLUŞTURMA eden kombinasyonları bul ve değiştir
- Yabancı besinleri temizle
- Pahalı balıkları temizle (levrek, çipura, somon)
- Pişirme bilgilerini kontrol et

---

## TALİMATI - GENETİK ALGORİTMA UYUMLU

## 🚨 📦 KRİTİK ÇIKTI FORMATI

Tüm dosyalar AMAÇ
Bu talimat, **genetik oluşturulduktan sonra:

```
📁 algoritmanın tolerans 3000_YEMEK_VERITABANI/
├── ihlallerini önlemek** için optimize tavuk_bazli_400.json ✅ (400 edilmiştir. yemek)
Her yemek **dar ├── dana_eti_bazli_300.json kalori/makro ✅ (300 yemek)
├── kofte_kiyma_bazli_300.json ✅ aralıklarında** (300 yemek)
├── balik_bazli_300.json ✅ (300 yemek olmalı ki - SADECE algoritma hamsi, uskumru, palamut, dinamik ton)
├── kullanıcı hindi_bazli_200.json profillerine göre doğru ✅ (200 yemek)
├── yumurta_bazli_400.json ✅ (400 yemek)
├── suzme_yogurt_bazli_300.json ✅ plan oluşturabilsin.

---

(300 ## yemek)
📊 HEDEF: 3000 ├── YEMEK

### peynir_bazli_200.json ✅ Besin (200 yemek)
└── Bazlı baklagil_bazli_300.json ✅ (300 yemek)

TOPLAM: 9 dosya, 3000 yemek
```

Dağılım

#### **SON Protein Kaynakları (Ana ADIM**: Tüm dosyaları **ZIP** olarak Yemekler)
1. paketle!

---

## 💡 **tavuk_bazli_400.json** → 400 yemek
2. ÖNEMLİ HATIRLATMALAR

**dana_eti_bazli_300.json** → 300 yemek  
3. ### Genetik Algoritma İçin:
- **kofte_kiyma_bazli_300.json** → 300 yemek
✅ Dar kalori 4. aralıkları **balik_bazli_300.json** → 300 → Tolerans yemek ihlali yok
- ✅ (SADECE Dengeli makro oranları → ekonomik: hamsi, uskumru, Daha palamut, ton balığı)
5. iyi **hindi_bazli_200.json** → 200 yemek

#### eşleşme
- Protein Kaynakları ✅ Çeşitli kombinasyonlar → (Kahvaltı & Ara Öğün)
6. Çeşitlilik sistemi **yumurta_bazli_400.json** → çalışır
- ✅ 400 Öğün yemek
tipi 7. dağılımı → Günlük **suzme_yogurt_bazli_300.json** → plan 300 dengeli

### Türk yemek
Mutfağı İçin:
- ✅ Yerel, kolay 8. bulunur **peynir_bazli_200.json** → 200 yemek

#### malzemeler
Bitkisel - Protein & Karbonhidrat
9. **baklagil_bazli_300.json** ✅ Ekonomik → 300 yemek (mercimek, nohut, balıklar (hamsi, uskumru, palamut, ton)
- fasulye, ❌ Pahalı barbunya)

balıklar YASAK (levrek, çipura, somon)
- **TOPLAM: 3000 YEMEK**

✅ ---

## Gerçekçi ⚡ GENETİK porsiyonlar ALGORİTMA (150g UYUMLULUĞU

et, ### 100g 🎯 Tolerans pilav)
- ✅ Türk İhlalini damak tadına Önleme uygun Stratejisi

kombinasyonlar
- ❌ **PROBLEM**: Genetik Yabancı, algoritma geniş pahalı, egzotik besinler YOK

### Ara Öğün Trendleri:
- ✅ Kahve (şekersiz, Türk/filtre/espresso)
kalori - aralıklarında yemek bulunca toleransı aşıyor.

**ÇÖZÜM**: Her öğün tipi ✅ Protein için **DAR bar (şekersiz, KALORI ARALIĞI** belirle!

doğal)
- ### ✅ Fıstık ezmesi (şekersiz, 📏 katıksız)
- ✅ Meyveler ÖĞÜN (muz, TİPİNE elma, GÖRE portakal)
- ✅ KALORİ Kuruyemiş (badem, ARALIĞI ceviz, fındık)
- ✅ Hindistan cevizi yağı (KATII!)

#### (bulletproof Kahvaltı
coffee)

- ### Pişirme **Kalori**: Detayları:
- ✅ 350-450 Her kcal yemekte pişirme yöntemi belirtilmiş
- (100 ✅ kcal Pişirme fark)
- süreleri verilmiş
- ✅ **Protein**: 25-35g
- Sıcaklık **Karbonhidrat**: bilgisi 35-50g
- **Yağ**: var (fırın için)
- ✅ 10-18g

#### Net talimatlar Öğle (15-20 Yemeği
dk - **Kalori**: 450-550 ızgara, 180°C fırın, vb.)

### Kalite İçin:
- ✅ Her yemek benzersiz
- ✅ Detaylı malzeme ve porsiyon bilgisi
- ✅ Pişirme yöntemi ve süresi belirtilmiş
- ✅ Kalori/makro değerleri gerçekçi

---

## 🎯 BAŞARILI TAMAMLAMA KRİTERLERİ

Talimat başarıyla tamamlanmışsa:

- [ ] 3000 yemek oluşturuldu ✅
- [ ] Her yemek dar kalori aralığında ✅
- [ ] Hiçbir yabancı besin yok ✅
- [ ] Hiçbir pahalı balık yok (levrek, çipura, somon) ✅
- [ ] Hiçbir un mamulü yok (poğaça, börek, vb.) ✅
- [ ] Ara öğün trend besinleri eklendi (kahve, protein bar, fıstık ezmesi, vb.) ✅
- [ ] Her yemekte pişirme yöntemi ve süresi var ✅
- [ ] Her dosyada öğün tipi dengeli dağıtıldı ✅
- [ ] Protein değerleri yeterli ✅
- [ ] Kombinasyonlar çeşitli ve benzersiz ✅
- [ ] JSON formatı doğru ✅
- [ ] ZIP dosyası hazır ✅

---

## 🔥 SON SÖZ

Bu talimat **genetik algoritmanın mükemmel çalışması** için optimize edilmiştir. Dar kalori aralıkları, algoritmanın kullanıcı profiline göre doğru kombinasyonlar yapmasını sağlar ve **tolerans ihlallerini önler**.

**Sadece Türk mutfağı** kuralı, kullanıcıların kolay bulabileceği, alışık oldukları yemekleri garanti eder.

**Ekonomik balıklar** (hamsi, uskumru, palamut, ton balığı) herkesin kcal (100 kcal fark)
- **Protein**: 40-55g
- bütçesine **Karbonhidrat**: 40-55g
- uygun.

**Ara öğün **Yağ**: 12-20g

#### trendleri** (kahve, Akşam Yemeği
- protein **Kalori**: 400-500 bar, kcal (100 kcal fıstık fark)
ezmesi, - **Protein**: hindistan cevizi 35-50g
- **Karbonhidrat**: 30-45g
- **Yağ**: 10-18g

#### Ara Öğün 1 (Sabah Ara Öğün)
- **Kalori**: 150-250 kcal yağı) modern (100 fitness kcal fark)
- **Protein**: 15-25g
- lifestyle'a **Karbonhidrat**: uygun.

15-25g
- **Detaylı **Yağ**: pişirme 5-10g

talimatları** #### Ara Öğün 2 (Öğleden Sonra/Akşam)
- yemeklerin **Kalori**: 150-250 kcal doğru (100 kcal hazırlanmasını fark)
- **Protein**: 15-25g
- garanti **Karbonhidrat**: eder.

10-20g
- **3000 yemek** **Yağ**: 5-10g

### ⚠️ çeşitliliği, günlük planlarda tekrar riskini minimize eder ve NEDEN DAR ARALIK ÖNEMLİ?

**Örnek Senaryo:**
- Kullanıcı kullanıcı profili: 2000 deneyimini maksimize eder.

kcal/gün, 150g protein, 180g carb, 60g fat
- Genetik algoritma: Her öğün için hedef hesaplar
- Eğer **BAŞARILI yemekler 300-700 kcal arasındaysa → Algoritma hatalı kombinasyon yapar → Tolerans aşılır!
- BİR Eğer yemekler 450-550 kcal arasındaysa → Algoritma doğru kombinasyon yapar → Tolerans içinde kalır!

---

## 🇹🇷 SADECE TÜRK MUTFAĞI - KATII KURALLAR

VERİ ### TABANI ✅ İZİN VERİLEN BESİNLER

#### Karbonhidrat = BAŞARILI BİR Kaynakları
- Bulgur pilavı, pirinç pilavı, UYGULAMA!** erişte, makarna
- Ekmek (tam buğday, çavdar, kepekli)
- 🚀
Patates (haşlama,
