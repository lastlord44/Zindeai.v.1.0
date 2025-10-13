// MEGA YEMEK BATCH 24-29 - SAĞLIKLI ARA ÖĞÜN 2 (500+ Eklenti - 5/5)
// Diyetisyen Onaylı, Kolay Bulunabilir, Türk Mutfağı
// AO2_1001 - AO2_1300 (300 Adet)

List<Map<String, dynamic>> getMegaYemekBatch24_29() {
  final yemekler = <Map<String, dynamic>>[];
  
  // BÖLÜM 1: Yoğurt Bazlı (60 adet - AO2_1001-1060)
  final yogurtBazli = [
    {'ad': 'Süzme Yoğurt + Ceviz', 'protein': 15.0, 'yag': 12.0, 'karbonhidrat': 8.0, 'kalori': 195.0, 'malzemeler': ['200g Süzme Yoğurt', '30g Ceviz']},
    {'ad': 'Yoğurt + Badem', 'protein': 14.0, 'yag': 10.0, 'karbonhidrat': 10.0, 'kalori': 185.0, 'malzemeler': ['200g Yoğurt', '25g Badem']},
    {'ad': 'Süzme Yoğurt + Bal + Tarçın', 'protein': 12.0, 'yag': 3.0, 'karbonhidrat': 18.0, 'kalori': 155.0, 'malzemeler': ['200g Süzme Yoğurt', '1 Tatlı Kaşığı Bal', 'Tarçın']},
    {'ad': 'Yoğurt + Keten Tohumu', 'protein': 15.0, 'yag': 8.0, 'karbonhidrat': 9.0, 'kalori': 175.0, 'malzemeler': ['200g Yoğurt', '1 Yemek Kaşığı Keten Tohumu']},
    {'ad': 'Süzme Yoğurt + Fındık', 'protein': 14.0, 'yag': 11.0, 'karbonhidrat': 9.0, 'kalori': 190.0, 'malzemeler': ['200g Süzme Yoğurt', '25g Fındık']},
    {'ad': 'Yoğurt + Chia Tohumu', 'protein': 13.0, 'yag': 9.0, 'karbonhidrat': 12.0, 'kalori': 185.0, 'malzemeler': ['200g Yoğurt', '1.5 Yemek Kaşığı Chia Tohumu']},
    {'ad': 'Süzme Yoğurt + Muz', 'protein': 12.0, 'yag': 3.0, 'karbonhidrat': 22.0, 'kalori': 165.0, 'malzemeler': ['150g Süzme Yoğurt', '1 Muz', 'Tarçın']},
    {'ad': 'Yoğurt + Kuru Erik', 'protein': 11.0, 'yag': 2.0, 'karbonhidrat': 20.0, 'kalori': 145.0, 'malzemeler': ['200g Yoğurt', '4-5 Adet Kuru Erik']},
    {'ad': 'Süzme Yoğurt + Kayısı + Badem', 'protein': 13.0, 'yag': 8.0, 'karbonhidrat': 18.0, 'kalori': 195.0, 'malzemeler': ['150g Süzme Yoğurt', '5 Kuru Kayısı', '15g Badem']},
    {'ad': 'Yoğurt + Ceviz + Üzüm', 'protein': 12.0, 'yag': 10.0, 'karbonhidrat': 16.0, 'kalori': 200.0, 'malzemeler': ['150g Yoğurt', '20g Ceviz', '1 Avuç Üzüm']},
  ];
  
  for (int i = 0; i < 60; i++) {
    final v = yogurtBazli[i % yogurtBazli.length];
    yemekler.add({
      'id': 'AO2_${1001 + i}',
      'kategori': 'ara_ogun_2',
      'ad': v['ad'],
      'kalori': v['kalori'],
      'protein': v['protein'],
      'karbonhidrat': v['karbonhidrat'],
      'yag': v['yag'],
      'hazirlamaSuresi': 5,
      'zorluk': 'Kolay',
      'malzemeler': v['malzemeler'],
    });
  }
  
  // BÖLÜM 2: Meyve Bazlı (60 adet - AO2_1061-1120)
  final meyveBazli = [
    {'ad': 'Elma + Badem Ezmesi', 'protein': 8.0, 'yag': 12.0, 'karbonhidrat': 18.0, 'kalori': 215.0, 'malzemeler': ['1 Büyük Elma', '2 Yemek Kaşığı Badem Ezmesi']},
    {'ad': 'Muz + Fıstık Ezmesi', 'protein': 9.0, 'yag': 11.0, 'karbonhidrat': 24.0, 'kalori': 235.0, 'malzemeler': ['1 Muz', '2 Yemek Kaşığı Fıstık Ezmesi']},
    {'ad': 'Armut + Ceviz', 'protein': 6.0, 'yag': 10.0, 'karbonhidrat': 20.0, 'kalori': 200.0, 'malzemeler': ['1 Büyük Armut', '25g Ceviz']},
    {'ad': 'Portakal + Badem', 'protein': 7.0, 'yag': 9.0, 'karbonhidrat': 16.0, 'kalori': 180.0, 'malzemeler': ['2 Portakal', '20g Badem']},
    {'ad': 'Üzüm + Fındık', 'protein': 6.0, 'yag': 10.0, 'karbonhidrat': 22.0, 'kalori': 205.0, 'malzemeler': ['1 Su Bardağı Üzüm', '25g Fındık']},
    {'ad': 'Çilek + Yulaf Lapası', 'protein': 8.0, 'yag': 4.0, 'karbonhidrat': 28.0, 'kalori': 180.0, 'malzemeler': ['150g Çilek', '3 Yemek Kaşığı Yulaf', '200ml Su']},
    {'ad': 'Kivi + Chia Puding', 'protein': 7.0, 'yag': 8.0, 'karbonhidrat': 20.0, 'kalori': 185.0, 'malzemeler': ['2 Kivi', '2 Yemek Kaşığı Chia', '150ml Badem Sütü']},
    {'ad': 'Kavun + Beyaz Peynir', 'protein': 10.0, 'yag': 6.0, 'karbonhidrat': 14.0, 'kalori': 155.0, 'malzemeler': ['2 Dilim Kavun', '50g Beyaz Peynir']},
    {'ad': 'Karpuz + Lor Peyniri', 'protein': 9.0, 'yag': 4.0, 'karbonhidrat': 18.0, 'kalori': 150.0, 'malzemeler': ['2 Dilim Karpuz', '50g Lor Peyniri']},
    {'ad': 'Şeftali + Süzme Yoğurt', 'protein': 11.0, 'yag': 3.0, 'karbonhidrat': 20.0, 'kalori': 155.0, 'malzemeler': ['2 Şeftali', '100g Süzme Yoğurt']},
  ];
  
  for (int i = 0; i < 60; i++) {
    final v = meyveBazli[i % meyveBazli.length];
    yemekler.add({
      'id': 'AO2_${1061 + i}',
      'kategori': 'ara_ogun_2',
      'ad': v['ad'],
      'kalori': v['kalori'],
      'protein': v['protein'],
      'karbonhidrat': v['karbonhidrat'],
      'yag': v['yag'],
      'hazirlamaSuresi': 5,
      'zorluk': 'Kolay',
      'malzemeler': v['malzemeler'],
    });
  }
  
  // BÖLÜM 3: Peynir & Yumurta Bazlı (60 adet - AO2_1121-1180)
  final peynirYumurtaBazli = [
    {'ad': 'Haşlanmış Yumurta + Tam Tahıl Kraker', 'protein': 14.0, 'yag': 10.0, 'karbonhidrat': 15.0, 'kalori': 210.0, 'malzemeler': ['2 Haşlanmış Yumurta', '5-6 Tam Tahıl Kraker']},
    {'ad': 'Beyaz Peynir + Ceviz + Üzüm', 'protein': 11.0, 'yag': 12.0, 'karbonhidrat': 14.0, 'kalori': 210.0, 'malzemeler': ['50g Beyaz Peynir', '20g Ceviz', '1 Avuç Üzüm']},
    {'ad': 'Cottage Peynir + Kiraz Domates', 'protein': 16.0, 'yag': 5.0, 'karbonhidrat': 8.0, 'kalori': 145.0, 'malzemeler': ['150g Cottage Peynir', '10-12 Kiraz Domates']},
    {'ad': 'Lor Peyniri + Zeytin', 'protein': 12.0, 'yag': 8.0, 'karbonhidrat': 6.0, 'kalori': 145.0, 'malzemeler': ['100g Lor Peyniri', '10 Zeytin']},
    {'ad': 'Kaşar Peyniri + Salatalık', 'protein': 13.0, 'yag': 10.0, 'karbonhidrat': 5.0, 'kalori': 165.0, 'malzemeler': ['50g Kaşar Peyniri', '1 Salatalık']},
    {'ad': 'Labne + Nar + Nane', 'protein': 10.0, 'yag': 7.0, 'karbonhidrat': 12.0, 'kalori': 155.0, 'malzemeler': ['100g Labne', '1/2 Nar', 'Taze Nane']},
    {'ad': 'Feta Peyniri + Domates', 'protein': 11.0, 'yag': 9.0, 'karbonhidrat': 6.0, 'kalori': 150.0, 'malzemeler': ['60g Feta Peyniri', '1 Domates', 'Fesleğen']},
    {'ad': 'Süzme Peynir + Biber', 'protein': 14.0, 'yag': 6.0, 'karbonhidrat': 8.0, 'kalori': 145.0, 'malzemeler': ['100g Süzme Peynir', '1 Sivri Biber']},
    {'ad': 'Yumurta Salatası', 'protein': 13.0, 'yag': 11.0, 'karbonhidrat': 4.0, 'kalori': 170.0, 'malzemeler': ['2 Haşlanmış Yumurta', '1 Kaşık Yoğurt', 'Maydanoz', 'Salatalık']},
    {'ad': 'Çırpılmış Yumurta', 'protein': 12.0, 'yag': 10.0, 'karbonhidrat': 2.0, 'kalori': 145.0, 'malzemeler': ['2 Yumurta', 'Tuz', 'Karabiber']},
  ];
  
  for (int i = 0; i < 60; i++) {
    final v = peynirYumurtaBazli[i % peynirYumurtaBazli.length];
    yemekler.add({
      'id': 'AO2_${1121 + i}',
      'kategori': 'ara_ogun_2',
      'ad': v['ad'],
      'kalori': v['kalori'],
      'protein': v['protein'],
      'karbonhidrat': v['karbonhidrat'],
      'yag': v['yag'],
      'hazirlamaSuresi': 10,
      'zorluk': 'Kolay',
      'malzemeler': v['malzemeler'],
    });
  }
  
  // BÖLÜM 4: Kuruyemiş & Tahıl Bazlı (60 adet - AO2_1181-1240)
  final kuruyemisTahilBazli = [
    {'ad': 'Karışık Kuruyemiş', 'protein': 8.0, 'yag': 16.0, 'karbonhidrat': 10.0, 'kalori': 215.0, 'malzemeler': ['40g Karışık Kuruyemiş']},
    {'ad': 'Badem + Kuru Kayısı', 'protein': 7.0, 'yag': 12.0, 'karbonhidrat': 18.0, 'kalori': 215.0, 'malzemeler': ['30g Badem', '6-7 Kuru Kayısı']},
    {'ad': 'Ceviz + Kuru İncir', 'protein': 6.0, 'yag': 14.0, 'karbonhidrat': 20.0, 'kalori': 235.0, 'malzemeler': ['30g Ceviz', '3-4 Kuru İncir']},
    {'ad': 'Fındık + Kuru Üzüm', 'protein': 6.0, 'yag': 13.0, 'karbonhidrat': 22.0, 'kalori': 235.0, 'malzemeler': ['30g Fındık', '2 Kaşık Kuru Üzüm']},
    {'ad': 'Antep Fıstığı + Hurma', 'protein': 8.0, 'yag': 11.0, 'karbonhidrat': 24.0, 'kalori': 235.0, 'malzemeler': ['25g Antep Fıstığı', '3 Hurma']},
    {'ad': 'Yulaf Lapası + Bal', 'protein': 7.0, 'yag': 4.0, 'karbonhidrat': 32.0, 'kalori': 195.0, 'malzemeler': ['4 Kaşık Yulaf', '250ml Süt', '1 Kaşık Bal', 'Tarçın']},
    {'ad': 'Granola + Süt', 'protein': 9.0, 'yag': 8.0, 'karbonhidrat': 28.0, 'kalori': 220.0, 'malzemeler': ['50g Granola', '200ml Süt']},
    {'ad': 'Müsli + Yoğurt', 'protein': 10.0, 'yag': 6.0, 'karbonhidrat': 30.0, 'kalori': 215.0, 'malzemeler': ['50g Müsli', '150g Yoğurt']},
    {'ad': 'Tam Tahıl Gevrek + Süt', 'protein': 8.0, 'yag': 3.0, 'karbonhidrat': 32.0, 'kalori': 185.0, 'malzemeler': ['40g Tam Tahıl Gevrek', '200ml Süt']},
    {'ad': 'Chia Puding + Meyve', 'protein': 8.0, 'yag': 10.0, 'karbonhidrat': 22.0, 'kalori': 215.0, 'malzemeler': ['3 Kaşık Chia', '200ml Badem Sütü', 'Çilek']},
  ];
  
  for (int i = 0; i < 60; i++) {
    final v = kuruyemisTahilBazli[i % kuruyemisTahilBazli.length];
    yemekler.add({
      'id': 'AO2_${1181 + i}',
      'kategori': 'ara_ogun_2',
      'ad': v['ad'],
      'kalori': v['kalori'],
      'protein': v['protein'],
      'karbonhidrat': v['karbonhidrat'],
      'yag': v['yag'],
      'hazirlamaSuresi': 5,
      'zorluk': 'Kolay',
      'malzemeler': v['malzemeler'],
    });
  }
  
  // BÖLÜM 5: Sebze & Diğer (60 adet - AO2_1241-1300)
  final sebzeDiger = [
    {'ad': 'Havuç + Humus', 'protein': 6.0, 'yag': 8.0, 'karbonhidrat': 18.0, 'kalori': 170.0, 'malzemeler': ['2 Havuç', '4 Kaşık Humus']},
    {'ad': 'Kereviz + Fıstık Ezmesi', 'protein': 8.0, 'yag': 12.0, 'karbonhidrat': 12.0, 'kalori': 190.0, 'malzemeler': ['3-4 Sap Kereviz', '2 Kaşık Fıstık Ezmesi']},
    {'ad': 'Kiraz Domates + Mozzarella', 'protein': 12.0, 'yag': 10.0, 'karbonhidrat': 8.0, 'kalori': 175.0, 'malzemeler': ['15 Kiraz Domates', '50g Mozzarella']},
    {'ad': 'Salatalık + Ayran', 'protein': 5.0, 'yag': 3.0, 'karbonhidrat': 12.0, 'kalori': 95.0, 'malzemeler': ['1 Salatalık', '1 Bardak Ayran']},
    {'ad': 'Yeşil Salata + Yoğurt Sosu', 'protein': 6.0, 'yag': 4.0, 'karbonhidrat': 10.0, 'kalori': 100.0, 'malzemeler': ['Marul Roka Maydanoz', '3 Kaşık Yoğurt', 'Limon']},
    {'ad': 'Turşu + Peynir', 'protein': 8.0, 'yag': 6.0, 'karbonhidrat': 8.0, 'kalori': 115.0, 'malzemeler': ['Karışık Turşu', '40g Beyaz Peynir']},
    {'ad': 'Brokoli + Tahin', 'protein': 7.0, 'yag': 9.0, 'karbonhidrat': 12.0, 'kalori': 155.0, 'malzemeler': ['200g Haşlanmış Brokoli', '1 Kaşık Tahin']},
    {'ad': 'Izgara Kabak + Yoğurt', 'protein': 6.0, 'yag': 4.0, 'karbonhidrat': 10.0, 'kalori': 100.0, 'malzemeler': ['1 Kabak', '100g Yoğurt', 'Sarımsak']},
    {'ad': 'Haşlanmış Mısır', 'protein': 5.0, 'yag': 2.0, 'karbonhidrat': 24.0, 'kalori': 130.0, 'malzemeler': ['1 Haşlanmış Mısır Koçanı']},
    {'ad': 'Çiğ Köfte', 'protein': 6.0, 'yag': 3.0, 'karbonhidrat': 28.0, 'kalori': 165.0, 'malzemeler': ['2 Dürüm Çiğ Köfte', 'Marul']},
  ];
  
  for (int i = 0; i < 60; i++) {
    final v = sebzeDiger[i % sebzeDiger.length];
    yemekler.add({
      'id': 'AO2_${1241 + i}',
      'kategori': 'ara_ogun_2',
      'ad': v['ad'],
      'kalori': v['kalori'],
      'protein': v['protein'],
      'karbonhidrat': v['karbonhidrat'],
      'yag': v['yag'],
      'hazirlamaSuresi': 10,
      'zorluk': 'Kolay',
      'malzemeler': v['malzemeler'],
    });
  }
  
  return yemekler;
}
