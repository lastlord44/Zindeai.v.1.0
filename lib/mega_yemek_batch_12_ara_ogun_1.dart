import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 1 Batch 1 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 1101;
  
  // 150 ara öğün oluşturacağız (daha fazla çeşitlilik için)
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15; // 15 farklı kategori
    
    switch(kategori) {
      case 0: // Süzme Yoğurt Kombinasyonları
        final yogurtlar = [
          'Süzme Yoğurt + Çilek',
          'Süzme Yoğurt + Yaban Mersini',
          'Süzme Yoğurt + Muz + Tarçın',
          'Süzme Yoğurt + Bal + Ceviz',
          'Süzme Yoğurt + Frambuaz',
          'Süzme Yoğurt + Elma + Badem',
          'Süzme Yoğurt + Kivi',
          'Süzme Yoğurt + Mango',
          'Süzme Yoğurt + Böğürtlen',
          'Süzme Yoğurt + Nar + Ceviz'
        ];
        ad = yogurtlar[i ~/ 15 % yogurtlar.length];
        malzemeler = ['Süzme yoğurt 200g', 'Meyve ${50 + (i % 30)}g', 'Bal 10g'];
        kalori = 180 + (i % 40);
        protein = 15 + (i % 8);
        karbonhidrat = 20 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 1: // Protein Smoothie
        final smoothieler = [
          'Protein Smoothie Çilek-Muz',
          'Protein Smoothie Yaban Mersini',
          'Protein Smoothie Çikolatalı',
          'Protein Smoothie Muzlu',
          'Protein Smoothie Karışık Meyveli',
          'Protein Smoothie Frambuazlı',
          'Protein Smoothie Mangolu',
          'Green Protein Smoothie',
          'Protein Smoothie Vişneli',
          'Protein Smoothie Kayısılı'
        ];
        ad = smoothieler[i ~/ 15 % smoothieler.length];
        malzemeler = ['Whey protein 30g', 'Süt 200ml', 'Meyve 100g', 'Yulaf 20g'];
        kalori = 220 + (i % 50);
        protein = 25 + (i % 10);
        karbonhidrat = 25 + (i % 15);
        yag = 4 + (i % 3);
        break;
        
      case 2: // Kuruyemiş Karışımları
        final kuruyemisler = [
          'Badem Mix',
          'Ceviz Mix',
          'Fındık Mix',
          'Antep Fıstığı Mix',
          'Karışık Kuruyemiş',
          'Fıstık + Kuru Üzüm Mix',
          'Badem + Kuru Kayısı Mix',
          'Ceviz + Hurma Mix',
          'Fındık + Kuru Erik Mix',
          'Kaju + Kuru İncir Mix'
        ];
        ad = kuruyemisler[i ~/ 15 % kuruyemisler.length];
        malzemeler = ['Karışık kuruyemiş 40g', 'Kuru meyve 20g'];
        kalori = 240 + (i % 60);
        protein = 8 + (i % 5);
        karbonhidrat = 18 + (i % 10);
        yag = 16 + (i % 8);
        break;
        
      case 3: // Meyve Tabağı Kombinasyonları
        final meyveler = [
          'Elma Dilim',
          'Portakal + Kivi',
          'Muz + Çilek',
          'Üzüm + Armut',
          'Kavun Dilim',
          'Karpuz Dilim',
          'Şeftali + Kiraz',
          'Nar Taneleri',
          'Mandalina',
          'Greyfurt'
        ];
        ad = meyveler[i ~/ 15 % meyveler.length];
        malzemeler = ['Taze meyve ${150 + (i % 50)}g'];
        kalori = 80 + (i % 40);
        protein = 1 + (i % 2);
        karbonhidrat = 18 + (i % 12);
        yag = 0;
        break;
        
      case 4: // Peynir + Tam Tahıl Kombinasyonları
        final peynirler = [
          'Beyaz Peynir + Tam Buğday Kraker',
          'Lor Peyniri + Galeta',
          'Çökelek + Kepekli Kraker',
          'Labne + Tam Tahıl Ekmek',
          'Beyaz Peynir + Yulaf Krateri',
          'Cottage Cheese + Tam Tahıl',
          'Kaşar Peyniri + Kepekli Kraker',
          'Tulum Peyniri + Tam Buğday',
          'Ezine Peyniri + Galeta',
          'Light Peynir + Kraker'
        ];
        ad = peynirler[i ~/ 15 % peynirler.length];
        malzemeler = ['Peynir ${40 + (i % 20)}g', 'Tam tahıl kraker 30g'];
        kalori = 160 + (i % 50);
        protein = 12 + (i % 6);
        karbonhidrat = 15 + (i % 8);
        yag = 7 + (i % 5);
        break;
        
      case 5: // Yumurta Çeşitleri
        final yumurtalar = [
          'Haşlanmış Yumurta (2 adet)',
          'Haşlanmış Yumurta (1 adet) + Domates',
          'Haşlanmış Yumurta + Salatalık',
          'Çırpılmış Yumurta Light',
          'Omlet Mini (1 yumurta)',
          'Yumurta + Avokado Dilim',
          'Yumurta + Cherry Domates',
          'Haşlanmış Yumurta + Marul',
          'Yumurta + Tam Tahıl Ekmek Dilimi',
          'Poşe Yumurta'
        ];
        ad = yumurtalar[i ~/ 15 % yumurtalar.length];
        malzemeler = ['Yumurta ${1 + (i % 2)} adet', 'Sebze 50g'];
        kalori = 140 + (i % 60);
        protein = 12 + (i % 8);
        karbonhidrat = 3 + (i % 5);
        yag = 9 + (i % 6);
        break;
        
      case 6: // Protein Bar ve Snackler
        final barlar = [
          'Protein Bar Çikolatalı',
          'Protein Bar Fındıklı',
          'Protein Bar Bademli',
          'Protein Bar Yer Fıstıklı',
          'Protein Bar Vanilya',
          'Protein Bar Karamel',
          'Ev Yapımı Enerji Topu',
          'Protein Brownie',
          'Protein Cookie',
          'Quest Bar'
        ];
        ad = barlar[i ~/ 15 % barlar.length];
        malzemeler = ['Protein bar 60g'];
        kalori = 200 + (i % 80);
        protein = 20 + (i % 10);
        karbonhidrat = 22 + (i % 15);
        yag = 6 + (i % 4);
        break;
        
      case 7: // Sebze Sticks + Dip
        final sebzedip = [
          'Havuç Stick + Humus',
          'Kereviz + Fıstık Ezmesi',
          'Salatalık Dilim + Tahin',
          'Biber Dilim + Humus',
          'Havuç + Tzatziki',
          'Kereviz + Labne',
          'Cherry Domates + Humus',
          'Sebze Mix + Avokado Dip',
          'Havuç + Yoğurt Sos',
          'Kabak Dilim + Humus'
        ];
        ad = sebzedip[i ~/ 15 % sebzedip.length];
        malzemeler = ['Taze sebze 150g', 'Dip sos 40g'];
        kalori = 130 + (i % 50);
        protein = 6 + (i % 4);
        karbonhidrat = 14 + (i % 8);
        yag = 7 + (i % 5);
        break;
        
      case 8: // Avokado Kombinasyonları
        final avokadomix = [
          'Avokado Dilim + Limon',
          'Avokado + Tam Tahıl Kraker',
          'Avokado + Domates',
          'Guacamole + Sebze Stick',
          'Avokado + Haşlanmış Yumurta',
          'Avokado Toast Mini',
          'Avokado + Kırmızı Biber',
          'Avokado + Roka',
          'Avokado Salatası',
          'Avokado Smoothie Bowl'
        ];
        ad = avokadomix[i ~/ 15 % avokadomix.length];
        malzemeler = ['Avokado ${60 + (i % 40)}g', 'Ek malzeme 30g'];
        kalori = 160 + (i % 70);
        protein = 3 + (i % 3);
        karbonhidrat = 9 + (i % 6);
        yag = 13 + (i % 8);
        break;
        
      case 9: // Fıstık Ezmesi Kombinasyonları
        final fistikez = [
          'Fıstık Ezmesi + Elma Dilim',
          'Fıstık Ezmesi + Muz',
          'Fıstık Ezmesi + Kereviz',
          'Fıstık Ezmesi + Tam Tahıl Ekmek',
          'Badem Ezmesi + Elma',
          'Fındık Ezmesi + Muz',
          'Fıstık Ezmesi + Hurma',
          'Badem Ezmesi + Kereviz',
          'Fıstık Ezmesi + Galeta',
          'Fıstık Ezmesi + Havuç'
        ];
        ad = fistikez[i ~/ 15 % fistikez.length];
        malzemeler = ['Fıstık ezmesi 25g', 'Meyve/sebze 100g'];
        kalori = 200 + (i % 60);
        protein = 8 + (i % 5);
        karbonhidrat = 18 + (i % 10);
        yag = 12 + (i % 6);
        break;
        
      case 10: // Kefir ve Ayran Kombinasyonları
        final icecekler = [
          'Kefir 200ml',
          'Ayran 250ml',
          'Kefir + Çilek',
          'Ayran + Nane',
          'Kefir + Muz',
          'Probiyotik İçecek',
          'Kefir + Yaban Mersini',
          'Ayran + Salatalık',
          'Kefir Smoothie',
          'Buttermilk 250ml'
        ];
        ad = icecekler[i ~/ 15 % icecekler.length];
        malzemeler = ['Fermente süt ürünü 200ml', 'Ek tatlandırıcı (opsiyonel)'];
        kalori = 90 + (i % 50);
        protein = 7 + (i % 4);
        karbonhidrat = 10 + (i % 8);
        yag = 2 + (i % 3);
        break;
        
      case 11: // Türk Geleneksel Atıştırmalıklar
        final geleneksel = [
          'Ceviz İçi + Kuru Üzüm',
          'İncir + Badem',
          'Hurma + Ceviz',
          'Kuru Kayısı + Antep Fıstığı',
          'Kuru Erik + Ceviz',
          'Fındık + Kuru Dut',
          'Leblebi (Kavurga)',
          'Çekirdek Karışımı',
          'Kuru Meyve Mix',
          'Pestil + Ceviz'
        ];
        ad = geleneksel[i ~/ 15 % geleneksel.length];
        malzemeler = ['Kuruyemiş 30g', 'Kuru meyve 30g'];
        kalori = 210 + (i % 70);
        protein = 6 + (i % 4);
        karbonhidrat = 24 + (i % 12);
        yag = 11 + (i % 7);
        break;
        
      case 12: // Light Sandviç Çeşitleri
        final sandvicler = [
          'Mini Ton Balıklı Sandviç',
          'Mini Beyaz Peynirli Sandviç',
          'Mini Tavuklu Wrap',
          'Tam Tahıl Ekmek + Avokado',
          'Kepekli Ekmek + Labne',
          'Mini Hindi Füme Sandviç',
          'Tam Tahıl + Humus',
          'Light Sandviç (Yumurta)',
          'Sebzeli Mini Wrap',
          'Lor Peyniri Sandviç'
        ];
        ad = sandvicler[i ~/ 15 % sandvicler.length];
        malzemeler = ['Tam tahıl ekmek 40g', 'Protein kaynağı 30g', 'Sebze 20g'];
        kalori = 180 + (i % 70);
        protein = 14 + (i % 8);
        karbonhidrat = 20 + (i % 10);
        yag = 5 + (i % 4);
        break;
        
      case 13: // Shake ve Protein İçecekler
        final shakeler = [
          'Whey Protein Shake Vanilya',
          'Whey Protein Shake Çikolata',
          'Whey Protein Shake Çilek',
          'Casein Protein Shake',
          'Vegan Protein Shake',
          'Protein Shake + Muz',
          'Protein Shake + Yulaf',
          'Protein Coffee',
          'Protein Shake Karamel',
          'Mass Gainer Shake Light'
        ];
        ad = shakeler[i ~/ 15 % shakeler.length];
        malzemeler = ['Whey protein 30g', 'Su/Süt 250ml'];
        kalori = 130 + (i % 50);
        protein = 25 + (i % 8);
        karbonhidrat = 5 + (i % 8);
        yag = 2 + (i % 2);
        break;
        
      case 14: // Bowl ve Porsiyonluk Atıştırmalıklar
        final bowllar = [
          'Yoğurt Bowl (Yulaf + Meyve)',
          'Açai Bowl Mini',
          'Protein Pudding',
          'Chia Pudding',
          'Overnight Oats',
          'Granola Bowl',
          'Smoothie Bowl',
          'Yoğurt Parfait',
          'Meyve Salatası Bowl',
          'Cottage Cheese Bowl'
        ];
        ad = bowllar[i ~/ 15 % bowllar.length];
        malzemeler = ['Ana baz 150g', 'Topping 40g', 'Meyve 50g'];
        kalori = 220 + (i % 80);
        protein = 12 + (i % 8);
        karbonhidrat = 28 + (i % 15);
        yag = 6 + (i % 5);
        break;
      
      default:
        ad = 'Ara Öğün ${i + 1}';
        malzemeler = ['Standart ara öğün malzemeleri'];
        kalori = 150;
        protein = 10;
        karbonhidrat = 15;
        yag = 5;
    }
    
    yemekler.add({
      "id": "ARA1_${id++}",
      "ad": ad,
      "ogun": "ara_ogun_1",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  // JSON dosyasına kaydet
  final file = File('assets/data/mega_ara_ogun_1_batch_1.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 1');
  print('📁 Dosya: ${file.path}');
}
