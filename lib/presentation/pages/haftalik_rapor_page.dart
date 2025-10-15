// ============================================================================
// lib/presentation/pages/haftalik_rapor_page.dart
// HAFTALİK UYUM RAPORU SAYFASI
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/services/haftalik_rapor_servisi.dart';
import '../../domain/services/yemek_onay_servisi.dart';
import '../../domain/entities/haftalik_rapor.dart';
import '../../domain/entities/yemek_onay_sistemi.dart';

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
  Map<DateTime, GunlukOnayDurumu>? _onayRaporu;
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
      // Haftanın başlangıcını hesapla (Pazartesi)
      final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);
      
      // Klasik haftalık raporu al
      final rapor = await HaftalikRaporServisi.haftalikRaporOlustur(
        baslangicTarihi: haftaBaslangici,
      );
      
      // Yeni onay sistemi raporu al
      final onayRaporu = await YemekOnayServisi.haftalikUyumRaporu(
        baslangicTarihi: haftaBaslangici,
      );

      setState(() {
        _rapor = rapor;
        _onayRaporu = onayRaporu;
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
    // Pazartesi başlangıç (1 = Pazartesi, 7 = Pazar)
    final gunFarki = tarih.weekday - 1;
    return DateTime(tarih.year, tarih.month, tarih.day - gunFarki);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Haftalık Rapor'),
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
          Text(
            _hata!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
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
    if (_rapor == null && (_onayRaporu == null || _onayRaporu!.isEmpty)) {
      return const Center(
        child: Text('Rapor verisi bulunamadı'),
      );
    }

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

          // Günlük detaylar
          if (_onayRaporu != null) _gunlukDetaylarWidget(),
          const SizedBox(height: 20),

          // Klasik rapor (varsa)
          if (_rapor != null) _klasikRaporWidget(),
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
            lastDate: DateTime.now().add(const Duration(days: 30)),
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
    
    // İstatistikleri hesapla
    double toplamUyum = 0;
    int toplamOnaylanan = 0;
    int toplamYemek = 0;
    int toplamAtlanan = 0;
    
    for (final gunluk in onayRaporu.values) {
      toplamUyum += gunluk.uyumYuzdesi;
      toplamOnaylanan += gunluk.onaylananSayisi;
      toplamYemek += gunluk.toplamYemekSayisi;
      toplamAtlanan += gunluk.atlananSayisi;
    }
    
    final ortalamaUyum = onayRaporu.isNotEmpty ? toplamUyum / onayRaporu.length : 0.0;

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
                  'Genel Özet',
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
                        '${ortalamaUyum.toStringAsFixed(1)}%',
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
                    'Onaylanan',
                    toplamOnaylanan.toString(),
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
                    toplamAtlanan.toString(),
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

  Widget _gunlukDetaylarWidget() {
    final onayRaporu = _onayRaporu!;
    final siraliGunler = onayRaporu.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_view_week, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Günlük Detaylar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...siraliGunler.map((tarih) {
              final gunluk = onayRaporu[tarih]!;
              return _gunlukDetayKarti(tarih, gunluk);
            }),
          ],
        ),
      ),
    );
  }

  Widget _gunlukDetayKarti(DateTime tarih, GunlukOnayDurumu gunluk) {
    final gunAdi = _gunAdiAl(tarih.weekday);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                gunAdi,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                _tarihString(tarih),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          LinearProgressIndicator(
            value: gunluk.uyumYuzdesi / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              gunluk.uyumYuzdesi >= 80 ? Colors.green :
              gunluk.uyumYuzdesi >= 60 ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Text(
                '${gunluk.uyumYuzdesi.toStringAsFixed(0)}% uyum',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${gunluk.onaylananSayisi}/${gunluk.toplamYemekSayisi}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          
          if (gunluk.gunDurumu.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              gunluk.gunDurumu,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _klasikRaporWidget() {
    final rapor = _rapor!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Detaylı Analiz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Hedef Analizi',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (rapor.hedefAnalizi.enIyiGun != null) ...[
              Text('En İyi Gün: ${rapor.hedefAnalizi.enIyiGun!.uyumYuzdesi.toStringAsFixed(1)}%'),
              const SizedBox(height: 4),
            ],
            
            if (rapor.hedefAnalizi.enKotuGun != null) ...[
              Text('En Düşük Gün: ${rapor.hedefAnalizi.enKotuGun!.uyumYuzdesi.toStringAsFixed(1)}%'),
              const SizedBox(height: 4),
            ],
            
            Text('Tutarlılık Skoru: ${rapor.hedefAnalizi.tutarlilikSkoru.toStringAsFixed(1)}/100'),
            Text('Trend: ${rapor.hedefAnalizi.gelismeTrendi}'),
          ],
        ),
      ),
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