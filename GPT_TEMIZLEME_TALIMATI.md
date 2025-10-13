# 🔥 JSON DOSYALARI TEMİZLEME TALİMATI (ChatGPT İçin)

## 📍 Hedef Klasör
`C:\Users\MS\Desktop\zindeai 05.10.2025\assets\data`

## 🎯 Görev
Bu klasördeki TÜM `.json` dosyalarını aşağıdaki kurallara göre temizle:

---

## ❌ SİLİNMESİ GEREKEN BESİNLER

### 1. UN ÜRÜNLERİ (Zararlı Karbonhidrat)
Aşağıdaki kelimeleri içeren **TÜM** yemekleri sil:
- poğaça, pogaca
- pişi, pisi  
- börek, borek
- sigara böreği, sigara boregi
- simit
- croissant, kruvasan
- hamburger, burger
- pizza
- sandviç, sandwich
- pide
- lahmacun
- gözleme, gozleme
- tost
- galeta
- kraker
- ekmek (SADECE yemek adında geçiyorsa, malzeme olarak değil)

### 2. YABANCI BESİNLER
- whey
- protein shake, protein smoothie
- protein powder, protein tozu
- cottage cheese, cottage
- smoothie bowl
- chia pudding
- acai bowl
- quinoa
- hummus wrap
- falafel wrap
- burrito
- taco
- sushi
- poke bowl
- ramen
- pad thai
- curry
- bagel
- gravlax
- rice cake
- bcaa, casein, kreatin, gainer, supplement

### 3. KIZARTMA VE FAST FOOD
- kızarmış, kizarmis, fried, crispy
- cips, chips
- patates kızartması, french fries
- nugget
- sosisli, hot dog
- döner, doner
- kokoreç, kokorec

---

## 🔍 TEMİZLEME YÖNTEMİ

Her JSON dosyasında:
1. Dosyayı aç
2. Her yemeğin `meal_name` alanına bak
3. Yukarıdaki YASAK KELİMELERDEN herhangi birini içeriyorsa **O YEMEĞİ SİL**
4. Temiz yemekleri yeni bir array'e topla
5. Dosyayı temiz yemeklerle OVERWRITE et

### 📝 Örnek Kod (Python)
```python
import json
import os

YASAK_KELIMELER = [
    'poğaça', 'pogaca', 'pişi', 'pisi', 'börek', 'borek',
    'sigara böreği', 'sigara boregi', 'simit', 'croissant',
    'hamburger', 'burger', 'pizza', 'sandviç', 'sandwich',
    'pide', 'lahmacun', 'gözleme', 'gozleme', 'tost',
    'whey', 'protein shake', 'protein smoothie', 'cottage cheese',
    'sushi', 'ramen', 'burrito', 'taco', 'bagel',
    'kızarmış', 'kizarmis', 'fried', 'döner', 'doner',
    # ... tüm liste
]

def temizle(json_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        yemekler = json.load(f)
    
    temiz = []
    for yemek in yemekler:
        meal_name = yemek.get('meal_name', '').lower()
        
        yasak_var = False
        for yasak in YASAK_KELIMELER:
            if yasak.lower() in meal_name:
                yasak_var = True
                break
        
        if not yasak_var:
            temiz.append(yemek)
    
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(temiz, f, ensure_ascii=False, indent=2)
    
    print(f"{json_path}: {len(yemekler)} -> {len(temiz)} (silinen: {len(yemekler)-len(temiz)})")
```

---

## 📊 TOLERANS İYİLEŞTİRMESİ

Ek olarak, kalori değerleri **çok uç** olan yemekleri de sil:

### Kalori Limitleri (Öğün Bazında)
- **Kahvaltı**: 200-600 kcal aralığında
- **Öğle**: 300-800 kcal aralığında  
- **Akşam**: 300-800 kcal aralığında
- **Ara Öğün 1**: 100-300 kcal aralığında
- **Ara Öğün 2**: 100-300 kcal aralığında

Bu sınırların DIŞINDA kalan yemekleri de sil. Böylece genetik algoritma daha kolay hedeflere ulaşır.

### Örnek Kontrol
```python
# Dosya adından öğün tipini anla
if 'kahvalti' in dosya_adi:
    min_kcal, max_kcal = 200, 600
elif 'ogle' in dosya_adi:
    min_kcal, max_kcal = 300, 800
elif 'aksam' in dosya_adi:
    min_kcal, max_kcal = 300, 800
elif 'ara_ogun' in dosya_adi:
    min_kcal, max_kcal = 100, 300

# Kalori kontrolü
kalori = yemek.get('calories', 0)
if kalori < min_kcal or kalori > max_kcal:
    # Bu yemeği silme listesine ekle
```

---

## ✅ ÇIKTI FORMATI

Her dosya için şunu rapor et:
```
mega_kahvalti_batch_1.json: 100 -> 87 (silinen: 13)
mega_ogle_batch_1.json: 100 -> 95 (silinen: 5)
...
TOPLAM: 2300 -> 2150 (silinen: 150)
```

---

## 🚀 SONUÇ

Tüm JSON dosyalarını temizledikten sonra:
1. Sadece **SAĞLIKLI TÜRK MUTFAĞI** yemekleri kalacak
2. Kalori değerleri **MAKUL** aralıkta olacak
3. Genetik algoritma **DAHA KOLAY** hedeflere yaklaşacak
4. Tolerans **%10'un altına** düşecek

**ÖNEMLİ**: TÜM değişiklikleri yaptıktan sonra dosyaları KAYDET!

