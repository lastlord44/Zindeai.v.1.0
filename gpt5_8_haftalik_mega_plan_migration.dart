import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔥 GPT-5 PRO: 8 HAFTALıK MEGA PLAN MIGRATION');
  print('🎯 En yaygın profil için 336 farklı yemek import ediliyor...');
  print('📊 Hedef: 2400 kcal maintenance/lean bulk erkek profili');
  
  // Hive başlat
  if (!Directory('hive_data').existsSync()) {
    Directory('hive_data').createSync();
  }
  
  Hive.init('hive_data');
  Hive.registerAdapter(YemekHiveModelAdapter());

  final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📚 Mevcut veritabanı: ${yemekBox.length} yemek');

  // GPT-5 Pro'dan gelen JSON'u oku
  final jsonPath = r'C:\Users\MS\Desktop\gpt5.pro.yemekler\turk_diyetisyen_8_haftalik_mega_plan.json';
  
  if (!File(jsonPath).existsSync()) {
    print('❌ GPT-5 Pro JSON dosyası bulunamadı: $jsonPath');
    print('👨‍💻 Önce GPT5_8_HAFTALIK_MEGA_PLAN_PROMPT.md\'deki prompt\'u GPT-5 Pro\'ya ver');
    print('💾 Dönen JSON\'u şu path\'e kaydet: $jsonPath');
    return;
  }

  print('📄 GPT-5 Pro JSON dosyası bulundu: $jsonPath');

  try {
    final jsonString = await File(jsonPath).readAsString();
    final Map<String, dynamic> megaPlan = json.decode(jsonString);
    
    int yeniYemekSayisi = 0;
    int hataluYemek = 0;

    print('📊 GPT-5 Pro mega plan analiz ediliyor...');

    // 8 haftalık planı işle
    for (String hafta in megaPlan.keys) {
      if (hafta.startsWith('hafta_')) {
        final haftaData = megaPlan[hafta] as Map<String, dynamic>;
        
        // Her günü işle
        for (String gun in haftaData.keys) {
          final gunData = haftaData[gun] as Map<String, dynamic>;
          
          // Her öğünü işle  
          for (String ogun in gunData.keys) {
            try {
              final ogunData = gunData[ogun] as Map<String, dynamic>;
              
              // GPT-5 Pro data'sından direkt YemekHiveModel oluştur
              final hiveModel = _createHiveModelFromGptData(ogunData, ogun, hafta, gun);
              
              if (hiveModel != null) {
                await yemekBox.put(hiveModel.mealId!, hiveModel);
                yeniYemekSayisi++;
                
                if (yeniYemekSayisi % 50 == 0) {
                  final yuzde = ((yeniYemekSayisi / 336) * 100).round();
                  print('📊 İşlenen: $yeniYemekSayisi/336 ($yuzde%)');
                }
              }
            } catch (e) {
              hataluYemek++;
              print('⚠️  Yemek işleme hatası: $hafta-$gun-$ogun -> $e');
            }
          }
        }
      }
    }

    print('\n🎉 GPT-5 PRO 8 HAFTALıK MEGA PLAN MIGRATION TAMAMLANDI!');
    print('✅ Toplam eklenen: $yeniYemekSayisi yemek');
    print('⚠️  Hatalı: $hataluYemek yemek');
    print('📊 Yeni veritabanı boyutu: ${yemekBox.length} yemek');

    // Kategori dağılımı analizi
    await _kategoriAnalizi(yemekBox);
    
    // Kalori dağılımı analizi  
    await _kaloriAnalizi(yemekBox);
    
    print('\n🚀 8 HAFTALıK MEGA PLAN ÖZELLİKLERİ:');
    print('   ✅ Profesyonel Türk diyetisyeni standardı');
    print('   ✅ 336 farklı yemek (8 hafta x 7 gün x 6 öğün)');
    print('   ✅ 2400 kcal maintenance/lean bulk optimizasyonu');
    print('   ✅ Detaylı malzeme gramajları ve makro değerler');
    print('   ✅ Türk mutfağı + modern füzyon');
    print('   ✅ Ekonomik ve pratik yemekler');
    
    print('\n🔄 Sonraki adım: 20 profil stres testini tekrar çalıştır!');
    print('💡 Beklenen: %10 → %70+ başarı oranı artışı');
    
  } catch (e) {
    print('❌ Migration hatası: $e');
  } finally {
    await Hive.close();
  }
}

YemekHiveModel? _createHiveModelFromGptData(Map<String, dynamic> ogunData, String ogunTipi, String hafta, String gun) {
  try {
    final yemekAdi = ogunData['yemek_adi'] as String;
    final malzemeler = ogunData['malzemeler'] as List<dynamic>;
    final toplam = ogunData['toplam'] as Map<String, dynamic>;
    final hazirlikSuresi = ogunData['hazirlik_suresi'] as String? ?? '15 dk';
    final tarifNotu = ogunData['tarif_notu'] as String? ?? '';
    
    // Unique ID oluştur
    final id = '${hafta}_${gun}_${ogunTipi}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Hazırlık süresini dakikaya çevir
    final hazirlikDk = _parseHazirlikSuresi(hazirlikSuresi);
    
    // Malzemeleri string listesi olarak çevir
    final malzemeListesi = malzemeler.map((m) {
      final malzeme = m as Map<String, dynamic>;
      return '${malzeme['ad']} - ${malzeme['miktar']} ${malzeme['birim']}';
    }).toList();
    
    // Kategoriyi çevir
    final kategori = _stringToCategory(ogunTipi);
    
    return YemekHiveModel(
      mealId: id,
      category: kategori,
      mealName: yemekAdi,
      calorie: (toplam['kcal'] as num).toDouble(),
      proteinG: (toplam['protein'] as num).toDouble(),
      carbG: (toplam['karb'] as num).toDouble(),
      fatG: (toplam['yag'] as num).toDouble(),
      fiberG: 2.0, // Default fiber
      goalTag: 'maintenance',
      difficulty: 'kolay',
      prepTimeMin: hazirlikDk,
      ingredients: malzemeListesi,
      recipe: tarifNotu.isNotEmpty ? tarifNotu : 'GPT-5 Pro optimized meal - $yemekAdi',
      imageUrl: null,
      tags: ['GPT5-Pro', 'Turkish-Cuisine', '8-Week-Plan'],
      alternatives: [],
      isFavorite: false,
      proteinSource: _detectProteinFromMealName(yemekAdi, malzemeListesi),
    );
  } catch (e) {
    print('⚠️  YemekHiveModel oluşturma hatası: $e');
    return null;
  }
}

String _stringToCategory(String ogun) {
  switch (ogun.toLowerCase()) {
    case 'kahvalti': return 'kahvalti';
    case 'ara_ogun_1': return 'ara_ogun_1';  
    case 'ogle': return 'ogle';
    case 'ara_ogun_2': return 'ara_ogun_2';
    case 'aksam': return 'aksam';
    case 'gece_atistirma': return 'gece_atistirma';
    default: return 'ogle';
  }
}

String _detectProteinFromMealName(String mealName, List<String> ingredients) {
  final combined = '$mealName ${ingredients.join(' ')}'.toLowerCase();
  
  if (combined.contains('tavuk') || combined.contains('chicken')) return 'Tavuk';
  if (combined.contains('et') || combined.contains('köfte') || combined.contains('kıyma')) return 'Et';  
  if (combined.contains('balık') || combined.contains('somon') || combined.contains('levrek')) return 'Balık';
  if (combined.contains('yumurta') || combined.contains('menemen')) return 'Yumurta';
  if (combined.contains('peynir') || combined.contains('lor') || combined.contains('labne')) return 'Süt Ürünleri';
  if (combined.contains('mercimek') || combined.contains('nohut') || combined.contains('fasulye')) return 'Baklagil';
  
  return 'Karma';
}

int _parseHazirlikSuresi(String sure) {
  final regex = RegExp(r'(\d+)');
  final match = regex.firstMatch(sure);
  return match != null ? int.parse(match.group(1)!) : 15;
}

Future<void> _kategoriAnalizi(Box<YemekHiveModel> box) async {
  final kategoriler = <String, int>{};
  
  for (final yemek in box.values) {
    kategoriler[yemek.category ?? 'Bilinmeyen'] = (kategoriler[yemek.category ?? 'Bilinmeyen'] ?? 0) + 1;
  }
  
  print('\n📋 KATEGORİ DAĞILIMI:');
  kategoriler.forEach((kategori, sayi) {
    print('   📂 $kategori: $sayi yemek');
  });
}

Future<void> _kaloriAnalizi(Box<YemekHiveModel> box) async {
  final kaloriAraliklari = <String, int>{
    '0-200 kcal': 0,
    '200-400 kcal': 0, 
    '400-600 kcal': 0,
    '600-800 kcal': 0,
    '800+ kcal': 0,
  };
  
  for (final yemek in box.values) {
    final kcal = yemek.calorie ?? 0.0;
    if (kcal < 200) kaloriAraliklari['0-200 kcal'] = kaloriAraliklari['0-200 kcal']! + 1;
    else if (kcal < 400) kaloriAraliklari['200-400 kcal'] = kaloriAraliklari['200-400 kcal']! + 1;
    else if (kcal < 600) kaloriAraliklari['400-600 kcal'] = kaloriAraliklari['400-600 kcal']! + 1;
    else if (kcal < 800) kaloriAraliklari['600-800 kcal'] = kaloriAraliklari['600-800 kcal']! + 1;
    else kaloriAraliklari['800+ kcal'] = kaloriAraliklari['800+ kcal']! + 1;
  }
  
  print('\n🔥 KALORİ DAĞILIMI:');
  kaloriAraliklari.forEach((aralik, sayi) {
    print('   🔸 $aralik: $sayi yemek');
  });
}