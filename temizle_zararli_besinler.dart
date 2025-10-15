// ============================================================================
// temizle_zararli_besinler.dart
// HIVE DB'DEN ZARARLII BESİNLERİ TEMİZLEME SCRİPTİ
// ============================================================================
// 🎯 AMAÇ: Un ürünleri, yabancı besinler ve zararlı yemekleri Hive'dan sil
// 🔥 KULLANIM: dart run temizle_zararli_besinler.dart
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('\n╔═══════════════════════════════════════════════════════════════╗');
  print('║  🔥 HIVE DB TEMİZLEME SCRİPTİ - ZARARLII BESİNLER 🔥        ║');
  print('╚═══════════════════════════════════════════════════════════════╝\n');

  try {
    // Hive'ı başlat
    await Hive.initFlutter();
    await HiveService.init();

    print('✅ Hive başlatıldı\n');

    // Yemek box'ını aç
    final yemekBox = Hive.box<Yemek>('yemekler');
    final oncekiSayi = yemekBox.length;

    print('📊 Mevcut yemek sayısı: $oncekiSayi\n');
    print('🔍 Zararlı besinler taranıyor...\n');

    // 🚫 YASAK KELİMELER LİSTESİ
    final yasakKelimeler = [
      // Yabancı Supplement/Protein Ürünleri
      'whey',
      'protein shake',
      'protein powder',
      'protein smoothie',
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

      // Yabancı Yemekler
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

      // Un Ürünleri (Sağlıksız Karbonhidrat)
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

      // Zararlı/Kızartma/Fast Food
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

      // Aşırı İşlenmiş Ürünler
      'hazır çorba',
      'instant',
      'paketli',
    ];

    // Silinecek yemekleri bul
    final silinecekler = <String>[];
    final detaylar = <String, String>{}; // yemek adı -> sebep

    for (var i = 0; i < yemekBox.length; i++) {
      final yemek = yemekBox.getAt(i);
      if (yemek == null) continue;

      final adLower = yemek.ad.toLowerCase();

      // Yasak kelime kontrolü
      for (final yasak in yasakKelimeler) {
        if (adLower.contains(yasak.toLowerCase())) {
          silinecekler.add(yemek.id);
          detaylar[yemek.ad] = yasak;
          break;
        }
      }
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('📋 SİLİNECEK ZARAR BESINLER (${silinecekler.length} adet):\n');

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

    // Kullanıcıdan onay al
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('⚠️  DİKKAT: ${silinecekler.length} zararlı besin silinecek!');
    print('❓ Devam etmek istiyor musun? (E/H): ');

    final onay = stdin.readLineSync()?.toLowerCase();

    if (onay != 'e' && onay != 'evet') {
      print('\n❌ İşlem iptal edildi.\n');
      exit(0);
    }

    // Yemekleri sil
    print('\n🔥 Silme işlemi başladı...\n');

    int silinenSayisi = 0;
    for (final id in silinecekler) {
      // ID'ye göre yemeği bul ve sil
      for (var i = 0; i < yemekBox.length; i++) {
        final yemek = yemekBox.getAt(i);
        if (yemek?.id == id) {
          await yemekBox.deleteAt(i);
          silinenSayisi++;

          // İlerleme göster
          if (silinenSayisi % 10 == 0) {
            print('   ⏳ $silinenSayisi / ${silinecekler.length} silindi...');
          }
          break;
        }
      }
    }

    final sonrakiSayi = yemekBox.length;

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('✅ TEMİZLEME TAMAMLANDI!\n');
    print('📊 SONUÇLAR:');
    print('   • Önceki yemek sayısı: $oncekiSayi');
    print('   • Silinen zararlı besin: $silinenSayisi');
    print('   • Kalan sağlıklı yemek: $sonrakiSayi');
    print(
        '   • Temizlik oranı: %${((silinenSayisi / oncekiSayi) * 100).toStringAsFixed(1)}\n');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    print('🎯 SONRAKI ADIMLAR:');
    print('   1. Uygulamayı kapat (tamamen)');
    print('   2. flutter run ile başlat');
    print('   3. Plan Oluştur butonuna tıkla');
    print('   4. Artık sadece SAĞLIKLI Türk mutfağı yemekleri gelecek!\n');
  } catch (e, stackTrace) {
    print('\n❌ HATA: $e');
    print('Stack trace: $stackTrace\n');
    exit(1);
  }
}

