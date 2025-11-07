// ============================================================================
// lib/presentation/pages/haftalik_rapor_page.dart
// HAFTALİK DETAYLI YEMEK UYUM RAPORU SAYFASI
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/services/haftalik_rapor_servisi.dart';
import '../../domain/services/yemek_onay_servisi.dart';
import '../../domain/entities/haftalik_rapor.dart';
import '../../domain/entities/yemek_onay_sistemi.dart';
import '../../domain/entities/gunluk_plan.dart';
import '../../data/local/hive_service.dart';

class HaftalikRaporPage extends StatefulWidget {
  final DateTime? baslangicTarihi;

  const HaftalikRaporPage({
    super.key,
    this.baslangicTarihi,
  });

  @override
  State<HaftalikRaporPage> createState() => _HaftalikRaporPageState();
}

class _HaftalikRaporPageState extends State<HaftalikRaporPage> {
  HaftalikRapor? _rapor;
  Map<String, dynamic>? _onayRaporu;
  Map<DateTime, GunlukPlan?> _gunlukPlanlar = {};
  Map<DateTime, GunlukOnayDurumu?> _gunlukOnaylar = {};
  bool _yukleniyor = true;
  String? _hata;
  
  late DateTime _secilenTarih;

  @override
  void initState() {
    super.initState();
    _secilenTarih = widget.baslangicTarihi ?? DateTime.now();
    _raporuYukle();
  }

  Future<void> _raporuYukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);
      
      // Klasik haftalık raporu al
      final rapor = await HaftalikRaporServisi.haftalikRaporOlustur(
        baslangicTarihi: haftaBaslangici,
      );
      
      // Yeni onay sistemi raporu al
      final onayRaporu = await YemekOnayServisi.haftalikUyumRaporu(
        baslangicTarihi: haftaBaslangici,
      );

      // 🔥 YENİ: 7 günlük planları ve onayları yükle
      final gunlukPlanlar = <DateTime, GunlukPlan?>{};
      final gunlukOnaylar = <DateTime, GunlukOnayDurumu?>{};

      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime(
          haftaBaslangici.year,
          haftaBaslangici.month,
          haftaBaslangici.day + gun,
        );
        
        gunlukPlanlar[tarih] = await HiveService.planGetir(tarih);
        gunlukOnaylar[tarih] = await HiveService.yemekOnayVerisiGetir(tarih);
      }

      setState(() {
        _rapor = rapor;
        _onayRaporu = onayRaporu;
        _gunlukPlanlar = gunlukPlanlar;
        _gunlukOnaylar = gunlukOnaylar;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _hata = 'Rapor yüklenirken hata oluştu: $e';
        _yukleniyor = false;
      });
    }
  }

  DateTime _haftaBaslangiciHesapla(DateTime tarih) {
    final gunFarki = tarih.weekday - 1;
    return DateTime(tarih.year, tarih.month, tarih.day - gunFarki);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Haftalık Detaylı Rapor'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _raporuYukle,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? _hataWidget()
              : _raporWidget(),
    );
  }

  Widget _hataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _hata!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _raporuYukle,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _raporWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih seçici
          _tarihSeciciWidget(),
          const SizedBox(height: 20),

          // Genel özet kartı
          if (_onayRaporu != null) _genelOzetKarti(),
          const SizedBox(height: 20),

          // 🔥 YENİ: Günlük detaylar (tüm yemekler)
          _gunlukDetaylarWidget(),
          const SizedBox(height: 20),

          // Tavsiyeler
          if (_rapor != null) _tavsiyelerWidget(),
        ],
      ),
    );
  }

  Widget _tarihSeciciWidget() {
    final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);
    final haftaSonu = haftaBaslangici.add(const Duration(days: 6));

    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_month),
        title: Text(
          '${_tarihString(haftaBaslangici)} - ${_tarihString(haftaSonu)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Hafta seçin'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final secilen = await showDatePicker(
            context: context,
            initialDate: _secilenTarih,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          
          if (secilen != null) {
            setState(() {
              _secilenTarih = secilen;
            });
            _raporuYukle();
          }
        },
      ),
    );
  }

  Widget _genelOzetKarti() {
    final onayRaporu = _onayRaporu!;
    final toplamYemek = onayRaporu['toplamYemek'] as int? ?? 0;
    final onaylananYemek = onayRaporu['onaylananYemek'] as int? ?? 0;
    final atlananYemek = onayRaporu['atlananYemek'] as int? ?? 0;
    final uyumYuzdesi = onayRaporu['uyumYuzdesi'] as double? ?? 0.0;

    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.teal[600]),
                const SizedBox(width: 8),
                Text(
                  'Haftalık Özet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Uyum yüzdesi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 40, color: Colors.teal[700]),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${uyumYuzdesi.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      Text(
                        'Ortalama Uyum',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Detay istatistikler
            Row(
              children: [
                Expanded(
                  child: _istatistikKutusu(
                    'Yenilen',
                    onaylananYemek.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _istatistikKutusu(
                    'Toplam',
                    toplamYemek.toString(),
                    Icons.restaurant,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _istatistikKutusu(
                    'Atlanan',
                    atlananYemek.toString(),
                    Icons.cancel,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _istatistikKutusu(String baslik, String deger, IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: renk, size: 24),
          const SizedBox(height: 4),
          Text(
            deger,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              color: renk,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔥 7 GÜNLÜK TOPLAM RAPOR
  Widget _gunlukDetaylarWidget() {
    if (_onayRaporu == null) return const SizedBox();
    
    final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);
    
    // 7 günlük verileri topla
    int toplamPlanlananYemek = 0;
    int toplamYenilenYemek = 0;
    int toplamAtlananYemek = 0;
    double toplamKalori = 0;
    double toplamProtein = 0;
    double toplamKarb = 0;
    double toplamYag = 0;
    
    for (int gun = 0; gun < 7; gun++) {
      final tarih = DateTime(
        haftaBaslangici.year,
        haftaBaslangici.month,
        haftaBaslangici.day + gun,
      );
      
      final plan = _gunlukPlanlar[tarih];
      final onayDurumu = _gunlukOnaylar[tarih];
      
      if (plan != null) {
        toplamPlanlananYemek += plan.ogunler.length;
        toplamKalori += plan.toplamKalori;
        toplamProtein += plan.toplamProtein;
        toplamKarb += plan.toplamKarbonhidrat;
        toplamYag += plan.toplamYag;
        
        if (onayDurumu != null) {
          toplamYenilenYemek += onayDurumu.yenmisSayisi;
          toplamAtlananYemek += onayDurumu.atlananSayisi;
        }
      }
    }
    
    final haftaSonu = haftaBaslangici.add(const Duration(days: 6));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  '7 Günlük Toplam Rapor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_tarihString(haftaBaslangici)} - ${_tarihString(haftaSonu)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Öğün istatistikleri
            Row(
              children: [
                Expanded(
                  child: _toplamKutusu(
                    'Planlanan',
                    toplamPlanlananYemek.toString(),
                    'öğün',
                    Icons.restaurant_menu,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _toplamKutusu(
                    'Yenilen',
                    toplamYenilenYemek.toString(),
                    'öğün',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _toplamKutusu(
                    'Atlanan',
                    toplamAtlananYemek.toString(),
                    'öğün',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Kalori
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange[700], size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${toplamKalori.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      Text(
                        '7 günlük toplam kalori',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Makrolar
            Text(
              '7 Günlük Makro Toplam',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _makroSutun('Protein', toplamProtein, Colors.blue),
                _makroSutun('Karbonhidrat', toplamKarb, Colors.orange),
                _makroSutun('Yağ', toplamYag, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _toplamKutusu(String baslik, String deger, String birim, IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: renk, size: 28),
          const SizedBox(height: 8),
          Text(
            deger,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
          Text(
            birim,
            style: TextStyle(fontSize: 10, color: renk),
          ),
          const SizedBox(height: 4),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: renk,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _makroSutun(String baslik, double deger, Color renk) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: renk.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                baslik,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: renk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${deger.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: renk,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🗑️ Günlük detaylar kaldırıldı - sadece 7 günlük toplam rapor gösteriliyor
  Widget _gunKarti_KULLANILMIYOR(DateTime tarih) {
    final plan = _gunlukPlanlar[tarih];
    final onayDurumu = _gunlukOnaylar[tarih];
    final gunAdi = _gunAdiAl(tarih.weekday);

    // Plan yoksa
    if (plan == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$gunAdi - ${_tarihString(tarih)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Plan oluşturulmamış',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Günlük uyum hesapla
    final yenilenSayisi = onayDurumu?.yenmisSayisi ?? 0;
    final toplamYemek = plan.ogunler.length;
    final uyumYuzdesi = toplamYemek > 0 ? (yenilenSayisi / toplamYemek) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: uyumYuzdesi >= 80 ? Colors.green :
                       uyumYuzdesi >= 60 ? Colors.orange : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$gunAdi - ${_tarihString(tarih)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: uyumYuzdesi / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                  uyumYuzdesi >= 80 ? Colors.green :
                  uyumYuzdesi >= 60 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$yenilenSayisi/$toplamYemek öğün yenildi (${uyumYuzdesi.toStringAsFixed(0)}%) • ${plan.toplamKalori.toStringAsFixed(0)} kcal',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Makro özet
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _makroKutusu('P', plan.toplamProtein, Colors.blue),
                        _makroKutusu('K', plan.toplamKarbonhidrat, Colors.orange),
                        _makroKutusu('Y', plan.toplamYag, Colors.red),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Öğünler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Divider(),
                  
                  // Öğün listesi
                  ...plan.ogunler.map((yemek) {
                    final onayVerisi = onayDurumu?.yemekDurumu(yemek.id);
                    final yenildiMi = onayVerisi?.yenmis ?? false;
                    final atlandiMi = onayVerisi?.atlanmis ?? false;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Durum ikonu
                          Icon(
                            yenildiMi ? Icons.check_circle :
                            atlandiMi ? Icons.cancel :
                            Icons.radio_button_unchecked,
                            color: yenildiMi ? Colors.green :
                                   atlandiMi ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  yemek.ad,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    decoration: atlandiMi ? TextDecoration.lineThrough : null,
                                    color: atlandiMi ? Colors.grey : null,
                                  ),
                                ),
                                Text(
                                  '${yemek.kalori.toStringAsFixed(0)} kcal • P:${yemek.protein.toStringAsFixed(0)}g K:${yemek.karbonhidrat.toStringAsFixed(0)}g Y:${yemek.yag.toStringAsFixed(0)}g',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makroKutusu(String baslik, double deger, Color renk) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: renk,
          ),
        ),
        Text(
          '${deger.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: renk,
          ),
        ),
      ],
    );
  }

  Widget _tavsiyelerWidget() {
    final rapor = _rapor!;
    
    if (rapor.tavsiyeler.isEmpty) return const SizedBox();
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Öneriler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...rapor.tavsiyeler.map((tavsiye) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.blue[600])),
                  Expanded(
                    child: Text(
                      tavsiye,
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _tarihString(DateTime tarih) {
    return '${tarih.day}.${tarih.month}.${tarih.year}';
  }

  String _gunAdiAl(int weekday) {
    const gunler = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return gunler[weekday];
  }
}