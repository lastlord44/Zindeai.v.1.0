import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 1 Batch 2 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 1251; // 1101 + 150
  
  // 150 ara öğün daha oluşturacağız
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15;
    
    switch(kategori) {
      case 0: // Rice Cake Kombinasyonları
        final ricecake = [
          'Pirinç Patlağı + Fıstık Ezmesi',
          'Pirinç Patlağı + Avokado',
          'Pirinç Patlağı + Humus',
          'Pirinç Patlağı + Labne + Domates',
          'Pirinç Patlağı + Cottage Cheese',
          'Pirinç Patlağı + Ton Balığı',
          'Pirinç Patlağı + Yumurta Salatası',
          'Pirinç Patlağı + Reçel Light',
          'Pirinç Patlağı + Bal + Ceviz',
          'Pirinç Patlağı + Tavuk Göğsü'
        ];
        ad = ricecake[i ~/ 15 % ricecake.length];
        malzemeler = ['Pirinç patlağı ${2 + (i % 3)} adet', 'Üst malzeme ${20 + (i % 20)}g'];
        kalori = 140 + (i % 60);
        protein = 8 + (i % 8);
        karbonhidrat = 18 + (i % 12);
        yag = 4 + (i % 5);
        break;
        
      case 1: // Protein Tozu Atıştırmalıkları
        final proteinsnack = [
          'Protein Pancake Mini',
          'Protein Waffle Mini',
          'Protein Muffin',
          'Protein Balls',
          'Protein Flapjack',
          'Protein Donuts',
          'Protein Bites',
          'Protein Pops',
          'Protein Bark',
          'Protein Chips'
        ];
        ad = proteinsnack[i ~/ 15 % proteinsnack.length];
        malzemeler = ['Whey protein 25g', 'Yulaf 20g', 'Yumurta 1 adet', 'Tatlandırıcı'];
        kalori = 180 + (i % 70);
        protein = 20 + (i % 12);
        karbonhidrat = 18 + (i % 15);
        yag = 4 + (i % 4);
        break;
        
      case 2: // Edamame ve Baklagil Atıştırmaları
        final baklagil = [
          'Edamame Haşlama',
          'Nohut Kızartması',
          'Barbunya Salatası Mini',
          'Mercimek Köftesi Mini',
          'Bezelye Salatası',
          'Soya Fasulyesi Haşlama',
          'Hummus Bowl',
          'Falafel Mini (2 adet)',
          'Bakla Salatası',
          'Börülce Salatası'
        ];
        ad = baklagil[i ~/ 15 % baklagil.length];
        malzemeler = ['Baklagil ${80 + (i % 40)}g', 'Zeytinyağı 5ml', 'Baharatlar'];
        kalori = 120 + (i % 60);
        protein = 10 + (i % 8);
        karbonhidrat = 16 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 3: // Deniz Ürünleri Hafif Atıştırmalar
        final seafood = [
          'Ton Balığı Konservesi (80g)',
          'Sardalya Konservesi',
          'Füme Somon Dilim (50g)',
          'Karides Haşlama (100g)',
          'İstavrit Izgara Mini',
          'Çupra Füme Dilim',
          'Levrek Füme',
          'Hamsi Izgara Mini',
          'Ahtapot Haşlama',
          'Midye Haşlama'
        ];
        ad = seafood[i ~/ 15 % seafood.length];
        malzemeler = ['Deniz ürünü ${60 + (i % 40)}g', 'Limon', 'Baharatlar'];
        kalori = 100 + (i % 80);
        protein = 18 + (i % 12);
        karbonhidrat = 2 + (i % 3);
        yag = 2 + (i % 4);
        break;
        
      case 4: // Türk Kahvaltılık Miniatures
        final turkish = [
          'Menemen Mini Porsiyon',
          'Çılbır Mini',
          'Sucuklu Yumurta Mini',
          'Peynirli Omlet Mini',
          'Ispanaklı Yumurta',
          'Mücver Mini (2 adet)',
          'Gözleme Dilimi',
          'Börek Dilimi',
          'Simit Yarım',
          'Poğaça Mini'
        ];
        ad = turkish[i ~/ 15 % turkish.length];
        malzemeler = ['Ana malzeme ${50 + (i % 30)}g', 'Yumurta 1 adet', 'Baharat'];
        kalori = 160 + (i % 80);
        protein = 12 + (i % 8);
        karbonhidrat = 14 + (i % 10);
        yag = 8 + (i % 6);
        break;
        
      case 5: // Çikolata ve Kakao Bazlı Sağlıklı
        final choco = [
          'Bitter Çikolata (20g)',
          'Kakao Nibs + Badem',
          'Protein Çikolata',
          'Çikolatalı Protein Puding',
          'Kakao + Yulaf Topları',
          'Dark Chocolate + Fındık',
          'Çikolatalı Chia Pudding',
          'Kakao + Muz Smoothie',
          'Çikolata Kaplı Çilek',
          'Protein Brownies Mini'
        ];
        ad = choco[i ~/ 15 % choco.length];
        malzemeler = ['Kakao/Çikolata ${15 + (i % 15)}g', 'Ek tatlandırıcı'];
        kalori = 140 + (i % 80);
        protein = 6 + (i % 8);
        karbonhidrat = 18 + (i % 15);
        yag = 8 + (i % 6);
        break;
        
      case 6: // Süt Ürünleri Varyasyonları
        final dairy = [
          'Ayran + Ceviz',
          'Kefir + Badem',
          'Süzme Yoğurt + Salatalık',
          'Labne Topları',
          'Beyaz Peynir + Zeytin',
          'Lor Peyniri + Domates',
          'Cottage Cheese + Ananas',
          'Ricotta + Bal',
          'Kaşar Küpleri',
          'Mozzarella + Cherry Domates'
        ];
        ad = dairy[i ~/ 15 % dairy.length];
        malzemeler = ['Süt ürünü ${100 + (i % 50)}g', 'Ek malzeme 30g'];
        kalori = 130 + (i % 70);
        protein = 12 + (i % 10);
        karbonhidrat = 8 + (i % 8);
        yag = 6 + (i % 6);
        break;
        
      case 7: // Granola ve Müsli Karışımları
        final granola = [
          'Granola + Yoğurt',
          'Müsli Bar',
          'Yulaf + Kuru Meyve Mix',
          'Granola Clusters',
          'Müsli + Süt',
          'Yulaf Topları',
          'Granola + Meyve',
          'Müsli Cookies',
          'Yulaf Bar',
          'Granola Parfait Mini'
        ];
        ad = granola[i ~/ 15 % granola.length];
        malzemeler = ['Granola/Müsli ${40 + (i % 20)}g', 'Süt/Yoğurt 100ml', 'Meyve 30g'];
        kalori = 200 + (i % 80);
        protein = 8 + (i % 6);
        karbonhidrat = 32 + (i % 15);
        yag = 6 + (i % 5);
        break;
        
      case 8: // Sebze Çubukları ve Soslama
        final vegstick = [
          'Havuç + Baba Ganoush',
          'Kereviz + Tahin',
          'Brokoli + Yoğurt Sos',
          'Karnabahar + Humus',
          'Kabak + Labne',
          'Kırmızı Biber + Guacamole',
          'Salatalık + Tzatziki',
          'Mantar Haşlama + Sos',
          'Kuşkonmaz + Zeytinyağı',
          'Patlıcan + Yoğurt'
        ];
        ad = vegstick[i ~/ 15 % vegstick.length];
        malzemeler = ['Sebze ${120 + (i % 60)}g', 'Dip sos 40g'];
        kalori = 110 + (i % 60);
        protein = 5 + (i % 5);
        karbonhidrat = 12 + (i % 10);
        yag = 6 + (i % 6);
        break;
        
      case 9: // Mini Wrap ve Rolls
        final wraps = [
          'Tavuk Wrap Mini',
          'Ton Balığı Roll',
          'Sebze Wrap Light',
          'Humus Wrap',
          'Hindi Roll',
          'Avokado Wrap',
          'Yumurta Roll',
          'Peynir Wrap',
          'Somon Roll',
          'Falafel Wrap Mini'
        ];
        ad = wraps[i ~/ 15 % wraps.length];
        malzemeler = ['Tortilla 1 adet', 'Protein ${40 + (i % 20)}g', 'Sebze 30g', 'Sos 15g'];
        kalori = 180 + (i % 90);
        protein = 15 + (i % 10);
        karbonhidrat = 20 + (i % 12);
        yag = 6 + (i % 5);
        break;
        
      case 10: // Smoothie Bowl Variations
        final bowls = [
          'Berry Smoothie Bowl',
          'Mango Smoothie Bowl',
          'Green Smoothie Bowl',
          'Protein Smoothie Bowl',
          'Açai Bowl Light',
          'Pitaya Bowl',
          'Banana Nice Cream Bowl',
          'Çikolatalı Smoothie Bowl',
          'Tropical Smoothie Bowl',
          'Matcha Smoothie Bowl'
        ];
        ad = bowls[i ~/ 15 % bowls.length];
        malzemeler = ['Meyve püre 150g', 'Topping 30g', 'Protein tozu 15g'];
        kalori = 210 + (i % 90);
        protein = 10 + (i % 8);
        karbonhidrat = 32 + (i % 18);
        yag = 5 + (i % 5);
        break;
        
      case 11: // Tahıl Bazlı Atıştırmalıklar
        final grains = [
          'Kinoa Salatası Mini',
          'Bulgur Köftesi Mini',
          'Karabuğday Kraker',
          'Amarant Patlağı',
          'Quinoa Ball',
          'Freekeh Salatası',
          'Arpa Lapası',
          'Çavdar Krateri',
          'Mısır Gevreği + Süt',
          'Tritikale Mix'
        ];
        ad = grains[i ~/ 15 % grains.length];
        malzemeler = ['Tahıl ${50 + (i % 30)}g', 'Sebze/Protein 30g', 'Zeytinyağı 5ml'];
        kalori = 150 + (i % 70);
        protein = 6 + (i % 6);
        karbonhidrat = 24 + (i % 15);
        yag = 4 + (i % 4);
        break;
        
      case 12: // Ev Yapımı Enerji Atıştırmaları
        final energy = [
          'Hurma + Badem Topu',
          'Enerji Bar Ev Yapımı',
          'Protein Truffle',
          'Fındık + Kuru Üzüm Topu',
          'Yulaf + Bal Topu',
          'Kakao + Fıstık Topu',
          'Kuru Meyve + Ceviz Mix',
          'Chia + Hurma Topu',
          'Badem + Kayısı Topu',
          'Antep Fıstığı + İncir Topu'
        ];
        ad = energy[i ~/ 15 % energy.length];
        malzemeler = ['Kuruyemiş 25g', 'Kuru meyve 25g', 'Bal/Hurma 10g'];
        kalori = 180 + (i % 80);
        protein = 6 + (i % 5);
        karbonhidrat = 22 + (i % 15);
        yag = 9 + (i % 7);
        break;
        
      case 13: // Dondurma ve Frozen Desserts (Sağlıklı)
        final frozen = [
          'Frozen Yoğurt Light',
          'Meyve Dondurması Ev Yapımı',
          'Protein Ice Cream',
          'Donmuş Muz Dilimleri',
          'Smoothie Pops',
          'Yoğurt Popsicles',
          'Çilek Sorbe',
          'Mango Sorbe',
          'Nice Cream (Muz Bazlı)',
          'Yaban Mersini Frozen Yoğurt'
        ];
        ad = frozen[i ~/ 15 % frozen.length];
        malzemeler = ['Ana baz 100g', 'Meyve 50g', 'Tatlandırıcı'];
        kalori = 120 + (i % 80);
        protein = 5 + (i % 6);
        karbonhidrat = 20 + (i % 15);
        yag = 2 + (i % 3);
        break;
        
      case 14: // Özel Diyet Atıştırmaları
        final special = [
          'Keto Fat Bomb',
          'Vegan Protein Bite',
          'Paleo Trail Mix',
          'Gluten-Free Cracker + Humus',
          'Low Carb Muffin',
          'Vegan Nice Cream',
          'Keto Cheese Chips',
          'Paleo Energy Ball',
          'Gluten-Free Granola',
          'Vegan Protein Bar'
        ];
        ad = special[i ~/ 15 % special.length];
        malzemeler = ['Özel diyet uyumlu malzemeler'];
        kalori = 160 + (i % 90);
        protein = 10 + (i % 10);
        karbonhidrat = 12 + (i % 15);
        yag = 10 + (i % 8);
        break;
      
      default:
        ad = 'Ara Öğün 1 Varyasyon ${i + 1}';
        malzemeler = ['Standart ara öğün malzemeleri'];
        kalori = 150;
        protein = 10;
        karbonhidrat = 15;
        yag = 5;
    }
    
    yemekler.add({
      "id": "ARA1_${id++}",
      "ad": ad,
      "ogun": "ara_ogun_1",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_ara_ogun_1_batch_2.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 1');
  print('📊 TOPLAM ARA ÖĞÜN 1 (2 Batch): 300 ara öğün');
  print('📁 Dosya: ${file.path}');
}
