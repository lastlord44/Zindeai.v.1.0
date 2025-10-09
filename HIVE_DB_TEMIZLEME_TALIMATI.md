# 🗑️ HIVE DATABASE TEMİZLEME TALİMATI

**Tarih:** 10 Ekim 2025  
**Durum:** Ara Öğün 2 Sorunu - Veritabanı Temizleme Gerekli

---

## 🔍 DURUM ANALİZİ

### **Hive Database Konumu Bulunamadı** ❌
- `%APPDATA%\com.example.zindeai` - **YOK**
- `%LOCALAPPDATA%\com.example.zindeai` - **YOK**
- Proje klasöründe `.hive` dosyaları - **YOK**
- `.db` dosyaları - **YOK**

### **Mevcut JSON Dosyaları** ✅
```
assets/data/
├─ ara_ogun_1_batch_01.json
├─ ara_ogun_1_batch_02.json
├─ ara_ogun_2_batch_01.json
├─ ara_ogun_2_batch_02.json
└─ ara_ogun_toplu_120.json  ← 120 yeni ara öğün 2 yemeği!
```

---

## 🚀 ÇÖZÜM: UYGULAMA İÇİNDEN TEMİZLEME

### **ADIM 1: Uygulamayı Başlat** ✅
```bash
flutter run --debug
```
**Durum:** Uygulama başlatıldı (arka planda çalışıyor)

### **ADIM 2: Maintenance Page'i Aç**
1. Uygulamada **⚙️ Settings** butonuna bas
2. **Maintenance Page**'i aç
3. **"🔄 DB Temizle ve Yeniden Yükle"** butonuna bas

### **ADIM 3: Migration Kontrolü**
Uygulama başladığında otomatik olarak:
1. **Migration kontrolü** yapılacak
2. **Hive database** oluşturulacak
3. **JSON dosyaları** Hive'a yüklenecek
4. **Ara öğün 2** kategorisi düzgün oluşturulacak

---

## 📊 BEKLENİLEN SONUÇ

### **Migration Sonrası:**
```
Kategori Dağılımı:
├─ Kahvaltı: 300+ yemek
├─ Ara Öğün 1: 50+ yemek
├─ Ara Öğün 2: 120+ yemek  ← 🔥 BU ARTTI!
├─ Öğle Yemeği: 300+ yemek
├─ Akşam Yemeği: 450+ yemek
└─ Gece Atıştırması: 20+ yemek
```

### **Ara Öğün 2 Sorunu Çözülecek:**
- ✅ UI'da görünecek
- ✅ 120+ çeşitli yemek
- ✅ Süzme yoğurt spam'i bitecek

---

## 🔧 ALTERNATİF ÇÖZÜM (Manuel)

Eğer Maintenance Page çalışmazsa:

### **1. Uygulamayı Kapat**
```bash
# Flutter process'lerini kapat
taskkill /F /IM flutter.exe
taskkill /F /IM dart.exe
```

### **2. Hive Klasörlerini Manuel Sil**
```bash
# Windows'ta Hive verileri genellikle şurada:
rmdir /s /q "%APPDATA%\com.example.zindeai"
rmdir /s /q "%LOCALAPPDATA%\com.example.zindeai"
```

### **3. Uygulamayı Yeniden Başlat**
```bash
flutter run
```

---

## 🎯 SONUÇ

**Ana Sorun:** Hive database henüz oluşturulmamış veya yanlış kategoride veriler var.

**Çözüm:** Uygulama içinden Maintenance Page ile temizleme ve yeniden migration.

**Beklenen:** Ara öğün 2 sorunu tamamen çözülecek.

---

**Not:** Uygulama şu anda çalışıyor. Maintenance Page'i açıp DB temizleme işlemini yapabilirsin.
