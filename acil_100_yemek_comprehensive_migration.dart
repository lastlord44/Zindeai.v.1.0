// 🚨 100 YEMEK COMPREHENSİVE MİGRATİON
// Stres Test Sonuçlarına Göre Kritik Eksiklikleri Giderme
// Bulk Profillerin %0 Başarı Sorununu Çözme

import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🚨 100 YEMEK COMPREHENSİVE MİGRATİON BAŞLATILIYOR...');
  print('🎯 Hedef: Bulk profillerin %0 başarı sorununu çözme');
  print('📊 Kritik eksiklikler: Yüksek kalori + Makro dengesizlik\n');
  
  // Hive başlat
  Hive.init('./hive_data');
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
  print('📚 Mevcut veritabanı: ${yemekBox.length} yemek');
  
  // 🔥 100 YEMEK - KATEGORİZE EDİLMİŞ VE MAKRO OPTİMİZE
  final yemekler = [
    
    // 🍽️ YÜKSEK KALORİLİ ÖĞLE YEMEKLERİ (40 adet) - 600-900 kcal
    ['Etli Nohut Yemeği', 'ogle', 750, 45, 65, 28, 'Nohut,Kuşbaşı Et,Soğan,Domates', 60, 'orta'],
    ['Tavuklu Pilav Kombo', 'ogle', 820, 50, 85, 32, 'Tavuk,Pirinç,Tereyağı,Bulgur', 45, 'orta'],
    ['Adana Kebap Porsiyon', 'ogle', 680, 42, 35, 38, 'Kuzu Kıyma,Lavaş,Salata,Yoğurt', 25, 'orta'],
    ['Etli Kuru Fasulye', 'ogle', 720, 38, 68, 25, 'Kuru Fasulye,Dana Eti,Bulgur', 50, 'orta'],
    ['İskender Kebap', 'ogle', 850, 48, 62, 42, 'Et,Lavaş,Yoğurt,Tereyağı,Domates', 20, 'orta'],
    ['Tavuk Döner Combo', 'ogle', 780, 55, 58, 35, 'Tavuk,Lavaş,Pilav,Salata', 15, 'kolay'],
    ['Etli Güveç Yemeği', 'ogle', 690, 40, 48, 32, 'Dana,Patlıcan,Patates,Domates', 65, 'orta'],
    ['Kuzu Tandır Menu', 'ogle', 920, 65, 45, 48, 'Kuzu,Patates,Bulgur,Salata', 120, 'zor'],
    ['Etli Türlü Yemeği', 'ogle', 650, 35, 55, 28, 'Et,Kabak,Patlıcan,Biber', 55, 'orta'],
    ['Tavuklu Bulgur Pilavı', 'ogle', 740, 48, 72, 26, 'Tavuk,Bulgur,Tereyağı,Et Suyu', 40, 'orta'],
    ['Mantı Porsiyon', 'ogle', 680, 32, 78, 22, 'Hamur,Kıyma,Yoğurt,Tereyağı', 90, 'zor'],
    ['Etli Makarna', 'ogle', 720, 38, 82, 28, 'Makarna,Kıyma,Domates,Peynir', 30, 'kolay'],
    ['Tavuk Şiş Menu', 'ogle', 660, 52, 38, 28, 'Tavuk,Bulgur,Salata,Lavaş', 35, 'orta'],
    ['Etli Sebze Güveç', 'ogle', 610, 35, 45, 25, 'Et,Sebze,Patates,Bulgur', 50, 'orta'],
    ['Fırın Kebap', 'ogle', 800, 48, 52, 38, 'Kuzu,Patates,Soğan,Pilav', 75, 'orta'],
    ['Tavuklu Nohut', 'ogle', 690, 42, 58, 24, 'Tavuk,Nohut,Bulgur,Tereyağı', 45, 'orta'],
    ['Etli Dolma', 'ogle', 620, 32, 68, 22, 'Biber,Pirinç,Kıyma,Domates', 70, 'orta'],
    ['Kuşbaşı Güveç', 'ogle', 760, 45, 48, 35, 'Kuşbaşı,Sebze,Bulgur', 55, 'orta'],
    ['Tavuk Sote Menu', 'ogle', 580, 48, 32, 28, 'Tavuk,Mantar,Biber,Pilav', 30, 'orta'],
    ['Etli Bezelye', 'ogle', 640, 38, 52, 22, 'Et,Bezelye,Havuç,Bulgur', 45, 'orta'],
    ['Tavuklu Sebze Sote', 'ogle', 590, 45, 35, 25, 'Tavuk,Karışık Sebze,Bulgur', 35, 'orta'],
    ['Karnıyarık Menu', 'ogle', 650, 32, 48, 32, 'Patlıcan,Kıyma,Pilav,Salata', 50, 'orta'],
    ['Etli Bamya', 'ogle', 580, 35, 42, 24, 'Bamya,Et,Bulgur,Domates', 45, 'orta'],
    ['Tavuk Kapama', 'ogle', 700, 48, 45, 32, 'Tavuk,Patates,Havuç,Pilav', 50, 'orta'],
    ['Etli Pırasa', 'ogle', 560, 32, 38, 26, 'Pırasa,Et,Havuç,Bulgur', 40, 'orta'],
    ['Fırında Tavuk Menu', 'ogle', 720, 52, 48, 32, 'Tavuk,Patates,Sebze,Pilav', 60, 'orta'],
    ['Etli Lahana Dolması', 'ogle', 630, 35, 55, 24, 'Lahana,Pirinç,Kıyma', 60, 'orta'],
    ['Tavuklu Pilav Özel', 'ogle', 780, 48, 82, 28, 'Tavuk,Pirinç,Kuruyemiş,Tereyağı', 45, 'orta'],
    ['Urfa Kebap Menu', 'ogle', 720, 45, 42, 35, 'Kıyma,Lavaş,Bulgur,Salata', 30, 'orta'],
    ['Etli Karnabahar', 'ogle', 540, 32, 35, 24, 'Karnabahar,Et,Bulgur', 35, 'orta'],
    ['Tavuk Yahnisi', 'ogle', 620, 42, 38, 28, 'Tavuk,Soğan,Patates,Bulgur', 45, 'orta'],
    ['Etli Kereviz', 'ogle', 520, 28, 35, 22, 'Kereviz,Et,Havuç,Bulgur', 40, 'orta'],
    ['Fırın Et Menu', 'ogle', 820, 55, 52, 38, 'Dana,Patates,Soğan,Pilav', 90, 'orta'],
    ['Tavuklu Türlü', 'ogle', 580, 42, 45, 24, 'Tavuk,Sebze,Bulgur', 45, 'orta'],
    ['Etli Ispanak', 'ogle', 560, 35, 32, 26, 'Ispanak,Et,Bulgur,Yoğurt', 35, 'kolay'],
    ['Kuzu Güveç Özel', 'ogle', 860, 58, 48, 45, 'Kuzu,Sebze,Bulgur,Tereyağı', 80, 'orta'],
    ['Tavuklu Bezelye', 'ogle', 590, 45, 48, 22, 'Tavuk,Bezelye,Bulgur', 40, 'orta'],
    ['Etli Taze Fasulye', 'ogle', 570, 32, 45, 24, 'Taze Fasulye,Et,Bulgur', 40, 'orta'],
    ['Tavuk Rosto Menu', 'ogle', 740, 52, 42, 35, 'Tavuk,Patates,Havuç,Pilav', 70, 'orta'],
    ['Özbek Pilavı', 'ogle', 820, 42, 95, 32, 'Pirinç,Et,Havuç,Kuruyemiş', 50, 'orta'],

    // 🌙 BESLEYİCİ AKŞAM YEMEKLERİ (25 adet) - 400-650 kcal
    ['Izgara Tavuk Porsiyon', 'aksam', 480, 52, 18, 22, 'Tavuk,Salata,Bulgur,Zeytinyağı', 25, 'kolay'],
    ['Fırın Somon Menu', 'aksam', 520, 48, 22, 28, 'Somon,Sebze,Bulgur', 30, 'orta'],
    ['Tavuk Şnitzel', 'aksam', 580, 45, 35, 26, 'Tavuk,Galeta Unu,Salata', 25, 'orta'],
    ['Izgara Köfte', 'aksam', 490, 38, 24, 26, 'Köfte,Salata,Bulgur', 20, 'kolay'],
    ['Fırın Levrek', 'aksam', 420, 42, 15, 22, 'Levrek,Sebze,Zeytinyağı', 35, 'orta'],
    ['Tavuk Fajita', 'aksam', 540, 48, 38, 24, 'Tavuk,Biber,Lavaş,Salata', 20, 'kolay'],
    ['Izgara Dana', 'aksam', 560, 48, 12, 32, 'Dana,Salata,Sebze', 20, 'orta'],
    ['Fırın Dorada', 'aksam', 450, 45, 18, 24, 'Dorada,Patates,Sebze', 40, 'orta'],
    ['Tavuk Cordon Bleu', 'aksam', 620, 52, 28, 32, 'Tavuk,Peynir,Jambon,Salata', 35, 'orta'],
    ['Sebzeli Köfte', 'aksam', 470, 35, 32, 22, 'Köfte,Sebze,Bulgur', 25, 'kolay'],
    ['Tavuk Teriyaki', 'aksam', 510, 46, 35, 20, 'Tavuk,Sebze,Sos', 25, 'orta'],
    ['Fırın Çupra', 'aksam', 440, 44, 16, 22, 'Çupra,Sebze,Zeytinyağı', 35, 'orta'],
    ['Izgara Tavuk Salata', 'aksam', 390, 45, 18, 16, 'Tavuk,Yeşillik,Domates', 15, 'kolay'],
    ['Balık Tava', 'aksam', 520, 42, 22, 28, 'Balık,Un,Salata,Pilav', 20, 'kolay'],
    ['Tavuk Steak', 'aksam', 540, 50, 15, 28, 'Tavuk,Mantar,Salata', 20, 'orta'],
    ['Sebze Güveç Light', 'aksam', 320, 12, 42, 16, 'Sebze,Zeytinyağı,Bulgur', 40, 'kolay'],
    ['Fırın Tavuk But', 'aksam', 580, 48, 25, 30, 'Tavuk But,Patates,Sebze', 50, 'orta'],
    ['Izgara Balık Menu', 'aksam', 460, 46, 18, 24, 'Balık,Salata,Bulgur', 25, 'kolay'],
    ['Tavuk Wrap', 'aksam', 480, 42, 45, 18, 'Tavuk,Tortilla,Salata', 15, 'kolay'],
    ['Sebzeli Omlet', 'aksam', 380, 28, 15, 24, 'Yumurta,Sebze,Peynir', 15, 'kolay'],
    ['Fırın Palamut', 'aksam', 420, 48, 12, 22, 'Palamut,Sebze,Zeytinyağı', 30, 'orta'],
    ['Tavuk Caesar Salad', 'aksam', 450, 48, 22, 20, 'Tavuk,Marul,Kruton,Sos', 15, 'kolay'],
    ['Izgara Somon Salata', 'aksam', 520, 45, 18, 28, 'Somon,Yeşillik,Avokado', 20, 'kolay'],
    ['Sebze Burger', 'aksam', 420, 18, 52, 18, 'Sebze Köfte,Ekmek,Salata', 20, 'kolay'],
    ['Fırın Tavuk Göğüs', 'aksam', 440, 52, 12, 22, 'Tavuk Göğüs,Sebze', 25, 'kolay'],

    // 💪 YÜKSEK PROTEİN ARA ÖĞÜNLER (20 adet) - 250-450 kcal
    ['Protein Shake Özel', 'araOgun2', 350, 35, 28, 8, 'Protein Tozu,Süt,Muz,Yulaf', 5, 'kolay'],
    ['Yumurtalı Sandviç', 'araOgun2', 420, 28, 38, 18, 'Yumurta,Ekmek,Peynir,Domates', 10, 'kolay'],
    ['Protein Bar Ev Yapımı', 'araOgun2', 380, 25, 42, 12, 'Protein Tozu,Yulaf,Bal,Fındık', 15, 'kolay'],
    ['Lor Peyniri Mix', 'araOgun2', 320, 28, 22, 12, 'Lor Peyniri,Ceviz,Bal,Meyve', 5, 'kolay'],
    ['Protein Smoothie Bowl', 'araOgun2', 400, 32, 45, 10, 'Protein,Meyve,Granola,Süt', 5, 'kolay'],
    ['Peynirli Omlet', 'araOgun2', 360, 26, 8, 26, 'Yumurta,Peynir,Sebze', 10, 'kolay'],
    ['Labne Wrap', 'araOgun2', 330, 22, 35, 14, 'Labne,Lavaş,Sebze,Zeytinyağı', 5, 'kolay'],
    ['Tuna Salad Sandwich', 'araOgun2', 380, 32, 28, 16, 'Ton Balığı,Ekmek,Sebze', 8, 'kolay'],
    ['Greek Yogurt Bowl', 'araOgun2', 290, 20, 35, 8, 'Yoğurt,Granola,Meyve,Bal', 3, 'kolay'],
    ['Protein Pancake', 'araOgun2', 420, 28, 48, 12, 'Protein Tozu,Yulaf,Yumurta', 15, 'kolay'],
    ['Kuruyemiş Mix', 'araOgun2', 450, 18, 22, 36, 'Badem,Ceviz,Fındık,Kuru Meyve', 1, 'kolay'],
    ['Peynir Kraker Combo', 'araOgun2', 320, 22, 28, 16, 'Kraker,Beyaz Peynir,Domates', 3, 'kolay'],
    ['Protein Muffin', 'araOgun2', 350, 24, 38, 14, 'Protein Tozu,Un,Yumurta,Muz', 25, 'orta'],
    ['Avokado Toast', 'araOgun2', 380, 12, 32, 24, 'Avokado,Tam Buğday Ekmek', 5, 'kolay'],
    ['Hummus Sebze', 'araOgun2', 280, 12, 32, 16, 'Hummus,Havuç,Salatalık,Biber', 5, 'kolay'],
    ['Protein Puding', 'araOgun2', 320, 30, 28, 8, 'Protein Tozu,Süt,Chia', 10, 'kolay'],
    ['Egg Muffin', 'araOgun2', 340, 24, 18, 20, 'Yumurta,Sebze,Peynir', 20, 'orta'],
    ['Süzme Yoğurt Bowl', 'araOgun2', 300, 25, 32, 6, 'Süzme Yoğurt,Granola,Meyve', 3, 'kolay'],
    ['Trail Mix Premium', 'araOgun2', 420, 15, 35, 28, 'Kuruyemiş,Kuru Meyve,Çikolata', 1, 'kolay'],
    ['Protein Bite', 'araOgun2', 290, 20, 25, 14, 'Protein Tozu,Hurma,Badem', 10, 'kolay'],

    // 🍳 KALORİ YOĞUN KAHVALTILAR (15 adet) - 450-700 kcal
    ['Türk Kahvaltısı Özel', 'kahvalti', 680, 28, 55, 38, 'Peynir,Tereyağı,Bal,Reçel,Ekmek,Zeytin', 15, 'kolay'],
    ['Menemen Combo', 'kahvalti', 520, 24, 32, 32, 'Yumurta,Domates,Biber,Peynir,Ekmek', 15, 'kolay'],
    ['Sucuklu Yumurta Özel', 'kahvalti', 580, 32, 28, 38, 'Yumurta,Sucuk,Peynir,Ekmek', 12, 'kolay'],
    ['Börek Porsiyon', 'kahvalti', 650, 25, 58, 35, 'Yufka,Peynir,Yumurta,Süt,Tereyağı', 40, 'orta'],
    ['Çılbır Özel', 'kahvalti', 480, 28, 22, 32, 'Yumurta,Yoğurt,Tereyağı,Ekmek', 20, 'orta'],
    ['Avokado Toast Deluxe', 'kahvalti', 540, 18, 45, 32, 'Avokado,Tam Buğday Ekmek,Yumurta', 10, 'kolay'],
    ['Protein Kahvaltı', 'kahvalti', 620, 45, 38, 28, 'Protein Tozu,Yulaf,Süt,Meyve,Fındık', 8, 'kolay'],
    ['Peynirli Omlet Özel', 'kahvalti', 450, 32, 18, 28, 'Yumurta,Peynir,Sebze,Ekmek', 15, 'kolay'],
    ['Granola Bowl Premium', 'kahvalti', 520, 18, 68, 22, 'Granola,Yoğurt,Meyve,Bal,Kuruyemiş', 5, 'kolay'],
    ['Simit Peynir Combo', 'kahvalti', 480, 22, 58, 20, 'Simit,Peynir,Domates,Reçel', 5, 'kolay'],
    ['Pancake Stack', 'kahvalti', 590, 20, 82, 22, 'Un,Süt,Yumurta,Bal,Tereyağı', 20, 'orta'],
    ['Kahvaltı Tabağı Zengin', 'kahvalti', 720, 32, 65, 42, 'Karma Peynir,Zeytin,Reçel,Bal,Ekmek', 10, 'kolay'],
    ['French Toast', 'kahvalti', 560, 18, 68, 24, 'Ekmek,Süt,Yumurta,Tereyağı,Bal', 15, 'kolay'],
    ['Protein Waffle', 'kahvalti', 480, 28, 52, 18, 'Protein Tozu,Un,Yumurta,Süt', 15, 'orta'],
    ['Açık Büfe Kahvaltı', 'kahvalti', 650, 28, 72, 32, 'Peynir,Zeytin,Reçel,Yumurta,Ekmek', 20, 'kolay'],
  ];

  print('📥 ${yemekler.length} YEMEK COMPREHENSİVE PAKET yükleniyor...\n');

  int eklenenSayi = 0;
  final kategoriler = {'kahvalti': 0, 'araOgun1': 0, 'ogle': 0, 'araOgun2': 0, 'aksam': 0};
  
  for (var yemekData in yemekler) {
    try {
      final yemek = YemekHiveModel(
        mealId: 'comp_${eklenenSayi + 1}',
        mealName: yemekData[0] as String,
        category: yemekData[1] as String,
        calorie: (yemekData[2] as int).toDouble(),
        proteinG: (yemekData[3] as int).toDouble(),
        carbG: (yemekData[4] as int).toDouble(),
        fatG: (yemekData[5] as int).toDouble(),
        ingredients: (yemekData[6] as String).split(','),
        prepTimeMin: yemekData[7] as int,
        difficulty: yemekData[8] as String,
        recipe: 'Türk mutfağı comprehensive yemek - Bulk profiller için optimize',
        goalTag: 'Bulk Friendly',
        alternatives: [],
        fiberG: 3.0,
        imageUrl: null,
        tags: ['Yüksek Kalori', 'Bulk', 'Türk Mutfağı'],
        isFavorite: false,
        proteinSource: _proteinKaynagiTespitEt(yemekData[0] as String, yemekData[6] as String),
      );

      await yemekBox.put(yemek.mealId!, yemek);
      eklenenSayi++;
      kategoriler[yemekData[1] as String] = (kategoriler[yemekData[1] as String] ?? 0) + 1;
      
      if (eklenenSayi % 25 == 0) {
        print('📊 İşlenen: $eklenenSayi/${yemekler.length} (${(eklenenSayi/yemekler.length*100).round()}%)');
      }
      
    } catch (e) {
      print('❌ Hata: ${yemekData[0]} - $e');
    }
  }

  await yemekBox.close();
  
  print('\n🎉 COMPREHENSİVE MİGRATİON TAMAMLANDI!');
  print('✅ Toplam eklenen: $eklenenSayi yemek');
  print('📊 Yeni veritabanı boyutu: ${yemekBox.length + eklenenSayi} yemek');
  
  print('\n📋 KATEGORİ DAĞILIMI:');
  print('   🍳 Kahvaltı: ${kategoriler['kahvalti']} yemek (450-700 kcal)');
  print('   🍽️ Öğle: ${kategoriler['ogle']} yemek (600-900 kcal) ⚡');
  print('   🌙 Akşam: ${kategoriler['aksam']} yemek (400-650 kcal)');
  print('   🍎 Ara Öğün 1: ${kategoriler['araOgun1']} yemek');
  print('   🥤 Ara Öğün 2: ${kategoriler['araOgun2']} yemek (250-450 kcal) 💪');
  
  print('\n🚀 BULK PROFİL OPTİMİZASYONLARI:');
  print('   ✅ Yüksek kalori yemekleri eklendi (600-900 kcal)');
  print('   ✅ Protein açısından zengin ara öğünler');
  print('   ✅ Makro dengesi optimize edildi');
  print('   ✅ Türk mutfağı kültürel uyumluluk');
  
  print('\n💡 BEKLENEN İYİLEŞTİRMELER:');
  print('   📈 Bulk profil başarı oranı: %0 → %70+ hedefi');
  print('   📈 Yüksek kalori toleransı artırılması');
  print('   📈 V5.3 RadikalFix performans boost');
  
  print('\n🔄 Sonraki adım: Stres testi tekrarla!');
}

// Protein kaynağı tespit helper
String _proteinKaynagiTespitEt(String yemekAdi, String malzemeler) {
  final combined = '${yemekAdi.toLowerCase()} ${malzemeler.toLowerCase()}';
  
  if (combined.contains('tavuk') || combined.contains('chicken')) return 'Tavuk';
  if (combined.contains('et') || combined.contains('köfte') || combined.contains('kıyma') || 
      combined.contains('kuzu') || combined.contains('dana')) return 'Et';
  if (combined.contains('balık') || combined.contains('somon') || combined.contains('levrek') ||
      combined.contains('ton') || combined.contains('çupra') || combined.contains('palamut')) return 'Balık';
  if (combined.contains('yumurta') || combined.contains('omlet')) return 'Yumurta';
  if (combined.contains('peynir') || combined.contains('lor') || combined.contains('labne')) return 'Süt Ürünleri';
  if (combined.contains('nohut') || combined.contains('fasulye') || combined.contains('bezelye')) return 'Baklagil';
  if (combined.contains('protein')) return 'Protein Supplement';
  
  return 'Karma';
}