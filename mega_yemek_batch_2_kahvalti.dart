import 'dart:convert';
import 'dart:io';

/// BATCH 2: KAHVALTILAR (100 yemek daha - ID 101-200)
void main() async {
  print('🍳 KAHVALTI BATCH 2: 100 yemek oluşturuluyor...\n');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 101;
  
  // 100 farklı kahvaltı alternatifi
  final kategoriler = [
    {'tip': 'Yumurtalı Ekmek', 'base': ['Yumurta 100g', 'Ekmek 70g']},
    {'tip': 'Peynir Tabağı', 'base': ['Çeşitli Peynir 100g', 'Ekmek 60g']},
    {'tip': 'Süt Ürünlü', 'base': ['Süt 200ml', 'Tahıl 50g']},
    {'tip': 'Sebze Kahvaltı', 'base': ['Sebze 150g', 'Peynir 60g']},
    {'tip': 'Hamur İşi', 'base': ['Hamur 80g', 'İç Malzeme 70g']},
  ];
  
  for (int i = 0; i < 100; i++) {
    final kategori = kategoriler[i % kategoriler.length];
    final varyasyon = i ~/ kategoriler.length;
    
    String ad;
    List<String> malzemeler;
    int kalori;
    int protein;
    int karbonhidrat;
    int yag;
    
    switch(i % 5) {
      case 0: // Yumurtalı
        ad = _yumurtaliIsimler[varyasyon % _yumurtaliIsimler.length];
        malzemeler = ["Yumurta ${100 + i % 50}g", "Ekmek ${60 + i % 20}g", _ekstralar[i % _ekstralar.length]];
        kalori = 380 + (i % 120);
        protein = 20 + (i % 12);
        karbonhidrat = 35 + (i % 15);
        yag = 16 + (i % 12);
        break;
        
      case 1: // Peynirli
        ad = _peynirliIsimler[varyasyon % _peynirliIsimler.length];
        malzemeler = ["${_peynirTipleri[i % _peynirTipleri.length]} ${80 + i % 40}g", "Ekmek ${60 + i % 20}g", _sebzeler[i % _sebzeler.length]];
        kalori = 400 + (i % 100);
        protein = 18 + (i % 10);
        karbonhidrat = 40 + (i % 20);
        yag = 18 + (i % 10);
        break;
        
      case 2: // Süt Ürünlü
        ad = _sutUrunleriIsimler[varyasyon % _sutUrunleriIsimler.length];
        malzemeler = ["${_sutUrunleri[i % _sutUrunleri.length]} ${150 + i % 50}g", "${_tahillar[i % _tahillar.length]} ${50 + i % 20}g", _meyveler[i % _meyveler.length]];
        kalori = 360 + (i % 140);
        protein = 14 + (i % 8);
        karbonhidrat = 55 + (i % 25);
        yag = 10 + (i % 10);
        break;
        
      case 3: // Sebzeli
        ad = _sebzeliIsimler[varyasyon % _sebzeliIsimler.length];
        malzemeler = [_sebzeler[i % _sebzeler.length], "Zeytinyağı 10g", "Ekmek ${60 + i % 20}g"];
        kalori = 340 + (i % 100);
        protein = 16 + (i % 8);
        karbonhidrat = 38 + (i % 18);
        yag = 14 + (i % 10);
        break;
        
      case 4: // Hamur İşi
        ad = _hamurIsiIsimler[varyasyon % _hamurIsiIsimler.length];
        malzemeler = ["Un 80g", "${_icMalzemeler[i % _icMalzemeler.length]}", "Yoğurt ${50 + i % 50}g"];
        kalori = 450 + (i % 100);
        protein = 18 + (i % 10);
        karbonhidrat = 60 + (i % 20);
        yag = 16 + (i % 12);
        break;
        
      default:
        ad = "Kahvaltı Alternatif ${i + 1}";
        malzemeler = ["Karma Kahvaltı"];
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
  
  final file = File('assets/data/mega_kahvalti_batch_2.json');
  await file.create(recursive: true);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(yemekler));
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} kahvaltı yemeği');
  print('📁 Dosya: ${file.path}');
}

final _yumurtaliIsimler = [
  'Çırpılmış Yumurta + Peynir + Ekmek',
  'Sahanda Yumurta + Domates + Ekmek',
  'Haşlanmış Yumurta + Zeytin + Peynir',
  'Yumurtalı Sandviç + Marul',
  'Rafadan Yumurta + Avokado + Ekmek',
  'Menemen + Kaşar + Ekmek',
  'Omlet + Mantar + Domates',
  'Yumurta + Jambon + Ekmek',
  'Yumurta + Sosis + Salata',
  'Çılbır + Yoğurt + Sarımsak',
  'Yumurta + Pastırma + Biber',
  'Yumurta + Sucuk + Domates',
  'Yumurtalı Wrap + Sebze',
  'Yumurta + Lor + Maydanoz',
  'Yumurta + Ispanak + Peynir',
  'Yumurta + Kavurma + Salata',
  'Yumurta + Ton Balığı + Ekmek',
  'Yumurta + Füme Et + Roka',
  'Yumurta + Biberli Ezme + Ekmek',
  'Yumurta + Pesto + Ekmek'
];

final _peynirliIsimler = [
  'Beyaz Peynir + Zeytin + Domates + Ekmek',
  'Kaşar + Salatalık + Ceviz + Ekmek',
  'Lor + Bal + Ceviz + Ekmek',
  'Tulum + Roka + Domates + Ekmek',
  'Çerkez Peyniri + Yeşillik + Ekmek',
  'Labne + Zeytinyağı + Nane + Ekmek',
  'Feta + Zeytin + Biber + Ekmek',
  'Kaşar Tost + Domates + Marul',
  'Peynir Tabağı + Ceviz + Üzüm',
  'Cottage Cheese + Salatalık + Ekmek',
  'Ricotta + Bal + Meyve',
  'Mozzarella + Domates + Fesleğen',
  'Peynir + Kavun + Fındık',
  'Cream Cheese + Somon + Ekmek',
  'Keçi Peyniri + Roka + Ekmek',
  'Peynir + Ceviz + Reçel + Ekmek',
  'Kaşar + Sosis + Ekmek',
  'Peynir + Yeşil Zeytin + Ekmek',
  'Peynirli Pide + Ayran',
  'Peynir + Domates + Biber + Ekmek'
];

final _sutUrunleriIsimler = [
  'Yoğurt + Granola + Meyve',
  'Süt + Yulaf + Muz + Bal',
  'Yoğurt + Chia + Çilek',
  'Süt + Mısır Gevreği + Muz',
  'Yoğurt + Hurma + Ceviz',
  'Süt + Kepek + Elma',
  'Smoothie Bowl + Granola + Meyve',
  'Süzme Yoğurt + Bal + Badem',
  'Yoğurt + Yaban Mersini + Fındık',
  'Süt + Protein Tozu + Muz',
  'Yoğurt + Kivi + Chia',
  'Süt + Karabuğday + Bal',
  'Yoğurt + Kayısı + Ceviz',
  'Süt + Tam Buğday Gevrek + Çilek',
  'Ayran + Ekmek + Peynir',
  'Yoğurt + Elma + Tarçın',
  'Süt + Quinoa + Meyve',
  'Yoğurt + Mango + Hindistan Cevizi',
  'Süt + Amarant + Fındık',
  'Yoğurt + İncir + Bal'
];

final _sebzeliIsimler = [
  'Közlenmiş Patlıcan + Yoğurt + Ekmek',
  'Avokado + Yumurta + Ekmek',
  'Domates + Salatalık + Peynir + Ekmek',
  'Sebze Omlet + Ekmek',
  'Roka + Peynir + Ceviz + Ekmek',
  'Enginar + Zeytinyağı + Ekmek',
  'Irmik Helvası + Salata',
  'Patlıcan Salatası + Ekmek',
  'Yeşil Salata + Peynir + Ceviz',
  'Izgara Sebze + Labne + Ekmek',
  'Humus + Domates + Ekmek',
  'Ezme + Peynir + Ekmek',
  'Çoban Salata + Peynir + Ekmek',
  'Atom + Zeytinyağı + Ekmek',
  'Maydanoz Salatası + Bulgur + Ekmek',
  'Kısır + Yoğurt',
  'Marul + Ceviz + Peynir + Ekmek',
  'Kapya Biber + Yoğurt + Ekmek',
  'Sebzeli Wrap + Humus',
  'Mantar Sote + Ekmek'
];

final _hamurIsiIsimler = [
  'Peynirli Börek + Ayran',
  'Ispanaklı Börek + Yoğurt',
  'Kıymalı Börek + Salata',
  'Su Böreği + Peynir',
  'Gözleme Peynirli + Ayran',
  'Gözleme Patatesli + Yoğurt',
  'Poğaça Peynirli + Çay',
  'Poğaça Zeytinli + Ayran',
  'Açma + Peynir + Domates',
  'Çörek + Peynir + Çay',
  'Simit + Peynir + Domates',
  'Pide Peynirli + Ayran',
  'Lahmacun + Ayran + Yeşillik',
  'Katmer + Kaymak + Fıstık',
  'Milföy Börek + Yoğurt',
  'Sigara Böreği + Salata',
  'Kol Böreği + Ayran',
  'Çiğ Börek + Yoğurt',
  'Mantı + Yoğurt + Salça',
  'Pişi + Peynir + Bal'
];

final _peynirTipleri = ['Beyaz Peynir', 'Kaşar', 'Lor', 'Tulum', 'Çerkez Peyniri', 'Labne', 'Feta', 'Cottage Cheese'];
final _sebzeler = ['Domates 80g', 'Salatalık 70g', 'Biber 60g', 'Marul 50g', 'Roka 40g', 'Maydanoz 30g'];
final _meyveler = ['Muz 100g', 'Çilek 80g', 'Elma 90g', 'Kivi 70g', 'Üzüm 60g'];
final _ekstralar = ['Zeytin 40g', 'Ceviz 30g', 'Bal 20g', 'Reçel 25g', 'Tahin 15g'];
final _sutUrunleri = ['Yoğurt', 'Süt', 'Süzme Yoğurt', 'Ayran'];
final _tahillar = ['Yulaf', 'Granola', 'Mısır Gevreği', 'Kepekli Gevrek'];
final _icMalzemeler = ['Peynir 70g', 'Kıyma 60g', 'Ispanak 80g', 'Patates 100g'];
