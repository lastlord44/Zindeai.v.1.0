import 'dart:convert';
import 'dart:io';

/// BATCH 9: AKŞAM YEMEKLERİ 2 (100 yemek - ID 801-900)
void main() async {
  print('🌙 AKŞAM YEMEKLERİ BATCH 2: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 801;
  
  // 100 farklı akşam yemeği alternatifi daha
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Et yemekleri (Akşama uyarlanmış)
        final etYemekleri = ['Izgara Dana + Sebze + Pilav', 'Kuzu Tandır + Bulgur', 'Biftek + Mantar + Patates', 'Dana Kavurma + Pilav + Cacık', 'Kuzu Pirzola + Sebze'];
        ad = etYemekleri[i ~/ 10 % etYemekleri.length];
        malzemeler = ["Et ${110 + i % 60}g", "Sebze ${80 + i % 40}g", "Pilav ${50 + i % 30}g"];
        kalori = 470 + (i % 110);
        protein = 36 + (i % 15);
        karbonhidrat = 42 + (i % 22);
        yag = 18 + (i % 14);
        break;
        
      case 1: // Dolma & Sarma çeşitleri
        final dolmaSarma = ['Yaprak Sarma + Yoğurt', 'Biber Dolması + Yoğurt', 'Kabak Dolması + Pilav', 'Lahana Sarması + Yoğurt', 'Patlıcan Dolması + Pilav'];
        ad = dolmaSarma[i ~/ 10 % dolmaSarma.length];
        malzemeler = ["Dolma/Sarma ${140 + i % 70}g", "Yoğurt ${100 + i % 50}g", "Ek ${50 + i % 30}g"];
        kalori = 430 + (i % 100);
        protein = 20 + (i % 10);
        karbonhidrat = 54 + (i % 26);
        yag = 14 + (i % 10);
        break;
        
      case 2: // Güveç çeşitleri
        final guvecler = ['Tavuk Güveç + Pilav', 'Et Güveç + Bulgur', 'Sebze Güveç + Pilav', 'Mantarlı Tavuk Güveç', 'Patlıcan Güveç + Pilav'];
        ad = guvecler[i ~/ 10 % guvecler.length];
        malzemeler = ["Güveç ${130 + i % 70}g", "Pilav ${55 + i % 30}g", "Sebze ${70 + i % 40}g"];
        kalori = 450 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 50 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 3: // Musakka & Karnıyarık
        final musakkalar = ['Patlıcan Musakka + Pilav + Yoğurt', 'Kabak Musakka + Bulgur', 'Patlıcan Karnıyarık + Cacık', 'Karnabahar Musakka + Pilav', 'Karışık Musakka + Yoğurt'];
        ad = musakkalar[i ~/ 10 % musakkalar.length];
        malzemeler = ["Ana Yemek ${140 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 460 + (i % 110);
        protein = 24 + (i % 10);
        karbonhidrat = 52 + (i % 24);
        yag = 18 + (i % 14);
        break;
        
      case 4: // Balık çeşitleri (Akşam için)
        final balikCesitleri = ['Levrek Fırın + Sebze + Pilav', 'Çipura Izgara + Salata', 'Somon Teriyaki + Pirinç', 'Alabalık Fırın + Patates', 'Hamsi Pilavı + Salata'];
        ad = balikCesitleri[i ~/ 10 % balikCesitleri.length];
        malzemeler = ["Balık ${130 + i % 70}g", "Sebze/Pilav ${100 + i % 50}g", "Garnitür ${60 + i % 30}g"];
        kalori = 420 + (i % 100);
        protein = 34 + (i % 16);
        karbonhidrat = 40 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 5: // Kıymalı yemekler
        final kiymaliYemekler = ['Kıymalı Patlıcan + Pilav', 'Kıymalı Ispanak + Yoğurt', 'Kıymalı Patates + Bulgur', 'İçli Köfte + Salata', 'Kıymalı Makarna + Salata'];
        ad = kiymaliYemekler[i ~/ 10 % kiymaliYemekler.length];
        malzemeler = ["Kıyma + Sebze ${120 + i % 60}g", "Pilav ${55 + i % 30}g", "Yoğurt/Salata ${70 + i % 40}g"];
        kalori = 460 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 50 + (i % 26);
        yag = 18 + (i % 14);
        break;
        
      case 6: // Fırın yemekleri
        final firinYemekleri = ['Fırın Tavuk + Patates + Salata', 'Fırın Köfte + Sebze + Pilav', 'Fırın Balık + Sebze', 'Fırın Sebze + Peynir + Pilav', 'Fırın Patlıcan + Yoğurt'];
        ad = firinYemekleri[i ~/ 10 % firinYemekleri.length];
        malzemeler = ["Ana Malzeme ${130 + i % 70}g", "Sebze ${90 + i % 50}g", "Pilav ${50 + i % 30}g"];
        kalori = 450 + (i % 110);
        protein = 30 + (i % 14);
        karbonhidrat = 46 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 7: // Salata + Protein (Hafif akşam)
        final salataProtein = ['Caesar Salata + Tavuk', 'Kinoa Salata + Somon', 'Ton Balıklı Salata + Ekmek', 'Tavuklu Bulgur Salatası', 'Akdeniz Salatası + Peynir'];
        ad = salataProtein[i ~/ 10 % salataProtein.length];
        malzemeler = ["Sebze ${100 + i % 60}g", "Protein ${90 + i % 50}g", "Sos/Ekmek ${50 + i % 30}g"];
        kalori = 390 + (i % 90);
        protein = 30 + (i % 14);
        karbonhidrat = 36 + (i % 20);
        yag = 14 + (i % 10);
        break;
        
      case 8: // Sote çeşitleri
        final soteler = ['Tavuk Sote + Bulgur + Salata', 'Et Sote + Pilav + Cacık', 'Sebze Sote + Pilav', 'Mantar Sote + Tavuk + Bulgur', 'Karides Sote + Pirinç'];
        ad = soteler[i ~/ 10 % soteler.length];
        malzemeler = ["Sote ${120 + i % 60}g", "Pilav ${60 + i % 30}g", "Garnitür ${70 + i % 40}g"];
        kalori = 440 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 48 + (i % 24);
        yag = 14 + (i % 10);
        break;
        
      case 9: // Zeytinyağlılar
        final zeytinyaglilar = ['Zeytinyağlı Taze Fasulye + Pilav', 'Zeytinyağlı Barbunya + Bulgur', 'Zeytinyağlı Pırasa + Pilav + Yoğurt', 'Zeytinyağlı Kabak + Yoğurt', 'Zeytinyağlı Enginar + Pilav'];
        ad = zeytinyaglilar[i ~/ 10 % zeytinyaglilar.length];
        malzemeler = ["Sebze ${130 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 390 + (i % 90);
        protein = 16 + (i % 8);
        karbonhidrat = 60 + (i % 26);
        yag = 10 + (i % 8);
        break;
        
      default:
        ad = "Akşam Yemeği ${id}";
        malzemeler = ["Karma"];
        kalori = 420;
        protein = 25;
        karbonhidrat = 48;
        yag = 12;
    }
    
    yemekler.add({
      "id": "AKSAM_${id++}",
      "ad": ad,
      "ogun": "aksam",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_aksam_batch_2.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} akşam yemeği');
  print('📊 Toplam Akşam (2 Batch): 200 yemek');
  print('📁 Dosya: ${file.path}');
}
