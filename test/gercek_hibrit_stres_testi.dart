// ============================================================================
// test/gercek_hibrit_stres_testi.dart
// GERÇEK DB + HİBRİT SİSTEM STRES TESTİ (Mock DEĞİL!)
// GPT-5 Pro Data + AIBeslenmeServisi + HiveService Integration
// ============================================================================

import 'dart:io';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';

// 🔥 GERÇEK IMPORT'LAR - Mock değil!
import '../lib/data/local/hive_service.dart';
import '../lib/domain/services/ai_beslenme_servisi.dart';
import '../lib/domain/entities/kullanici_profili.dart';
import '../lib/domain/entities/hedef.dart';
import '../lib/domain/entities/gunluk_plan.dart';
import '../lib/domain/usecases/makro_hesapla.dart';
import '../lib/core/utils/app_logger.dart';
import '../lib/core/utils/logger.dart';
import '../lib/core/constants/app_constants.dart';

// ============================================================================
// GERÇEK PROFİL VERİLERİ (20 FAR KLI DEMOGRAFİK)
// ============================================================================

class GercekProfilGenerator {
  static List<TestProfili> get testProfilleri => [
    // 🔥 CUT PROFİLLERİ (8 profil) - Definasyon
    TestProfili(
      ad: "Ahmet CUT",
      yas: 28, boy: 178, kilo: 85, hedefKilo: 78,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloVermek, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1800, kategori: "CUT"
    ),
    TestProfili(
      ad: "Ayşe CUT",
      yas: 25, boy: 165, kilo: 68, hedefKilo: 60,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloVermek, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1400, kategori: "CUT"
    ),
    TestProfili(
      ad: "Mehmet AGRESIF CUT",
      yas: 32, boy: 175, kilo: 90, hedefKilo: 80,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloVer, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1600, kategori: "CUT"
    ),
    TestProfili(
      ad: "Zeynep LEAN CUT",
      yas: 29, boy: 170, kilo: 72, hedefKilo: 66,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloVer, diyetTipi: DiyetTipi.vejetaryen,
      beklenenKalori: 1650, kategori: "CUT"
    ),
    TestProfili(
      ad: "Can VEGAN CUT",
      yas: 26, boy: 172, kilo: 78, hedefKilo: 72,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloVermek, diyetTipi: DiyetTipi.vegan,
      beklenenKalori: 1750, kategori: "CUT"
    ),
    TestProfili(
      ad: "Elif KADIN CUT",
      yas: 35, boy: 162, kilo: 65, hedefKilo: 58,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.kiloVermek, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1350, kategori: "CUT"
    ),
    TestProfili(
      ad: "Burak ERKEK CUT",
      yas: 24, boy: 180, kilo: 88, hedefKilo: 82,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloVer, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1950, kategori: "CUT"
    ),
    TestProfili(
      ad: "Seda OFFICE CUT",
      yas: 31, boy: 168, kilo: 70, hedefKilo: 63,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.hareketsiz,
      hedef: Hedef.kiloVermek, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 1450, kategori: "CUT"
    ),

    // 🏋️ LEAN BULK PROFİLLERİ (6 profil) - Kas Yapımı
    TestProfili(
      ad: "Emre LEAN BULK",
      yas: 27, boy: 175, kilo: 75, hedefKilo: 82,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 2800, kategori: "LEAN_BULK"
    ),
    TestProfili(
      ad: "Deniz KADIN BULK",
      yas: 26, boy: 167, kilo: 58, hedefKilo: 65,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 2400, kategori: "LEAN_BULK"
    ),
    TestProfili(
      ad: "Okan POWERLIFTER",
      yas: 30, boy: 182, kilo: 85, hedefKilo: 95,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 3200, kategori: "LEAN_BULK"
    ),
    TestProfili(
      ad: "İrem VEGET BULK",
      yas: 28, boy: 165, kilo: 55, hedefKilo: 62,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloAl, diyetTipi: DiyetTipi.vejetaryen,
      beklenenKalori: 2600, kategori: "LEAN_BULK"
    ),
    TestProfili(
      ad: "Kaan GENÇ BULK",
      yas: 22, boy: 177, kilo: 68, hedefKilo: 78,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 3000, kategori: "LEAN_BULK"
    ),
    TestProfili(
      ad: "Gizem ATLETIK",
      yas: 24, boy: 172, kilo: 62, hedefKilo: 68,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 2700, kategori: "LEAN_BULK"
    ),

    // 🚀 MEGA BULK PROFİLLERİ (3 profil) - Yüksek Kalori
    TestProfili(
      ad: "Barış MEGA BULK",
      yas: 25, boy: 185, kilo: 80, hedefKilo: 95,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 3800, kategori: "MEGA_BULK"
    ),
    TestProfili(
      ad: "Arda HARDGAINER",
      yas: 20, boy: 178, kilo: 62, hedefKilo: 75,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloAlmak, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 3600, kategori: "MEGA_BULK"
    ),
    TestProfili(
      ad: "Tolga STRONGMAN",
      yas: 33, boy: 190, kilo: 95, hedefKilo: 110,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 4200, kategori: "MEGA_BULK"
    ),

    // 🎯 MAINTENANCE PROFİLLERİ (3 profil) - Form Koruma
    TestProfili(
      ad: "Hakan MAINTAIN",
      yas: 35, boy: 176, kilo: 80, hedefKilo: 80,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.formdaKal, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 2400, kategori: "MAINTENANCE"
    ),
    TestProfili(
      ad: "Nihan FORM KORU",
      yas: 32, boy: 168, kilo: 63, hedefKilo: 63,
      cinsiyet: Cinsiyet.kadin, aktivite: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.formdaKal, diyetTipi: DiyetTipi.vejetaryen,
      beklenenKalori: 2100, kategori: "MAINTENANCE"
    ),
    TestProfili(
      ad: "Serkan OFFICE MAINTAIN",
      yas: 40, boy: 174, kilo: 78, hedefKilo: 78,
      cinsiyet: Cinsiyet.erkek, aktivite: AktiviteSeviyesi.hareketsiz,
      hedef: Hedef.formdaKal, diyetTipi: DiyetTipi.normal,
      beklenenKalori: 2200, kategori: "MAINTENANCE"
    ),
  ];
}

// ============================================================================
// TEST PROFİLİ CLASS
// ============================================================================

class TestProfili {
  final String ad;
  final int yas;
  final double boy, kilo, hedefKilo;
  final Cinsiyet cinsiyet;
  final AktiviteSeviyesi aktivite;
  final Hedef hedef;
  final DiyetTipi diyetTipi;
  final double beklenenKalori;
  final String kategori;

  TestProfili({
    required this.ad, required this.yas, required this.boy, required this.kilo, required this.hedefKilo,
    required this.cinsiyet, required this.aktivite, required this.hedef, required this.diyetTipi,
    required this.beklenenKalori, required this.kategori
  });

  KullaniciProfili toKullaniciProfili() {
    return KullaniciProfili(
      id: 'test_${ad.toLowerCase().replaceAll(' ', '_')}',
      ad: ad.split(' ')[0],
      soyad: ad.split(' ').length > 1 ? ad.split(' ').sublist(1).join(' ') : 'Test',
      yas: yas, boy: boy, mevcutKilo: kilo, hedefKilo: hedefKilo,
      cinsiyet: cinsiyet, aktiviteSeviyesi: aktivite, hedef: hedef,
      diyetTipi: diyetTipi, kayitTarihi: DateTime.now()
    );
  }
}

// ============================================================================
// DİYETİSYEN KALİTE KONTROL SİSTEMİ
// ============================================================================

class DiyetisyenKaliteAnaliz {
  static Map<String, dynamic> planAnalizi(GunlukPlan plan, TestProfili profil) {
    final analizSonucu = <String, dynamic>{
      'profil_adi': profil.ad,
      'kategori': profil.kategori,
      'hedef_kalori': profil.beklenenKalori,
      'gercek_kalori': plan.toplamKalori,
      'hedef_protein': _hesaplaHedefProtein(profil),
      'gercek_protein': plan.toplamProtein,
      'ogun_sayisi': plan.planlananOgunSayisi,
      'makro_kalitesi': plan.makroKaliteSkoru,
      'tolerans_durumu': plan.tumMakrolarToleranstaMi,
      'basari_puani': 0.0,
      'hatalar': <String>[],
      'uyarilar': <String>[],
      'diyetisyen_notu': '',
    };

    // 🔥 DİYETİSYEN STANDARDI KONTROLLER
    final hatalar = <String>[];
    final uyarilar = <String>[];
    double basariPuani = 100.0;

    // 1. ÖĞÜN SAYISI KONTROLÜ
    if (plan.planlananOgunSayisi < 4) {
      hatalar.add('Öğün sayısı yetersiz: ${plan.planlananOgunSayisi}/6');
      basariPuani -= 30;
    } else if (plan.planlananOgunSayisi < 5) {
      uyarilar.add('Öğün sayısı az: ${plan.planlananOgunSayisi}/6');
      basariPuani -= 10;
    }

    // 2. ANA ÖĞÜN KONTROLÜ
    if (plan.kahvalti == null) {
      hatalar.add('Kahvaltı eksik - KRITIK!');
      basariPuani -= 25;
    }
    if (plan.ogleYemegi == null) {
      hatalar.add('Öğle yemeği eksik - KRITIK!');
      basariPuani -= 25;
    }
    if (plan.aksamYemegi == null) {
      hatalar.add('Akşam yemeği eksik - KRITIK!');
      basariPuani -= 25;
    }

    // 3. MAKRO TOLERANS KONTROLÜ
    if (!plan.tumMakrolarToleranstaMi) {
      hatalar.add('Makro toleransı aşıldı: ${plan.toleransAsanMakrolar.join(", ")}');
      basariPuani -= 40;
    }

    // 4. KALORİ KONTROLÜ
    final kaloriSapma = ((plan.toplamKalori - profil.beklenenKalori).abs() / profil.beklenenKalori * 100);
    if (kaloriSapma > 20) {
      hatalar.add('Kalori sapması çok yüksek: ${kaloriSapma.toStringAsFixed(1)}%');
      basariPuani -= 30;
    } else if (kaloriSapma > 10) {
      uyarilar.add('Kalori sapması yüksek: ${kaloriSapma.toStringAsFixed(1)}%');
      basariPuani -= 15;
    }

    // 5. PROTEİN KONTROLÜ
    final hedefProtein = _hesaplaHedefProtein(profil);
    final proteinSapma = ((plan.toplamProtein - hedefProtein).abs() / hedefProtein * 100);
    if (proteinSapma > 20) {
      hatalar.add('Protein sapması çok yüksek: ${proteinSapma.toStringAsFixed(1)}%');
      basariPuani -= 25;
    }

    // 6. ARA ÖĞÜN KALİTESİ (BULK için önemli)
    if (profil.kategori.contains('BULK') || profil.kategori == 'MEGA_BULK') {
      if (plan.araOgun1 == null && plan.araOgun2 == null) {
        hatalar.add('BULK profili için ara öğünler eksik');
        basariPuani -= 20;
      }
      if (profil.beklenenKalori >= 3000 && plan.geceAtistirma == null) {
        uyarilar.add('Yüksek kalori hedefi için gece atıştırması önerilir');
        basariPuani -= 5;
      }
    }

    // 7. DİYET TİPİ UYGUNLUK
    if (profil.diyetTipi != DiyetTipi.normal) {
      // Bu detayı plan.ogunler'den kontrol edebiliriz ama şimdilik genel uyarı
      uyarilar.add('${profil.diyetTipi.aciklama} diyeti uygunluğu kontrol edilmeli');
    }

    // BAŞARI PUANI FİNAL HESAPLAMA
    basariPuani = basariPuani.clamp(0.0, 100.0);
    
    // DİYETİSYEN NOTU OLUŞTUR
    String diyetisyenNotu;
    if (basariPuani >= 85) {
      diyetisyenNotu = '✅ MÜKEMMEl - Profesyonel diyetisyen standartında plan';
    } else if (basariPuani >= 70) {
      diyetisyenNotu = '✅ İYİ - Kabul edilebilir kalitede plan, küçük iyileştirmeler gerekli';
    } else if (basariPuani >= 50) {
      diyetisyenNotu = '⚠️ ORTA - Ciddi eksiklikler var, revizyon gerekli';
    } else {
      diyetisyenNotu = '❌ KÖTÜ - Diyetisyen standartlarının çok altında, yeniden yapılmalı';
    }

    analizSonucu['basari_puani'] = basariPuani;
    analizSonucu['hatalar'] = hatalar;
    analizSonucu['uyarilar'] = uyarilar;
    analizSonucu['diyetisyen_notu'] = diyetisyenNotu;

    return analizSonucu;
  }

  static double _hesaplaHedefProtein(TestProfili profil) {
    // Diyetisyen standardı: Vücut ağırlığının 1.2-2.2 katı (aktivite seviyesine göre)
    double carpan;
    switch (profil.aktivite) {
      case AktiviteSeviyesi.hareketsiz:
        carpan = 1.2;
        break;
      case AktiviteSeviyesi.hafifAktif:
        carpan = 1.4;
        break;
      case AktiviteSeviyesi.ortaAktif:
        carpan = 1.7;
        break;
      case AktiviteSeviyesi.cokAktif:
        carpan = 2.0;
        break;
    }

    // Hedef için (kilo verme/alma durumunda farklı hesaplama)
    if (profil.hedef == Hedef.kiloVermek || profil.hedef == Hedef.kasKazanKiloVer) {
      return profil.hedefKilo! * carpan;
    } else {
      return profil.kilo * carpan;
    }
  }
}

// ============================================================================
// ANA TEST SİSTEMİ
// ============================================================================

class GercekHibritStresTesti {
  static late AIBeslenmeServisi aiServisi;
  static final Random random = Random();

  static Future<void> main() async {
    print('🚀 GERÇEK DB + HİBRİT SİSTEM STRES TESTİ BAŞLADI');
    print('📊 20 Farklı Demografik Profil ile Test');
    print('🔥 Mock DEĞİL - GERÇEK HiveService + AIBeslenmeServisi');
    print('=' * 80);

    final sonuclar = <Map<String, dynamic>>[];
    int basariliPlanlar = 0;
    int toplamPlanlar = 0;

    try {
      // 🔥 GERÇEK SİSTEM BAŞLATMA
      await _gercekSistemBaslat();
      
      // 🔥 GERÇEK DB DURUMU KONTROL
      await _dbDurumKontrol();

      // 🔥 20 PROFİL İLE TEST
      final testProfilleri = GercekProfilGenerator.testProfilleri;
      
      for (int i = 0; i < testProfilleri.length; i++) {
        final profil = testProfilleri[i];
        print('\n🎯 PROFİL ${i + 1}/20: ${profil.ad} (${profil.kategori})');
        print('   Hedef: ${profil.beklenenKalori.toInt()} kcal | ${profil.hedef.aciklama}');
        
        try {
          toplamPlanlar++;
          final sonuc = await _profilTesti(profil);
          sonuclar.add(sonuc);
          
          if (sonuc['basari_puani'] >= 70) {
            basariliPlanlar++;
            print('   ✅ BAŞARILI: ${sonuc['basari_puani'].toStringAsFixed(1)}/100');
          } else {
            print('   ❌ BAŞARISIZ: ${sonuc['basari_puani'].toStringAsFixed(1)}/100');
            print('   🔍 Hatalar: ${sonuc['hatalar'].join(", ")}');
          }
          
        } catch (e) {
          print('   💥 HATA: $e');
          sonuclar.add({
            'profil_adi': profil.ad,
            'kategori': profil.kategori,
            'basari_puani': 0.0,
            'hatalar': ['Sistem hatası: $e'],
            'diyetisyen_notu': '❌ TEST BAŞARISIZ - Sistem hatası'
          });
        }
        
        // Her testten sonra kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
      }

      // 🔥 SONUÇ ANALİZİ
      await _sonucAnalizi(sonuclar, basariliPlanlar, toplamPlanlar);

    } catch (e, stackTrace) {
      print('💥 KRITIK SISTEM HATASI: $e');
      print('📋 StackTrace: $stackTrace');
    }

    print('\n🏁 TEST TAMAMLANDI!');
  }

  static Future<void> _gercekSistemBaslat() async {
    print('\n🔧 GERÇEK SİSTEM BAŞLATILIYOR...');
    
    // Hive başlat (test modunda)
    await HiveService.init(isTest: true);
    print('✅ HiveService başlatıldı (test modu)');
    
    // AI Servisi başlat
    aiServisi = AIBeslenmeServisi();
    print('✅ AIBeslenmeServisi hazırlandı');
    
    print('🎯 Sistem başlatma tamamlandı!\n');
  }

  static Future<void> _dbDurumKontrol() async {
    print('🔍 GERÇEK DB DURUMU KONTROL EDİLİYOR...');
    
    try {
      final yemekSayisi = await HiveService.yemekSayisi();
      final kategoriSayilari = await HiveService.kategoriSayilari();
      
      print('📊 Toplam Yemek: $yemekSayisi');
      print('📋 Kategori Dağılımı:');
      kategoriSayilari.forEach((kategori, sayi) {
        print('   • $kategori: $sayi adet');
      });
      
      if (yemekSayisi == 0) {
        throw Exception('DB BOŞ! Migration yapılmamış olabilir.');
      }
      
      if (yemekSayisi < 1000) {
        print('⚠️ UYARI: Yemek sayısı az ($yemekSayisi), test sonuçları etkilenebilir');
      }
      
      print('✅ DB durumu uygun\n');
      
    } catch (e) {
      print('❌ DB DURUM KONTROLÜ BAŞARISIZ: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> _profilTesti(TestProfili testProfili) async {
    // KullaniciProfili entity oluştur
    final profil = testProfili.toKullaniciProfili();
    
    // Makro hedefleri hesapla (gerçek sistem kullanarak)
    final makroHesaplayici = MakroHesapla();
    final makroHedefleri = makroHesaplayici.tamHesaplama(profil);
    
    print('   📊 Hesaplanan Hedefler:');
    print('      Kalori: ${makroHedefleri.gunlukKalori.toInt()} kcal');
    print('      Protein: ${makroHedefleri.gunlukProtein.toInt()}g');
    print('      Karb: ${makroHedefleri.gunlukKarbonhidrat.toInt()}g');
    print('      Yağ: ${makroHedefleri.gunlukYag.toInt()}g');
    
    // Gerçek AI sistemi ile plan oluştur
    final plan = await aiServisi.gunlukPlanOlustur(
      hedefKalori: makroHedefleri.gunlukKalori,
      hedefProtein: makroHedefleri.gunlukProtein,
      hedefKarb: makroHedefleri.gunlukKarbonhidrat,
      hedefYag: makroHedefleri.gunlukYag,
      hedef: profil.hedef,
      kisitlamalar: profil.tumKisitlamalar,
      tarih: DateTime.now(),
    );
    
    print('   🍽️ Oluşturulan Plan:');
    print('      Kahvaltı: ${plan.kahvalti?.ad ?? 'YOK'}');
    print('      Ara1: ${plan.araOgun1?.ad ?? 'YOK'}');
    print('      Öğle: ${plan.ogleYemegi?.ad ?? 'YOK'}');
    print('      Ara2: ${plan.araOgun2?.ad ?? 'YOK'}');
    print('      Akşam: ${plan.aksamYemegi?.ad ?? 'YOK'}');
    print('      Gece: ${plan.geceAtistirma?.ad ?? 'YOK'}');
    print('   📈 Toplam: ${plan.toplamKalori.toInt()} kcal, ${plan.toplamProtein.toInt()}g protein');
    
    // Diyetisyen kalite analizi
    final analiz = DiyetisyenKaliteAnaliz.planAnalizi(plan, testProfili);
    
    return analiz;
  }

  static Future<void> _sonucAnalizi(List<Map<String, dynamic>> sonuclar, int basarili, int toplam) async {
    print('\n' + '=' * 80);
    print('📊 GERÇEK HİBRİT STRES TESTİ SONUÇLARI');
    print('=' * 80);
    
    final basariOrani = (basarili / toplam * 100);
    print('🎯 GENEL BAŞARI ORANI: ${basariOrani.toStringAsFixed(1)}% ($basarili/$toplam)');
    
    // Kategori bazında analiz
    final kategoriAnaliz = <String, List<double>>{};
    for (final sonuc in sonuclar) {
      final kategori = sonuc['kategori'] as String;
      final puan = sonuc['basari_puani'] as double;
      kategoriAnaliz[kategori] ??= [];
      kategoriAnaliz[kategori]!.add(puan);
    }
    
    print('\n📋 KATEGORİ BAZINDA PERFORMANS:');
    kategoriAnaliz.forEach((kategori, puanlar) {
      final ortalama = puanlar.fold(0.0, (a, b) => a + b) / puanlar.length;
      final basariliSayi = puanlar.where((p) => p >= 70).length;
      print('   $kategori: ${ortalama.toStringAsFixed(1)}/100 (${basariliSayi}/${puanlar.length} başarılı)');
    });
    
    // En iyi ve en kötü performanslar
    sonuclar.sort((a, b) => (b['basari_puani'] as double).compareTo(a['basari_puani'] as double));
    
    print('\n🏆 EN İYİ 3 PERFORMANS:');
    for (int i = 0; i < 3 && i < sonuclar.length; i++) {
      final s = sonuclar[i];
      print('   ${i + 1}. ${s['profil_adi']}: ${s['basari_puani'].toStringAsFixed(1)}/100');
      print('      ${s['diyetisyen_notu']}');
    }
    
    print('\n📉 EN KÖTÜ 3 PERFORMANS:');
    for (int i = sonuclar.length - 3; i < sonuclar.length && i >= 0; i++) {
      if (i < 0) continue;
      final s = sonuclar[i];
      print('   ${sonuclar.length - i}. ${s['profil_adi']}: ${s['basari_puani'].toStringAsFixed(1)}/100');
      print('      Hatalar: ${(s['hatalar'] as List).join(", ")}');
    }
    
    // Karşılaştırmalı analiz
    print('\n🔍 SİSTEM KARŞILAŞTIRMALARİ:');
    if (basariOrani >= 75) {
      print('✅ DİYETİSYEN SEVİYESİ: Profesyonel kalitede sistem');
    } else if (basariOrani >= 60) {
      print('⚠️ ORTA SEVİYE: İyileştirme gerekli ama kullanılabilir');
    } else if (basariOrani >= 40) {
      print('❌ DÜŞÜK SEVİYE: Ciddi problemler var');
    } else {
      print('💥 KRİTİK SEVİYE: Sistem başarısız');
    }
    
    print('\n🎭 MOCK vs GERÇEK SİSTEM:');
    print('   • Bu test GERÇEK HiveService + AIBeslenmeServisi kullandı');
    print('   • GPT-5 Pro veriler migration ile yüklendi');
    print('   • 20 demografik varyasyon test edildi');
    print('   • Diyetisyen seviyesinde kalite kontrolü uygulandı');
    
    // Detaylı rapor dosyaya kaydet
    await _detayliRaporKaydet(sonuclar, basariOrani);
  }

  static Future<void> _detayliRaporKaydet(List<Map<String, dynamic>> sonuclar, double basariOrani) async {
    final rapor = StringBuffer();
    rapor.writeln('GERÇEK HİBRİT STRES TESTİ DETAYLI RAPORU');
    rapor.writeln('Tarih: ${DateTime.now()}');
    rapor.writeln('Sistem: HiveService + AIBeslenmeServisi (GERÇEK)');
    rapor.writeln('Genel Başarı: ${basariOrani.toStringAsFixed(1)}%');
    rapor.writeln('=' * 80);
    
    for (int i = 0; i < sonuclar.length; i++) {
      final s = sonuclar[i];
      rapor.writeln('\n${i + 1}. ${s['profil_adi']} (${s['kategori']})');
      rapor.writeln('   Başarı Puanı: ${s['basari_puani'].toStringAsFixed(1)}/100');
      rapor.writeln('   Hedef Kalori: ${s['hedef_kalori']} kcal');
      rapor.writeln('   Gerçek Kalori: ${s['gercek_kalori'].toStringAsFixed(0)} kcal');
      rapor.writeln('   Hedef Protein: ${s['hedef_protein'].toStringAsFixed(1)}g');
      rapor.writeln('   Gerçek Protein: ${s['gercek_protein'].toStringAsFixed(1)}g');
      rapor.writeln('   Öğün Sayısı: ${s['ogun_sayisi']}');
      rapor.writeln('   Makro Kalitesi: ${s['makro_kalitesi'].toStringAsFixed(1)}');
      rapor.writeln('   Tolerans Durumu: ${s['tolerans_durumu']}');
      rapor.writeln('   Diyetisyen Notu: ${s['diyetisyen_notu']}');
      if ((s['hatalar'] as List).isNotEmpty) {
        rapor.writeln('   Hatalar: ${(s['hatalar'] as List).join(", ")}');
      }
      if ((s['uyarilar'] as List).isNotEmpty) {
        rapor.writeln('   Uyarılar: ${(s['uyarilar'] as List).join(", ")}');
      }
      rapor.writeln('   ${'-' * 40}');
    }
    
    try {
      final file = File('GERCEK_HIBRIT_STRES_TEST_RAPORU.md');
      await file.writeAsString(rapor.toString());
      print('📄 Detaylı rapor kaydedildi: ${file.path}');
    } catch (e) {
      print('⚠️ Rapor kaydetme hatası: $e');
    }
  }
}

// ============================================================================
// MAIN FONKSİYONU
// ============================================================================

void main() async {
  await GercekHibritStresTesti.main();
}