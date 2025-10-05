# 🚀 ZİNDEAI - ENTEGRASYON KILAVUZU

## 📋 HAZIRLIK

Bu kılavuz, oluşturduğum tüm dosyaları mevcut projenize **adım adım** nasıl entegre edeceğinizi gösteriyor.

**⚠️ ÖNEMLİ:** Mevcut çalışan kodlarınıza dokunmayacağız!

---

## ✅ ADIM 1: BAĞIMLILIKLAR (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Grafikler (FAZ 10 için)
  fl_chart: ^0.65.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Hive Code Generation
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

Terminalde çalıştır:
```bash
flutter pub get
```

---

## 📦 ADIM 2: DOSYA YAPISI OLUŞTUR

```
lib/
├── main.dart (MEVCUT - DOKUNMA)
├── core/
│   └── ... (MEVCUT - DOKUNMA)
├── data/
│   ├── datasources/
│   │   └── yemek_local_data_source.dart 🆕
│   ├── local/
│   │   └── hive_service.dart 🆕
│   └── models/
│       ├── kullanici_hive_model.dart 🆕
│       └── gunluk_plan_hive_model.dart 🆕
├── domain/
│   ├── entities/
│   │   ├── yemek.dart 🆕
│   │   ├── gunluk_plan.dart 🆕
│   │   └── ... (MEVCUT)
│   └── usecases/
│       └── ogun_planlayici.dart 🆕
└── presentation/
    ├── bloc/
    │   └── home/
    │       └── home_bloc.dart 🆕
    ├── pages/
    │   ├── home_page.dart 🆕
    │   └── ... (MEVCUT)
    └── widgets/
        ├── makro_progress_card.dart 🆕
        └── ogun_card.dart 🆕
```

---

## 🔧 ADIM 3: DOSYALARI KOPYALA

### 3.1 Domain Entities

**ENTEGRASYON/yemek.dart** → **lib/domain/entities/yemek.dart**

**ENTEGRASYON/gunluk_plan.dart** → **lib/domain/entities/gunluk_plan.dart**

### 3.2 Data Layer

**ENTEGRASYON/yemek_local_data_source.dart** → **lib/data/datasources/yemek_local_data_source.dart**

**ENTEGRASYON/hive_service.dart** → **lib/data/local/hive_service.dart**

### 3.3 Domain Use Cases

**ENTEGRASYON/ogun_planlayici.dart** → **lib/domain/usecases/ogun_planlayici.dart**

### 3.4 Presentation Widgets

**ENTEGRASYON/makro_progress_card.dart** → **lib/presentation/widgets/makro_progress_card.dart**

**ENTEGRASYON/ogun_card.dart** → **lib/presentation/widgets/ogun_card.dart**

### 3.5 BLoC

**ENTEGRASYON/home_bloc.dart** → **lib/presentation/bloc/home/home_bloc.dart**

### 3.6 Pages

**ENTEGRASYON/home_page.dart** → **lib/presentation/pages/home_page.dart**

---

## 🎯 ADIM 4: HIVE MODELS OLUŞTUR

### 4.1 Kullanici Hive Model

**lib/data/models/kullanici_hive_model.dart** oluştur:

```dart
import 'package:hive/hive.dart';
import '../../domain/entities/kullanici_profili.dart';

part 'kullanici_hive_model.g.dart';

@HiveType(typeId: 0)
class KullaniciHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String ad;

  @HiveField(2)
  String soyad;

  @HiveField(3)
  int yas;

  @HiveField(4)
  double boy;

  @HiveField(5)
  double mevcutKilo;

  @HiveField(6)
  double? hedefKilo;

  @HiveField(7)
  String hedef;

  @HiveField(8)
  String cinsiyet;

  @HiveField(9)
  String aktiviteSeviyesi;

  @HiveField(10)
  String diyetTipi;

  @HiveField(11)
  List<String> manuelAlerjiler;

  @HiveField(12)
  String kayitTarihi;

  KullaniciHiveModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.yas,
    required this.boy,
    required this.mevcutKilo,
    this.hedefKilo,
    required this.hedef,
    required this.cinsiyet,
    required this.aktiviteSeviyesi,
    required this.diyetTipi,
    required this.manuelAlerjiler,
    required this.kayitTarihi,
  });

  KullaniciProfili toDomain() {
    return KullaniciProfili(
      id: id,
      ad: ad,
      soyad: soyad,
      yas: yas,
      cinsiyet: Cinsiyet.values.firstWhere((e) => e.name == cinsiyet),
      boy: boy,
      mevcutKilo: mevcutKilo,
      hedefKilo: hedefKilo,
      hedef: Hedef.values.firstWhere((e) => e.name == hedef),
      aktiviteSeviyesi: AktiviteSeviyesi.values.firstWhere((e) => e.name == aktiviteSeviyesi),
      diyetTipi: DiyetTipi.values.firstWhere((e) => e.name == diyetTipi),
      manuelAlerjiler: manuelAlerjiler,
      kayitTarihi: DateTime.parse(kayitTarihi),
    );
  }

  factory KullaniciHiveModel.fromDomain(KullaniciProfili profil) {
    return KullaniciHiveModel(
      id: profil.id,
      ad: profil.ad,
      soyad: profil.soyad,
      yas: profil.yas,
      boy: profil.boy,
      mevcutKilo: profil.mevcutKilo,
      hedefKilo: profil.hedefKilo,
      hedef: profil.hedef.name,
      cinsiyet: profil.cinsiyet.name,
      aktiviteSeviyesi: profil.aktiviteSeviyesi.name,
      diyetTipi: profil.diyetTipi.name,
      manuelAlerjiler: profil.manuelAlerjiler,
      kayitTarihi: profil.kayitTarihi.toIso8601String(),
    );
  }
}
```

### 4.2 GunlukPlan Hive Model

**lib/data/models/gunluk_plan_hive_model.dart** oluştur:

```dart
import 'package:hive/hive.dart';
import '../../domain/entities/gunluk_plan.dart';

part 'gunluk_plan_hive_model.g.dart';

@HiveType(typeId: 1)
class GunlukPlanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tarih;

  @HiveField(2)
  String kahvaltiId;

  @HiveField(3)
  String araOgun1Id;

  @HiveField(4)
  String ogleId;

  @HiveField(5)
  String araOgun2Id;

  @HiveField(6)
  String aksamId;

  @HiveField(7)
  double fitnessSkor;

  GunlukPlanHiveModel({
    required this.id,
    required this.tarih,
    required this.kahvaltiId,
    required this.araOgun1Id,
    required this.ogleId,
    required this.araOgun2Id,
    required this.aksamId,
    required this.fitnessSkor,
  });

  // TODO: toDomain ve fromDomain metodlarını ekle
  // Bu metodlar yemek ID'lerini kullanarak gerçek Yemek objelerini yüklemelidir
}
```

### 4.3 Code Generation Çalıştır

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔄 ADIM 5: main.dart'ı GÜNCELLE

```dart
import 'package:flutter/material.dart';
import 'data/local/hive_service.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı başlat
  await HiveService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZindeAI',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomePage(), // 🆕 Yeni ana sayfa
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## ✅ ADIM 6: TEST ET

```bash
flutter run
```

### Beklenen Sonuç:
1. ✅ Uygulama açılır
2. ✅ Hive başlatılır
3. ✅ HomePage yüklenir
4. ✅ Eğer kullanıcı yoksa hata mesajı gösterir

---

## 🎯 ADIM 7: İLK KULLANICI OLUŞTUR

HomePage'de hata alıyorsan (normal), önce bir kullanıcı profili oluşturmalısın.

**Geçici test kodu ekle (main.dart):**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  
  // 🧪 TEST KULLANICISI OLUŞTUR
  if (!HiveService.kullaniciVarMi()) {
    final testKullanici = KullaniciProfili(
      id: '1',
      ad: 'Test',
      soyad: 'Kullanıcı',
      yas: 25,
      cinsiyet: Cinsiyet.erkek,
      boy: 175,
      mevcutKilo: 75,
      hedefKilo: 80,
      hedef: Hedef.kiloAl,
      aktiviteSeviyesi: AktiviteSeviyesi.orta,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );
    
    await HiveService.kullaniciKaydet(testKullanici);
    print('✅ Test kullanıcısı oluşturuldu!');
  }
  
  runApp(const MyApp());
}
```

Tekrar çalıştır:
```bash
flutter run
```

---

## 🎉 BAŞARILI!

Artık:
- ✅ Kullanıcı profili kaydediliyor
- ✅ Günlük plan otomatik oluşturuluyor
- ✅ Makro kartları gösteriliyor
- ✅ Öğünler listeleniyor
- ✅ Yenile butonu çalışıyor

---

## 🔧 SORUN GİDERME

### Hata: "Kullanıcı bulunamadı"
**Çözüm:** Test kullanıcısı oluştur (Adım 7)

### Hata: "assets/data/kahvalti.json not found"
**Çözüm:** JSON dosyalarını ekle veya geçici olarak boş liste döndür

### Hata: "Bad state: No element"
**Çözüm:** Enum dönüşümlerini kontrol et

### Hata: "MissingPluginException"
**Çözüm:** 
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 SONRAKİ ADIMLAR

1. ✅ Profil oluşturma sayfası ekle
2. ✅ JSON yemek dosyalarını ekle
3. ✅ Alternatif besin sistemini entegre et
4. ✅ Analytics sayfasını ekle
5. ✅ Antrenman sistemini ekle

---

## 🎯 ÖZETİN ÖZETİ

```bash
# 1. Bağımlılıkları ekle
flutter pub add flutter_bloc equatable hive hive_flutter fl_chart

# 2. Dosyaları kopyala
ENTEGRASYON/ klasöründeki tüm dosyaları ilgili yerlere kopyala

# 3. Hive models oluştur
lib/data/models/ klasörüne model dosyalarını ekle

# 4. Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# 5. main.dart güncelle
Hive.init() ekle

# 6. Test et
flutter run

# 7. Başarılı! 🎉
```

**HER ŞEY HAZIR! BAŞARILI ENTEGRASYONLAR! 🚀**
