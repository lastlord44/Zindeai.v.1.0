# 🔴 KRİTİK SORUN: KAHVALTIDA ARA ÖĞÜN ÇIKIYOR!

## 📋 SORUN TANIMI

Kullanıcı raporu: **Kahvaltıda ara öğün besinleri çıkıyor**

Örnek profil:
- Boy: 160cm
- Kilo: 55kg
- Yaş: 25
- Cinsiyet: Kadın
- Hedef: Kilo kaybı
- Aktivite: Orta aktif (haftada 3 gün antrenman)

## 🧮 BEKLENEN MAKRO HESAPLAMALARI

### 1. BMR (Mifflin-St Jeor Formülü - Kadın)
```
BMR = (10 × kilo) + (6.25 × boy) - (5 × yaş) - 161
BMR = (10 × 55) + (6.25 × 160) - (5 × 25) - 161
BMR = 550 + 1000 - 125 - 161
BMR = 1264 kcal/gün
```

### 2. TDEE (Orta Aktif = 1.55)
```
TDEE = BMR × 1.55
TDEE = 1264 × 1.55
TDEE = 1959 kcal/gün
```

### 3. Kilo Kaybı İçin Hedef (500 kcal deficit)
```
Hedef Kalori = TDEE - 500
Hedef Kalori = 1959 - 500
Hedef Kalori = 1460 kcal/gün
```

### 4. Makro Dağılımı
```
Protein (35%):  (1460 × 0.35) / 4 = 128g
Karbonhidrat (40%): (1460 × 0.40) / 4 = 146g
Yağ (25%):      (1460 × 0.25) / 9 = 41g
```

**GÜNLÜK HEDEFLER:**
- Kalori: 1460 kcal
- Protein: 128g
- Karbonhidrat: 146g
- Yağ: 41g

---

## 🔍 SORUNUN KÖK NEDENİ ANALİZİ

### Olası Nedenler:

#### 1. ❌ VERİTABANI KATEGORİ HATASI
**Hipotez:** Ara öğün yemekleri JSON'da yanlış kategoriyle kaydedilmiş olabilir.

**Kontrol noktaları:**
- `assets/data/kahvalti_batch_01.json` içinde ara öğün yemekleri var mı?
- `assets/data/kahvalti_batch_02.json` içinde ara öğün yemekleri var mı?
- Migration sırasında kategori mapping'i doğru yapılmış mı?

#### 2. ❌ ÖĞÜN PLANLAYICI SEÇİM HATASI
**Hipotez:** `OgunPlanlayici` kahvaltı öğünü için yemek seçerken, yanlış kategoriden yemek alıyor.

**Kod analizi:**
```dart
// ogun_planlayici.dart - satır ~180
final plan = _rastgelePlanOlustur(yemekler, hedefKalori, hedefProtein, hedefKarb, hedefYag);

// _rastgelePlanOlustur içinde:
kahvalti: _cesitliYemekSec(yemekler[OgunTipi.kahvalti]!, OgunTipi.kahvalti),
```

**SORUN TESPİT EDİLDİ:** 
- `yemekler[OgunTipi.kahvalti]` içinde ara öğün kategorisindeki yemekler olabilir!
- Yani Hive DB'de kahvaltı kategorisinde ara öğün yemekleri var!

#### 3. ❌ KATEGORİ MAPPİNG HATASI
**Hipotez:** `YemekHiveDataSource` içinde kategori mapping'i yanlış.

**Kod kontrolü:**
```dart
// yemek_hive_data_source.dart - satır ~200
String _ogunTipiToKategori(OgunTipi ogun) {
  switch (ogun) {
    case OgunTipi.kahvalti:
      return 'Kahvaltı';  // ✅ DOĞRU
    case OgunTipi.araOgun1:
      return 'Ara Öğün 1';  // ✅ DOĞRU
    ...
  }
}
```

Mapping doğru görünüyor! **Sorun burada değil**.

---

## 🎯 GERÇEK SORUN: VERİTABANI KIRLILIĞI

### Hipotez:
JSON dosyalarında **kahvalti** kategorisindeki bazı yemeklerin **category** alanı "Ara Öğün 1" veya "Ara Öğün 2" olarak işaretlenmiş olabilir!

### Örnek senaryo:
```json
// kahvalti_batch_01.json içinde:
{
  "id": "yemek123",
  "name": "Süzme Yoğurt + Muz",
  "category": "Ara Öğün 1",  // ❌ YANLIŞ! Dosya adı kahvalti ama category ara öğün!
  "meal_time": "Kahvaltı",
  "calories": 150,
  ...
}
```

### Migration sırasında ne oluyor?
```dart
// yemek_migration_guncel.dart
final kategori = yemekMap['category'] as String? ?? 'Bilinmiyor';
```

Migration, **JSON'daki `category` alanını** kullanarak Hive DB'ye kaydediyor!

Yani:
1. Dosya adı: `kahvalti_batch_01.json`
2. İçindeki yemek: `"category": "Ara Öğün 1"`
3. Migration sonucu: **Hive DB'de "Ara Öğün 1" kategorisine kaydedilir**
4. Sorun: Kahvaltı listesine ara öğün yemeği gelir!

---

## ✅ ÇÖZÜM ÖNERİLERİ

### Çözüm 1: JSON Dosyalarını Temizle (MANUEL)
```bash
# Tüm kahvalti*.json dosyalarını kontrol et
# "category": "Ara Öğün" içeren satırları bul ve düzelt
```

### Çözüm 2: Migration'a Dosya Adı Kontrolü Ekle (OTOMATİK)
```dart
// yemek_migration_guncel.dart içinde:
String _kategoriOtoAlgila(String dosyaAdi, String? jsonKategori) {
  // Dosya adına göre kategori belirle (JSON'daki category'ye güvenme!)
  if (dosyaAdi.contains('kahvalti')) return 'Kahvaltı';
  if (dosyaAdi.contains('ara_ogun_1')) return 'Ara Öğün 1';
  if (dosyaAdi.contains('ara_ogun_2')) return 'Ara Öğün 2';
  if (dosyaAdi.contains('ogle')) return 'Öğle Yemeği';
  if (dosyaAdi.contains('aksam')) return 'Akşam Yemeği';
  
  // Fallback: JSON'daki category'yi kullan
  return jsonKategori ?? 'Bilinmiyor';
}
```

### Çözüm 3: Öğün Planlayıcısına Kategori Validasyonu Ekle (GÜVENLİK)
```dart
// ogun_planlayici.dart içinde _cesitliYemekSec metoduna:
Yemek _cesitliYemekSec(List<Yemek> yemekler, OgunTipi ogunTipi) {
  if (yemekler.isEmpty) {
    throw Exception('Yemek listesi boş!');
  }

  // 🔥 YENİ: Kategori validasyonu - yemeklerin ogunTipi ile eşleştiğini kontrol et
  final uygunYemekler = yemekler.where((y) => y.ogun == ogunTipi).toList();
  
  if (uygunYemekler.isEmpty) {
    AppLogger.error('❌ HATA: $ogunTipi için uygun yemek yok! Tüm yemekler farklı kategoriden!');
    // Fallback: Orijinal listeyi kullan (eski davranış)
    return yemekler[_random.nextInt(yemekler.length)];
  }
  
  // Sadece uygun kategorideki yemeklerden seç
  // ... (mevcut çeşitlilik mekanizması)
}
```

---

## 🔧 HEMEN YAPILMASI GEREKENLER

### 1. JSON Dosya Kontrolü
```bash
# Kahvaltı dosyalarında ara öğün var mı kontrol et:
grep -n '"category".*Ara Öğün' assets/data/kahvalti*.json
```

### 2. Hive DB Kontrolü
```dart
// Test scripti:
final kahvaltilar = await hiveService.kategoriYemekleriGetir('Kahvaltı');
final araOgunluKahvaltilar = kahvaltilar.where((y) => 
  y.ogun == OgunTipi.araOgun1 || y.ogun == OgunTipi.araOgun2
).toList();

print('Kahvaltı kategorisinde ara öğün sayısı: ${araOgunluKahvaltilar.length}');
```

### 3. Migration'ı Düzelt ve Yeniden Çalıştır
- `yemek_migration_guncel.dart` dosyasına dosya adı bazlı kategori algılama ekle
- Hive DB'yi temizle: `await YemekMigration.migrationTemizle();`
- Migration'ı yeniden çalıştır: `await YemekMigration.jsonToHiveMigration();`

---

## 📊 TEST PLANI

### Test 1: DB Kontrolü
```dart
final summary = await DBSummaryService.getDatabaseSummary();
print(summary);

// Kategorilere göre yemek sayıları
// Kahvaltı: 60 (beklenen)
// Ara Öğün 1: 170 (beklenen)
// Ara Öğün 2: 50 (beklenen)
```

### Test 2: Kategori Cross-Check
```dart
// Kahvaltı kategorisindeki yemeklerin hepsi OgunTipi.kahvalti mi?
final kahvaltilar = await dataSource.yemekleriYukle(OgunTipi.kahvalti);
final yanlisKategoriler = kahvaltilar.where((y) => y.ogun != OgunTipi.kahvalti);

if (yanlisKategoriler.isNotEmpty) {
  print('❌ HATA: ${yanlisKategoriler.length} yemek yanlış kategoride!');
  for (final yemek in yanlisKategoriler) {
    print('  - ${yemek.ad}: Beklenen=kahvalti, Gerçek=${yemek.ogun}');
  }
}
```

### Test 3: 7 Günlük Plan Simülasyonu
```dart
final haftalikPlan = await planlayici.haftalikPlanOlustur(
  hedefKalori: 1460,
  hedefProtein: 128,
  hedefKarb: 146,
  hedefYag: 41,
);

// Her günün kahvaltısını kontrol et
for (final gun in haftalikPlan) {
  if (gun.kahvalti != null) {
    final kategori = gun.kahvalti!.ogun.toString();
    if (kategori.contains('araOgun')) {
      print('❌ HATA: ${gun.tarih} - Kahvaltıda ara öğün!');
      print('   Yemek: ${gun.kahvalti!.ad}');
      print('   Kategori: $kategori');
    }
  }
}
```

---

## 🎯 ÖNCELİKLİ EYLEM PLANI

1. ✅ **JSON dosya kontrolü yapılacak** (grep veya manuel)
2. ✅ **Migration düzeltilecek** (dosya adı bazlı kategori)
3. ✅ **Hive DB temizlenip yeniden yüklenecek**
4. ✅ **OgunPlanlayici'ya kategori validasyonu eklenecek** (güvenlik)
5. ✅ **Test yapılacak** (7 günlük plan + kategori kontrolü)

---

## 📝 NOTLAR

- Bu sorun **sadece kahvaltıda** değil, **tüm öğünlerde** olabilir!
- Öğle yemeğinde kahvaltılık çıkabilir
- Akşam yemeğinde ara öğün çıkabilir
- vb.

**Kök neden:** JSON dosyalarındaki `category` alanı ile dosya adı tutarsızlığı!

**Kalıcı çözüm:** Migration'da dosya adını baz al, JSON'daki category'ye güvenme!
