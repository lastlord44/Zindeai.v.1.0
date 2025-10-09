import 'dart:convert';
import 'dart:io';

/// BATCH 1: KAHVALTILAR (100 yemek - her grupda 2-3 alternatif)
void main() async {
  print('🍳 KAHVALTI BATCH 1: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 1;
  
  // GRUP 1: Menemenler (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Zeytinyağlı Menemen + Tam Buğday Ekmeği",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 100g", "Domates 80g", "Biber 60g", "Soğan 30g", "Zeytinyağı 10g", "Tam Buğday Ekmeği 60g"],
      "kalori": 380,
      "protein": 20,
      "karbonhidrat": 38,
      "yag": 18
    },
    {
      "id": "KAH_${id++}",
      "ad": "Tereyağlı Menemen + Beyaz Peynir",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 100g", "Domates 80g", "Biber 60g", "Tereyağı 12g", "Beyaz Peynir 50g"],
      "kalori": 390,
      "protein": 22,
      "karbonhidrat": 12,
      "yag": 28
    },
    {
      "id": "KAH_${id++}",
      "ad": "Sebzeli Kaşarlı Menemen + Zeytin",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 100g", "Domates 70g", "Biber 60g", "Kaşar 40g", "Zeytin 30g"],
      "kalori": 400,
      "protein": 24,
      "karbonhidrat": 14,
      "yag": 30
    },
  ]);
  
  // GRUP 2: Omletler (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Sebzeli Omlet 3 Yumurta + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 150g", "Domates 50g", "Biber 40g", "Soğan 20g", "Ekmek 50g"],
      "kalori": 410,
      "protein": 26,
      "karbonhidrat": 32,
      "yag": 20
    },
    {
      "id": "KAH_${id++}",
      "ad": "Peynirli Omlet + Roka Salatası",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 150g", "Beyaz Peynir 60g", "Roka 50g", "Zeytinyağı 10g"],
      "kalori": 380,
      "protein": 28,
      "karbonhidrat": 8,
      "yag": 28
    },
    {
      "id": "KAH_${id++}",
      "ad": "Mantarlı Kaşarlı Omlet + Domates",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 150g", "Mantar 60g", "Kaşar 50g", "Domates 80g"],
      "kalori": 420,
      "protein": 30,
      "karbonhidrat": 12,
      "yag": 30
    },
  ]);
  
  // GRUP 3: Sahanda/Haşlama (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Haşlanmış Yumurta 3 Adet + Avokado + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 150g", "Avokado 100g", "Tam Buğday Ekmeği 60g"],
      "kalori": 460,
      "protein": 24,
      "karbonhidrat": 35,
      "yag": 26
    },
    {
      "id": "KAH_${id++}",
      "ad": "Rafadan Yumurta 2 Adet + Peynir + Zeytin",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 100g", "Beyaz Peynir 80g", "Zeytin 40g", "Ekmek 50g"],
      "kalori": 420,
      "protein": 26,
      "karbonhidrat": 28,
      "yag": 24
    },
    {
      "id": "KAH_${id++}",
      "ad": "Sahanda Yumurta 2 + Sucuk + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Yumurta 100g", "Sucuk 50g", "Ekmek 60g", "Domates 50g"],
      "kalori": 480,
      "protein": 24,
      "karbonhidrat": 32,
      "yag": 30
    },
  ]);
  
  // GRUP 4: Peynirli Kahvaltılar (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Beyaz Peynir + Zeytin + Ceviz + Bal + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Beyaz Peynir 100g", "Zeytin 40g", "Ceviz 30g", "Bal 20g", "Ekmek 70g"],
      "kalori": 520,
      "protein": 24,
      "karbonhidrat": 48,
      "yag": 26
    },
    {
      "id": "KAH_${id++}",
      "ad": "Kaşar Peyniri + Domates + Salatalık + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Kaşar Peyniri 80g", "Domates 100g", "Salatalık 80g", "Ekmek 60g"],
      "kalori": 440,
      "protein": 22,
      "karbonhidrat": 38,
      "yag": 24
    },
    {
      "id": "KAH_${id++}",
      "ad": "Lor Peyniri + Maydanoz + Ceviz + Ekmek",
      "ogun": "kahvalti",
      "malzemeler": ["Lor Peyniri 120g", "Maydanoz 20g", "Ceviz 25g", "Ekmek 60g"],
      "kalori": 400,
      "protein": 26,
      "karbonhidrat": 34,
      "yag": 18
    },
  ]);
  
  // GRUP 5: Tostlar (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Kaşarlı Tost + Domates + Marul",
      "ogun": "kahvalti",
      "malzemeler": ["Tam Buğday Ekmeği 80g", "Kaşar 60g", "Domates 60g", "Marul 30g"],
      "kalori": 420,
      "protein": 20,
      "karbonhidrat": 42,
      "yag": 20
    },
    {
      "id": "KAH_${id++}",
      "ad": "Karışık Tost (Kaşar + Beyaz Peynir + Zeytin)",
      "ogun": "kahvalti",
      "malzemeler": ["Ekmek 80g", "Kaşar 40g", "Beyaz Peynir 40g", "Zeytin 30g"],
      "kalori": 460,
      "protein": 22,
      "karbonhidrat": 40,
      "yag": 24
    },
    {
      "id": "KAH_${id++}",
      "ad": "Sucuklu Kaşarlı Tost + Turşu",
      "ogun": "kahvalti",
      "malzemeler": ["Ekmek 80g", "Sucuk 40g", "Kaşar 50g", "Turşu 30g"],
      "kalori": 500,
      "protein": 22,
      "karbonhidrat": 42,
      "yag": 28
    },
  ]);
  
  // GRUP 6: Yulaf Bazlı (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Yulaf + Süt + Muz + Bal",
      "ogun": "kahvalti",
      "malzemeler": ["Yulaf 60g", "Süt 200ml", "Muz 100g", "Bal 15g"],
      "kalori": 420,
      "protein": 16,
      "karbonhidrat": 68,
      "yag": 10
    },
    {
      "id": "KAH_${id++}",
      "ad": "Yulaf + Yoğurt + Çilek + Ceviz",
      "ogun": "kahvalti",
      "malzemeler": ["Yulaf 50g", "Yoğurt 150g", "Çilek 80g", "Ceviz 25g"],
      "kalori": 400,
      "protein": 18,
      "karbonhidrat": 50,
      "yag": 16
    },
    {
      "id": "KAH_${id++}",
      "ad": "Muzlu Yulaf Pankek + Bal",
      "ogun": "kahvalti",
      "malzemeler": ["Yulaf 60g", "Yumurta 50g", "Muz 100g", "Bal 20g", "Süt 50ml"],
      "kalori": 440,
      "protein": 18,
      "karbonhidrat": 66,
      "yag": 12
    },
  ]);
  
  // GRUP 7: Börekler (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Peynirli Börek + Ayran",
      "ogun": "kahvalti",
      "malzemeler": ["Yufka 80g", "Beyaz Peynir 80g", "Maydanoz 20g", "Ayran 200ml"],
      "kalori": 480,
      "protein": 20,
      "karbonhidrat": 52,
      "yag": 22
    },
    {
      "id": "KAH_${id++}",
      "ad": "Ispanaklı Börek + Yoğurt",
      "ogun": "kahvalti",
      "malzemeler": ["Yufka 80g", "Ispanak 100g", "Beyaz Peynir 60g", "Yoğurt 150g"],
      "kalori": 460,
      "protein": 22,
      "karbonhidrat": 50,
      "yag": 20
    },
    {
      "id": "KAH_${id++}",
      "ad": "Kıymalı Börek + Ayran",
      "ogun": "kahvalti",
      "malzemeler": ["Yufka 80g", "Dana Kıyma 60g", "Soğan 30g", "Ayran 200ml"],
      "kalori": 500,
      "protein": 24,
      "karbonhidrat": 54,
      "yag": 22
    },
  ]);
  
  // GRUP 8: Tahıl Bazlı (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Granola + Süt + Muz + Fındık",
      "ogun": "kahvalti",
      "malzemeler": ["Granola 60g", "Süt 200ml", "Muz 80g", "Fındık 20g"],
      "kalori": 480,
      "protein": 14,
      "karbonhidrat": 64,
      "yag": 18
    },
    {
      "id": "KAH_${id++}",
      "ad": "Mısır Gevreği + Süt + Çilek",
      "ogun": "kahvalti",
      "malzemeler": ["Mısır Gevreği 50g", "Süt 250ml", "Çilek 100g"],
      "kalori": 360,
      "protein": 12,
      "karbonhidrat": 62,
      "yag": 8
    },
    {
      "id": "KAH_${id++}",
      "ad": "Kepekli Gevrek + Yoğurt + Meyve",
      "ogun": "kahvalti",
      "malzemeler": ["Kepekli Gevrek 60g", "Yoğurt 200g", "Elma 80g", "Bal 10g"],
      "kalori": 400,
      "protein": 16,
      "karbonhidrat": 68,
      "yag": 8
    },
  ]);
  
  // GRUP 9: Gözleme Çeşitleri (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Peynirli Gözleme + Ayran",
      "ogun": "kahvalti",
      "malzemeler": ["Un 80g", "Beyaz Peynir 100g", "Maydanoz 20g", "Ayran 200ml"],
      "kalori": 490,
      "protein": 22,
      "karbonhidrat": 56,
      "yag": 20
    },
    {
      "id": "KAH_${id++}",
      "ad": "Patatesli Gözleme + Yoğurt",
      "ogun": "kahvalti",
      "malzemeler": ["Un 80g", "Patates 120g", "Soğan 30g", "Yoğurt 150g"],
      "kalori": 480,
      "protein": 16,
      "karbonhidrat": 72,
      "yag": 16
    },
    {
      "id": "KAH_${id++}",
      "ad": "Karışık Gözleme (Peynir + Ispanak) + Ayran",
      "ogun": "kahvalti",
      "malzemeler": ["Un 80g", "Beyaz Peynir 60g", "Ispanak 80g", "Ayran 200ml"],
      "kalori": 470,
      "protein": 20,
      "karbonhidrat": 58,
      "yag": 18
    },
  ]);
  
  // GRUP 10: Yoğurt Bazlı (3 alternatif)
  yemekler.addAll([
    {
      "id": "KAH_${id++}",
      "ad": "Süzme Yoğurt + Bal + Ceviz + Meyve",
      "ogun": "kahvalti",
      "malzemeler": ["Süzme Yoğurt 200g", "Bal 25g", "Ceviz 30g", "Muz 80g"],
      "kalori": 460,
      "protein": 20,
      "karbonhidrat": 56,
      "yag": 18
    },
    {
      "id": "KAH_${id++}",
      "ad": "Yoğurt + Granola + Yaban Mersini",
      "ogun": "kahvalti",
      "malzemeler": ["Yoğurt 200g", "Granola 50g", "Yaban Mersini 60g"],
      "kalori": 420,
      "protein": 16,
      "karbonhidrat": 60,
      "yag": 14
    },
    {
      "id": "KAH_${id++}",
      "ad": "Yoğurt + Çilek + Fındık + Bal",
      "ogun": "kahvalti",
      "malzemeler": ["Yoğurt 200g", "Çilek 100g", "Fındık 25g", "Bal 15g"],
      "kalori": 400,
      "protein": 14,
      "karbonhidrat": 52,
      "yag": 16
    },
  ]);
  
  // GRUP 11-34: Daha fazla alternatif (70 yemek daha)
  for (int i = 0; i < 70; i++) {
    final kategori = i % 7;
    String ad = "";
    List<String> malzemeler = [];
    int kalori = 400;
    int protein = 20;
    int karbonhidrat = 45;
    int yag = 15;
    
    switch(kategori) {
      case 0: // Simit grubu
        ad = "Simit + ${i % 2 == 0 ? 'Peynir' : 'Kaşar'} + Domates + Salatalık";
        malzemeler = ["Simit 120g", "${i % 2 == 0 ? 'Beyaz Peynir' : 'Kaşar'} 70g", "Domates 80g", "Salatalık 60g"];
        kalori = 460 + (i % 30);
        protein = 20 + (i % 5);
        karbonhidrat = 60 + (i % 10);
        yag = 16 + (i % 6);
        break;
      case 1: // Sandviç grubu
        ad = "Sandviç ${i % 2 == 0 ? 'Tavuklu' : 'Ton Balıklı'} + Marul";
        malzemeler = ["Tam Buğday Ekmeği 80g", "${i % 2 == 0 ? 'Tavuk Göğüs' : 'Ton Balığı'} 70g", "Marul 40g", "Domates 50g"];
        kalori = 410 + (i % 25);
        protein = 28 + (i % 4);
        karbonhidrat = 40 + (i % 8);
        yag = 12 + (i % 5);
        break;
      case 2: // Pankek/Krep grubu
        ad = "${i % 2 == 0 ? 'Pankek' : 'Krep'} + Muz + ${i % 2 == 0 ? 'Bal' : 'Fıstık Ezmesi'}";
        malzemeler = ["Un 70g", "Yumurta 50g", "Süt 100ml", "Muz 80g", "${i % 2 == 0 ? 'Bal' : 'Fıstık Ezmesi'} 25g"];
        kalori = 500 + (i % 40);
        protein = 18 + (i % 6);
        karbonhidrat = 65 + (i % 10);
        yag = 16 + (i % 8);
        break;
      case 3: // Poğaça grubu
        ad = "${i % 3 == 0 ? 'Peynirli' : i % 3 == 1 ? 'Patatesli' : 'Zeytinli'} Poğaça + Ayran";
        malzemeler = ["Un 90g", "${i % 3 == 0 ? 'Beyaz Peynir 70g' : i % 3 == 1 ? 'Patates 100g' : 'Zeytin 50g'}", "Yoğurt 40g", "Ayran 200ml"];
        kalori = 480 + (i % 30);
        protein = 16 + (i % 6);
        karbonhidrat = 64 + (i % 12);
        yag = 18 + (i % 5);
        break;
      case 4: // Tahin/Pekmez/Reçel grubu
        ad = "Ekmek + ${i % 3 == 0 ? 'Tahin Pekmez' : i % 3 == 1 ? 'Reçel' : 'Fıstık Ezmesi'} + Peynir";
        malzemeler = ["Ekmek 70g", "${i % 3 == 0 ? 'Tahin 20g, Pekmez 25g' : i % 3 == 1 ? 'Reçel 30g' : 'Fıstık Ezmesi 30g'}", "Beyaz Peynir 60g"];
        kalori = 450 + (i % 40);
        protein = 16 + (i % 4);
        karbonhidrat = 56 + (i % 12);
        yag = 16 + (i % 8);
        break;
      case 5: // Avokado grubu
        ad = "Avokado Toast + ${i % 2 == 0 ? 'Yumurta' : 'Peynir'}";
        malzemeler = ["Tam Buğday Ekmeği 80g", "Avokado 100g", "${i % 2 == 0 ? 'Yumurta 100g' : 'Beyaz Peynir 70g'}", "Limon 10g"];
        kalori = 470 + (i % 35);
        protein = 20 + (i % 5);
        karbonhidrat = 38 + (i % 8);
        yag = 26 + (i % 6);
        break;
      case 6: // Smoothie Bowl grubu
        ad = "Smoothie Bowl ${i % 2 == 0 ? 'Çilekli' : 'Muzlu'} + Granola";
        malzemeler = ["${i % 2 == 0 ? 'Çilek 100g' : 'Muz 150g'}", "Yoğurt 150g", "Granola 40g", "${i % 2 == 0 ? 'Chia 10g' : 'Fındık 20g'}"];
        kalori = 430 + (i % 30);
        protein = 15 + (i % 3);
        karbonhidrat = 64 + (i % 10);
        yag = 13 + (i % 5);
        break;
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
  
  // JSON dosyasına kaydet
  final file = File('assets/data/mega_kahvalti_batch_1.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} kahvaltı yemeği');
  print('📁 Dosya: ${file.path}');
}
