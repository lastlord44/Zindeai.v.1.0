// Hive veritabanından zararlı besinleri temizle
import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

void main() async {
  print('🔥 HIVE VERİTABANI ZARARLI BESİN TEMİZLEYİCİ');
  print('=' * 60);

  try {
    // Hive'ı başlat
    Hive.init(Directory.current.path);
    Hive.registerAdapter(YemekHiveModelAdapter());

    // Box'ı aç
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    final oncekiSayi = box.length;

    print('📊 Mevcut yemek sayısı: $oncekiSayi');

    if (oncekiSayi == 0) {
      print('❌ Veritabanı boş! Önce uygulamayı çalıştır.');
      exit(1);
    }

    // Zararlı besin listesi
    final zararliKelimeler = [
      'whey',
      'protein shake',
      'protein powder',
      'smoothie',
      'vegan protein',
      'protein bite',
      'protein tozu',
      'casein',
      'bcaa',
      'kreatin',
      'gainer',
      'supplement',
      'cottage cheese',
      'cottage',
      'smoothie bowl',
      'chia pudding',
      'acai bowl',
      'quinoa',
      'hummus wrap',
      'falafel wrap',
      'burrito',
      'taco',
      'sushi',
      'poke bowl',
      'ramen',
      'pad thai',
      'curry',
      'poğaça',
      'pogaca',
      'börek',
      'borek',
      'simit',
      'croissant',
      'hamburger',
      'burger',
      'pizza',
      'sandviç',
      'sandwich',
      'pide',
      'lahmacun',
      'gözleme',
      'gozleme',
      'tost',
      'ekmek',
      'galeta',
      'kraker',
      'kızarmış',
      'kizarmis',
      'cips',
      'chips',
      'patates kızartması',
      'french fries',
      'nugget',
      'crispy',
      'fried',
      'tavuk burger',
      'sosisli',
      'hot dog',
      'doner',
      'döner',
      'kokoreç',
      'kokorec',
      'hazır çorba',
      'instant',
      'paketli'
    ];

    // Silinecek yemekleri bul
    final silinecekler = <int>[];
    final detaylar = <String, String>{};

    for (var i = 0; i < box.length; i++) {
      final yemek = box.getAt(i);
      if (yemek == null) continue;

      final adLower = (yemek.mealName ?? '').toLowerCase();

      for (final zararli in zararliKelimeler) {
        if (adLower.contains(zararli.toLowerCase())) {
          silinecekler.add(i);
          detaylar[yemek.mealName ?? ''] = zararli;
          break;
        }
      }
    }

    print('\n📋 SİLİNECEK ZARARLI BESİNLER (${silinecekler.length} adet):');

    // Kategori bazında grupla
    final kategoriler = <String, List<String>>{};
    for (final entry in detaylar.entries) {
      final yemekAdi = entry.key;
      final sebep = entry.value;
      kategoriler.putIfAbsent(sebep, () => []).add(yemekAdi);
    }

    // Kategori bazında yazdır
    int sira = 1;
    kategoriler.forEach((sebep, yemekler) {
      print('🚫 $sebep (${yemekler.length} yemek):');
      for (final yemek in yemekler) {
        print('   $sira. $yemek');
        sira++;
      }
      print('');
    });

    if (silinecekler.isEmpty) {
      print('✅ Zararlı besin bulunamadı! Veritabanı zaten temiz.');
      await box.close();
      await Hive.close();
      exit(0);
    }

    // Kullanıcıdan onay al
    print('⚠️  DİKKAT: ${silinecekler.length} zararlı besin silinecek!');
    print('❓ Devam etmek istiyor musun? (E/H): ');

    final onay = stdin.readLineSync()?.toLowerCase();

    if (onay != 'e' && onay != 'evet') {
      print('\n❌ İşlem iptal edildi.');
      await box.close();
      await Hive.close();
      exit(0);
    }

    // Yemekleri sil (ters sırada sil ki index kayması olmasın)
    print('\n🔥 Silme işlemi başladı...');

    int silinenSayisi = 0;
    for (var i = silinecekler.length - 1; i >= 0; i--) {
      final index = silinecekler[i];
      await box.deleteAt(index);
      silinenSayisi++;

      if (silinenSayisi % 10 == 0) {
        print('   ⏳ $silinenSayisi / ${silinecekler.length} silindi...');
      }
    }

    final sonrakiSayi = box.length;

    print('\n✅ TEMİZLEME TAMAMLANDI!');
    print('📊 SONUÇLAR:');
    print('   • Önceki yemek sayısı: $oncekiSayi');
    print('   • Silinen zararlı besin: $silinenSayisi');
    print('   • Kalan sağlıklı yemek: $sonrakiSayi');
    print(
        '   • Temizlik oranı: %${((silinenSayisi / oncekiSayi) * 100).toStringAsFixed(1)}');

    await box.close();
    await Hive.close();

    print('\n🎯 SONRAKI ADIMLAR:');
    print('   1. Uygulamayı kapat (tamamen)');
    print('   2. flutter run ile başlat');
    print('   3. Plan Oluştur butonuna tıkla');
    print('   4. Artık sadece SAĞLIKLI Türk mutfağı yemekleri gelecek!');
  } catch (e, stackTrace) {
    print('\n❌ HATA: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
