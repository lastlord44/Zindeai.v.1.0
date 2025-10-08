import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/yemek_migration_guncel.dart';
import '../../core/utils/app_logger.dart';

/// 🔧 Maintenance & Debug Sayfası
/// Migration'ı temizleyip yeniden çalıştırmak için kullanılır
class MaintenancePage extends StatefulWidget {
  const MaintenancePage({Key? key}) : super(key: key);

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool _isLoading = false;
  String _statusMessage = 'Hazır';
  Map<String, int>? _kategoriSayilari;
  int? _toplamYemek;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// DB istatistiklerini yükle
  Future<void> _loadStats() async {
    try {
      final toplamYemek = await HiveService.yemekSayisi();
      final kategoriSayilari = await HiveService.kategoriSayilari();

      setState(() {
        _toplamYemek = toplamYemek;
        _kategoriSayilari = kategoriSayilari;
      });
    } catch (e) {
      AppLogger.error('Stats yükleme hatası', error: e);
    }
  }

  /// DB'yi temizle ve yeniden yükle
  Future<void> _resetDatabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mevcut yemekler siliniyor...';
    });

    try {
      // 1. Mevcut yemekleri sil
      await HiveService.tumYemekleriSil();
      AppLogger.info('✅ Mevcut yemekler silindi');

      setState(() {
        _statusMessage = 'Migration başlatılıyor...';
      });

      // 2. Migration'ı çalıştır (güncellenmiş meal_name düzeltmeleri ile!)
      final success = await YemekMigration.jsonToHiveMigration();

      if (success) {
        setState(() {
          _statusMessage = '✅ Migration başarıyla tamamlandı!';
        });
        AppLogger.success('✅ Migration başarıyla tamamlandı!');

        // İstatistikleri güncelle
        await _loadStats();

        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Yemek veritabanı başarıyla güncellendi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = '❌ Migration başarısız!';
        });
        AppLogger.error('❌ Migration başarısız');
      }
    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Hata: $e';
      });
      AppLogger.error('Migration hatası', error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('🔧 Maintenance & Debug'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.amber.shade700, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dikkat!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bu işlem tüm mevcut yemekleri silip yeniden yükleyecek. Devam etmek istediğinizden emin misiniz?',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mevcut durum
            Text(
              'Mevcut Durum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.restaurant, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Toplam Yemek: ${_toplamYemek ?? '...'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_kategoriSayilari != null &&
                      _kategoriSayilari!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori Dağılımı:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._kategoriSayilari!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${entry.value} yemek',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status mesajı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusMessage.contains('✅')
                    ? Colors.green.shade50
                    : _statusMessage.contains('❌')
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.shade300
                      : _statusMessage.contains('❌')
                          ? Colors.red.shade300
                          : Colors.blue.shade300,
                ),
              ),
              child: Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _statusMessage.contains('✅')
                          ? Icons.check_circle
                          : _statusMessage.contains('❌')
                              ? Icons.error
                              : Icons.info,
                      color: _statusMessage.contains('✅')
                          ? Colors.green.shade700
                          : _statusMessage.contains('❌')
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('✅')
                            ? Colors.green.shade900
                            : _statusMessage.contains('❌')
                                ? Colors.red.shade900
                                : Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Temizle ve yeniden yükle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _resetDatabase,
                icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.refresh),
                label: Text(
                  _isLoading
                      ? 'Migration Çalışıyor...'
                      : '🔄 DB Temizle ve Yeniden Yükle',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isLoading ? 0 : 2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Yenile butonu (sadece stats)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadStats,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('📊 İstatistikleri Yenile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

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
                        'Ne Yapılıyor?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '''1. Mevcut tüm yemekler Hive DB'den silinir
2. JSON dosyalarından yeniden migration yapılır
3. Ara öğün meal_name düzeltmeleri otomatik uygulanır:
   • Ara Öğün 1: "Kahvaltı Kombinasyonu:" → "Ara Öğün 1:"
   • Ara Öğün 2: "Öğle:" → "Ara Öğün 2:"
4. Tüm kategori sayıları güncellenir''',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
