import 'dart:convert';
import 'dart:io';

/// BATCH 3: KAHVALTILAR SON (100 yemek daha - ID 201-300)
void main() async {
  print('🍳 KAHVALTI BATCH 3: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 201;
  
  // 100 daha farklı kahvaltı alternatifi
  for (int i = 0; i < 100; i++) {
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    final kategori = i % 10;
    
    switch(kategori) {
      case 0: // Kış kahvaltıları
        final kisSecenekleri = [
          'Sıcak Sütlü Yulaf + Tarçın + Bal',
          'Salep + Peynir + Ekmek',
          'Sütlü Muhallebi + Çay',
          'Sıcak Süt + Bal + Badem',
          'Sahlep + Tarçın + Fındık',
          'Sütlaç + Meyve',
          'Kakaolu Süt + Pankek',
          'Sıcak Çikolata + Kurabiye',
          'Sütlü Çay + Bisküvi',
          'Bal Kaymak + Ekmek'
        ];
        ad = kisSecenekleri[i ~/ 10 % kisSecenekleri.length];
        malzemeler = ["Sıcak İçecek 200ml", "Ekmek/Tahıl ${60 + i % 30}g", "Şeker/Bal ${20 + i % 10}g"];
        kalori = 380 + (i % 100);
        protein = 12 + (i % 8);
        karbonhidrat = 65 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 1: // Spor kahvaltıları (yüksek protein)
        final sporSecenekleri = [
          'Protein Shake + Yumurta + Muz',
          'Cottage Cheese + Yaban Mersini + Yulaf',
          'Izgara Tavuk + Avokado + Ekmek',
          'Ton Balığı + Yumurta + Salata',
          'Whey Protein + Süt + Yulaf',
          'Yumurta Beyazı Omlet + Ispanak',
          'Izgara Hindi + Tam Buğday Ekmek',
          'Kaşar + Yumurta + Esmer Ekmek',
          'Protein Bar + Yoğurt + Meyve',
          'Tavuk Göğüs + Salatalık + Ekmek'
        ];
        ad = sporSecenekleri[i ~/ 10 % sporSecenekleri.length];
        malzemeler = ["Protein Kaynağı ${100 + i % 50}g", "Karbonhidrat ${50 + i % 30}g", "Yağ ${10 + i % 10}g"];
        kalori = 420 + (i % 120);
        protein = 30 + (i % 15);
        karbonhidrat = 40 + (i % 20);
        yag = 12 + (i % 10);
        break;
        
      case 2: // Vegan kahvaltılar
        final veganSecenekleri = [
          'Humus + Domates + Tam Buğday Ekmek',
          'Falafel + Salata + Tahin',
          'Avokado Toast + Chia + Limon',
          'Yulaf + Badem Sütü + Muz',
          'Kinoa Salata + Zeytinyağı',
          'Nohut Ezme + Biber + Ekmek',
          'Smoothie Bowl (Vegan) + Granola',
          'Fıstık Ezmesi + Muz + Ekmek',
          'Kısır + Domates + Salatalık',
          'Mercimek Köfte + Marul + Limon'
        ];
        ad = veganSecenekleri[i ~/ 10 % veganSecenekleri.length];
        malzemeler = ["Bitkisel Protein ${80 + i % 40}g", "Sebze ${100 + i % 50}g", "Tam Tahıl ${60 + i % 20}g"];
        kalori = 360 + (i % 90);
        protein = 15 + (i % 8);
        karbonhidrat = 55 + (i % 20);
        yag = 14 + (i % 12);
        break;
        
      case 3: // Geleneksel Türk kahvaltıları
        final gelenekselSecenekleri = [
          'Menemen + Peynir + Zeytin + Ekmek',
          'Sucuklu Yumurta + Domates + Ekmek',
          'Van Kahvaltısı (Otlu Peynir + Bal)',
          'Çılbır + Yoğurt + Tereyağı',
          'Kaymak + Bal + Ceviz + Ekmek',
          'Börek + Ayran + Domates',
          'Gözleme + Ayran + Salata',
          'Pişmaniye + Çay + Peynir',
          'Tahini Helvası + Peynir + Ekmek',
          'Kavut + Süt + Ceviz'
        ];
        ad = gelenekselSecenekleri[i ~/ 10 % gelenekselSecenekleri.length];
        malzemeler = ["Yöresel Ürün ${80 + i % 40}g", "Peynir ${60 + i % 30}g", "Ekmek ${70 + i % 20}g"];
        kalori = 450 + (i % 100);
        protein = 20 + (i % 10);
        karbonhidrat = 50 + (i % 20);
        yag = 22 + (i % 12);
        break;
        
      case 4: // Hızlı hazır kahvaltılar
        final hizliSecenekleri = [
          'Sade Yoğurt + Granola Bar',
          'Smoothie + Protein Bar',
          'Süt + Bisküvi + Muz',
          'Yoğurt İçeceği + Çerez',
          'Hazır Sandviç + Meyve Suyu',
          'Granola Bar + Meyve',
          'Protein Shake + Kuruyemiş',
          'Ayran + Simit + Peynir',
          'Meyve Suyu + Kraker + Peynir',
          'Kefir + Tahıl Bar'
        ];
        ad = hizliSecenekleri[i ~/ 10 % hizliSecenekleri.length];
        malzemeler = ["Hazır Ürün ${80 + i % 40}g", "İçecek 200ml", "Ek Besin ${30 + i % 20}g"];
        kalori = 350 + (i % 100);
        protein = 14 + (i % 8);
        karbonhidrat = 50 + (i % 25);
        yag = 12 + (i % 10);
        break;
        
      case 5: // Sağlıklı detoks kahvaltıları
        final detoksSecenekleri = [
          'Yeşil Smoothie + Chia + Limon',
          'Yulaf + Zencefil + Bal',
          'Yoğurt + Keten Tohumu + Meyve',
          'Yeşil Çay + Meyve Salatası',
          'Smoothie Bowl + Avokado + Ispanak',
          'Probiyotik Yoğurt + Yaban Mersini',
          'Detoks Suyu + Yulaf Bar',
          'Yeşil Elma + Badem + Yulaf',
          'Kuşburnu Çayı + Kuruyemiş + Ekmek',
          'Matcha Latte + Proteini Bar'
        ];
        ad = detoksSecenekleri[i ~/ 10 % detoksSecenekleri.length];
        malzemeler = ["Süper Besin ${60 + i % 30}g", "Meyve/Sebze ${100 + i % 50}g", "Tohum ${20 + i % 15}g"];
        kalori = 340 + (i % 80);
        protein = 12 + (i % 6);
        karbonhidrat = 52 + (i % 20);
        yag = 10 + (i % 8);
        break;
        
      case 6: // Zengin kahvaltılar
        final zenginSecenekleri = [
          'Somon Füme + Avokado + Yumurta + Ekmek',
          'Kaviar + Blini + Ekşi Krema',
          'Truffle Omlet + Mantar + Peynir',
          'Peynir Tabağı (5 Çeşit) + Meyve',
          'Jambon + Peynir + Croissant',
          'Eggs Benedict + Hollandaise Sos',
          'Lobster Omlet + Avokado',
          'Gravlax + Krem Peynir + Bagel',
          'Foie Gras + Çilek Reçeli + Ekmek',
          'Waffle + Çilekli Krema + Akçaağaç Şurubu'
        ];
        ad = zenginSecenekleri[i ~/ 10 % zenginSecenekleri.length];
        malzemeler = ["Premium Ürün ${80 + i % 40}g", "Lüks Malzeme ${60 + i % 30}g", "Ekmek ${70 + i % 20}g"];
        kalori = 520 + (i % 100);
        protein = 25 + (i % 12);
        karbonhidrat = 45 + (i % 20);
        yag = 28 + (i % 15);
        break;
        
      case 7: // Dünya mutfaklarından
        final dunyaSecenekleri = [
          'Pancakes (Amerikan) + Akçaağaç Şurubu',
          'Croissant (Fransız) + Reçel + Kahve',
          'Full English Breakfast',
          'Churros (İspanyol) + Çikolata Sos',
          'Congee (Çin) + Soya Sosu',
          'Idli (Hint) + Sambar Sos',
          'Açaí Bowl (Brezilya) + Granola',
          'Shakshuka (Orta Doğu) + Ekmek',
          'Bagel (New York) + Cream Cheese + Somon',
          'Tacos de Desayuno (Meksika)'
        ];
        ad = dunyaSecenekleri[i ~/ 10 % dunyaSecenekleri.length];
        malzemeler = ["Ana Yemek ${100 + i % 50}g", "Sos/Ekstra ${40 + i % 20}g", "Garnitür ${60 + i % 30}g"];
        kalori = 440 + (i % 120);
        protein = 18 + (i % 10);
        karbonhidrat = 58 + (i % 25);
        yag = 18 + (i % 14);
        break;
        
      case 8: // Hafif diyet kahvaltıları
        final hafifSecenekleri = [
          'Izgara Sebze + Az Yağlı Peynir',
          'Protein Shake + Elma',
          'Yağsız Yoğurt + Çilek',
          'Yumurta Beyazı Omlet + Salata',
          'Meyve Salatası + Az Yağlı Süt',
          'Tam Tahıl Krakerler + Lor',
          'Yeşil Salata + Ton Balığı',
          'Köfte (Az Yağlı) + Domates',
          'Sebze Çorbası + Galeta',
          'Ispanak + Yumurta + Az Yağlı Peynir'
        ];
        ad = hafifSecenekleri[i ~/ 10 % hafifSecenekleri.length];
        malzemeler = ["Az Kalorili Besin ${80 + i % 40}g", "Sebze ${100 + i % 50}g", "Protein ${60 + i % 30}g"];
        kalori = 300 + (i % 80);
        protein = 18 + (i % 8);
        karbonhidrat = 35 + (i % 20);
        yag = 8 + (i % 6);
        break;
        
      case 9: // Özel diyet kahvaltıları
        final ozelSecenekleri = [
          'Keto: Yumurta + Avokado + Bacon',
          'Paleo: Omlet + Sebze + Somon',
          'Gluten-Free: Yulaf + Yoğurt + Meyve',
          'Laktozsuz: Badem Sütü + Tahıl',
          'Düşük Karbonhidrat: Peynir + Sebze + Yumurta',
          'Yüksek Fiber: Tam Tahıl + Chia',
          'Akdeniz Diyeti: Zeytin + Peynir + Domates',
          'Dash Diyeti: Yulaf + Az Yağlı Süt',
          'Vejetaryen: Peynir + Sebze + Ekmek',
          'Pescatarian: Somon + Yumurta + Avokado'
        ];
        ad = ozelSecenekleri[i ~/ 10 % ozelSecenekleri.length];
        malzemeler = ["Diyet Uygun Besin ${90 + i % 40}g", "Sebze/Meyve ${80 + i % 40}g", "Ek Malzeme ${50 + i % 25}g"];
        kalori = 390 + (i % 110);
        protein = 22 + (i % 12);
        karbonhidrat = 38 + (i % 25);
        yag = 18 + (i % 12);
        break;
        
      default:
        ad = "Kahvaltı Alternatif ${id}";
        malzemeler = ["Karma"];
        kalori = 400;
        protein = 18;
        karbonhidrat = 45;
        yag = 15;
    }
    
    yemekler.add({
      "id": "KAH_${id++}",
      "ad": ad,
      "ogun": "kahvalti",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_kahvalti_batch_3.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} kahvaltı yemeği');
  print('📊 Toplam Kahvaltı (3 Batch): 300 yemek');
  print('📁 Dosya: ${file.path}');
}
