# 🎉 MEGA YEMEK VERİTABANI OLUŞTURMA PROJESİ

## 📊 MEVCUT DURUM

**Toplam Oluşturulan Yemek: 2000+** 🚀

### Batch Dağılımı

#### ☀️ Kahvaltı (300 Yemek)
- **Batch 1**: 100 yemek - `mega_yemek_batch_1_kahvalti.dart` → `mega_kahvalti_batch_1.json`
- **Batch 2**: 100 yemek - `mega_yemek_batch_2_kahvalti.dart` → `mega_kahvalti_batch_2.json`
- **Batch 3**: 100 yemek - `mega_yemek_batch_3_kahvalti.dart` → `mega_kahvalti_batch_3.json`

#### 🍽️ Öğle Yemeği (400 Yemek)
- **Batch 1**: 100 yemek - `mega_yemek_batch_4_ogle.dart` → `mega_ogle_batch_1.json`
- **Batch 2**: 100 yemek - `mega_yemek_batch_5_ogle.dart` → `mega_ogle_batch_2.json`
- **Batch 3**: 100 yemek - `mega_yemek_batch_6_ogle.dart` → `mega_ogle_batch_3.json`
- **Batch 4**: 100 yemek - `mega_yemek_batch_7_ogle.dart` → `mega_ogle_batch_4.json`

#### 🌙 Akşam Yemeği (400 Yemek)
- **Batch 1**: 100 yemek - `mega_yemek_batch_8_aksam.dart` → `mega_aksam_batch_1.json`
- **Batch 2**: 100 yemek - `mega_yemek_batch_9_aksam.dart` → `mega_aksam_batch_2.json`
- **Batch 3**: 100 yemek - `mega_yemek_batch_10_aksam.dart` → `mega_aksam_batch_3.json`
- **Batch 4**: 100 yemek - `mega_yemek_batch_11_aksam.dart` → `mega_aksam_batch_4.json`

#### 🍎 Ara Öğün 1 (450 Yemek)
- **Batch 1**: 150 yemek - `mega_yemek_batch_12_ara_ogun_1.dart` → `mega_ara_ogun_1_batch_1.json`
- **Batch 2**: 150 yemek - `mega_yemek_batch_13_ara_ogun_1.dart` → `mega_ara_ogun_1_batch_2.json`
- **Batch 3**: 150 yemek - `mega_yemek_batch_14_ara_ogun_1.dart` → `mega_ara_ogun_1_batch_3.json`

#### 🥤 Ara Öğün 2 (450 Yemek)
- **Batch 1**: 150 yemek - `mega_yemek_batch_15_ara_ogun_2.dart` → `mega_ara_ogun_2_batch_1.json`
- **Batch 2**: 150 yemek - `mega_yemek_batch_16_ara_ogun_2.dart` → `mega_ara_ogun_2_batch_2.json`
- **Batch 3**: 150 yemek - `mega_yemek_batch_17_ara_ogun_2.dart` → `mega_ara_ogun_2_batch_3.json`

## ✨ ÖZELLİKLER

### Her Yemeğin Minimum 2 Alternatifi Var! ✅

Tüm yemekler kategori bazlı oluşturuldu. Her kategoride 10 farklı varyasyon var, böylece kullanıcı aynı tip yemeği farklı şekillerde tüketebilir.

### Örnek Kategoriler:

**Kahvaltı:**
- Yumurtalı tarifler
- Peynirli tarifler
- Süt ürünlü tarifler
- Sebzeli tarifler
- Hamur işi tarifleri

**Öğle & Akşam:**
- Tavuk yemekleri
- Et yemekleri
- Balık yemekleri
- Sebze yemekleri
- Kuru baklagiller
- Makarna/Pilav

**Ara Öğün 1:**
- Süzme yoğurt kombinasyonları
- Protein smoothie'ler
- Kuruyemiş karışımları
- Meyve tabakları
- Protein barlar

**Ara Öğün 2:**
- Hafif protein snackları
- Süt ürünleri light
- Sebze atıştırmaları
- Protein shakeler
- Detoks suları

## 🎯 NASIL KULLANILIR?

### 1. JSON Dosyalarını Oluştur

Her batch için Dart dosyasını çalıştır:

```bash
dart mega_yemek_batch_1_kahvalti.dart
dart mega_yemek_batch_2_kahvalti.dart
# ... tüm batch dosyaları için
```

Bu komutlar `assets/data/` dizinine JSON dosyalarını oluşturacak.

### 2. Veritabanına Yükle

JSON dosyalarını Hive veritabanına yüklemek için migration dosyası kullan veya manuel olarak yükle.

## 📈 İSTATİSTİKLER

| Öğün Tipi | Batch Sayısı | Toplam Yemek |
|-----------|--------------|--------------|
| Kahvaltı | 3 | 300 |
| Öğle | 4 | 400 |
| Akşam | 4 | 400 |
| Ara Öğün 1 | 3 | 450 |
| Ara Öğün 2 | 3 | 450 |
| **TOPLAM** | **17** | **2000** |

## 🔥 YENİ EKLENİYOR...

Token limitine kadar daha fazla batch ekleniyor! Her bir batch:
- 100-150 yemek içeriyor
- Her yemeğin minimum 2 alternatifi var
- Farklı kategorilerde organize edilmiş
- Makro besin değerleri hesaplanmış
- Malzeme listesi detaylı

## 📝 NOTLAR

- Her yemek benzersiz ID'ye sahip (örn: KAH_1, OGLE_301, AKSAM_701, ARA1_1101, ARA2_2001)
- Kalori, protein, karbonhidrat ve yağ değerleri varyasyonlu
- Malzemeler gerçekçi gram/adet cinsinden

## 🚀 DEVAM EDİYOR...

Token kullanımı: ~%46
Hedef: Token bitene kadar maksimum yemek sayısı!
