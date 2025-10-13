import 'dart:convert';
import 'dart:io';

/// BATCH 5: ÖĞLE YEMEKLERİ 2 (100 yemek daha - ID 401-500)
void main() async {
  print('🍗 ÖĞLE YEMEKLERİ BATCH 2: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 401;
  
  // 100 farklı öğle yemeği daha
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Kebaplar
        final kebaplar = [
          'Adana Kebap + Bulgur Pilavı + Közlenmiş Biber',
          'Urfa Kebap + Lavash + Soğan Salatası',
          'Şiş Kebap + Pilav + Salata',
          'Tavuk Şiş + Bulgur + Cacık',
          'Beyti Kebap + Ayran + Ezme',
          'İskender Kebap + Yoğurt + Salça',
          'Patlıcan Kebap + Pilav + Turşu',
          'Ali Nazik + Bulgur + Salata',
          'Testi Kebabı + Pilav',
          'Kuzu Şiş + Bulgur + Közlenmiş Sebze'
        ];
        ad = kebaplar[i ~/ 10 % kebaplar.length];
        malzemeler = ["Et/Tavuk ${120 + i % 80}g", "Pilav ${60 + i % 30}g", "Sebze/Sos ${70 + i % 40}g"];
        kalori = 500 + (i % 120);
        protein = 35 + (i % 15);
        karbonhidrat = 50 + (i % 25);
        yag = 20 + (i % 12);
        break;
        
      case 1: // Sulu yemekler
        final suluYemekler = [
          'Hünkar Beğendi + Kuzu + Pilav',
          'Etli Bamya + Bulgur Pilavı',
          'Etli Taze Fasulye + Pilav + Yoğurt',
          'Etli Türlü + Bulgur + Cacık',
          'Etli Kabak + Pilav + Turşu',
          'Etli Pırasa + Bulgur + Yoğurt',
          'Etli Kereviz + Pilav + Salata',
          'Etli Lahana Sarma + Yoğurt',
          'Etli Yaprak Sarma + Pilav',
          'Etli Enginar + Bulgur + Limon'
        ];
        ad = suluYemekler[i ~/ 10 % suluYemekler.length];
        malzemeler = ["Sebze + Et ${150 + i % 70}g", "Pilav ${50 + i % 30}g", "Ek ${60 + i % 30}g"];
        kalori = 460 + (i % 100);
        protein = 28 + (i % 12);
        karbonhidrat = 52 + (i % 20);
        yag = 16 + (i % 10);
        break;
        
      case 2: // Deniz ürünleri
        final denizUrunleri = [
          'Karides Güveç + Pilav + Salata',
          'Kalamar Tava + Bulgur + Limon',
          'Ahtapot Salatası + Ekmek',
          'Midye Tava + Patates + Turşu',
          'Palamut Izgara + Pilav + Roka',
          'Levrek Buğulama + Sebze + Pilav',
          'Çipura Fırın + Patates + Salata',
          'Barbunya Balığı Tava + Bulgur',
          'Hamsi Pilavı + Mısır Ekmeği',
          'Balık Köfte + Pilav + Salata'
        ];
        ad = denizUrunleri[i ~/ 10 % denizUrunleri.length];
        malzemeler = ["Deniz Ürünü ${130 + i % 70}g", "Karbonhidrat ${50 + i % 30}g", "Sebze ${70 + i % 40}g"];
        kalori = 430 + (i % 110);
        protein = 32 + (i % 15);
        karbonhidrat = 45 + (i % 20);
        yag = 14 + (i % 12);
        break;
        
      case 3: // Tavuk çeşitleri
        final tavukCesitleri = [
          'Tavuk Kapama + Bulgur + Yoğurt',
          'Tavuk Haşlama + Sebze + Pilav',
          'Tavuklu Bezelye + Pilav',
          'Tavuklu Bamya + Bulgur',
          'Kremalı Mantarlı Tavuk + Pirinç',
          'Tavuk Sote + Sebze + Bulgur',
          'Tavuk Tandır + Patates + Salata',
          'Tavuklu Makarna + Beyaz Sos',
          'Tavuk Güveç + Esmer Pirinç',
          'Tavuk Rosto + Sebze Garnitür'
        ];
        ad = tavukCesitleri[i ~/ 10 % tavukCesitleri.length];
        malzemeler = ["Tavuk ${130 + i % 70}g", "Pilav ${55 + i % 25}g", "Sebze ${65 + i % 35}g"];
        kalori = 445 + (i % 105);
        protein = 36 + (i % 14);
        karbonhidrat = 48 + (i % 22);
        yag = 12 + (i % 10);
        break;
        
      case 4: // Kıymalı yemekler
        final kiymaliYemekler = [
          'Kıymalı Biber Dolması + Yoğurt',
          'Kıymalı Patlıcan Karnıyarık + Pilav',
          'Kıymalı Kabak Dolması + Yoğurt',
          'İçli Köfte + Bulgur + Salata',
          'Kıymalı Ispanak + Pilav + Yoğurt',
          'Kıymalı Patates + Bulgur',
          'Kıymalı Makarna + Salata',
          'Etli Ekmek + Ayran + Salata',
          'Kıymalı Börek + Yoğurt',
          'Tepsi Köfte + Pilav + Turşu'
        ];
        ad = kiymaliYemekler[i ~/ 10 % kiymaliYemekler.length];
        malzemeler = ["Kıyma + Sebze ${120 + i % 60}g", "Pilav ${50 + i % 30}g", "Yoğurt ${80 + i % 40}g"];
        kalori = 470 + (i % 110);
        protein = 30 + (i % 14);
        karbonhidrat = 50 + (i % 25);
        yag = 18 + (i % 12);
        break;
        
      case 5: // Dünya mutfakları
        final dunyaMutfagi = [
          'Köri Soslu Tavuk + Pilav',
          'Sweet & Sour Tavuk + Pirinç',
          'Pad Thai + Sebze',
          'Teriyaki Tavuk + Sebze + Pirinç',
          'Tavuk Fajita + Tortilla + Salsa',
          'Chili Con Carne + Pirinç',
          'Ramen + Tavuk + Sebze',
          'Biryani + Tavuk + Yoğurt',
          'Nasi Goreng + Yumurta',
          'Tom Yum + Karides + Pirinç'
        ];
        ad = dunyaMutfagi[i ~/ 10 % dunyaMutfagi.length];
        malzemeler = ["Protein ${110 + i % 60}g", "Pirinç/Makarna ${60 + i % 30}g", "Sos/Sebze ${70 + i % 40}g"];
        kalori = 490 + (i % 120);
        protein = 28 + (i % 14);
        karbonhidrat = 58 + (i % 25);
        yag = 16 + (i % 12);
        break;
        
      case 6: // Sağlıklı light yemekler
        final lightYemekler = [
          'Izgara Tavuk + Kinoa + Buharda Sebze',
          'Ton Salatası + Az Yağlı Peynir + Ekmek',
          'Izgara Somon + Esmer Pirinç + Brokoli',
          'Tavuk Göğüs + Tatlı Patates + Salata',
          'Izgara Sebze + Lor Peyniri + Bulgur',
          'Mercimek Çorbası + Izgara Tavuk',
          'Yeşil Salata + Ton Balığı + Yulaf Ekmeği',
          'Sebze Güveç + Az Yağlı Et + Bulgur',
          'Tavuk Salatası + Yoğurt Sos',
          'Izgara Balık + Sebze + Kinoa'
        ];
        ad = lightYemekler[i ~/ 10 % lightYemekler.length];
        malzemeler = ["Protein ${100 + i % 50}g", "Tam Tahıl ${50 + i % 25}g", "Sebze ${100 + i % 50}g"];
        kalori = 380 + (i % 90);
        protein = 32 + (i % 14);
        karbonhidrat = 42 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 7: // Özel diyet yemekleri
        final ozelDiyetYemekleri = [
          'Keto: Izgara Et + Avokado + Yeşil Salata',
          'Vegan: Nohut Güveç + Bulgur',
          'Paleo: Tavuk + Tatlı Patates + Sebze',
          'Glutensiz: Pirinç Makarna + Et Sos',
          'Akdeniz: Zeytinyağlı Sebze + Balık',
          'Protein Ağırlıklı: Tavuk + Yumurta + Kinoa',
          'Düşük Karbonhidrat: Et + Sebze + Salata',
          'Yüksek Protein: Biftek + Mercimek',
          'Vejetaryen: Sebze Güveç + Peynir + Bulgur',
          'Pescatarian: Somon + Sebze + Pirinç'
        ];
        ad = ozelDiyetYemekleri[i ~/ 10 % ozelDiyetYemekleri.length];
        malzemeler = ["Protein ${110 + i % 60}g", "Karbonhidrat ${45 + i % 30}g", "Sebze ${90 + i % 50}g"];
        kalori = 420 + (i % 110);
        protein = 30 + (i % 15);
        karbonhidrat = 40 + (i % 25);
        yag = 14 + (i % 12);
        break;
        
      case 8: // Pilav & Bulgur çeşitleri
        final pilavCesitleri = [
          'Etli Pilav + Haydari + Turşu',
          'Tavuklu Bulgur Pilavı + Cacık',
          'Sebzeli Pilav + Yoğurt + Salata',
          'İç Pilav + Tavuk Haşlama',
          'Nohutlu Pilav + Köfte + Turşu',
          'Şehriyeli Pilav + Tavuk + Salata',
          'Domatesli Bulgur + Et + Yoğurt',
          'Mercimekli Bulgur + Cacık + Turşu',
          'Mantarlı Pilav + Tavuk',
          'Arpa Şehriyeli Pilav + Köfte'
        ];
        ad = pilavCesitleri[i ~/ 10 % pilavCesitleri.length];
        malzemeler = ["Pilav ${70 + i % 30}g", "Et/Tavuk ${90 + i % 50}g", "Yoğurt/Salata ${70 + i % 30}g"];
        kalori = 455 + (i % 105);
        protein = 26 + (i % 12);
        karbonhidrat = 60 + (i % 25);
        yag = 12 + (i % 10);
        break;
        
      case 9: // Yerel yöresel yemekler
        final yoreselYemekler = [
          'Mantı (Kayseri) + Yoğurt + Salça',
          'Çiğ Köfte (Urfa) + Ayran + Yeşillik',
          'Tantuni (Mersin) + Ayran + Turşu',
          'Kokoreç + Ekmek + Turşu',
          'Mumbar Dolması + Pilav + Yoğurt',
          'Keşkek + Ayran',
          'Kuru Fasulye Pilaki (İstanbul) + Pilav',
          'Tirit + Et + Yoğurt',
          'Arabaşı Çorbası + Ekmek',
          'Kavurma + Yumurta + Ekmek'
        ];
        ad = yoreselYemekler[i ~/ 10 % yoreselYemekler.length];
        malzemeler = ["Ana Malzeme ${120 + i % 70}g", "Ekmek/Pilav ${60 + i % 30}g", "Ek ${60 + i % 30}g"];
        kalori = 480 + (i % 120);
        protein = 28 + (i % 14);
        karbonhidrat = 54 + (i % 26);
        yag = 18 + (i % 14);
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
  
  final file = File('assets/data/mega_ogle_batch_2.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} öğle yemeği');
  print('📊 Toplam Öğle (2 Batch): 200 yemek');
  print('📁 Dosya: ${file.path}');
}
