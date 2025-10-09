import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 2 Batch 2 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 2151; // 2001 + 150
  
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
      case 0: // Hafif Protein Barları
        final barlar = [
          'Protein Bar Light Çikolatalı',
          'Protein Bar Light Vanilya',
          'Protein Bar Light Fındıklı',
          'Protein Bar Light Frambuazlı',
          'Protein Bar Light Karamel',
          'Protein Bar Light Yer Fıstığı',
          'Protein Bar Light Bademli',
          'Protein Bar Light Çilekli',
          'Quest Bar Mini',
          'RX Bar Light'
        ];
        ad = barlar[i ~/ 15 % barlar.length];
        malzemeler = ['Protein bar light ${30 + (i % 20)}g'];
        kalori = 110 + (i % 70);
        protein = 12 + (i % 10);
        karbonhidrat = 12 + (i % 10);
        yag = 4 + (i % 4);
        break;
        
      case 1: // Akşam Öncesi Sebze Suları
        final sular = [
          'Havuç Suyu (200ml)',
          'Kereviz Suyu',
          'Pancar Suyu Light',
          'Karışık Sebze Suyu',
          'Yeşil Detoks Suyu',
          'Domates Suyu',
          'Havuç-Elma Karışımı',
          'Salatalık-Nane Suyu',
          'Maydanoz-Limon Suyu',
          'Ispanak-Elma Suyu'
        ];
        ad = sular[i ~/ 15 % sular.length];
        malzemeler = ['Sebze suyu ${150 + (i % 100)}ml'];
        kalori = 40 + (i % 60);
        protein = 2 + (i % 3);
        karbonhidrat = 8 + (i % 10);
        yag = 0;
        break;
        
      case 2: // Light Peynir Çeşitleri
        final peynirler = [
          'Light Beyaz Peynir (40g)',
          'Cottage Cheese Light (100g)',
          'Lor Peyniri Light (70g)',
          'Çökelek (80g)',
          'Labne Light (60g)',
          'Ricotta Light (70g)',
          'Light Krem Peynir (30g)',
          'Light Kaşar (30g)',
          'Tulum Peyniri Light (40g)',
          'Light Mozzarella (40g)'
        ];
        ad = peynirler[i ~/ 15 % peynirler.length];
        malzemeler = ['Light peynir ${40 + (i % 40)}g'];
        kalori = 70 + (i % 60);
        protein = 8 + (i % 8);
        karbonhidrat = 3 + (i % 5);
        yag = 4 + (i % 5);
        break;
        
      case 3: // Stevia Tatlandırmalı Atıştırmalar
        final tatli = [
          'Stevia Yoğurt Bardağı',
          'Sugar-Free Puding',
          'Stevia Tatlandırmalı Komposto',
          'Sugar-Free Jelatin',
          'Stevia Yoğurt + Meyve',
          'Diabetik Puding',
          'Sugar-Free Chia Puding',
          'Stevia Smoothie',
          'Sugar-Free Frozen Yoğurt',
          'Stevia Kefir Mix'
        ];
        ad = tatli[i ~/ 15 % tatli.length];
        malzemeler = ['Ana malzeme 100g', 'Stevia tatlandırıcı'];
        kalori = 60 + (i % 70);
        protein = 6 + (i % 6);
        karbonhidrat = 10 + (i % 10);
        yag = 2 + (i % 3);
        break;
        
      case 4: // Akşam Öncesi Mini Salatalar
        final salatalar = [
          'Ton Balıklı Mini Salata',
          'Tavuk Göğüslü Salata Mini',
          'Yumurtalı Yeşil Salata',
          'Beyaz Peynirli Roka',
          'Közlenmiş Biberli Salata',
          'Izgara Sebze Salatası Mini',
          'Protein Salata Bowl',
          'Akdeniz Salatası Mini',
          'Kinoa Protein Salata',
          'Mercimekli Yeşil Salata'
        ];
        ad = salatalar[i ~/ 15 % salatalar.length];
        malzemeler = ['Yeşillik ${80 + (i % 60)}g', 'Protein ${40 + (i % 30)}g', 'Zeytinyağı 5ml'];
        kalori = 100 + (i % 80);
        protein = 12 + (i % 10);
        karbonhidrat = 8 + (i % 8);
        yag = 5 + (i % 5);
        break;
        
      case 5: // Chia ve Tohum Bazlı
        final tohumlar = [
          'Chia Pudding Mini',
          'Keten Tohumu Mix',
          'Chia + Yoğurt',
          'Kabak Çekirdeği (20g)',
          'Ay Çekirdeği Light (20g)',
          'Susam (15g)',
          'Keten + Yulaf Mix',
          'Chia + Süt',
          'Tohum Karışımı',
          'Chia + Kefir'
        ];
        ad = tohumlar[i ~/ 15 % tohumlar.length];
        malzemeler = ['Tohum ${15 + (i % 15)}g', 'Sıvı/Yoğurt (opsiyonel)'];
        kalori = 80 + (i % 70);
        protein = 5 + (i % 5);
        karbonhidrat = 8 + (i % 8);
        yag = 6 + (i % 6);
        break;
        
      case 6: // Akşam Çayları ve İnfüzyonlar
        final caylar = [
          'Yeşil Çay + Limon',
          'Beyaz Çay',
          'Ihlamur',
          'Papatya Çayı',
          'Nane-Limon',
          'Adaçayı',
          'Kuşburnu Çayı',
          'Rezene Çayı',
          'Zencefil Çayı',
          'Mate Çayı'
        ];
        ad = caylar[i ~/ 15 % caylar.length];
        malzemeler = ['Bitki çayı 250ml'];
        kalori = 5 + (i % 15);
        protein = 0;
        karbonhidrat = 1 + (i % 3);
        yag = 0;
        break;
        
      case 7: // Protein Atıştırmaları Light
        final proteinler = [
          'Izgara Tavuk Parçası (60g)',
          'Hindi Dilim Light',
          'Haşlanmış Yumurta Beyazı (2 adet)',
          'Tavuk Jambon (2 dilim)',
          'Light Sosis (1 adet)',
          'Tavuk Salam Light (2 dilim)',
          'Füme Hindi (50g)',
          'Izgara Balık Parçası (50g)',
          'Karides (60g)',
          'Ton Balığı Light (50g)'
        ];
        ad = proteinler[i ~/ 15 % proteinler.length];
        malzemeler = ['Protein kaynağı ${50 + (i % 30)}g'];
        kalori = 80 + (i % 70);
        protein = 15 + (i % 10);
        karbonhidrat = 1 + (i % 3);
        yag = 2 + (i % 4);
        break;
        
      case 8: // Fırınlanmış Sebzeler
        final firinsebze = [
          'Fırın Kabak Dilimleri',
          'Fırın Patlıcan',
          'Fırın Biber',
          'Fırın Mantar',
          'Fırın Domates',
          'Fırın Havuç',
          'Fırın Karnabahar',
          'Fırın Brokoli',
          'Fırın Tatlı Patates (küçük)',
          'Fırın Kuşkonmaz'
        ];
        ad = firinsebze[i ~/ 15 % firinsebze.length];
        malzemeler = ['Fırınlanmış sebze ${100 + (i % 80)}g', 'Zeytinyağı 5ml', 'Baharat'];
        kalori = 70 + (i % 60);
        protein = 3 + (i % 4);
        karbonhidrat = 12 + (i % 10);
        yag = 3 + (i % 4);
        break;
        
      case 9: // Light Kraker ve Ekmekler
        final krakerler = [
          'Kepekli Kraker (3 adet)',
          'Protein Kraker (2 adet)',
          'Tam Tahıl Grissini (3 adet)',
          'Pirinç Krateri (2 adet)',
          'Yulaf Krateri (2 adet)',
          'Kinoa Kraker (2 adet)',
          'Light Melba Toast (3 adet)',
          'Tam Buğday Kraker (3 adet)',
          'Galeta Light (3 adet)',
          'Kepek Bisküvisi (2 adet)'
        ];
        ad = krakerler[i ~/ 15 % krakerler.length];
        malzemeler = ['Light kraker ${20 + (i % 15)}g'];
        kalori = 60 + (i % 60);
        protein = 3 + (i % 4);
        karbonhidrat = 12 + (i % 10);
        yag = 1 + (i % 2);
        break;
        
      case 10: // Akşam Öncesi Meyveler (Az Şekerli)
        final meyveler = [
          'Yeşil Elma (1 küçük)',
          'Greyfurt (yarım)',
          'Çilek (100g)',
          'Frambuaz (80g)',
          'Yaban Mersini (70g)',
          'Böğürtlen (80g)',
          'Karpuz (150g)',
          'Kavun (100g)',
          'Kiraz (10 adet)',
          'Ahududu (80g)'
        ];
        ad = meyveler[i ~/ 15 % meyveler.length];
        malzemeler = ['Az şekerli meyve ${70 + (i % 60)}g'];
        kalori = 50 + (i % 50);
        protein = 1 + (i % 2);
        karbonhidrat = 12 + (i % 10);
        yag = 0;
        break;
        
      case 11: // Protein Pudingler
        final pudingler = [
          'Chia Protein Puding',
          'Whey Protein Puding',
          'Casein Puding',
          'Vegan Protein Puding',
          'Çikolatalı Protein Puding',
          'Vanilya Protein Puding',
          'Frambuazlı Protein Puding',
          'Kahveli Protein Puding',
          'Muzlu Protein Puding',
          'Çilekli Protein Puding'
        ];
        ad = pudingler[i ~/ 15 % pudingler.length];
        malzemeler = ['Protein tozu 20g', 'Süt/Su 100ml', 'Tatlandırıcı'];
        kalori = 90 + (i % 60);
        protein = 15 + (i % 10);
        karbonhidrat = 8 + (i % 8);
        yag = 2 + (i % 3);
        break;
        
      case 12: // Zeytinyağlı Light Mezeler
        final mezeler = [
          'Zeytinyağlı Yaprak Sarma (1 adet)',
          'Zeytinyağlı Biber Dolma (1 adet)',
          'Zeytinyağlı Pırasa (50g)',
          'Zeytinyağlı Enginar (yarım)',
          'Zeytinyağlı Taze Fasulye (50g)',
          'Zeytinyağlı Barbunya (50g)',
          'Zeytinyağlı Bamya (50g)',
          'Zeytinyağlı Kabak (80g)',
          'Zeytinyağlı Kereviz (60g)',
          'Zeytinyağlı Lahana Sarma (1 adet)'
        ];
        ad = mezeler[i ~/ 15 % mezeler.length];
        malzemeler = ['Zeytinyağlı yemek ${50 + (i % 40)}g'];
        kalori = 60 + (i % 60);
        protein = 2 + (i % 3);
        karbonhidrat = 10 + (i % 8);
        yag = 3 + (i % 4);
        break;
        
      case 13: // Baharatlı Atıştırmalıklar
        final baharatli = [
          'Kavrulmuş Nohut Baharatlı',
          'Fırın Leblebi',
          'Baharatlı Ay Çekirdeği',
          'Sumak + Nohut Mix',
          'Baharatlı Edamame',
          'Kimyon + Leblebi',
          'Fırın Nohut Krokan',
          'Baharatlı Bezelye',
          'Pul Biber + Leblebi',
          'Hardal + Badem Mix'
        ];
        ad = baharatli[i ~/ 15 % baharatli.length];
        malzemeler = ['Ana ürün ${30 + (i % 25)}g', 'Baharat karışımı'];
        kalori = 100 + (i % 70);
        protein = 6 + (i % 6);
        karbonhidrat = 14 + (i % 10);
        yag = 4 + (i % 4);
        break;
        
      case 14: // Probiyotik İçecekler
        final probiyotik = [
          'Kefir Light (200ml)',
          'Kombucha (200ml)',
          'Probiyotik Yoğurt İçeceği',
          'Ayran Light (200ml)',
          'Fermente Süt',
          'Probiyotik Smoothie',
          'Kefir + Meyve',
          'Kombucha + Zencefil',
          'Probiyotik Water Kefir',
          'Fermente Sebze Suyu'
        ];
        ad = probiyotik[i ~/ 15 % probiyotik.length];
        malzemeler = ['Probiyotik içecek ${150 + (i % 100)}ml'];
        kalori = 50 + (i % 60);
        protein = 5 + (i % 5);
        karbonhidrat = 7 + (i % 8);
        yag = 1 + (i % 3);
        break;
      
      default:
        ad = 'Ara Öğün 2 Varyasyon ${i + 1}';
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
  
  final file = File('assets/data/mega_ara_ogun_2_batch_2.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 2');
  print('📊 TOPLAM ARA ÖĞÜN 2 (2 Batch): 300 ara öğün');
  print('📁 Dosya: ${file.path}');
}
