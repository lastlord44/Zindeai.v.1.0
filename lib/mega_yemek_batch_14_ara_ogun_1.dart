import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 1 Batch 3 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 1401; // 1251 + 150
  
  // 150 ara öğün daha
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15;
    
    switch(kategori) {
      case 0: // Bakliyat Bazlı Atıştırmalıklar
        final bakla = [
          'Fırınlanmış Nohut Krokan',
          'Baharatlı Bezelye Kızartması',
          'Soya Fıstığı Mix',
          'Edamame + Deniz Tuzu',
          'Nohut + Sumak',
          'Barbunya Fasulyesi Salatası',
          'Fasulye Dip + Kraker',
          'Mercimek Cipsi',
          'Börülce + Zeytinyağı',
          'Bakla + Limon'
        ];
        ad = bakla[i ~/ 15 % bakla.length];
        malzemeler = ['Baklagil ${70 + (i % 50)}g', 'Baharat/Sos ${10 + (i % 10)}g'];
        kalori = 130 + (i % 70);
        protein = 9 + (i % 7);
        karbonhidrat = 18 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 1: // Çiğ Atıştırmalıklar (Raw Snacks)
        final raw = [
          'Çiğ Badem Dilimleri',
          'Çiğ Havuç + Humus',
          'Çiğ Brokoli Çubukları',
          'Çiğ Mantar + Zeytinyağı',
          'Çiğ Kabak Dilimleri',
          'Çiğ Karnabahar + Sos',
          'Çiğ Ispanak Salatası Mini',
          'Çiğ Cherry Domates',
          'Çiğ Kırmızı Lahana',
          'Çiğ Roka + Parmesan'
        ];
        ad = raw[i ~/ 15 % raw.length];
        malzemeler = ['Çiğ sebze ${100 + (i % 80)}g', 'Dip/Sos 30g'];
        kalori = 80 + (i % 60);
        protein = 4 + (i % 5);
        karbonhidrat = 12 + (i % 10);
        yag = 3 + (i % 5);
        break;
        
      case 2: // Kurutulmuş Meyveler
        final kuru = [
          'Kuru Kayısı',
          'Kuru İncir',
          'Kuru Üzüm',
          'Kuru Erik',
          'Hurma (4 adet)',
          'Kuru Elma Dilimleri',
          'Kuru Mango',
          'Kuru Ananas',
          'Kuru Çilek',
          'Kuru Armut'
        ];
        ad = kuru[i ~/ 15 % kuru.length];
        malzemeler = ['Kuru meyve ${40 + (i % 30)}g'];
        kalori = 110 + (i % 70);
        protein = 2 + (i % 3);
        karbonhidrat = 26 + (i % 15);
        yag = 0;
        break;
        
      case 3: // Taze Tatlı Atıştırmalar
        final tatli = [
          'Meyve Şişi',
          'Meyve Salatası Bardağı',
          'Elma Dilimleri + Tarçın',
          'Portakal Dilimleri',
          'Çilek + Yoğurt Dip',
          'Muz + Fıstık Ezmesi',
          'Üzüm Taneleri (150g)',
          'Kavun + Mozzarella',
          'Karpuz Küpleri',
          'Şeftali Dilimleri'
        ];
        ad = tatli[i ~/ 15 % tatli.length];
        malzemeler = ['Taze meyve ${120 + (i % 80)}g', 'Ek sos (opsiyonel)'];
        kalori = 90 + (i % 60);
        protein = 2 + (i % 3);
        karbonhidrat = 20 + (i % 15);
        yag = 1 + (i % 2);
        break;
        
      case 4: // Protein Kahvaltılık Gevrekler
        final cereal = [
          'Protein Granola + Süt',
          'Yulaf + Protein Tozu',
          'Kepek Gevreği + Süt',
          'Müsli + Kefir',
          'Kinoa Gevreği + Yoğurt',
          'Tahıl Karışımı + Badem Sütü',
          'Cornflakes Protein + Süt',
          'Yulaf Ezmesi Soğuk',
          'Granola + Meyve',
          'Tam Tahıl Gevrek + Süt'
        ];
        ad = cereal[i ~/ 15 % cereal.length];
        malzemeler = ['Tahıl ${40 + (i % 20)}g', 'Süt/Yoğurt 150ml', 'Meyve (opsiyonel)'];
        kalori = 180 + (i % 80);
        protein = 12 + (i % 10);
        karbonhidrat = 28 + (i % 15);
        yag = 4 + (i % 4);
        break;
        
      case 5: // Zeytinyağlı Atıştırmalar
        final olive = [
          'Zeytinyağlı Taze Fasulye',
          'Zeytinyağlı Pırasa Mini',
          'Zeytinyağlı Enginar',
          'Zeytinyağlı Kabak',
          'Zeytinyağlı Barbunya',
          'Zeytinyağlı Biber Dolması',
          'Zeytinyağlı Yaprak Sarması (2 adet)',
          'Zeytinyağlı Kereviz',
          'Zeytinyağlı Bamya',
          'Zeytinyağlı Lahana Sarması'
        ];
        ad = olive[i ~/ 15 % olive.length];
        malzemeler = ['Sebze ${100 + (i % 50)}g', 'Zeytinyağı 10ml', 'Baharat'];
        kalori = 120 + (i % 60);
        protein = 3 + (i % 4);
        karbonhidrat = 15 + (i % 10);
        yag = 6 + (i % 5);
        break;
        
      case 6: // Dip ve Ezme Çeşitleri
        final dips = [
          'Humus + Sebze Stick',
          'Baba Ganoush + Kraker',
          'Tzatziki + Havuç',
          'Tahin + Pekmez',
          'Guacamole + Pirinç Patlağı',
          'Taramasalata + Kraker',
          'Patlıcan Salatası + Domates',
          'Yoğurt + Sarımsak Ezme',
          'Acuka + Kereviz',
          'Atom + Sebze'
        ];
        ad = dips[i ~/ 15 % dips.length];
        malzemeler = ['Ezme/Dip ${60 + (i % 40)}g', 'Sebze/Kraker 50g'];
        kalori = 140 + (i % 70);
        protein = 6 + (i % 6);
        karbonhidrat = 16 + (i % 12);
        yag = 7 + (i % 6);
        break;
        
      case 7: // Kahve ve Çay Kombinasyonları
        final drinks = [
          'Cappuccino Light',
          'Latte + Badem Sütü',
          'Türk Kahvesi + Hurma',
          'Espresso + Bitter Çikolata',
          'Yeşil Çay + Badem',
          'Matcha Latte',
          'Chai Tea + Süt',
          'Protein Kahve',
          'Cold Brew + Süt',
          'Bulletproof Coffee Light'
        ];
        ad = drinks[i ~/ 15 % drinks.length];
        malzemeler = ['Kahve/Çay 200ml', 'Süt/Tatlandırıcı', 'Ek (opsiyonel)'];
        kalori = 80 + (i % 90);
        protein = 4 + (i % 6);
        karbonhidrat = 10 + (i % 12);
        yag = 4 + (i % 6);
        break;
        
      case 8: // Mini Salata Çeşitleri
        final salads = [
          'Çoban Salatası Mini',
          'Akdeniz Salatası Bardağı',
          'Yeşil Salata + Ton Balığı',
          'Roka + Parmesan',
          'Kırmızı Lahana Salatası',
          'Mevsim Salata Mini',
          'Caesar Salad Light',
          'Kinoa Salatası',
          'Mercimek Salatası Mini',
          'Bulgur Salatası'
        ];
        ad = salads[i ~/ 15 % salads.length];
        malzemeler = ['Sebze karışımı ${100 + (i % 50)}g', 'Protein 30g', 'Sos 15ml'];
        kalori = 110 + (i % 80);
        protein = 8 + (i % 8);
        karbonhidrat = 12 + (i % 10);
        yag = 5 + (i % 5);
        break;
        
      case 9: // Ev Yapımı Sağlıklı Atıştırmalıklar
        final homemade = [
          'Ev Yapımı Granola Bar',
          'Ev Yapımı Protein Topu',
          'Ev Yapımı Enerji Bar',
          'Ev Yapımı Yulaf Kurabiyesi',
          'Ev Yapımı Protein Kraker',
          'Ev Yapımı Meyve Leather',
          'Ev Yapımı Trail Mix',
          'Ev Yapımı Protein Brownie',
          'Ev Yapımı Chia Bar',
          'Ev Yapımı Tahini Ball'
        ];
        ad = homemade[i ~/ 15 % homemade.length];
        malzemeler = ['Karışık malzemeler (ev yapımı)'];
        kalori = 170 + (i % 80);
        protein = 8 + (i % 8);
        karbonhidrat = 22 + (i % 15);
        yag = 7 + (i % 6);
        break;
        
      case 10: // Çiğ Kuruyemiş Mix'leri
        final nuts = [
          'Çiğ Badem (30g)',
          'Çiğ Ceviz (25g)',
          'Çiğ Fındık (30g)',
          'Çiğ Kaju (30g)',
          'Çiğ Antep Fıstığı (25g)',
          'Çiğ Brezilya Cevizi',
          'Çiğ Pekan Cevizi',
          'Çiğ Macadamia',
          'Karışık Çiğ Nuts',
          'Çiğ Kabak Çekirdeği'
        ];
        ad = nuts[i ~/ 15 % nuts.length];
        malzemeler = ['Çiğ kuruyemiş ${25 + (i % 15)}g'];
        kalori = 160 + (i % 80);
        protein = 6 + (i % 5);
        karbonhidrat = 8 + (i % 8);
        yag = 14 + (i % 8);
        break;
        
      case 11: // Kavrulmuş Kuruyemiş Mix'leri
        final roasted = [
          'Kavrulmuş Badem',
          'Kavrulmuş Fındık',
          'Kavrulmuş Yer Fıstığı',
          'Kavrulmuş Nohut',
          'Kavrulmuş Ay Çekirdeği',
          'Kavrulmuş Kabak Çekirdeği',
          'Kavrulmuş Kaju',
          'Kavrulmuş Leblebi',
          'Kavrulmuş Antep Fıstığı',
          'Kavrulmuş Mix Nuts'
        ];
        ad = roasted[i ~/ 15 % roasted.length];
        malzemeler = ['Kavrulmuş kuruyemiş ${30 + (i % 20)}g'];
        kalori = 180 + (i % 90);
        protein = 7 + (i % 6);
        karbonhidrat = 10 + (i % 10);
        yag = 15 + (i % 9);
        break;
        
      case 12: // Tahıl Kreması ve Lapalar
        final porridge = [
          'Yulaf Lapası Mini',
          'Kinoa Lapası',
          'Bulgur Lapası',
          'Arpa Lapası',
          'Pirinç Lapası',
          'Karabuğday Lapası',
          'Mısır Lapası',
          'Çavdar Lapası',
          'Amarant Lapası',
          'Tahıl Mix Lapası'
        ];
        ad = porridge[i ~/ 15 % porridge.length];
        malzemeler = ['Tahıl ${40 + (i % 20)}g', 'Süt/Su 150ml', 'Tatlandırıcı'];
        kalori = 150 + (i % 70);
        protein = 6 + (i % 5);
        karbonhidrat = 26 + (i % 15);
        yag = 3 + (i % 4);
        break;
        
      case 13: // Pişmiş Sebze Atıştırmalıklar
        final cooked = [
          'Haşlanmış Mısır',
          'Fırınlanmış Tatlı Patates',
          'Buharda Brokoli + Sos',
          'Haşlanmış Karnabahar',
          'Fırın Kabak Dilimleri',
          'Izgara Patlıcan',
          'Haşlanmış Bezelye',
          'Fırın Havuç',
          'Buharda Kuşkonmaz',
          'Haşlanmış Ispanak'
        ];
        ad = cooked[i ~/ 15 % cooked.length];
        malzemeler = ['Pişmiş sebze ${120 + (i % 80)}g', 'Zeytinyağı 5ml', 'Baharat'];
        kalori = 100 + (i % 70);
        protein = 4 + (i % 4);
        karbonhidrat = 18 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 14: // Fermente Gıdalar
        final fermented = [
          'Kefir + Meyve',
          'Ayran + Nane',
          'Probiyotik Yoğurt',
          'Kombucha',
          'Kimchi Mini Porsiyon',
          'Turşu Çeşitleri',
          'Fermente Lahana',
          'Probiyotik İçecek',
          'Yoğurt + Probiyotik',
          'Kefir Smoothie'
        ];
        ad = fermented[i ~/ 15 % fermented.length];
        malzemeler = ['Fermente gıda ${100 + (i % 100)}g'];
        kalori = 70 + (i % 80);
        protein = 5 + (i % 6);
        karbonhidrat = 10 + (i % 10);
        yag = 2 + (i % 4);
        break;
      
      default:
        ad = 'Ara Öğün 1 Özel ${i + 1}';
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
  
  final file = File('assets/data/mega_ara_ogun_1_batch_3.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 1');
  print('📊 TOPLAM ARA ÖĞÜN 1 (3 Batch): 450 ara öğün');
  print('📁 Dosya: ${file.path}');
}
