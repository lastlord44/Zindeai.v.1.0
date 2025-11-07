// ============================================================================
// YEMEK DÜZELTME VE YENİ YEMEK EKLEME MİGRATION SERVİSİ
// Kalori/Makro Hesaplama Hatalarını Düzelt + Yeni Kaliteli Yemekler Ekle
// ============================================================================

import 'package:hive/hive.dart';
import '../../data/models/yemek_hive_model.dart';
import '../utils/app_logger.dart';
import '../../yeni_kaliteli_yemekler_batch.dart';

class YemekDuzeltmeMigration {
  /// ✅ 1. ADIM: Kalori-Makro Uyumsuzluklarını Düzelt
  static Future<int> kaloriMakroUyumsuzluklariniDuzelt() async {
    try {
      AppLogger.info('🔧 KALORİ-MAKRO UYUMSUZLUKLARI DÜZELTİLİYOR...');
      
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      int duzeltilen = 0;
      
      for (var key in box.keys) {
        final yemek = box.get(key);
        if (yemek == null) continue;
        
        // Kalori varsa ama makrolar hatalıysa düzelt
        if (yemek.calorie != null && yemek.calorie! > 0) {
          final protein = yemek.proteinG ?? 0.0;
          final karb = yemek.carbG ?? 0.0;
          final yag = yemek.fatG ?? 0.0;
          
          // Hesaplanan kalori
          final hesaplananKalori = (protein * 4) + (karb * 4) + (yag * 9);
          
          // %20'den fazla fark varsa düzelt
          final fark = (yemek.calorie! - hesaplananKalori).abs();
          final yuzde = hesaplananKalori > 0 ? (fark / yemek.calorie!) * 100 : 0;
          
          if (yuzde > 20 && fark > 20) {
            // Makroları kaloriye göre yeniden hesapla (eski oranları koruyarak)
            final toplamMakroKalori = hesaplananKalori;
            
            if (toplamMakroKalori > 0) {
              final carpan = yemek.calorie! / toplamMakroKalori;
              
              yemek.proteinG = protein * carpan;
              yemek.carbG = karb * carpan;
              yemek.fatG = yag * carpan;
              
              await box.put(key, yemek);
              duzeltilen++;
              
              AppLogger.debug('✅ Düzeltildi: ${yemek.mealName} - Kalori: ${yemek.calorie} kcal');
            }
          }
        }
      }
      
      AppLogger.info('✅ $duzeltilen yemek düzeltildi');
      return duzeltilen;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Kalori-makro düzeltme hatası', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  /// ✅ 2. ADIM: Sıfır Kalori Olan Yemekleri Sil veya Düzelt
  static Future<int> sifirKaloriYemekleriTemizle() async {
    try {
      AppLogger.info('🔧 SIFIR KALORİ YEMEKLER TEMİZLENİYOR...');
      
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      int silinen = 0;
      final silinecekKeys = <String>[];
      
      for (var key in box.keys) {
        final yemek = box.get(key);
        if (yemek == null) continue;
        
        // Kalori 0 veya null ise sil
        if (yemek.calorie == null || yemek.calorie! == 0) {
          silinecekKeys.add(key.toString());
        }
      }
      
      // Toplu silme
      for (var key in silinecekKeys) {
        await box.delete(key);
        silinen++;
      }
      
      AppLogger.info('✅ $silinen sıfır kalorili yemek silindi');
      return silinen;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Sıfır kalori temizleme hatası', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  /// ✅ 3. ADIM: Çok Düşük Kalori (<50) Olan Yemekleri Düzelt veya Sil
  static Future<int> dusukKaloriYemekleriDuzelt() async {
    try {
      AppLogger.info('🔧 DÜŞÜK KALORİ YEMEKLER DÜZELTİLİYOR...');
      
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      int duzeltilen = 0;
      final silinecekKeys = <String>[];
      
      for (var key in box.keys) {
        final yemek = box.get(key);
        if (yemek == null) continue;
        
        // Kalori < 50 ise değerlendir
        if (yemek.calorie != null && yemek.calorie! > 0 && yemek.calorie! < 50) {
          // Eğer gerçekten düşük kalorili bir atıştırmalık ise koru
          final kategori = yemek.category?.toLowerCase() ?? '';
          if (kategori.contains('ara') || kategori.contains('atıştırmalık')) {
            // Makroları kontrol et, makrolar makul ise koru
            final protein = yemek.proteinG ?? 0;
            final karb = yemek.carbG ?? 0;
            final yag = yemek.fatG ?? 0;
            
            if (protein > 1 || karb > 1 || yag > 0.5) {
              // Makrolar var, koru
              continue;
            }
          }
          
          // Aksi halde sil
          silinecekKeys.add(key.toString());
        }
      }
      
      // Toplu silme
      for (var key in silinecekKeys) {
        await box.delete(key);
        duzeltilen++;
      }
      
      AppLogger.info('✅ $duzeltilen düşük kalorili yemek temizlendi');
      return duzeltilen;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Düşük kalori düzeltme hatası', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  /// ✅ 4. ADIM: Yeni Kaliteli Yemekleri Ekle
  static Future<bool> yeniYemekleriEkle() async {
    try {
      AppLogger.info('🚀 YENİ KALİTELİ YEMEKLER EKLENİYOR...');
      
      final box = await Hive.openBox<YemekHiveModel>('yemekler');
      final baslangicSayisi = box.length;
      
      int yuklenen = 0;
      
      // KAHVALTI YEMEKLERİ
      try {
        final kahvaltilar = getKahvaltiYemekleri();
        for (var jsonYemek in kahvaltilar) {
          // ID çakışması kontrolü
          final mealId = jsonYemek['meal_id']?.toString();
          if (mealId != null && !box.containsKey(mealId)) {
            final yemek = YemekHiveModel.fromJson(jsonYemek);
            await box.put(yemek.mealId, yemek);
            yuklenen++;
          }
        }
        AppLogger.info('✅ Kahvaltı: ${kahvaltilar.length} yemek eklendi');
      } catch (e) {
        AppLogger.warning('⚠️ Kahvaltı yüklemede hata: $e');
      }
      
      // ÖĞLE YEMEKLERİ
      try {
        final ogleYemekleri = getOgleYemekleri();
        for (var jsonYemek in ogleYemekleri) {
          final mealId = jsonYemek['meal_id']?.toString();
          if (mealId != null && !box.containsKey(mealId)) {
            final yemek = YemekHiveModel.fromJson(jsonYemek);
            await box.put(yemek.mealId, yemek);
            yuklenen++;
          }
        }
        AppLogger.info('✅ Öğle: ${ogleYemekleri.length} yemek eklendi');
      } catch (e) {
        AppLogger.warning('⚠️ Öğle yüklemede hata: $e');
      }
      
      // AKŞAM YEMEKLERİ
      try {
        final aksamYemekleri = getAksamYemekleri();
        for (var jsonYemek in aksamYemekleri) {
          final mealId = jsonYemek['meal_id']?.toString();
          if (mealId != null && !box.containsKey(mealId)) {
            final yemek = YemekHiveModel.fromJson(jsonYemek);
            await box.put(yemek.mealId, yemek);
            yuklenen++;
          }
        }
        AppLogger.info('✅ Akşam: ${aksamYemekleri.length} yemek eklendi');
      } catch (e) {
        AppLogger.warning('⚠️ Akşam yüklemede hata: $e');
      }
      
      final bitisSayisi = box.length;
      
      AppLogger.info('═══════════════════════════════════════════');
      AppLogger.info('🎉 YENİ YEMEK EKLEME TAMAMLANDI!');
      AppLogger.info('📈 Önceki yemek sayısı: $baslangicSayisi');
      AppLogger.info('📈 Yeni yemek sayısı: $bitisSayisi');
      AppLogger.info('➕ Eklenen toplam: $yuklenen yemek');
      AppLogger.info('═══════════════════════════════════════════');
      
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yeni yemek ekleme hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// ⭐ KOMPLE MİGRATION: Tüm Düzeltmeleri ve Yeni Yemekleri Ekle
  static Future<Map<String, dynamic>> tumDuzeltmeleriYap() async {
    AppLogger.info('🎯 KOMPLE VERİTABANI DÜZELTMESİ BAŞLIYOR...\n');
    
    final baslangicZamani = DateTime.now();
    final sonuclar = <String, dynamic>{};
    
    try {
      // 1. Kalori-Makro uyumsuzluklarını düzelt
      final kaloriDuzeltme = await kaloriMakroUyumsuzluklariniDuzelt();
      sonuclar['kalori_duzeltme'] = kaloriDuzeltme;
      
      // 2. Sıfır kalorili yemekleri temizle
      final sifirKaloriTemizlik = await sifirKaloriYemekleriTemizle();
      sonuclar['sifir_kalori_temizlik'] = sifirKaloriTemizlik;
      
      // 3. Düşük kalorili yemekleri düzelt
      final dusukKaloriDuzeltme = await dusukKaloriYemekleriDuzelt();
      sonuclar['dusuk_kalori_duzeltme'] = dusukKaloriDuzeltme;
      
      // 4. Yeni kaliteli yemekleri ekle
      final yeniEkleme = await yeniYemekleriEkle();
      sonuclar['yeni_yemek_ekleme'] = yeniEkleme;
      
      final bitisZamani = DateTime.now();
      final sure = bitisZamani.difference(baslangicZamani);
      
      sonuclar['basarili'] = true;
      sonuclar['sure_saniye'] = sure.inSeconds;
      sonuclar['toplam_islem'] = kaloriDuzeltme + sifirKaloriTemizlik + dusukKaloriDuzeltme;
      
      AppLogger.info('\n═══════════════════════════════════════════');
      AppLogger.info('✅ TÜM DÜZELTMELER TAMAMLANDI!');
      AppLogger.info('⏱️ Süre: ${sure.inSeconds} saniye');
      AppLogger.info('🔧 Toplam İşlem: ${sonuclar['toplam_islem']}');
      AppLogger.info('═══════════════════════════════════════════\n');
      
      return sonuclar;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Komple düzeltme hatası', error: e, stackTrace: stackTrace);
      sonuclar['basarili'] = false;
      sonuclar['hata'] = e.toString();
      return sonuclar;
    }
  }
}