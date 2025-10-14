// lib/test_makro_fix.dart
// 🔧 MAKRO VE KATEGORİ DÜZELTMESİ TEST WIDGET'I

import 'package:flutter/material.dart';
import 'data/local/hive_service.dart';
import 'core/utils/yemek_migration_guncel.dart';
import 'core/utils/app_logger.dart';

class TestMakroFixPage extends StatefulWidget {
  const TestMakroFixPage({super.key});

  @override
  State<TestMakroFixPage> createState() => _TestMakroFixPageState();
}

class _TestMakroFixPageState extends State<TestMakroFixPage> {
  String _status = 'Hazır';
  bool _isLoading = false;

  Future<void> _testMakroFix() async {
    setState(() {
      _isLoading = true;
      _status = '🔍 Test başlatılıyor...';
    });

    try {
      // 1. Mevcut durum kontrolü
      setState(() => _status = '📊 Mevcut durum kontrol ediliyor...');
      final mevcutSayi = await HiveService.yemekSayisi();
      AppLogger.info('Mevcut yemek sayısı: $mevcutSayi');

      // 2. DB'yi temizle
      setState(() => _status = '🗑️ DB temizleniyor...');
      await HiveService.tumYemekleriSil();
      AppLogger.success('✅ DB temizlendi');

      // 3. Yeni migration çalıştır
      setState(() => _status = '🔄 Migration başlatılıyor...');
      final basarili = await YemekMigration.jsonToHiveMigration();
      
      if (!basarili) {
        setState(() => _status = '❌ Migration başarısız!');
        return;
      }

      // 4. Yeni durum kontrolü
      setState(() => _status = '✅ Yeni durum kontrol ediliyor...');
      final yeniSayi = await HiveService.yemekSayisi();
      final kategoriSayilari = await HiveService.kategoriSayilari();

      // 5. 0 kalorili yemek kontrolü
      final tumYemekler = await HiveService.tumYemekleriGetir();
      final sifirKalorili = tumYemekler.where((y) => y.kalori == 0).length;

      // 6. Sonuçları göster
      String sonuc = '🎉 TEST TAMAMLANDI!\n\n';
      sonuc += '📊 Toplam yemek: $yeniSayi\n\n';
      sonuc += '📈 Kategori Dağılımı:\n';
      kategoriSayilari.forEach((k, v) => sonuc += '  $k: $v yemek\n');
      sonuc += '\n❌ 0 Kalorili yemek: $sifirKalorili';
      
      if (sifirKalorili == 0) {
        sonuc += '\n\n✅ BAŞARILI: Hiç 0 kalorili yemek yok!';
      } else {
        sonuc += '\n\n⚠️ DİKKAT: $sifirKalorili yemek hala 0 kalorili!';
      }

      setState(() => _status = sonuc);
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Test hatası', error: e, stackTrace: stackTrace);
      setState(() => _status = '❌ HATA: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makro & Kategori Fix Test'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔧 Makro ve Kategori Düzeltmesi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bu test:\n'
              '1. DB\'yi temizler\n'
              '2. Düzeltilmiş migration\'ı çalıştırır\n'
              '3. 0 kalorili yemekleri kontrol eder\n'
              '4. Kategori dağılımını gösterir',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testMakroFix,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('🚀 TESTI BAŞLAT', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}