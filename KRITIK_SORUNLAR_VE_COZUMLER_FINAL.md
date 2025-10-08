# 🔥 KRİTİK SORUNLAR - ACIL DÜZELTME GEREKİYOR

## 📋 Kullanıcı Bildirimi (08.10.2025 02:26)

### 🚨 1. ANA YEMEK ÇEŞİTLİLİĞİ SORUNU (KRİTİK!)

**SORUN:**
- Öğlenlerde sürekli SOMON geliyor
- Akşamlarda sürekli HAŞ LANMIŞ NOHUT geliyor
- Sadece YAN yemekler değişiyor (pilav, garnitür, vs.)
- **ANA YEMEK değişmeli!**

**KÖK NEDEN:**
Çeşitlilik mekanizması muhtemelen sadece garnitürleri/yan yemekleri değiştiriyor, ana protein kaynağını değiştirmiyor.

**ÇÖZÜM:**
1. ✅ Migration servisine `sonmealler` JSON'ları eklendi (1050+ akşam yemeği)
2. ⏳ Çeşitlilik mekanizmasını kontrol et - ANA yemeği değiştirmeli
3. ⏳ Hive DB temizle + yeniden migration
4. ⏳ Test et - her gün FARKLI ana yemek gelmeli

---

### 🐛 2. 8 ADET BUG TESPİT EDİLDİ

#### 🔴 KRİTİK (3 adet)
1. **Alternatif Besin Bottom Sheet Entegrasyon Hatası**
2. **BLoC Context Kaybı Riski**
3. **Android Geri Tuşu Eksik** ← Zaten düzeltildi ✅

#### 🟡 ORTA (3 adet)
4. **Null Safety Riski**
5. **Memory Leak Riski**
6. **Gereksiz API Çağrısı** ← Zaten düzeltildi ✅

#### 🟢 DÜŞÜK (2 adet)
7. **Çeşitlilik Geçmişi Temizleme**
8. **Alternatif Bulunamadı Mesajı** ← Zaten düzeltildi ✅

---

## ✅ YAPILAN DÜZELTMELER (Şu Ana Kadar)

### 1. Migration Servisi Güncellendi ✅
```dart
// ÖNCESİ: 300 akşam yemeği
'zindeai_aksam_300.json',

// SONRASI: 1050+ akşam yemeği!
'zindeai_aksam_300.json',
'aksam_combo_450.json',              // YENİ!
'aksam_yemekbalık_150.json',         // YENİ!
'aksam_yemekleri_150_kofte_kiyma_kusbasi_haslama.json', // YENİ!
'aksam_yemegi_batch_01.json',
'aksam_yemegi_batch_02.json',
```

### 2. Category Mapping Düzeltildi ✅
- `ara_ogun_2` underscore format desteği eklendi
- Migration doğru çalışacak

### 3. Bitkisel Süt Alternatifleri Eklendi ✅
- 1 besin → 4 besin (yulaf, soya, hindistan cevizi)

### 4. Android Geri Tuşu Eklendi ✅
- `WillPopScope` ile çıkış onayı

### 5. Gereksiz API Çağrısı Kaldırıldı ✅
- Performans optimizasyonu

### 6. Alternatif Bulunamadı Mesajı Eklendi ✅
- Boş state handling

---

## ⏳ YAPILACAKLAR (ACİL!)

### 1. ÇEŞİTLİLİK MEKANİZMASINI DÜZELT
**Problem:** Sadece yan yemekler değişiyor, ana yemek değişmiyor.

**Kontrol Edilecek:**
- `ogun_planlayici.dart` → `_cesitliYemekSec` metodu
- `_sonSecilenYemekler` static variable
- Genetik algoritma fitness function

**Beklenen:** Her gün FARKLI ana yemek (tavuk, balık, nohut, kuru fasulye, köfte, vs.)

---

### 2. KALAN 5 BUG'I DÜZELT

#### Bug 1: Alternatif Besin Bottom Sheet Entegrasyon
- AlternatifBesinBottomSheet adapter oluştur
- BLoC context düzelt

#### Bug 2: BLoC Context Kaybı
- BlocProvider'ı YeniHomePage seviyesinde tut

#### Bug 4: Null Safety
- Null safety kontrolleri ekle

#### Bug 5: Memory Leak
- Memory leak'leri düzelt

#### Bug 7: Çeşitlilik Geçmişi
- Kullanılmayan fonksiyonları kaldır

---

## 🎯 ÖNCELİK SIRASI

1. **ÖNCE:** Hive DB temizle + Migration (ana yemek çeşitliliği için)
2. **SONRA:** 5 bug'ı düzelt
3. **SON:** Test et - her gün farklı ana yemek kontrolü

---

## 📝 KULLANICI TALİMATI

### ADIM 1: Hive DB'yi Temizle
```
c:\Users\MS\Desktop\zindeai 05.10.2025\hive_data klasörünü SİL
```

### ADIM 2: Flutter App Çalıştır
```bash
flutter run
```

### ADIM 3: Test Et
- 7 gün plan oluştur
- Her gün FARKLI ana yemek kontrol et:
  - Pazartesi: Tavuk
  - Salı: Balık
  - Çarşamba: Nohut
  - Perşembe: Köfte
  - Cuma: Kuru fasulye
  - Cumartesi: Hindi
  - Pazar: Somon
  
**AMAÇ:** HİÇBİR GÜN AYNI ANA YEMEK TEKRAR ETMEMELİ!

---

## 🔥 SONUÇ

**Durum:** ACİL MÜDAHALE GEREKİYOR
- ✅ Migration güncellendi (1050+ akşam yemeği)
- ⏳ Çeşitlilik mekanizması kontrol edilecek
- ⏳ 5 bug düzeltilecek
- ⏳ Test edilecek

**Beklenen Süre:** 15-20 dakika (bug düzeltme + test)

---

**Hazırlayan:** AI Assistant  
**Tarih:** 08.10.2025 02:28  
**Durum:** 🔴 ACİL - ÇEŞİTLİLİK MEKANİZMASI BOZUK
