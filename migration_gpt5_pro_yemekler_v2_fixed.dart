// migration_gpt5_pro_yemekler_v2_fixed.dart
// GPT-5 Pro V2.0 yemeklerini V6.0 Deterministik Sistem için migrate etme script'i (HATA DÜZELTİLMİŞ)
import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

void main() async {
  print('\n🚀 GPT-5 PRO V2.0 YEMEK MİGRATİON BAŞLIYOR! (FIXED)');
  print('═══════════════════════════════════════════════════');
  
  final gpt5ProPath = r'C:\Users\MS\Desktop\gpt5.pro.yemekler\v.2.0';
  
  int toplamYuklenen = 0;
  int basariliYukleme = 0;
  int hataliYemek = 0;
  final kategoriIstatistik = <OgunTipi, int>{};
  
  try {
    // 🔥 HIVE SERVİSİ BAŞLAT
    await HiveService.init();
    print('✅ Hive servisi başlatıldı\n');
    
    // Mevcut yemek sayısını kontrol et
    final mevcutSayisi = await HiveService.yemekSayisi();
    print('📊 Mevcut veritabanı: $mevcutSayisi yemek\n');
    
    // GPT-5 Pro klasörünü tara
    final gpt5Directory = Directory(gpt5ProPath);
    if (!gpt5Directory.existsSync()) {
      print('❌ HATA: GPT-5 Pro klasörü bulunamadı: $gpt5ProPath');
      return;
    }
    
    final jsonFiles = gpt5Directory
        .listSync()
        .where((file) => file.path.endsWith('.json') && !file.path.contains('kullanici_profilleri'))
        .toList();
        
    print('📁 Bulunan JSON dosyası: ${jsonFiles.length} adet');
    print('');
    
    // Her JSON dosyasını işle
    for (int i = 0; i < jsonFiles.length; i++) {
      final file = File(jsonFiles[i].path);
      final fileName = file.path.split(r'\').last;
      
      print('📄 İşleniyor [${"${i + 1}".padLeft(2)}/${jsonFiles.length}]: $fileName');
      
      try {
        final jsonContent = await file.readAsString(encoding: utf8);
        final List<dynamic> yemekListesi = json.decode(jsonContent);
        
        int batchBasarili = 0;
        int batchHatali = 0;
        
        for (final yemekJson in yemekListesi) {
          try {
            // GPT-5 Pro formatından YemekHiveModel'e çevir
            final hiveModel = _gpt5ProToHiveModel(yemekJson);
            
            if (hiveModel != null) {
              // HiveService kullanarak kaydet
              await HiveService.yemekKaydet(hiveModel);
              
              // Yemek entity'sine çevir ve kategori istatistiği güncelle
              final yemek = hiveModel.toEntity();
              kategoriIstatistik[yemek.ogun] = (kategoriIstatistik[yemek.ogun] ?? 0) + 1;
              
              batchBasarili++;
              basariliYukleme++;
            } else {
              batchHatali++;
              hataliYemek++;
            }
            toplamYuklenen++;
            
          } catch (e) {
            print('   ⚠️ Yemek parse hatası: ${e.toString().substring(0, 50)}...');
            batchHatali++;
            hataliYemek++;
            toplamYuklenen++;
          }
        }
        
        final basariYuzdesi = batchBasarili > 0 ? (batchBasarili / (batchBasarili + batchHatali) * 100) : 0;
        print('   ✅ $batchBasarili başarılı, ❌ $batchHatali hatalı (${basariYuzdesi.toStringAsFixed(1)}%)');
        
      } catch (e) {
        print('   ❌ Dosya okuma hatası: $e');
        continue;
      }
    }
    
    // Migration sonuçlarını raporla
    print('\n🏆 GPT-5 PRO V2.0 MİGRATİON TAMAMLANDI!');
    print('═══════════════════════════════════════════════════');
    print('📊 SONUÇ ÖZETİ:');
    print('   • Toplam işlenen: $toplamYuklenen yemek');
    print('   • Başarılı yükleme: $basariliYukleme yemek');
    print('   • Hatalı yemek: $hataliYemek yemek');
    
    final genelBasariYuzdesi = toplamYuklenen > 0 ? (basariliYukleme / toplamYuklenen * 100) : 0;
    print('   • Başarı oranı: ${genelBasariYuzdesi.toStringAsFixed(1)}%');
    print('');
    
    print('🍽️ KATEGORİ DAĞILIMI:');
    kategoriIstatistik.forEach((kategori, sayi) {
      print('   • ${kategori.ad}: $sayi yemek');
    });
    
    // Yeni toplam yemek sayısını kontrol et
    final yeniSayisi = await HiveService.yemekSayisi();
    final artis = yeniSayisi - mevcutSayisi;
    
    print('');
    print('📈 VERİTABANI DURUMU:');
    print('   • Önceki toplam: $mevcutSayisi yemek');
    print('   • Yeni toplam: $yeniSayisi yemek');
    print('   • Net artış: +$artis yemek');
    
    if (genelBasariYuzdesi >= 80) {
      print('\n🎊 MİGRATİON BAŞARILI! V6.0 sistemi güçlendirildi!');
    } else if (genelBasariYuzdesi >= 60) {
      print('\n⚠️ Migration tamamlandı ama bazı sorunlar var. İnceleme gerekli.');
    } else {
      print('\n❌ Migration sorunlu. Veri kalitesi kontrol edilmeli.');
    }
    
  } catch (e, stackTrace) {
    print('❌ KRİTİK HATA: $e');
    print('Stack trace: $stackTrace');
  }
}

/// GPT-5 Pro formatından YemekHiveModel'e çevirir
YemekHiveModel? _gpt5ProToHiveModel(Map<String, dynamic> gpt5Json) {
  try {
    // GPT-5 Pro JSON formatı analizi ve dönüşümü
    final ad = gpt5Json['ad'] ?? gpt5Json['name'] ?? gpt5Json['yemek_adi'] ?? gpt5Json['meal_name'];
    final kalori = _parseDouble(gpt5Json['kalori'] ?? gpt5Json['calories'] ?? gpt5Json['kcal']);
    final protein = _parseDouble(gpt5Json['protein'] ?? gpt5Json['protein_g']);
    final karbonhidrat = _parseDouble(gpt5Json['karbonhidrat'] ?? gpt5Json['carbs'] ?? gpt5Json['carbs_g']);
    final yag = _parseDouble(gpt5Json['yag'] ?? gpt5Json['fat'] ?? gpt5Json['fat_g']);
    final lif = _parseDouble(gpt5Json['lif'] ?? gpt5Json['fiber'] ?? gpt5Json['fiber_g'] ?? 0);
    
    // Kategori belirleme (GPT-5 Pro'nun verdiği kategoriye göre)
    final kategoriStr = gpt5Json['kategori'] ?? gpt5Json['category'] ?? gpt5Json['ogun_tipi'] ?? 'Öğle Yemeği';
    
    // Malzemeler listesi
    final malzemelerRaw = gpt5Json['malzemeler'] ?? gpt5Json['ingredients'] ?? [];
    final malzemeler = malzemelerRaw is List 
      ? malzemelerRaw.map((m) => m.toString()).toList()
      : <String>[];
    
    // Hazırlama süresi (opsiyonel)
    final hazirlamaSuresi = _parseInt(gpt5Json['hazirlamaasuresi'] ?? gpt5Json['prep_time'] ?? 15);
    
    // Minimum validasyon
    if (ad == null || ad.toString().trim().isEmpty || 
        kalori <= 0 || protein < 0 || karbonhidrat < 0 || yag < 0) {
      return null;
    }
    
    // YemekHiveModel oluştur
    final hiveModel = YemekHiveModel(
      mealId: YemekHiveModel.generateMealId(),
      mealName: ad.toString().trim(),
      category: kategoriStr.toString().trim(),
      calorie: kalori,
      proteinG: protein,
      carbG: karbonhidrat,
      fatG: yag,
      fiberG: lif,
      goalTag: gpt5Json['goal']?.toString() ?? 'cut',
      difficulty: gpt5Json['zorluk']?.toString() ?? 'kolay',
      prepTimeMin: hazirlamaSuresi,
      ingredients: malzemeler,
      recipe: gpt5Json['aciklama']?.toString() ?? gpt5Json['tarif']?.toString(),
      imageUrl: gpt5Json['gorselUrl']?.toString(),
      tags: malzemeler.isNotEmpty ? [malzemeler.first] : ['genel'],
      alternatives: [],
      isFavorite: false,
      proteinSource: gpt5Json['proteinKaynagi']?.toString(),
    );
    
    return hiveModel;
    
  } catch (e) {
    print('   ⚠️ Parse hatası: $e');
    return null;
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}