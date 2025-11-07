// ============================================================================
// CAMERA TEST PAGE - AI Foto Analiz Testi
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/services/ai_foto_analiz_servisi.dart';
import '../../core/utils/app_logger.dart';

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({Key? key}) : super(key: key);

  @override
  State<CameraTestPage> createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  final AIFotoAnalizServisi _aiServisi = AIFotoAnalizServisi();
  Map<String, dynamic>? _sonAnaliz;
  bool _yukleniyor = false;

  /// Mock camera görüntüsü oluştur ve analiz et
  Future<void> _mockCameraAnaliziYap() async {
    setState(() {
      _yukleniyor = true;
      _sonAnaliz = null;
    });

    try {
      // Mock kamera byte'ları (gerçek uygulamada camera plugin'den gelecek)
      final mockCameraBytes = Uint8List.fromList(List.generate(100, (index) => index % 256));
      
      AppLogger.info('📸 Camera Test: Mock analiz başlatılıyor...');
      
      final sonuc = await _aiServisi.canliYemekTanima(cameraBytes: mockCameraBytes);
      
      setState(() {
        _sonAnaliz = sonuc;
        _yukleniyor = false;
      });
      
      AppLogger.success('✅ Camera Test: Analiz tamamlandı');
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _sonAnaliz = {
          'hata': true,
          'mesaj': e.toString(),
        };
      });
      
      AppLogger.error('❌ Camera Test Hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Camera AI Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Butonu
            ElevatedButton.icon(
              onPressed: _yukleniyor ? null : _mockCameraAnaliziYap,
              icon: const Icon(Icons.camera_alt),
              label: _yukleniyor
                  ? const Text('Analiz Ediliyor...')
                  : const Text('Mock Camera Analizi Başlat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Loading Indicator
            if (_yukleniyor)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('AI analiz yapıyor...'),
                  ],
                ),
              ),
            
            // Analiz Sonucu
            if (_sonAnaliz != null && !_yukleniyor)
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📊 Analiz Sonucu',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const Divider(height: 24),
                          
                          if (_sonAnaliz!.containsKey('hata'))
                            _buildErrorCard()
                          else
                            _buildSuccessCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            // Info Card
            if (_sonAnaliz == null && !_yukleniyor)
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Camera AI Test Bilgileri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '🎯 Bu sayfa AI Foto Analiz servisini test eder.\n\n'
                          '📸 Mock kamera verisi ile canlı yemek tanıma özelliğini test eder.\n\n'
                          '🤖 Gerçek uygulamada:\n'
                          '  • Camera plugin kullanılır\n'
                          '  • Gerçek zamanlı görüntü analizi yapılır\n'
                          '  • AI sonuçları gösterilir\n\n'
                          '✅ Sistemi test etmek için yukarıdaki butona tıklayın.',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Hata Oluştu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _sonAnaliz!['mesaj'] ?? 'Bilinmeyen hata',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanınma Durumu
          _buildInfoRow(
            icon: Icons.check_circle_outline,
            label: 'Tanındı',
            value: _sonAnaliz!['tanindi'] == true ? 'Evet ✅' : 'Hayır ❌',
            color: Colors.green.shade700,
          ),
          const Divider(height: 24),
          
          // Hızlı Tanım
          if (_sonAnaliz!.containsKey('hizli_tanim'))
            _buildInfoRow(
              icon: Icons.flash_on,
              label: 'Hızlı Tanım',
              value: _sonAnaliz!['hizli_tanim'],
              color: Colors.orange.shade700,
            ),
          const SizedBox(height: 12),
          
          // Güvenilirlik
          if (_sonAnaliz!.containsKey('guvenlilk'))
            _buildInfoRow(
              icon: Icons.analytics_outlined,
              label: 'Güvenilirlik',
              value: '${(_sonAnaliz!['guvenlilk'] * 100).toStringAsFixed(1)}%',
              color: Colors.blue.shade700,
            ),
          const SizedBox(height: 12),
          
          // Öneri
          if (_sonAnaliz!.containsKey('oneri'))
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sonAnaliz!['oneri'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Raw Data (Debug)
          ExpansionTile(
            title: const Text('🔍 Raw Debug Data'),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _sonAnaliz.toString(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}