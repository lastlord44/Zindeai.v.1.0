## Mobil Test Sonrası Sorunlar ve Çözümler

### Belirti
"Hala aynı yemekler çıkıyor" — yeni eklenen JSON dosyalarındaki yemekler öneri/planlarda görünmüyor.

### Kök Neden Adayları
1) Migration atlanıyor: Mevcut veri sayısı > 0 ise `migrationGerekliMi()` false dönüyor.
2) Dosya adları uyuşmazlığı: Türkçe karakterli adlar iki varyantla bulunabiliyor.
3) Migration listesi eksik: `_jsonDosyalari` listesinde olmayan dosyalar hiç okunmuyor.
4) Önbellek/var olan plan: Eski plan geri yükleniyor olabilir.
5) Filtre/kısıt mantığı: Kategoriler/etiketler yeni veriyi dışarıda bırakıyor olabilir.

### Doğrulama Adımları
- `HiveService.yemekSayisi()` ve `kategoriSayilari()` logla.
- `_jsonDosyalari` ile `assets/data/` birebir eşleşiyor mu kontrol et.
- `YemekMigration.tekDosyaMigration('aksam_combo_450.json')` ile duman testi yap.
- Günlük plan/öneri kutularını temizle ve yeniden oluşturmayı dene.

### Çözüm
- Migration'ı zorla tekrar çalıştır (gerekirse sil-yükle).
- Dosya adlarını ASCII'ye normalize et (`balık` -> `balik`).
- Migration listesine yeni dosyaları ekle ve logları INFO seviyesinde özetle.

# 🐛 SORUN ANALİZİ VE ÇÖZÜMLER

## Tarih: 7 Ekim 2025

---

## 🔍 SORUN 1: Alternatif Bulunamayınca Geri Tuşu Yok

### Mevcut Durum
- ❌ Kullanıcı malzeme alternatifi istediğinde, eğer alternatif bulunamazsa `HomeError` state'i emit ediliyor
- ❌ `home_page_yeni.dart`'daki BlocConsumer listener'ı sadece `AlternativeMealsLoaded` ve `AlternativeIngredientsLoaded` için bottom sheet açıyor
- ❌ Error durumunda bottom sheet açılmadığı için kullanıcı sıkışıp kalıyor - geri dönüş yolu yok!

### Kod Lokasyonu
**Dosya:** `lib/presentation/bloc/home/home_bloc.dart`
**Metod:** `_onGenerateIngredientAlternatives` (satır ~338)

```dart
if (alternatifler.isEmpty) {
  AppLogger.warning('⚠️ Alternatif besin bulunamadı: "${parsedMalzeme.besinAdi}"');
  emit(HomeError(  // ❌ SORUN: Bu state ile bottom sheet açılmıyor!
    message: 'Bu malzeme için alternatif bulunamadı: "${parsedMalzeme.besinAdi}"',
  ));
  return;
}
```

### Çözüm
**Yaklaşım 1 (ÖNERİLEN):** Alternatif bulunamasa bile bottom sheet aç, içinde "Alternatif bulunamadı" mesajı ve GERİ BUTONU göster

**Yaklaşım 2:** SnackBar ile kullanıcıyı bilgilendir ve önceki state'e dön

---

## 🐛 SORUN 2: Her Öğlen Aynı Yemek Çıkıyor

### Mevcut Durum
- ❌ Çeşitlilik mekanizması (`_cesitliYemekSec`) var AMA sadece tek bir günlük plan içinde çalışıyor
- ❌ Haftalık plan oluşturulurken (`haftalikPlanOlustur`), her gün için AYRI `gunlukPlanOlustur` çağırılıyor
- ❌ Her `gunlukPlanOlustur` çağrısı kendi genetik algoritmasını çalıştırıyor ve çeşitlilik geçmişini KULLANMIYOR
- ❌ Sonuç: Pazartesi öğle = Salı öğle = Çarşamba öğle (aynı yemek!)

### Kod Lokasyonu
**Dosya:** `lib/domain/usecases/ogun_planlayici.dart`
**Metod:** `haftalikPlanOlustur` (satır ~506)

```dart
for (int gun = 0; gun < 7; gun++) {
  // Her gün için ayrı plan oluştur
  final gunlukPlan = await gunlukPlanOlustur(...);  // ❌ Çeşitlilik geçmişi kullanılmıyor!
  haftalikPlanlar.add(guncelPlan);
}
```

### KÖK NEDEN
Genetik algoritma her gün için BAĞIMSIZ çalışıyor. `_sonSecilenYemekler` map'i günler arası paylaşılmıyor veya kullanılmıyor.

### Çözüm
1. ✅ `haftalikPlanOlustur` başında `cesitlilikGecmisiniTemizle()` çağır
2. ✅ Her gün için plan oluşturulurken, çeşitlilik mekanizması önceki günleri HATIRLASIN
3. ✅ Genetik algoritmadaki `_rastgelePlanOlustur` ve `_mutasyonUygula` zaten `_cesitliYemekSec` kullanıyor, bu doğru
4. ✅ Sorun: Popülasyon oluşturulurken aynı yemekler seçiliyor, sonra fitness'a göre sıralanıyor ama çeşitlilik skorları YOK

---

## 🐛 SORUN 3: Akşam Öğle ile Aynı Olmamalı (Cumartesi/Pazar Hariç)

### Mevcut Durum
- ✅ `_aksamYemegiSec` metodu MEVCUT ve mantık doğru
- ✅ Hafta içi: öğle != akşam kontrolü yapılıyor
- ✅ Hafta sonu istisnası: nohut/fasulye/barbunya için aynı olabilir
- ❓ TEST EDİLMELİ: Bu mantık her zaman çalışıyor mu?

### Kod Lokasyonu
**Dosya:** `lib/domain/usecases/ogun_planlayici.dart`
**Metod:** `_aksamYemegiSec` (satır ~171)

### Potansiyel Sorun
- Genetik algoritmada `_rastgelePlanOlustur` içinde `_aksamYemegiSec` kullanılıyor ✅
- Ama `_mutasyonUygula` içinde de kullanılıyor mu? ✅ Evet kullanılıyor (satır ~460)
- Ama `_caprazla` (crossover) işleminde EBEVEYNLERİN akşam yemekleri direkt kopyalanabilir!
  - Eğer ebeveynlerden birinin akşam yemeği = öğle yemeği ise, bu hata çocuğa geçer! ❌

### Çözüm
`_caprazla` metodundan sonra akşam-öğle kontrolü yapılmalı.

---

## ✅ ÇÖZÜM PLANI

### Fix 1: Alternatif Bulunamayınca Bottom Sheet Göster
- [ ] `alternatif_besin_bottom_sheet.dart`'ı güncelle: boş liste durumunda da GERİ BUTONU göster
- [ ] Bloc'ta `HomeError` yerine `AlternativeIngredientsLoaded` (boş liste ile) emit et

### Fix 2: Çeşitlilik Mekanizmasını Düzelt
- [ ] `haftalikPlanOlustur` başında çeşitlilik geçmişini temizle
- [ ] Günler arası çeşitlilik için mechanism ekle (her gün öğle farklı olsun)

### Fix 3: Akşam-Öğle Kontrolünü Güçlendir
- [ ] `_caprazla` sonrası validation ekle
- [ ] Test senaryoları çalıştır

---

## 📊 ÖNCELİK SIRASI

1. **YÜKSEK:** Fix 1 (Kullanıcı deneyimi kritik)
2. **YÜKSEK:** Fix 2 (Ana fonksiyonalite bozuk)
3. **ORTA:** Fix 3 (Mevcut kod çalışıyor, sadece edge case)

---

## 🚀 SONRAKI ADIMLAR

1. Çözümleri uygula
2. Test et
3. Kullanıcıya rapor sun
