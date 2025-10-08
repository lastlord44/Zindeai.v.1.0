# 🔥 VERİTABANI TEMİZLEME VE YENİDEN YÜKLEME KILAVUZU

## ❌ MEVCUT SORUN

Hive DB'de **20,750 yemek** var (Normal: ~2,400 olmalı)
- Migration birden fazla kez çalışmış
- Duplicate veriler oluşmuş
- Kategori karışıklıkları olabilir

## ✅ ÇÖZÜM ADIMLARI

### 1️⃣ UYGUL AMAYI KAPAT

Uygulamayı tamamen kapatın (Android'de arka planda da çalışmıyorsa emin olun)

### 2️⃣ HIVE KLASÖRÜNÜ SİL (Android)

Android cihazda uygulamanın veri klasörünü temizleyin:

**YOL 1: Ayarlardan**
```
Ayarlar → Uygulamalar → ZindeAI → Depolama → Verileri Temizle
```

**YOL 2: Manuel (Root gerekli)**
```
/data/data/com.example.zinde_ai/files/hive_data/
```

### 3️⃣ UYGULAMAYI YENİDEN BAŞLAT

```bash
flutter run -d 2304FPN6DG
```

### 4️⃣ LOGLARI İZLE

Otomatik migration çalışacak. Logları kontrol edin:

```
✅ DOĞRU SAYILAR:
- Kahvaltı: ~300 yemek
- Öğle: ~380 yemek  
- Akşam: ~1050 yemek
- Ara Öğün 1: ~170 yemek
- Ara Öğün 2: ~50 yemek
- TOPLAM: ~2,400 yemek

❌ YANLIŞ: 20,750 yemek (eski duplicate)
```

### 5️⃣ SEÇİLEN BESİNLERİ KONTROL ET

Logda şunu göreceksiniz:

```
🍽️ === SEÇİLEN BESİNLER ===
  [kahvalti] Yumurtalı Kahvaltı (350 kcal, P:25g)
  [araOgun1] Badem (160 kcal, P:6g)
  [ogle] Tavuk Göğsü (420 kcal, P:45g)
  [araOgun2] Süzme Yoğurt (120 kcal, P:12g)
  [aksam] Izgara Somon (480 kcal, P:52g)
================================
```

**KONTROL ET:**
- ❌ Kahvaltıda "Whey Protein", "Pirinç Patlağı" varsa → HATA!
- ✅ Kahvaltıda "Yumurta", "Peynir", "Ekmek" varsa → DOĞRU!
- ❌ Ara öğün 2'de tek besin varsa → SORUN!
- ✅ Her kategoride uygun besinler varsa → BAŞARILI!

### 6️⃣ MAKRO KONTROLÜ

```
Hedef: 2022 kcal, 188g protein
Gerçek: [Logda görülecek]
```

Fark %10'dan fazla ise → SORUN VAR

## 🐛 SORUN YAŞARSAN

### Duplicate sorunları devam ediyorsa:

1. `HiveService.tumYemekleriSil()` çağır
2. Uygulamayı kapat-aç
3. Migration otomatik çalışacak

### Kahvaltıda hala ara öğün besinleri görüyorsan:

JSON dosyalarının `category` field'ına bak. Logda göreceksin:
```
[kahvalti] Whey Protein ← BU YANLIŞ!
```

Bu durumda kategori mapping'de sorun var demektir.

## 📊 BAŞARI KRİTERLERİ

✅ Toplam yemek: ~2,400
✅ Her kategoride yeterli çeşitlilik
✅ Kahvaltıda yumurtalı yemekler var
✅ Ara öğün 2'de en az 2-3 farklı besin
✅ Makro hedefler %10 içinde tutuluyor
✅ Öğle-akşam farklı yemekler

## 🔥 SON NOTLAR

- Migration artık **duplicate önleme** yapıyor
- Aynı `meal_id` varsa atlanıyor
- Seçilen besinler artık **logda görünüyor**
- Her besin sadece 1 kez loglanıyor (spam yok)

Başarılar! 🚀
