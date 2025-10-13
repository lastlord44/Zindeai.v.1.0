# 🚀 3000 Yemek Migration Talimatı

## 📋 Özet

ChatGPT ile oluşturduğunuz **29 JSON dosyası** (toplam ~2900 yemek) `assets/data/son/` klasöründe hazır. Bu yemekleri Hive DB'ye yüklemek için migration utility class'ı oluşturuldu.

## 🎯 Migration Utility

**Dosya**: `lib/core/utils/yemek_migration_3000.dart`

### ✅ Özellikler:

- ✅ **YemekHiveModel.fromJson()** kullanarak otomatik parse
- ✅ **HiveService.yemekKaydet()** ile doğru method
- ✅ **Static method çağrıları** düzeltildi
- ✅ **29 JSON dosyası** tanımlı
- ✅ **Progress tracking** konsola yazdırılıyor
- ✅ **Kategori bazında istatistik** sunuyor

### 📦 Yüklenecek Yemekler:

| Kategori | Dosya Sayısı | Yemek Sayısı |
|----------|--------------|--------------|
| **Tavuk** | 3 | 300 |
| **Dana** | 3 | 300 |
| **Köfte/Kıyma** | 3 | 300 |
| **Balık** | 3 | 300 |
| **Hindi** | 2 | 200 |
| **Yumurta** | 4 | 400 |
| **Süzme Yoğurt** | 3 | 300 |
| **Peynir** | 2 | 200 |
| **Baklagil** | 3 | 300 |
| **Trend Ara Öğün** | 3 | 300 |
| **TOPLAM** | **29** | **~2900** |

## 🛠️ Kullanım Yöntemi

### Seçenek 1: Geçici Flag ile Main'e Ekle (ÖNERİLEN)

**1. main.dart dosyasını aç**

**2. YemekMigration3000 import et:**

```dart
import 'package:zindeai/core/utils/yemek_migration_3000.dart';
```

**3. runApp() öncesine ekle:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive başlat
  await Hive.initFlutter();
  
  // Adapters register et
  Hive.registerAdapter(YemekHiveModelAdapter());
  Hive.registerAdapter(KullaniciHiveModelAdapter());
  // ... diğer adapterlar
  
  // HiveService init
  await HiveService.init();
  
  // 🚀 SADECE BİR KEZ ÇALIŞTIR!
  const MIGRATION_3000_AKTIF = true;  // Migration sonrası false yap
  
  if (MIGRATION_3000_AKTIF) {
    print('🔄 3000 Yemek Migration başlıyor...');
    await YemekMigration3000.yukle();
    print('✅ Migration tamamlandı!');
  }
  
  runApp(MyApp());
}
```

**4. Uygulamayı çalıştır:**

```bash
flutter run
```

**5. Console'da migration loglarını izle:**

```
🚀 3000 YEMEK MİGRATION BAŞLADI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Mevcut yemek sayısı: 0

📄 İşleniyor: tavuk_aksam_100.json
   ✅ 100 yemek yüklendi
📄 İşleniyor: tavuk_ara_ogun_100.json
   ✅ 100 yemek yüklendi
...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 MİGRATION SONUÇLARI:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Başarılı dosya: 29
❌ Hatalı dosya: 0
📈 Toplam yüklenen: 2900 yemek

📊 KATEGORİ BAZINDA DAĞILIM:
   • OgunTipi.kahvalti: 600 yemek
   • OgunTipi.ogle: 600 yemek
   • OgunTipi.aksam: 900 yemek
   • OgunTipi.araOgun1: 400 yemek
   • OgunTipi.araOgun2: 400 yemek

🎯 GÜNCEL TOPLAM: 2900 yemek
🆕 Eklenen: 2900 yeni yemek

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ MİGRATION TAMAMLANDI!
```

**6. Migration başarılı olduktan sonra:**

```dart
const MIGRATION_3000_AKTIF = false;  // ❌ Devre dışı bırak
```

### Seçenek 2: Debug Button ile Ayarlar Sayfasından

**1. Profil/Ayarlar sayfasına debug button ekle:**

```dart
// lib/presentation/pages/profil_page.dart

ElevatedButton(
  onPressed: () async {
    await YemekMigration3000.yukle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Migration tamamlandı!')),
    );
  },
  child: Text('🚀 3000 Yemek Yükle'),
)
```

## 📊 Sonuç Kontrolü

Migration sonrası DB durumunu kontrol et:

```dart
import 'package:zindeai/core/utils/db_summary_service.dart';

// DB özetini al
final summary = await DBSummaryService.getDatabaseSummary();
print(summary);

// Sağlık kontrolü
final health = await DBSummaryService.healthCheck();
print(health);
```

## ⚠️ Önemli Notlar

### ✅ DOs:
- ✅ Migration'ı **sadece bir kez** çalıştır
- ✅ Console loglarını **dikkatle izle**
- ✅ Migration sonrası **flag'i kapat**
- ✅ DB durumunu **kontrol et**

### ❌ DON'Ts:
- ❌ Migration'ı **tekrar tekrar çalıştırma** (duplicate yemek oluşur)
- ❌ JSON dosyalarını **elle düzenleme**
- ❌ Migration sırasında **uygulamayı kapatma**

## 🐛 Sorun Giderme

### Dosya Bulunamadı Hatası
```
⚠️  Dosya bulunamadı: assets/data/son/tavuk_aksam_100.json
```

**Çözüm**: JSON dosyalarının `assets/data/son/` klasöründe olduğundan emin ol.

### Yemek İşlenirken Hata
```
⚠️  Yemek işlenirken hata: ...
```

**Çözüm**: JSON formatını kontrol et, YemekHiveModel.fromJson() hatayı loglayacak.

### HiveService Hatası
```
❌ Dosya işlenirken hata: ...
```

**Çözüm**: HiveService.init() çağrıldığından emin ol.

## 📝 Teknik Detaylar

### JSON Format (Old Format)
```json
{
  "meal_name": "Izgara Tavuk Göğüs + Bulgur Pilavı + yeşil salata + Kekik",
  "main_ingredient": "tavuk",
  "meal_type": "aksam",
  "calories": 462,
  "protein": 44,
  "carbs": 38,
  "fat": 15,
  "portion_info": "...",
  "cooking_method": "...",
  "cooking_time": "...",
  "ingredients": [...]
}
```

### YemekHiveModel Dönüşümü
- ✅ `meal_name` → `ad`
- ✅ `meal_type` → `ogun` (OgunTipi enum)
- ✅ `calories` → `kalori` (double)
- ✅ `protein` → `protein` (double)
- ✅ `carbs` → `karbonhidrat` (double)
- ✅ `fat` → `yag` (double)
- ✅ `ingredients` → `malzemeler` (List<String>)
- ✅ Unique ID otomatik oluşturuluyor

## 🎉 Beklenen Sonuç

Migration başarılı olduktan sonra:

```
📊 DB DURUMU:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Toplam Yemek: 2900
📦 Kahvaltı: 600
📦 Öğle: 600
📦 Akşam: 900
📦 Ara Öğün 1: 400
📦 Ara Öğün 2: 400

✅ Sağlık: İyi
```

---

**Hazırlayan**: Cline AI Assistant  
**Tarih**: 13.10.2025  
**Versiyon**: 1.0
