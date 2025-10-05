# 🎯 ZİNDEAI - KALAN FAZLAR (4-10) ROADMAP

## ✅ TAMAMLANAN FAZLAR

- ✅ FAZ 1: Proje Mimarisi ve Logger
- ✅ FAZ 2: Hedef Sistemi ve Entity'ler
- ✅ FAZ 3: Makro Hesaplama Motoru + Alerji Sistemi
- ✅ BONUS: Alternatif Besin Önerisi Sistemi

---

## 🚀 FAZ 4: YEMEK ENTITY'LERİ VE JSON PARSER (Hafta 2-3)

### 4.1 Yemek Modeli

```dart
// domain/entities/yemek.dart

enum OgunTipi {
  kahvalti,
  araOgun1,
  ogle,
  araOgun2,
  aksam,
  geceAtistirma,
  cheatMeal
}

enum Zorluk {
  kolay,
  orta,
  zor
}

class Yemek extends Equatable {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final List<AlternatifBesin> alternatifler; // ⭐ Bonus özellik
  final int hazirlamaSuresi; // dakika
  final Zorluk zorluk;
  final List<String> etiketler; // ['vejetaryen', 'glutensiz']
  final String? tarif;
  final String? gorselUrl;

  // Makro uyumu kontrolü
  bool makroyaUygunMu(MakroHedefleri hedefler, double tolerans) {
    final kaloriFark = (kalori - hedefler.gunlukKalori / 5).abs();
    return kaloriFark <= hedefler.gunlukKalori * tolerans;
  }

  // Kısıtlama kontrolü (alerji, vegan vb)
  bool kisitlamayaUygunMu(List<String> kisitlamalar) {
    for (final kisitlama in kisitlamalar) {
      if (malzemeler.any((m) => m.toLowerCase().contains(kisitlama.toLowerCase()))) {
        return false;
      }
    }
    return true;
  }
}
```

### 4.2 JSON Parser

```dart
// data/datasources/yemek_local_data_source.dart

class YemekLocalDataSource {
  Future<List<Yemek>> yemekleriYukle(OgunTipi ogun) async {
    final jsonString = await rootBundle.loadString('assets/data/${ogun.name}.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Yemek.fromJson(json)).toList();
  }

  // Tüm öğünleri paralel yükle
  Future<Map<OgunTipi, List<Yemek>>> tumYemekleriYukle() async {
    final futures = OgunTipi.values.map((ogun) async {
      final yemekler = await yemekleriYukle(ogun);
      return MapEntry(ogun, yemekler);
    });
    
    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }
}
```

### 4.3 Test

```dart
void main() async {
  final dataSource = YemekLocalDataSource();
  final kahvaltilar = await dataSource.yemekleriYukle(OgunTipi.kahvalti);
  
  AppLogger.info('FAZ 4 TAMAMLANDI: ${kahvaltilar.length} kahvaltı yüklendi');
  AppLogger.debug('İlk kahvaltı: ${kahvaltilar.first.ad}');
}
```

---

## 🚀 FAZ 5: AKILLI ÖĞÜN EŞLEŞTİRME ALGORİTMASI (Hafta 3)

### 5.1 Akıllı Öğün Planlayıcı

```dart
// domain/usecases/ogun_planla.dart

class OgunPlanlayici {
  final YemekLocalDataSource dataSource;
  
  /// Günlük öğün planı oluştur
  Future<GunlukPlan> gunlukPlanOlustur({
    required MakroHedefleri hedefler,
    required List<String> kisitlamalar,
    required List<String> tercihler,
  }) async {
    // 1. Tüm yemekleri yükle
    final tumYemekler = await dataSource.tumYemekleriYukle();
    
    // 2. Kısıtlamalara göre filtrele
    final uygunYemekler = _kisitlamalariFiltrele(tumYemekler, kisitlamalar);
    
    // 3. Genetik algoritma ile en iyi kombinasyonu bul
    final plan = _genetikAlgoritmaIleEslestir(
      yemekler: uygunYemekler,
      hedefKalori: hedefler.gunlukKalori,
      hedefProtein: hedefler.gunlukProtein,
      hedefKarb: hedefler.gunlukKarbonhidrat,
      hedefYag: hedefler.gunlukYag,
    );
    
    return plan;
  }
  
  /// Genetik algoritma ile eşleştirme
  GunlukPlan _genetikAlgoritmaIleEslestir({
    required Map<OgunTipi, List<Yemek>> yemekler,
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
  }) {
    // 1. Rastgele popülasyon oluştur
    List<GunlukPlan> populasyon = List.generate(100, (_) {
      return _rastgelePlanOlustur(yemekler);
    });
    
    // 2. 50 jenerasyon boyunca evrimleştir
    for (int jenerasyon = 0; jenerasyon < 50; jenerasyon++) {
      // Fitness hesapla
      populasyon.sort((a, b) {
        final fitnessA = _fitnessHesapla(a, hedefKalori, hedefProtein, hedefKarb, hedefYag);
        final fitnessB = _fitnessHesapla(b, hedefKalori, hedefProtein, hedefKarb, hedefYag);
        return fitnessB.compareTo(fitnessA); // Yüksek fitness önce
      });
      
      // En iyi %20'yi seç
      final enIyiler = populasyon.take(20).toList();
      
      // Yeni nesil oluştur
      populasyon = [];
      for (int i = 0; i < 100; i++) {
        final parent1 = enIyiler[Random().nextInt(enIyiler.length)];
        final parent2 = enIyiler[Random().nextInt(enIyiler.length)];
        final cocuk = _caprazla(parent1, parent2);
        final mutasyon = _mutasyonUygula(cocuk, yemekler);
        populasyon.add(mutasyon);
      }
    }
    
    // En iyi planı döndür
    return populasyon.first;
  }
  
  /// Fitness fonksiyonu (0-100 arası skor)
  double _fitnessHesapla(
    GunlukPlan plan,
    double hedefKalori,
    double hedefProtein,
    double hedefKarb,
    double hedefYag,
  ) {
    final toplamKalori = plan.toplamKalori;
    final toplamProtein = plan.toplamProtein;
    final toplamKarb = plan.toplamKarbonhidrat;
    final toplamYag = plan.toplamYag;
    
    // Sapma hesapla (0-1 arası, 0 mükemmel)
    final kaloriSapma = (toplamKalori - hedefKalori).abs() / hedefKalori;
    final proteinSapma = (toplamProtein - hedefProtein).abs() / hedefProtein;
    final karbSapma = (toplamKarb - hedefKarb).abs() / hedefKarb;
    final yagSapma = (toplamYag - hedefYag).abs() / hedefYag;
    
    // Ağırlıklı ortalama
    final toplamSapma = (
      kaloriSapma * 0.4 +
      proteinSapma * 0.3 +
      karbSapma * 0.2 +
      yagSapma * 0.1
    );
    
    // Fitness: 0 sapma = 100 skor, 1 sapma = 0 skor
    return (1 - toplamSapma.clamp(0, 1)) * 100;
  }
}
```

### 5.2 Test

```dart
void main() async {
  final planlayici = OgunPlanlayici();
  
  final hedefler = MakroHedefleri(
    gunlukKalori: 2500,
    gunlukProtein: 150,
    gunlukKarbonhidrat: 300,
    gunlukYag: 80,
  );
  
  final plan = await planlayici.gunlukPlanOlustur(
    hedefler: hedefler,
    kisitlamalar: ['Süt', 'Yumurta'],
    tercihler: ['Tavuk', 'Pirinç'],
  );
  
  AppLogger.info('FAZ 5 TAMAMLANDI');
  AppLogger.debug('Günlük Plan: ${plan.ogunler.map((o) => o.ad).join(', ')}');
  AppLogger.debug('Toplam Kalori: ${plan.toplamKalori} (Hedef: 2500)');
  AppLogger.debug('Fitness Skoru: ${plan.fitnessSkor}/100');
}
```

---

## 🚀 FAZ 6: LOCAL STORAGE (HIVE) (Hafta 3-4)

### 6.1 Hive Setup

```dart
// data/models/kullanici_model.dart

@HiveType(typeId: 0)
class KullaniciModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String ad;
  
  @HiveField(2)
  int yas;
  
  @HiveField(3)
  double kilo;
  
  @HiveField(4)
  List<String> manuelAlerjiler;
  
  // ... diğer alanlar
}

// data/local/hive_service.dart

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(KullaniciModelAdapter());
    await Hive.openBox<KullaniciModel>('kullanici');
    await Hive.openBox<GunlukPlanModel>('planlar');
  }
  
  static Future<void> kullaniciKaydet(KullaniciModel kullanici) async {
    final box = Hive.box<KullaniciModel>('kullanici');
    await box.put('aktif_kullanici', kullanici);
  }
  
  static KullaniciModel? kullaniciGetir() {
    final box = Hive.box<KullaniciModel>('kullanici');
    return box.get('aktif_kullanici');
  }
}
```

### 6.2 Test

```dart
void main() async {
  await HiveService.init();
  
  final kullanici = KullaniciModel(
    id: '1',
    ad: 'Ahmet',
    yas: 25,
    kilo: 75,
    manuelAlerjiler: ['Ceviz'],
  );
  
  await HiveService.kullaniciKaydet(kullanici);
  
  final kayitli = HiveService.kullaniciGetir();
  AppLogger.info('FAZ 6 TAMAMLANDI: ${kayitli?.ad} kaydedildi');
}
```

---

## 🚀 FAZ 7: UI COMPONENTS (WIDGETLAR) (Hafta 4)

### 7.1 Widget Listesi

```dart
// presentation/widgets/makro_progress_card.dart
class MakroProgressCard extends StatelessWidget {
  final String baslik;
  final double mevcut;
  final double hedef;
  final Color renk;
  
  @override
  Widget build(BuildContext context) {
    final yuzde = (mevcut / hedef * 100).clamp(0, 100);
    
    return Card(
      child: Column(
        children: [
          Text('$baslik: ${mevcut.toStringAsFixed(0)}/${hedef.toStringAsFixed(0)}g'),
          LinearProgressIndicator(
            value: yuzde / 100,
            backgroundColor: renk.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(renk),
          ),
          Text('${yuzde.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

// presentation/widgets/ogun_card.dart
class OgunCard extends StatelessWidget {
  final Yemek yemek;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(yemek.ogun.emoji)),
        title: Text(yemek.ad),
        subtitle: Text('${yemek.kalori.toStringAsFixed(0)} kcal'),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: onTap,
        ),
      ),
    );
  }
}
```

---

## 🚀 FAZ 8: ANA EKRANLAR (BLOC İLE) (Hafta 4-5)

### 8.1 BLoC Pattern

```dart
// presentation/bloc/home/home_bloc.dart

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadDailyPlan>(_onLoadDailyPlan);
    on<AddMeal>(_onAddMeal);
  }
  
  Future<void> _onLoadDailyPlan(LoadDailyPlan event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    
    try {
      final kullanici = HiveService.kullaniciGetir();
      final hedefler = MakroHesapla().tamHesaplama(kullanici);
      final plan = await OgunPlanlayici().gunlukPlanOlustur(hedefler: hedefler);
      
      emit(HomeLoaded(plan: plan, hedefler: hedefler));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

// presentation/pages/home_page.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (state is HomeLoaded) {
          return Column(
            children: [
              MakroProgressCard(...),
              Expanded(
                child: ListView(
                  children: state.plan.ogunler.map((ogun) {
                    return OgunCard(yemek: ogun, onTap: () {...});
                  }).toList(),
                ),
              ),
            ],
          );
        }
        
        return Center(child: Text('Hata'));
      },
    );
  }
}
```

---

## 🚀 FAZ 9: ANTRENMAN SİSTEMİ (Hafta 5-6)

### 9.1 Antrenman Modeli

```dart
class Egzersiz {
  final String ad;
  final int sure; // saniye
  final int kalori;
  final String videoUrl;
  final Zorluk zorluk;
}

class AntrenmanProgrami {
  final String ad;
  final List<Egzersiz> egzersizler;
  final int toplamSure;
  final int toplamKalori;
}

class AntrenmanTakip {
  final DateTime tarih;
  final AntrenmanProgrami program;
  final bool tamamlandi;
  final int tamamlananEgzersizSayisi;
}
```

---

## 🚀 FAZ 10: ANALYTICS VE GRAFİKLER (Hafta 6)

### 10.1 İstatistikler

```dart
// FL Chart ile grafikler

class MacroChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _getProteinData(),
            colors: [Colors.red],
          ),
          LineChartBarData(
            spots: _getCarbData(),
            colors: [Colors.amber],
          ),
        ],
      ),
    );
  }
}

class WeightProgressChart extends StatelessWidget {
  // 30 günlük kilo takibi grafiği
}
```

---

## 📦 TOPLAM PROJE YAPISI

```
zinde_ai/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── utils/
│   │   └── network/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── yemek_local_data_source.dart
│   │   │   └── antrenman_data_source.dart
│   │   ├── models/
│   │   │   ├── kullanici_model.dart (Hive)
│   │   │   ├── yemek_model.dart
│   │   │   └── antrenman_model.dart
│   │   ├── repositories/
│   │   │   └── yemek_repository_impl.dart
│   │   └── local/
│   │       └── hive_service.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── kullanici_profili.dart
│   │   │   ├── makro_hedefleri.dart
│   │   │   ├── yemek.dart
│   │   │   └── alternatif_besin.dart
│   │   ├── repositories/
│   │   │   └── yemek_repository.dart
│   │   └── usecases/
│   │       ├── makro_hesapla.dart
│   │       ├── ogun_planla.dart
│   │       └── alternatif_oner.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── home/
│       │   ├── profile/
│       │   └── analytics/
│       ├── pages/
│       │   ├── home_page.dart
│       │   ├── meal_detail_page.dart
│       │   ├── profile_page.dart
│       │   └── analytics_page.dart
│       └── widgets/
│           ├── makro_progress_card.dart
│           ├── ogun_card.dart
│           └── alternatif_besin_bottom_sheet.dart
├── assets/
│   ├── data/
│   │   ├── kahvalti.json
│   │   ├── ara_ogun_1.json
│   │   └── ...
│   └── videos/
│       └── egzersizler/
└── test/
```

---

## ✅ SON DURUM

**Tamamlanan:**
- ✅ FAZ 1-3: Temel mimari, makro hesaplama, alerji sistemi
- ✅ BONUS: Alternatif besin önerisi sistemi

**Kalan:**
- ⏳ FAZ 4: Yemek Entity'leri
- ⏳ FAZ 5: Akıllı Öğün Eşleştirme
- ⏳ FAZ 6: Hive Storage
- ⏳ FAZ 7: UI Components
- ⏳ FAZ 8: Ana Ekranlar (BLoC)
- ⏳ FAZ 9: Antrenman Sistemi
- ⏳ FAZ 10: Analytics

**Sonraki adım:** FAZ 4'ü başlat! 🚀
