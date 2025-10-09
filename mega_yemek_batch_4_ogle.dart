import 'dart:convert';
import 'dart:io';

/// BATCH 4: ÖĞLE YEMEKLERİ (100 yemek - ID 301-400)
void main() async {
  print('🍗 ÖĞLE YEMEKLERİ BATCH 1: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 301;
  
  // 100 farklı öğle yemeği alternatifi
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Tavuk yemekleri
        final tavuklar = [
          'Izgara Tavuk Göğüs + Bulgur Pilavı + Salata',
          'Fırında Tavuk But + Patates + Sebze',
          'Tavuk Sote + Esmer Pirinç + Cacık',
          'Tavuk Şiş + Bulgur + Közlenmiş Biber',
          'Haşlanmış Tavuk + Sebze Püresi',
          'Tavuk Kanat + Patates Kızartması + Salata',
          'Tavuklu Nohut Yemeği + Pilav',
          'Tavuklu Sebze Güveç + Bulgur',
          'Kremalı Mantarlı Tavuk + Pirinç',
          'Tavuk Döner + Bulgur Pilavı + Turşu'
        ];
        ad = tavuklar[i ~/ 10 % tavuklar.length];
        malzemeler = ["Tavuk ${120 + i % 80}g", "Karbonhidrat ${50 + i % 30}g", "Sebze ${80 + i % 40}g"];
        kalori = 450 + (i % 100);
        protein = 38 + (i % 15);
        karbonhidrat = 45 + (i % 20);
        yag = 12 + (i % 10);
        break;
        
      case 1: // Et yemekleri
        final etler = [
          'Izgara Köfte + Bulgur Pilavı + Salata',
          'Dana Haşlama + Sebze + Pilav',
          'Kuzu Güveç + Esmer Pirinç',
          'Dana Kavurma + Bulgur + Yoğurt',
          'Biftek + Patates + Mantar Sos',
          'Etli Kuru Fasulye + Pilav + Turşu',
          'Kıymalı Patlıcan Musakka + Yoğurt',
          'Etli Nohut + Bulgur Pilavı',
          'Dana Rosto + Sebze Garnitür',
          'Kuzu Pirzola + Patates + Salata'
        ];
        ad = etler[i ~/ 10 % etler.length];
        malzemeler = ["Et ${100 + i % 60}g", "Pilav/Bulgur ${50 + i % 30}g", "Sebze ${70 + i % 40}g"];
        kalori = 480 + (i % 120);
        protein = 35 + (i % 15);
        karbonhidrat = 48 + (i % 25);
        yag = 18 + (i % 12);
        break;
        
      case 2: // Balık yemekleri
        final baliklar = [
          'Izgara Somon + Bulgur Pilavı + Salata',
          'Levrek Buğulama + Esmer Pirinç',
          'Hamsi Tava + Mısır Ekmeği + Salata',
          'Ton Balığı Izgara + Kinoa + Sebze',
          'Sardalya Tava + Bulgur + Limon',
          'Alabalık Fırın + Patates + Roka',
          'Uskumru Izgara + Pilav + Salata',
          'Palamut Tava + Bulgur + Turşu',
          'Levrek Izgara + Sebze + Pilav',
          'Mezgit Kızartma + Patates + Salata'
        ];
        ad = baliklar[i ~/ 10 % baliklar.length];
        malzemeler = ["Balık ${120 + i % 80}g", "Pilav ${50 + i % 30}g", "Sebze ${80 + i % 40}g"];
        kalori = 420 + (i % 110);
        protein = 35 + (i % 15);
        karbonhidrat = 42 + (i % 20);
        yag = 14 + (i % 12);
        break;
        
      case 3: // Kuru baklagiller
        final baklagiller = [
          'Kuru Fasulye + Bulgur Pilavı + Turşu',
          'Nohut Yemeği + Esmer Pirinç + Salata',
          'Barbunya Pilaki + Bulgur + Yoğurt',
          'Yeşil Mercimek Yemeği + Pilav',
          'Kırmızı Mercimek Çorbası + Pilav + Salata',
          'Nohutlu Ispanak + Bulgur + Yoğurt',
          'Börülce Yemeği + Pilav + Turşu',
          'Mercimekli Köfte + Salata + Yoğurt',
          'Etli Nohut + Bulgur Pilavı',
          'Kuru Fasulye Pilaki + Pilav'
        ];
        ad = baklagiller[i ~/ 10 % baklagiller.length];
        malzemeler = ["Baklagil ${100 + i % 50}g", "Pilav ${50 + i % 30}g", "Yoğurt/Salata ${80 + i % 40}g"];
        kalori = 430 + (i % 100);
        protein = 20 + (i % 10);
        karbonhidrat = 68 + (i % 20);
        yag = 8 + (i % 8);
        break;
        
      case 4: // Sebze yemekleri
        final sebzeler = [
          'Patlıcan Musakka + Yoğurt + Pilav',
          'Türlü + Bulgur Pilavı',
          'Kabak Dolması + Yoğurt',
          'Ispanaklı Börek + Ayran',
          'Karnabahar Graten + Pilav',
          'Pırasa Yemeği + Pilav + Yoğurt',
          'Bamya Yemeği + Bulgur + Cacık',
          'Kabak Mücver + Yoğurt + Salata',
          'Patlıcan Karnıyarık + Pilav',
          'Biber Dolması + Yoğurt'
        ];
        ad = sebzeler[i ~/ 10 % sebzeler.length];
        malzemeler = ["Sebze ${120 + i % 80}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 400 + (i % 100);
        protein = 18 + (i % 10);
        karbonhidrat = 55 + (i % 25);
        yag = 14 + (i % 10);
        break;
        
      case 5: // Makarna çeşitleri
        final makarnalar = [
          'Bolonez Makarna + Salata',
          'Fettuccine Alfredo + Tavuk',
          'Penne Arabiata + Peynir',
          'Mantı + Yoğurt + Salça',
          'Ravioli + Domates Sos',
          'Kıymalı Makarna + Salata',
          'Tavuklu Spagetti + Sebze',
          'Pesto Soslu Makarna + Mantar',
          'Kremalı Mantarlı Makarna',
          'Fırın Makarna + Salata'
        ];
        ad = makarnalar[i ~/ 10 % makarnalar.length];
        malzemeler = ["Makarna ${80 + i % 40}g", "Sos/Et ${60 + i % 40}g", "Sebze ${60 + i % 30}g"];
        kalori = 480 + (i % 120);
        protein = 22 + (i % 12);
        karbonhidrat = 65 + (i % 25);
        yag = 16 + (i % 12);
        break;
        
      case 6: // Pilav çeşitleri
        final pilavlar = [
          'İç Pilav + Tavuk + Salata',
          'Etli Pilav + Yoğurt + Turşu',
          'Tavuklu Nohutlu Pilav + Salata',
          'Bulgur Pilavı + Köfte + Cacık',
          'Sebzeli Pilav + Tavuk',
          'Esmer Pirinç Pilav + Izgara Et',
          'Şehriyeli Pilav + Tavuk Haşlama',
          'Nohutlu Bulgur Pilavı + Yoğurt',
          'Mercimekli Bulgur + Cacık',
          'Etli Sebzeli Pilav + Turşu'
        ];
        ad = pilavlar[i ~/ 10 % pilavlar.length];
        malzemeler = ["Pilav ${70 + i % 30}g", "Protein ${80 + i % 50}g", "Sebze ${60 + i % 30}g"];
        kalori = 460 + (i % 100);
        protein = 28 + (i % 12);
        karbonhidrat = 58 + (i % 20);
        yag = 14 + (i % 10);
        break;
        
      case 7: // Çorbalar + Ana Yemek
        final corbalar = [
          'Mercimek Çorbası + Tavuklu Sandviç',
          'Tarhana Çorbası + Börek + Ayran',
          'Ezogelin Çorbası + Pilav + Köfte',
          'Domates Çorbası + Peynirli Tost',
          'Sebze Çorbası + Tavuk + Pilav',
          'İşkembe Çorbası + Ekmek + Turşu',
          'Yayla Çorbası + Pilav + Salata',
          'Düğün Çorbası + Ekmek + Peynir',
          'Tavuk Suyu Çorbası + Pilav',
          'Kelle Paça + Ekmek + Turşu'
        ];
        ad = corbalar[i ~/ 10 % corbalar.length];
        malzemeler = ["Çorba 250ml", "Ana Yemek ${80 + i % 50}g", "Ekmek ${50 + i % 30}g"];
        kalori = 440 + (i % 110);
        protein = 24 + (i % 12);
        karbonhidrat = 55 + (i % 25);
        yag = 12 + (i % 10);
        break;
        
      case 8: // Ev yemekleri karışık
        final evYemekleri = [
          'Karnıyarık + Pilav + Cacık',
          'İmam Bayıldı + Bulgur + Yoğurt',
          'Hünkar Beğendi + Kuzu',
          'Patlıcan Kebabı + Pilav',
          'Tepsi Kebabı + Bulgur + Ayran',
          'Güveç + Pilav + Salata',
          'Türlü + Tavuk + Pilav',
          'Fırın Sebze + Et + Pilav',
          'Kapama + Bulgur + Yoğurt',
          'Tas Kebabı + Pilav + Turşu'
        ];
        ad = evYemekleri[i ~/ 10 % evYemekleri.length];
        malzemeler = ["Ana Malzeme ${100 + i % 60}g", "Pilav ${60 + i % 30}g", "Garnitür ${70 + i % 30}g"];
        kalori = 470 + (i % 110);
        protein = 26 + (i % 14);
        karbonhidrat = 52 + (i % 25);
        yag = 18 + (i % 12);
        break;
        
      case 9: // Fast food & pratik
        final pratik = [
          'Hamburger + Patates Kızartması',
          'Tavuk Wrap + Salata',
          'Pizza Dilim (3) + Salata',
          'Döner Dürüm + Ayran',
          'Lahmacun (2) + Ayran + Yeşillik',
          'Pide Kıymalı + Ayran',
          'Sandviç Tavuklu + Cips',
          'Tost Kaşarlı + Ayran',
          'Köfte Ekmek + Patates',
          'Tavuk Burger + Soğan Halkası'
        ];
        ad = pratik[i ~/ 10 % pratik.length];
        malzemeler = ["Ana Ürün ${120 + i % 80}g", "Ek ${60 + i % 40}g", "İçecek 200ml"];
        kalori = 520 + (i % 130);
        protein = 26 + (i % 14);
        karbonhidrat = 60 + (i % 30);
        yag = 22 + (i % 15);
        break;
        
      default:
        ad = "Öğle Yemeği ${id}";
        malzemeler = ["Karma"];
        kalori = 450;
        protein = 25;
        karbonhidrat = 50;
        yag = 15;
    }
    
    yemekler.add({
      "id": "OGLE_${id++}",
      "ad": ad,
      "ogun": "ogle",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_ogle_batch_1.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} öğle yemeği');
  print('📁 Dosya: ${file.path}');
}
