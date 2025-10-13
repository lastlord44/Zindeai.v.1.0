# 500 YENİ YEMEK YÜKLEME TALİMATI

## 📍 BATCH DOSYALARI NEREDE?

Tüm batch dosyaları **lib/** klasörüne taşındı:

```
lib/mega_yemek_batch_20_kahvalti_saglikli.dart  ✅
lib/mega_yemek_batch_21_ogle_saglikli.dart      ✅  
lib/mega_yemek_batch_22_aksam_saglikli.dart     ✅
lib/mega_yemek_batch_23_ara_ogun_1.dart         ✅
lib/mega_yemek_batch_24_29_ara_ogun_2.dart      ✅
```

## ⚠️ SORUN NEDİR?

- Proje klasöründeki `hive_db/yemekler.hive` dosyasında 500 yemek var ✅
- AMA uygulama TELEFONUN app data klasöründeki ESKİ DB'yi kullanıyor ❌
- Eski DB'de hala "Katmer", "Protein Bar" gibi saçma yemekler var

## ✅ ÇÖZÜM (3 ADIM)

### ADIM 1: Uygulamayı Telefondan Kaldır
```
Ayarlar > Uygulamalar > ZindeAI > Kaldır
```
Bu eski DB'yi de siler.

### ADIM 2: Flutter Clean
```bash
flutter clean
```

### ADIM 3: Uygulamayı Yeniden Yükle
```bash
flutter run
```

Uygulama başlarken HiveService otomatik olarak 500 yemeği yükleyecek.

## 📊 BEKLENEN SONUÇ

Uygulama başladıktan sonra loglarda şunları göreceksin:

```
🚀 500 YENİ YEMEK MİGRATION BAŞLIYOR...
✅ Batch 20 (Kahvaltı): 50 yemek
✅ Batch 21 (Öğle): 50 yemek
✅ Batch 22 (Akşam): 50 yemek
✅ Batch 23 (Ara Öğün 1): 50 yemek
✅ Batch 24-29 (Ara Öğün 2): 300 yemek
🎉 500 YENİ YEMEK MİGRATION TAMAMLANDI!
```

## 🍽️ YENİ YEMEK ÖRNEKLERİ

Artık şunları göreceksin:
- ✅ Haşlanmış Yumurta + Tam Buğday Ekmeği (2 yumurta, 2 dilim ekmek)
- ✅ Izgara Tavuk Göğsü + Bulgur Pilavı (150g tavuk, 80g bulgur)
- ✅ Balık Izgara + Bulgur Pilavı (150g levrek, 80g bulgur)

❌ Artık şunlar YOK:
- ❌ Katmer + Kaymak + Fıstık
- ❌ Protein Bar + Apple
- ❌ Tavuk Wrap Mini

---

**Not:** Eğer hala sorun devam ederse `lib/data/local/hive_service.dart` dosyasındaki migration kodunu kontrol etmem gerekir.
