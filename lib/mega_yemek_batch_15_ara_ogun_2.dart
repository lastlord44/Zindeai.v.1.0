import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 2 Batch 1 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 2001; // Ara Öğün 2 için yeni ID aralığı
  
  // 150 ara öğün 2
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15;
    
    switch(kategori) {
      case 0: // Akşam Öncesi Protein Snackları
        final proteinler = [
          'Tavuk Göğsü Haşlama (100g)',
          'Izgara Tavuk Dilim',
          'Hindi Füme (80g)',
          'Tavuk Sote Mini',
          'Izgara Köfte (2 adet)',
          'Hindi Göğsü Haşlama',
          'Tavuk Jambon Light',
          'Izgara Tavuk Şiş Mini',
          'Hindi Roll',
          'Tavuk Salam Light'
        ];
        ad = proteinler[i ~/ 15 % proteinler.length];
        malzemeler = ['Protein kaynağı ${80 + (i % 40)}g', 'Baharat'];
        kalori = 120 + (i % 80);
        protein = 22 + (i % 12);
        karbonhidrat = 2 + (i % 4);
        yag = 3 + (i % 5);
        break;
        
      case 1: // Akşam Hafif Süt Ürünleri
        final sutler = [
          'Süzme Yoğurt (150g)',
          'Kefir (200ml)',
          'Ayran Light',
          'Labne (100g)',
          'Cottage Cheese (120g)',
          'Lor Peyniri (80g)',
          'Beyaz Peynir Light (50g)',
          'Probiyotik Yoğurt',
          'Çökelek (100g)',
          'Ricotta Light'
        ];
        ad = sutler[i ~/ 15 % sutler.length];
        malzemeler = ['Süt ürünü ${100 + (i % 80)}g'];
        kalori = 90 + (i % 70);
        protein = 12 + (i % 10);
        karbonhidrat = 8 + (i % 10);
        yag = 3 + (i % 5);
        break;
        
      case 2: // Akşam Sebze Atıştırmaları
        final sebzeler = [
          'Çiğ Havuç Stick',
          'Salatalık Dilimleri',
          'Cherry Domates (150g)',
          'Biber Dilimleri',
          'Kereviz Çubukları',
          'Haşlanmış Brokoli',
          'Haşlanmış Karnabahar',
          'Çiğ Mantar',
          'Kabak Dilimleri Izgara',
          'Ispanak Haşlama'
        ];
        ad = sebzeler[i ~/ 15 % sebzeler.length];
        malzemeler = ['Sebze ${120 + (i % 100)}g', 'Zeytinyağı 5ml (opsiyonel)'];
        kalori = 50 + (i % 50);
        protein = 3 + (i % 4);
        karbonhidrat = 8 + (i % 8);
        yag = 1 + (i % 3);
        break;
        
      case 3: // Akşam Yumurta Snackları
        final yumurtalar = [
          'Haşlanmış Yumurta (1 adet)',
          'Yumurta Beyazı (3 adet)',
          'Omlet Light (1 yumurta)',
          'Çırpılmış Yumurta',
          'Poşe Yumurta',
          'Rafadan Yumurta',
          'Yumurta + Sebze',
          'Haşlanmış Yumurta + Domates',
          'Yumurta Beyazı Omlet',
          'Mini Menemen (1 yumurta)'
        ];
        ad = yumurtalar[i ~/ 15 % yumurtalar.length];
        malzemeler = ['Yumurta ${1 + (i % 2)} adet', 'Sebze (opsiyonel) 30g'];
        kalori = 80 + (i % 90);
        protein = 8 + (i % 10);
        karbonhidrat = 2 + (i % 4);
        yag = 6 + (i % 7);
        break;
        
      case 4: // Akşam Balık/Deniz Ürünleri Light
        final balik = [
          'Ton Balığı (60g)',
          'Sardalya Konservesi',
          'Füme Somon (40g)',
          'Karides Haşlama (80g)',
          'İstavrit Izgara Mini',
          'Mezgit Haşlama',
          'Hamsi Izgara (3 adet)',
          'Uskumru Füme Dilim',
          'Levrek Haşlama Mini',
          'Çupra Izgara Dilim'
        ];
        ad = balik[i ~/ 15 % balik.length];
        malzemeler = ['Balık ${50 + (i % 40)}g', 'Limon', 'Baharat'];
        kalori = 90 + (i % 80);
        protein = 16 + (i % 12);
        karbonhidrat = 1 + (i % 2);
        yag = 3 + (i % 6);
        break;
        
      case 5: // Akşam Kuruyemiş Mini Porsiyon
        final nuts = [
          'Badem (15g)',
          'Ceviz (12g)',
          'Fındık (15g)',
          'Antep Fıstığı (12g)',
          'Kaju (15g)',
          'Ay Çekirdeği (20g)',
          'Kabak Çekirdeği (20g)',
          'Yer Fıstığı (15g)',
          'Çiğ Badem (15g)',
          'Karışık Nuts Mini (15g)'
        ];
        ad = nuts[i ~/ 15 % nuts.length];
        malzemeler = ['Kuruyemiş ${12 + (i % 10)}g'];
        kalori = 90 + (i % 70);
        protein = 4 + (i % 4);
        karbonhidrat = 5 + (i % 6);
        yag = 8 + (i % 6);
        break;
        
      case 6: // Akşam Meyve Porsiyonları
        final meyveler = [
          'Elma (1 adet küçük)',
          'Portakal (1 adet küçük)',
          'Kivi (2 adet)',
          'Çilek (100g)',
          'Yaban Mersini (80g)',
          'Greyfurt (yarım)',
          'Mandalina (2 adet)',
          'Armut (1 adet küçük)',
          'Şeftali (1 adet)',
          'Kiraz (15 adet)'
        ];
        ad = meyveler[i ~/ 15 % meyveler.length];
        malzemeler = ['Taze meyve ${80 + (i % 70)}g'];
        kalori = 60 + (i % 50);
        protein = 1 + (i % 2);
        karbonhidrat = 14 + (i % 12);
        yag = 0;
        break;
        
      case 7: // Akşam Protein Shake Light
        final shakeler = [
          'Whey Shake Light (15g)',
          'Casein Shake (20g)',
          'Vegan Protein (20g)',
          'Protein Shake Su Bazlı',
          'Protein Coffee Light',
          'Protein Shake Vanilya',
          'Protein Shake Çikolata',
          'BCAA + Protein Mix',
          'Protein Shake Çilek',
          'Isolate Protein Shake'
        ];
        ad = shakeler[i ~/ 15 % shakeler.length];
        malzemeler = ['Protein tozu ${15 + (i % 10)}g', 'Su 200ml'];
        kalori = 70 + (i % 50);
        protein = 18 + (i % 10);
        karbonhidrat = 3 + (i % 5);
        yag = 1 + (i % 2);
        break;
        
      case 8: // Akşam Çorba Mini Porsiyon
        final corbalar = [
          'Ezogelin Çorbası (1 kase)',
          'Mercimek Çorbası',
          'Tavuk Suyu Çorbası',
          'Sebze Çorbası',
          'Domates Çorbası Light',
          'Brokoli Çorbası',
          'Mantar Çorbası',
          'Ispanak Çorbası',
          'Tarhana Çorbası Light',
          'Kemik Suyu'
        ];
        ad = corbalar[i ~/ 15 % corbalar.length];
        malzemeler = ['Çorba 200ml', 'Baharat'];
        kalori = 80 + (i % 80);
        protein = 6 + (i % 6);
        karbonhidrat = 12 + (i % 10);
        yag = 3 + (i % 4);
        break;
        
      case 9: // Akşam Salata Mini
        final salatalar = [
          'Yeşil Salata',
          'Çoban Salatası Mini',
          'Roka Salatası',
          'Marul + Limon',
          'Izgara Sebze Salatası',
          'Kırmızı Lahana Salatası',
          'Mevsim Salatası',
          'Ispanak Salatası',
          'Karışık Yeşillik',
          'Roka + Cherry Domates'
        ];
        ad = salatalar[i ~/ 15 % salatalar.length];
        malzemeler = ['Salata ${100 + (i % 80)}g', 'Limon + Zeytinyağı 5ml'];
        kalori = 50 + (i % 60);
        protein = 2 + (i % 3);
        karbonhidrat = 8 + (i % 8);
        yag = 3 + (i % 4);
        break;
        
      case 10: // Akşam Humus ve Dip'ler Light
        final dipler = [
          'Humus (40g)',
          'Baba Ganoush (40g)',
          'Tzatziki (50g)',
          'Yoğurt Dip',
          'Tahin Light (20g)',
          'Patlıcan Ezme (50g)',
          'Atom (40g)',
          'Labne Dip',
          'Acuka Light (30g)',
          'Cacık (100g)'
        ];
        ad = dipler[i ~/ 15 % dipler.length];
        malzemeler = ['Dip ${30 + (i % 30)}g', 'Sebze stick (opsiyonel)'];
        kalori = 60 + (i % 60);
        protein = 4 + (i % 4);
        karbonhidrat = 6 + (i % 6);
        yag = 4 + (i % 5);
        break;
        
      case 11: // Akşam Light Atıştırmalıklar
        final light = [
          'Pirinç Patlağı (2 adet)',
          'Galeta (3 adet)',
          'Protein Kraker (2 adet)',
          'Kepekli Kraker (3 adet)',
          'Tam Buğday Kraker',
          'Yulaf Krateri',
          'Karabuğday Patlağı',
          'Kinoa Patlağı',
          'Mısır Patlağı Light (30g)',
          'Pirinç Krateri'
        ];
        ad = light[i ~/ 15 % light.length];
        malzemeler = ['Light atıştırmalık ${20 + (i % 20)}g'];
        kalori = 70 + (i % 60);
        protein = 3 + (i % 4);
        karbonhidrat = 14 + (i % 10);
        yag = 1 + (i % 2);
        break;
        
      case 12: // Akşam Fermente Gıdalar
        final fermente = [
          'Kefir (150ml)',
          'Ayran (200ml)',
          'Probiyotik Yoğurt (100g)',
          'Turşu Suyu (100ml)',
          'Kombucha (150ml)',
          'Fermente Lahana (50g)',
          'Turşu Çeşitleri (50g)',
          'Kimchi Mini (30g)',
          'Probiyotik İçecek',
          'Yoğurt + Probiyotik'
        ];
        ad = fermente[i ~/ 15 % fermente.length];
        malzemeler = ['Fermente gıda ${80 + (i % 70)}g/ml'];
        kalori = 40 + (i % 60);
        protein = 4 + (i % 5);
        karbonhidrat = 6 + (i % 8);
        yag = 1 + (i % 3);
        break;
        
      case 13: // Akşam Tahıl Mini
        final tahil = [
          'Yulaf (30g)',
          'Kinoa Haşlama (50g)',
          'Bulgur Haşlama (40g)',
          'Pirinç (30g)',
          'Karabuğday (40g)',
          'Arpa Lapası Mini',
          'Freekeh (40g)',
          'Amarant (30g)',
          'Yulaf Lapası Mini',
          'Bulgur Köftesi (1 adet)'
        ];
        ad = tahil[i ~/ 15 % tahil.length];
        malzemeler = ['Tahıl ${30 + (i % 25)}g', 'Su/Sebze 50g'];
        kalori = 100 + (i % 70);
        protein = 4 + (i % 4);
        karbonhidrat = 20 + (i % 12);
        yag = 2 + (i % 3);
        break;
        
      case 14: // Akşam Özel Diyet Snackları
        final ozel = [
          'Keto Peynir Chips',
          'Vegan Protein Bite',
          'Paleo Mix Mini',
          'Low Carb Kraker',
          'Gluten-Free Snack',
          'Sugar-Free Pudding',
          'Keto Fat Bomb Mini',
          'Vegan Bar Mini',
          'Paleo Kurabiye',
          'Diabetic Snack'
        ];
        ad = ozel[i ~/ 15 % ozel.length];
        malzemeler = ['Özel diyet uyumlu atıştırmalık'];
        kalori = 90 + (i % 80);
        protein = 8 + (i % 8);
        karbonhidrat = 8 + (i % 10);
        yag = 6 + (i % 7);
        break;
      
      default:
        ad = 'Ara Öğün 2 ${i + 1}';
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
  
  final file = File('assets/data/mega_ara_ogun_2_batch_1.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 2');
  print('📁 Dosya: ${file.path}');
}
