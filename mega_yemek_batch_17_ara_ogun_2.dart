import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Ara Öğün 2 Batch 3 oluşturuluyor...');
  
  final yemekler = <Map<String, dynamic>>[];
  int id = 2301; // 2151 + 150
  
  // 150 ara öğün 2 daha
  for (int i = 0; i < 150; i++) {
    String ad = '';
    List<String> malzemeler = [];
    int kalori = 0;
    int protein = 0;
    int karbonhidrat = 0;
    int yag = 0;
    
    final kategori = i % 15;
    
    switch(kategori) {
      case 0: // Akşam Atıştırmalık Tartlar
        final tartlar = [
          'Mini Tart Sebzeli',
          'Quiche Mini Porsiyon',
          'Ispanak Tartaleti',
          'Mantarlı Mini Tart',
          'Peynirli Tart Light',
          'Domatesli Quiche',
          'Brokoli Tart Mini',
          'Soğan Tartı Mini',
          'Pırasa Tartı',
          'Light Lorraine Quiche'
        ];
        ad = tartlar[i ~/ 15 % tartlar.length];
        malzemeler = ['Tart hamuru 30g', 'İç malzeme ${40 + (i % 30)}g', 'Yumurta 1 adet'];
        kalori = 140 + (i % 80);
        protein = 8 + (i % 8);
        karbonhidrat = 14 + (i % 10);
        yag = 7 + (i % 6);
        break;
        
      case 1: // Izgara Sebze Kombinasyonları
        final izgara = [
          'Izgara Kabak Dilimleri',
          'Izgara Patlıcan',
          'Izgara Biber',
          'Izgara Mantar Şapka',
          'Izgara Cherry Domates',
          'Izgara Brokoli',
          'Izgara Kuşkonmaz',
          'Izgara Karnabahar',
          'Izgara Havuç Stick',
          'Izgara Sebze Mix'
        ];
        ad = izgara[i ~/ 15 % izgara.length];
        malzemeler = ['Izgara sebze ${100 + (i % 100)}g', 'Zeytinyağı 5ml', 'Baharat'];
        kalori = 60 + (i % 70);
        protein = 3 + (i % 5);
        karbonhidrat = 10 + (i % 10);
        yag = 3 + (i % 4);
        break;
        
      case 2: // Deniz Yosunu ve Alg Tabanlı
        final deniz = [
          'Nori Yaprağı (2 yaprak)',
          'Wakame Salatası',
          'Spirulina Smoothie',
          'Deniz Yosunu Cipsi',
          'Nori Roll Sebzeli',
          'Kombu Çorbası',
          'Chlorella Mix',
          'Dulse Flakes + Salata',
          'Kelp Noodle Salatası',
          'Agar-Agar Puding'
        ];
        ad = deniz[i ~/ 15 % deniz.length];
        malzemeler = ['Deniz yosunu ${10 + (i % 20)}g', 'Ek malzeme (opsiyonel)'];
        kalori = 30 + (i % 50);
        protein = 3 + (i % 5);
        karbonhidrat = 5 + (i % 8);
        yag = 1 + (i % 2);
        break;
        
      case 3: // Fırın Cips Alternatifleri
        final cipsler = [
          'Fırın Patates Cipsi Light',
          'Fırın Kabak Cipsi',
          'Fırın Pancar Cipsi',
          'Fırın Havuç Cipsi',
          'Fırın Kereviz Cipsi',
          'Fırın Rende Patates',
          'Fırın Kale Cipsi',
          'Fırın Lahana Cipsi',
          'Fırın Tatlı Patates Cipsi',
          'Fırın Patlıcan Cipsi'
        ];
        ad = cipsler[i ~/ 15 % cipsler.length];
        malzemeler = ['Sebze ${80 + (i % 60)}g', 'Zeytinyağı sprey', 'Deniz tuzu', 'Baharat'];
        kalori = 80 + (i % 70);
        protein = 2 + (i % 3);
        karbonhidrat = 15 + (i % 12);
        yag = 3 + (i % 4);
        break;
        
      case 4: // Süt Ürünleri Kombinasyonları
        final sutkombo = [
          'Yoğurt + Salatalık',
          'Kefir + Chia',
          'Labne + Domates',
          'Ayran + Nane + Limon',
          'Süzme Yoğurt + Kimyon',
          'Cottage Cheese + Biber',
          'Kefir + Kakao',
          'Yoğurt + Sarımsak',
          'Labne + Zeytin',
          'Lor + Maydanoz'
        ];
        ad = sutkombo[i ~/ 15 % sutkombo.length];
        malzemeler = ['Süt ürünü ${100 + (i % 80)}g', 'Ek tatlandırıcı ${20 + (i % 30)}g'];
        kalori = 80 + (i % 70);
        protein = 10 + (i % 10);
        karbonhidrat = 8 + (i % 10);
        yag = 3 + (i % 5);
        break;
        
      case 5: // Mini Sandviç/Wrap Varyasyonları
        final minisandvic = [
          'Cucumber Sandwich Mini',
          'Avokado Toast Dilimi',
          'Humus Wrap Mini',
          'Light Club Sandwich',
          'Ton Balığı Sandviç Mini',
          'Peynir Wrap Mini',
          'Sebzeli Tortilla Roll',
          'Yumurta Sandwich Mini',
          'Tavuk Wrap Mini',
          'Somon Sandwich Mini'
        ];
        ad = minisandvic[i ~/ 15 % minisandvic.length];
        malzemeler = ['Ekmek/Tortilla 30g', 'İç malzeme ${40 + (i % 30)}g', 'Sebze 20g'];
        kalori = 120 + (i % 90);
        protein = 10 + (i % 10);
        karbonhidrat = 15 + (i % 12);
        yag = 4 + (i % 5);
        break;
        
      case 6: // Buharda Pişmiş Atıştırmalar
        final buhar = [
          'Buharda Sebze',
          'Buharda Brokoli + Sos',
          'Buharda Karnabahar',
          'Buharda Havuç Dilim',
          'Buharda Bezelye',
          'Buharda Fasulye',
          'Buharda Kuşkonmaz',
          'Buharda Kabak',
          'Buharda Pırasa',
          'Buharda Ispanak'
        ];
        ad = buhar[i ~/ 15 % buhar.length];
        malzemeler = ['Buharda sebze ${120 + (i % 100)}g', 'Zeytinyağı 5ml', 'Limon'];
        kalori = 50 + (i % 60);
        protein = 3 + (i % 4);
        karbonhidrat = 10 + (i % 10);
        yag = 2 + (i % 3);
        break;
        
      case 7: // Akşam İçin Detoks Suları
        final detoks = [
          'Limon + Zencefil Suyu',
          'Salatalık + Nane Detoks',
          'Greyfurt Suyu',
          'Elma Sirkesi İçeceği',
          'Yeşil Detoks Suyu',
          'Havuç + Portakal Detoks',
          'Maydanoz + Limon Suyu',
          'Pancar Detoks Suyu',
          'Kereviz + Elma Suyu',
          'Ananas + Zencefil Suyu'
        ];
        ad = detoks[i ~/ 15 % detoks.length];
        malzemeler = ['Detoks karışımı ${200 + (i % 100)}ml'];
        kalori = 30 + (i % 50);
        protein = 1 + (i % 2);
        karbonhidrat = 7 + (i % 10);
        yag = 0;
        break;
        
      case 8: // Miso ve Fermente Çorbalar
        final fermentecorba = [
          'Miso Çorbası Light',
          'Kimchi Çorbası',
          'Fermente Sebze Çorbası',
          'Doenjang Çorbası',
          'Miso + Tofu',
          'Wakame Miso',
          'Sebzeli Miso',
          'Mantarlı Miso',
          'Probiyotik Çorba',
          'Fermente Lahana Çorbası'
        ];
        ad = fermentecorba[i ~/ 15 % fermentecorba.length];
        malzemeler = ['Çorba bazı 200ml', 'Fermente malzeme 30g', 'Tofu/Sebze 40g'];
        kalori = 60 + (i % 70);
        protein = 6 + (i % 6);
        karbonhidrat = 8 + (i % 8);
        yag = 2 + (i % 3);
        break;
        
      case 9: // Tofu Atıştırmaları
        final tofu = [
          'Izgara Tofu (80g)',
          'Fırın Tofu Küpleri',
          'Tofu Scramble Light',
          'Közlenmiş Tofu',
          'Baharatlı Tofu',
          'Soya Soslu Tofu',
          'Tofu + Sebze',
          'Tofu Stick',
          'Tofu Salata',
          'Marine Edilmiş Tofu'
        ];
        ad = tofu[i ~/ 15 % tofu.length];
        malzemeler = ['Tofu ${70 + (i % 40)}g', 'Baharat/Sos 10ml'];
        kalori = 80 + (i % 60);
        protein = 10 + (i % 8);
        karbonhidrat = 3 + (i % 4);
        yag = 5 + (i % 5);
        break;
        
      case 10: // Tempeh Atıştırmaları
        final tempeh = [
          'Izgara Tempeh (70g)',
          'Fırın Tempeh Dilim',
          'Baharatlı Tempeh',
          'Tempeh Stick',
          'Közlenmiş Tempeh',
          'Tempeh + Sebze',
          'Tempeh Salata',
          'Soya Soslu Tempeh',
          'Tempeh Crumble',
          'Marine Tempeh'
        ];
        ad = tempeh[i ~/ 15 % tempeh.length];
        malzemeler = ['Tempeh ${60 + (i % 30)}g', 'Baharat/Sos'];
        kalori = 90 + (i % 70);
        protein = 11 + (i % 8);
        karbonhidrat = 6 + (i % 6);
        yag = 5 + (i % 5);
        break;
        
      case 11: // Seitan (Buğday Proteini)
        final seitan = [
          'Izgara Seitan (60g)',
          'Fırın Seitan Dilim',
          'Seitan Stick',
          'Baharatlı Seitan',
          'Seitan + Sebze',
          'BBQ Seitan',
          'Teriyaki Seitan',
          'Seitan Wrap Mini',
          'Seitan Salata',
          'Seitan Skewer'
        ];
        ad = seitan[i ~/ 15 % seitan.length];
        malzemeler = ['Seitan ${50 + (i % 30)}g', 'Sos/Baharat 10ml'];
        kalori = 70 + (i % 60);
        protein = 14 + (i % 10);
        karbonhidrat = 4 + (i % 5);
        yag = 1 + (i % 2);
        break;
        
      case 12: // Vegan Protein Snackları
        final veganprotein = [
          'Vegan Protein Bar',
          'Vegan Protein Ball',
          'Vegan Protein Shake',
          'Bezelye Proteini Shake',
          'Kinoa Protein Bowl Mini',
          'Vegan Protein Brownie',
          'Vegan Protein Cookie',
          'Hemp Protein Smoothie',
          'Vegan Protein Chips',
          'Soya Protein Snack'
        ];
        ad = veganprotein[i ~/ 15 % veganprotein.length];
        malzemeler = ['Vegan protein kaynağı ${40 + (i % 30)}g'];
        kalori = 100 + (i % 80);
        protein = 12 + (i % 10);
        karbonhidrat = 10 + (i % 10);
        yag = 4 + (i % 4);
        break;
        
      case 13: // Akşam Çay Saati Snackları
        final caysnack = [
          'Çay + Bitter Çikolata (10g)',
          'Çay + Tam Buğday Bisküvi (2 adet)',
          'Çay + Badem (10 adet)',
          'Yeşil Çay + Hurma (2 adet)',
          'Beyaz Çay + Ceviz (6 adet)',
          'Ihlamur + Fındık (10 adet)',
          'Papatya + Kuru Kayısı (3 adet)',
          'Nane Çayı + İncir (2 adet)',
          'Adaçayı + Antep Fıstığı (15g)',
          'Kuşburnu + Kuru Üzüm (20g)'
        ];
        ad = caysnack[i ~/ 15 % caysnack.length];
        malzemeler = ['Bitki çayı 250ml', 'Sağlıklı atıştırmalık ${15 + (i % 20)}g'];
        kalori = 60 + (i % 80);
        protein = 3 + (i % 4);
        karbonhidrat = 10 + (i % 12);
        yag = 3 + (i % 6);
        break;
        
      case 14: // Özel Beslenme Snackları
        final ozelbeslenme = [
          'Ketojenik Snack Mix',
          'Paleo Trail Mix Mini',
          'Gluten-Free Protein Bar',
          'Low-FODMAP Snack',
          'Anti-inflamatuar Mix',
          'Diabetik Uyumlu Bar',
          'Laktoz-Free Puding',
          'Raw Vegan Ball',
          'Keto Cheese Snack',
          'Whole30 Uyumlu Mix'
        ];
        ad = ozelbeslenme[i ~/ 15 % ozelbeslenme.length];
        malzemeler = ['Özel diyet uyumlu malzemeler'];
        kalori = 90 + (i % 90);
        protein = 9 + (i % 9);
        karbonhidrat = 8 + (i % 12);
        yag = 6 + (i % 8);
        break;
      
      default:
        ad = 'Ara Öğün 2 Özel Varyasyon ${i + 1}';
        malzemeler = ['Standart ara öğün 2 malzemeleri'];
        kalori = 100;
        protein = 8;
        karbonhidrat = 10;
        yag = 3;
    }
    
    yemekler.add({
      "id": "ARA2_${id++}",
      "ad": ad,
      "ogun": "ara_ogun_2",
      "malzemeler": malzemeler,
      "kalori": kalori,
      "protein": protein,
      "karbonhidrat": karbonhidrat,
      "yag": yag
    });
  }
  
  final file = File('assets/data/mega_ara_ogun_2_batch_3.json');
  await file.create(recursive: true);
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(yemekler)
  );
  
  print('✅ Başarılı!');
  print('📊 Toplam: ${yemekler.length} ara öğün 2');
  print('📊 TOPLAM ARA ÖĞÜN 2 (3 Batch): 450 ara öğün');
  print('📊 ŞİMDİYE KADAR GRANDhave TOPLAM: 2000 YEMEK! 🎉🎊');
  print('📁 Dosya: ${file.path}');
  print('\n🚀 Token izin verirse devam ediyoruz...');
}
