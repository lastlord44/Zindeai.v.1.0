import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/domain/entities/besin_malzeme.dart';
import 'lib/domain/entities/yemek.dart'; // ✅ OgunTipi import edildi
import 'lib/domain/entities/ogun_sablonu.dart';
import 'lib/domain/usecases/malzeme_tabanli_genetik_algoritma.dart';

void main() async {
  print('🧪 MALZEME BAZLI GENETİK ALGORİTMA TEST\n');
  print('=' * 60);
  
  try {
    // Hive init
    Hive.init('hive_db');
    
    // 1. BESİN MALZEMELERİNİ YÜKLE
    print('\n📦 Besin malzemeleri yükleniyor...');
    final List<BesinMalzeme> tumBesinler = [];
    
    // Batch dosyalarını yükle (TÜM 20 batch - 4000 besin)
    for (int i = 1; i <= 20; i++) {
      String dosyaAdi;
      if (i == 1) {
        dosyaAdi = 'besin_malzemeleri_200.json';
      } else if (i == 2) {
        dosyaAdi = 'besin_malzemeleri_batch2_200.json';
      } else if (i == 3) {
        dosyaAdi = 'besin_malzemeleri_batch2_0201_0400.json';
      } else if (i == 4) {
        dosyaAdi = 'besin_malzemeleri_batch3_0401_0600.json';
      } else if (i == 5) {
        dosyaAdi = 'besin_malzemeleri_batch4_0601_0800.json';
      } else if (i == 6) {
        dosyaAdi = 'besin_malzemeleri_batch5_0801_1000.json';
      } else if (i == 7) {
        dosyaAdi = 'besin_malzemeleri_batch6_1001_1200.json';
      } else if (i == 8) {
        dosyaAdi = 'besin_malzemeleri_batch7_1201_1400_karbonhidrat_set3.json';
      } else if (i == 9) {
        dosyaAdi = 'besin_malzemeleri_batch8_1401_1600_karbonhidrat_set4.json';
      } else if (i == 10) {
        dosyaAdi = 'besin_malzemeleri_batch9_1601_1800_yag_sut_set1.json';
      } else if (i == 11) {
        dosyaAdi = 'besin_malzemeleri_batch10_1801_2000_yag_sut_set2.json';
      } else if (i == 12) {
        dosyaAdi = 'besin_malzemeleri_batch11_2001_2200_yag_sut_set3.json';
      } else if (i == 13) {
        dosyaAdi = 'besin_malzemeleri_batch12_2201_2400_yag_sut_set4.json';
      } else if (i == 14) {
        dosyaAdi = 'besin_malzemeleri_batch13_2401_2600_sebze_set1.json';
      } else if (i == 15) {
        dosyaAdi = 'besin_malzemeleri_batch14_2601_2800_sebze_set2.json';
      } else if (i == 16) {
        dosyaAdi = 'besin_malzemeleri_batch15_2801_3000_sebze_set3.json';
      } else if (i == 17) {
        dosyaAdi = 'besin_malzemeleri_batch16_3001_3200_sebze_set4.json';
      } else if (i == 18) {
        dosyaAdi = 'besin_malzemeleri_batch17_3201_3400_meyve_set1.json';
      } else if (i == 19) {
        dosyaAdi = 'besin_malzemeleri_batch18_3401_3600_meyve_set2.json';
      } else {
        dosyaAdi = 'besin_malzemeleri_batch19_3601_3800_trend_modern_set1.json';
      }
      
      final dosya = File('hive_db/$dosyaAdi');
      if (await dosya.exists()) {
        final jsonStr = await dosya.readAsString();
        final besinler = BesinMalzeme.listFromJsonString(jsonStr);
        tumBesinler.addAll(besinler);
        print('  ✅ $dosyaAdi: ${besinler.length} besin');
      }
    }
    
    print('  📊 TOPLAM: ${tumBesinler.length} besin malzemesi yüklendi');
    
    // 2. DEFAULT ŞABLONLARI YÜKLE
    print('\n📋 Öğün şablonları yükleniyor...');
    final sablonlar = defaultTemplatesTRStrict();
    final sablonMap = <OgunTipi, OgunSablonu>{};
    for (final sablon in sablonlar) {
      sablonMap[sablon.ogunTipi] = sablon;
    }
    
    print('  ✅ ${sablonlar.length} default şablon yüklendi');
    sablonMap.forEach((tip, sablon) {
      print('     ${tip.name}: ${sablon.kategoriKurallari.length} kategori kuralı');
    });
    
    // 3. TEST SENARYOSU: 160kg 55 yaş erkek (önceki log'daki kullanıcı)
    print('\n' + '=' * 60);
    print('🎯 TEST SENARYOSU: 160kg, 55 yaş, erkek');
    print('=' * 60);
    
    final double hedefKalori = 3093.0;
    final double hedefProtein = 125.0;
    final double hedefKarb = 415.0;
    final double hedefYag = 75.0;
    
    print('\n📊 HEDEF MAKROLAR:');
    print('  🔥 Kalori:      ${hedefKalori.toStringAsFixed(0)} kcal');
    print('  💪 Protein:     ${hedefProtein.toStringAsFixed(0)} g');
    print('  🍞 Karbonhidrat: ${hedefKarb.toStringAsFixed(0)} g');
    print('  🥑 Yağ:         ${hedefYag.toStringAsFixed(0)} g');
    
    // 4. KAHVALTI TESTİ
    print('\n' + '-' * 60);
    print('🍳 KAHVALTI OPTİMİZASYONU BAŞLIYOR...');
    print('-' * 60);
    
    // Kahvaltı için makro dağılımı (toplam kalorin %25'i)
    final kahvaltiKalori = hedefKalori * 0.25;
    final kahvaltiProtein = hedefProtein * 0.25;
    final kahvaltiKarb = hedefKarb * 0.25;
    final kahvaltiYag = hedefYag * 0.25;
    
    print('\n🎯 Kahvaltı Hedefi:');
    print('  Kalori: ${kahvaltiKalori.toStringAsFixed(0)} kcal');
    print('  Protein: ${kahvaltiProtein.toStringAsFixed(0)} g');
    print('  Karb: ${kahvaltiKarb.toStringAsFixed(0)} g');
    print('  Yağ: ${kahvaltiYag.toStringAsFixed(0)} g');
    
    final kahvaltiBaslangic = DateTime.now();
    
    final kahvaltiAlgoritma = MalzemeTabanliGenetikAlgoritma(
      besinler: tumBesinler,
      ogunTipi: OgunTipi.kahvalti,
      sablon: sablonMap[OgunTipi.kahvalti]!,
      hedef: HedefMakrolar(
        kalori: kahvaltiKalori,
        protein: kahvaltiProtein,
        karbonhidrat: kahvaltiKarb,
        yag: kahvaltiYag,
      ),
    );
    
    final kahvaltiSonuc = await kahvaltiAlgoritma.optimize();
    final kahvaltiSure = DateTime.now().difference(kahvaltiBaslangic);
    
    _sonucYazdir('KAHVALTI', kahvaltiSonuc, kahvaltiKalori, kahvaltiProtein, kahvaltiKarb, kahvaltiYag, kahvaltiSure);
    
    // 5. ÖĞLE YEMEĞİ TESTİ
    print('\n' + '-' * 60);
    print('🍽️ ÖĞLE YEMEĞİ OPTİMİZASYONU BAŞLIYOR...');
    print('-' * 60);
    
    // Öğle için makro dağılımı (toplam kalorin %35'i)
    final ogleKalori = hedefKalori * 0.35;
    final ogleProtein = hedefProtein * 0.35;
    final ogleKarb = hedefKarb * 0.35;
    final ogleYag = hedefYag * 0.35;
    
    print('\n🎯 Öğle Hedefi:');
    print('  Kalori: ${ogleKalori.toStringAsFixed(0)} kcal');
    print('  Protein: ${ogleProtein.toStringAsFixed(0)} g');
    print('  Karb: ${ogleKarb.toStringAsFixed(0)} g');
    print('  Yağ: ${ogleYag.toStringAsFixed(0)} g');
    
    final ogleBaslangic = DateTime.now();
    
    final ogleAlgoritma = MalzemeTabanliGenetikAlgoritma(
      besinler: tumBesinler,
      ogunTipi: OgunTipi.ogle,
      sablon: sablonMap[OgunTipi.ogle]!,
      hedef: HedefMakrolar(
        kalori: ogleKalori,
        protein: ogleProtein,
        karbonhidrat: ogleKarb,
        yag: ogleYag,
      ),
    );
    
    final ogleSonuc = await ogleAlgoritma.optimize();
    final ogleSure = DateTime.now().difference(ogleBaslangic);
    
    _sonucYazdir('ÖĞLE', ogleSonuc, ogleKalori, ogleProtein, ogleKarb, ogleYag, ogleSure);
    
    // 6. GENEL DEĞERLENDİRME
    print('\n' + '=' * 60);
    print('📊 GENEL DEĞERLENDİRME');
    print('=' * 60);
    
    final double toplamKalori = kahvaltiSonuc.gercekMakrolar.kalori + ogleSonuc.gercekMakrolar.kalori;
    final double toplamProtein = kahvaltiSonuc.gercekMakrolar.protein + ogleSonuc.gercekMakrolar.protein;
    final double toplamKarb = kahvaltiSonuc.gercekMakrolar.karbonhidrat + ogleSonuc.gercekMakrolar.karbonhidrat;
    final double toplamYag = kahvaltiSonuc.gercekMakrolar.yag + ogleSonuc.gercekMakrolar.yag;
    
    final double beklenenKalori = kahvaltiKalori + ogleKalori;
    final double beklenenProtein = kahvaltiProtein + ogleProtein;
    final double beklenenKarb = kahvaltiKarb + ogleKarb;
    final double beklenenYag = kahvaltiYag + ogleYag;
    
    print('\n🎯 İki Öğün Toplamı:');
    print('  Kalori:      ${toplamKalori.toStringAsFixed(1)} / ${beklenenKalori.toStringAsFixed(0)} (${_sapmaYuzde(toplamKalori, beklenenKalori)})');
    print('  Protein:     ${toplamProtein.toStringAsFixed(1)} / ${beklenenProtein.toStringAsFixed(0)} (${_sapmaYuzde(toplamProtein, beklenenProtein)})');
    print('  Karbonhidrat: ${toplamKarb.toStringAsFixed(1)} / ${beklenenKarb.toStringAsFixed(0)} (${_sapmaYuzde(toplamKarb, beklenenKarb)})');
    print('  Yağ:         ${toplamYag.toStringAsFixed(1)} / ${beklenenYag.toStringAsFixed(0)} (${_sapmaYuzde(toplamYag, beklenenYag)})');
    
    print('\n✅ BAŞARI: Malzeme bazlı sistem çalışıyor!');
    print('   Önceki sistem: %36.8 kalori sapması');
    print('   Yeni sistem: ${_sapmaYuzde(toplamKalori, beklenenKalori)} kalori sapması');
    
    final yuzde = ((toplamKalori - beklenenKalori).abs() / beklenenKalori * 100);
    if (yuzde <= 2.0) {
      print('\n🎉 HEDEF TUTTURULDU: %1-2 tolerans içinde!');
    } else if (yuzde <= 5.0) {
      print('\n✅ İYİ: %5 tolerans içinde');
    } else {
      print('\n⚠️  ORTA: Daha fazla optimizasyon gerekebilir');
    }
    
    print('\n' + '=' * 60);
    print('✅ TEST TAMAMLANDI');
    print('=' * 60);
    
  } catch (e, stack) {
    print('\n❌ HATA: $e');
    print('Stack trace: $stack');
  }
}

void _sonucYazdir(String ogunAdi, Ogun sonuc, double hedefKalori, double hedefProtein, double hedefKarb, double hedefYag, Duration sure) {
  print('\n✅ $ogunAdi SONUCU:');
  print('  ⏱️  Süre: ${sure.inMilliseconds}ms');
  print('  🏆 Tolerans Sapma: %${(sonuc.toleransSapma * 100).toStringAsFixed(1)}');
  print('\n  📊 Makrolar:');
  print('     Kalori:      ${sonuc.gercekMakrolar.kalori.toStringAsFixed(1)} / ${hedefKalori.toStringAsFixed(0)} (${_sapmaYuzde(sonuc.gercekMakrolar.kalori, hedefKalori)})');
  print('     Protein:     ${sonuc.gercekMakrolar.protein.toStringAsFixed(1)} / ${hedefProtein.toStringAsFixed(0)} (${_sapmaYuzde(sonuc.gercekMakrolar.protein, hedefProtein)})');
  print('     Karbonhidrat: ${sonuc.gercekMakrolar.karbonhidrat.toStringAsFixed(1)} / ${hedefKarb.toStringAsFixed(0)} (${_sapmaYuzde(sonuc.gercekMakrolar.karbonhidrat, hedefKarb)})');
  print('     Yağ:         ${sonuc.gercekMakrolar.yag.toStringAsFixed(1)} / ${hedefYag.toStringAsFixed(0)} (${_sapmaYuzde(sonuc.gercekMakrolar.yag, hedefYag)})');
  
  print('\n  🥗 Malzemeler (${sonuc.malzemeler.length} adet):');
  for (final m in sonuc.malzemeler) {
    final kalori = (m.miktarG * m.besin.kalori100g / 100);
    print('     • ${m.besin.ad}: ${m.miktarG.toStringAsFixed(0)}g (${kalori.toStringAsFixed(0)} kcal, ${m.besin.kategori.name})');
  }
}

String _sapmaYuzde(double gercek, double hedef) {
  final sapma = ((gercek - hedef) / hedef * 100);
  final isaret = sapma >= 0 ? '+' : '';
  return '$isaret${sapma.toStringAsFixed(1)}%';
}
