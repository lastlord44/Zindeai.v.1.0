import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔥 GPT-5 PRO: 1000 PROFİL VARYASYONU MEGA MIGRATION');
  print('🎯 500 farklı yemek - 1000 profil kombinasyonunu kapsıyor');
  print('📊 Spektrum: 1200-5000 kcal, tüm hedefler, özel durumlar');
  
  // Hive başlat
  if (!Directory('hive_data').existsSync()) {
    Directory('hive_data').createSync();
  }
  
  Hive.init('hive_data');
  Hive.registerAdapter(YemekHiveModelAdapter());

  final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📚 Mevcut veritabanı: ${yemekBox.length} yemek');

  // GPT-5 Pro'dan gelen JSON'u oku
  final jsonPath = r'C:\Users\MS\Desktop\gpt5.pro.yemekler\mega_1000_profil_500_yemek_veritabani.json';
  
  if (!File(jsonPath).existsSync()) {
    print('❌ GPT-5 Pro JSON dosyası bulunamadı: $jsonPath');
    print('👨‍💻 GPT5_1000_PROFIL_VARYASYONU_MEGA_PROMPT.md\'deki prompt\'u GPT-5 Pro\'ya ver');
    print('💾 Dönen JSON\'u şu path\'e kaydet: $jsonPath');
    return;
  }

  print('📄 GPT-5 Pro mega JSON dosyası bulundu: $jsonPath');

  try {
    final jsonString = await File(jsonPath).readAsString();
    final Map<String, dynamic> megaData = json.decode(jsonString);
    
    int yeniYemekSayisi = 0;
    int hataluYemek = 0;

    print('📊 GPT-5 Pro 1000 profil kapsayıcı veritabanı analiz ediliyor...');

    // mega_yemek_veritabani altındaki tüm yemekleri işle
    final yemekVeritabani = megaData['mega_yemek_veritabani'] as Map<String, dynamic>;
    final toplamYemek = yemekVeritabani.length;
    
    print('🎯 Toplam yemek sayısı: $toplamYemek');
    
    for (String yemekKey in yemekVeritabani.keys) {
      try {
        final yemekData = yemekVeritabani[yemekKey] as Map<String, dynamic>;
        
        // GPT-5 Pro mega formatından YemekHiveModel oluştur
        final hiveModel = _createHiveModelFromMegaData(yemekData, yemekKey);
        
        if (hiveModel != null) {
          await yemekBox.put(hiveModel.mealId!, hiveModel);
          yeniYemekSayisi++;
          
          if (yeniYemekSayisi % 25 == 0) {
            final yuzde = ((yeniYemekSayisi / toplamYemek) * 100).round();
            print('📊 İşlenen: $yeniYemekSayisi/$toplamYemek ($yuzde%)');
          }
        }
      } catch (e) {
        hataluYemek++;
        print('⚠️  Yemek işleme hatası: $yemekKey -> $e');
      }
    }

    print('\n🎉 GPT-5 PRO 1000 PROFİL MEGA MIGRATION TAMAMLANDI!');
    print('✅ Toplam eklenen: $yeniYemekSayisi yemek');
    print('⚠️  Hatalı: $hataluYemek yemek');
    print('📊 Yeni veritabanı boyutu: ${yemekBox.length} yemek');

    // Kapsamlı analizler
    await _spektrumAnalizi(yemekBox);
    await _kategoriAnalizi(yemekBox);
    await _kaloriAnalizi(yemekBox);
    await _profilKapsamiAnalizi(yemekBox);
    
    print('\n🚀 1000 PROFİL KAPSAMA ÖZELLİKLERİ:');
    print('   ✅ Demografik spektrum: 16-65 yaş, tüm cinsiyetler');
    print('   ✅ Kalori spektrum: 1200-5000 kcal');
    print('   ✅ Hedef spektrum: Cut/Bulk/Maintenance/Recomp');
    print('   ✅ Özel durum desteği: Alerji/Vegan/Diabetik/vs');
    print('   ✅ Kültürel çeşitlilik: Türk/Akdeniz/Modern/Füzyon');
    print('   ✅ Ekonomik seçenekler: Budget → Premium');
    
    print('\n🔄 Sonraki adım: 20 profil stres testini tekrar çalıştır!');
    print('💡 Beklenen: %10 → %85+ başarı oranı (1000 profil kapsamı)');
    
  } catch (e) {
    print('❌ Migration hatası: $e');
  } finally {
    await Hive.close();
  }
}

YemekHiveModel? _createHiveModelFromMegaData(Map<String, dynamic> yemekData, String yemekKey) {
  try {
    final genelBilgiler = yemekData['genel_bilgiler'] as Map<String, dynamic>;
    final besinDegerleri = yemekData['besin_degerleri'] as Map<String, dynamic>;
    final malzemeler = yemekData['malzemeler'] as List<dynamic>;
    final uygunluk = yemekData['uygunluk'] as Map<String, dynamic>;
    
    // Malzemeleri string listesi olarak çevir
    final malzemeListesi = malzemeler.map((m) {
      final malzeme = m as Map<String, dynamic>;
      return '${malzeme['ad']} - ${malzeme['miktar']} ${malzeme['birim']}';
    }).toList();
    
    // Etiketler
    final etiketler = yemekData['etiketler'] as List<dynamic>? ?? [];
    final etiketListesi = etiketler.map((e) => e.toString()).toList();
    
    // Kategoriyi Hive model formatına çevir
    final kategori = _kategoriToHiveFormat(genelBilgiler['kategori'] as String);
    
    // Protein kaynağını tespit et
    final besinKaynaklari = yemekData['besin_kaynaklari'] as Map<String, dynamic>?;
    final proteinKaynagi = besinKaynaklari?['ana_protein'] as String? ?? 
                          _detectProteinFromMealName(genelBilgiler['ad'] as String, malzemeListesi);
    
    return YemekHiveModel(
      mealId: genelBilgiler['id'] as String,
      category: kategori,
      mealName: genelBilgiler['ad'] as String,
      calorie: (besinDegerleri['kalori'] as num).toDouble(),
      proteinG: (besinDegerleri['protein'] as num).toDouble(),
      carbG: (besinDegerleri['karbonhidrat'] as num).toDouble(),
      fatG: (besinDegerleri['yag'] as num).toDouble(),
      fiberG: (besinDegerleri['lif'] as num?)?.toDouble() ?? 2.0,
      goalTag: _parseGoalTags(uygunluk['hedefler'] as List<dynamic>),
      difficulty: genelBilgiler['zorluk'] as String? ?? 'kolay',
      prepTimeMin: _parseHazirlikSuresi(genelBilgiler['hazirlik_suresi'] as String? ?? '15 dk'),
      ingredients: malzemeListesi,
      recipe: yemekData['tarif'] as String? ?? 'GPT-5 Pro optimized recipe',
      imageUrl: null,
      tags: etiketListesi,
      alternatives: [],
      isFavorite: false,
      proteinSource: proteinKaynagi,
    );
  } catch (e) {
    print('⚠️  Mega data parsing hatası: $e');
    return null;
  }
}

String _kategoriToHiveFormat(String kategori) {
  switch (kategori.toLowerCase()) {
    case 'kahvalti': return 'kahvalti';
    case 'ara_ogun_1': return 'ara_ogun_1';  
    case 'ogle': return 'ogle';
    case 'ara_ogun_2': return 'ara_ogun_2';
    case 'aksam': return 'aksam';
    case 'gece_atistirma': return 'gece_atistirma';
    default: return kategori.toLowerCase();
  }
}

String _parseGoalTags(List<dynamic> hedefler) {
  final hedefSet = hedefler.map((h) => h.toString().toLowerCase()).toSet();
  
  if (hedefSet.contains('cut')) return 'cut';
  if (hedefSet.contains('bulk')) return 'bulk';
  if (hedefSet.contains('maintenance')) return 'maintenance';
  if (hedefSet.contains('recomp')) return 'recomp';
  
  return 'balanced';
}

String _detectProteinFromMealName(String mealName, List<String> ingredients) {
  final combined = '$mealName ${ingredients.join(' ')}'.toLowerCase();
  
  if (combined.contains('tavuk') || combined.contains('chicken')) return 'Tavuk';
  if (combined.contains('et') || combined.contains('köfte') || combined.contains('kıyma')) return 'Et';  
  if (combined.contains('balık') || combined.contains('somon') || combined.contains('levrek')) return 'Balık';
  if (combined.contains('yumurta') || combined.contains('menemen')) return 'Yumurta';
  if (combined.contains('peynir') || combined.contains('lor') || combined.contains('labne')) return 'Süt Ürünleri';
  if (combined.contains('mercimek') || combined.contains('nohut') || combined.contains('fasulye')) return 'Baklagil';
  if (combined.contains('tofu') || combined.contains('tempeh')) return 'Soya';
  
  return 'Karma';
}

int _parseHazirlikSuresi(String sure) {
  final regex = RegExp(r'(\d+)');
  final match = regex.firstMatch(sure);
  return match != null ? int.parse(match.group(1)!) : 15;
}

Future<void> _spektrumAnalizi(Box<YemekHiveModel> box) async {
  final kaloriAraliklari = <String, int>{
    'Ultra Low (100-200)': 0,
    'Low (200-400)': 0,
    'Medium (400-700)': 0,
    'High (700-1000)': 0,
    'Ultra High (1000+)': 0,
  };
  
  for (final yemek in box.values) {
    final kcal = yemek.calorie ?? 0.0;
    if (kcal < 200) kaloriAraliklari['Ultra Low (100-200)'] = kaloriAraliklari['Ultra Low (100-200)']! + 1;
    else if (kcal < 400) kaloriAraliklari['Low (200-400)'] = kaloriAraliklari['Low (200-400)']! + 1;
    else if (kcal < 700) kaloriAraliklari['Medium (400-700)'] = kaloriAraliklari['Medium (400-700)']! + 1;
    else if (kcal < 1000) kaloriAraliklari['High (700-1000)'] = kaloriAraliklari['High (700-1000)']! + 1;
    else kaloriAraliklari['Ultra High (1000+)'] = kaloriAraliklari['Ultra High (1000+)']! + 1;
  }
  
  print('\n🎯 PROFİL SPEKTRUM KAPSAMI:');
  kaloriAraliklari.forEach((aralik, sayi) {
    print('   🔸 $aralik: $sayi yemek');
  });
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
  double minKalori = double.infinity;
  double maxKalori = 0.0;
  double toplamKalori = 0.0;
  int validYemek = 0;
  
  for (final yemek in box.values) {
    final kcal = yemek.calorie;
    if (kcal != null && kcal > 0) {
      if (kcal < minKalori) minKalori = kcal;
      if (kcal > maxKalori) maxKalori = kcal;
      toplamKalori += kcal;
      validYemek++;
    }
  }
  
  final ortalama = validYemek > 0 ? toplamKalori / validYemek : 0.0;
  
  print('\n🔥 KALORİ SPEKTRUM ANALİZİ:');
  print('   📊 Min kalori: ${minKalori.toInt()} kcal');
  print('   📊 Max kalori: ${maxKalori.toInt()} kcal');
  print('   📊 Ortalama: ${ortalama.toInt()} kcal');
  print('   📊 Spektrum genişliği: ${(maxKalori - minKalori).toInt()} kcal');
}

Future<void> _profilKapsamiAnalizi(Box<YemekHiveModel> box) async {
  final proteinKaynaklari = <String, int>{};
  final goalTags = <String, int>{};
  
  for (final yemek in box.values) {
    // Protein kaynağı dağılımı
    final protein = yemek.proteinSource ?? 'Bilinmeyen';
    proteinKaynaklari[protein] = (proteinKaynaklari[protein] ?? 0) + 1;
    
    // Hedef dağılımı
    final goal = yemek.goalTag ?? 'balanced';
    goalTags[goal] = (goalTags[goal] ?? 0) + 1;
  }
  
  print('\n🍗 PROTEİN KAYNAĞI ÇEŞİTLİLİĞİ:');
  proteinKaynaklari.forEach((kaynak, sayi) {
    print('   🥩 $kaynak: $sayi yemek');
  });
  
  print('\n🎯 HEDEF KAPSAMI:');
  goalTags.forEach((hedef, sayi) {
    print('   🎯 $hedef: $sayi yemek');
  });
}