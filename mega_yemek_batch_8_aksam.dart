import 'dart:convert';
import 'dart:io';

/// BATCH 8: AKŞAM YEMEKLERİ 1 (100 yemek - ID 701-800)
void main() async {
  print('🌙 AKŞAM YEMEKLERİ BATCH 1: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 701;
  
  // Akşam yemekleri genelde öğle ile benzer ama hafif versiyonları da var
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Hafif tavuk yemekleri
        final hafifTavuklar = ['Izgara Tavuk + Salata + Yoğurt', 'Haşlanmış Tavuk + Sebze + Bulgur', 'Tavuk Sote + Kinoa', 'Tavuk Göğüs + Brokoli + Esmer Pirinç', 'Fırın Tavuk + Sebze Garnitür'];
        ad = hafifTavuklar[i ~/ 10 % hafifTavuklar.length];
        malzemeler = ["Tavuk ${120 + i % 60}g", "Sebze ${90 + i % 50}g", "Karbonhidrat ${50 + i % 30}g"];
        kalori = 420 + (i % 100);
        protein = 38 + (i % 14);
        karbonhidrat = 40 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 1: // Balık yemekleri
        final baliklar = ['Izgara Somon + Salata + Pilav', 'Fırın Levrek + Sebze', 'Hamsi Buğulama + Bulgur', 'Ton Balığı Salatası + Ekmek', 'Palamut Izgara + Pilav'];
        ad = baliklar[i ~/ 10 % baliklar.length];
        malzemeler = ["Balık ${130 + i % 70}g", "Sebze ${80 + i % 40}g", "Pilav ${50 + i % 30}g"];
        kalori = 410 + (i % 110);
        protein = 35 + (i % 15);
        karbonhidrat = 38 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 2: // Çorba + Ana yemek
        final corbaKombo = ['Mercimek Çorbası + Tavuk + Salata', 'Sebze Çorbası + Köfte + Bulgur', 'Tarhana Çorbası + Peynir + Ekmek', 'Ezogelin + Tavuk Sote', 'Yayla Çorbası + Pilav'];
        ad = corbaKombo[i ~/ 10 % corbaKombo.length];
        malzemeler = ["Çorba 250ml", "Ana Malzeme ${90 + i % 50}g", "Ek ${60 + i % 30}g"];
        kalori = 430 + (i % 100);
        protein = 26 + (i % 12);
        karbonhidrat = 50 + (i % 24);
        yag = 12 + (i % 10);
        break;
        
      case 3: // Sebze ağırlıklı
        final sebzeAgirlikli = ['Zeytinyağlı Fasulye + Pilav + Yoğurt', 'Zeytinyağlı Pırasa + Bulgur', 'Sebze Güveç + Pilav', 'Türlü + Yoğurt', 'Zeytinyağlı Enginar + Pilav'];
        ad = sebzeAgirlikli[i ~/ 10 % sebzeAgirlikli.length];
        malzemeler = ["Sebze ${130 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 390 + (i % 90);
        protein = 18 + (i % 10);
        karbonhidrat = 58 + (i % 26);
        yag = 10 + (i % 8);
        break;
        
      case 4: // Köfte çeşitleri
        final kofteler = ['Izgara Köfte + Bulgur + Salata', 'Fırın Köfte + Patates', 'Tavuk Köfte + Pilav + Cacık', 'İnegöl Köfte + Bulgur', 'Mercimek Köfte + Salata + Yoğurt'];
        ad = kofteler[i ~/ 10 % kofteler.length];
        malzemeler = ["Köfte ${110 + i % 60}g", "Pilav/Bulgur ${55 + i % 30}g", "Garnitür ${70 + i % 40}g"];
        kalori = 450 + (i % 110);
        protein = 32 + (i % 14);
        karbonhidrat = 48 + (i % 24);
        yag = 16 + (i % 12);
        break;
        
      case 5: // Omlet & Yumurtalı yemekler
        final yumurtalilar = ['Sebzeli Omlet + Salata + Ekmek', 'Menemen + Peynir + Ekmek', 'Çırpılmış Yumurta + Avokado', 'Yumurtalı Ispanak + Yoğurt', 'Sahanda Yumurta + Sebze + Ekmek'];
        ad = yumurtalilar[i ~/ 10 % yumurtalilar.length];
        malzemeler = ["Yumurta ${120 + i % 60}g", "Sebze ${80 + i % 40}g", "Ekmek ${60 + i % 30}g"];
        kalori = 400 + (i % 100);
        protein = 24 + (i % 12);
        karbonhidrat = 40 + (i % 22);
        yag = 18 + (i % 14);
        break;
        
      case 6: // Makarna çeşitleri
        final makarnalar = ['Domates Soslu Makarna + Salata', 'Pesto Makarna + Tavuk', 'Kremalı Mantarlı Makarna', 'Ton Balıklı Makarna', 'Sebzeli Makarna + Peynir'];
        ad = makarnalar[i ~/ 10 % makarnalar.length];
        malzemeler = ["Makarna ${80 + i % 40}g", "Sos/Protein ${70 + i % 40}g", "Sebze ${60 + i % 30}g"];
        kalori = 460 + (i % 110);
        protein = 22 + (i % 12);
        karbonhidrat = 62 + (i % 26);
        yag = 14 + (i % 12);
        break;
        
      case 7: // Sağlıklı hafif yemekler
        final saglikli = ['Izgara Tavuk + Quinoa + Buharda Sebze', 'Ton Salatası + Yulaf Ekmeği', 'Izgara Somon + Tatlı Patates', 'Tavuk Salatası + Az Yağlı Peynir', 'Sebze Bowl + Tahini Sos'];
        ad = saglikli[i ~/ 10 % saglikli.length];
        malzemeler = ["Protein ${100 + i % 50}g", "Sebze ${100 + i % 50}g", "Sağlıklı Karbonhidrat ${50 + i % 30}g"];
        kalori = 380 + (i % 90);
        protein = 32 + (i % 14);
        karbonhidrat = 38 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 8: // Wrap & Sandviç
        final wrapSandvic = ['Tavuk Wrap + Salata', 'Ton Balıklı Sandviç', 'Izgara Tavuk Sandviç + Marul', 'Sebze Wrap + Humus', 'Peynirli Tost + Salata'];
        ad = wrapSandvic[i ~/ 10 % wrapSandvic.length];
        malzemeler = ["Ana Ürün ${130 + i % 70}g", "Sebze ${70 + i % 40}g", "Sos ${30 + i % 20}g"];
        kalori = 440 + (i % 110);
        protein = 26 + (i % 12);
        karbonhidrat = 50 + (i % 26);
        yag = 14 + (i % 12);
        break;
        
      case 9: // Pilav & bulgur çeşitleri
        final pilavlar = ['Tavuklu Bulgur Pilavı + Cacık', 'Sebzeli Pilav + Yoğurt', 'Nohutlu Pilav + Salata', 'Mercimekli Bulgur + Yoğurt', 'İç Pilav + Tavuk'];
        ad = pilavlar[i ~/ 10 % pilavlar.length];
        malzemeler = ["Pilav ${70 + i % 30}g", "Protein/Sebze ${90 + i % 50}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 440 + (i % 100);
        protein = 24 + (i % 12);
        karbonhidrat = 58 + (i % 26);
        yag = 12 + (i % 10);
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
  
  final file = File('assets/data/mega_aksam_batch_1.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} akşam yemeği');
  print('📁 Dosya: ${file.path}');
}
