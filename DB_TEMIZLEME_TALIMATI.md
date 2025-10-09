# 🔧 DB TEMİZLEME TALİMATI

## Android Uygulamadan DB Temizleme:

### Yöntem 1: Android Ayarlar (EN KOLAY!)
```
1. Telefonda Ayarlar'ı aç
2. Uygulamalar > ZindeAI
3. Depolama > Veriyi Temizle
4. Uygulamayı tekrar aç
```

### Yöntem 2: Maintenance Page (Kod içinden)
```
1. flutter run (uygulamayı çalıştır)
2. Profil > Maintenance (veya ayarlar menüsü)
3. "🔄 DB Temizle ve Yeniden Yükle" butonuna bas
```

**NOT:** Yöntem 1 daha basit, direk kullan!

---

## 🐛 MEVCUT SORUNLAR

### 1. ÖĞÜN BAZLI MAKRO SİSTEMİ ÇALIŞMIYOR!

Loglardan analiz:
```
Hedefler (3093 kcal için):
- Kahvaltı: 773 kcal (%25)
- Ara Öğün 1: 309 kcal (%10)
- Öğle: 928 kcal (%30)
- Ara Öğün 2: 309 kcal (%10)
- Akşam: 773 kcal (%25)

Gerçek:
- Kahvaltı: 370 kcal ❌ (403 kcal eksik!)
- Ara Öğün 1: 219 kcal ❌
- Öğle: 635 kcal ❌ (293 kcal eksik!)
- Ara Öğün 2: 288 kcal ✅
- Akşam: 539 kcal ❌ (234 kcal eksik!)
```

**KÖK NEDEN:** Hedefli yemek seçim algoritması çalışmıyor!

### 2. OLASI SORUNLAR:
- DB'de yeterli yüksek kalorili yemek yok mu?
- Çeşitlilik filtresi çok agresif mi?
- Hedef skorlama sistemi yanlış mı çalışıyor?

---

## ✅ YAPMAM GEREKENLER:

1. DB'yi Android Ayarlar > Depolama > Veriyi Temizle ile temizle
2. Uygulamayı tekrar çalıştır
3. Logları bana gönder
4. Ben de öğün bazlı algoritmanın neden çalışmadığını debug edeceğim
