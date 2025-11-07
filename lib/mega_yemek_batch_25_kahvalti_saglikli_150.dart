// ============================================================================
// 150 SAĞLIKLI KAHVALTI - DİNAMİK MAL ZEME BAZLI İSİMLENDİRME
// ============================================================================
// 🎯 MAKRO BAZLI DİNAMİK SİSTEM:
// - Her yemek makro değerlerine göre otomatik isimlendirilir
// - Malzemeler temel alınarak anlamlı isimler oluşturulur
// - Sağlıklı, zararsız, dengeli kahvaltılar
// ============================================================================

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🍳 150 Sağlıklı Kahvaltı Oluşturuluyor...\n');
  
  final kahvaltilar = <Map<String, dynamic>>[];
  int idCounter = 1;

  // ========================================================================
  // KATEGORİ 1: YÜKSEK PROTEİN KAHVALTILAR (30 adet)
  // ========================================================================
  print('📊 Kategori 1: Yüksek Protein Kahvaltılar (30 adet)');
  
  // Yumurta bazlı - yüksek protein
  final yumurtaProteinKahvaltilar = [
    {
      'malzemeler': ['Yumurta (3 adet, haşlanmış)', 'Lor Peyniri (50g)', 'Tam Buğday Ekmeği (1 dilim)', 'Domates (1 adet)', 'Salatalık (1 adet)'],
      'protein': 28, 'karb': 25, 'yag': 12, 'kalori': 320,
    },
    {
      'malzemeler': ['Omlet (3 yumurta)', 'Beyaz Peynir (50g)', 'Yeşil Biber (1 adet)', 'Domates (1 adet)', 'Zeytin (10 adet)'],
      'protein': 30, 'karb': 8, 'yag': 20, 'kalori': 340,
    },
    {
      'malzemeler': ['Menemen (3 yumurta)', 'Tam Buğday Ekmeği (1 dilim)', 'Ezine Peyniri (30g)', 'Roka Salatası'],
      'protein': 27, 'karb': 22, 'yag': 18, 'kalori': 350,
    },
    {
      'malzemeler': ['Yumurta (2 adet, sahanda)', 'Sucuk (40g, yağsız)', 'Tam Buğday Ekmeği (1 dilim)', 'Domates (1 adet)'],
      'protein': 26, 'karb': 20, 'yag': 22, 'kalori': 380,
    },
    {
      'malzemeler': ['Çılbır (2 yumurta, yoğurt soslu)', 'Yoğurt (100g)', 'Tereyağı (5g)', 'Sumak'],
      'protein': 24, 'karb': 12, 'yag': 14, 'kalori': 280,
    },
    {
      'malzemeler': ['Yumurta (3 adet, haşlanmış)', 'Avokado (yarım)', 'Tam Buğday Ekmeği (1 dilim)', 'Cherry Domates (5 adet)'],
      'protein': 25, 'karb': 28, 'yag': 18, 'kalori': 370,
    },
    {
      'malzemeler': ['Ispanaklı Omlet (3 yumurta)', 'Feta Peyniri (40g)', 'Tam Buğday Ekmeği (1 dilim)'],
      'protein': 29, 'karb': 20, 'yag': 16, 'kalori': 340,
    },
    {
      'malzemeler': ['Yumurta (2 adet)', 'Somon (füme, 50g)', 'Cream Cheese (20g)', 'Tam Buğday Ekmeği (1 dilim)'],
      'protein': 32, 'karb': 18, 'yag': 15, 'kalori': 350,
    },
    {
      'malzemeler': ['Shakshuka (2 yumurta)', 'Domates Sosu (100g)', 'Ezine Peyniri (30g)', 'Maydanoz'],
      'protein': 26, 'karb': 15, 'yag': 17, 'kalori': 320,
    },
    {
      'malzemeler': ['Yumurta (3 adet)', 'Mantar (100g, sote)', 'Kaşar Peyniri (30g)', 'Tam Buğday Ekmeği (1 dilim)'],
      'protein': 28, 'karb': 22, 'yag': 16, 'kalori': 345,
    },
  ];

  for (var data in yumurtaProteinKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_yp_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['yüksek protein', 'sağlıklı', 'kahvaltı'],
    ));
  }

  // Süzme yoğurt bazlı - yüksek protein
  final yogurtProteinKahvaltilar = [
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Chia Tohumu (15g)', 'Badem (30g)', 'Çilek (100g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 24, 'karb': 35, 'yag': 14, 'kalori': 360,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Yulaf (40g)', 'Ceviz (20g)', 'Muz (1 adet)', 'Tarçın'],
      'protein': 22, 'karb': 42, 'yag': 12, 'kalori': 370,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Granola (30g)', 'Böğürtlen (80g)', 'Keten Tohumu (10g)'],
      'protein': 23, 'karb': 38, 'yag': 10, 'kalori': 340,
    },
    {
      'malzemeler': ['Protein Yoğurt (200g)', 'Hurma (3 adet)', 'Badem Ezmesi (20g)', 'Kakao Tozu (5g)'],
      'protein': 26, 'karb': 40, 'yag': 11, 'kalori': 365,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Yaban Mersini (100g)', 'Fındık (25g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 22, 'karb': 36, 'yag': 13, 'kalori': 350,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Kinoa Gevreği (30g)', 'Kivi (1 adet)', 'Chia Tohumu (10g)'],
      'protein': 24, 'karb': 34, 'yag': 9, 'kalori': 330,
    },
    {
      'malzemeler': ['Protein Yoğurt (200g)', 'Karabuğday Gevreği (30g)', 'Ahududu (80g)', 'Badem (20g)'],
      'protein': 25, 'karb': 37, 'yag': 11, 'kalori': 355,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Yulaf Kepeği (30g)', 'Elma (1 adet, dilimlenmiş)', 'Ceviz (20g)', 'Tarçın'],
      'protein': 23, 'karb': 39, 'yag': 12, 'kalori': 360,
    },
    {
      'malzemeler': ['Süzme Yoğurt (200g)', 'Quinoa Patlağı (30g)', 'Mango (80g)', 'Kaju (20g)'],
      'protein': 22, 'karb': 41, 'yag': 10, 'kalori': 350,
    },
    {
      'malzemeler': ['Protein Yoğurt (200g)', 'Chia Puding', 'Frambuaz (80g)', 'Fındık (20g)', 'Stevia'],
      'protein': 26, 'karb': 32, 'yag': 13, 'kalori': 345,
    },
  ];

  for (var data in yogurtProteinKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_yp_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['yüksek protein', 'sağlıklı', 'probiyotik'],
    ));
  }

  // Lor peyniri bazlı - yüksek protein
  final lorProteinKahvaltilar = [
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Çavdar Ekmeği (2 dilim)', 'Domates (1 adet)', 'Roka', 'Zeytin (8 adet)'],
      'protein': 24, 'karb': 30, 'yag': 12, 'kalori': 340,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Yulaf Ekmeği (2 dilim)', 'Salatalık (1 adet)', 'Taze Nane', 'Ceviz (15g)'],
      'protein': 25, 'karb': 32, 'yag': 14, 'kalori': 360,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Siyah Ekmek (2 dilim)', 'Avokado (yarım)', 'Cherry Domates (5 adet)'],
      'protein': 23, 'karb': 35, 'yag': 18, 'kalori': 385,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Kepekli Ekmek (2 dilim)', 'Biber (1 adet)', 'Maydanoz', 'Zeytin (10 adet)'],
      'protein': 24, 'karb': 28, 'yag': 13, 'kalori': 335,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Tam Buğday Ekmeği (2 dilim)', 'Ispanak (taze, 50g)', 'Domates (1 adet)'],
      'protein': 26, 'karb': 30, 'yag': 11, 'kalori': 330,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Quinoa Ekmeği (2 dilim)', 'Roka', 'Havuç (1 adet, rendelenmiş)', 'Badem (15g)'],
      'protein': 25, 'karb': 33, 'yag': 15, 'kalori': 365,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Chia Ekmeği (2 dilim)', 'Domates (1 adet)', 'Taze Fesleğen', 'Zeytin (8 adet)'],
      'protein': 26, 'karb': 29, 'yag': 14, 'kalori': 350,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Tam Tahıllı Ekmek (2 dilim)', 'Yeşil Biber (1 adet)', 'Ceviz (20g)'],
      'protein': 25, 'karb': 31, 'yag': 16, 'kalori': 370,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Karabuğday Ekmeği (2 dilim)', 'Salatalık (1 adet)', 'Dereotu', 'Zeytin (10 adet)'],
      'protein': 24, 'karb': 32, 'yag': 13, 'kalori': 345,
    },
    {
      'malzemeler': ['Lor Peyniri (100g)', 'Yulaf Kepeği Ekmeği (2 dilim)', 'Domates (1 adet)', 'Roka', 'Fındık (20g)'],
      'protein': 27, 'karb': 30, 'yag': 17, 'kalori': 375,
    },
  ];

  for (var data in lorProteinKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_yp_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['yüksek protein', 'düşük yağ', 'sağlıklı'],
    ));
  }

  // ========================================================================
  // KATEGORİ 2: DENGEL İ MAKRO KAHVALTILAR (50 adet)
  // ========================================================================
  print('📊 Kategori 2: Dengeli Makro Kahvaltılar (50 adet)');
  
  // Klasik Türk kahvaltısı - dengeli
  final klasikDengeliKahvaltilar = [
    {
      'malzemeler': ['Beyaz Peynir (50g)', 'Yumurta (2 adet, haşlanmış)', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Zeytin (10 adet)'],
      'protein': 20, 'karb': 35, 'yag': 15, 'kalori': 360,
    },
    {
      'malzemeler': ['Kaşar Peyniri (40g)', 'Yumurta (1 adet)', 'Çavdar Ekmeği (2 dilim)', 'Yeşil Biber (1 adet)', 'Domates (1 adet)', 'Zeytin (8 adet)'],
      'protein': 18, 'karb': 38, 'yag': 14, 'kalori': 350,
    },
    {
      'malzemeler': ['Ezine Peyniri (50g)', 'Simit (1 adet)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Yeşil Biber (1 adet)'],
      'protein': 16, 'karb': 42, 'yag': 12, 'kalori': 340,
    },
    {
      'malzemeler': ['Labne (80g)', 'Tam Buğday Ekmeği (2 dilim)', 'Zeytin (12 adet)', 'Domates (1 adet)', 'Salatalık (1 adet)'],
      'protein': 18, 'karb': 36, 'yag': 16, 'kalori': 355,
    },
    {
      'malzemeler': ['Beyaz Peynir (40g)', 'Reçel (ev yapımı, 30g)', 'Tam Tahıllı Ekmek (2 dilim)', 'Tereyağı (10g)'],
      'protein': 14, 'karb': 45, 'yag': 13, 'kalori': 350,
    },
    {
      'malzemeler': ['Taze Kaşar (40g)', 'Bal (1 yemek kaşığı)', 'Çavdar Ekmeği (2 dilim)', 'Ceviz (20g)'],
      'protein': 16, 'karb': 40, 'yag': 18, 'kalori': 380,
    },
    {
      'malzemeler': ['Süzme Peynir (60g)', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Biber (1 adet)', 'Zeytin (10 adet)'],
      'protein': 19, 'karb': 34, 'yag': 14, 'kalori': 345,
    },
    {
      'malzemeler': ['Feta Peyniri (50g)', 'Kuru İncir (3 adet)', 'Kepekli Ekmek (2 dilim)', 'Ceviz (15g)'],
      'protein': 15, 'karb': 43, 'yag': 16, 'kalori': 370,
    },
    {
      'malzemeler': ['Tulum Peyniri (40g)', 'Tahin (20g)', 'Pekmez (20g)', 'Tam Buğday Ekmeği (2 dilim)'],
      'protein': 17, 'karb': 38, 'yag': 19, 'kalori': 385,
    },
    {
      'malzemeler': ['Çökelek (80g)', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Yeşil Biber (1 adet)', 'Maydanoz'],
      'protein': 18, 'karb': 35, 'yag': 10, 'kalori': 315,
    },
  ];

  for (var data in klasikDengeliKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_db_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['dengeli', 'sağlıklı', 'türk mutfağı'],
    ));
  }

  // Yulaf bazlı - dengeli
  final yulafDengeliKahvaltilar = [
    {
      'malzemeler': ['Yulaf (50g)', 'Süt (200ml)', 'Muz (1 adet)', 'Badem (20g)', 'Tarçın'],
      'protein': 15, 'karb': 48, 'yag': 12, 'kalori': 360,
    },
    {
      'malzemeler': ['Overnight Oats (yulaf 50g)', 'Yoğurt (100g)', 'Çilek (100g)', 'Chia Tohumu (10g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 16, 'karb': 45, 'yag': 10, 'kalori': 340,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Badem Sütü (200ml)', 'Yaban Mersini (80g)', 'Ceviz (20g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 14, 'karb': 50, 'yag': 13, 'kalori': 370,
    },
    {
      'malzemeler': ['Yulaf Lapası (50g)', 'Süt (200ml)', 'Elma (1 adet, rendelenmiş)', 'Tarçın', 'Badem (20g)'],
      'protein': 16, 'karb': 47, 'yag': 12, 'kalori': 360,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Kefir (200ml)', 'Frambuaz (80g)', 'Fındık (20g)', 'Keten Tohumu (10g)'],
      'protein': 17, 'karb': 44, 'yag': 14, 'kalori': 365,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Süzme Yoğurt (100g)', 'Kayısı (kuru, 5 adet)', 'Ceviz (20g)', 'Tarçın'],
      'protein': 18, 'karb': 46, 'yag': 13, 'kalori': 370,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Hindistan Cevizi Sütü (200ml)', 'Mango (80g)', 'Chia Tohumu (10g)'],
      'protein': 12, 'karb': 52, 'yag': 11, 'kalori': 350,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Süt (200ml)', 'Hurma (3 adet)', 'Badem Ezmesi (20g)', 'Kakao Tozu (5g)'],
      'protein': 15, 'karb': 50, 'yag': 14, 'kalori': 380,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Yoğurt (100g)', 'Böğürtlen (80g)', 'Fındık (20g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 16, 'karb': 45, 'yag': 13, 'kalori': 355,
    },
    {
      'malzemeler': ['Yulaf (50g)', 'Badem Sütü (200ml)', 'Kivi (1 adet)', 'Chia Tohumu (10g)', 'Ceviz (15g)'],
      'protein': 14, 'karb': 48, 'yag': 12, 'kalori': 350,
    },
  ];

  for (var data in yulafDengeliKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_db_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['dengeli', 'yulaf', 'lif açısından zengin'],
    ));
  }

  // Menemen ve benzeri sıcak kahvaltılar - dengeli
  final sicakDengeliKahvaltilar = [
    {
      'malzemeler': ['Menemen (2 yumurta)', 'Tam Buğday Ekmeği (2 dilim)', 'Beyaz Peynir (30g)'],
      'protein': 20, 'karb': 32, 'yag': 16, 'kalori': 350,
    },
    {
      'malzemeler': ['Ispanaklı Börek (2 dilim, fırın)', 'Yoğurt (100g)', 'Salatalık (1 adet)'],
      'protein': 16, 'karb': 40, 'yag': 14, 'kalori': 345,
    },
    {
      'malzemeler': ['Gözleme (peynirli, 1 adet)', 'Ayran (200ml)', 'Domates (1 adet)'],
      'protein': 18, 'karb': 42, 'yag': 13, 'kalori': 355,
    },
    {
      'malzemeler': ['Sütlü Haşlanmış Yumurta (2 adet)', 'Tam Buğday Ekmeği (2 dilim)', 'Zeytin (10 adet)', 'Domates (1 adet)'],
      'protein': 18, 'karb': 34, 'yag': 15, 'kalori': 340,
    },
    {
      'malzemeler': ['Sebzeli Omlet (2 yumurta)', 'Siyah Ekmek (2 dilim)', 'Avokado (yarım)'],
      'protein': 19, 'karb': 36, 'yag': 18, 'kalori': 370,
    },
    {
      'malzemeler': ['Peynirli Tost (tam buğday)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Turşu'],
      'protein': 17, 'karb': 38, 'yag': 14, 'kalori': 345,
    },
    {
      'malzemeler': ['Beyaz Peynirli Gözleme (1 adet)', 'Ayran (200ml)', 'Yeşil Biber (1 adet)'],
      'protein': 19, 'karb': 40, 'yag': 12, 'kalori': 345,
    },
    {
      'malzemeler': ['Patatesli Börek (2 dilim, fırın)', 'Yoğurt (100g)', 'Maydanoz Salatası'],
      'protein': 14, 'karb': 44, 'yag': 13, 'kalori': 350,
    },
    {
      'malzemeler': ['Sütlü Menemen (2 yumurta)', 'Çavdar Ekmeği (2 dilim)', 'Ezine Peyniri (30g)'],
      'protein': 21, 'karb': 33, 'yag': 15, 'kalori': 355,
    },
    {
      'malzemeler': ['Kıymalı Yumurta (2 yumurta, dana kıyma 30g)', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)'],
      'protein': 24, 'karb': 32, 'yag': 16, 'kalori': 370,
    },
  ];

  for (var data in sicakDengeliKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_db_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['dengeli', 'sıcak', 'sağlıklı'],
    ));
  }

  // Smoothie bowl ve modern kahvaltılar - dengeli
  final modernDengeliKahvaltilar = [
    {
      'malzemeler': ['Smoothie Bowl (yaban mersini, muz)', 'Granola (30g)', 'Chia Tohumu (10g)', 'Badem (20g)'],
      'protein': 14, 'karb': 50, 'yag': 13, 'kalori': 370,
    },
    {
      'malzemeler': ['Açai Bowl', 'Muz (1 adet)', 'Granola (30g)', 'Hindistan Cevizi (15g)', 'Yaban Mersini (50g)'],
      'protein': 12, 'karb': 52, 'yag': 12, 'kalori': 360,
    },
    {
      'malzemeler': ['Protein Pancake (yulaf 40g, yumurta 2)', 'Yaban Mersini (80g)', 'Tahin (15g)', 'Pekmez (15g)'],
      'protein': 20, 'karb': 42, 'yag': 14, 'kalori': 370,
    },
    {
      'malzemeler': ['Avokado Toast (tam buğday ekmeği)', 'Poşe Yumurta (1 adet)', 'Cherry Domates (5 adet)', 'Susam'],
      'protein': 16, 'karb': 34, 'yag': 18, 'kalori': 360,
    },
    {
      'malzemeler': ['Chia Puding (chia 30g, badem sütü)', 'Mango (80g)', 'Hindistan Cevizi (15g)', 'Granola (20g)'],
      'protein': 13, 'karb': 48, 'yag': 14, 'kalori': 355,
    },
    {
      'malzemeler': ['Protein Waffle (yulaf 40g, yumurta 2)', 'Çilek (100g)', 'Yoğurt (50g)', 'Bal (1 tatlı kaşığı)'],
      'protein': 19, 'karb': 44, 'yag': 12, 'kalori': 360,
    },
    {
      'malzemeler': ['Quinoa Bowl', 'Yumurta (1 adet, haşlanmış)', 'Avokado (yarım)', 'Domates (1 adet)', 'Taze Fesleğen'],
      'protein': 18, 'karb': 38, 'yag': 16, 'kalori': 365,
    },
    {
      'malzemeler': ['Yeşil Smoothie Bowl (ıspanak, muz)', 'Granola (30g)', 'Badem (20g)', 'Kivi (1 adet)'],
      'protein': 13, 'karb': 49, 'yag': 13, 'kalori': 355,
    },
    {
      'malzemeler': ['Fıstık Ezmeli Toast (tam buğday)', 'Muz (1 adet)', 'Chia Tohumu (10g)', 'Tarçın'],
      'protein': 15, 'karb': 46, 'yag': 14, 'kalori': 360,
    },
    {
      'malzemeler': ['Ricotta Peyniri (80g)', 'Tam Buğday Ekmeği (2 dilim)', 'İncir (taze, 3 adet)', 'Bal (1 tatlı kaşığı)', 'Ceviz (15g)'],
      'protein': 17, 'karb': 45, 'yag': 15, 'kalori': 375,
    },
  ];

  for (var data in modernDengeliKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_db_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['dengeli', 'modern', 'sağlıklı'],
    ));
  }

  // Vegan/Vejetaryen opsiyonlar - dengeli
  final veganDengeliKahvaltilar = [
    {
      'malzemeler': ['Tofu Scramble (100g)', 'Tam Buğday Ekmeği (2 dilim)', 'Avokado (yarım)', 'Domates (1 adet)'],
      'protein': 18, 'karb': 38, 'yag': 16, 'kalori': 365,
    },
    {
      'malzemeler': ['Humus (100g)', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Zeytin (10 adet)'],
      'protein': 15, 'karb': 42, 'yag': 14, 'kalori': 350,
    },
    {
      'malzemeler': ['Badem Süt (200ml)', 'Yulaf (50g)', 'Chia Tohumu (15g)', 'Muz (1 adet)', 'Ceviz (20g)'],
      'protein': 14, 'karb': 48, 'yag': 16, 'kalori': 375,
    },
    {
      'malzemeler': ['Ezme (Acuka)', 'Tam Buğday Ekmeği (2 dilim)', 'Zeytin (12 adet)', 'Yeşil Biber (1 adet)', 'Ceviz (20g)'],
      'protein': 12, 'karb': 40, 'yag': 18, 'kalori': 360,
    },
    {
      'malzemeler': ['Badem Ezmesi (30g)', 'Tam Buğday Ekmeği (2 dilim)', 'Muz (1 adet)', 'Chia Tohumu (10g)'],
      'protein': 14, 'karb': 46, 'yag': 16, 'kalori': 370,
    },
    {
      'malzemeler': ['Tahin (30g)', 'Pekmez (30g)', 'Tam Buğday Ekmeği (2 dilim)', 'Ceviz (20g)'],
      'protein': 13, 'karb': 44, 'yag': 20, 'kalori': 390,
    },
    {
      'malzemeler': ['Soya Yoğurdu (200g)', 'Granola (30g)', 'Yaban Mersini (80g)', 'Keten Tohumu (10g)'],
      'protein': 15, 'karb': 45, 'yag': 12, 'kalori': 345,
    },
    {
      'malzemeler': ['Nohut Salatası', 'Tam Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Zeytin (10 adet)'],
      'protein': 16, 'karb': 46, 'yag': 14, 'kalori': 365,
    },
    {
      'malzemeler': ['Mercimek Buğday Ekmeği (2 dilim)', 'Domates (1 adet)', 'Yeşil Biber (1 adet)', 'Maydanoz'],
      'protein': 17, 'karb': 44, 'yag': 12, 'kalori': 350,
    },
    {
      'malzemeler': ['Quinoa Salatası', 'Nohut (50g)', 'Avokado (yarım)', 'Domates (1 adet)', 'Salatalık (1 adet)'],
      'protein': 16, 'karb': 42, 'yag': 15, 'kalori': 360,
    },
  ];

  for (var data in veganDengeliKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: 'saglikli_kahvalti_db_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: data['yag'] as int,
      kalori: data['kalori'] as int,
      etiketler: ['dengeli', 'vegan', 'bitkisel protein'],
    ));
  }

  // ========================================================================
  // KATEGORİ 3: DÜŞÜK KALORİLİ KAHVALTILAR (35 adet)
  // ========================================================================
  print('📊 Kategori 3: Düşük Kalorili Kahvaltılar (35 adet)');
  
  // Hafif kahvaltılar
  final dusukKaloriKahvaltilar = [
    {
      'malzemeler': ['Süzme Yoğurt (150g)', 'Çilek (100g)', 'Bal (1 tatlı kaşığı)', 'Tarçın'],
      'protein': 15, 'karb': 25, 'yag': 3, 'kalori': 185,
    },
    {
      'malzemeler': ['Yumurta Beyazı Omleti (4 adet beyaz)', 'Ispanak (50g)', 'Domates (1 adet)', 'Mantar (50g)'],
      'protein': 18, 'karb': 8, 'yag': 2, 'kalori': 120,
    },
    {
      'malzemeler': ['Lor Peyniri (80g)', 'Tam Buğday Ekmeği (1 dilim)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Roka'],
      'protein': 16, 'karb': 18, 'yag': 5, 'kalori': 180,
    },
    {
      'malzemeler': ['Yoğurt (150g, %0 yağlı)', 'Yulaf (25g)', 'Yaban Mersini (60g)', 'Stevia'],
      'protein': 14, 'karb': 28, 'yag': 2, 'kalori': 180,
    },
    {
      'malzemeler': ['Haşlanmış Yumurta (2 adet)', 'Salatalık (1 adet)', 'Domates (1 adet)', 'Yeşil Biber (1 adet)'],
      'protein': 14, 'karb': 10, 'yag': 10, 'kalori': 180,
    },
    {
      'malzemeler': ['Cottage Cheese (100g)', 'Cherry Domates (10 adet)', 'Salatalık (1 adet)', 'Taze Fesleğen'],
      'protein': 15, 'karb': 8, 'yag': 4, 'kalori': 125,
    },
    {
      'malzemeler': ['Protein Yoğurt (150g)', 'Chia Tohumu (10g)', 'Frambuaz (60g)'],
      'protein': 18, 'karb': 20, 'yag': 4, 'kalori': 185,
    },
    {
      'malzemeler': ['Beyaz Peynir (40g, %15 yağlı)', 'Tam Buğday Ekmeği (1 dilim)', 'Domates (1 adet)', 'Roka', 'Zeytin (5 adet)'],
      'protein': 14, 'karb': 20, 'yag': 7, 'kalori': 195,
    },
    {
      'malzemeler': ['Lor Peyniri (80g)', 'Çavdar Ekmeği (1 dilim)', 'Salatalık (1 adet)', 'Taze Anladım. Nane'],
      'protein': Flutter 15, 'karb': 16, 'yag': bağımlılığı 5, 'kalori': olmadan 170,
    },
    {
      'malzemeler': ['Süzme Yoğurt çalışamıyor. (120g)', Direkt çözüme 'Yaban Mersini (80g)', 'Keten Tohumu geçiyorum:

1. (5g)'],
      'protein': 14, 'karb': **150 sağlıklı 22, 'yag': kahvaltı** 4, 'kalori': 175,
    },
    {
      'malzemeler': ['Yumurta ekleyeceğim
2. **Dinamik (1 adet)', isim oluşturucu** sistem 'Yumurta Beyazı kuracağım
3. (3 **Makro adet)', 'Domates (1 bazlı** adet)', otomatik ayarlama 'Yeşil Biber (1 adet)'],
      'protein': yapacağım

Önce 20, 'karb': 150 8, 'yag': 6, 'kalori': 165,
    },
    {
      'malzemeler': ['Protein yeni sağlıklı kahvaltı Puding JSON dosyası oluşturuyorum:

<write_to_file>
(kakao, 150g)', 'Çilek (80g)', 'Chia Tohumu (5g)'],
      'protein': 16, 'karb': 24, <path>assets/data/kahvalti_saglikli_150_guncel.json</path>
'yag': 3, 'kalori': <content>
180,
    [
  },
    {
    {
      'malzemeler': ['Yoğurt (150g, "meal_id": %2 yağlı)', 'Elma (1 adet, dilimlenmiş)', "kahvalti_saglikli_001",
    "meal_name": "Yulaf Ezmeli Protein 'Tarçın', 'Badem (10g)'],
      'protein': 12, 'karb': 28, 'yag': 6, 'kalori': 210,
    },
    {
      'malzemeler': ['Lor Peyniri (70g)', 'Tam Kahvaltısı",
    "category": "Kahvaltı",
    "meal_type": Tahıllı Kraker (5 adet)', 'Domates (1 adet)', 'Taze Fesleğen'],
      'protein': 14, 'karb': 20, 'yag': 6, 'kalori': 185,
    },
    {
      'malzemeler': ['Süzme Yoğurt (120g)', 'Böğürtlen (70g)', 'Keten Tohumu (5g)', 'Stevia'],
      'protein': 14, 'karb': 20, 'yag': 4, 'kalori': 170,
    },
    {
      'malzemeler': ['Haşlanmış Yumurta (2 adet)', 'Tam Buğday Ekmeği (1 dilim)', 'Domates (1 adet)'],
      'protein': 16, 'karb': 18, 'yag': 11, 'kalori': 230,
    },
    {
      'malzemeler': ['Protein Yoğurt (150g)', 'Kivi (1 adet)', 'Chia Tohumu (5g)'],
      'protein': 18, 'karb': 20, 'yag': 3, 'kalori': 175,
    },
    {
      'malzemeler': ['Beyaz Peynir (30g)', 'Yumurta (1 adet, haşlanmış)', 'Tam Buğday Ekmeği (1 dilim)', 'Salatalık (1 adet)'],
      'protein': 15, 'karb': 16, 'yag': 9, 'kalori': 200,
    },
    {
      'malzemeler': ['Lor Peyniri (80g)', 'Domates (1 adet)', 'Salatalık (1 adet)', 'Yeşil Biber (1 adet)', 'Maydanoz'],
      'protein': 14, 'karb': 10, 'yag': 5, 'kalori': 140,
    },
    {
      'malzemeler': ['Yoğurt (120g, %0 yağlı)', 'Yulaf (20g)', 'Ahududu (60g)'],
      'protein': 13, 'karb': 26, 'yag': 2, 'kalori': 170,
    },
    {
      'malzemeler': ['Yumurta Beyazı Omleti (5 adet beyaz)', 'Mantar (80g)', 'Ispanak (50g)', 'Cherry Domates (5 adet)'],
      'protein': 22, 'karb': 10, 'yag': 2, 'kalori': 145,
    },
    {
      'malzemeler': ['Cottage Cheese (80g)', 'Yaban Mersini (70g)', 'Keten Tohumu (5g)'],
      'protein': "kahvalti",
    "kalori": 350,
    "protein": 25,
    14, 'karb': 16, 'yag': "karbonhidrat": 45,
    4, 'kalori': "yag": 8,
    155,
    },
    {
      'malzemeler': "malzemeler": ["Yulaf ['Süzme Yoğurt Ezmesi (50g)", "Süzme (100g)', Yoğurt 'Çilek (150g)", (100g)', "Muz (1 adet)", 'Chia Tohumu "Bal (5g)', 'Stevia'],
      (1 tatlı 'protein': kaşığı)", "Ceviz 12, 'karb': (5 20, 'yag': adet)"],
    3, 'kalori': 150,
    },
    "hazirlamaSuresi": {
      'malzemeler': 10,
    "zorluk": ['Lor Peyniri "kolay",
    (60g)', 'Çavdar "etiketler": ["sağlıklı", Krispsi (3 adet)', 'Domates (1 adet)', "protein", "enerji"]
  },
  'Roka'],
      {
    "meal_id": 'protein': "kahvalti_saglikli_002",
    "meal_name": "Avokadolu Tam Buğday Ekmeği",
    "category": "Kahvaltı",
    "meal_type": 13, 'karb': "kahvalti",
    "kalori": 380,
    "protein": 18, 18,
    'yag': "karbonhidrat": 5, 'kalori': 42,
    "yag": 16,
    170,
    },
    "malzemeler": ["Tam {
      'malzemeler': ['Yumurta Buğday (1 Ekmeği (2 adet)', dilim)", "Avokado (1/2 adet)", "Poşe Yumurta (1 adet)", "Cherry Domates (5 adet)", "Tuz, Karabiber"],
    "hazirlamaSuresi": 12,
    "zorluk": "kolay",
    'Yumurta "etiketler": Beyazı (2 adet)', ["sağlıklı", 'Tam Buğday Ekmeği "avokado", (1 dilim)', 'Domates "protein"]
  (1 adet)'],
      },
  {
    'protein': 18, "meal_id": 'karb': 18, 'yag': 7, 'kalori': 200,
    "kahvalti_saglikli_003",
    "meal_name": },
    {
      'malzemeler': ['Protein Yoğurt (120g)', "Protein Smoothie 'Frambuaz Bowl",
    (60g)', "category": "Kahvaltı",
    "meal_type": 'Keten "kahvalti",
    "kalori": Tohumu (5g)'],
      320,
    "protein": 22,
    "karbonhidrat": 'protein': 16, 'karb': 48,
    "yag": 6,
    "malzemeler": 18, 'yag': ["Muz (1 adet)", 3, 'kalori': 160,
    },
    {
      'malzemeler': ['Beyaz Peynir (35g, %15 yağlı)', 'Tam Buğday "Yaban Ekmeği Mersini (100g)", "Protein (1 Tozu dilim)', (30g)", "Badem Sütü (200ml)", "Granola (30g)"],
    "hazirlamaSuresi": 'Salatalık 8,
    (1 "zorluk": "kolay",
    "etiketler": adet)', ["smoothie", "protein", "meyve"]
  },
  {
    "meal_id": 'Zeytin (5 "kahvalti_saglikli_004",
    "meal_name": adet)'],
      'protein': "Lor 13, 'karb': Peynirli 18, 'yag': Menemen",
    "category": "Kahvaltı",
    8, 'kalori': "meal_type": "kahvalti",
    190,
    "kalori": 295,
    },
    {
      "protein": 'malzemeler': 24,
    ['Lor "karbonhidrat": Peyniri (70g)', 18,
    "yag": 14,
    "malzemeler": 'Domates (1 adet)', ["Yumurta (2 adet)", 'Yeşil "Lor Biber (1 Peyniri (100g)", "Domates adet)', (2 adet)", 'Salatalık (1 "Biber adet)', (1 adet)", "Zeytinyağı (1 'Dereotu'],
      'protein': yemek kaşığı)"],
    "hazirlamaSuresi": 13, 'karb': 15,
    12, 'yag': "zorluk": "kolay",
    "etiketler": 5, 'kalori': ["protein", 145,
    },
    "geleneksel", {
      'malzemeler': "sağlıklı"]
  },
  {
    ['Süzme "meal_id": "kahvalti_saglikli_005",
    "meal_name": Yoğurt (100g)', 'Yaban Mersini "Chia (60g)', Pudingli 'Badem (10g)', Kahvaltı",
    "category": "Kahvaltı",
    "meal_type": 'Tarçın'],
      "kahvalti",
    "kalori": 'protein': 12, 'karb': 310,
    "protein": 18,
    "karbonhidrat": 20, 'yag': 6, 38,
    "yag": 'kalori': 12,
    "malzemeler": 175,
    ["Chia Tohumu },
    (30g)", {
      'malzemeler': "Badem Sütü (250ml)", "Muz (1 adet)", ['Haşlanmış "Fındık Yumurta Ezmesi (15g)", (2 adet)', "Bal (1 tatlı 'Domates (1 kaşığı)"],
    adet)', "hazirlamaSuresi": 5,
    "zorluk": "kolay",
    "etiketler": 'Salatalık (1 ["chia", adet)', "omega3", 'Taze "sağlıklı"]
  Nane'],
      },
  'protein': {
    "meal_id": "kahvalti_saglikli_006",
    14, 'karb': "meal_name": "Kinoa 8, 'yag': Kahvaltı 10, 'kalori': Tabağı",
    "category": "Kahvaltı",
    "meal_type": 175,
    },
    "kahvalti",
    "kalori": {
      'malzemeler': 340,
    "protein": ['Protein Yoğurt 20,
    "karbonhidrat": (130g)', 44,
    "yag": 'Böğürtlen 10,
    "malzemeler": ["Kinoa (60g)', (50g)", "Haşlanmış 'Chia Tohumu Yumurta (5g)'],
      'protein': (2 adet)", "Avokado 17, 'karb': (1/4 adet)", "Cherry Domates (5 adet)", 18, 'yag': "Taze 3, 'kalori': Maydanoz"],
    "hazirlamaSuresi": 165,
    },
    {
      'malzemeler': ['Yumurta 20,
    Beyazı "zorluk": "orta",
    "etiketler": ["kinoa", "protein", "gluten-free"]
  },
  Omleti {
    (4 "meal_id": adet beyaz)', "kahvalti_saglikli_007",
    "meal_name": "Süzme Yoğurtlu 'Domates (1 adet)', Meyve Kasesi",
    'Yeşil "category": Biber (1 adet)', "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": 'Mantar (50g)'],
      'protein': 285,
    "protein": 20,
    "karbonhidrat": 18, 'karb': 10, 'yag': 42,
    "yag": 2, 'kalori': 130,
    },
    4,
    {
      "malzemeler": 'malzemeler': ['Cottage ["Süzme Cheese Yoğurt (90g)', 'Çilek (200g)", (70g)', "Çilek 'Keten Tohumu (5g)'],
      'protein': 14, (100g)", 'karb': "Muz (1 adet)", "Bal 14, 'yag': (1 tatlı 4, 'kalori': 145,
    },
    {
      'malzemeler': ['Lor Peyniri kaşığı)", "Badem (10 (75g)', 'Tam adet)"],
    "hazirlamaSuresi": 5,
    Tahıllı Kraker (4 adet)', "zorluk": "kolay",
    'Salatalık "etiketler": (1 adet)', ["yoğurt", 'Taze "meyve", Fesleğen'],
      'protein': 14, 'karb': "antioksidan"]
  },
  {
    18, 'yag': "meal_id": 6, 'kalori': "kahvalti_saglikli_008",
    "meal_name": 175,
    },
    "Tam Buğday {
      'malzemeler': ['Yoğurt Pankek (120g, %0 yağlı)', 'Ahududu Stack",
    "category": "Kahvaltı",
    (70g)', "meal_type": 'Chia "kahvalti",
    Tohumu "kalori": (5g)', 'Stevia'],
      'protein': 13, 360,
    "protein": 'karb': 20, 16,
    'yag': 3, "karbonhidrat": 'kalori': 52,
    "yag": 155,
    },
  ];

  for (var data 10,
    in "malzemeler": ["Tam Buğday dusukKaloriKahvaltilar) {
    Unu kahvaltilar.add(_yemekOlustur(
      (80g)", id: "Yumurta 'saglikli_kahvalti_dk_${idCounter++}',
      malzemeler: (1 adet)", data['malzemeler'] as "Süt List<String>,
      protein: data['protein'] as int,
      karb: data['karb'] as int,
      yag: (100ml)", "Muz (1 adet)", data['yag'] as int,
      kalori: data['kalori'] "Yaban Mersini as int,
      etiketler: ['düşük kalori', 'diyet', 'sağlıklı'],
    ));
  (50g)"],
    "hazirlamaSuresi": }

  // 15,
    "zorluk": "orta",
    "etiketler": ========================================================================
  // KATEGORİ 4: YÜKSEK KALORİLİ/BULK KAHVALTILAR (35 adet)
  // ["pankek", ========================================================================
  "kahvaltı", "sağlıklı"]
  print('📊 },
  Kategori {
    "meal_id": "kahvalti_saglikli_009",
    "meal_name": "Izgara Sebzeli 4: Omlet",
    Yüksek "category": Kalorili/Bulk "Kahvaltı",
    Kahvaltılar (35 "meal_type": adet)');
  
  final "kahvalti",
    "kalori": 275,
    "protein": yuksekKaloriKahvaltilar = [
    {
      22,
    'malzemeler': "karbonhidrat": ['Yumurta 14,
    "yag": (4 15,
    adet)', 'Sucuk "malzemeler": (60g)', ["Yumurta 'Tam (3 Buğday adet)", Ekmeği "Mantar (3 dilim)', (50g)", 'Kaşar Peyniri "Ispanak (30g)", "Domates (1 adet)", (50g)', 'Domates (1 adet)'],
      "Beyaz Peynir 'protein': 38, 'karb': 45, 'yag': (30g)"],
    28, 'kalori': 580,
    },
    {
      'malzemeler': "hazirlamaSuresi": 12,
    "zorluk": ['Protein "kolay",
    "etiketler": Pancake ["omlet", (yulaf "sebze", 60g, yumurta "protein"]
  },
  {
    "meal_id": 3)', 'Fıstık "kahvalti_saglikli_010",
    "meal_name": "Fıstık Ezmesi (30g)', Ezmeli Muz 'Muz (1 adet)', 'Bal (2 yemek Dilim",
    "category": "Kahvaltı",
    kaşığı)'],
      "meal_type": 'protein': "kahvalti",
    "kalori": 32, 'karb': 68, 395,
    'yag': "protein": 20, 'kalori': 18,
    580,
    "karbonhidrat": },
    {
      48,
    'malzemeler': "yag": ['Yulaf (80g)', 16,
    'Tam "malzemeler": ["Tam Buğday Yağlı Süt Ekmeği (2 dilim)", "Fıstık Ezmesi (300ml)', (30g)", 'Muz "Muz (2 adet)', (1 adet)", "Bal 'Fıstık (1 tatlı Ezmesi kaşığı)", (30g)', 'Bal (1 "Chia Tohumu yemek (10g)"],
    kaşığı)'],
      "hazirlamaSuresi": 'protein': 24, 'karb': 5,
    95, 'yag': "zorluk": "kolay",
    22, "etiketler": 'kalori': 650,
    },
    {
      'malzemeler': ['Menemen ["fıstık-ezmesi", (4 "enerji", yumurta)', "pratik"]
  },
  {
    "meal_id": 'Kavurma (50g)', "kahvalti_saglikli_011",
    'Tam Buğday "meal_name": Ekmeği (3 dilim)', "Peynirli 'Beyaz Sebze Peynir (60g)'],
      'protein': Wrap",
    "category": 42, "Kahvaltı",
    'karb': 48, 'yag': "meal_type": 30, "kahvalti",
    'kalori': "kalori": 345,
    630,
    "protein": },
    {
      'malzemeler': ['Smoothie 19,
    "karbonhidrat": (muz 40,
    "yag": 12,
    2, yulaf "malzemeler": 50g, ["Tam fıstık Buğday Tortilla (1 ezmesi adet)", 30g, "Kaşar Peyniri süt 300ml)', (40g)", 'Hurma (5 adet)', 'Badem "Salatalık (1/2 adet)", "Domates (1 adet)", "Roka (30g)'],
      'protein': 26, 'karb': 105, 'yag': 28, 'kalori': (30g)"],
    750,
    },
    "hazirlamaSuresi": {
      'malzemeler': 8,
    "zorluk": "kolay",
    "etiketler": ['Yumurta ["wrap", "sebze", "pratik"]
  },
  (3 adet)', {
    'Pastırma "meal_id": (50g)', 'Kaşar Peyniri (60g)', 'Simit "kahvalti_saglikli_012",
    "meal_name": "Yeşil Smoothie (1 + adet)', 'Domates (1 adet)'],
      'protein': Yumurta",
    36, 'karb': "category": 52, 'yag': "Kahvaltı",
    "meal_type": 26, 'kalori': "kahvalti",
    580,
    },
    "kalori": 315,
    {
      'malzemeler': "protein": ['Protein 24,
    Waffle (yulaf "karbonhidrat": 60g, yumurta 32,
    3)', "yag": 10,
    "malzemeler": 'Badem ["Ispanak Ezmesi (30g)', 'Frambuaz (100g)', 'Akçaağaç (50g)", "Muz (1 adet)", "Badem Sütü (200ml)", "Haşlanmış Yumurta (2 adet)", Şurubu (30ml)'],
      'protein': 30, 'karb': 72, 'yag': 22, 'kalori': 600,
    },
    {
      'malzemeler': ['Sac "Bal (1 tatlı Kavurma kaşığı)"],
    "hazirlamaSuresi": (100g, 10,
    "zorluk": "kolay",
    "etiketler": ["smoothie", "detoks", "protein"]
  dana)', },
  {
    'Yumurta "meal_id": "kahvalti_saglikli_013",
    "meal_name": "Türk Kahvaltı (2 adet)', Tabağı Light",
    'Tam Buğday "category": "Kahvaltı",
    Ekmeği "meal_type": "kahvalti",
    (3 "kalori": dilim)', 370,
    "protein": 21,
    "karbonhidrat": 'Ayran (200ml)'],
      45,
    'protein': "yag": 42, 12,
    'karb': "malzemeler": ["Tam Buğday 48, Ekmeği 'yag': (2 24, dilim)", 'kalori': 580,
    "Beyaz },
    Peynir (50g)", "Domates {
      'malzemeler': ['Süzme Yoğurt (2 adet)", "Salatalık (1 adet)", (300g)', "Zeytin (10 'Granola (60g)', adet)", 'Muz (1 adet)', "Ceviz (5 'Badem (30g)', adet)"],
    'Bal "hazirlamaSuresi": 5,
    (2 yemek "zorluk": "kolay",
    kaşığı)'],
      "etiketler": 'protein': ["geleneksel", 30, 'karb': "dengeli", 85, 'yag': "sağlıklı"]
  },
  24, {
    'kalori': "meal_id": 650,
    },
    {
      'malzemeler': "kahvalti_saglikli_014",
    "meal_name": "Cottage Cheese ['Omlet (4 Meyve yumurta)', 'Kaşar Peyniri Tabağı",
    (60g)', "category": 'Mantar "Kahvaltı",
    (100g)', 'Tam Buğday "meal_type": Ekmeği "kahvalti",
    "kalori": (3 dilim)', 290,
    "protein": 22,
    "karbonhidrat": 'Avokado (1 adet)'],
      'protein': 38,
    "yag": 40, 'karb': 50, 'yag': 5,
    32, 'kalori': "malzemeler": ["Cottage Cheese 650,
    },
    (150g)", "Ananas {
      'malzemeler': (100g)", ['Yulaf "Kivi (70g)', 'Protein (2 adet)", "Bal Tozu (1 tatlı kaşığı)", (30g)', "Ceviz (5 adet)"],
    'Fıstık Ezmesi "hazirlamaSuresi": (30g)', 'Muz 5,
    "zorluk": "kolay",
    (2 adet)', 'Süt (300ml)'],
      "etiketler": 'protein': ["cottage-cheese", "meyve", 42, 'karb': 90, 'yag': 22, 'kalori': 700,
    },
    {
      'malzemeler': "düşük-yağ"]
  },
  {
    "meal_id": ['Yumurta "kahvalti_saglikli_015",
    (3 adet)', "meal_name": "Sebzeli 'Salam Yumurta (60g)', 'Tam Buğday Ekmeği (3 dilim)', Muffin",
    "category": 'Kaşar Peyniri "Kahvaltı",
    (50g)', 'Tereyağı "meal_type": "kahvalti",
    "kalori": (15g)'],
      'protein': 36, 'karb': 265,
    "protein": 20,
    "karbonhidrat": 48, 'yag': 30, 'kalori': 18,
    "yag": 600,
    },
    {
      'malzemeler': 13,
    "malzemeler": ["Yumurta (3 adet)", ['Açai Bowl', "Brokoli (50g)", 'Granola (60g)', "Kırmızı Biber 'Muz (1 adet)', (30g)", 'Hindistan Cevizi (30g)', "Kaşar Peyniri 'Fıstık (30g)", Ezmesi "Soğan (30g)', (20g)"],
    "hazirlamaSuresi": 'Yaban Mersini 25,
    "zorluk": (100g)'],
      'protein': "orta",
    "etiketler": ["muffin", 20, 'karb': 98, 'yag': "sebze", 28, 'kalori': 680,
    },
    {
      'malzemeler': "önceden-hazırlanabilir"]
  ['Gözleme },
  {
    "meal_id": (peynirli, "kahvalti_saglikli_016",
    "meal_name": "Ekşi 2 adet)', 'Yoğurt (200g)', Mayalı 'Bal (1 Ekmek + yemek kaşığı)', Somon 'Ceviz (30g)'],
      Füme",
    'protein': "category": "Kahvaltı",
    32, 'karb': "meal_type": 72, "kahvalti",
    'yag': "kalori": 26, 'kalori': 640,
    385,
    },
    "protein": {
      26,
    'malzemeler': "karbonhidrat": ['Yumurta (4 38,
    "yag": adet, 14,
    "malzemeler": sahanda)', ["Ekşi Mayalı Ekmek (2 'Kavurma dilim)", "Füme Somon (60g)', 'Tam (60g)", Buğday Ekmeği "Labne (2 dilim)', 'Zeytin (50g)", (15 "Kapari adet)', 'Domates (1 (10g)", adet)'],
      'protein': 40, 'karb': 40, 'yag': 32, 'kalori': "Dereotu"],
    "hazirlamaSuresi": 600,
    },
    {
      'malzemeler': 5,
    ['Protein Smoothie "zorluk": "kolay",
    "etiketler": ["somon", "omega3", (süt 300ml, muz 2, protein tozu "premium"]
  },
  30g, yulaf {
    50g)', "meal_id": 'Fıstık Ezmesi "kahvalti_saglikli_017",
    (30g)', "meal_name": 'Bal (1 yemek "Acai Bowl kaşığı)'],
      'protein': Türk 40, 'karb': 95, 'yag': Versiyonu",
    20, 'kalori': "category": 700,
    },
    "Kahvaltı",
    "meal_type": "kahvalti",
    {
      'malzemeler': "kalori": ['Menemen 330,
    "protein": (3 yumurta)', 16,
    "karbonhidrat": 52,
    'Sucuk "yag": (50g)', 8,
    "malzemeler": 'Kaşar Peyniri (50g)', 'Tam Buğday Ekmeği ["Dondurulmuş (3 Vişne dilim)'],
      'protein': (100g)", 36, 'karb': 48, 'yag': "Muz (1 adet)", 28, 'kalori': 580,
    },
    {
      'malzemeler': "Süzme Yoğurt ['Yulaf (100g)", "Granola (80g)', (30g)", 'Tam "Hindistan Yağlı Cevizi Yoğurt (15g)"],
    (200g)', "hazirlamaSuresi": 'Hurma 10,
    (6 "zorluk": adet)', "kolay",
    'Badem "etiketler": (40g)', ["acai-bowl", "antioksidan", 'Bal (1 yemek kaşığı)'],
      "enerji"]
  },
  'protein': {
    26, 'karb': "meal_id": 100, "kahvalti_saglikli_018",
    'yag': 26, 'kalori': 700,
    },
    "meal_name": "Mercimekli {
      'malzemeler': ['Yumurta Gözleme",
    (3 "category": adet)', "Kahvaltı",
    'Peynirli "meal_type": "kahvalti",
    "kalori": Tost 355,
    "protein": (tam 18,
    "karbonhidrat": buğday, 48,
    2 adet)', 'Kaşar "yag": Peyniri 10,
    "malzemeler": (60g)', 'Tereyağı ["Tam Buğday (15g)', 'Domates (1 adet)'],
      Yufkası 'protein': (1 adet)", 34, 'karb': 52, "Kırmızı 'yag': Mercimek 28, 'kalori': (80g)", 600,
    },
    {
      'malzemeler': ['Protein "Soğan (1 adet)", Pancake (yulaf "Baharatlar", 70g, yumurta 4)', "Zeytinyağı (1 'Tahin yemek (30g)', kaşığı)"],
    'Pekmez "hazirlamaSuresi": (30g)', 20,
    'Ceviz (30g)'],
      'protein': 36, 'karb': 75, 'yag': 30, 'kalori': 680,
    },
    {
      'malzemeler': ['Yumurta (4 adet)', "zorluk": "orta",
    'Somon "etiketler": ["gözleme", "mercimek", "geleneksel"]
  },
  {
    "meal_id": "kahvalti_saglikli_019",
    "meal_name": "Protein Waffle + (füme, Meyve",
    "category": "Kahvaltı",
    80g)', "meal_type": 'Cream Cheese "kahvalti",
    "kalori": (40g)', 'Bagel 340,
    "protein": 24,
    (1 adet)', "karbonhidrat": 'Avokado 42,
    "yag": (yarım)'],
      'protein': 42, 'karb': 9,
    "malzemeler": 50, 'yag': ["Yulaf 30, 'kalori': 640,
    },
    Unu ["Yulaf 30, 'kalori': 640,
    },
    Unu {
      'malzemeler': (60g)", ['Yulaf "Protein Tozu (30g)", (70g)', {
      'malzemeler': (60g)", ['Yulaf "Protein Tozu (30g)", (70g)', "Yumurta 'Süt (300ml)', 'Muz (2 adet)', (1 adet)", "Yumurta 'Süt (300ml)', 'Muz (2 adet)', (1 adet)", "Çilek 'Badem Ezmesi (30g)', (100g)", "Bal (1 'Chia Tohumu tatlı "Çilek 'Badem Ezmesi (30g)', (100g)", "Bal (1 'Chia Tohumu tatlı kaşığı)"],
    (20g)', 'Bal "hazirlamaSuresi": (1 yemek 12,
    kaşığı)'],
      'protein': "zorluk": kaşığı)"],
    (20g)', 'Bal "hazirlamaSuresi": (1 yemek 12,
    kaşığı)'],
      'protein': "zorluk": "kolay",
    "kolay",
    28, 'karb': "etiketler": 98, ["waffle", 'yag': "protein", 26, 'kalori': 710,
    28, 'karb': "etiketler": 98, ["waffle", 'yag': "protein", 26, 'kalori': 710,
    },
    },
    "spor"]
  },
  {
      'malzemeler': {
    "meal_id": "kahvalti_saglikli_020",
    "spor"]
  },
  {
      'malzemeler': {
    "meal_id": "kahvalti_saglikli_020",
    ['Ispanaklı ['Ispanaklı "meal_name": Börek "Shakshuka (4 Türk dilim, "meal_name": Börek "Shakshuka (4 Türk dilim, Usulü",
    ev "category": "Kahvaltı",
    "meal_type": yapımı)', Usulü",
    ev "category": "Kahvaltı",
    "meal_type": yapımı)', "kahvalti",
    'Yoğurt "kalori": (200g)', 305,
    "protein": 'Ayran 19,
    "kahvalti",
    'Yoğurt "kalori": (200g)', 305,
    "protein": 'Ayran 19,
    (200ml)'],
      (200ml)'],
      'protein': "karbonhidrat": 28, 'karb': 24,
    "yag": 70, 'yag': 26, 'kalori': 16,
    'protein': "karbonhidrat": 28, 'karb': 24,
    "yag": 70, 'yag': 26, 'kalori': 16,
    620,
    },
    "malzemeler": ["Yumurta {
      'malzemeler': (2 adet)", ['Yumurta "Domates 620,
    },
    "malzemeler": ["Yumurta {
      'malzemeler': (2 adet)", ['Yumurta "Domates (3 adet)', (3 adet)", 'Pastırma (60g)', "Kırmızı Biber (1 adet)", 'Tam (3 adet)', (3 adet)", 'Pastırma (60g)', "Kırmızı Biber (1 adet)", 'Tam Buğday "Soğan Buğday "Soğan (1 Ekmeği (3 adet)", dilim)', "Zeytinyağı 'Kaşar (1 yemek kaşığı)", Peyniri (50g)', (1 Ekmeği (3 adet)", dilim)', "Zeytinyağı 'Kaşar (1 yemek kaşığı)", Peyniri (50g)', 'Domates 'Domates (1 adet)'],
      'protein': "Baharatlar"],
    "hazirlamaSuresi": 38, 'karb': 48, 'yag': 18,
    (1 adet)'],
      'protein': "Baharatlar"],
    "hazirlamaSuresi": 38, 'karb': 48, 'yag': 18,
    28, 'kalori': "zorluk": "orta",
    "etiketler": 590,
    },
    ["shakshuka", "protein", {
      'malzemeler': 28, 'kalori': "zorluk": "orta",
    "etiketler": 590,
    },
    ["shakshuka", "protein", {
      'malzemeler': "lezzetli"]
  "lezzetli"]
  ['Smoothie },
  {
    Bowl (muz 2, "meal_id": yaban mersini 100g, "kahvalti_saglikli_021",
    ['Smoothie },
  {
    Bowl (muz 2, "meal_id": yaban mersini 100g, "kahvalti_saglikli_021",
    "meal_name": protein tozu 30g)', "Tam Buğday 'Granola Krep "meal_name": protein tozu 30g)', "Tam Buğday 'Granola Krep + (60g)', + (60g)', 'Badem (30g)', Labne",
    "category": 'Hindistan Cevizi 'Badem (30g)', Labne",
    "category": 'Hindistan Cevizi "Kahvaltı",
    "Kahvaltı",
    (20g)'],
      "meal_type": 'protein': "kahvalti",
    "kalori": 36, 'karb': (20g)'],
      "meal_type": 'protein': "kahvalti",
    "kalori": 36, 'karb': 92, 325,
    'yag': "protein": 26, 17,
    'kalori': 700,
    "karbonhidrat": },
    {
      44,
    'malzemeler': 92, 325,
    'yag': "protein": 26, 17,
    'kalori': 700,
    "karbonhidrat": },
    {
      44,
    'malzemeler': "yag": "yag": ['Yumurta (4 adet)', 'Kavurma ['Yumurta (4 adet)', 'Kavurma 10,
    (70g)', 'Tam Buğday Ekmeği "malzemeler": ["Tam (2 Buğday dilim)', Unu (60g)", 10,
    (70g)', 'Tam Buğday Ekmeği "malzemeler": ["Tam (2 Buğday dilim)', Unu (60g)", "Yumurta (1 adet)", 'Ezine "Süt Peyniri (100ml)", "Labne (50g)', (80g)", 'Zeytin "Yumurta (1 adet)", 'Ezine "Süt Peyniri (100ml)", "Labne (50g)', (80g)", 'Zeytin "Bal (1 tatlı (12 adet)'],
      kaşığı)"],
    'protein': "hazirlamaSuresi": 42, "Bal (1 tatlı (12 adet)'],
      kaşığı)"],
    'protein': "hazirlamaSuresi": 42, 15,
    'karb': 15,
    'karb': "zorluk": 42, 'yag': "orta",
    "etiketler": 34, 'kalori': 640,
    ["krep", },
    "labne", "zorluk": 42, 'yag': "orta",
    "etiketler": 34, 'kalori': 640,
    ["krep", },
    "labne", {
      "sağlıklı"]
  'malzemeler': ['Protein },
  {
    Waffle (yulaf "meal_id": 70g, "kahvalti_saglikli_022",
    yumurta {
      "sağlıklı"]
  'malzemeler': ['Protein },
  {
    Waffle (yulaf "meal_id": 70g, "kahvalti_saglikli_022",
    yumurta 4)', "meal_name": "Beyaz 'Fıstık Ezmesi Peynirli Sebze (40g)', 4)', "meal_name": "Beyaz 'Fıstık Ezmesi Peynirli Sebze (40g)', 'Muz Scramble",
    "category": "Kahvaltı",
    (1 adet)', 'Akçaağaç 'Muz Scramble",
    "category": "Kahvaltı",
    (1 adet)', 'Akçaağaç "meal_type": "meal_type": Şurubu "kahvalti",
    "kalori": (40ml)'],
      'protein': 36, 280,
    'karb': Şurubu "kahvalti",
    "kalori": (40ml)'],
      'protein': 36, 280,
    'karb': "protein": "protein": 21,
    "karbonhidrat": 80, 'yag': 26, 'kalori': 16,
    "yag": 680,
    21,
    "karbonhidrat": 80, 'yag': 26, 'kalori': 16,
    "yag": 680,
    },
    },
    {
      'malzemeler': 15,
    "malzemeler": ["Yumurta ['Yulaf (3 (80g)', adet)", {
      'malzemeler': 15,
    "malzemeler": ["Yumurta ['Yulaf (3 (80g)', adet)", "Beyaz Peynir (50g)", "Mantar (50g)", 'Süzme Yoğurt (250g)', 'Muz "Beyaz Peynir (50g)", "Mantar (50g)", 'Süzme Yoğurt (250g)', 'Muz "Cherry Domates (5 adet)", (2 "Taze adet)', 'Ceviz "Cherry Domates (5 adet)", (2 "Taze adet)', 'Ceviz (40g)', 'Bal (2 yemek kaşığı)', (40g)', 'Bal (2 yemek kaşığı)', Fesleğen"],
    Fesleğen"],
    "hazirlamaSuresi": 10,
    "zorluk": "kolay",
    "hazirlamaSuresi": 10,
    "zorluk": "kolay",
    "etiketler": 'Kakao Tozu ["scramble", "sebze", (10g)'],
      "protein"]
  'protein': 32, },
  'karb': {
    100, 'yag': "etiketler": 'Kakao Tozu ["scramble", "sebze", (10g)'],
      "protein"]
  'protein': 32, },
  'karb': {
    100, 'yag': 28, "meal_id": 'kalori': 740,
    },
    {
      'malzemeler': "kahvalti_saglikli_023",
    "meal_name": "Yulaf 28, "meal_id": 'kalori': 740,
    },
    {
      'malzemeler': "kahvalti_saglikli_023",
    "meal_name": "Yulaf Ezmesi ['Menemen (4 + yumurta)', 'Salam Tahin Ezmesi ['Menemen (4 + yumurta)', 'Salam Tahin (60g)', 'Tam Buğday Ekmeği Pekmez",
    (3 dilim)', "category": (60g)', 'Tam Buğday Ekmeği Pekmez",
    (3 dilim)', "category": 'Kaşar "Kahvaltı",
    Peyniri "meal_type": (60g)'],
      'protein': "kahvalti",
    40, "kalori": 'Kaşar "Kahvaltı",
    Peyniri "meal_type": (60g)'],
      'protein': "kahvalti",
    40, "kalori": 'karb': 'karb': 50, 'yag': 370,
    "protein": 32, 14,
    'kalori': "karbonhidrat": 650,
    },
    50, 'yag': 370,
    "protein": 32, 14,
    'kalori': "karbonhidrat": 650,
    },
    {
      56,
    'malzemeler': "yag": ['Yumurta (3 adet)', 'Sucuk 12,
    {
      56,
    'malzemeler': "yag": ['Yumurta (3 adet)', 'Sucuk 12,
    (60g)', "malzemeler": 'Kaşar ["Yulaf Ezmesi Peyniri (60g)', (60g)", 'Simit (1 "Süt adet)', (60g)', "malzemeler": 'Kaşar ["Yulaf Ezmesi Peyniri (60g)', (60g)", 'Simit (1 "Süt adet)', 'Zeytin (200ml)", "Tahin (15 adet)'],
      'protein': 36, 'Zeytin (200ml)", "Tahin (15 adet)'],
      'protein': 36, (15g)", "Pekmez (15g)", "Pekmez 'karb': (20g)", 54, 'yag': 30, 'kalori': "Ceviz (5 'karb': (20g)", 54, 'yag': 30, 'kalori': "Ceviz (5 adet)"],
    adet)"],
    620,
    },
    "hazirlamaSuresi": {
      'malzemeler': ['Protein 8,
    "zorluk": "kolay",
    620,
    },
    "hazirlamaSuresi": {
      'malzemeler': ['Protein 8,
    "zorluk": "kolay",
    Smoothie "etiketler": (süt 400ml, muz ["yulaf", 2, protein tozu 40g, Smoothie "etiketler": (süt 400ml, muz ["yulaf", 2, protein tozu 40g, yulaf "tahin-pekmez", yulaf "tahin-pekmez", 60g, "geleneksel"]
  },
  fıstık ezmesi 60g, "geleneksel"]
  },
  fıstık ezmesi {
    {
    "meal_id": "kahvalti_saglikli_024",
    30g)'],
      'protein': "meal_name": "Humus + 48, 'karb': Sebze "meal_id": "kahvalti_saglikli_024",
    30g)'],
      'protein': "meal_name": "Humus + 48, 'karb': Sebze 100, 'yag': 24, 'kalori': 780,
    },
    Çubukları",
    "category": 100, 'yag': 24, 'kalori': 780,
    },
    Çubukları",
    "category": {
      {
      'malzemeler': "Kahvaltı",
    ['Gözleme "meal_type": "kahvalti",
    "kalori": 'malzemeler': "Kahvaltı",
    ['Gözleme "meal_type": "kahvalti",
    "kalori": 315,
    "protein": 15,
    (kıymalı, 2 adet)', "karbonhidrat": 'Ayran 315,
    "protein": 15,
    (kıymalı, 2 adet)', "karbonhidrat": 'Ayran 42,
    "yag": (300ml)', 'Yoğurt 10,
    42,
    "yag": (300ml)', 'Yoğurt 10,
    "malzemeler": ["Humus (100g)", (150g)'],
      'protein': 36, 'karb': "Havuç (100g)", 72, "malzemeler": ["Humus (100g)", (150g)'],
      'protein': 36, 'karb': "Havuç (100g)", 72, 'yag': 'yag': "Salatalık 28, 'kalori': (100g)", 660,
    },
    "Tam Buğday {
      'malzemeler': Ekmeği "Salatalık 28, 'kalori': (100g)", 660,
    },
    "Tam Buğday {
      'malzemeler': Ekmeği (1 ['Yulaf dilim)", (75g)', 'Tam Yağlı "Zeytin (10 (1 ['Yulaf dilim)", (75g)', 'Tam Yağlı "Zeytin (10 adet)"],
    Süt (300ml)', "hazirlamaSuresi": 'Hurma 5,
    adet)"],
    Süt (300ml)', "hazirlamaSuresi": 'Hurma 5,
    (7 "zorluk": "kolay",
    adet)', "etiketler": ["humus", 'Fındık (40g)', "vegan", (7 "zorluk": "kolay",
    adet)', "etiketler": ["humus", 'Fındık (40g)', "vegan", 'Chia Tohumu "sağlıklı"]
  },
  {
    "meal_id": (20g)'],
      'protein': 'Chia Tohumu "sağlıklı"]
  },
  {
    "meal_id": (20g)'],
      'protein': "kahvalti_saglikli_025",
    "kahvalti_saglikli_025",
    28, 'karb': "meal_name": "Ricotta 105, 'yag': 30, 'kalori': + Bal 760,
    },
    28, 'karb': "meal_name": "Ricotta 105, 'yag': 30, 'kalori': + Bal 760,
    },
    + {
      'malzemeler': ['Yumurta (4 Ceviz",
    adet)', 'Pastırma + {
      'malzemeler': ['Yumurta (4 Ceviz",
    adet)', 'Pastırma "category": (70g)', "Kahvaltı",
    "meal_type": "kahvalti",
    'Tam Buğday "kalori": Ekmeği (3 dilim)', "category": (70g)', "Kahvaltı",
    "meal_type": "kahvalti",
    'Tam Buğday "kalori": Ekmeği (3 dilim)', 340,
    'Kaşar "protein": Peyniri 19,
    "karbonhidrat": (60g)', 38,
    340,
    'Kaşar "protein": Peyniri 19,
    "karbonhidrat": (60g)', 38,
    'Avokado 'Avokado "yag": (1 adet)'],
      'protein': 44, 'karb': 13,
    "malzemeler": 52, 'yag': "yag": (1 adet)'],
      'protein': 44, 'karb': 13,
    "malzemeler": 52, 'yag': ["Ricotta Peyniri 38, 'kalori': 720,
    },
    (150g)", {
      'malzemeler': "Tam Buğday ["Ricotta Peyniri 38, 'kalori': 720,
    },
    (150g)", {
      'malzemeler': "Tam Buğday Ekmeği ['Açai Bowl', (2 dilim)", "Bal 'Granola (70g)', 'Muz (20g)", Ekmeği ['Açai Bowl', (2 dilim)", "Bal 'Granola (70g)', 'Muz (20g)", "Ceviz "Ceviz (2 adet)', (10 'Fıstık adet)", Ezmesi (40g)', (2 adet)', (10 'Fıstık adet)", Ezmesi (40g)', 'Hindistan 'Hindistan Cevizi (30g)', 'Bal "Tarçın"],
    "hazirlamaSuresi": 5,
    (2 "zorluk": yemek Cevizi (30g)', 'Bal "Tarçın"],
    "hazirlamaSuresi": 5,
    (2 "zorluk": yemek kaşığı)'],
      'protein': 24, 'karb': kaşığı)'],
      'protein': 24, 'karb': 115, 'yag': 32, 'kalori': 800,
    },
  ];

  115, 'yag': 32, 'kalori': 800,
    },
  ];

  for for (var data in yuksekKaloriKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      (var data in yuksekKaloriKahvaltilar) {
    kahvaltilar.add(_yemekOlustur(
      id: id: 'saglikli_kahvalti_yk_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: "kolay",
    'saglikli_kahvalti_yk_${idCounter++}',
      malzemeler: data['malzemeler'] as List<String>,
      protein: "kolay",
    "etiketler": data['protein'] ["ricotta", as "bal", int,
      "omega3"]
  },
  {
    "meal_id": karb: "kahvalti_saglikli_026",
    data['karb'] "meal_name": as int,
      yag: "Sebze Frittata",
    "category": "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": 295,
    "protein": data['yag'] 22,
    as "etiketler": data['protein'] ["ricotta", as "bal", int,
      "omega3"]
  },
  {
    "meal_id": karb: "kahvalti_saglikli_026",
    data['karb'] "meal_name": as int,
      yag: "Sebze Frittata",
    "category": "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": 295,
    "protein": data['yag'] 22,
    as "karbonhidrat": "karbonhidrat": int,
      18,
    "yag": 16,
    kalori: data['kalori'] "malzemeler": as ["Yumurta int,
      etiketler: (3 ['yüksek adet)", kalori', int,
      18,
    "yag": 16,
    kalori: data['kalori'] "malzemeler": as ["Yumurta int,
      etiketler: (3 ['yüksek adet)", kalori', "Kabak 'bulk', 'kas (80g)", "Domates (2 adet)", "Soğan (1 "Kabak 'bulk', 'kas (80g)", "Domates (2 adet)", "Soğan (1 adet)", yapımı'],
    ));
  }

  // JSON "Lor Peyniri dosyasını (50g)"],
    "hazirlamaSuresi": adet)", yapımı'],
    ));
  }

  // JSON "Lor Peyniri dosyasını (50g)"],
    "hazirlamaSuresi": kaydet
  final jsonOutput = 20,
    "zorluk": "orta",
    jsonEncode(kahvaltilar);
  "etiketler": kaydet
  final jsonOutput = 20,
    "zorluk": "orta",
    jsonEncode(kahvaltilar);
  "etiketler": final ["frittata", "sebze", file = "İtalyan"]
  },
  final ["frittata", "sebze", file = "İtalyan"]
  },
  {
    {
    "meal_id": "kahvalti_saglikli_027",
    File('assets/data/kahvalti_saglikli_150.json');
  "meal_name": await "meal_id": "kahvalti_saglikli_027",
    File('assets/data/kahvalti_saglikli_150.json');
  "meal_name": await "Yaban Mersinli Smoothie file.parent.create(recursive: true);
  await "Yaban Mersinli Smoothie file.parent.create(recursive: true);
  await Bowl",
    "category": file.writeAsString(jsonOutput);

  "Kahvaltı",
    print('\n✅ "meal_type": 150 "kahvalti",
    Bowl",
    "category": file.writeAsString(jsonOutput);

  "Kahvaltı",
    print('\n✅ "meal_type": 150 "kahvalti",
    "kalori": "kalori": 310,
    "protein": Sağlıklı Kahvaltı 18,
    310,
    "protein": Sağlıklı Kahvaltı 18,
    "karbonhidrat": 48,
    Oluşturuldu!');
  "yag": print('📁 6,
    "malzemeler": Dosya: "karbonhidrat": 48,
    Oluşturuldu!');
  "yag": print('📁 6,
    "malzemeler": Dosya: ["Dondurulmuş Yaban Mersini (150g)", "Muz ["Dondurulmuş Yaban Mersini (150g)", "Muz assets/data/kahvalti_saglikli_150.json');
  (1 adet)", print('📊 Toplam: "Süzme Yoğurt ${kahvaltilar.length} (100g)", assets/data/kahvalti_saglikli_150.json');
  (1 adet)", print('📊 Toplam: "Süzme Yoğurt ${kahvaltilar.length} (100g)", "Granola "Granola (30g)", "Badem yemek\n');
  
  // (30g)", "Badem yemek\n');
  
  // (10 adet)"],
    "hazirlamaSuresi": İstatistikler
  final 8,
    (10 adet)"],
    "hazirlamaSuresi": İstatistikler
  final 8,
    "zorluk": "kolay",
    "etiketler": ["smoothie-bowl", avgKalori = "antioksidan", "zorluk": "kolay",
    "etiketler": ["smoothie-bowl", avgKalori = "antioksidan", kahvaltilar.fold<int>(0, (sum, "meyve"]
  },
  k) {
    => sum + kahvaltilar.fold<int>(0, (sum, "meyve"]
  },
  k) {
    => sum + "meal_id": (k['kalori'] as "kahvalti_saglikli_028",
    "meal_name": "Tam int)) / kahvaltilar.length;
  final avgProtein = Tahıllı "meal_id": (k['kalori'] as "kahvalti_saglikli_028",
    "meal_name": "Tam int)) / kahvaltilar.length;
  final avgProtein = Tahıllı kahvaltilar.fold<int>(0, Granola (sum, k) + => sum + (k['protein'] as kahvaltilar.fold<int>(0, Granola (sum, k) + => sum + (k['protein'] as int)) / kahvaltilar.length;
  final avgKarb = int)) / kahvaltilar.length;
  final avgKarb = kahvaltilar.fold<int>(0, kahvaltilar.fold<int>(0, Yoğurt",
    "category": (sum, k) => sum + "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": 360,
    (k['karbonhidrat'] as "protein": Yoğurt",
    "category": (sum, k) => sum + "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": 360,
    (k['karbonhidrat'] as "protein": 16,
    "karbonhidrat": int)) / kahvaltilar.length;
  52,
    "yag": final avgYag = 16,
    "karbonhidrat": int)) / kahvaltilar.length;
  52,
    "yag": final avgYag = kahvaltilar.fold<int>(0, 10,
    (sum, "malzemeler": ["Granola (60g)", kahvaltilar.fold<int>(0, 10,
    (sum, "malzemeler": ["Granola (60g)", k) => sum + (k['yag'] as int)) / kahvaltilar.length;

  print('📈 "Süzme Yoğurt (150g)", k) => sum + (k['yag'] as int)) / kahvaltilar.length;

  print('📈 "Süzme Yoğurt (150g)", "Kuru İSTATİSTİKLER:');
  Üzüm print('   (30g)", "Kuru İSTATİSTİKLER:');
  Üzüm print('   (30g)", "Badem (10 adet)", "Bal Ort. (1 Kalori: tatlı "Badem (10 adet)", "Bal Ort. (1 Kalori: tatlı kaşığı)"],
    ${avgKalori.toInt()} "hazirlamaSuresi": kcal');
  print('   3,
    "zorluk": "kolay",
    kaşığı)"],
    ${avgKalori.toInt()} "hazirlamaSuresi": kcal');
  print('   3,
    "zorluk": "kolay",
    "etiketler": Ort. Protein: ["granola", "pratik", ${avgProtein.toInt()}g');
  print('   Ort. "etiketler": Ort. Protein: ["granola", "pratik", ${avgProtein.toInt()}g');
  print('   Ort. "enerji"]
  },
  {
    Karbonhidrat: "meal_id": ${avgKarb.toInt()}g');
  print('   "enerji"]
  },
  {
    Karbonhidrat: "meal_id": ${avgKarb.toInt()}g');
  print('   "kahvalti_saglikli_029",
    "kahvalti_saglikli_029",
    "meal_name": Ort. Yağ: "Ispanaklı ${avgYag.toInt()}g');
Yumurta "meal_name": Ort. Yağ: "Ispanaklı ${avgYag.toInt()}g');
Yumurta }

// Dinamik Wrap",
    "category": "Kahvaltı",
    isim "meal_type": oluşturma }

// Dinamik Wrap",
    "category": "Kahvaltı",
    isim "meal_type": oluşturma helper "kahvalti",
    "kalori": metodu
335,
    "protein": helper "kahvalti",
    "kalori": metodu
335,
    "protein": Map<String, 20,
    dynamic> "karbonhidrat": 38,
    "yag": 12,
    _yemekOlustur({
  Map<String, 20,
    dynamic> "karbonhidrat": 38,
    "yag": 12,
    _yemekOlustur({
  required "malzemeler": String id,
  required List<String> ["Tam Buğday malzemeler,
  required int protein,
  Tortilla (1 required adet)", int karb,
  required required "malzemeler": String id,
  required List<String> ["Tam Buğday malzemeler,
  required int protein,
  Tortilla (1 required adet)", int karb,
  required int yag,
  "Scrambled required int kalori,
  Yumurta required List<String> etiketler,
}) (2 {
  int yag,
  "Scrambled required int kalori,
  Yumurta required List<String> etiketler,
}) (2 {
  adet)", adet)", // "Taze Ispanak (50g)", "Kaşar Peyniri // "Taze Ispanak (50g)", "Kaşar Peyniri (30g)", (30g)", Malzemelerden "Domates dinamik isim (1 adet)"],
    oluştur
  final "hazirlamaSuresi": Malzemelerden "Domates dinamik isim (1 adet)"],
    oluştur
  final "hazirlamaSuresi": anamalzemeler = 10,
    "zorluk": "kolay",
    <String>[];
  anamalzemeler = 10,
    "zorluk": "kolay",
    <String>[];
  for for "etiketler": (var ["wrap", malzeme in "ıspanak", "protein"]
  "etiketler": (var ["wrap", malzeme in "ıspanak", "protein"]
  },
  {
    "meal_id": malzemeler.take(3)) {
    // "kahvalti_saglikli_030",
    },
  {
    "meal_id": malzemeler.take(3)) {
    // "kahvalti_saglikli_030",
    "meal_name": "Elmalı İlk 3 malzeme
    "meal_name": "Elmalı İlk 3 malzeme
    final Tarçınlı final Tarçınlı malzemeAdi = malzemeAdi = Yulaf",
    Yulaf",
    "category": "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": malzeme.split('(').first.trim();
    "category": "Kahvaltı",
    "meal_type": "kahvalti",
    "kalori": malzeme.split('(').first.trim();
    325,
    "protein": 12,
    "karbonhidrat": anamalzemeler.add(malzemeAdi);
  }

  325,
    "protein": 12,
    "karbonhidrat": anamalzemeler.add(malzemeAdi);
  }

  54,
    "yag": 8,
    final "malzemeler": yemekAdi ["Yulaf = Ezmesi 54,
    "yag": 8,
    final "malzemeler": yemekAdi ["Yulaf = Ezmesi (60g)", "Süt (200ml)", "Elma 'Kahvaltı: (60g)", "Süt (200ml)", "Elma 'Kahvaltı: ${anamalzemeler.join(" + ")}';

  return {
    (1 adet)", "Tarçın 'meal_id': id,
    (1 'meal_name': ${anamalzemeler.join(" + ")}';

  return {
    (1 adet)", "Tarçın 'meal_id': id,
    (1 'meal_name': yemekAdi,
    tatlı kaşığı)", 'category': "Ceviz (5 'Kahvaltı',
    'meal_type': yemekAdi,
    tatlı kaşığı)", 'category': "Ceviz (5 'Kahvaltı',
    'meal_type': adet)"],
    "hazirlamaSuresi": 10,
    'kahvalti',
    "zorluk": 'kalori': adet)"],
    "hazirlamaSuresi": 10,
    'kahvalti',
    "zorluk": 'kalori': kalori,
    kalori,
    "kolay",
    'protein': "etiketler": protein,
    'karbonhidrat': ["yulaf", karb,
    'yag': yag,
    "elma", "kolay",
    'protein': "etiketler": protein,
    'karbonhidrat': ["yulaf", karb,
    'yag': yag,
    "elma", 'malzemeler': "tarçın"]
  },
  {
    malzemeler,
    "meal_id": 'malzemeler': "tarçın"]
  },
  {
    malzemeler,
    "meal_id": "kahvalti_saglikli_031",
    "meal_name": "Kahvaltı 'hazırlama_süresi': 15,
    Protein "kahvalti_saglikli_031",
    "meal_name": "Kahvaltı 'hazırlama_süresi': 15,
    Protein Kasesi",
    "category": 'zorluk': "Kahvaltı",
    "meal_type": "kahvalti",
    Kasesi",
    "category": 'zorluk': "Kahvaltı",
    "meal_type": "kahvalti",
    'Kolay',
    "kalori": 'etiketler': 365,
    "protein": etiketler,
    28,
    'Kolay',
    "kalori": 'etiketler': 365,
    "protein": etiketler,
    28,
    "karbonhidrat": "karbonhidrat": 42,
    "yag": 10,
    'tarif': "malzemeler": 42,
    "yag": 10,
    'tarif': "malzemeler": 'Tüm ["Kinoa (50g)", "Haşlanmış Yumurta malzemeleri (2 adet)", 'Tüm ["Kinoa (50g)", "Haşlanmış Yumurta malzemeleri (2 adet)", karıştırın veya karıştırın veya servis edin.',
  };
}
servis edin.',
  };
}
</content>