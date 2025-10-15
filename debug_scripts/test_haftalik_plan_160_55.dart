// Test: 160cm/55kg/kadın/kilo kaybı/orta aktif profil için haftalık plan
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';
import 'lib/domain/usecases/ogun_planlayici.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 === 160cm/55kg Kadın Profil Test Başlatılıyor ===\n');
  
  // Hive'ı başlat
  await Hive.initFlutter();
  
  // Profil bilgileri
  const boy = 160; // cm
  const kilo = 55; // kg
  const yas = 25;
  const cinsiyet = 'kadın';
  const hedef = 'kilo kaybı';
  const aktivite = 'orta aktif (haftada 3 gün)';
  
  print('📋 PROFIL BİLGİLERİ:');
  print('   Boy: $boy cm');
  print('   Kilo: $kilo kg');
  print('   Yaş: $yas');
  print('   Cinsiyet: $cinsiyet');
  print('   Hedef: $hedef');
  print('   Aktivite: $aktivite\n');
  
  // Makro hesaplama (Mifflin-St Jeor)
  print('🧮 MAKRO HESAPLAMALARI:');
  
  // BMR (Kadın): (10 × kilo) + (6.25 × boy) - (5 × yaş) - 161
  final bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
  print('   BMR (Bazal Metabolizma): ${bmr.toStringAsFixed(0)} kcal/gün');
  
  // TDEE (Orta aktif = 1.55)
  final tdee = bmr * 1.55;
  print('   TDEE (Toplam Günlük Enerji): ${tdee.toStringAsFixed(0)} kcal/gün');
  
  // Kilo kaybı için deficit (günde 500 kcal)
  final hedefKalori = tdee - 500;
  print('   Hedef Kalori (defisit ile): ${hedefKalori.toStringAsFixed(0)} kcal/gün\n');
  
  // Makro dağılımı (Protein %35, Karb %40, Yağ %25)
  final hedefProtein = (hedefKalori * 0.35) / 4; // 1g protein = 4 kcal
  final hedefKarb = (hedefKalori * 0.40) / 4; // 1g karb = 4 kcal
  final hedefYag = (hedefKalori * 0.25) / 9; // 1g yağ = 9 kcal
  
  print('📊 GÜNLÜK MAKRO HEDEFLERİ:');
  print('   Protein: ${hedefProtein.toStringAsFixed(0)}g (35%)');
  print('   Karbonhidrat: ${hedefKarb.toStringAsFixed(0)}g (40%)');
  print('   Yağ: ${hedefYag.toStringAsFixed(0)}g (25%)');
  print('   Toplam: ${hedefKalori.toStringAsFixed(0)} kcal\n');
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    // Öğün planlayıcıyı oluştur
    final dataSource = YemekHiveDataSource();
    final planlayici = OgunPlanlayici(dataSource: dataSource);
    
    print('📅 7 GÜNLÜK BESLENME PLANI OLUŞTURULUYOR...\n');
    
    final haftalikPlan = await planlayici.haftalikPlanOlustur(
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
      kisitlamalar: [], // Kısıtlama yok
    );
    
    print('\n✅ HAFTALIK PLAN OLUŞTURULDU!\n');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    // Her günü detaylı göster
    for (int i = 0; i < haftalikPlan.length; i++) {
      final gun = haftalikPlan[i];
      final gunAdi = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'][i];
      
      print('📆 ${i + 1}. GÜN - $gunAdi');
      print('   Fitness Skoru: ${gun.fitnessSkoru.toStringAsFixed(1)}/100');
      print('');
      
      // Öğünleri listele
      if (gun.kahvalti != null) {
        print('   🌅 KAHVALTI: ${gun.kahvalti!.ad}');
        print('      → ${gun.kahvalti!.kalori.toStringAsFixed(0)} kcal | P:${gun.kahvalti!.protein.toStringAsFixed(0)}g K:${gun.kahvalti!.karbonhidrat.toStringAsFixed(0)}g Y:${gun.kahvalti!.yag.toStringAsFixed(0)}g');
        print('      → Kategori: ${gun.kahvalti!.ogun.toString().split('.').last}');
        
        // ⚠️ KRİTİK KONTROL: Kahvaltıda ara öğün var mı?
        if (gun.kahvalti!.ogun.toString().contains('araOgun')) {
          print('      ⚠️⚠️⚠️ HATA: KAHVALTIDA ARA ÖĞÜN ÇIKTI! ⚠️⚠️⚠️');
        }
      }
      
      if (gun.araOgun1 != null) {
        print('   🍎 ARA ÖĞÜN 1: ${gun.araOgun1!.ad}');
        print('      → ${gun.araOgun1!.kalori.toStringAsFixed(0)} kcal | P:${gun.araOgun1!.protein.toStringAsFixed(0)}g K:${gun.araOgun1!.karbonhidrat.toStringAsFixed(0)}g Y:${gun.araOgun1!.yag.toStringAsFixed(0)}g');
      }
      
      if (gun.ogleYemegi != null) {
        print('   🍽️ ÖĞLE: ${gun.ogleYemegi!.ad}');
        print('      → ${gun.ogleYemegi!.kalori.toStringAsFixed(0)} kcal | P:${gun.ogleYemegi!.protein.toStringAsFixed(0)}g K:${gun.ogleYemegi!.karbonhidrat.toStringAsFixed(0)}g Y:${gun.ogleYemegi!.yag.toStringAsFixed(0)}g');
      }
      
      if (gun.araOgun2 != null) {
        print('   🥤 ARA ÖĞÜN 2: ${gun.araOgun2!.ad}');
        print('      → ${gun.araOgun2!.kalori.toStringAsFixed(0)} kcal | P:${gun.araOgun2!.protein.toStringAsFixed(0)}g K:${gun.araOgun2!.karbonhidrat.toStringAsFixed(0)}g Y:${gun.araOgun2!.yag.toStringAsFixed(0)}g');
      }
      
      if (gun.aksamYemegi != null) {
        print('   🌙 AKŞAM: ${gun.aksamYemegi!.ad}');
        print('      → ${gun.aksamYemegi!.kalori.toStringAsFixed(0)} kcal | P:${gun.aksamYemegi!.protein.toStringAsFixed(0)}g K:${gun.aksamYemegi!.karbonhidrat.toStringAsFixed(0)}g Y:${gun.aksamYemegi!.yag.toStringAsFixed(0)}g');
      }
      
      print('');
      print('   📊 GÜNLÜK TOPLAM:');
      print('      Kalori: ${gun.toplamKalori.toStringAsFixed(0)} / ${hedefKalori.toStringAsFixed(0)} (${((gun.toplamKalori - hedefKalori).abs() / hedefKalori * 100).toStringAsFixed(1)}% sapma)');
      print('      Protein: ${gun.toplamProtein.toStringAsFixed(0)}g / ${hedefProtein.toStringAsFixed(0)}g (${((gun.toplamProtein - hedefProtein).abs() / hedefProtein * 100).toStringAsFixed(1)}% sapma)');
      print('      Karb: ${gun.toplamKarbonhidrat.toStringAsFixed(0)}g / ${hedefKarb.toStringAsFixed(0)}g (${((gun.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb * 100).toStringAsFixed(1)}% sapma)');
      print('      Yağ: ${gun.toplamYag.toStringAsFixed(0)}g / ${hedefYag.toStringAsFixed(0)}g (${((gun.toplamYag - hedefYag).abs() / hedefYag * 100).toStringAsFixed(1)}% sapma)');
      
      // Tolerans kontrolü
      final toleransDisiMakrolar = <String>[];
      if (((gun.toplamKalori - hedefKalori).abs() / hedefKalori * 100) > 10) {
        toleransDisiMakrolar.add('Kalori');
      }
      if (((gun.toplamProtein - hedefProtein).abs() / hedefProtein * 100) > 10) {
        toleransDisiMakrolar.add('Protein');
      }
      if (((gun.toplamKarbonhidrat - hedefKarb).abs() / hedefKarb * 100) > 10) {
        toleransDisiMakrolar.add('Karbonhidrat');
      }
      if (((gun.toplamYag - hedefYag).abs() / hedefYag * 100) > 10) {
        toleransDisiMakrolar.add('Yağ');
      }
      
      if (toleransDisiMakrolar.isNotEmpty) {
        print('      ⚠️ TOLERANS DIŞI: ${toleransDisiMakrolar.join(", ")}');
      } else {
        print('      ✅ Tüm makrolar tolerans içinde (±10%)');
      }
      
      print('');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
    
    // Genel istatistikler
    print('📈 HAFTALIK GENEL İSTATİSTİKLER:\n');
    
    final ortalamaKalori = haftalikPlan.map((g) => g.toplamKalori).reduce((a, b) => a + b) / 7;
    final ortalamaProtein = haftalikPlan.map((g) => g.toplamProtein).reduce((a, b) => a + b) / 7;
    final ortalamaKarb = haftalikPlan.map((g) => g.toplamKarbonhidrat).reduce((a, b) => a + b) / 7;
    final ortalamaYag = haftalikPlan.map((g) => g.toplamYag).reduce((a, b) => a + b) / 7;
    final ortalamaFitness = haftalikPlan.map((g) => g.fitnessSkoru).reduce((a, b) => a + b) / 7;
    
    print('   Ortalama Kalori: ${ortalamaKalori.toStringAsFixed(0)} kcal/gün');
    print('   Ortalama Protein: ${ortalamaProtein.toStringAsFixed(0)}g/gün');
    print('   Ortalama Karbonhidrat: ${ortalamaKarb.toStringAsFixed(0)}g/gün');
    print('   Ortalama Yağ: ${ortalamaYag.toStringAsFixed(0)}g/gün');
    print('   Ortalama Fitness Skoru: ${ortalamaFitness.toStringAsFixed(1)}/100\n');
    
    // Kahvaltıda ara öğün kontrolü
    print('🔍 KRİTİK KONTROLLER:\n');
    int kahvaltidaAraOgunSayisi = 0;
    for (final gun in haftalikPlan) {
      if (gun.kahvalti != null && gun.kahvalti!.ogun.toString().contains('araOgun')) {
        kahvaltidaAraOgunSayisi++;
      }
    }
    
    if (kahvaltidaAraOgunSayisi > 0) {
      print('   ❌ HATA: $kahvaltidaAraOgunSayisi günde kahvaltıda ara öğün çıktı!');
    } else {
      print('   ✅ Kahvaltılarda ara öğün sorunu YOK');
    }
    
    // Çeşitlilik kontrolü
    final benzersizKahvaltilar = haftalikPlan.map((g) => g.kahvalti?.id).toSet().length;
    final benzersizOgleler = haftalikPlan.map((g) => g.ogleYemegi?.id).toSet().length;
    final benzersizAksamlar = haftalikPlan.map((g) => g.aksamYemegi?.id).toSet().length;
    
    print('   Benzersiz kahvaltı sayısı: $benzersizKahvaltilar/7 ${benzersizKahvaltilar >= 5 ? "✅" : "⚠️"}');
    print('   Benzersiz öğle yemeği sayısı: $benzersizOgleler/7 ${benzersizOgleler >= 5 ? "✅" : "⚠️"}');
    print('   Benzersiz akşam yemeği sayısı: $benzersizAksamlar/7 ${benzersizAksamlar >= 5 ? "✅" : "⚠️"}');
    
    print('\n✅ TEST TAMAMLANDI!\n');
    
  } catch (e, stackTrace) {
    print('\n❌ HATA OLUŞTU: $e');
    print('Stack Trace:\n$stackTrace');
    exit(1);
  }
  
  exit(0);
}
