// ============================================================================
// ALTERNATİF BESİN SİSTEMİ - DEMO & TEST SAYFASI
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/alternatif_besin_legacy.dart';
import '../../domain/services/alternatif_oneri_servisi.dart';
import '../widgets/alternatif_besin_bottom_sheet.dart';

class AlternatifBesinDemoPage extends StatefulWidget {
  const AlternatifBesinDemoPage({Key? key}) : super(key: key);

  @override
  State<AlternatifBesinDemoPage> createState() =>
      _AlternatifBesinDemoPageState();
}

class _AlternatifBesinDemoPageState extends State<AlternatifBesinDemoPage> {
  final _besinController = TextEditingController();
  final _miktarController = TextEditingController(text: '10');
  String _secilenBirim = 'adet';
  List<AlternatifBesinLegacy> _alternatifler = [];
  AlternatifBesinLegacy? _sonSecim;

  // Test için hazır besin örnekleri
  final List<Map<String, dynamic>> _ornekBesinler = [
    {'ad': 'Badem', 'miktar': 10.0, 'birim': 'adet'},
    {'ad': 'Ceviz', 'miktar': 6.0, 'birim': 'adet'},
    {'ad': 'Fındık', 'miktar': 13.0, 'birim': 'adet'},
    {'ad': 'Elma', 'miktar': 1.0, 'birim': 'adet'},
    {'ad': 'Muz', 'miktar': 1.0, 'birim': 'adet'},
    {'ad': 'Yoğurt', 'miktar': 200.0, 'birim': 'gram'},
    {'ad': 'Süt', 'miktar': 200.0, 'birim': 'ml'},
    {'ad': 'Tavuk Göğsü', 'miktar': 150.0, 'birim': 'gram'},
    {'ad': 'Yumurta', 'miktar': 2.0, 'birim': 'adet'},
    {'ad': 'Ekmek', 'miktar': 2.0, 'birim': 'dilim'},
  ];

  void _alternatifBul() {
    final besin = _besinController.text.trim();
    final miktar = double.tryParse(_miktarController.text) ?? 10;

    if (besin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen besin adı girin!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _alternatifler = AlternatifOneriServisi.otomatikAlternatifUret(
        besinAdi: besin,
        miktar: miktar,
        birim: _secilenBirim,
      );
      _sonSecim = null;
    });

    if (_alternatifler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('😔 "$besin" için alternatif bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${_alternatifler.length} alternatif bulundu!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _ornekBesinSec(Map<String, dynamic> ornek) {
    setState(() {
      _besinController.text = ornek['ad'];
      _miktarController.text = ornek['miktar'].toString();
      _secilenBirim = ornek['birim'];
    });
    _alternatifBul();
  }

  Future<void> _bottomSheetGoster() async {
    if (_alternatifler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Önce alternatif bulun!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final secilen = await AlternatifBesinBottomSheet.goster(
      context,
      orijinalBesinAdi: _besinController.text,
      orijinalMiktar: double.tryParse(_miktarController.text) ?? 10,
      orijinalBirim: _secilenBirim,
      alternatifler: _alternatifler,
      alerjiNedeni: '${_besinController.text} alerjiniz var veya bulamıyorsunuz',
    );

    if (secilen != null) {
      setState(() {
        _sonSecim = secilen;
      });
    }
  }

  @override
  void dispose() {
    _besinController.dispose();
    _miktarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text('🧪 Alternatif Besin Test'),
        backgroundColor: Colors.purple.shade200,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bilgi kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Nasıl Kullanılır?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Örnek seçin veya manuel girin  2. Alternatif Bul  3. Bottom Sheet Göster ile test edin',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Manuel giriş
            Container(
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
                  const Text(
                    '🔍 Manuel Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _besinController,
                    decoration: InputDecoration(
                      labelText: 'Besin Adı',
                      hintText: 'örn: Badem, Ceviz, Elma',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _miktarController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Miktar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _secilenBirim,
                          decoration: InputDecoration(
                            labelText: 'Birim',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: ['adet', 'gram', 'ml', 'dilim']
                              .map((birim) => DropdownMenuItem(
                                    value: birim,
                                    child: Text(birim),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _secilenBirim = val!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _alternatifBul,
                          icon: const Icon(Icons.search),
                          label: const Text('Alternatif Bul'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _bottomSheetGoster,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Bottom Sheet Göster'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Örnek besinler
            Container(
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
                  const Text(
                    '📋 Hazır Örnekler (Tıklayın)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ornekBesinler.map((ornek) {
                      return ActionChip(
                        label: Text(
                          '${ornek['ad']} (${ornek['miktar']} ${ornek['birim']})',
                        ),
                        onPressed: () => _ornekBesinSec(ornek),
                        backgroundColor: Colors.purple.shade50,
                        side: BorderSide(color: Colors.purple.shade200),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bulunan alternatifler
            if (_alternatifler.isNotEmpty) ...[
              Container(
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
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '${_alternatifler.length} Alternatif Bulundu',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
            ..._alternatifler.map((alt) => _buildAlternatifCard(alt)).toList(),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Son seçim
            if (_sonSecim != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Son Seçiminiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '✅ ${_sonSecim!.miktar.toStringAsFixed(0)} ${_sonSecim!.birim} ${_sonSecim!.ad}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Neden: ${_sonSecim!.neden}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        _buildNutrientInfo(
                          '🔥',
                          '${_sonSecim!.kalori.toStringAsFixed(0)} kcal',
                        ),
                        _buildNutrientInfo(
                          '💪',
                          '${_sonSecim!.protein.toStringAsFixed(1)}g',
                        ),
                        _buildNutrientInfo(
                          '🍚',
                          '${_sonSecim!.karbonhidrat.toStringAsFixed(1)}g',
                        ),
                        _buildNutrientInfo(
                          '🥑',
                          '${_sonSecim!.yag.toStringAsFixed(1)}g',
                        ),
                      ],
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

  Widget _buildAlternatifCard(AlternatifBesinLegacy alternatif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${alternatif.miktar.toStringAsFixed(0)} ${alternatif.birim} ${alternatif.ad}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alternatif.neden,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge('🔥 ${alternatif.kalori.toStringAsFixed(0)} kcal',
                  Colors.orange),
              _buildBadge(
                  '💪 ${alternatif.protein.toStringAsFixed(1)}g', Colors.red),
              _buildBadge('🍚 ${alternatif.karbonhidrat.toStringAsFixed(1)}g',
                  Colors.amber),
              _buildBadge(
                  '🥑 ${alternatif.yag.toStringAsFixed(1)}g', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
