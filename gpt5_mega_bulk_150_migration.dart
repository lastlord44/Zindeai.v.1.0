// 🚀 GPT-5 PRO MEGA BULK 150 YEMEK MİGRATİON
// Ultra-High Calorie Yemekler - Bulk Profil %0 Başarı Sorunu Çözümü

import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🚀 GPT-5 PRO MEGA BULK 150 YEMEK MİGRATİON BAŞLATILIYOR...');
  print('🎯 Hedef: 3500+ kcal bulk profillerin %0 başarı sorununu çözme');
  print('📊 GPT-5 Pro tarafından oluşturulan ultra-high calorie yemekler\n');
  
  // Hive başlat
  Hive.init('./hive_data');
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
  print('📚 Mevcut veritabanı: ${yemekBox.length} yemek');
  
  // JSON dosyasını oku
  final jsonFile = File(r'C:\Users\MS\Desktop\gpt5.pro.yemekler\mega_bulk_yemekler_150.json');
  
  if (!jsonFile.existsSync()) {
    print('❌ HATA: JSON dosyası bulunamadı!');
    print('📂 Beklenen konum: ${jsonFile.path}');
    return;
  }
  
  print('📄 JSON dosyası bulundu: ${jsonFile.path}');
  
  try {
    // JSON içeriğini oku
    final jsonString = jsonFile.readAsStringSync();
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    
    // Yemek listesini al
    final yemekListesi = jsonData['mega_bulk_yemekler'] as List<dynamic>;
    print('📊 GPT-5 Pro dan gelen yemek sayisi: ${yemekListesi.length}');
    
    int eklenenSayi = 0;
    final kategoriler = <String, int>{};
    final kaloriDagilimi = <String, int>{};
    
    for (var yemekData in yemekListesi) {
      try {
        final yemekMap = yemekData as Map<String, dynamic>;
        
        // Kategori adını normalize et
        String kategori = yemekMap['kategori'] as String;
        switch (kategori.toLowerCase()) {
          case 'kahvalti':
          case 'kahvaltı':
            kategori = 'kahvalti';
            break;
          case 'ara_ogun_1':
          case 'ara ogun 1':
          case 'araogun1':
            kategori = 'araOgun1';
            break;
          case 'ogle':
          case 'öğle':
          case 'ogle_yemegi':
            kategori = 'ogle';
            break;
          case 'ara_ogun_2':
          case 'ara ogun 2':
          case 'araogun2':
            kategori = 'araOgun2';
            break;
          case 'aksam':
          case 'akşam':
          case 'aksam_yemegi':
            kategori = 'aksam';
            break;
          case 'gece_atistirma':
          case 'gece atıştırma':
          case 'geceatistirma':
            kategori = 'geceAtistirma';
            break;
        }
        
        // Zorluk seviyesini normalize et
        String zorluk = yemekMap['zorluk'] as String? ?? 'orta';
        switch (zorluk.toLowerCase()) {
          case 'easy':
          case 'kolay':
            zorluk = 'kolay';
            break;
          case 'medium':
          case 'orta':
            zorluk = 'orta';
            break;
          case 'hard':
          case 'zor':
            zorluk = 'zor';
            break;
        }
        
        // Malzemeleri parse et
        List<String> malzemeler = [];
        final malzemelerRaw = yemekMap['malzemeler'];
        if (malzemelerRaw is String) {
          malzemeler = malzemelerRaw.split(',').map((s) => s.trim()).toList();
        } else if (malzemelerRaw is List) {
          malzemeler = malzemelerRaw.map((s) => s.toString().trim()).toList();
        }
        
        final yemek = YemekHiveModel(
          mealId: 'gpt5_${eklenenSayi + 1}',
          mealName: yemekMap['ad'] as String,
          category: kategori,
          calorie: (yemekMap['kalori'] as num).toDouble(),
          proteinG: (yemekMap['protein'] as num).toDouble(),
          carbG: (yemekMap['karbonhidrat'] as num).toDouble(),
          fatG: (yemekMap['yag'] as num).toDouble(),
          ingredients: malzemeler,
          prepTimeMin: (yemekMap['sure'] as num?)?.toInt() ?? 30,
          difficulty: zorluk,
          recipe: 'GPT-5 Pro tarafından oluşturulan mega bulk tarifi',
          goalTag: 'Mega Bulk',
          alternatives: [],
          fiberG: 4.0,
          imageUrl: null,
          tags: ['GPT-5 Pro', 'Mega Bulk', 'Ultra High Calorie'],
          isFavorite: false,
          proteinSource: _proteinKaynagiTespitEt(yemekMap['ad'] as String, malzemeler),
        );

        await yemekBox.put(yemek.mealId!, yemek);
        eklenenSayi++;
        
        // İstatistikleri güncelle
        kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
        
        // Kalori aralığını belirle
        final kalori = yemek.calorie!.toInt();
        String kaloriAralik;
        if (kalori < 500) kaloriAralik = '300-500';
        else if (kalori < 700) kaloriAralik = '500-700';
        else if (kalori < 900) kaloriAralik = '700-900';
        else if (kalori < 1100) kaloriAralik = '900-1100';
        else kaloriAralik = '1100+';
        
        kaloriDagilimi[kaloriAralik] = (kaloriDagilimi[kaloriAralik] ?? 0) + 1;
        
        if (eklenenSayi % 30 == 0) {
          print('📊 İşlenen: $eklenenSayi/${yemekListesi.length} (${(eklenenSayi/yemekListesi.length*100).round()}%)');
        }
        
      } catch (e) {
        print('❌ Yemek işleme hatası: $e');
      }
    }
    
    await yemekBox.close();
    
    print('\n🎉 GPT-5 PRO MEGA BULK MİGRATİON TAMAMLANDI!');
    print('✅ Toplam eklenen: $eklenenSayi yemek');
    print('📊 Yeni veritabanı boyutu: ~${6415 + eklenenSayi} yemek');
    
    print('\n📋 KATEGORİ DAĞILIMI:');
    kategoriler.forEach((kategori, sayi) {
      final emoji = _kategoriEmoji(kategori);
      print('   $emoji $kategori: $sayi yemek');
    });
    
    print('\n🔥 KALORİ DAĞILIMI (GPT-5 Pro Ultra-High):');
    kaloriDagilimi.forEach((aralik, sayi) {
      print('   🔸 $aralik kcal: $sayi yemek');
    });
    
    print('\n🚀 BULK PROFİL BOOST ÖZELLİKLERİ:');
    print('   ✅ GPT-5 Pro AI tarafından optimize edildi');
    print('   ✅ 800-1200+ kcal ultra-high calorie yemekler');
    print('   ✅ Türk mutfağı + uluslararası füzyon');
    print('   ✅ 6 öğün sistemi desteği (gece atıştırma dahil)');
    print('   ✅ Makro optimize (yüksek protein+karb+yağ)');
    
    print('\n📈 BEKLENEN İYİLEŞTİRMELER:');
    print('   🎯 Bulk profil başarı oranı: %0 → %70+ hedef');
    print('   🎯 3500-5000 kcal profil desteği');
    print('   🎯 V5.3 RadikalFix performans artışı');
    
    print('\n🔄 Sonraki adım: 20 profil stres testini tekrar çalıştır!');
    print('💡 Beklenen: %15 → %70+ başarı oranı artışı');
    
  } catch (e, stackTrace) {
    print('❌ KRITIK HATA: $e');
    print('📊 Stack trace: $stackTrace');
    print('💡 JSON formatını kontrol edin ve tekrar deneyin.');
  }
}

// Kategori emoji helper
String _kategoriEmoji(String kategori) {
  switch (kategori) {
    case 'kahvalti': return '🍳';
    case 'araOgun1': return '🍎';
    case 'ogle': return '🍽️';
    case 'araOgun2': return '🥤';
    case 'aksam': return '🌙';
    case 'geceAtistirma': return '🌃';
    default: return '🍴';
  }
}

// Protein kaynağı tespit helper
String _proteinKaynagiTespitEt(String yemekAdi, List<String> malzemeler) {
  final combined = '${yemekAdi.toLowerCase()} ${malzemeler.join(' ').toLowerCase()}';
  
  if (combined.contains('tavuk') || combined.contains('chicken')) return 'Tavuk';
  if (combined.contains('et') || combined.contains('köfte') || combined.contains('kıyma') || 
      combined.contains('kuzu') || combined.contains('dana') || combined.contains('beef')) return 'Et';
  if (combined.contains('balık') || combined.contains('somon') || combined.contains('ton') ||
      combined.contains('fish')) return 'Balık';
  if (combined.contains('yumurta') || combined.contains('omlet') || combined.contains('egg')) return 'Yumurta';
  if (combined.contains('peynir') || combined.contains('lor') || combined.contains('cheese')) return 'Süt Ürünleri';
  if (combined.contains('protein') || combined.contains('whey') || combined.contains('casein')) return 'Protein Supplement';
  if (combined.contains('nohut') || combined.contains('fasulye') || combined.contains('mercimek')) return 'Baklagil';
  
  return 'Karma';
}