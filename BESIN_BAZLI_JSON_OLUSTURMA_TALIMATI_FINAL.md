# 🎯 3000 YEMEK OLUŞTURMA TALİMATI - GENETİK ALGORİTMA UYUMLU

## 🚨 KRİTİK AMAÇ
Bu talimat, **genetik algoritmanın tolerans ihlallerini önlemek** için optimize edilmiştir. Her yemek **dar kalori/makro aralıklarında** olmalı ki algoritma dinamik kullanıcı profillerine göre doğru plan oluşturabilsin.

---

## 📊 HEDEF: 3000 YEMEK (30 DOSYA x 100 YEMEK)

### Her Dosya TAM 100 Yemek İçermeli!

#### Tavuk Bazlı (4 dosya x 100 = 400 yemek)
1. **tavuk_ogle_100.json** → 100 yemek (öğle yemekleri)
2. **tavuk_aksam_100.json** → 100 yemek (akşam yemekleri)
3. **tavuk_kahvalti_100.json** → 100 yemek (kahvaltı)
4. **tavuk_ara_ogun_100.json** → 100 yemek (ara öğünler)

#### Dana Eti Bazlı (3 dosya x 100 = 300 yemek)
5. **dana_ogle_100.json** → 100 yemek
6. **dana_aksam_100.json** → 100 yemek
7. **dana_kahvalti_ara_100.json** → 100 yemek

#### Köfte/Kıyma Bazlı (3 dosya x 100 = 300 yemek)
8. **kofte_ogle_100.json** → 100 yemek
9. **kofte_aksam_100.json** → 100 yemek
10. **kofte_ara_100.json** → 100 yemek

#### Balık Bazlı (3 dosya x 100 = 300 yemek) - SADECE EKONOMİK
11. **balik_ogle_100.json** → 100 yemek (hamsi, uskumru, palamut, ton)
12. **balik_aksam_100.json** → 100 yemek
13. **balik_kahvalti_ara_100.json** → 100 yemek

#### Hindi Bazlı (2 dosya x 100 = 200 yemek)
14. **hindi_ogle_100.json** → 100 yemek
15. **hindi_aksam_100.json** → 100 yemek

#### Yumurta Bazlı (4 dosya x 100 = 400 yemek)
16. **yumurta_kahvalti_100.json** → 100 yemek
17. **yumurta_ara_ogun_1_100.json** → 100 yemek
18. **yumurta_ara_ogun_2_100.json** → 100 yemek
19. **yumurta_ogle_aksam_100.json** → 100 yemek

#### Süzme Yoğurt Bazlı (3 dosya x 100 = 300 yemek)
20. **yogurt_kahvalti_100.json** → 100 yemek
21. **yogurt_ara_ogun_1_100.json** → 100 yemek
22. **yogurt_ara_ogun_2_100.json** → 100 yemek

#### Peynir Bazlı (2 dosya x 100 = 200 yemek)
23. **peynir_kahvalti_100.json** → 100 yemek
24. **peynir_ara_ogun_100.json** → 100 yemek

#### Baklagil Bazlı (3 dosya x 100 = 300 yemek)
25. **baklagil_ogle_100.json** → 100 yemek (mercimek, nohut, fasulye)
26. **baklagil_aksam_100.json** → 100 yemek
27. **baklagil_kahvalti_100.json** → 100 yemek

#### Trend Ara Öğünler (3 dosya x 100 = 300 yemek)
28. **trend_ara_ogun_kahve_100.json** → 100 yemek (kahve bazlı)
29. **trend_ara_ogun_proteinbar_100.json** → 100 yemek (protein bar, fıstık ezmesi)
30. **trend_ara_ogun_meyve_100.json** → 100 yemek (muz, elma, kuruyemiş)

**TOPLAM: 30 DOSYA x 100 YEMEK = 3000 YEMEK**

---

## ⚡ GENETİK ALGORİTMA UYUMLULUĞU

### 🎯 Tolerans İhlalini Önleme Stratejisi

**PROBLEM**: Genetik algoritma geniş kalori aralıklarında yemek bulunca toleransı aşıyor.

**ÇÖZÜM**: Her öğün tipi için **DAR KALORI ARALIĞI** ve **KATII MAKRO KONTROL**!

### 📏 ÖĞÜN TİPİNE GÖRE ARALIKLAR (AŞILMAMALI!)

#### Kahvaltı
- **Kalori**: 350-450 kcal (100 kcal fark)
- **Protein**: 25-35g (**AŞILMAMALI!**)
- **Karbonhidrat**: 35-50g (**AŞILMAMALI!**)
- **Yağ**: 10-18g (**AŞILMAMALI!**)

#### Öğle Yemeği
- **Kalori**: 450-550 kcal (100 kcal fark)
- **Protein**: 40-55g (**AŞILMAMALI!**)
- **Karbonhidrat**: 40-55g (**AŞILMAMALI!**)
- **Yağ**: 12-20g (**AŞILMAMALI!**)

#### Akşam Yemeği
- **Kalori**: 400-500 kcal (100 kcal fark)
- **Protein**: 35-50g (**AŞILMAMALI!**)
- **Karbonhidrat**: 30-45g (**AŞILMAMALI!**)
- **Yağ**: 10-18g (**AŞILMAMALI!**)

#### Ara Öğün 1 (Sabah)
- **Kalori**: 150-250 kcal (100 kcal fark)
- **Protein**: 15-25g (**AŞILMAMALI!**)
- **Karbonhidrat**: 15-25g (**AŞILMAMALI!**)
- **Yağ**: 5-10g (**AŞILMAMALI!**)

#### Ara Öğün 2 (Öğleden Sonra/Akşam)
- **Kalori**: 150-250 kcal (100 kcal fark)
- **Protein**: 15-25g (**AŞILMAMALI!**)
- **Karbonhidrat**: 10-20g (**AŞILMAMALI!**)
- **Yağ**: 5-10g (**AŞILMAMALI!**)

### ⚠️ NEDEN DAR ARALIK ÖNEMLİ?

**Örnek Senaryo:**
- Kullanıcı profili: 2000 kcal/gün, 150g protein, 180g carb, 60g fat
- Genetik algoritma: Her öğün için hedef hesaplar
- Eğer yemekler 300-700 kcal arasındaysa → Algoritma hatalı kombinasyon yapar → Tolerans aşılır!
- Eğer yemekler 450-550 kcal arasındaysa → Algoritma doğru kombinasyon yapar → Tolerans içinde kalır!

---

## 🚫 ÇİFT KARBONHİDRAT YASAĞI (KRİTİK!)

**ÇOK ÖNEMLİ**: Her yemekte **SADECE 1 ADET** karbonhidrat kaynağı olabilir!

### ❌ YASAK KOMBİNASYONLAR (Saçma Sapan Yemekler!)

**Asla yapma:**
- ❌ Bulgur + Patates (iki karbonhidrat!)
- ❌ Pirinç + Makarna (iki karbonhidrat!)
- ❌ Patates + Ekmek (iki karbonhidrat!)
- ❌ Bulgur + Mercimek (iki karbonhidrat!)
- ❌ Makarna + Ekmek (iki karbonhidrat!)
- ❌ Pirinç + Patates (iki karbonhidrat!)
- ❌ Mercimek + Bulgur (iki karbonhidrat!)
- ❌ Nohut + Pirinç (iki karbonhidrat!)

### ✅ DOĞRU KULLANIM

**Tek karbonhidrat kaynağı:**
- ✅ Tavuk + Bulgur + Salata (tek karbonhidrat: bulgur)
- ✅ Balık + Pirinç + Brokoli (tek karbonhidrat: pirinç)
- ✅ Et + Patates + Havuç (tek karbonhidrat: patates)
- ✅ Yumurta + Ekmek + Domates (tek karbonhidrat: ekmek)
- ✅ Köfte + Makarna + Salata (tek karbonhidrat: makarna)

**NOT**: Sebze ve yeşillikler karbonhidrat kaynağı SAYILMAZ. Sadece ana karbonhidrat (bulgur, pirinç, makarna, patates, ekmek, mercimek, nohut, fasulye) için geçerli.

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
- Tavuk (göğüs, but), hindi
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
- **Hindistan cevizi yağı** (güncel trend)
- Ceviz, badem, fındık, fıstık
- Zeytin

#### 🔥 ARA ÖĞÜN TREND BESİNLERİ

1. **Kahve** (şekersiz)
   - Türk kahvesi, filtre kahve, espresso
   - Bulletproof coffee (hindistan cevizi yağı ile)

2. **Meyveler**
   - Muz, elma, portakal, armut

3. **Fıstık Ezmesi**
   - Şekersiz, doğal fıstık ezmesi
   - Badem ezmesi

4. **Protein Bar**
   - Şekersiz, doğal içerikli
   - Yüksek protein (15-20g)

5. **Kuruyemiş**
   - Badem, ceviz, fındık

### ❌ YASAK BESİNLER

1. **Yabancı Mutfak**
   - Quinoa, chia seed, acai berry
   - Hummus, tahini
   - Cottage cheese, ricotta
   - Avokado
   - Protein tozu (whey, kazein)
   - Sushi, poke bowl

2. **Pahalı Balıklar (YASAK!)**
   - ❌ Levrek
   - ❌ Çipura
   - ❌ Somon
   - **SADECE EKONOMİK**: Hamsi, uskumru, palamut, ton

3. **Fast Food & Sağlıksız**
   - Pizza, hamburger, tost
   - Döner, kokoreç
   - Poğaça, börek, pişi, simit

---

## 📝 JSON YAPI FORMATI

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
    "cooking_time": "15-20 dk tavuk, 15 dk bulgur",
    "ingredients": [
      "150g tavuk göğüs (ızgara, 15-20 dk)",
      "100g bulgur pilavı (haşlama, 15 dk)",
      "200g karışık yeşillik",
      "1 yemek kaşığı zeytinyağı",
      "Domates, salatalık",
      "Tuz, karabiber, limon"
    ]
  }
]
```

---

## 🔥 KALİTE KONTROL KURALLARI (13 MADDE)

### Her Yemek İçin MUTLAKA Kontrol Et:

1. ✅ **Kalori aralığı doğru mu?** (Öğüne göre ±100 kcal - **AŞILMAMALI!**)
2. ✅ **Protein aralığı doğru mu?** (**AŞILMAMALI!**)
3. ✅ **Karbonhidrat aralığı doğru mu?** (**AŞILMAMALI!**)
4. ✅ **Yağ aralığı doğru mu?** (**AŞILMAMALI!**)
5. ✅ **Tek karbonhidrat kaynağı mı?** (Çift karbonhidrat YASAK!)
6. ✅ **Yabancı besin var mı?** (Quinoa, chia, whey → YASAK!)
7. ✅ **Pahalı balık var mı?** (Levrek, çipura, somon → YASAK!)
8. ✅ **Un mamulü var mı?** (Poğaça, börek → YASAK!)
9. ✅ **Porsiyon bilgisi net mi?** (150g tavuk, 100g bulgur)
10. ✅ **Pişirme yöntemi var mı?** (Izgara, fırın, haşlama)
11. ✅ **Pişirme süresi var mı?** (15-20 dk gibi)
12. ✅ **Malzeme listesi detaylı mı?**
13. ✅ **Aynı kombinasyon tekrar etmiş mi?** (Her yemek farklı!)

### 🎯 MAKRO ARALIK KONTROLÜ TABLOSU

| Öğün Tipi | Kalori | Protein | Karbonhidrat | Yağ |
|-----------|--------|---------|--------------|-----|
| Kahvaltı | 350-450 | 25-35g | 35-50g | 10-18g |
| Öğle | 450-550 | 40-55g | 40-55g | 12-20g |
| Akşam | 400-500 | 35-50g | 30-45g | 10-18g |
| Ara Öğün 1 | 150-250 | 15-25g | 15-25g | 5-10g |
| Ara Öğün 2 | 150-250 | 15-25g | 10-20g | 5-10g |

**UYARI**: Bu aralıkların dışına çıkan yemek **KABUL EDİLMEZ**!

---

## 📦 ÇIKTI FORMATI (ÇOK ÖNEMLİ!)

### TEK ZIP DOSYASI

Tüm dosyalar oluşturulduktan sonra **TEK BİR ZIP** dosyası olarak sun!

```
📦 3000_YEMEK_VERITABANI.zip
├── tavuk_ogle_100.json (100 yemek)
├── tavuk_aksam_100.json (100 yemek)
├── tavuk_kahvalti_100.json (100 yemek)
├── tavuk_ara_ogun_100.json (100 yemek)
├── dana_ogle_100.json (100 yemek)
├── dana_aksam_100.json (100 yemek)
├── dana_kahvalti_ara_100.json (100 yemek)
├── kofte_ogle_100.json (100 yemek)
├── kofte_aksam_100.json (100 yemek)
├── kofte_ara_100.json (100 yemek)
├── balik_ogle_100.json (100 yemek)
├── balik_aksam_100.json (100 yemek)
├── balik_kahvalti_ara_100.json (100 yemek)
├── hindi_ogle_100.json (100 yemek)
├── hindi_aksam_100.json (100 yemek)
├── yumurta_kahvalti_100.json (100 yemek)
├── yumurta_ara_ogun_1_100.json (100 yemek)
├── yumurta_ara_ogun_2_100.json (100 yemek)
├── yumurta_ogle_aksam_100.json (100 yemek)
├── yogurt_kahvalti_100.json (100 yemek)
├── yogurt_ara_ogun_1_100.json (100 yemek)
├── yogurt_ara_ogun_2_100.json (100 yemek)
├── peynir_kahvalti_100.json (100 yemek)
├── peynir_ara_ogun_100.json (100 yemek)
├── baklagil_ogle_100.json (100 yemek)
├── baklagil_aksam_100.json (100 yemek)
├── baklagil_kahvalti_100.json (100 yemek)
├── trend_ara_ogun_kahve_100.json (100 yemek)
├── trend_ara_ogun_proteinbar_100.json (100 yemek)
└── trend_ara_ogun_meyve_100.json (100 yemek)

TOPLAM: 30 DOSYA x 100 YEMEK = 3000 YEMEK
```

**SON ADIM**: Tüm dosyaları **TEK BİR ZIP** olarak paketle ve sun!

---

## 💡 ÖNEMLİ HATIRLATMALAR

### Genetik Algoritma İçin:
- ✅ Dar kalori aralıkları → Tolerans ihlali yok
- ✅ Protein/Carb/Fat aralıkları **KESİN** uyulmalı
- ✅ Çift karbonhidrat yasağı → Saçma kombinasyonlar yok
- ✅ Her dosya tam 100 yemek → Kolay yönetim

### Türk Mutfağı İçin:
- ✅ Ekonomik balıklar (hamsi, uskumru, palamut, ton)
- ❌ Pahalı balıklar YASAK (levrek, çipura, somon)
- ✅ Yerel, kolay bulunur malzemeler
- ❌ Yabancı, pahalı besinler YOK

### Ara Öğün Trendleri:
- ✅ Kahve, protein bar, fıstık ezmesi
- ✅ Muz, elma, kuruyemiş
- ✅ Hindistan cevizi yağı
- ✅ Modern fitness lifestyle

### Dosya Formatı:
- ✅ Her dosya TAM 100 yemek
- ✅ 30 dosya toplam
- ✅ TEK ZIP dosyası
- ✅ Kolay parse edilebilir JSON

---

## 🎯 BAŞARILI TAMAMLAMA KRİTERLERİ

- [ ] 30 dosya oluşturuldu ✅
- [ ] Her dosya TAM 100 yemek ✅
- [ ] Toplam 3000 yemek ✅
- [ ] Her yemek dar kalori/makro aralığında ✅
- [ ] Protein/Carb/Fat aralıkları AŞILMAMIŞ ✅
- [ ] Hiçbir çift karbonhidrat yok ✅
- [ ] Hiçbir yabancı besin yok ✅
- [ ] Hiçbir pahalı balık yok ✅
- [ ] Ara öğün trend besinleri eklendi ✅
- [ ] Her yemekte pişirme bilgisi var ✅
- [ ] JSON formatı doğru ✅
- [ ] TEK ZIP dosyası hazır ✅

---

## 🔥 SON SÖZ

Bu talimat **genetik algoritmanın mükemmel çalışması** ve **tolerans ihlallerinin tamamen önlenmesi** için optimize edilmiştir.

**Kritik Özellikler:**
1. **Dar Kalori/Makro Aralıkları**: Tolerans aşılmaz
2. **Çift Karbonhidrat Yasağı**: Saçma kombinasyonlar önlenir
3. **Protein/Carb/Fat Kontrol**: Kesin aralıklara uyum
4. **Her Dosya 100 Yemek**: Kolay yönetim ve parse
5. **Tek ZIP**: Pratik kullanım

**BAŞARILI BİR VERİ = BAŞARILI BİR UYGULAMA!** 🚀
