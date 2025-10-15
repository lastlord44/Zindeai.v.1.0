// ============================================================================
// lib/domain/services/ai_foto_analiz_servisi.dart
// AI FOTO ANALİZİ VE GÖRSELİ METNE ÇEVİRME SERVİSİ
// ============================================================================

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../../core/utils/app_logger.dart';

class AIFotoAnalizServisi {
  
  /// 📸 Yemek fotoğrafını analiz et ve besin değerlerini çıkar
  Future<Map<String, dynamic>> yemekFotoAnalizEt({
    required File fotoFile,
    double? porsiyon = 1.0,
  }) async {
    try {
      AppLogger.info('📸 AI Foto Analizi: Yemek fotoğrafı analiz ediliyor...');
      
      // Fotoğrafı base64'e çevir
      final bytes = await fotoFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Mock analiz (gerçek API sonra entegre edilecek)
      final analiz = await _mockYemekAnalizi(base64Image, porsiyon ?? 1.0);
      
      AppLogger.success('✅ AI Foto Analizi: Yemek başarıyla analiz edildi');
      return analiz;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Foto Analizi Hatası', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🥗 Besin fotoğrafını analiz et ve makro değerleri hesapla
  Future<Map<String, dynamic>> besinFotoAnalizEt({
    required Uint8List imageBytes,
    double? porsiyon = 1.0,
  }) async {
    try {
      AppLogger.info('🥗 AI Besin Analizi: Foto analiz ediliyor...');
      
      // Base64'e çevir
      final base64Image = base64Encode(imageBytes);
      
      // Mock analiz
      final analiz = await _mockBesinAnalizi(base64Image, porsiyon ?? 1.0);
      
      AppLogger.success('✅ AI Besin Analizi tamamlandı');
      return analiz;
      
    } catch (e) {
      AppLogger.error('❌ AI Besin Analizi Hatası: $e');
      rethrow;
    }
  }

  /// 🎯 Kamera ile canlı yemek tanıma
  Future<Map<String, dynamic>> canliYemekTanima({
    required Uint8List cameraBytes,
  }) async {
    try {
      AppLogger.info('🎯 AI Canlı Tanıma: Real-time analiz...');
      
      final base64Image = base64Encode(cameraBytes);
      final analiz = await _mockCanliAnaliz(base64Image);
      
      return analiz;
      
    } catch (e) {
      AppLogger.error('❌ AI Canlı Tanıma Hatası: $e');
      return {'tanindi': false, 'hata': e.toString()};
    }
  }

  /// Mock yemek analizi (geliştirme amaçlı)
  Future<Map<String, dynamic>> _mockYemekAnalizi(String base64Image, double porsiyon) async {
    await Future.delayed(Duration(milliseconds: 1500)); // API simulasyonu
    
    // Rastgele yemek türleri (Türk mutfağı odaklı)
    final rastgeleYemekler = [
      {
        'ad': 'Izgara Tavuk Göğsü',
        'kalori': 165.0 * porsiyon,
        'protein': 31.0 * porsiyon,
        'karbonhidrat': 0.0 * porsiyon,
        'yag': 3.6 * porsiyon,
        'guvenlilk': 0.92,
      },
      {
        'ad': 'Bulgur Pilavı',
        'kalori': 83.0 * porsiyon,
        'protein': 3.1 * porsiyon,
        'karbonhidrat': 18.6 * porsiyon,
        'yag': 0.2 * porsiyon,
        'guvenlilk': 0.88,
      },
      {
        'ad': 'Mercimek Çorbası',
        'kalori': 116.0 * porsiyon,
        'protein': 9.0 * porsiyon,
        'karbonhidrat': 20.0 * porsiyon,
        'yag': 0.4 * porsiyon,
        'guvenlilk': 0.85,
      },
      {
        'ad': 'Yoğurt',
        'kalori': 59.0 * porsiyon,
        'protein': 10.0 * porsiyon,
        'karbonhidrat': 3.6 * porsiyon,
        'yag': 0.4 * porsiyon,
        'guvenlilk': 0.94,
      },
    ];
    
    final secilen = rastgeleYemekler[DateTime.now().millisecond % rastgeleYemekler.length];
    
    return {
      'basarili': true,
      'yemek': secilen,
      'porsiyon': porsiyon,
      'analiz_suresi': '1.5s',
      'oneriler': [
        'Protein miktarını artırmak için yumurta ekleyebilirsiniz',
        'Karbon miktarını düşürmek için porsiyon azaltabilirsiniz',
      ],
    };
  }

  /// Mock besin analizi
  Future<Map<String, dynamic>> _mockBesinAnalizi(String base64Image, double porsiyon) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    return {
      'basarili': true,
      'tanınan_besinler': [
        {
          'ad': 'Domates',
          'miktar': '150g',
          'kalori': 27.0 * porsiyon,
          'protein': 1.4 * porsiyon,
          'karbonhidrat': 5.8 * porsiyon,
          'yag': 0.2 * porsiyon,
        },
        {
          'ad': 'Salatalık',
          'miktar': '100g',
          'kalori': 16.0 * porsiyon,
          'protein': 0.7 * porsiyon,
          'karbonhidrat': 3.6 * porsiyon,
          'yag': 0.1 * porsiyon,
        },
      ],
      'toplam_kalori': 43.0 * porsiyon,
      'analiz_guvenliligi': 0.91,
    };
  }

  /// Mock canlı analiz
  Future<Map<String, dynamic>> _mockCanliAnaliz(String base64Image) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return {
      'tanindi': true,
      'hizli_tanim': 'Yemek tespit edildi',
      'guvenlilk': 0.87,
      'oneri': 'Daha net fotoğraf için yaklaşın',
    };
  }
}