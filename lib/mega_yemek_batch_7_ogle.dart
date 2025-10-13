import 'dart:convert';
import 'dart:io';

/// BATCH 7: ÖĞLE YEMEKLERİ 4 SON (100 yemek - ID 601-700)
void main() async {
  print('🍗 ÖĞLE YEMEKLERİ BATCH 4 (SON): 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 601;
  
  // 100 farklı öğle yemeği daha - son batch
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    // Çeşitlilik için 10 farklı kategori
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Salata + Protein kombinasyonları
        final salataKombolar = ['Caesar Salata + Izgara Tavuk', 'Ton Balıklı Salata + Ekmek', 'Akdeniz Salatası + Peynir', 'Tavuklu Bulgur Salatası', 'Kinoa Salata + Avokado + Yumurta'];
        ad = salataKombolar[i ~/ 10 % salataKombolar.length];
        malzemeler = ["Sebze ${100 + i % 60}g", "Protein ${80 + i % 50}g", "Sos ${30 + i % 20}g"];
        kalori = 380 + (i % 100);
        protein = 28 + (i % 14);
        karbonhidrat = 38 + (i % 22);
        yag = 14 + (i % 10);
        break;
        
      case 1: // Tencere yemekleri
        final tencereYemekleri = ['Etli Kuru Fasulye + Pilav', 'Nohutlu Pilav + Tavuk', 'Sebzeli Et + Bulgur', 'Bamya + Et + Pilav', 'Taze Fasulye + Tavuk + Pilav'];
        ad = tencereYemekleri[i ~/ 10 % tencereYemekleri.length];
        malzemeler = ["Ana Yemek ${140 + i % 70}g", "Pilav ${60 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 460 + (i % 110);
        protein = 28 + (i % 12);
        karbonhidrat = 58 + (i % 26);
        yag = 14 + (i % 10);
        break;
        
      case 2: // Protein bowl kombinasyonları
        final proteinBowls = ['Tavuk Bowl + Kinoa + Sebze', 'Somon Bowl + Esmer Pirinç + Avokado', 'Köfte Bowl + Bulgur + Salata', 'Ton Balığı Bowl + Kinoa', 'Et Bowl + Tatlı Patates'];
        ad = proteinBowls[i ~/ 10 % proteinBowls.length];
        malzemeler = ["Protein ${110 + i % 60}g", "Tahıl ${60 + i % 30}g", "Sebze ${90 + i % 50}g"];
        kalori = 440 + (i % 110);
        protein = 32 + (i % 16);
        karbonhidrat = 48 + (i % 24);
        yag = 12 + (i % 10);
        break;
        
      case 3: // Karides & Deniz ürünleri çeşitleri
        final denizsUrunleriEkstra = ['Karides Tava + Pilav', 'Kalamar Izgara + Bulgur', 'Midye Pilaki + Ekmek', 'Ahtapot Izgara + Salata', 'Karides Güveç + Pilav'];
        ad = denizsUrunleriEkstra[i ~/ 10 % denizsUrunleriEkstra.length];
        malzemeler = ["Deniz Ürünü ${120 + i % 70}g", "Karbonhidrat ${50 + i % 30}g", "Sebze ${70 + i % 40}g"];
        kalori = 420 + (i % 100);
        protein = 30 + (i % 14);
        karbonhidrat = 44 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 4: // Özel soslu yemekler
        final sosluYemekler = ['Tavuk Tikka Masala + Pilav', 'Tavuk Teriyaki + Sebze + Pirinç', 'Beef Stroganoff + Pilav', 'Tavuk Marsala + Makarna', 'Tavuk Paprikash + Bulgur'];
        ad = sosluYemekler[i ~/ 10 % sosluYemekler.length];
        malzemeler = ["Et/Tavuk ${120 + i % 60}g", "Sos ${60 + i % 30}g", "Pilav ${60 + i % 30}g"];
        kalori = 480 + (i % 120);
        protein = 30 + (i % 14);
        karbonhidrat = 52 + (i % 26);
        yag = 16 + (i % 12);
        break;
        
      case 5: // Kızartma + Pilav kombinasyonları
        final kizartmaKombolar = ['Patlıcan Kızartma + Pilav + Yoğurt', 'Kabak Mücver + Pilav + Cacık', 'Balık Kızartma + Patates + Salata', 'Tavuk Schnitzel + Bulgur', 'Karnabahar Kızartma + Pilav'];
        ad = kizartmaKombolar[i ~/ 10 % kizartmaKombolar.length];
        malzemeler = ["Kızartma ${130 + i % 70}g", "Pilav ${55 + i % 30}g", "Garnitür ${70 + i % 40}g"];
        kalori = 460 + (i % 110);
        protein = 24 + (i % 12);
        karbonhidrat = 54 + (i % 26);
        yag = 18 + (i % 14);
        break;
        
      case 6: // Izgara + Sebze kombinasyonları
        final izgaraSebzeKombo = ['Izgara Tavuk + Buharda Sebze + Kinoa', 'Izgara Somon + Brokoli + Pirinç', 'Izgara Köfte + Közlenmiş Sebze + Bulgur', 'Izgara Et + Mantar + Pilav', 'Izgara Balık + Kabak + Pirinç'];
        ad = izgaraSebzeKombo[i ~/ 10 % izgaraSebzeKombo.length];
        malzemeler = ["Izgara Protein ${120 + i % 70}g", "Sebze ${100 + i % 50}g", "Tahıl ${50 + i % 30}g"];
        kalori = 420 + (i % 100);
        protein = 34 + (i % 16);
        karbonhidrat = 42 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 7: // Sandviç & Burger çeşitleri
        final sandvicBurgerler = ['Tavuk Burger + Patates + Salata', 'Köfte Burger + Soğan Halkası', 'Izgara Tavuk Sandviç + Cips', 'Balık Burger + Patates', 'Vejetaryen Burger + Avokado'];
        ad = sandvicBurgerler[i ~/ 10 % sandvicBurgerler.length];
        malzemeler = ["Ana Ürün ${140 + i % 70}g", "Patates ${80 + i % 40}g", "Sebze ${60 + i % 30}g"];
        kalori = 520 + (i % 130);
        protein = 28 + (i % 14);
        karbonhidrat = 60 + (i % 28);
        yag = 22 + (i % 16);
        break;
        
      case 8: // Çorba + Sandviç/Börek kombinasyonları
        final corbaKomboEkstra = ['İşkembe Çorbası + Ekmek', 'Paça Çorbası + Ekmek + Turşu', 'Tavuk Suyu + Börek', 'Sebze Çorbası + Peynirli Tost', 'Mercimek Çorbası + Kıymalı Pide'];
        ad = corbaKomboEkstra[i ~/ 10 % corbaKomboEkstra.length];
        malzemeler = ["Çorba 250ml", "Ekmek/Börek ${100 + i % 60}g", "Ek ${50 + i % 30}g"];
        kalori = 450 + (i % 110);
        protein = 24 + (i % 12);
        karbonhidrat = 56 + (i % 26);
        yag = 14 + (i % 12);
        break;
        
      case 9: // Karışık özel yemekler
        final ozelKarisikYemekler = ['Etli Yaprak Sarma + Yoğurt', 'Mantı + Yoğurt + Salça', 'Içli Köfte + Salata + Ayran', 'Lahmacun + Ayran + Yeşillik', 'Pide Karışık + Ayran'];
        ad = ozelKarisikYemekler[i ~/ 10 % ozelKarisikYemekler.length];
        malzemeler = ["Ana Yemek ${130 + i % 70}g", "Yoğurt/Ayran ${100 + i % 50}g", "Ek ${60 + i % 30}g"];
        kalori = 480 + (i % 120);
        protein = 26 + (i % 12);
        karbonhidrat = 58 + (i % 28);
        yag = 16 + (i % 14);
        break;
        
      default:
        ad = "Öğle Yemeği Özel ${id}";
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
  
  final file = File('assets/data/mega_ogle_batch_4.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} öğle yemeği');
  print('📊 TOPLAM ÖĞLE YEMEKLERİ (4 Batch): 400 yemek 🎉');
  print('📁 Dosya: ${file.path}');
  print('\n🎯 Şimdi akşam yemeklerine geçiyoruz...');
}
