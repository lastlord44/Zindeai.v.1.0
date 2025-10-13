import 'dart:convert';
import 'dart:io';

/// BATCH 6: ÖĞLE YEMEKLERİ 3 (100 yemek daha - ID 501-600)
void main() async {
  print('🍗 ÖĞLE YEMEKLERİ BATCH 3: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 501;
  
  // 100 farklı öğle yemeği daha (çeşitlilik maksimum)
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final varyasyon = i % 20; // 20 farklı kategori
    
    switch(varyasyon) {
      case 0: // Zeytinyağlılar
        final zeytinyaglilar = ['Zeytinyağlı Taze Fasulye', 'Zeytinyağlı Pırasa', 'Zeytinyağlı Barbunya', 'Zeytinyağlı Kabak', 'Zeytinyağlı Bakla'];
        ad = "${zeytinyaglilar[i ~/ 20 % zeytinyaglilar.length]} + Pilav + Yoğurt";
        malzemeler = ["Sebze ${120 + i % 60}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 380 + (i % 90);
        protein = 16 + (i % 8);
        karbonhidrat = 58 + (i % 22);
        yag = 12 + (i % 8);
        break;
        
      case 1: // Izgara çeşitleri
        final izgaralar = ['Izgara Köfte', 'Izgara Tavuk', 'Izgara Balık', 'Izgara Et', 'Izgara Sebze + Hellim'];
        ad = "${izgaralar[i ~/ 20 % izgaralar.length]} + Bulgur + Salata + Turşu";
        malzemeler = ["Protein ${110 + i % 70}g", "Bulgur ${60 + i % 30}g", "Salata ${70 + i % 40}g"];
        kalori = 470 + (i % 110);
        protein = 34 + (i % 16);
        karbonhidrat = 48 + (i % 22);
        yag = 16 + (i % 12);
        break;
        
      case 2: // Fırın yemekleri
        final firinYemekleri = ['Fırın Tavuk', 'Fırın Balık', 'Fırın Köfte', 'Fırın Sebze + Et', 'Fırın Patlıcan + Kıyma'];
        ad = "${firinYemekleri[i ~/ 20 % firinYemekleri.length]} + Patates + Salata";
        malzemeler = ["Ana Malzeme ${130 + i % 70}g", "Patates ${100 + i % 50}g", "Salata ${60 + i % 30}g"];
        kalori = 460 + (i % 110);
        protein = 32 + (i % 14);
        karbonhidrat = 50 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 3: // Dolma & Sarma
        final dolmalar = ['Biber Dolması', 'Kabak Dolması', 'Patlıcan Dolması', 'Yaprak Sarma', 'Lahana Sarması'];
        ad = "${dolmalar[i ~/ 20 % dolmalar.length]} + Yoğurt + Pilav";
        malzemeler = ["Dolma/Sarma ${150 + i % 70}g", "Yoğurt ${100 + i % 50}g", "Pilav ${50 + i % 30}g"];
        kalori = 440 + (i % 100);
        protein = 20 + (i % 10);
        karbonhidrat = 56 + (i % 24);
        yag = 14 + (i % 10);
        break;
        
      case 4: // Tavada yemekler
        final tavalar = ['Tavada Köfte', 'Tavada Tavuk', 'Tavada Balık', 'Tavada Karides', 'Tavada Sebzeli Et'];
        ad = "${tavalar[i ~/ 20 % tavalar.length]} + Pilav + Turşu";
        malzemeler = ["Protein ${120 + i % 70}g", "Pilav ${60 + i % 30}g", "Turşu ${30 + i % 20}g"];
        kalori = 480 + (i % 120);
        protein = 30 + (i % 14);
        karbonhidrat = 52 + (i % 24);
        yag = 18 + (i % 14);
        break;
        
      case 5: // Çorba + Ana Yemek kombos
        final corbaKombo = ['Mercimek Çorbası + Köfte', 'Tarhana + Tavuk', 'Ezogelin + Et', 'Düğün Çorbası + Pilav', 'Yayla + Börek'];
        ad = "${corbaKombo[i ~/ 20 % corbaKombo.length]} + Pilav";
        malzemeler = ["Çorba 250ml", "Ana Yemek ${90 + i % 60}g", "Pilav ${50 + i % 30}g"];
        kalori = 450 + (i % 110);
        protein = 26 + (i % 12);
        karbonhidrat = 58 + (i % 26);
        yag = 12 + (i % 10);
        break;
        
      case 6: // Etli sebze yemekleri
        final etliSebzeler = ['Etli Taze Fasulye', 'Etli Bezelye', 'Etli Bamya', 'Etli Kabak', 'Etli Kereviz'];
        ad = "${etliSebzeler[i ~/ 20 % etliSebzeler.length]} + Pilav + Yoğurt";
        malzemeler = ["Sebze + Et ${140 + i % 70}g", "Pilav ${55 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 460 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 54 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 7: // Pilav çeşitleri farklı kombinasyonlar
        final pilavKombolar = ['İç Pilav + Tavuk', 'Nohutlu Pilav + Köfte', 'Şehriyeli Pilav + Et', 'Domatesli Pilav + Tavuk', 'Bulgur Pilav + Izgara'];
        ad = pilavKombolar[i ~/ 20 % pilavKombolar.length];
        malzemeler = ["Pilav ${70 + i % 30}g", "Protein ${100 + i % 60}g", "Salata ${60 + i % 30}g"];
        kalori = 470 + (i % 110);
        protein = 30 + (i % 14);
        karbonhidrat = 60 + (i % 26);
        yag = 14 + (i % 10);
        break;
        
      case 8: // Türk usulü kebaplar
        final kebapCesitleri = ['Ali Nazik', 'Hünkar Beğendi', 'Patlıcan Kebabı', 'Orman Kebabı', 'Testi Kebabı'];
        ad = "${kebapCesitleri[i ~/ 20 % kebapCesitleri.length]} + Pilav";
        malzemeler = ["Et ${110 + i % 60}g", "Garnitür ${80 + i % 40}g", "Pilav ${60 + i % 30}g"];
        kalori = 490 + (i % 120);
        protein = 32 + (i % 14);
        karbonhidrat = 52 + (i % 24);
        yag = 20 + (i % 14);
        break;
        
      case 9: // Kızartmalar
        final kizartmalar = ['Patlıcan Kızartma', 'Kabak Kızartma', 'Balık Kızartma', 'Tavuk Kızartma', 'Karnabahar Kızartma'];
        ad = "${kizartmalar[i ~/ 20 % kizartmalar.length]} + Pilav + Cacık";
        malzemeler = ["Kızartma ${130 + i % 70}g", "Pilav ${50 + i % 30}g", "Cacık ${100 + i % 50}g"];
        kalori = 450 + (i % 110);
        protein = 22 + (i % 10);
        karbonhidrat = 56 + (i % 26);
        yag = 16 + (i % 12);
        break;
        
      case 10: // Güveç çeşitleri
        final guvecler = ['Tavuk Güveç', 'Et Güveç', 'Sebze Güveç', 'Mantarlı Güveç', 'Karides Güveç'];
        ad = "${guvecler[i ~/ 20 % guvecler.length]} + Pilav + Salata";
        malzemeler = ["Güveç ${140 + i % 70}g", "Pilav ${60 + i % 30}g", "Salata ${60 + i % 30}g"];
        kalori = 460 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 52 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 11: // Musakka & türevleri
        final musakkalar = ['Patlıcan Musakka', 'Kabak Musakka', 'Patates Musakka', 'Karnabahar Musakka', 'Karışık Musakka'];
        ad = "${musakkalar[i ~/ 20 % musakkalar.length]} + Pilav + Yoğurt";
        malzemeler = ["Musakka ${150 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 470 + (i % 110);
        protein = 24 + (i % 10);
        karbonhidrat = 54 + (i % 24);
        yag = 18 + (i % 14);
        break;
        
      case 12: // Haşlama & Kapama
        final haslamalar = ['Tavuk Haşlama', 'Et Haşlama', 'Tavuk Kapama', 'Et Kapama', 'Balık Buğulama'];
        ad = "${haslamalar[i ~/ 20 % haslamalar.length]} + Pilav + Sebze";
        malzemeler = ["Protein ${130 + i % 70}g", "Pilav ${55 + i % 30}g", "Sebze ${70 + i % 40}g"];
        kalori = 440 + (i % 100);
        protein = 36 + (i % 16);
        karbonhidrat = 48 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 13: // Sote çeşitleri
        final soteler = ['Tavuk Sote', 'Et Sote', 'Mantar Sote', 'Sebze Sote', 'Karides Sote'];
        ad = "${soteler[i ~/ 20 % soteler.length]} + Bulgur + Salata";
        malzemeler = ["Sote ${130 + i % 70}g", "Bulgur ${60 + i % 30}g", "Salata ${60 + i % 30}g"];
        kalori = 450 + (i % 110);
        protein = 30 + (i % 14);
        karbonhidrat = 50 + (i % 24);
        yag = 14 + (i % 10);
        break;
        
      case 14: // Kavurma çeşitleri
        final kavurmalar = ['Tavuk Kavurma', 'Et Kavurma', 'Ciğer Kavurma', 'Sebzeli Kavurma', 'Nohutlu Kavurma'];
        ad = "${kavurmalar[i ~/ 20 % kavurmalar.length]} + Pilav + Turşu";
        malzemeler = ["Kavurma ${120 + i % 60}g", "Pilav ${60 + i % 30}g", "Turşu ${30 + i % 20}g"];
        kalori = 480 + (i % 120);
        protein = 32 + (i % 14);
        karbonhidrat = 52 + (i % 24);
        yag = 18 + (i % 14);
        break;
        
      case 15: // Wrap & Dürüm
        final wraplar = ['Tavuk Wrap', 'Et Wrap', 'Falafel Wrap', 'Sebze Wrap', 'Ton Balıklı Wrap'];
        ad = "${wraplar[i ~/ 20 % wraplar.length]} + Patates + Ayran";
        malzemeler = ["Wrap ${150 + i % 70}g", "Patates ${80 + i % 40}g", "Ayran 200ml"];
        kalori = 490 + (i % 120);
        protein = 26 + (i % 12);
        karbonhidrat = 60 + (i % 28);
        yag = 16 + (i % 12);
        break;
        
      case 16: // Pide & Lahmacun
        final pideler = ['Kıymalı Pide', 'Kaşarlı Pide', 'Peynirli Pide', 'Sucuklu Pide', 'Karışık Pide'];
        ad = "${pideler[i ~/ 20 % pideler.length]} + Ayran + Salata";
        malzemeler = ["Pide ${140 + i % 70}g", "Ayran 200ml", "Salata ${60 + i % 30}g"];
        kalori = 500 + (i % 130);
        protein = 24 + (i % 12);
        karbonhidrat = 64 + (i % 28);
        yag = 18 + (i % 14);
        break;
        
      case 17: // Tandır çeşitleri
        final tandirlar = ['Kuzu Tandır', 'Tavuk Tandır', 'Dana Tandır', 'Et Tandır + Pilav', 'Tandır Kebap'];
        ad = "${tandirlar[i ~/ 20 % tandirlar.length]} + Bulgur + Salata";
        malzemeler = ["Tandır ${140 + i % 70}g", "Bulgur ${60 + i % 30}g", "Salata ${60 + i % 30}g"];
        kalori = 510 + (i % 130);
        protein = 38 + (i % 16);
        karbonhidrat = 50 + (i % 24);
        yag = 20 + (i % 14);
        break;
        
      case 18: // Kremalı yemekler
        final kremalilar = ['Kremalı Tavuk', 'Kremalı Mantar', 'Kremalı Makarna', 'Kremalı Sebze', 'Kremalı Köfte'];
        ad = "${kremalilar[i ~/ 20 % kremalilar.length]} + Pilav + Salata";
        malzemeler = ["Ana Malzeme ${120 + i % 60}g", "Pilav ${60 + i % 30}g", "Salata ${60 + i % 30}g"];
        kalori = 480 + (i % 120);
        protein = 26 + (i % 12);
        karbonhidrat = 54 + (i % 26);
        yag = 18 + (i % 14);
        break;
        
      case 19: // Özel tarifler
        final ozelTarifler = ['Karnıyarık', 'İmam Bayıldı', 'Şakşuka', 'Türlü', 'Patlıcan Beğendi'];
        ad = "${ozelTarifler[i ~/ 20 % ozelTarifler.length]} + Pilav + Cacık";
        malzemeler = ["Özel Tarif ${140 + i % 70}g", "Pilav ${60 + i % 30}g", "Cacık ${100 + i % 50}g"];
        kalori = 460 + (i % 110);
        protein = 22 + (i % 10);
        karbonhidrat = 56 + (i % 26);
        yag = 16 + (i % 12);
        break;
        
      default:
        ad = "Öğle Yemeği Spesyal ${id}";
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
  
  final file = File('assets/data/mega_ogle_batch_3.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} öğle yemeği');
  print('📊 Toplam Öğle (3 Batch): 300 yemek');
  print('📁 Dosya: ${file.path}');
}
