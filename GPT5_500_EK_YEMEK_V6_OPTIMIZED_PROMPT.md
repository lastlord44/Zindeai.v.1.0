# 🚀 GPT-5 PRO: 500 EK TÜRK YEMEĞİ - V6.0 SİSTEM OPTİMİZASYONU

## 📋 GÖREV TANIMI
**V6.0 Deterministik Beslenme Sistemi** için 500 ek Türk yemek çeşidi oluştur. Mevcut 6000+ yemek DB'sine eklenecek, özellikle eksik kategorilerde çeşitliliği artıracak.

## 🎯 HEDEF KATEGORİLER (500 YEMEK DAĞILIMI)

### 🥤 İÇECEK & SMOOTHİE (100 adet)
- **Protein Smoothie'leri** (30): Whey, kakao, muz, fıstık ezmesi kombinasyonları
- **Sebze-Meyve Smoothie** (25): Ispanak-elma, havuç-portakal vb.
- **Geleneksel İçecekler** (20): Ayran çeşitleri, bitki çayları, su içeriği yüksek
- **Fit İçecekler** (15): Yeşil çay kombinasyonları, detox suları
- **Enerji İçecekleri** (10): Doğal kahve bazlı, guarana vs alternatifler

### 🥗 SALATA & SEBZE YEMEKLERİ (120 adet)
- **Protein Salatalar** (40): Tavuk, ton balığı, yumurta bazlı, doyurucu
- **Türk Usulü Mezeler** (30): Çoban salata, piyaz, atom vb. çeşitleri  
- **Fit Salata Bowlları** (25): Quinoa, bulgur bazlı bowl'lar
- **Sebze Sote/Kavurma** (25): Patlıcan, kabak, karnabahar yemekleri

### 🍪 ATIŞTIRILMALIK & FIT TATLI (80 adet)
- **Protein Topları** (20): Hurma-badem, chia seed kombinasyonları
- **Fit Kurabiyeler** (15): Yulaf bazlı, şekersiz alternatifler
- **Türk Fit Tatlıları** (20): Muhallebi, sütlaç protein versiyonları
- **Kuru Meyve Karışımları** (15): Trail mix çeşitleri, portion kontrollü
- **Ev Yapımı Bar'lar** (10): Granola bar, protein bar alternatifleri

### 🥘 TÜRK MUTFAĞI GELİŞTİRME (120 adet)
- **Zeytinyağlı Yemekler** (35): Dolma çeşitleri, sebze yemekleri
- **Et Yemekleri Çeşitleri** (30): Kebab alternatifleri, güveç çeşitleri
- **Balık & Deniz Ürünleri** (25): Hamsi, çupra, levrek preparasyon çeşitleri
- **Çorba Çeşitleri** (20): Mercimek, yayla, tarhana varyasyonları
- **Pilav & Makarna** (10): Özel pilav çeşitleri, fit makarna sosları

### 🥙 KAHVALTI & BRENCh GELİŞTİRME (50 adet)
- **Türk Kahvaltısı Varyasyonları** (20): Menemen çeşitleri, börek alternatifleri
- **Fit Kahvaltılar** (15): Protein pancake, overnight oats Türk lezzetleri
- **Brunch Öğünleri** (15): Avokado toast Türk versiyonu, fit muffin'ler

### 🍜 ÖZEL & FUSION YEMEKLERİ (30 adet)
- **Türk-Fit Fusion** (15): Protein köfte, fit lahmacun alternatifleri
- **Özel Occasions** (15): Bayram, özel gün yemekleri fit versiyonları

## 📊 ZORUNLU JSON FORMAT

```json
{
  "yemekler": [
    {
      "id": "protein_smoothie_muzlu_001",
      "ad": "Muzlu Whey Protein Smoothie",
      "kategori": "smoothie",
      "ogun_tipi": ["ara_ogun", "kahvalti"],
      "malzemeler": [
        {
          "malzeme": "whey_protein_tozu",
          "miktar": 30,
          "birim": "g"
        },
        {
          "malzeme": "muz",
          "miktar": 150,
          "birim": "g"
        },
        {
          "malzeme": "sut_yagsiz",
          "miktar": 200,
          "birim": "ml"
        },
        {
          "malzeme": "badem_sutu",
          "miktar": 100,
          "birim": "ml"
        }
      ],
      "besin_degerleri": {
        "kalori": 285,
        "protein": 28.5,
        "karbonhidrat": 32.1,
        "yag": 4.2,
        "lif": 3.1,
        "doymus_yag": 1.8
      },
      "hazirlik_suresi": 5,
      "pisirme_suresi": 0,
      "porsiyon": 1,
      "zorluk": "kolay",
      "etiketler": ["protein", "fit", "hızlı", "vegetarian"],
      "tarif_ozeti": "Whey protein, taze muz ve süt ile hazırlanan besleyici smoothie. Antrenman sonrası ideal.",
      "besin_grubu": "protein_icecegi",
      "kulturel_ozellik": "modern_turkiye"
    }
  ]
}
```

## 🔥 ÖZEL KURALLLAR & STANDARDLAR

### ✅ ZORUNLU KURALLAR
1. **100g Pişmiş Standart**: Tüm besin değerleri 100g pişmiş/hazır halde
2. **Lif & Doymuş Yağ**: Her yemekte mutlaka belirt (0 bile olsa)
3. **Gerçekçi Makro Değerler**: USDA/TurKomp verilerine uygun
4. **Türk Mutfağı Odaklı**: %80 geleneksel Türk lezzetleri, %20 modern adaptasyon
5. **Portion Kontrol**: Tek kişilik, makul porsiyon boyutları

### 📊 MAKRO DAĞILIM HEDEFLERİ (500 yemek geneli)
- **Yüksek Protein** (150 adet): >20g protein/100g
- **Dengeli Makro** (200 adet): 15-20g protein, dengeli karb/yağ
- **Düşük Kalori** (100 adet): <150 kcal/100g (sebze ağırlıklı)
- **Yüksek Kalori** (50 adet): >300 kcal/100g (bulk support)

### 🎯 V6.0 SİSTEM UYUMLULUĞU
- **MacroAdjuster Uyumlu**: Kolay ölçeklenebilir porsiyonlar
- **Türk Damak Zevki**: Baharatlar, geleneksel kombinasyonlar
- **Çeşitlilik Odaklı**: Aynı kategoride farklı makro profilleri
- **Pratik Hazırlanabilir**: Evde kolayca yapılabilir

### 🥗 ÖZEL ODAK NOKTALARI

#### Smoothie & İçecek Kategorisi
- Su içeriği yüksek (>80ml/100g eşdeğer)
- Doğal tatlandırıcılar (hurma, muz, stevia)
- Protein tozu entegrasyonu
- Türk lezzetleri (tarçın, vanilya, kakao)

#### Salata & Sebze Kategorisi  
- Yüksek lif içeriği (>5g/100g)
- Zeytinyağı entegrasyonu
- Mevsimsel sebzeler
- Doygunluk hissi veren protein eklentileri

#### Atıştırmalık Kategorisi
- Portion kontrol (tek lokmalık)
- Doğal şekerler
- Sağlıklı yağlar (fındık, ceviz, badem)
- Kolay taşınabilir

## 🚀 ÇIKTI FORMATІ

**5 batch halinde JSON üret:**
- **Batch 1**: İçecek & Smoothie (100 adet)
- **Batch 2**: Salata & Sebze (120 adet)  
- **Batch 3**: Atıştırmalık & Fit Tatlı (80 adet)
- **Batch 4**: Türk Mutfağı Geliştirme (120 adet)
- **Batch 5**: Kahvaltı & Özel Yemekler (80 adet)

Her batch için ayrı JSON file üret: `batch_1_icecek_100.json`, `batch_2_salata_120.json` vs.

## 💪 ÖZEL NOTLAR

- V6.0 DETERMİNİSTİK SİSTEM için optimize edildi
- MacroAdjuster algoritması ile uyumlu
- Gerçek Türk mutfağı deneyimi
- Fitness hedeflerine uygun çeşitlilik

**HEDEF**: V6.0 sisteminin %85+ başarı oranını %90+'a çıkararak, mükemmel kullanıcı deneyimi sağla! 🚀

---
*Bu prompt V6.0 Deterministik Beslenme Sistemi için özel olarak tasarlanmıştır. GPT-5 Pro tarafından işlenmelidir.*