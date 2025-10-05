# 🚀 FAZ 6-10: KALAN FAZLARIN TAMAMLANMASI

Bu dokümanda FAZ 6'dan FAZ 10'a kadar tüm fazların kod örnekleri ve açıklamaları yer almaktadır.

---

## FAZ 6: LOCAL STORAGE (HIVE) - Hafta 3-4

### 6.1 Hive Setup

```dart
// pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

### 6.2 Hive Models

```dart
// lib/data/models/kullanici_hive_model.dart

import 'package:hive/hive.dart';

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
  String hedef; // enum string olarak

  @HiveField(8)
  String cinsiyet;

  @HiveField(9)
  String aktiviteSeviyesi;

  @HiveField(10)
  String diyetTipi;

  @HiveField(11)
  List<String> manuelAlerjiler;

  @HiveField(12)
  DateTime kayitTarihi;

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

  // Domain entity'ye dönüştürme
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
      kayitTarihi: kayitTarihi,
    );
  }

  // Domain entity'den oluşturma
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
      kayitTarihi: profil.kayitTarihi,
    );
  }
}
```

### 6.3 Hive Service

```dart
// lib/data/local/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _kullaniciBox = 'kullanici';
  static const String _planlarBox = 'planlar';
  static const String _antrenmanBox = 'antrenman';

  /// Hive'ı başlat
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapter'ları kaydet
    Hive.registerAdapter(KullaniciHiveModelAdapter());
    Hive.registerAdapter(GunlukPlanHiveModelAdapter());

    // Box'ları aç
    await Hive.openBox<KullaniciHiveModel>(_kullaniciBox);
    await Hive.openBox<GunlukPlanHiveModel>(_planlarBox);
  }

  /// Kullanıcı kaydet
  static Future<void> kullaniciKaydet(KullaniciProfili profil) async {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    final model = KullaniciHiveModel.fromDomain(profil);
    await box.put('aktif_kullanici', model);
    print('✅ Kullanıcı kaydedildi: ${profil.ad}');
  }

  /// Kullanıcı getir
  static KullaniciProfili? kullaniciGetir() {
    final box = Hive.box<KullaniciHiveModel>(_kullaniciBox);
    final model = box.get('aktif_kullanici');
    return model?.toDomain();
  }

  /// Plan kaydet
  static Future<void> planKaydet(GunlukPlan plan) async {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final model = GunlukPlanHiveModel.fromDomain(plan);
    await box.put(plan.tarih.toIso8601String(), model);
    print('✅ Plan kaydedildi: ${plan.tarih}');
  }

  /// Plan getir (tarihe göre)
  static GunlukPlan? planGetir(DateTime tarih) {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final model = box.get(tarih.toIso8601String());
    return model?.toDomain();
  }

  /// Son 30 günün planlarını getir
  static List<GunlukPlan> sonPlanlariGetir({int gun = 30}) {
    final box = Hive.box<GunlukPlanHiveModel>(_planlarBox);
    final simdi = DateTime.now();
    final baslangic = simdi.subtract(Duration(days: gun));

    return box.values
        .where((model) {
          final tarih = DateTime.parse(model.tarih);
          return tarih.isAfter(baslangic) && tarih.isBefore(simdi);
        })
        .map((model) => model.toDomain())
        .toList();
  }

  /// Tüm verileri sil
  static Future<void> tumVerileriSil() async {
    await Hive.box<KullaniciHiveModel>(_kullaniciBox).clear();
    await Hive.box<GunlukPlanHiveModel>(_planlarBox).clear();
    print('🗑️ Tüm veriler silindi');
  }
}
```

### 6.4 Kullanım

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı başlat
  await HiveService.init();
  
  runApp(MyApp());
}

// Profil kaydetme
final profil = KullaniciProfili(...);
await HiveService.kullaniciKaydet(profil);

// Profil okuma
final kayitliProfil = HiveService.kullaniciGetir();
if (kayitliProfil != null) {
  print('Hoş geldin ${kayitliProfil.ad}!');
}

// Plan kaydetme
final plan = GunlukPlan(...);
await HiveService.planKaydet(plan);

// Son 7 günün planları
final gecmisPlanlar = HiveService.sonPlanlariGetir(gun: 7);
```

---

## FAZ 7: UI COMPONENTS (WIDGETLAR) - Hafta 4

### 7.1 Makro Progress Card

```dart
// lib/presentation/widgets/makro_progress_card.dart

class MakroProgressCard extends StatelessWidget {
  final String baslik;
  final double mevcut;
  final double hedef;
  final Color renk;
  final String emoji;

  const MakroProgressCard({
    Key? key,
    required this.baslik,
    required this.mevcut,
    required this.hedef,
    required this.renk,
    required this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yuzde = (mevcut / hedef * 100).clamp(0, 100);
    final kalanMiktar = hedef - mevcut;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: renk.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                '${mevcut.toStringAsFixed(0)}/${hedef.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: renk,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: yuzde / 100,
              minHeight: 10,
              backgroundColor: renk.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(renk),
            ),
          ),

          const SizedBox(height: 8),

          // Yüzde ve kalan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${yuzde.toStringAsFixed(0)}% tamamlandı',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (kalanMiktar > 0)
                Text(
                  'Kalan: ${kalanMiktar.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 7.2 Öğün Card

```dart
// lib/presentation/widgets/ogun_card.dart

class OgunCard extends StatelessWidget {
  final Yemek yemek;
  final VoidCallback onTap;
  final bool secili;

  const OgunCard({
    Key? key,
    required this.yemek,
    required this.onTap,
    this.secili = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secili ? Colors.purple : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      yemek.ogun.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yemek.ad,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildMakroBadge('🔥', '${yemek.kalori.toStringAsFixed(0)} kcal'),
                          const SizedBox(width: 8),
                          _buildMakroBadge('💪', '${yemek.protein.toStringAsFixed(0)}g'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Seçim ikonu
                Icon(
                  secili ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: secili ? Colors.purple : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMakroBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## FAZ 8: ANA EKRANLAR (BLOC İLE) - Hafta 4-5

### 8.1 Home BLoC

```dart
// lib/presentation/bloc/home/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDailyPlan extends HomeEvent {}

class RefreshPlan extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final GunlukPlan plan;
  final MakroHedefleri hedefler;
  final KullaniciProfili kullanici;

  HomeLoaded({
    required this.plan,
    required this.hedefler,
    required this.kullanici,
  });

  @override
  List<Object?> get props => [plan, hedefler, kullanici];
}

class HomeError extends HomeState {
  final String mesaj;

  HomeError(this.mesaj);

  @override
  List<Object?> get props => [mesaj];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final OgunPlanlayici planlayici;
  final MakroHesapla makroHesaplama;

  HomeBloc({
    required this.planlayici,
    required this.makroHesaplama,
  }) : super(HomeInitial()) {
    on<LoadDailyPlan>(_onLoadDailyPlan);
    on<RefreshPlan>(_onRefreshPlan);
  }

  Future<void> _onLoadDailyPlan(
    LoadDailyPlan event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Kullanıcıyı getir
      final kullanici = HiveService.kullaniciGetir();
      if (kullanici == null) {
        emit(HomeError('Kullanıcı bulunamadı'));
        return;
      }

      // Makro hedeflerini hesapla
      final hedefler = makroHesaplama.tamHesaplama(kullanici);

      // Bugünün planını kontrol et
      final bugun = DateTime.now();
      var plan = HiveService.planGetir(bugun);

      // Plan yoksa yeni oluştur
      if (plan == null) {
        plan = await planlayici.gunlukPlanOlustur(
          hedefKalori: hedefler.gunlukKalori,
          hedefProtein: hedefler.gunlukProtein,
          hedefKarb: hedefler.gunlukKarbonhidrat,
          hedefYag: hedefler.gunlukYag,
          kisitlamalar: kullanici.tumKisitlamalar,
        );

        // Planı kaydet
        await HiveService.planKaydet(plan);
      }

      emit(HomeLoaded(
        plan: plan,
        hedefler: hedefler,
        kullanici: kullanici,
      ));
    } catch (e) {
      emit(HomeError('Plan yüklenirken hata: $e'));
    }
  }

  Future<void> _onRefreshPlan(
    RefreshPlan event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    emit(HomeLoading());

    try {
      // Yeni plan oluştur
      final yeniPlan = await planlayici.gunlukPlanOlustur(
        hedefKalori: currentState.hedefler.gunlukKalori,
        hedefProtein: currentState.hedefler.gunlukProtein,
        hedefKarb: currentState.hedefler.gunlukKarbonhidrat,
        hedefYag: currentState.hedefler.gunlukYag,
        kisitlamalar: currentState.kullanici.tumKisitlamalar,
      );

      // Planı kaydet
      await HiveService.planKaydet(yeniPlan);

      emit(HomeLoaded(
        plan: yeniPlan,
        hedefler: currentState.hedefler,
        kullanici: currentState.kullanici,
      ));
    } catch (e) {
      emit(HomeError('Plan yenilenirken hata: $e'));
    }
  }
}
```

### 8.2 Home Page

```dart
// lib/presentation/pages/home_page.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        planlayici: OgunPlanlayici(dataSource: YemekLocalDataSource()),
        makroHesaplama: MakroHesapla(),
      )..add(LoadDailyPlan()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ZindeAI'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Profil sayfasına git
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.mesaj),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(LoadDailyPlan());
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshPlan());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Makro kartları
                    MakroProgressCard(
                      baslik: 'Kalori',
                      mevcut: state.plan.toplamKalori,
                      hedef: state.hedefler.gunlukKalori,
                      renk: Colors.orange,
                      emoji: '🔥',
                    ),
                    MakroProgressCard(
                      baslik: 'Protein',
                      mevcut: state.plan.toplamProtein,
                      hedef: state.hedefler.gunlukProtein,
                      renk: Colors.red,
                      emoji: '💪',
                    ),
                    MakroProgressCard(
                      baslik: 'Karbonhidrat',
                      mevcut: state.plan.toplamKarbonhidrat,
                      hedef: state.hedefler.gunlukKarbonhidrat,
                      renk: Colors.amber,
                      emoji: '🍚',
                    ),
                    MakroProgressCard(
                      baslik: 'Yağ',
                      mevcut: state.plan.toplamYag,
                      hedef: state.hedefler.gunlukYag,
                      renk: Colors.green,
                      emoji: '🥑',
                    ),

                    const SizedBox(height: 24),

                    // Öğünler
                    Text(
                      'Bugünün Öğünleri',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    ...state.plan.tumOgunler.map((ogun) {
                      return OgunCard(
                        yemek: ogun,
                        onTap: () {
                          // Öğün detayı göster
                        },
                      );
                    }),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<HomeBloc>().add(RefreshPlan());
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
```

---

## FAZ 9: ANTRENMAN SİSTEMİ - Hafta 5-6

### 9.1 Antrenman Modeli

```dart
// lib/domain/entities/antrenman.dart

class Egzersiz {
  final String id;
  final String ad;
  final int sure; // saniye
  final int kalori;
  final String videoUrl;
  final Zorluk zorluk;
  final String aciklama;

  const Egzersiz({
    required this.id,
    required this.ad,
    required this.sure,
    required this.kalori,
    required this.videoUrl,
    required this.zorluk,
    required this.aciklama,
  });
}

class AntrenmanProgrami {
  final String id;
  final String ad;
  final List<Egzersiz> egzersizler;
  final Zorluk zorluk;

  const AntrenmanProgrami({
    required this.id,
    required this.ad,
    required this.egzersizler,
    required this.zorluk,
  });

  int get toplamSure => egzersizler.fold(0, (sum, e) => sum + e.sure);
  int get toplamKalori => egzersizler.fold(0, (sum, e) => sum + e.kalori);
}
```

---

## FAZ 10: ANALYTICS VE GRAFİKLER - Hafta 6

### 10.1 Analytics BLoC

```dart
// lib/presentation/bloc/analytics/analytics_bloc.dart

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    try {
      // Son 30 günün planlarını al
      final planlar = HiveService.sonPlanlariGetir(gun: 30);

      // İstatistikler hesapla
      final ortalama Kalori = planlar.fold(0.0, (sum, p) => sum + p.toplamKalori) / planlar.length;
      final ortalamaProtein = planlar.fold(0.0, (sum, p) => sum + p.toplamProtein) / planlar.length;

      emit(AnalyticsLoaded(
        planlar: planlar,
        ortalamaKalori: ortalamaKalori,
        ortalamaProtein: ortalamaProtein,
      ));
    } catch (e) {
      emit(AnalyticsError('İstatistikler yüklenirken hata: $e'));
    }
  }
}
```

### 10.2 Grafikler (FL Chart)

```dart
// lib/presentation/widgets/makro_chart.dart

import 'package:fl_chart/fl_chart.dart';

class MakroChart extends StatelessWidget {
  final List<GunlukPlan> planlar;

  const MakroChart({Key? key, required this.planlar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // Protein çizgisi
          LineChartBarData(
            spots: _getProteinSpots(),
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          // Karbonhidrat çizgisi
          LineChartBarData(
            spots: _getCarbSpots(),
            color: Colors.amber,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getProteinSpots() {
    return planlar.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toplamProtein);
    }).toList();
  }

  List<FlSpot> _getCarbSpots() {
    return planlar.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toplamKarbonhidrat);
    }).toList();
  }
}
```

---

## ✅ SONUÇ

Bu dokümanda FAZ 6-10 için kod örnekleri ve açıklamalar yer almaktadır:

- ✅ FAZ 6: Hive ile local storage
- ✅ FAZ 7: UI widget'ları (MakroProgressCard, OgunCard)
- ✅ FAZ 8: BLoC pattern ile ana ekranlar
- ✅ FAZ 9: Antrenman sistemi modelleri
- ✅ FAZ 10: Analytics ve grafikler

Her faz için detaylı kodlar ve açıklamalar verilmiştir.
