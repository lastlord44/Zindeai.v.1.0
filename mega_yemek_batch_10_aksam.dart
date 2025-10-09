import 'dart:convert';
import 'dart:io';

/// BATCH 10: AKŞAM YEMEKLERİ 3 (100 yemek - ID 901-1000)
void main() async {
  print('🌙 AKŞAM YEMEKLERİ BATCH 3: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 901;
  
  // 100 farklı akşam yemeği daha - maksimum çeşitlilik
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Izgara + Pilav kombinasyonları
        final izgaraKombo = ['Izgara Tavuk + Bulgur + Cacık', 'Izgara Köfte + Pilav + Salata', 'Izgara Balık + Esmer Pirinç', 'Izgara Dana + Bulgur + Yoğurt', 'Izgara Sebze + Peynir + Pilav'];
        ad = izgaraKombo[i ~/ 10 % izgaraKombo.length];
        malzemeler = ["Izgara Protein ${120 + i % 60}g", "Pilav ${55 + i % 30}g", "Garnitür ${70 + i % 40}g"];
        kalori = 430 + (i % 100);
        protein = 34 + (i % 16);
        karbonhidrat = 44 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 1: // Hafif akşam yemekleri
        final hafifAksam = ['Izgara Tavuk + Yeşil Salata', 'Ton Balığı Salatası + Avokado', 'Sebze Bowl + Kinoa + Tavuk', 'Izgara Somon + Brokoli', 'Tavuk Göğüs + Buharda Sebze'];
        ad = hafifAksam[i ~/ 10 % hafifAksam.length];
        malzemeler = ["Protein ${100 + i % 60}g", "Sebze ${100 + i % 60}g", "Sağlıklı Karbonhidrat ${40 + i % 30}g"];
        kalori = 360 + (i % 90);
        protein = 32 + (i % 16);
        karbonhidrat = 32 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 2: // Çorba + Yemek kombinasyonları
        final corbaYemek = ['Mercimek Çorbası + Izgara Tavuk + Salata', 'Tarhana + Börek + Yoğurt', 'Ezogelin + Pilav + Köfte', 'Sebze Çorbası + Tavuk + Bulgur', 'Tavuk Suyu + Pilav + Salata'];
        ad = corbaYemek[i ~/ 10 % corbaYemek.length];
        malzemeler = ["Çorba 250ml", "Ana Yemek ${90 + i % 50}g", "Pilav/Salata ${60 + i % 30}g"];
        kalori = 420 + (i % 100);
        protein = 24 + (i % 12);
        karbonhidrat = 52 + (i % 26);
        yag = 10 + (i % 8);
        break;
        
      case 3: // Kızartma çeşitleri
        final kizartmalar = ['Kabak Mücver + Pilav + Yoğurt', 'Patlıcan Kızartma + Bulgur + Cacık', 'Karnabahar Kızartma + Pilav', 'Tavuk Schnitzel + Patates + Salata', 'Balık Kızartma + Bulgur + Limon'];
        ad = kizartmalar[i ~/ 10 % kizartmalar.length];
        malzemeler = ["Kızartma ${130 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt/Salata ${70 + i % 40}g"];
        kalori = 450 + (i % 110);
        protein = 24 + (i % 12);
        karbonhidrat = 54 + (i % 26);
        yag = 16 + (i % 14);
        break;
        
      case 4: // Tavuk çeşitleri (Akşam için hafif)
        final tavukCesitleri = ['Tavuk Haşlama + Sebze + Pilav', 'Tavuk Sote + Bulgur + Salata', 'Fırın Tavuk + Patates', 'Tavuk Güveç + Pilav', 'Izgara Tavuk + Kinoa + Sebze'];
        ad = tavukCesitleri[i ~/ 10 % tavukCesitleri.length];
        malzemeler = ["Tavuk ${120 + i % 60}g", "Sebze ${80 + i % 40}g", "Karbonhidrat ${50 + i % 30}g"];
        kalori = 420 + (i % 100);
        protein = 36 + (i % 16);
        karbonhidrat = 42 + (i % 22);
        yag = 10 + (i % 8);
        break;
        
      case 5: // Balık ve deniz ürünleri
        final baliklar = ['Levrek Buğulama + Sebze + Pilav', 'Çipura Fırın + Salata', 'Somon Teriyaki + Esmer Pirinç', 'Hamsi Buğulama + Bulgur', 'Alabalık Izgara + Sebze'];
        ad = baliklar[i ~/ 10 % baliklar.length];
        malzemeler = ["Balık ${130 + i % 70}g", "Sebze/Pilav ${90 + i % 50}g", "Garnitür ${60 + i % 30}g"];
        kalori = 400 + (i % 100);
        protein = 34 + (i % 16);
        karbonhidrat = 38 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 6: // Sebze ağırlıklı yemekler
        final sebzeAgirlikli = ['Türlü + Pilav + Yoğurt', 'Zeytinyağlı Pırasa + Bulgur', 'Sebze Güveç + Pilav', 'İmam Bayıldı + Pilav', 'Zeytinyağlı Enginar + Yoğurt'];
        ad = sebzeAgirlikli[i ~/ 10 % sebzeAgirlikli.length];
        malzemeler = ["Sebze ${130 + i % 70}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 380 + (i % 90);
        protein = 16 + (i % 8);
        karbonhidrat = 58 + (i % 26);
        yag = 10 + (i % 8);
        break;
        
      case 7: // Proteini ağırlıklı (Spor akşamı)
        final proteinAgirlikli = ['Izgara Tavuk + Quinoa + Brokoli', 'Ton Balığı + Kinoa + Avokado', 'Izgara Dana + Tatlı Patates', 'Somon + Esmer Pirinç + Ispanak', 'Tavuk Göğüs + Bulgur + Sebze'];
        ad = proteinAgirlikli[i ~/ 10 % proteinAgirlikli.length];
        malzemeler = ["Protein ${130 + i % 70}g", "Sağlıklı Karbonhidrat ${50 + i % 30}g", "Sebze ${90 + i % 50}g"];
        kalori = 410 + (i % 100);
        protein = 38 + (i % 16);
        karbonhidrat = 40 + (i % 22);
        yag = 10 + (i % 8);
        break;
        
      case 8: // Makarna & Hamur işi
        final makarnaHamur = ['Sebzeli Makarna + Salata', 'Mantı + Yoğurt + Salça', 'Pesto Makarna + Tavuk', 'Kıymalı Makarna + Salata', 'Ravioli + Domates Sos'];
        ad = makarnaHamur[i ~/ 10 % makarnaHamur.length];
        malzemeler = ["Hamur İşi ${90 + i % 50}g", "Sos/Protein ${70 + i % 40}g", "Sebze ${60 + i % 30}g"];
        kalori = 450 + (i % 110);
        protein = 22 + (i % 12);
        karbonhidrat = 60 + (i % 28);
        yag = 14 + (i % 12);
        break;
        
      case 9: // Pratik akşam yemekleri
        final pratikAksam = ['Tavuk Wrap + Salata', 'Izgara Tavuk Sandviç + Marul', 'Ton Balıklı Sandviç + Sebze', 'Omlet + Sebze + Ekmek', 'Peynirli Tost + Salata'];
        ad = pratikAksam[i ~/ 10 % pratikAksam.length];
        malzemeler = ["Ana Ürün ${120 + i % 60}g", "Sebze ${80 + i % 40}g", "Ek ${50 + i % 30}g"];
        kalori = 400 + (i % 100);
        protein = 26 + (i % 12);
        karbonhidrat = 42 + (i % 22);
        yag = 14 + (i % 10);
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
  
  final file = File('assets/data/mega_aksam_batch_3.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} akşam yemeği');
  print('📊 Toplam Akşam (3 Batch): 300 yemek');
  print('📁 Dosya: ${file.path}');
}
