// ============================================================================
// lib/presentation/pages/alisveris_listesi_page.dart
// HAFTALİK ALIŞVERİŞ LİSTESİ SAYFASI
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/services/haftalik_alisveris_servisi.dart';
import '../../domain/entities/alisveris_listesi.dart';
import '../../data/local/hive_service.dart';

class AlisverisListesiPage extends StatefulWidget {
  final DateTime? baslangicTarihi;

  const AlisverisListesiPage({
    super.key,
    this.baslangicTarihi,
  });

  @override
  State<AlisverisListesiPage> createState() => _AlisverisListesiPageState();
}

class _AlisverisListesiPageState extends State<AlisverisListesiPage> {
  AlisverisListesi? _liste;
  bool _yukleniyor = true;
  String? _hata;
  late DateTime _secilenTarih;
  final Set<String> _alinanMalzemeler = {};

  @override
  void initState() {
    super.initState();
    _secilenTarih = widget.baslangicTarihi ?? DateTime.now();
    _listeyiYukle();
  }

  Future<void> _listeyiYukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      // Kullanıcı profilini al
      final kullanici = await HiveService.kullaniciGetir();
      if (kullanici == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Haftanın başlangıcını hesapla (Pazartesi)
      final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);

      // Alışveriş listesini oluştur
      final liste =
          await HaftalikAlisverisServisi.haftalikAlisverisListesiOlustur(
        baslangicTarihi: haftaBaslangici,
        kullanici: kullanici,
      );

      setState(() {
        _liste = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _hata = 'Liste oluşturulurken hata oluştu: $e';
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
        title: const Text('🛒 Alışveriş Listesi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_liste != null) ...[
            IconButton(
              onPressed: _listeyiPaylas,
              icon: const Icon(Icons.share),
              tooltip: 'Paylaş',
            ),
            IconButton(
              onPressed: _listeyiKopyala,
              icon: const Icon(Icons.copy),
              tooltip: 'Kopyala',
            ),
          ],
          IconButton(
            onPressed: _listeyiYukle,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? _hataWidget()
              : _listeWidget(),
      floatingActionButton: _liste != null
          ? FloatingActionButton.extended(
              onPressed: _tumunuSecDeselect,
              icon: Icon(_tumMalzemelerAlindiMi()
                  ? Icons.clear_all
                  : Icons.check_circle_outline),
              label: Text(_tumMalzemelerAlindiMi()
                  ? 'Tümünü Temizle'
                  : 'Tümünü İşaretle'),
              backgroundColor: Colors.green,
            )
          : null,
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
            onPressed: _listeyiYukle,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _listeWidget() {
    if (_liste == null) {
      return const Center(child: Text('Liste verisi bulunamadı'));
    }

    final liste = _liste!;

    return Column(
      children: [
        // Özet header
        Container(
          width: double.infinity,
          color: Colors.green[50],
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih seçici
              _tarihSeciciWidget(),
              const SizedBox(height: 16),

              // İstatistikler
              Row(
                children: [
                  Expanded(
                    child: _istatistikKutusu(
                      'Toplam\nMalzeme',
                      liste.toplamMalzemeSayisi.toString(),
                      Icons.shopping_basket,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _istatistikKutusu(
                      'Tahmini\nMaliyet',
                      '${liste.toplamMaliyetTahmini.toStringAsFixed(0)}₺',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _istatistikKutusu(
                      'Market\nBölümü',
                      liste.marketBolumSayisi.toString(),
                      Icons.store,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _istatistikKutusu(
                      'Alınan',
                      '${_alinanMalzemeler.length}/${liste.toplamMalzemeSayisi}',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste içeriği
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: '🛒 Market Bölümleri'),
                    Tab(text: '📋 Kategoriler'),
                  ],
                  labelColor: Colors.green[700],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _marketBolumleriTab(),
                      _kategorilerTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarihSeciciWidget() {
    final haftaBaslangici = _haftaBaslangiciHesapla(_secilenTarih);
    final haftaSonu = haftaBaslangici.add(const Duration(days: 6));

    return InkWell(
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
            _alinanMalzemeler.clear();
          });
          _listeyiYukle();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.green),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_tarihString(haftaBaslangici)} - ${_tarihString(haftaSonu)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Hafta seçmek için dokunun',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _istatistikKutusu(
      String baslik, String deger, IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: renk, size: 20),
          const SizedBox(height: 4),
          Text(
            deger,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 10,
              color: renk,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _marketBolumleriTab() {
    final liste = _liste!;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: liste.marketBolumleri.length,
      itemBuilder: (context, index) {
        final entry = liste.marketBolumleri.entries.elementAt(index);
        return _malzemeBolumKarti(entry.key, entry.value);
      },
    );
  }

  Widget _kategorilerTab() {
    final liste = _liste!;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: liste.kategoriler.length,
      itemBuilder: (context, index) {
        final entry = liste.kategoriler.entries.elementAt(index);
        return _malzemeBolumKarti(entry.key, entry.value);
      },
    );
  }

  Widget _malzemeBolumKarti(String baslik, List<MalzemeDetayi> malzemeler) {
    if (malzemeler.isEmpty) return const SizedBox();

    final alinanSayisi =
        malzemeler.where((m) => _alinanMalzemeler.contains(m.ad)).length;
    final toplamMaliyet =
        malzemeler.fold<double>(0, (sum, m) => sum + m.toplamMaliyet);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          baslik,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${malzemeler.length} malzeme • ${toplamMaliyet.toStringAsFixed(0)}₺ • $alinanSayisi alındı',
          style: const TextStyle(fontSize: 12),
        ),
        leading: CircleAvatar(
          backgroundColor: alinanSayisi == malzemeler.length
              ? Colors.green
              : Colors.grey[300],
          child: Text(
            '$alinanSayisi/${malzemeler.length}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        children:
            malzemeler.map((malzeme) => _malzemeListTile(malzeme)).toList(),
      ),
    );
  }

  Widget _malzemeListTile(MalzemeDetayi malzeme) {
    final alindi = _alinanMalzemeler.contains(malzeme.ad);

    return ListTile(
      dense: true,
      leading: Checkbox(
        value: alindi,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _alinanMalzemeler.add(malzeme.ad);
            } else {
              _alinanMalzemeler.remove(malzeme.ad);
            }
          });
        },
        activeColor: Colors.green,
      ),
      title: Text(
        malzeme.ad,
        style: TextStyle(
          decoration: alindi ? TextDecoration.lineThrough : null,
          color: alindi ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        '${malzeme.miktarBirimMetni} • ${malzeme.toplamMaliyet.toStringAsFixed(1)}₺',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _oncelikRengiAl(malzeme.oncelik),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          malzeme.oncelikMetni,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _oncelikRengiAl(int oncelik) {
    switch (oncelik) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 1:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _tumunuSecDeselect() {
    final liste = _liste!;
    final tumMalzemeler = <String>{};

    for (final bolum in liste.marketBolumleri.values) {
      for (final malzeme in bolum) {
        tumMalzemeler.add(malzeme.ad);
      }
    }

    setState(() {
      if (_tumMalzemelerAlindiMi()) {
        _alinanMalzemeler.clear();
      } else {
        _alinanMalzemeler.addAll(tumMalzemeler);
      }
    });
  }

  bool _tumMalzemelerAlindiMi() {
    final liste = _liste!;
    final tumMalzemeler = <String>{};

    for (final bolum in liste.marketBolumleri.values) {
      for (final malzeme in bolum) {
        tumMalzemeler.add(malzeme.ad);
      }
    }

    return _alinanMalzemeler.containsAll(tumMalzemeler);
  }

  Future<void> _listeyiPaylas() async {
    final liste = _liste!;
    final metin = _listeMetniOlustur(liste);

    await Clipboard.setData(ClipboardData(text: metin));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste panoya kopyalandı'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _listeyiKopyala() async {
    final liste = _liste!;
    final basitListe = _basitListeOlustur(liste);

    await Clipboard.setData(ClipboardData(text: basitListe));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Basit liste panoya kopyalandı'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _listeMetniOlustur(AlisverisListesi liste) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 HAFTALİK ALIŞVERİŞ LİSTESİ');
    buffer.writeln(
        '${_tarihString(liste.baslangicTarihi)} - ${_tarihString(liste.bitisTarihi)}');
    buffer.writeln('');
    buffer.writeln('📊 ÖZET:');
    buffer.writeln('• Toplam malzeme: ${liste.toplamMalzemeSayisi}');
    buffer.writeln(
        '• Tahmini maliyet: ${liste.toplamMaliyetTahmini.toStringAsFixed(0)}₺');
    buffer.writeln('• Planlı gün sayısı: ${liste.planliGunSayisi}');
    buffer.writeln('');

    for (final entry in liste.marketBolumleri.entries) {
      if (entry.value.isNotEmpty) {
        buffer.writeln('${entry.key}:');
        for (final malzeme in entry.value) {
          buffer.writeln(
              '  ☐ ${malzeme.ad} (${malzeme.miktarBirimMetni}) - ${malzeme.toplamMaliyet.toStringAsFixed(1)}₺');
        }
        buffer.writeln('');
      }
    }

    if (liste.oneriler.isNotEmpty) {
      buffer.writeln('💡 ÖNERİLER:');
      for (final oneri in liste.oneriler) {
        buffer.writeln('• $oneri');
      }
    }

    return buffer.toString();
  }

  String _basitListeOlustur(AlisverisListesi liste) {
    final buffer = StringBuffer();
    buffer.writeln('Alışveriş Listesi');
    buffer.writeln('');

    for (final entry in liste.marketBolumleri.entries) {
      if (entry.value.isNotEmpty) {
        buffer.writeln('${entry.key}:');
        for (final malzeme in entry.value) {
          buffer.writeln('☐ ${malzeme.ad}');
        }
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  String _tarihString(DateTime tarih) {
    return '${tarih.day}.${tarih.month}.${tarih.year}';
  }
}
