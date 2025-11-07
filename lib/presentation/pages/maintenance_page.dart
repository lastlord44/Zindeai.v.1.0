import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // 🔥 Hive import eklendi
import '../../data/local/hive_service.dart';
import '../../core/utils/yemek_migration_guncel.dart';
import '../../core/utils/app_logger.dart';

/// 🔧 Maintenance & Debug Sayfası (GELİŞMİŞ)
/// Migration, DB health check, istatistikler ve daha fazlası
class MaintenancePage extends StatefulWidget {
  const MaintenancePage({Key? key}) : super(key: key);

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _statusMessage = 'Hazır';
  Map<String, int>? _kategoriSayilari;
  int? _toplamYemek;
  Map<String, dynamic>? _healthCheckResults;
  double? _migrationProgress;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
    _performHealthCheck();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  /// 🏥 Database Health Check
  Future<void> _performHealthCheck() async {
    try {
      final yemekler = await HiveService.tumYemekleriGetir();

      int bosKaloriYemek = 0;
      int eksikMalzemeYemek = 0;
      int cokDusukKaloriYemek = 0;
      int cokYuksekKaloriYemek = 0;

      for (var yemek in yemekler) {
        if (yemek.kalori <= 0) bosKaloriYemek++;
        if (yemek.kalori > 0 && yemek.kalori < 50) cokDusukKaloriYemek++;
        if (yemek.kalori > 2000) cokYuksekKaloriYemek++;
        if (yemek.malzemeler.isEmpty) eksikMalzemeYemek++;
      }

      final kaloriOrtalama = yemekler.isEmpty
          ? 0
          : yemekler.fold<double>(0, (sum, y) => sum + y.kalori) /
              yemekler.length;

      final proteinOrtalama = yemekler.isEmpty
          ? 0
          : yemekler.fold<double>(0, (sum, y) => sum + y.protein) /
              yemekler.length;

      setState(() {
        _healthCheckResults = {
          'toplamYemek': yemekler.length,
          'bosKaloriYemek': bosKaloriYemek,
          'eksikMalzemeYemek': eksikMalzemeYemek,
          'cokDusukKaloriYemek': cokDusukKaloriYemek,
          'cokYuksekKaloriYemek': cokYuksekKaloriYemek,
          'kaloriOrtalama': kaloriOrtalama.toStringAsFixed(1),
          'proteinOrtalama': proteinOrtalama.toStringAsFixed(1),
          'healthScore': _calculateHealthScore(
            yemekler.length,
            bosKaloriYemek,
            eksikMalzemeYemek,
          ),
        };
      });
    } catch (e) {
      AppLogger.error('Health check hatası', error: e);
    }
  }

  /// 💯 Health Score hesapla (0-100)
  double _calculateHealthScore(int toplam, int bosKalori, int eksikMalzeme) {
    if (toplam == 0) return 0;

    final sorunluYemek = bosKalori + eksikMalzeme;
    final saglikliYemek = toplam - sorunluYemek;

    return (saglikliYemek / toplam) * 100;
  }

  /// DB'yi temizle ve yeniden yükle (İLERLEME TAKIPLI)
  Future<void> _resetDatabase() async {
    // Kullanıcıdan onay al
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Dikkat!'),
        content: const Text(
          'Bu işlem tüm mevcut yemekleri silip yeniden yükleyecek.\n\n'
          'Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Evet, Temizle'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Mevcut yemekler siliniyor...';
      _migrationProgress = 0.0;
    });

    try {
      // 1. Mevcut yemekleri sil
      await HiveService.tumYemekleriSil();
      AppLogger.info('✅ Mevcut yemekler silindi');

      setState(() {
        _statusMessage = 'Migration başlatılıyor...';
        _migrationProgress = 0.2;
      });

      // 2. Migration'ı çalıştır
      final stopwatch = Stopwatch()..start();
      final success = await YemekMigration.jsonToHiveMigration();
      stopwatch.stop();

      if (success) {
        setState(() {
          _statusMessage =
              '✅ Migration başarıyla tamamlandı! (${stopwatch.elapsed.inSeconds}s)';
          _migrationProgress = 1.0;
        });
        AppLogger.success(
            '✅ Migration tamamlandı: ${stopwatch.elapsed.inSeconds}s');

        // İstatistikleri ve health check'i güncelle
        await _loadStats();
        await _performHealthCheck();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${_toplamYemek ?? 0} yemek yüklendi! (${stopwatch.elapsed.inSeconds}s)',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = '❌ Migration başarısız!';
          _migrationProgress = null;
        });
        AppLogger.error('❌ Migration başarısız');
      }
    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Hata: $e';
        _migrationProgress = null;
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Genel'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Sağlık'),
            Tab(icon: Icon(Icons.info), text: 'Detaylar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenelTab(),
          _buildSaglikTab(),
          _buildDetaylarTab(),
        ],
      ),
    );
  }

  /// 📊 GENEL TAB
  Widget _buildGenelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uyarı kartı
          _buildWarningCard(),
          const SizedBox(height: 24),

          // Mevcut durum
          _buildCurrentStatusCard(),
          const SizedBox(height: 24),

          // İlerleme göstergesi
          if (_migrationProgress != null) ...[
            _buildProgressCard(),
            const SizedBox(height: 24),
          ],

          // Status mesajı
          _buildStatusCard(),
          const SizedBox(height: 24),

          // Temizle ve yeniden yükle butonu
          _buildActionButtons(),
          const SizedBox(height: 24),

          // Bilgi kartı
          _buildInfoCard(),
        ],
      ),
    );
  }

  /// 🏥 SAĞLIK TAB
  Widget _buildSaglikTab() {
    if (_healthCheckResults == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final healthScore = _healthCheckResults!['healthScore'] as double;
    final color = healthScore >= 80
        ? Colors.green
        : healthScore >= 50
            ? Colors.orange
            : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Database Sağlık Skoru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${healthScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  healthScore >= 80
                      ? 'Mükemmel!'
                      : healthScore >= 50
                          ? 'İyi'
                          : 'Dikkat Gerekli',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sorunlar
          _buildHealthIssuesCard(),
          const SizedBox(height: 16),

          // İstatistikler
          _buildHealthStatsCard(),
          const SizedBox(height: 16),

          // Yenile butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _performHealthCheck,
              icon: const Icon(Icons.refresh),
              label: const Text('Sağlık Kontrolünü Yenile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 DETAYLAR TAB
  Widget _buildDetaylarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Dağılımı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_kategoriSayilari != null && _kategoriSayilari!.isNotEmpty)
            ..._kategoriSayilari!.entries.map((entry) {
              final percentage = _toplamYemek != null && _toplamYemek! > 0
                  ? (entry.value / _toplamYemek!) * 100
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${entry.value} yemek (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Kategori verisi bulunamadı'),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================

  Widget _buildWarningCard() {
    return Container(
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
                  'Bu işlem tüm mevcut yemekleri silip yeniden yükleyecek.',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
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
              const Icon(Icons.restaurant, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                'Toplam Yemek: ${_toplamYemek ?? '...'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_healthCheckResults != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ortalama Kalori: ${_healthCheckResults!['kaloriOrtalama']} kcal',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
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
          const Text(
            'İlerleme',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _migrationProgress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_migrationProgress! * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
                  borderRadius: BorderRadius.circular(12)),
              elevation: _isLoading ? 0 : 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _cleanForeignFoods,
            icon: const Icon(Icons.cleaning_services),
            label: const Text('🧹 Yabancı Besinleri Temizle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _checkDataInconsistencies,
            icon: const Icon(Icons.fact_check),
            label: const Text('🔍 Veri Tutarsızlığı Kontrolü'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  /// Veri tutarsızlık kontrolü (meal_name vs malzemeler)
  Future<void> _checkDataInconsistencies() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Veri tutarsızlıkları taranıyor...';
    });

    try {
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final tutarsizliklar = <Map<String, dynamic>>[];

      // Önemli malzemeler (yemek adında geçmesi gereken)
      final onemliMalzemeler = [
        'tavuk', 'balık', 'balik', 'ton', 'somon', 'uskumru', 'hamsi',
        'makarna', 'pirinç', 'pirinci', 'bulgur', 'mercimek', 'nohut',
        'fasulye', 'yumurta', 'peynir', 'yoğurt', 'yogurt', 'süzme',
        'dana', 'hindi', 'köfte', 'kofte', 'kebap', 'döner', 'pizza',
        'börek', 'poğaça', 'pogaca', 'çorba', 'corba', 'salata',
      ];

      for (var yemek in tumYemekler) {
        final mealNameLower = yemek.ad.toLowerCase();
        final malzemelerText = yemek.malzemeler.join(' ').toLowerCase();

        // Kontrol 1: Yemek adında geçen malzemeler, malzemelerde var mı?
        for (var malzeme in onemliMalzemeler) {
          if (mealNameLower.contains(malzeme) &&
              !malzemelerText.contains(malzeme)) {
            tutarsizliklar.add({
              'yemekId': yemek.id,
              'yemekAdi': yemek.ad,
              'sorun': 'Yemek adında "$malzeme" var ama malzemelerde yok',
              'malzemeler': yemek.malzemeler.take(3).join(', '),
            });
            AppLogger.warning('⚠️ TUTARSIZLIK: ${yemek.ad} - "$malzeme" yemek adında var ama malzemelerde yok');
            break; // Bir tutarsızlık yeterli
          }
        }

        // Kontrol 2: Malzemelerde önemli bir şey varsa yemek adında da olmalı
        for (var malzeme in onemliMalzemeler) {
          if (malzemelerText.contains(malzeme) &&
              !mealNameLower.contains(malzeme)) {
            // Bazı istisnalar: "yoğurt" malzemede olabilir ama her zaman adda olmayabilir
            final istisnalar = ['yumurta', 'peynir', 'yoğurt', 'yogurt', 'süzme'];
            if (!istisnalar.contains(malzeme)) {
              tutarsizliklar.add({
                'yemekId': yemek.id,
                'yemekAdi': yemek.ad,
                'sorun': 'Malzemelerde "$malzeme" var ama yemek adında yok',
                'malzemeler': yemek.malzemeler.take(3).join(', '),
              });
              AppLogger.warning('⚠️ TUTARSIZLIK: ${yemek.ad} - "$malzeme" malzemelerde var ama yemek adında yok');
              break;
            }
          }
        }
      }

      setState(() {
        _statusMessage = '✅ ${tutarsizliklar.length} tutarsızlık bulundu!';
      });

      if (mounted && tutarsizliklar.isNotEmpty) {
        // Sonuçları dialog ile göster
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('🔍 Veri Tutarsızlıkları (${tutarsizliklar.length})'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tutarsizliklar.length > 50 ? 50 : tutarsizliklar.length,
                itemBuilder: (context, index) {
                  final item = tutarsizliklar[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        item['yemekAdi'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['sorun'] as String,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Malzemeler: ${item['malzemeler']}...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tutarsızlık bulunamadı, veriler temiz!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Hata: $e';
      });
      AppLogger.error('Veri tutarsızlığı kontrolü hatası',
          error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Yabancı besinleri temizle (tempeh, quinoa vb.)
  Future<void> _cleanForeignFoods() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Yabancı Besinleri Temizle'),
        content: const Text(
          'Bu işlem Türk mutfağında olmayan yabancı besinleri (tempeh, quinoa, tofu vb.) veritabanından silecek.\n\n'
          'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Evet, Temizle'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Yabancı besinler taranıyor...';
    });

    try {
      final yabanciBesinler = [
        'tempeh', 'quinoa', 'kinoa', 'tofu', 'edamame', 'kimchi', 'kombucha',
        'seitan', 'miso', 'tahini', 'hummus', 'falafel', 'couscous', 'kuskus',
        'chia', 'acai', 'goji', 'spirulina', 'matcha', 'kale', 'arugula',
        'rocket', 'roka', 'bok choy', 'nori', 'wakame', 'sushi', 'sashimi',
        'wasabi', 'sriracha', 'paneer', 'ghee', 'naan', 'basmati', 'jasmine rice',
        'pad thai', 'pho', 'ramen', 'udon', 'soba', 'mochi', 'burrito', 'taco',
        'quesadilla', 'guacamole', 'salsa', 'tortilla', 'enchilada', 'chimichanga',
        'fajita', 'nachos', 'paella', 'risotto', 'gnocchi', 'ravioli', 'pesto',
        'bruschetta', 'ciabatta', 'focaccia', 'bagel', 'croissant', 'baguette',
        'prosciutto', 'salami', 'chorizo', 'pancetta', 'brie', 'camembert',
        'gorgonzola', 'parmesan', 'mozzarella', 'ricotta', 'mascarpone',
        'cheddar', 'gouda', 'swiss', 'blue cheese', 'cottage cheese', 'cream cheese',
      ];

      final tumYemekler = await HiveService.tumYemekleriGetir();
      int silinenSayisi = 0;

      for (var yemek in tumYemekler) {
        bool yabanciMi = false;

        // Yemek adında yabancı besin var mı?
        for (var yabanci in yabanciBesinler) {
          if (yemek.ad.toLowerCase().contains(yabanci.toLowerCase())) {
            yabanciMi = true;
            break;
          }
        }

        // Malzemelerde yabancı besin var mı?
        if (!yabanciMi) {
          for (var malzeme in yemek.malzemeler) {
            for (var yabanci in yabanciBesinler) {
              if (malzeme.toLowerCase().contains(yabanci.toLowerCase())) {
                yabanciMi = true;
                break;
              }
            }
            if (yabanciMi) break;
          }
        }

        if (yabanciMi) {
          // Yemeği Hive'dan direkt sil
          final box = Hive.box('yemekler');
          await box.delete(yemek.id);
          silinenSayisi++;
          AppLogger.info('🗑️ Silindi: ${yemek.ad}');
        }
      }

      setState(() {
        _statusMessage = '✅ $silinenSayisi yabancı besin temizlendi!';
      });

      // İstatistikleri güncelle
      await _loadStats();
      await _performHealthCheck();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $silinenSayisi yabancı besin temizlendi!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _statusMessage = '❌ Hata: $e';
      });
      AppLogger.error('Yabancı besin temizleme hatası',
          error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoCard() {
    return Container(
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
3. Kategori düzeltmeleri otomatik uygulanır
4. Tüm istatistikler güncellenir
5. Database sağlık kontrolü yapılır''',
            style: TextStyle(
                color: Colors.blue.shade900, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIssuesCard() {
    final bosKalori = _healthCheckResults!['bosKaloriYemek'] as int;
    final eksikMalzeme = _healthCheckResults!['eksikMalzemeYemek'] as int;
    final dusukKalori = _healthCheckResults!['cokDusukKaloriYemek'] as int;
    final yuksekKalori = _healthCheckResults!['cokYuksekKaloriYemek'] as int;

    return Container(
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
          const Text(
            'Tespit Edilen Sorunlar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildIssueRow('Boş kalori', bosKalori),
          _buildIssueRow('Eksik malzeme', eksikMalzeme),
          _buildIssueRow('Çok düşük kalori (<50)', dusukKalori),
          _buildIssueRow('Çok yüksek kalori (>2000)', yuksekKalori),
        ],
      ),
    );
  }

  Widget _buildIssueRow(String label, int count) {
    final hasIssue = count > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasIssue ? Icons.warning : Icons.check_circle,
            size: 20,
            color: hasIssue ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasIssue ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatsCard() {
    return Container(
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
          const Text(
            'Genel İstatistikler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Toplam Yemek',
                '${_healthCheckResults!['toplamYemek']}',
                Icons.restaurant_menu,
                Colors.blue,
              ),
              _buildStatItem(
                'Ort. Kalori',
                '${_healthCheckResults!['kaloriOrtalama']}',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatItem(
                'Ort. Protein',
                '${_healthCheckResults!['proteinOrtalama']}g',
                Icons.fitness_center,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
