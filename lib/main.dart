import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/local/hive_service.dart';
import 'data/datasources/yemek_hive_data_source.dart';
import 'domain/usecases/ogun_planlayici.dart';
import 'domain/usecases/makro_hesapla.dart';
import 'domain/entities/makro_hedefleri.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';
import 'presentation/bloc/home/home_state.dart';
import 'presentation/widgets/makro_progress_card.dart';
import 'presentation/widgets/ogun_card.dart';
import 'presentation/pages/home_page_yeni.dart';
import 'domain/entities/hedef.dart';
import 'domain/entities/kullanici_profili.dart';
import 'core/utils/app_logger.dart';

// ============================================================================
// MAKRO HESAPLAMA EKRANI - DİNAMİK GÜNCELLEME + ALERJİ SİSTEMİ
// ============================================================================

class MacroCalculatorPage extends StatefulWidget {
  const MacroCalculatorPage({Key? key}) : super(key: key);

  @override
  State<MacroCalculatorPage> createState() => _MacroCalculatorPageState();
}

class _MacroCalculatorPageState extends State<MacroCalculatorPage> {
  final _hesaplama = MakroHesapla();
  final _yasController = TextEditingController(text: '25');
  final _boyController = TextEditingController(text: '180');
  final _kiloController = TextEditingController(text: '73');
  final _hedefKiloController = TextEditingController(text: '80');
  final _alerjiController = TextEditingController();

  Cinsiyet _cinsiyet = Cinsiyet.erkek;
  Hedef _hedef = Hedef.kasKazanKiloAl;
  AktiviteSeviyesi _aktivite = AktiviteSeviyesi.ortaAktif;
  DiyetTipi _diyetTipi = DiyetTipi.normal;
  List<String> _manuelAlerjiler = [];

  MakroHedefleri? _sonuc;

  @override
  void initState() {
    super.initState();
    _hesapla(); // ⭐ İlk yüklemede hesapla

    // ⭐ DİNAMİK GÜNCELLEME: Her değişiklikte yeniden hesapla
    _yasController.addListener(_hesapla);
    _boyController.addListener(_hesapla);
    _kiloController.addListener(_hesapla);
  }

  @override
  void dispose() {
    _yasController.dispose();
    _boyController.dispose();
    _kiloController.dispose();
    _hedefKiloController.dispose();
    _alerjiController.dispose();
    super.dispose();
  }

  // ⭐ DİNAMİK HESAPLAMA
  void _hesapla() {
    final yas = int.tryParse(_yasController.text) ?? 25;
    final boy = double.tryParse(_boyController.text) ?? 180;
    final kilo = double.tryParse(_kiloController.text) ?? 73;

    if (yas > 0 && boy > 0 && kilo > 0) {
      // Geçici profil oluştur (hesaplama için)
      final tempProfil = KullaniciProfili(
        id: 'temp',
        ad: 'Temp',
        soyad: 'User',
        yas: yas,
        cinsiyet: _cinsiyet,
        boy: boy,
        mevcutKilo: kilo,
        hedef: _hedef,
        aktiviteSeviyesi: _aktivite,
        diyetTipi: _diyetTipi,
        manuelAlerjiler: _manuelAlerjiler,
        kayitTarihi: DateTime.now(),
      );

      setState(() {
        _sonuc = _hesaplama.tamHesaplama(tempProfil);
      });

      // Debug log
      print(
          '🔄 Yeniden hesaplandı: ${_sonuc?.gunlukKalori.toStringAsFixed(0)} kcal');
    }
  }

  // ⭐ ALERJİ EKLEME
  void _alerjiEkle() {
    final alerji = _alerjiController.text.trim();
    if (alerji.isNotEmpty && !_manuelAlerjiler.contains(alerji)) {
      setState(() {
        _manuelAlerjiler.add(alerji);
        _alerjiController.clear();
      });
    }
  }

  // ⭐ ALERJİ SİLME
  void _alerjiSil(String alerji) {
    setState(() {
      _manuelAlerjiler.remove(alerji);
    });
  }

  // ⭐ TÜM KISITLAMALAR
  List<String> get _tumKisitlamalar {
    final Set<String> kisitlamalar = {};
    kisitlamalar.addAll(_diyetTipi.varsayilanKisitlamalar);
    kisitlamalar.addAll(_manuelAlerjiler);
    return kisitlamalar.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text('ZindeAI - Makro Hesaplama'),
        backgroundColor: Colors.purple.shade200,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KİŞİSEL BİLGİLER
            _buildCard(
              title: 'Kişisel Bilgiler',
              icon: Icons.person,
              children: [
                _buildDropdown(
                  label: 'Cinsiyet',
                  value: _cinsiyet,
                  items: Cinsiyet.values,
                  onChanged: (val) {
                    setState(() => _cinsiyet = val!);
                    _hesapla();
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _yasController,
                  label: 'Yaş',
                  suffix: 'yıl',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _boyController,
                  label: 'Boy',
                  suffix: 'cm',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _kiloController,
                  label: 'Mevcut Kilo',
                  suffix: 'kg',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _hedefKiloController,
                  label: 'Hedef Kilo (Opsiyonel)',
                  suffix: 'kg',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // HEDEF VE AKTİVİTE
            _buildCard(
              title: 'Hedef ve Aktivite',
              icon: Icons.flag,
              children: [
                _buildDropdown(
                  label: 'Hedefiniz',
                  value: _hedef,
                  items: Hedef.values,
                  onChanged: (val) {
                    setState(() => _hedef = val!);
                    _hesapla();
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Aktivite Seviyesi',
                  value: _aktivite,
                  items: AktiviteSeviyesi.values,
                  onChanged: (val) {
                    setState(() => _aktivite = val!);
                    _hesapla();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ⭐ DİYET VE ALERJİLER
            _buildCard(
              title: 'Diyet ve Alerjiler',
              icon: Icons.restaurant_menu,
              children: [
                _buildDropdown(
                  label: 'Diyet Tipi',
                  value: _diyetTipi,
                  items: DiyetTipi.values,
                  onChanged: (val) {
                    setState(() => _diyetTipi = val!);
                  },
                ),

                const SizedBox(height: 16),

                // Otomatik kısıtlamalar
                if (_diyetTipi.varsayilanKisitlamalar.isNotEmpty) ...[
                  Text(
                    '🚫 Otomatik Kısıtlamalar (${_diyetTipi.aciklama}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _diyetTipi.varsayilanKisitlamalar
                        .map((k) => Chip(
                              label: Text(k),
                              backgroundColor: Colors.orange.shade100,
                              avatar: const Icon(Icons.block, size: 16),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Manuel alerji ekleme
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _alerjiController,
                        decoration: InputDecoration(
                          labelText: 'Manuel Alerji/Kısıtlama Ekle',
                          hintText: 'örn: Ceviz, Fındık, Soya',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _alerjiEkle(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _alerjiEkle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),

                // Eklenen alerjiler
                if (_manuelAlerjiler.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '⚠️ Manuel Alerjiler:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _manuelAlerjiler
                        .map((a) => Chip(
                              label: Text(a),
                              backgroundColor: Colors.red.shade100,
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _alerjiSil(a),
                            ))
                        .toList(),
                  ),
                ],

                // Tüm kısıtlamalar özeti
                if (_tumKisitlamalar.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Toplam ${_tumKisitlamalar.length} Kısıtlama',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tumKisitlamalar.join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // SONUÇLAR
            if (_sonuc != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade100, Colors.green.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Makrolar Hesaplandı!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMakroCard(
                      '🔥 Günlük Kalori',
                      '${_sonuc!.gunlukKalori.toStringAsFixed(0)} kcal',
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildMakroCard(
                      '💪 Protein',
                      '${_sonuc!.gunlukProtein.toStringAsFixed(0)} g',
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildMakroCard(
                      '🍚 Karbonhidrat',
                      '${_sonuc!.gunlukKarbonhidrat.toStringAsFixed(0)} g',
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildMakroCard(
                      '🥑 Yağ',
                      '${_sonuc!.gunlukYag.toStringAsFixed(0)} g',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        String text = '';
        if (item is Cinsiyet) text = item.aciklama;
        if (item is Hedef) text = item.aciklama;
        if (item is AktiviteSeviyesi) text = item.aciklama;
        if (item is DiyetTipi) text = item.aciklama;

        return DropdownMenuItem<T>(
          value: item,
          child: Text(text),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMakroCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MAIN - HIVE + BLOC ENTEGRASYONLYu
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  try {
    await HiveService.init();
    AppLogger.info('✅ Hive başarıyla başlatıldı');
  } catch (e) {
    AppLogger.error('❌ Hive başlatma hatası: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZindeAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const YeniHomePage(),
    );
  }
}

// ============================================================================
// HOME PAGE - GÜNLÜK PLAN EKRANI (BLOC ENTEGRASYONLU)
// ============================================================================

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        planlayici: OgunPlanlayici(
          dataSource: YemekHiveDataSource(),
        ),
        makroHesaplama: MakroHesapla(),
      )..add(LoadHomePage()),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ZindeAI - Günlük Plan'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil & Makro Hesaplama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MacroCalculatorPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? 'Yükleniyor...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Demo kullanıcı oluştur
                        _createDemoUser(context);
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Demo Kullanıcı Oluştur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(RefreshDailyPlan());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Kullanıcı bilgisi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            state.kullanici.ad[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merhaba ${state.kullanici.ad}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Hedef: ${state.kullanici.hedef.aciklama}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Fitness',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                state.plan.fitnessSkoru.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Makro progress kartları
                  Text(
                    'Günlük Makrolar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bugünün Öğünleri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(RefreshDailyPlan(forceRegenerate: true));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yenile'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Haftalık plan oluştur
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Haftalik Plan Olustur'),
                                  content: const Text(
                                    '7 gunluk haftalik plan olusturulsun mu? Bu islem birkac dakika surebilir.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('İptal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        context.read<HomeBloc>().add(
                                              GenerateWeeklyPlan(
                                                  forceRegenerate: true),
                                            );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Oluştur'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('7 Günlük Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...state.plan.ogunler.map((yemek) {
                    return OgunCard(
                      yemek: yemek,
                      onTap: () {
                        context
                            .read<HomeBloc>()
                            .add(ToggleMealCompletion(yemek.id));
                      },
                    );
                  }),

                  const SizedBox(height: 80),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _createDemoUser(BuildContext context) async {
    // Demo kullanıcı oluştur
    final demoUser = KullaniciProfili(
      id: 'demo_user',
      ad: 'Ahmet',
      soyad: 'Yılmaz',
      yas: 25,
      cinsiyet: Cinsiyet.erkek,
      boy: 180,
      mevcutKilo: 75,
      hedefKilo: 80,
      hedef: Hedef.kasKazanKiloAl,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    await HiveService.kullaniciKaydet(demoUser);

    if (context.mounted) {
      context.read<HomeBloc>().add(LoadHomePage());
    }
  }
}
