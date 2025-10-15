# 🔧 MAKRO VE KATEGORİ SORUNU ÇÖZÜM PLANI

## 📋 Tespit Edilen Sorunlar

### ❌ SORUN 1: Tüm Makro Değerleri 0
```
🍽️  KAHVALTI: Izgara Uskumru + Tam Buğday Ekmek + ıspanak sote + Pul biber
    Kalori: 0 kcal | Protein: 0g | Karb: 0g | Yağ: 0g
```

**Kök Neden:**
- `YemekHiveModel.toEntity()` metodunda null değerler 0.0'a dönüştürülüyor
- Migration sırasında JSON field'ları doğru parse edilemiyor
- `calorie`, `proteinG`, `carbG`, `fatG` değerleri null kalıyor

**Etkilenen Dosya:**
- `lib/data/models/yemek_hive_model.dart` (satır 172-175)

---

### ❌ SORUN 2: Kahvaltıda Ana Yemek Geliyor
```
🍽️  KAHVALTI: Izgara Uskumru (balık yemeği - yanlış kategori!)
```

**Kök Neden:**
- `balik_kahvalti_ara_100.json` dosyası iki kategori içeriyor
- Migration kodu belirsiz dosya adlarını yanlış parse ediyor
- Dosya adında hem "kahvalti" hem "ara" var → sadece "kahvalti" alınıyor

**Etkilenen Dosya:**
- `lib/core/utils/yemek_migration_guncel.dart` (satır 292-309)

---

## ✅ ÇÖZÜM ADIMLARI

### 1️⃣ DB Durumunu Kontrol Et
**Hedef:** Gerçek durumu gör, hangi yemeklerin makroları 0, hangi kategoriler yanlış?

**Yapılacaklar:**
- [ ] HiveService ile DB'deki yemekleri sorgula
- [ ] İlk 10 yemeğin makrolarını kontrol et
- [ ] Kategori dağılımını kontrol et
- [ ] "Izgara Uskumru" yemeğini bul ve hangi kategoride olduğunu gör

**Kullanılacak Araçlar:**
- `HiveService.tumYemekleriGetir()`
- `HiveService.kategoriSayilari()`
- `HiveService.yemekGetir("meal_id")`

---

### 2️⃣ JSON Format Analizi
**Hedef:** Kaynak JSON dosyalarının formatını anla

**Yapılacaklar:**
- [ ] Migration kodundaki field mapping'i kontrol et
- [ ] Yeni format vs eski format karşılaştırması yap
- [ ] `_parseDouble()` metodunun çalışma mantığını doğrula

**Kontrol Edilecek:**
```dart
// Yeni format (Türkçe field adları)
calorie: _parseDouble(json['kalori']),      // ✅ Doğru mu?
proteinG: _parseDouble(json['protein']),    // ✅ Doğru mu?
carbG: _parseDouble(json['karbonhidrat']),  // ✅ Doğru mu?
fatG: _parseDouble(json['yag']),            // ✅ Doğru mu?

// Eski format (İngilizce field adları)
calorie: _parseDouble(json['calorie']),     // ✅ Doğru mu?
proteinG: _parseDouble(json['protein_g']),  // ✅ Doğru mu?
carbG: _parseDouble(json['carb_g']),        // ✅ Doğru mu?
fatG: _parseDouble(json['fat_g']),          // ✅ Doğru mu?
```

---

### 3️⃣ Migration Kodunu Düzelt

**3.1. Kategori Mapping Düzeltmesi**

**Sorun:** Belirsiz dosya adları (örn: `balik_kahvalti_ara_100.json`)

**Çözüm:** Daha akıllı kategori tespit algoritması

```dart
static String? _dosyaAdindanKategoriBelirle(String dosyaAdi) {
  final dosyaLower = dosyaAdi.toLowerCase();
  
  // 🔥 YENİ: Önce EN SPESİFİK kategoriyi kontrol et
  if (dosyaLower.contains('ara_ogun_2') || dosyaLower.contains('ara ogun 2'))
    return 'Ara Öğün 2';
  if (dosyaLower.contains('ara_ogun_1') || dosyaLower.contains('ara ogun 1'))
    return 'Ara Öğün 1';
  
  // 🔥 YENİ: "kahvalti_ara" = Ara Öğün 1 olarak yorumla (kahvaltı değil!)
  if (dosyaLower.contains('kahvalti_ara') || dosyaLower.contains('kahvalti ara'))
    return 'Ara Öğün 1';
    
  // Sonra genel kategorileri kontrol et
  if (dosyaLower.contains('kahvalti')) return 'Kahvaltı';
  if (dosyaLower.contains('ogle')) return 'Öğle Yemeği';
  if (dosyaLower.contains('aksam')) return 'Akşam Yemeği';
  if (dosyaLower.contains('gece')) return 'Gece Atıştırması';
  if (dosyaLower.contains('cheat')) return 'Cheat Meal';
  
  return null;
}
```

---

**3.2. Makro Parse Düzeltmesi**

**Sorun:** JSON'dan makro değerleri çekilemiyor

**Çözüm:** Debug log ekle ve field mapping'i kontrol et

```dart
factory YemekHiveModel.fromJson(Map<String, dynamic> json) {
  // 🔥 DEBUG: JSON içeriğini kontrol et
  print('🔍 DEBUG - JSON Keys: ${json.keys.toList()}');
  print('🔍 DEBUG - Kalori field: ${json['kalori']} / ${json['calorie']}');
  print('🔍 DEBUG - Protein field: ${json['protein']} / ${json['protein_g']}');
  
  final bool yeniFormat = json.containsKey('isim') || 
                          json.containsKey('ad') || 
                          json.containsKey('aciklama');
  
  if (yeniFormat) {
    // 🔥 FIX: Null kontrolü ekle
    final kalori = _parseDouble(json['kalori']);
    final protein = _parseDouble(json['protein']);
    final karb = _parseDouble(json['karbonhidrat']);
    final yag = _parseDouble(json['yag']);
    
    print('🔍 DEBUG - Parsed: kalori=$kalori, protein=$protein');
    
    if (kalori == null) {
      print('⚠️ WARNING: Kalori null! JSON: $json');
    }
    
    model = YemekHiveModel(
      calorie: kalori,
      proteinG: protein,
      carbG: karb,
      fatG: yag,
      // ...
    );
  }
  
  return model;
}
```

---

### 4️⃣ DB'yi Temizle ve Yeniden Yükle

**Yapılacaklar:**
- [ ] Mevcut Hive DB'yi temizle
- [ ] Düzeltilmiş migration kodunu çalıştır
- [ ] Yeni DB'yi kontrol et
- [ ] Makro değerlerinin doğru geldiğini doğrula

**Komutlar:**
```dart
// 1. DB'yi temizle
await HiveService.tumYemekleriSil();

// 2. Migration'ı yeniden çalıştır
await YemekMigration.jsonToHiveMigration();

// 3. Kontrol et
final sayi = await HiveService.yemekSayisi();
final ornekYemek = await HiveService.yemekGetir('MEAL-...');
print('Yemek sayısı: $sayi');
print('Örnek yemek: ${ornekYemek?.ad} - ${ornekYemek?.kalori} kcal');
```

---

### 5️⃣ Test ve Doğrulama

**Kontrol Listesi:**
- [ ] ✅ Tüm yemeklerin makro değerleri 0'dan büyük mü?
- [ ] ✅ Kahvaltı kategorisinde sadece kahvaltılık yemekler var mı?
- [ ] ✅ Ara Öğün kategorilerinde doğru yemekler var mı?
- [ ] ✅ Öğle ve Akşam kategorilerinde ana yemekler var mı?
- [ ] ✅ Log'da "0 kcal" görünmüyor mu?

**Test Scripti:**
```dart
void main() async {
  await HiveService.init();
  
  // Test 1: Makro değerleri kontrolü
  final tumYemekler = await HiveService.tumYemekleriGetir();
  final sifirKaloriliYemekler = tumYemekler.where((y) => y.kalori == 0).toList();
  print('❌ 0 kalorili yemek sayısı: ${sifirKaloriliYemekler.length}');
  
  // Test 2: Kategori kontrolü
  final kahvaltilar = tumYemekler.where((y) => y.ogun == OgunTipi.kahvalti).toList();
  print('✅ Kahvaltı sayısı: ${kahvaltilar.length}');
  kahvaltilar.take(5).forEach((y) {
    print('  - ${y.ad} (${y.kalori} kcal)');
  });
  
  // Test 3: "Izgara Uskumru" kontrolü
  final uskumru = tumYemekler.firstWhere(
    (y) => y.ad.contains('Uskumru'),
    orElse: () => throw Exception('Uskumru bulunamadı!'),
  );
  print('🐟 Izgara Uskumru kategorisi: ${uskumru.ogun.ad}');
  print('   Kalori: ${uskumru.kalori} kcal');
}
```

---

## 🎯 ÖNCELİK SIRASI

1. **YÜKSEK** - DB durumunu kontrol et (mevcut durum analizi)
2. **YÜKSEK** - Kategori mapping algoritmasını düzelt
3. **YÜKSEK** - Makro parse mekanizmasını düzelt
4. **ORTA** - DB'yi temizle ve yeniden yükle
5. **DÜŞÜK** - Comprehensive test yap

---

## 📝 EK NOTLAR

### Potansiyel Riskler
- DB temizlendiğinde kullanıcı verileri kaybolabilir (plan geçmişi vb.)
- Migration uzun sürebilir (3000+ yemek)
- JSON formatı beklenmedik şekilde farklı olabilir

### Alternatif Çözümler
1. **Hızlı Fix:** Sadece yanlış kategorideki yemekleri manuel düzelt
2. **Kısmi Migration:** Sadece makroları güncelle, kategorilere dokunma
3. **Selective Fix:** Sadece sorunlu dosyaları yeniden migration et

---

## ✅ BAŞARILI SONUÇ KRİTERLERİ

1. **Makrolar:** Hiçbir yemekte 0 kcal / 0g olmasın
2. **Kategoriler:** Her yemek doğru kategoride olsun
3. **Log Çıktısı:** Şu görüntü olmalı:
   ```
   🍽️  KAHVALTI: Menemen + Peynir + Zeytin
       Kalori: 450 kcal | Protein: 25g | Karb: 35g | Yağ: 22g
   ```
4. **Performans:** Migration 30 saniyeden kısa sürsün
5. **Çeşitlilik:** Çeşitlilik mekanizması bozulmamış olmalı

---

**Son Güncelleme:** 2025-10-13
**Durum:** ✅ Plan Hazır - Onay Bekleniyor