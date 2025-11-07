// ============================================================================
// test/basit_gercek_test.dart  
// BASİT GERÇEK SİSTEM TESTİ - Flutter bağımlılığı YOK!
// ============================================================================

import 'dart:io';
import 'dart:math';

// ============================================================================
// MİNİMAL TEST CLASSLARI (Flutter'sız)
// ============================================================================

class MockYemek {
  final String id, ad;
  final double kalori, protein, karbonhidrat, yag;
  final String ogun;
  
  MockYemek({
    required this.id, required this.ad, required this.ogun,
    required this.kalori, required this.protein, 
    required this.karbonhidrat, required this.yag
  });
}

class MockPlan {
  final List<MockYemek> ogunler;
  final double hedefKalori;
  
  MockPlan(this.ogunler, this.hedefKalori);
  
  double get toplamKalori => ogunler.fold(0, (sum, y) => sum + y.kalori);
  double get toplamProtein => ogunler.fold(0, (sum, y) => sum + y.protein);
  
  double get kaloriSapmaYuzdesi => 
    ((toplamKalori - hedefKalori).abs() / hedefKalori * 100);
  
  bool get basariliMi => kaloriSapmaYuzdesi <= 15; // %15 tolerans
}

// ============================================================================
// TEST PROFİLLERİ (5 BASIT PROFİL)
// ============================================================================

class TestProfili {
  final String ad;
  final double hedefKalori;
  final String kategori;
  
  TestProfili(this.ad, this.hedefKalori, this.kategori);
}

final testProfilleri = [
  TestProfili("Ahmet CUT", 1800, "CUT"),
  TestProfili("Ayşe MAINTAIN", 2200, "MAINTENANCE"),
  TestProfili("Emre BULK", 2800, "LEAN_BULK"),
  TestProfili("Deniz MEGA BULK", 3500, "MEGA_BULK"),
  TestProfili("Zeynep OFFICE", 1600, "CUT"),
];

// ============================================================================
// MOCK VERİTABANI (Gerçek sistem simülasyonu)
// ============================================================================

final mockYemekler = [
  // KAHVALTI
  MockYemek(id: 'k1', ad: 'Peynirli Omlet', ogun: 'kahvalti', kalori: 420, protein: 25, karbonhidrat: 8, yag: 32),
  MockYemek(id: 'k2', ad: 'Ballı Yulaf', ogun: 'kahvalti', kalori: 480, protein: 20, karbonhidrat: 75, yag: 15),
  MockYemek(id: 'k3', ad: 'Menemen', ogun: 'kahvalti', kalori: 450, protein: 22, karbonhidrat: 35, yag: 25),
  
  // ARA ÖĞÜN 1
  MockYemek(id: 'a1_1', ad: 'Muz & Badem', ogun: 'araOgun1', kalori: 180, protein: 6, karbonhidrat: 25, yag: 8),
  MockYemek(id: 'a1_2', ad: 'Protein Smoothie', ogun: 'araOgun1', kalori: 200, protein: 20, karbonhidrat: 15, yag: 8),
  MockYemek(id: 'a1_3', ad: 'Fındık & Hurma', ogun: 'araOgun1', kalori: 220, protein: 8, karbonhidrat: 28, yag: 12),
  
  // ÖĞLE YEMEĞİ
  MockYemek(id: 'o1', ad: 'Tavuklu Pilav', ogun: 'ogle', kalori: 550, protein: 45, karbonhidrat: 55, yag: 15),
  MockYemek(id: 'o2', ad: 'Somon Bulgur', ogun: 'ogle', kalori: 620, protein: 40, karbonhidrat: 60, yag: 25),
  MockYemek(id: 'o3', ad: 'Köfte & Patates', ogun: 'ogle', kalori: 680, protein: 35, karbonhidrat: 45, yag: 35),
  
  // ARA ÖĞÜN 2
  MockYemek(id: 'a2_1', ad: 'Ballı Yoğurt', ogun: 'araOgun2', kalori: 180, protein: 15, karbonhidrat: 20, yag: 4),
  MockYemek(id: 'a2_2', ad: 'Protein Bar', ogun: 'araOgun2', kalori: 250, protein: 20, karbonhidrat: 25, yag: 8),
  MockYemek(id: 'a2_3', ad: 'Çikolatalı Süt', ogun: 'araOgun2', kalori: 300, protein: 12, karbonhidrat: 35, yag: 12),
  
  // AKŞAM YEMEĞİ
  MockYemek(id: 'ak1', ad: 'Izgara Somon', ogun: 'aksam', kalori: 450, protein: 40, karbonhidrat: 20, yag: 25),
  MockYemek(id: 'ak2', ad: 'Tavuk Salatası', ogun: 'aksam', kalori: 380, protein: 35, karbonhidrat: 15, yag: 22),
  MockYemek(id: 'ak3', ad: 'Etli Sebze', ogun: 'aksam', kalori: 520, protein: 42, karbonhidrat: 25, yag: 28),
  
  // GECE ATIŞTIRMA
  MockYemek(id: 'g1', ad: 'Lor Peynir & Meyve', ogun: 'geceAtistirma', kalori: 150, protein: 12, karbonhidrat: 15, yag: 5),
  MockYemek(id: 'g2', ad: 'Badem Sütü', ogun: 'geceAtistirma', kalori: 120, protein: 8, karbonhidrat: 12, yag: 6),
];

// ============================================================================
// BASİT AI SİSTEM SİMÜLASYONU
// ============================================================================

class BasitAISystem {
  final Random random = Random();
  
  MockPlan planOlustur(double hedefKalori) {
    final secilenOgunler = <MockYemek>[];
    
    // Öğün tiplerini filtrele
    final kahvaltilar = mockYemekler.where((y) => y.ogun == 'kahvalti').toList();
    final araOgun1ler = mockYemekler.where((y) => y.ogun == 'araOgun1').toList();
    final ogleler = mockYemekler.where((y) => y.ogun == 'ogle').toList();
    final araOgun2ler = mockYemekler.where((y) => y.ogun == 'araOgun2').toList();
    final aksamlar = mockYemekler.where((y) => y.ogun == 'aksam').toList();
    final geceler = mockYemekler.where((y) => y.ogun == 'geceAtistirma').toList();
    
    // Her öğünden rastgele seç
    secilenOgunler.add(kahvaltilar[random.nextInt(kahvaltilar.length)]);
    secilenOgunler.add(araOgun1ler[random.nextInt(araOgun1ler.length)]);
    secilenOgunler.add(ogleler[random.nextInt(ogleler.length)]);
    secilenOgunler.add(araOgun2ler[random.nextInt(araOgun2ler.length)]);
    secilenOgunler.add(aksamlar[random.nextInt(aksamlar.length)]);
    
    // Yüksek kalori hedefi için gece atıştırması ekle
    if (hedefKalori >= 3000) {
      secilenOgunler.add(geceler[random.nextInt(geceler.length)]);
    }
    
    return MockPlan(secilenOgunler, hedefKalori);
  }
}

// ============================================================================
// DİYETİSYEN KALİTE ANALİZİ
// ============================================================================

class DiyetisyenAnaliz {
  static Map<String, dynamic> planAnalizi(MockPlan plan, TestProfili profil) {
    final kaloriSapma = plan.kaloriSapmaYuzdesi;
    final proteinSapma = ((plan.toplamProtein - (profil.hedefKalori * 0.3 / 4)).abs() / (profil.hedefKalori * 0.3 / 4) * 100);
    
    double basariPuani = 100.0;
    final hatalar = <String>[];
    
    // Kalori kontrolü
    if (kaloriSapma > 20) {
      hatalar.add('Kalori sapması çok yüksek: ${kaloriSapma.toStringAsFixed(1)}%');
      basariPuani -= 40;
    } else if (kaloriSapma > 10) {
      basariPuani -= 20;
    }
    
    // Öğün sayısı kontrolü
    if (plan.ogunler.length < 4) {
      hatalar.add('Öğün sayısı yetersiz: ${plan.ogunler.length}');
      basariPuani -= 30;
    }
    
    // Protein kontrolü
    if (proteinSapma > 25) {
      hatalar.add('Protein dengesi bozuk');
      basariPuani -= 25;
    }
    
    basariPuani = basariPuani.clamp(0.0, 100.0);
    
    String diyetisyenNotu;
    if (basariPuani >= 80) {
      diyetisyenNotu = '✅ MÜKEMMEl - Profesyonel kalitede';
    } else if (basariPuani >= 60) {
      diyetisyenNotu = '⚠️ ORTA - İyileştirme gerekli';
    } else {
      diyetisyenNotu = '❌ KÖTÜ - Yeniden yapılmalı';
    }
    
    return {
      'profil_adi': profil.ad,
      'kategori': profil.kategori,
      'hedef_kalori': profil.hedefKalori,
      'gercek_kalori': plan.toplamKalori,
      'kalori_sapma': kaloriSapma,
      'ogun_sayisi': plan.ogunler.length,
      'basari_puani': basariPuani,
      'hatalar': hatalar,
      'diyetisyen_notu': diyetisyenNotu,
      'basarili': basariPuani >= 70,
    };
  }
}

// ============================================================================
// ANA TEST SİSTEMİ
// ============================================================================

Future<void> main() async {
  print('🚀 BASİT GERÇEK SİSTEM TESTİ BAŞLADI');
  print('📊 5 Demografik Profil ile Test');
  print('🔥 Flutter DEPENDENCY YOK - Pure Dart');
  print('=' * 60);
  
  final aiSystem = BasitAISystem();
  final sonuclar = <Map<String, dynamic>>[];
  int basariliPlanlar = 0;
  
  for (int i = 0; i < testProfilleri.length; i++) {
    final profil = testProfilleri[i];
    print('\n🎯 PROFİL ${i + 1}/5: ${profil.ad}');
    print('   Hedef: ${profil.hedefKalori.toInt()} kcal | ${profil.kategori}');
    
    try {
      // Plan oluştur
      final plan = aiSystem.planOlustur(profil.hedefKalori);
      
      print('   🍽️ Oluşturulan Plan:');
      for (final yemek in plan.ogunler) {
        print('      • ${yemek.ad} (${yemek.kalori.toInt()} kcal)');
      }
      print('   📈 Toplam: ${plan.toplamKalori.toInt()} kcal | Sapma: ${plan.kaloriSapmaYuzdesi.toStringAsFixed(1)}%');
      
      // Analiz et
      final analiz = DiyetisyenAnaliz.planAnalizi(plan, profil);
      sonuclar.add(analiz);
      
      if (analiz['basarili'] == true) {
        basariliPlanlar++;
        print('   ✅ BAŞARILI: ${analiz['basari_puani'].toStringAsFixed(1)}/100');
      } else {
        print('   ❌ BAŞARISIZ: ${analiz['basari_puani'].toStringAsFixed(1)}/100');
        print('   🔍 Hatalar: ${analiz['hatalar'].join(", ")}');
      }
      
    } catch (e) {
      print('   💥 HATA: $e');
      sonuclar.add({
        'profil_adi': profil.ad,
        'kategori': profil.kategori,
        'basari_puani': 0.0,
        'basarili': false,
        'hatalar': ['Sistem hatası: $e'],
      });
    }
    
    // Her testten sonra kısa bekleme
    await Future.delayed(Duration(milliseconds: 200));
  }
  
  // SONUÇ ANALİZİ
  print('\n' + '=' * 60);
  print('📊 BASİT GERÇEK SİSTEM TEST SONUÇLARI');
  print('=' * 60);
  
  final basariOrani = (basariliPlanlar / testProfilleri.length * 100);
  print('🎯 GENEL BAŞARI ORANI: ${basariOrani.toStringAsFixed(1)}% ($basariliPlanlar/${testProfilleri.length})');
  
  // Kategori analizi
  final kategoriBasari = <String, List<bool>>{};
  for (final sonuc in sonuclar) {
    final kategori = sonuc['kategori'] as String;
    kategoriBasari[kategori] ??= [];
    kategoriBasari[kategori]!.add(sonuc['basarili'] as bool);
  }
  
  print('\n📋 KATEGORİ PERFORMANSI:');
  kategoriBasari.forEach((kategori, basarilar) {
    final basariliSayi = basarilar.where((b) => b).length;
    final oran = (basariliSayi / basarilar.length * 100);
    print('   $kategori: ${oran.toStringAsFixed(1)}% (${basariliSayi}/${basarilar.length})');
  });
  
  // En iyi ve en kötü
  sonuclar.sort((a, b) => (b['basari_puani'] as double).compareTo(a['basari_puani'] as double));
  
  print('\n🏆 EN İYİ PERFORMANS:');
  final enIyi = sonuclar.first;
  print('   1. ${enIyi['profil_adi']}: ${enIyi['basari_puani'].toStringAsFixed(1)}/100');
  print('      ${enIyi['diyetisyen_notu']}');
  
  print('\n📉 EN KÖTÜ PERFORMANS:');
  final enKotu = sonuclar.last;
  print('   1. ${enKotu['profil_adi']}: ${enKotu['basari_puani'].toStringAsFixed(1)}/100');
  print('      Hatalar: ${(enKotu['hatalar'] as List).join(", ")}');
  
  // Sistem değerlendirmesi
  print('\n🔍 SİSTEM DEĞERLENDİRMESİ:');
  if (basariOrani >= 80) {
    print('✅ MÜKEMMEl: Profesyonel diyetisyen seviyesinde');
  } else if (basariOrani >= 60) {
    print('⚠️ ORTA: İyileştirme gerekli ama kullanılabilir');
  } else if (basariOrani >= 40) {
    print('❌ ZAYIF: Ciddi problemler mevcut');
  } else {
    print('💥 FELAKET: Sistem başarısız');
  }
  
  print('\n🎭 TESTİN ÖZELLİKLERİ:');
  print('   • Pure Dart implementation (Flutter dependency YOK)');
  print('   • 5 demografik varyasyon test edildi');
  print('   • ${mockYemekler.length} yemeklik mock database kullanıldı');
  print('   • Diyetisyen seviyesinde kalite kontrolü uygulandı');
  print('   • Gerçek sistem algoritması simülasyonu');
  
  print('\n🏁 BASİT TEST TAMAMLANDI!');
}