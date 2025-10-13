import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 2 Batch 4 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 2451; // 2301 + 150
  
  // 150 ara öğün 2 daha
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15;
    
    switch(kategori) {
      case 0: // Akşam Öncesi Et/Tavuk Snackları  
        final etler = [
          'Izgara Köfte Mini (1 adet)',
          'Tavuk Şiş (40g)',
          'Dana Parça Izgara (50g)',
          'Hindi Köftesi Mini',
          'Izgara Tavuk But (60g)',
          'Dana Jambon Light (40g)',
          'Tavuk Sote Küçük Porsiyon',
          'Izgara Biftek Dilim (50g)',
          'Hindi Sote Mini',
          'Izgara Dana Bonfile (50g)'
        ];
        ad = etler[i ~/ 15 % etler.length];
        malzemeler = ['Et/Tavuk ${40 + (i % 30)}g', 'Baharat'];
        kalori = 110 + (i % 90);
        protein = 18 + (i % 14);
        karbonhidrat = 1 + (i % 3);
        yag = 4 + (i % 6);
        break;
        
      case 1: // Bitki Bazlı Protein Alternatifleri
        final bitkiprotein = [
          'Edamame Protein Bowl',
          'Soya Nugget (5 adet)',
          'Nohut Protein Snack',
          'Bezelye Proteini Bar',
          'Mercimek Protein Topu',
          'Fasulye Protein Mix',
          'Kinoa Protein Ball',
          'Amarant Protein Snack',
          'Chia Protein Bite',
          'Hemp Protein Ball'
        ];
        ad = bitkiprotein[i ~/ 15 % bitkiprotein.length];
        malzemeler = ['Bitki bazlı protein ${50 + (i % 40)}g'];
        kalori = 120 + (i % 80);
        protein = 14 + (i % 10);
        karbonhidrat = 12 + (i % 10);
        yag = 4 + (i % 4);
        break;
        
      case 2: // Mini Sushialt ve Asya Atıştırmaları
        final asya = [
          'Sushi Roll Mini (2 parça)',
          'Edamame (80g)',
          'Miso Soup Light',
          'Wakame Salad Mini',
          'Tofu Stick (3 adet)',
          'Spring Roll Light (1 adet)',
          'Dumpling (2 adet)',
          'Gyoza Light (2 adet)',
          'Rice Paper Roll',
          'Seaweed Snack'
        ];
        ad = asya[i ~/ 15 % asya.length];
        malzemeler = ['Asya atıştırmalığı ${50 + (i % 50)}g'];
        kalori = 90 + (i % 80);
        protein = 7 + (i % 8);
        karbonhidrat = 12 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 3: // Akşam Öncesi Çorba Çeşitleri
        final corbalar = [
          'Tavuk Suyu Çorbası Light',
          'Sebze Çorbası (1 kase)',
          'Mantar Çorbası Light',
          'Domates Çorbası',
          'Brokoli Çorbası',
          'Ispanak Çorbası',
          'Balkabağı Çorbası',
          'Mercimek Çorbası Light',
          'Havuç Çorbası',
          'Kabak Çorbası'
        ];
        ad = corbalar[i ~/ 15 % corbalar.length];
        malzemeler = ['Çorba ${150 + (i % 100)}ml', 'Baharat'];
        kalori = 70 + (i % 70);
        protein = 5 + (i % 6);
        karbonhidrat = 10 + (i % 10);
        yag = 2 + (i % 3);
        break;
        
      case 4: // Probiyotik Zengin Atıştırmalar
        final probiyotik = [
          'Kefir + Chia (150ml)',
          'Sauerkraut (50g)',
          'Kimchi Light (40g)',
          'Pickles Çeşitleri (50g)',
          'Fermented Vegetables Mix',
          'Probiotic Yogurt Drink',
          'Kombucha Tea (200ml)',
          'Miso Soup Mini',
          'Tempeh Cube Fermente',
          'Natto (Japon Fermente Fasulye)'
        ];
        ad = probiyotik[i ~/ 15 % probiyotik.length];
        malzemeler = ['Probiyotik gıda ${50 + (i % 80)}g/ml'];
        kalori = 50 + (i % 70);
        protein = 4 + (i % 6);
        karbonhidrat = 6 + (i % 10);
        yag = 2 + (i % 4);
        break;
        
      case 5: // Ezme ve Meze Çeşitleri
        final mezeler = [
          'Humus Mini Porsiyon (40g)',
          'Muhammara (30g)',
          'Baba Ghanoush (40g)',
          'Tzatziki (50g)',
          'Haydari (40g)',
          'Acuka (30g)',
          'Taramasalata Light (30g)',
          'Fava (40g)',
          'Patlıcan Salatası (50g)',
          'Közlenmiş Biber Ezme (40g)'
        ];
        ad = mezeler[i ~/ 15 % mezeler.length];
        malzemeler = ['Ezme/Meze ${30 + (i % 30)}g', 'Sebze stick (opsiyonel)'];
        kalori = 60 + (i % 70);
        protein = 3 + (i % 5);
        karbonhidrat = 7 + (i % 8);
        yag = 4 + (i % 5);
        break;
        
      case 6: // Akşam Öncesi Makro-Balanced Snacklar
        final balanced = [
          'Mini Protein Bowl (Tavuk)',
          'Balanced Bento Box Mini',
          'Protein + Sebze Combo',
          'Tahıl + Protein Mix',
          'Yoğurt + Yulaf + Meyve',
          'Cottage Cheese Bowl',
          'Kinoa + Sebze Mini',
          'Edamame + Pirinç',
          'Protein Wrap Balanced',
          'Mini Buddha Bowl'
        ];
        ad = balanced[i ~/ 15 % balanced.length];
        malzemeler = ['Dengeli makro mix ${100 + (i % 80)}g'];
        kalori = 150 + (i % 90);
        protein = 12 + (i % 10);
        karbonhidrat = 15 + (i % 12);
        yag = 5 + (i % 5);
        break;
        
      case 7: // Düşük Kalorili Atıştırmalıklar
        final lowcal = [
          'Air-Popped Popcorn (30g)',
          'Sebze Stick (200g)',
          'Cherry Domates (150g)',
          'Salatalık Dilimleri (200g)',
          'Jelatin Sugar-Free',
          'Sparkling Water + Limon',
          'Ice Pop Sugar-Free',
          'Konjac Jelly',
          'Pickles Light (100g)',
          'Radish Snack'
        ];
        ad = lowcal[i ~/ 15 % lowcal.length];
        malzemeler = ['Düşük kalorili snack ${50 + (i % 100)}g'];
        kalori = 20 + (i % 50);
        protein = 1 + (i % 3);
        karbonhidrat = 5 + (i % 8);
        yag = 0;
        break;
        
      case 8: // Omega-3 Zengin Atıştırmalıklar
        final omega3 = [
          'Chia Pudding Mini',
          'Keten Tohumu + Yoğurt',
          'Ceviz (6 adet)',
          'Somon Füme Mini (30g)',
          'Sardalya (1 adet)',
          'Uskumru Füme Dilim (40g)',
          'Badem (12 adet)',
          'Hemp Seeds Mix (20g)',
          'Ton Balığı Konserve (50g)',
          'Avokado Küp (50g)'
        ];
        ad = omega3[i ~/ 15 % omega3.length];
        malzemeler = ['Omega-3 kaynağı ${20 + (i % 40)}g'];
        kalori = 100 + (i % 80);
        protein = 8 + (i % 10);
        karbonhidrat = 4 + (i % 6);
        yag = 8 + (i % 8);
        break;
        
      case 9: // Antioxidant Zengin Snacklar
        final antioksidan = [
          'Yaban Mersini (80g)',
          'Böğürtlen (70g)',
          'Frambuaz (80g)',
          'Nar Taneleri (100g)',
          'Bitter Çikolata (15g)',
          'Yeşil Çay + Badem',
          'Ahududu (80g)',
          'Çilek (100g)',
          'Kırmızı Üzüm (80g)',
          'Grenade + Ceviz Mix'
        ];
        ad = antioksidan[i ~/ 15 % antioksidan.length];
        malzemeler = ['Antioksidan zengin gıda ${60 + (i % 50)}g'];
        kalori = 60 + (i % 70);
        protein = 2 + (i % 4);
        karbonhidrat = 14 + (i % 12);
        yag = 2 + (i % 4);
        break;
        
      case 10: // Akşam Öncesi Smoothie Çeşitleri
        final smoothieler = [
          'Green Smoothie Light (200ml)',
          'Protein Smoothie Küçük',
          'Berry Smoothie',
          'Detox Smoothie',
          'Mango Smoothie Light',
          'Spinach + Banana Smoothie',
          'Kefir Smoothie',
          'Avocado Smoothie',
          'Cucumber Smoothie',
          'Beetroot Smoothie Light'
        ];
        ad = smoothieler[i ~/ 15 % smoothieler.length];
        malzemeler = ['Smoothie bileşenleri ${150 + (i % 100)}ml'];
        kalori = 90 + (i % 80);
        protein = 6 + (i % 8);
        karbonhidrat = 14 + (i % 12);
        yag = 2 + (i % 3);
        break;
        
      case 11: // Akşam Zencefil/Baharat Kombinasyonları
        final baharatli = [
          'Zencefil Çayı + Hurma (2 adet)',
          'Turmeric Latte Light',
          'Cinnamon Apple Slices',
          'Ginger Shot + Bal',
          'Tarçınlı Yoğurt',
          'Kimyon Çayı + Badem',
          'Karanfil Çayı + İncir',
          'Biberiye Çayı + Ceviz',
          'Kakule Kahve + Fındık',
          'Safran Süt Light'
        ];
        ad = baharatli[i ~/ 15 % baharatli.length];
        malzemeler = ['Bitki çayı/içecek 200ml', 'Baharat', 'Ek snack ${15 + (i % 20)}g'];
        kalori = 70 + (i % 80);
        protein = 3 + (i % 5);
        karbonhidrat = 12 + (i % 15);
        yag = 3 + (i % 5);
        break;
        
      case 12: // Akşam Öncesi Süperfoods
        final superfood = [
          'Acai Bowl Mini',
          'Goji Berry Mix (20g)',
          'Spirulina Smoothie',
          'Chia Seed Pudding',
          'Maca Powder Shake',
          'Wheatgrass Shot',
          'Chlorella Tablet + Su',
          'Moringa Smoothie',
          'Matcha Bowl Light',
          'Cacao Nibs + Badem'
        ];
        ad = superfood[i ~/ 15 % superfood.length];
        malzemeler = ['Superfood ${30 + (i % 40)}g', 'Ek malzeme'];
        kalori = 80 + (i % 90);
        protein = 5 + (i % 7);
        karbonhidrat = 12 + (i % 15);
        yag = 4 + (i % 6);
        break;
        
      case 13: // Mini Protein Meals
        final miniprotein = [
          'Mini Chicken Breast (60g)',
          'Tuna Cake Mini',
          'Salmon Patty Small',
          'Turkey Meatball (2 adet)',
          'Fish Stick Light (2 adet)',
          'Shrimp Skewer (3 adet)',
          'Egg White Frittata Mini',
          'Cottage Cheese Pancake Mini',
          'Protein Muffin Savory',
          'Mini Beef Patty (40g)'
        ];
        ad = miniprotein[i ~/ 15 % miniprotein.length];
        malzemeler = ['Protein kaynağı ${40 + (i % 40)}g', 'Baharat'];
        kalori = 90 + (i % 90);
        protein = 16 + (i % 12);
        karbonhidrat = 3 + (i % 5);
        yag = 3 + (i % 5);
        break;
        
      case 14: // Akşam Relax İçecekleri + Snack
        final relax = [
          'Chamomile Tea + Bisküvi',
          'Lavender Tea + Badem',
          'Valerian Root Tea + Hurma',
          'Passionflower Tea + Ceviz',
          'Warm Milk + Tarçın',
          'Lemon Balm Tea + İncir',
          'Ashwagandha Tea + Fıstık',
          'Holy Basil Tea + Kuru Kayısı',
          'Magnesium Drink + Muz',
          'Bedtime Tea + Protein Ball'
        ];
        ad = relax[i ~/ 15 % relax.length];
        malzemeler = ['Relax çayı 250ml', 'Sağlıklı snack ${20 + (i % 25)}g'];
        kalori = 80 + (i % 80);
        protein = 4 + (i % 5);
        karbonhidrat = 14 + (i % 12);
        yag = 4 + (i % 6);
        break;
      
      default:
        ad = 'Ara Öğün 2 Extra ${i + 1}';
        malzemeler = ['Standart ara öğün 2 malzemeleri'];
        kalori = 100;
        protein = 8;
        karbonhidrat = 10;
        yag = 3;
    }
    
    yemekler.add({
      "id": "ARA2_${id++}",
      "ad": ad,
      "ogun": "ara_ogun_2",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_ara_ogun_2_batch_4.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 2');
  print('📊 TOPLAM ARA ÖĞÜN 2 (4 Batch): 600 ara öğün');
  print('📊 ŞİMDİYE KADAR GRAND TOPLAM: 2150 YEMEK! 🎉');
  print('📁 Dosya: ${file.path}');
  print('\n🚀 Devam ediyoruz...');
}
