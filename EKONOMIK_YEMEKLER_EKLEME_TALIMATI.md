# 🍗 EKONOMİK ANA YEMEKLER EKLEME TALIMATI

**Tarih**: 9 Ekim 2025, 23:13
**Amaç**: DB'ye 200+ ekonomik ve alternatif ana yemek eklemek

## 📊 Mevcut Durum

- **DB'deki ana yemekler**: 160 (80 öğle + 80 akşam)
- **Hedef**: 360+ ana yemek (180 öğle + 180 akşam)
- **Eklenecek**: 200 ekonomik yemek (100 öğle + 100 akşam)

## 💰 EKONOMİK YEM

EK KAYNAKLARI

### ✅ Kullanılacak Malzemeler
- **Tavuk** (göğüs, but, kanat, kıyma)
- **Kıyma** (dana, kuzu)
- **Yumurta**
- **Hamsi, sardalya, uskumru** (ucuz balıklar)
- **Nohut, mercimek, fasulye** (bakliyat)
- **Bulgur, esmer pirinç** (tahıllar)
- **Sebzeler** (patlıcan, kabak, ıspanak, vb.)

### ❌ PAHALmış BALIKLARI KULLANMA
- Somon ❌
- Levrek ❌
- Çipura ❌
- Kalkan ❌
- Turbot ❌
- Dil balığı ❌

## 📁 Dosya Yapısı

JSON dosyası formatı:
```json
[
  {
    "id": "EKO_OGLE_001",
    "ad": "Tavuk Sote + Bulgur + Yoğurt",
    "kategori": "ogle",
    "kalori": 450,
    "protein": 36,
    "karbonhidrat": 48,
    "yag": 12,
    "porsiyon": "180g tavuk + bulgur + yoğurt"
  }
]
```

## ✅ Sonraki Adımlar

1. ✅ 200 ekonomik yemek JSON dosyası oluştur
2. ⏳ Migration scripti ile DB'ye yükle
3. ⏳ DB summary güncelle
4. ⏳ Test et (genetik algoritma + tolerans sistemi)

## 🎯 Beklenen Sonuç

- **360+ ana yemek** ile genetik algoritma daha fazla seçeneğe sahip olacak
- **±5% tolerans** içinde planlar oluşturabilecek
- **Ekonomik alternatifler** sayesinde herkes için uygun planlar
