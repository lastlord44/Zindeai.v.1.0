# 🔧 Maintenance Page - Gelişmiş Versiyon

**Tarih:** 18 Ekim 2025  
**Durum:** ✅ Tamamlandı  
**Dosya:** [`lib/presentation/pages/maintenance_page.dart`](lib/presentation/pages/maintenance_page.dart)

## 📋 Genel Bakış

Maintenance Page, ZindeAI uygulamasının database yönetimi, sağlık kontrolü ve migration işlemleri için gelişmiş bir admin arayüzüdür.

### 🎯 Temel Özellikler

- **3 Tab Sistemi**: Genel, Sağlık, Detaylar
- **Database Health Check**: Otomatik sağlık skoru hesaplama
- **Migration Yönetimi**: İlerleme takipli DB temizleme ve yeniden yükleme
- **İstatistikler**: Kategori dağılımı, kalori ortalamaları
- **Gerçek Zamanlı Monitoring**: Anlık durum güncellemeleri

## 🏗️ Mimari Yapı

### Tab Sistemi

```dart
TabController _tabController = TabController(length: 3, vsync: this);

Tabs:
1. 📊 Genel Tab - Migration ve temel işlemler
2. 🏥 Sağlık Tab - Health check ve sorun tespit
3. 📋 Detaylar Tab - Kategori dağılımı ve istatistikler
```

### State Management

```dart
// Ana state değişkenleri
bool _isLoading = false;
String _statusMessage = 'Hazır';
Map<String, int>? _kategoriSayilari;
int? _toplamYemek;
Map<String, dynamic>? _healthCheckResults;
double? _migrationProgress;
```

## 🎨 UI Bileşenleri

### 1. 📊 Genel Tab

#### Uyarı Kartı
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.amber.shade50,
    border: Border.all(color: Colors.amber.shade300),
  ),
  child: Text('⚠️ Bu işlem tüm verileri silecek!'),
)
```

#### Mevcut Durum Kartı
- Toplam yemek sayısı
- Ortalama kalori değeri
- Gerçek zamanlı güncelleme

#### İlerleme Göstergesi
```dart
LinearProgressIndicator(
  value: _migrationProgress,
  minHeight: 12,
  backgroundColor: Colors.grey.shade200,
)
```

#### Action Buttons
1. **DB Temizle ve Yeniden Yükle** - Ana migration işlemi
2. **İstatistikleri Yenile** - Manuel güncelleme

### 2. 🏥 Sağlık Tab

#### Health Score Kartı
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [color.shade400, color.shade600],
    ),
  ),
  child: Column(
    children: [
      Icon(Icons.favorite, size: 48),
      Text('${healthScore}%', fontSize: 48),
      Text(healthScore >= 80 ? 'Mükemmel!' : 'İyi'),
    ],
  ),
)
```

**Health Score Renk Sistemi:**
- 🟢 Yeşil (≥80%): Mükemmel
- 🟠 Turuncu (50-79%): İyi
- 🔴 Kırmızı (<50%): Dikkat Gerekli

#### Sorun Tespit Kartı
Tespit edilen sorunlar:
- ⚠️ Boş kalori yemekler
- ⚠️ Eksik malzeme yemekler
- ⚠️ Çok düşük kalori (<50 kcal)
- ⚠️ Çok yüksek kalori (>2000 kcal)

#### İstatistikler Kartı
- 📊 Toplam yemek sayısı
- 🔥 Ortalama kalori
- 💪 Ortalama protein

### 3. 📋 Detaylar Tab

#### Kategori Dağılımı
```dart
- Kategori adı
- Yemek sayısı
- Yüzde dilimi
- Görsel progress bar
```

**Örnek:**
```
Kahvaltı        ██████████ 450 yemek (15.0%)
Öğle Yemeği     ███████████████ 750 yemek (25.0%)
Akşam Yemeği    ███████████████ 750 yemek (25.0%)
Ara Öğün 1      ████████ 400 yemek (13.3%)
Ara Öğün 2      ████████ 400 yemek (13.3%)
```

## 🔬 Database Health Check Algoritması

### Sağlık Kontrolü
```dart
Future<void> _performHealthCheck() async {
  final yemekler = await HiveService.tumYemekleriGetir();
  
  // Sorun tespitleri
  int bosKaloriYemek = 0;
  int eksikMalzemeYemek = 0;
  int cokDusukKaloriYemek = 0;
  int cokYuksekKaloriYemek = 0;
  
  for (var yemek in yemekler) {
    if (yemek.kalori <= 0) bosKaloriYemek++;
    if (yemek.kalori > 0 && yemek.kalori < 50) cokDusukKaloriYemek++;
    if (yemek.kalori > 2000) cokYuksekKaloriYemek++;
    if (yemek.malzemeler.isEmpty) eksikMalzemeYemek++;
  }
  
  // Health score hesaplama
  final healthScore = _calculateHealthScore(
    yemekler.length,
    bosKaloriYemek,
    eksikMalzemeYemek,
  );
}
```

### Health Score Formülü
```dart
double _calculateHealthScore(int toplam, int bosKalori, int eksikMalzeme) {
  if (toplam == 0) return 0;
  
  final sorunluYemek = bosKalori + eksikMalzeme;
  final saglikliYemek = toplam - sorunluYemek;
  
  return (saglikliYemek / toplam) * 100;
}
```

**Formül:**
```
Health Score = (Sağlıklı Yemekler / Toplam Yemekler) × 100

Örnek:
- Toplam: 3000 yemek
- Boş kalori: 50
- Eksik malzeme: 100
- Sorunlu: 150
- Sağlıklı: 2850
- Score: Maintenance Page dokümantasyonunu oluşturuyorum:

<write_to_file>
<path>MAINTENANCE_PAGE_GELISMIS_VERSIYONU.md</path>
<content>
# 🔧 Maintenance Page - Gelişmiş Versiyon Dokümantasyonu

**Tarih:** 18 Ekim 2025  
**Versiyon:** 2.0 (Gelişmiş)  
**Dosya:** [`lib/presentation/pages/maintenance_page.dart`](lib/presentation/pages/maintenance_page.dart)

---

## 📋 Genel Bakış

Maintenance Page, ZindeAI uygulamasının veritabanı yönetimi, migration işlemleri ve sistem sağlığı kontrolü için geliştirilmiş profesyonel bir admin arayüzüdür.

### ✨ Temel Özellikler

- ✅ **3 Sekmeli Modern UI** (Genel, Sağlık, Detaylar)
- ✅ **Database Health Check Sistemi**
- ✅ **Detaylı İstatistikler ve Grafikler**
- ✅ **İlerleme Takipli Migration**
- ✅ **Onay Dialogları ile Güvenli İşlemler**
- ✅ **Gerçek Zamanlı Durum Güncellemeleri**

---

## 🎨 UI Yapısı

### Tab 1: Genel (Ana İşlemler)
```
├── Uyarı Kartı (Dikkat mesajı)
├── Mevcut Durum Kartı
│   ├── Toplam Yemek Sayısı
│   └── Ortalama Kalori
├── İlerleme Göstergesi (Migration sırasında)
├── Status Mesajı
├── Aksiyon Butonları
│   ├── DB Temizle ve Yeniden Yükle
│   └── İstatistikleri Yenile
└── Bilgi Kartı (Ne yapılıyor açıklaması)
```

### Tab 2: Sağlık (Health Check)
```
├── Database Sağlık Skoru (0-100%)
│   ├── Mükemmel (≥80%)
│   ├── İyi (50-79%)
│   └── Dikkat Gerekli (<50%)
├── Tespit Edilen Sorunlar
│   ├── Boş kalori yemekler
│   ├── Eksik malzeme yemekler
│   ├── Çok düşük kalori (<50 kcal)
│   └── Çok yüksek kalori (>2000 kcal)
├── Genel İstatistikler
│   ├── Toplam Yemek
│   ├── Ortalama Kalori
│   └── Ortalama Protein
└── Sağlık Kontrolünü Yenile Butonu
```

### Tab 3: Detaylar (Kategori Dağılımı)
```
└── Kategori Dağılımı
    ├── Her kategori için:
    │   ├── Kategori adı
    │   ├── Yemek sayısı
    │   ├── Yüzde oranı
    │   └── Görsel progress bar
```

---

## 🔧 Teknik Detaylar

### State Yönetimi

```dart
bool _isLoading = false;                    // Migration durumu
String _statusMessage = 'Hazır';            // Durum mesajı
Map<String, int>? _kategoriSayilari;        // Kategori bazlı sayılar
int? _toplamYemek;                          // Toplam yemek sayısı
Map<String, dynamic>? _healthCheckResults;  // Sağlık kontrolü sonuçları
double? _migrationProgress;                 // Migration ilerleme (0.0-1.0)
```

### Ana Fonksiyonlar

#### 1. `_loadStats()` - İstatistikleri Yükle
```dart
Future<void> _loadStats() async {
  final toplamYemek = await HiveService.yemekSayisi();
  final kategoriSayilari = await HiveService.kategoriSayilari();
  // State güncelleme
}
```

**Ne Yapar:**
- HiveService'den toplam yemek sayısını alır
- Kategori bazlı yemek sayılarını getirir
- UI'ı günceller

#### 2. `_performHealthCheck()` - Sağlık Kontrolü
```dart
Future<void> _performHealthCheck() async {
  // Tüm yemekleri getir
  final yemekler = await HiveService.tumYemekleriGetir();
  
  // Sorunları tespit et
  for (var yemek in yemekler) {
    if (yemek.kalori <= 0) bosKaloriYemek++;
    if (yemek.kalori < 50) cokDusukKaloriYemek++;
    if (yemek.kalori > 2000) cokYuksekKaloriYemek++;
    if (yemek.malzemeler.isEmpty) eksikMalzemeYemek++;
  }
  
  // Ortalamaları hesapla
  final kaloriOrtalama = ...;
  final proteinOrtalama = ...;
  
  // Health Score hesapla
  final healthScore = _calculateHealthScore(...);
}
```

**Ne Yapar:**
- Tüm yemekleri analiz eder
- 4 kategoride sorun tespit eder
- Ortalama değerleri hesaplar
- 0-100 arası sağlık skoru üretir

**Health Score Formülü:**
```dart
healthScore = (saglikliYemek / toplamYemek) * 100

saglikliYemek = toplam - (bosKalori + eksikMalzeme)
```

**Skor Anlamları:**
- **80-100%**: 🟢 Mükemmel - DB sağlıklı
- **50-79%**: 🟡 İyi - Minör sorunlar var
- **0-49%**: 🔴 Dikkat Gerekli - Major sorunlar tespit edildi

#### 3. `_resetDatabase()` - DB Reset + Migration
```dart
Future<void> _resetDatabase() async {
  // 1. Kullanıcıdan onay al
  final confirm = await showDialog<bool>(...);
  if (confirm != true) return;
  
  // 2. Loading başlat
  setState(() {
    _isLoading = true;
    _migrationProgress = 0.0;
  });
  
  // 3. Mevcut verileri sil
  await HiveService.tumYemekleriSil();
  setState(() => _migrationProgress = 0.2);
  
  // 4. Migration çalıştır (süre ölç)
  final stopwatch = Stopwatch()..start();
  final success = await YemekMigration.jsonToHiveMigration();
  stopwatch.stop();
  
  // 5. Sonuç göster + stats güncelle
  if (success) {
    await _loadStats();
    await _performHealthCheck();
    // Snackbar göster
  }
}
```

**İşlem Akışı:**
1. ⚠️ Onay dialogu göster
2. 🗑️ Mevcut yemekleri sil
3. 🔄 Migration başlat (progress: 20%)
4. ⏱️ Süre ölçümü yap
5. ✅ Başarı durumunda:
   - Stats'ı güncelle
   - Health check yap
   - Kullanıcıya bildir (Snackbar)
6. ❌ Hata durumunda:
   - Error mesajı göster
   - Log kaydet

---

## 🎯 Kullanım Senaryoları

### Senaryo 1: İlk Kurulum Sonrası Kontrol
```
1. Maintenance Page'i aç
2. Sağlık sekmesine geç
3. Health Score'u kontrol et
   - %100 olmalı (ideal durum)
4. Detaylar sekmesinde kategori dağılımını kontrol et
```

### Senaryo 2: Migration Sonrası Doğrulama
```
1. DB Temizle ve Yeniden Yükle butonuna bas
2. Onay dialogunda "Evet, Temizle" seç
3. İlerleme çubuğunu takip et
4. Başarı mesajını bekle (örn: "3400 yemek yüklendi! (45s)")
5. Sağlık sekmesinde health check sonuçlarını incele
```

### Senaryo 3: Periyodik Bakım
```
Haftada 1 kez:
1. Maintenance Page'i aç
2. "İstatistikleri Yenile" butonuna bas
3. Health Score'u kontrol et
4. Eğer <80% ise, DB reset düşün
```

### Senaryo 4: Sorun Giderme
```
Yemek planlaması hatalı ise:
1. Sağlık sekmesini aç
2. "Tespit Edilen Sorunlar" bölümünü incele
3. Eğer sorun sayısı yüksekse:
   - JSON dosyalarını kontrol et
   - DB'yi temizle ve yeniden yükle
4. Tekrar health check yap
```

---

## 📊 İstatistik Kartları

### Mevcut Durum Kartı
**Gösterilen Bilgiler:**
- 🍽️ Toplam Yemek Sayısı
- 🔥 Ortalama Kalori (varsa)

**Renk Şeması:** Beyaz arka plan, mor ikonlar

### Sağlık Skoru Kartı
**Dinamik Gradient:**
- **Yeşil (≥80%)**: 🟢 success gradient
- **Turuncu (50-79%)**: 🟡 warning gradient
- **Kırmızı (<50%)**: 🔴 error gradient

**Animasyonlar:**
- Gradient geçişleri
- Shadow efektleri (alpha: 0.3)

### Sorunlar Kartı
**İkon Sistemi:**
- ⚠️ Turuncu warning ikonu (sorun varsa)
- ✅ Yeşil check ikonu (sorun yoksa)

**Sorun Kategorileri:**
1. Boş kalori (kalori <= 0)
2. Eksik malzeme (malzemeler.isEmpty)
3. Çok düşük kalori (< 50 kcal)
4. Çok yüksek kalori (> 2000 kcal)

### Genel İstatistikler Kartı
**3 Sütunlu Layout:**
```
│ Toplam Yemek │ Ort. Kalori │ Ort. Protein │
│    3400       │   450.0     │    35.0g     │
```

**İkonlar:**
- 🍽️ Restaurant menu (Toplam)
- 🔥 Fire (Kalori)
- 💪 Fitness (Protein)

---

## 🎨 UI/UX Detayları

### Renk Paleti
```dart
// Ana renkler
Primary: Colors.deepPurple
Background: Colors.grey.shade50

// Status renkleri
Success: Colors.green.shade50
Error: Colors.red.shade50
Info: Colors.blue.shade50
Warning: Colors.amber.shade50

// Border renkleri
Success Border: Colors.green.shade300
Error Border: Colors.red.shade300
Info Border: Colors.blue.shade300
Warning Border: Colors.amber.shade300
```

### Shadow & Elevation
```dart
BoxShadow(
  color: Colors.black.withValues(alpha: 0.05),
  blurRadius: 10,
  offset: Offset(0, 5),
)
```

### Border Radius
- Kartlar: `BorderRadius.circular(12)`
- Butonlar: `BorderRadius.circular(12)`
- Progress bar: `BorderRadius.circular(8)`
- Mini elementler: `BorderRadius.circular(4)`

### Padding & Spacing
- Sayfa padding: `16px`
- Kart padding: `16px`
- Bölüm arası: `24px`
- Element arası: `12px`
- Mini spacing: `4px`, `6px`, `8px`

---

## 🔐 Güvenlik Önlemleri

### 1. Onay Dialogu
```dart
final confirm = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('⚠️ Dikkat!'),
    content: Text('Bu işlem tüm mevcut yemekleri silip yeniden yükleyecek...'),
    actions: [
      TextButton(...), // İptal
      ElevatedButton(...), // Evet, Temizle (KIR MIZI)
    ],
  ),
);
```

**Özellikler:**
- ⚠️ Görsel uyarı ikonu
- Açık ve net mesaj
- Kırmızı "Evet" butonu (tehlike vurgusu)
- Gri "İptal" butonu

### 2. Loading State Kontrolü
```dart
onPressed: _isLoading ? null : _resetDatabase
```
- Migration çalışırken butonlar disabled
- Kullanıcı müdahalesini engeller

### 3. Error Handling
```dart
try {
  // Migration işlemleri
} catch (e, stackTrace) {
  setState(() => _statusMessage = '❌ Hata: $e');
  AppLogger.error('Migration hatası', error: e, stackTrace: stackTrace);
}
```

---

## 📱 Responsive Tasarım

### Tab Bar
```dart
TabBar(
  controller: _tabController,
  indicatorColor: Colors.white,
  tabs: [
    Tab(icon: Icon(Icons.home), text: 'Genel'),
    Tab(icon: Icon(Icons.health_and_safety), text: 'Sağlık'),
    Tab(icon: Icon(Icons.info), text: 'Detaylar'),
  ],
)
```

### Scroll Desteği
Tüm tab'lar `SingleChildScrollView` ile sarılı:
- İçerik uzunsa scroll edilebilir
- Küçük ekranlarda taşma olmaz

---

## 🚀 Performance Optimizasyonları

### 1. Lazy Loading
- Health check sadece initState'te çalışır
- Stats sadece gerektiğinde güncellenir

### 2. Efficient State Updates
```dart
setState(() {
  _toplamYemek = toplamYemek;
  _kategoriSayilari = kategoriSayilari;
});
```
- Minimal state güncellemeleri
- Gereksiz rebuild'ler önlenmiş

### 3. Stopwatch ile Süre Ölçümü
```dart
final stopwatch = Stopwatch()..start();
final success = await YemekMigration.jsonToHiveMigration();
stopwatch.stop();
// Kullanıcıya "45s" gibi gerçek süre gösterilir
```

---

## 📈 İstatistik Hesaplamaları

### Kalori Ortalaması
```dart
final kaloriOrtalama = yemekler.isEmpty
    ? 0
    : yemekler.fold<double>(0, (sum, y) => sum + y.kalori) / yemekler.length;
```

### Protein Ortalaması
```dart
final proteinOrtalama = yemekler.isEmpty
    ? 0
    : yemekler.fold<double>(0, (sum, y) => sum + y.protein) / yemekler.length;
```

### Kategori Dağılımı Yüzdesi
```dart
final percentage = _toplamYemek != null && _toplamYemek! > 0
    ? (entry.value / _toplamYemek!) * 100
    : 0.0;
```

---

## 🐛 Debugging & Logging

### AppLogger Kullanımı
```dart
// Bilgi
AppLogger.info('✅ Mevcut yemekler silindi');

// Başarı
AppLogger.success('✅ Migration tamamlandı: ${stopwatch.elapsed.inSeconds}s');

// Hata
AppLogger.error('❌ Migration hatası', error: e, stackTrace: stackTrace);

// Debug
AppLogger.debug('✅ Kategori sayıları: $sayilar');
```

### Console Output Örnekleri
```
ℹ️ INFO: ✅ Mevcut yemekler silindi
✅ SUCCESS: ✅ Migration tamamlandı: 45s
❌ ERROR: Migration hatası | Error: Exception...
```

---

## 🔄 Migration Akışı

### Adım Adım İşlem
```
1. User: "DB Temizle" butonuna basar
2. System: Onay dialogu gösterir
3. User: "Evet, Temizle" der
4. System: _isLoading = true, progress = 0.0
5. System: HiveService.tumYemekleriSil() çağrılır
6. System: progress = 0.2
7. System: YemekMigration.jsonToHiveMigration() başlar
8. System: JSON dosyaları okunur, parse edilir, Hive'a kaydedilir
9. System: progress = 1.0
10. System: _loadStats() + _performHealthCheck() çağrılır
11. System: Snackbar gösterilir: "✅ 3400 yemek yüklendi! (45s)"
12. System: _isLoading = false
```

### Progress Değerleri
- **0.0**: Başlangıç
- **0.2**: Silme tamamlandı
- **1.0**: Migration tamamlandı

---

## 📝 Widget Tree

```
MaintenancePage (StatefulWidget)
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "🔧 Maintenance & Debug"
│   │   └── TabBar (3 tab)
│   └── TabBarView
│       ├── Tab 1: _buildGenelTab()
│       │   ├── SingleChildScrollView
│       │   └── Column
│       │       ├── _buildWarningCard()
│       │       ├── _buildCurrentStatusCard()
│       │       ├── _buildProgressCard() [conditional]
│       │       ├── _buildStatusCard()
│       │       ├── _buildActionButtons()
│       │       └── _buildInfoCard()
│       ├── Tab 2: _buildSaglikTab()
│       │   ├── SingleChildScrollView
│       │   └── Column
│       │       ├── Health Score Container (gradient)
│       │       ├── _buildHealthIssuesCard()
│       │       ├── _buildHealthStatsCard()
│       │       └── Refresh Button
│       └── Tab 3: _buildDetaylarTab()
│           ├── SingleChildScrollView
│           └── Column
│               └── Kategori listesi (progress bars)
```

---

## 🎓 Best Practices

### 1. State Management
✅ **DO:**
```dart
setState(() {
  _isLoading = true;
  _statusMessage = 'İşlem yapılıyor...';
});
```

❌ **DON'T:**
```dart
_isLoading = true; // setState olmadan
build(context); // Manuel rebuild
```

### 2. Async Operations
✅ **DO:**
```dart
try {
  await HiveService.tumYemekleriSil();
  await _loadStats();
} catch (e) {
  AppLogger.error('Hata', error: e);
}
```

❌ **DON'T:**
```dart
HiveService.tumYemekleriSil(); // await yok
_loadStats(); // Sıralı işlem garanti edilmez
```

### 3. User Feedback
✅ **DO:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('✅ İşlem başarılı!'))
);
```

❌ **DON'T:**
```dart
print('İşlem başarılı'); // Kullanıcı göremez
```

---

## 🔮 Gelecek Geliştirmeler

### Planlanan Özellikler
- [ ] **Export/Import**: DB'yi JSON olarak dışa aktar
- [ ] **Backup/Restore**: Otomatik yedekleme sistemi
- [ ] **Performance Monitoring**: Real-time performans grafikleri
- [ ] **Log Viewer**: Uygulama loglarını görüntüleme
- [ ] **Schedule Migration**: Zamanlanmış migration işlemleri
- [ ] **Notification System**: Migration tamamlandığında bildirim
- [ ] **Dark Mode Support**: Karanlık tema desteği

### Potansiyel İyileştirmeler
- Kategori bazlı filtreleme
- Yemek arama fonksiyonu
- Toplu düzenleme özellikleri
- JSON dosya validasyonu
- Hata raporlama sistemi

---

## 📚 İlgili Dosyalar

### Core Services
- [`lib/data/local/hive_service.dart`](lib/data/local/hive_service.dart) - Hive DB işlemleri
- [`lib/core/utils/yemek_migration_guncel.dart`](lib/core/utils/yemek_migration_guncel.dart) - Migration mantığı
- [`lib/core/utils/app_logger.dart`](lib/core/utils/app_logger.dart) - Logging sistemi

### Data Models
- [`lib/data/models/yemek_hive_model.dart`](lib/data/models/yemek_hive_model.dart) - Yemek Hive modeli
- [`lib/domain/entities/yemek.dart`](lib/domain/entities/yemek.dart) - Yemek entity

### JSON Data
- `assets/data/son/*.json` - 30 dosya × 100 yemek = ~3000 yemek
- `assets/data/kahvalti_yuksek_karb_50.json` - Karbonhidrat özel
- `assets/data/kahvalti.json` - Kahvaltı özel
- `assets/data/ara_ogun_toplu_120.json` - Ara öğünler
- `assets/data/cheat_meal.json` - Cheat meal'lar

---

## 🎯 Özet

Maintenance Page, ZindeAI uygulamasının **kalbi** sayılabilecek kritik bir yönetim arayüzüdür:

### Avantajları
✅ **Kullanıcı Dostu**: 3 sekmeli basit navigasyon  
✅ **Güvenli**: Onay dialogları ile hatalı işlemleri önler  
✅ **Bilgilendirici**: Detaylı health check ve istatistikler  
✅ **Performanslı**: Optimize edilmiş state management  
✅ **Profesyonel**: Modern UI/UX tasarımı  

### Ne doğrulama
- 🔄 Migration işlemleri
- 🏥 Periyodik sağlık kontrolleri
- 🐛 Sorun giderme ve debugging
- 📊 İstatistik analizi

---

**Son Güncelleme:** 18 Ekim 2025  
**Geliştirici:** Cline AI + ZindeAI Team  
**Versiyon:** 2.0 (Gelişmiş)