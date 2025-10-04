import 'package:flutter/material.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum Hedef {
  kiloVer('Kilo Ver'),
  kiloAl('Kilo Al'),
  formdaKal('Formda Kal'),
  kasKazanKiloAl('Kas Kazan + Kilo Al'),
  kasKazanKiloVer('Kas Kazan + Kilo Ver');

  final String aciklama;
  const Hedef(this.aciklama);
}

enum AktiviteSeviyesi {
  hareketsiz('Hareketsiz (Ofis işi)'),
  hafifAktif('Hafif Aktif (Haftada 1-3 gün)'),
  ortaAktif('Orta Aktif (Haftada 3-5 gün)'),
  cokAktif('Çok Aktif (Haftada 6-7 gün)'),
  ekstraAktif('Ekstra Aktif (Günde 2 antrenman)');

  final String aciklama;
  const AktiviteSeviyesi(this.aciklama);
}

enum Cinsiyet {
  erkek('Erkek'),
  kadin('Kadın');

  final String aciklama;
  const Cinsiyet(this.aciklama);
}

enum DiyetTipi {
  normal('Normal'),
  vejetaryen('Vejetaryen'),
  vegan('Vegan');

  final String aciklama;
  const DiyetTipi(this.aciklama);

  List<String> get varsayilanKisitlamalar {
    switch (this) {
      case DiyetTipi.vejetaryen:
        return ['Et', 'Tavuk', 'Balık', 'Deniz Ürünleri'];
      case DiyetTipi.vegan:
        return [
          'Et',
          'Tavuk',
          'Balık',
          'Deniz Ürünleri',
          'Süt',
          'Peynir',
          'Yoğurt',
          'Yumurta',
          'Bal'
        ];
      case DiyetTipi.normal:
        return [];
    }
  }
}

// ============================================================================
// MAKRO HEDEFLERİ
// ============================================================================

class MakroHedefleri {
  final double gunlukKalori;
  final double gunlukProtein;
  final double gunlukKarbonhidrat;
  final double gunlukYag;

  const MakroHedefleri({
    required this.gunlukKalori,
    required this.gunlukProtein,
    required this.gunlukKarbonhidrat,
    required this.gunlukYag,
  });
}

// ============================================================================
// MAKRO HESAPLAMA SERVİSİ
// ============================================================================

class MakroHesapla {
  double bmrHesapla({
    required double kilo,
    required double boy,
    required int yas,
    required Cinsiyet cinsiyet,
  }) {
    if (cinsiyet == Cinsiyet.erkek) {
      return (10 * kilo) + (6.25 * boy) - (5 * yas) + 5;
    } else {
      return (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    }
  }

  double tdeeHesapla(double bmr, AktiviteSeviyesi aktivite) {
    final carpanlar = {
      AktiviteSeviyesi.hareketsiz: 1.2,
      AktiviteSeviyesi.hafifAktif: 1.375,
      AktiviteSeviyesi.ortaAktif: 1.55,
      AktiviteSeviyesi.cokAktif: 1.725,
      AktiviteSeviyesi.ekstraAktif: 1.9,
    };
    return bmr * (carpanlar[aktivite] ?? 1.2);
  }

  double hedefKaloriHesapla(double tdee, Hedef hedef) {
    switch (hedef) {
      case Hedef.kiloVer:
        return tdee * 0.80;
      case Hedef.kasKazanKiloVer:
        return tdee * 0.85;
      case Hedef.formdaKal:
        return tdee;
      case Hedef.kiloAl:
        return tdee * 1.10;
      case Hedef.kasKazanKiloAl:
        return tdee * 1.15;
    }
  }

  MakroHedefleri makroDagilimHesapla({
    required double hedefKalori,
    required double mevcutKilo,
    required Hedef hedef,
  }) {
    double protein, yag, karbonhidrat;

    switch (hedef) {
      case Hedef.kiloVer:
        protein = mevcutKilo * 2.2;
        yag = mevcutKilo * 0.8;
        break;
      case Hedef.kasKazanKiloVer:
        protein = mevcutKilo * 2.5;
        yag = mevcutKilo * 0.7;
        break;
      case Hedef.formdaKal:
        protein = mevcutKilo * 2.0;
        yag = mevcutKilo * 1.0;
        break;
      case Hedef.kiloAl:
        protein = mevcutKilo * 2.0;
        yag = mevcutKilo * 1.1;
        break;
      case Hedef.kasKazanKiloAl:
        protein = mevcutKilo * 2.2;
        yag = mevcutKilo * 1.2;
        break;
    }

    final proteinKalori = protein * 4;
    final yagKalori = yag * 9;
    final kalanKalori = hedefKalori - proteinKalori - yagKalori;
    karbonhidrat = kalanKalori / 4;

    if (karbonhidrat < 50) {
      karbonhidrat = 100;
      yag = (hedefKalori - (protein * 4) - (karbonhidrat * 4)) / 9;
    }

    return MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: protein.clamp(0, 999),
      gunlukKarbonhidrat: karbonhidrat.clamp(50, 999),
      gunlukYag: yag.clamp(0, 999),
    );
  }

  MakroHedefleri tamHesaplama({
    required double kilo,
    required double boy,
    required int yas,
    required Cinsiyet cinsiyet,
    required AktiviteSeviyesi aktivite,
    required Hedef hedef,
  }) {
    final bmr = bmrHesapla(
      kilo: kilo,
      boy: boy,
      yas: yas,
      cinsiyet: cinsiyet,
    );
    final tdee = tdeeHesapla(bmr, aktivite);
    final hedefKalori = hedefKaloriHesapla(tdee, hedef);
    return makroDagilimHesapla(
      hedefKalori: hedefKalori,
      mevcutKilo: kilo,
      hedef: hedef,
    );
  }
}

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
      setState(() {
        _sonuc = _hesaplama.tamHesaplama(
          kilo: kilo,
          boy: boy,
          yas: yas,
          cinsiyet: _cinsiyet,
          aktivite: _aktivite,
          hedef: _hedef,
        );
      });

      // Debug log
      print('🔄 Yeniden hesaplandı: ${_sonuc?.gunlukKalori.toStringAsFixed(0)} kcal');
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
                            Icon(Icons.info_outline, color: Colors.amber.shade700),
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
                      color: Colors.green.withOpacity(0.3),
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
            color: Colors.black.withOpacity(0.05),
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
      value: value,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
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
      home: const MacroCalculatorPage(),
    );
  }
}
