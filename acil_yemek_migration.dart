// 🚨 ACİL YEMEK MİGRATİON SCRİPTİ
// Hive DB boş sorunu çözümü - 110+ Türk mutfağı yemeği

import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🚨 ACİL YEMEK MİGRATİON BAŞLATILIYOR...');
  print('📍 Problem: Hive DB boş - AI yemek öneremiyor');
  print('🎯 Çözüm: 110+ Türk mutfağı yemeği ekleniyor\n');
  
  // Hive başlat
  Hive.init('./hive_data');
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
  
  print('📊 Mevcut yemek sayısı: ${yemekBox.length}');
  
  // 🔥 TÜRK MUTFAĞI YEMEKLERİ (110 adet - kategorize edilmiş)
  final yemekler = [
    // 🍳 KAHVALTI (25 adet)
    ['Menemen', 'kahvalti', 320, 18, 12, 24, 'Yumurta,Domates,Biber,Soğan', 10, 'kolay'],
    ['Çılbır', 'kahvalti', 380, 22, 15, 28, 'Yumurta,Yoğurt,Tereyağı', 15, 'orta'],
    ['Sucuklu Yumurta', 'kahvalti', 420, 25, 8, 32, 'Yumurta,Sucuk', 8, 'kolay'],
    ['Peynirli Omlet', 'kahvalti', 360, 28, 6, 26, 'Yumurta,Beyaz Peynir', 10, 'kolay'],
    ['Börek', 'kahvalti', 450, 18, 35, 28, 'Yufka,Peynir,Yumurta', 30, 'orta'],
    ['Simit Peynir', 'kahvalti', 380, 16, 45, 18, 'Simit,Beyaz Peynir,Domates', 5, 'kolay'],
    ['Poğaça', 'kahvalti', 320, 12, 42, 15, 'Un,Yoğurt,Zeytin', 25, 'orta'],
    ['Kahvaltılık Krep', 'kahvalti', 340, 15, 38, 16, 'Un,Süt,Yumurta', 15, 'kolay'],
    ['Reçelli Ekmek', 'kahvalti', 280, 8, 52, 8, 'Ekmek,Reçel,Tereyağı', 3, 'kolay'],
    ['Lor Peyniri Salata', 'kahvalti', 220, 18, 12, 12, 'Lor Peyniri,Salatalık,Domates', 5, 'kolay'],
    ['Avokado Toast', 'kahvalti', 350, 12, 28, 22, 'Avokado,Tam Buğday Ekmek', 8, 'kolay'],
    ['Yumurtalı Sandviç', 'kahvalti', 420, 24, 38, 20, 'Ekmek,Yumurta,Peynir', 10, 'kolay'],
    ['Kahvaltı Tabağı', 'kahvalti', 480, 22, 35, 28, 'Peynir,Zeytin,Domates,Ekmek', 8, 'kolay'],
    ['Mısır Gevreği', 'kahvalti', 280, 12, 45, 8, 'Mısır Gevreği,Süt,Muz', 3, 'kolay'],
    ['Yoğurt Bal', 'kahvalti', 240, 15, 32, 6, 'Yoğurt,Bal,Ceviz', 3, 'kolay'],
    ['Peynirli Tost', 'kahvalti', 380, 20, 32, 22, 'Ekmek,Kaşar,Domates', 8, 'kolay'],
    ['Menemen Toast', 'kahvalti', 420, 22, 28, 26, 'Ekmek,Yumurta,Domates', 12, 'kolay'],
    ['Türk Kahvesi Köpük', 'kahvalti', 180, 8, 28, 6, 'Türk Kahvesi,Şeker,Lokum', 15, 'orta'],
    ['Pekmez Tahin', 'kahvalti', 320, 12, 35, 18, 'Pekmez,Tahin,Ekmek', 3, 'kolay'],
    ['Çay Bisküvi', 'kahvalti', 260, 6, 45, 10, 'Çay,Bisküvi,Şeker', 5, 'kolay'],
    ['Sahanda Yumurta', 'kahvalti', 280, 18, 2, 22, 'Yumurta,Tereyağı', 6, 'kolay'],
    ['Haşlama Yumurta', 'kahvalti', 220, 16, 2, 16, 'Yumurta,Tuz', 10, 'kolay'],
    ['Peynir Domates', 'kahvalti', 200, 14, 12, 12, 'Beyaz Peynir,Domates', 3, 'kolay'],
    ['Bal Kaymak', 'kahvalti', 340, 8, 28, 22, 'Bal,Kaymak,Ekmek', 3, 'kolay'],
    ['Tereyağlı Ekmek', 'kahvalti', 280, 8, 35, 15, 'Ekmek,Tereyağı,Bal', 3, 'kolay'],

    // 🍽️ ÖĞLE YEMEĞİ (30 adet)
    ['Tavuk Pilav', 'ogle', 520, 35, 48, 18, 'Tavuk,Pirinç,Soğan', 45, 'orta'],
    ['Köfte Patates', 'ogle', 580, 32, 35, 32, 'Köfte,Patates,Soğan', 40, 'orta'],
    ['Balık Izgara', 'ogle', 420, 45, 8, 22, 'Levrek,Zeytinyağı,Limon', 25, 'kolay'],
    ['Etli Nohut', 'ogle', 480, 28, 42, 22, 'Nohut,Kuşbaşı Et,Soğan', 60, 'orta'],
    ['Mercimek Çorbası', 'ogle', 280, 18, 38, 8, 'Mercimek,Soğan,Havuç', 30, 'kolay'],
    ['Türlü', 'ogle', 320, 12, 35, 18, 'Patlıcan,Kabak,Domates', 35, 'orta'],
    ['Mantı', 'ogle', 450, 22, 52, 18, 'Hamur,Kıyma,Yoğurt', 90, 'zor'],
    ['Tavuklu Salata', 'ogle', 380, 32, 18, 22, 'Tavuk,Marul,Domates', 15, 'kolay'],
    ['Etli Fasulye', 'ogle', 420, 25, 32, 22, 'Fasulye,Et,Soğan', 50, 'orta'],
    ['Sebze Çorbası', 'ogle', 180, 8, 28, 6, 'Karışık Sebze,Et Suyu', 25, 'kolay'],
    ['Tavuk Sote', 'ogle', 480, 38, 22, 28, 'Tavuk,Biber,Mantar', 25, 'orta'],
    ['Karnıyarık', 'ogle', 380, 18, 32, 22, 'Patlıcan,Kıyma,Domates', 45, 'orta'],
    ['Dolma', 'ogle', 320, 15, 38, 15, 'Biber,Pirinç,Kıyma', 60, 'zor'],
    ['Tavuk Çorbası', 'ogle', 220, 18, 15, 12, 'Tavuk,Un,Limon', 30, 'kolay'],
    ['Sebzeli Makarna', 'ogle', 420, 16, 58, 16, 'Makarna,Sebze,Zeytinyağı', 20, 'kolay'],
    ['Etli Pilav', 'ogle', 480, 22, 52, 18, 'Pirinç,Kuşbaşı,Soğan', 40, 'orta'],
    ['Balık Çorbası', 'ogle', 280, 24, 12, 16, 'Balık,Sebze,Limon', 35, 'orta'],
    ['Tavuk Döner', 'ogle', 520, 42, 28, 25, 'Tavuk,Lavaş,Salata', 15, 'kolay'],
    ['Kuzu Tandır', 'ogle', 580, 45, 15, 38, 'Kuzu,Patates,Soğan', 120, 'zor'],
    ['Sebze Güveç', 'ogle', 280, 12, 32, 16, 'Karışık Sebze,Zeytinyağı', 40, 'orta'],
    ['Tavuklu Pilav', 'ogle', 480, 32, 45, 18, 'Tavuk,Pirinç,Tereyağı', 35, 'orta'],
    ['Etli Bulgur', 'ogle', 420, 24, 48, 16, 'Bulgur,Kıyma,Domates', 30, 'kolay'],
    ['Balık Tava', 'ogle', 480, 38, 12, 32, 'Hamsi,Un,Zeytinyağı', 20, 'kolay'],
    ['Sebzeli Tavuk', 'ogle', 420, 35, 22, 22, 'Tavuk,Karışık Sebze', 35, 'orta'],
    ['İskender Kebap', 'ogle', 620, 42, 35, 32, 'Et,Lavaş,Yoğurt', 25, 'orta'],
    ['Lahmacun', 'ogle', 380, 18, 45, 16, 'Hamur,Kıyma,Domates', 25, 'orta'],
    ['Pide', 'ogle', 420, 22, 48, 18, 'Hamur,Peynir,Yumurta', 30, 'orta'],
    ['Tavuk Şiş', 'ogle', 380, 42, 8, 20, 'Tavuk,Salata,Lavaş', 30, 'orta'],
    ['Adana Kebap', 'ogle', 520, 38, 15, 32, 'Kıyma,Salata,Lavaş', 25, 'orta'],
    ['Sebze Yemeği', 'ogle', 220, 8, 28, 12, 'Karışık Sebze,Zeytinyağı', 30, 'kolay'],

    // 🌙 AKŞAM YEMEĞİ (25 adet)
    ['Izgara Tavuk', 'aksam', 420, 45, 8, 22, 'Tavuk,Salata,Zeytinyağı', 25, 'kolay'],
    ['Balık Fırın', 'aksam', 380, 42, 12, 18, 'Çupra,Patates,Limon', 35, 'orta'],
    ['Et Sote', 'aksam', 480, 38, 15, 28, 'Dana,Soğan,Biber', 30, 'orta'],
    ['Tavuk Salata', 'aksam', 320, 32, 18, 16, 'Tavuk,Yeşillik,Domates', 15, 'kolay'],
    ['Sebze Çorbası', 'aksam', 180, 8, 24, 8, 'Karışık Sebze', 20, 'kolay'],
    ['Omlet', 'aksam', 280, 22, 6, 20, 'Yumurta,Peynir', 10, 'kolay'],
    ['Ton Balığı Salata', 'aksam', 320, 28, 12, 18, 'Ton Balığı,Marul', 10, 'kolay'],
    ['Tavuk Çorbası', 'aksam', 220, 18, 15, 12, 'Tavuk,Sebze', 25, 'kolay'],
    ['Sebze Güveç', 'aksam', 250, 10, 28, 12, 'Karışık Sebze', 35, 'orta'],
    ['Balık Izgara', 'aksam', 380, 40, 6, 22, 'Levrek,Zeytinyağı', 20, 'kolay'],
    ['Tavuk Sote', 'aksam', 420, 35, 18, 24, 'Tavuk,Mantar', 25, 'orta'],
    ['Sebzeli Omlet', 'aksam', 320, 24, 12, 22, 'Yumurta,Sebze', 15, 'kolay'],
    ['Izgara Somon', 'aksam', 450, 42, 8, 28, 'Somon,Salata', 18, 'kolay'],
    ['Tavuk Haşlama', 'aksam', 320, 38, 8, 16, 'Tavuk,Sebze', 30, 'kolay'],
    ['Sebze Yemeği', 'aksam', 200, 8, 24, 10, 'Patlıcan,Kabak', 25, 'kolay'],
    ['Balık Çorbası', 'aksam', 240, 22, 12, 14, 'Balık,Sebze', 30, 'orta'],
    ['Tavuk Salata', 'aksam', 350, 30, 15, 20, 'Tavuk,Avokado', 12, 'kolay'],
    ['Izgara Et', 'aksam', 420, 40, 5, 26, 'Dana,Salata', 20, 'orta'],
    ['Sebze Çorbası', 'aksam', 160, 6, 22, 6, 'Brokoli,Havuç', 18, 'kolay'],
    ['Tavuk Fırın', 'aksam', 380, 42, 12, 20, 'Tavuk,Patates', 40, 'orta'],
    ['Balık Tava', 'aksam', 420, 35, 10, 28, 'Palamut,Soğan', 15, 'kolay'],
    ['Sebzeli Tavuk', 'aksam', 360, 32, 16, 20, 'Tavuk,Sebze', 25, 'orta'],
    ['Ton Salata', 'aksam', 280, 26, 8, 16, 'Ton,Marul,Domates', 8, 'kolay'],
    ['Tavuk Çorba', 'aksam', 200, 16, 12, 10, 'Tavuk,Şehriye', 20, 'kolay'],
    ['Sebze Sote', 'aksam', 220, 8, 20, 14, 'Karışık Sebze', 20, 'kolay'],

    // 🍎 ARA ÖĞÜN 1 (15 adet)
    ['Elma', 'araOgun1', 80, 0, 21, 0, 'Elma', 1, 'kolay'],
    ['Muz', 'araOgun1', 105, 1, 27, 0, 'Muz', 1, 'kolay'],
    ['Portakal', 'araOgun1', 85, 2, 21, 0, 'Portakal', 2, 'kolay'],
    ['Yoğurt', 'araOgun1', 120, 12, 16, 2, 'Yoğurt', 1, 'kolay'],
    ['Badem', 'araOgun1', 180, 6, 6, 16, 'Badem', 1, 'kolay'],
    ['Ceviz', 'araOgun1', 200, 5, 4, 20, 'Ceviz', 1, 'kolay'],
    ['Çay', 'araOgun1', 50, 2, 12, 0, 'Çay,Şeker', 3, 'kolay'],
    ['Kahve', 'araOgun1', 60, 2, 14, 0, 'Kahve,Süt,Şeker', 5, 'kolay'],
    ['Üzüm', 'araOgun1', 90, 1, 23, 0, 'Üzüm', 1, 'kolay'],
    ['Ayran', 'araOgun1', 80, 4, 8, 3, 'Ayran', 1, 'kolay'],
    ['Çilek', 'araOgun1', 60, 2, 14, 0, 'Çilek', 2, 'kolay'],
    ['Kivi', 'araOgun1', 70, 1, 17, 0, 'Kivi', 2, 'kolay'],
    ['Fındık', 'araOgun1', 190, 4, 5, 18, 'Fındık', 1, 'kolay'],
    ['Süt', 'araOgun1', 100, 8, 12, 3, 'Süt', 1, 'kolay'],
    ['Hurma', 'araOgun1', 120, 2, 32, 0, 'Hurma', 1, 'kolay'],

    // 🥤 ARA ÖĞÜN 2 (15 adet)
    ['Protein Bar', 'araOgun2', 280, 20, 30, 8, 'Protein Tozu,Yulaf', 1, 'kolay'],
    ['Smoothie', 'araOgun2', 220, 15, 32, 6, 'Süt,Meyve,Protein', 5, 'kolay'],
    ['Yoğurt Meyve', 'araOgun2', 180, 12, 28, 4, 'Yoğurt,Karışık Meyve', 3, 'kolay'],
    ['Granola', 'araOgun2', 320, 12, 45, 12, 'Yulaf,Bal,Kuruyemiş', 1, 'kolay'],
    ['Peynir Kraker', 'araOgun2', 220, 15, 25, 8, 'Kraker,Beyaz Peynir', 2, 'kolay'],
    ['Meyve Suyu', 'araOgun2', 140, 2, 35, 0, 'Portakal Suyu', 1, 'kolay'],
    ['Kek', 'araOgun2', 280, 6, 42, 12, 'Un,Şeker,Yumurta', 3, 'kolay'],
    ['Bisküvi', 'araOgun2', 240, 6, 36, 10, 'Bisküvi,Çay', 2, 'kolay'],
    ['Dondurma', 'araOgun2', 200, 6, 28, 8, 'Süt,Şeker', 1, 'kolay'],
    ['Çikolata', 'araOgun2', 180, 4, 20, 12, 'Çikolata', 1, 'kolay'],
    ['Pekmez Helva', 'araOgun2', 260, 8, 32, 12, 'Pekmez,Tahin', 1, 'kolay'],
    ['Meyve Salata', 'araOgun2', 120, 2, 30, 1, 'Karışık Meyve', 5, 'kolay'],
    ['Kuruyemiş', 'araOgun2', 300, 12, 15, 24, 'Badem,Ceviz,Fındık', 1, 'kolay'],
    ['Peynir', 'araOgun2', 160, 12, 4, 12, 'Beyaz Peynir', 1, 'kolay'],
    ['Reçel Ekmek', 'araOgun2', 200, 6, 36, 6, 'Ekmek,Reçel', 3, 'kolay'],
  ];

  print('📥 ${yemekler.length} yemek veritabanına ekleniyor...');

  int eklenenSayi = 0;
  for (var yemekData in yemekler) {
    try {
      final yemek = YemekHiveModel(
        mealId: 'acil_${eklenenSayi + 1}',
        mealName: yemekData[0] as String,
        category: yemekData[1] as String,
        calorie: (yemekData[2] as int).toDouble(),
        proteinG: (yemekData[3] as int).toDouble(),
        carbG: (yemekData[4] as int).toDouble(),
        fatG: (yemekData[5] as int).toDouble(),
        ingredients: (yemekData[6] as String).split(','),
        prepTimeMin: yemekData[7] as int,
        difficulty: yemekData[8] as String,
        recipe: 'Türk mutfağı tarifi - Geleneksel hazırlama yöntemi',
        goalTag: 'Bakım',
        alternatives: [],
        fiberG: 2.0,
        imageUrl: null,
        tags: ['Türk Mutfağı', 'Geleneksel'],
        isFavorite: false,
        proteinSource: _proteinKaynagiTespitEt(yemekData[0] as String, yemekData[6] as String),
      );

      await yemekBox.put(yemek.mealId!, yemek);
      eklenenSayi++;
      
      if (eklenenSayi % 20 == 0) {
        print('📊 İşlenen: $eklenenSayi/${yemekler.length}');
      }
      
    } catch (e) {
      print('❌ Hata: ${yemekData[0]} - $e');
    }
  }

  await yemekBox.close();
  
  print('\n🎉 ACİL MİGRATION TAMAMLANDI!');
  print('✅ Toplam eklenen yemek: $eklenenSayi');
  print('\n📊 Veritabanı durumu:');
  print('   🍳 Kahvaltı: 25 yemek');
  print('   🍽️ Öğle: 30 yemek');
  print('   🌙 Akşam: 25 yemek');  
  print('   🍎 Ara Öğün 1: 15 yemek');
  print('   🥤 Ara Öğün 2: 15 yemek');
  print('\n🚀 AI artık düzgün plan oluşturabilir!');
  print('💡 V5.3 RADİKAL FİX + Yemek DB = ÇÖZÜM!');
}

// Protein kaynağı tespit helper
String _proteinKaynagiTespitEt(String yemekAdi, String malzemeler) {
  final combined = '${yemekAdi.toLowerCase()} ${malzemeler.toLowerCase()}';
  
  if (combined.contains('tavuk') || combined.contains('chicken')) return 'Tavuk';
  if (combined.contains('et') || combined.contains('köfte') || combined.contains('kıyma')) return 'Et';
  if (combined.contains('balık') || combined.contains('somon') || combined.contains('levrek')) return 'Balık';
  if (combined.contains('yumurta') || combined.contains('omlet')) return 'Yumurta';
  if (combined.contains('peynir') || combined.contains('lor')) return 'Süt Ürünleri';
  if (combined.contains('mercimek') || combined.contains('nohut') || combined.contains('fasulye')) return 'Baklagil';
  
  return 'Karma';
}