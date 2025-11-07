import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

// Proje entity ve servislerini import et
import 'lib/domain/entities/kullanici_profili.dart';
import 'lib/domain/entities/hedef.dart';
import 'lib/domain/entities/gunluk_plan.dart';
import 'lib/domain/services/ai_beslenme_servisi.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/core/utils/app_logger.dart';

// Bu script, 50 farklı ve zorlayıcı profil için 7 günlük diyet planları oluşturarak
// AIBeslenmeServisi'ni stres testine tabi tutar.
// KULLANIM: dart run stres_testi_50_profil.dart

// Test için kullanılacak 50 çeşitli profil - ULTRA KAPSAMLI STRES TESTİ
final List<Map<String, dynamic>> testProfilleri = [
  // GRUP 1: Kilo Verme (Cut) - Çeşitli Aktivite Seviyeleri
  {'ad': 'Ali', 'cinsiyet': Cinsiyet.erkek, 'yas': 30, 'boy': 180, 'kilo': 95, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Ayşe', 'cinsiyet': Cinsiyet.kadin, 'yas': 28, 'boy': 165, 'kilo': 75, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Mehmet', 'cinsiyet': Cinsiyet.erkek, 'yas': 45, 'boy': 175, 'kilo': 110, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},
  {'ad': 'Fatma', 'cinsiyet': Cinsiyet.kadin, 'yas': 35, 'boy': 160, 'kilo': 80, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Can', 'cinsiyet': Cinsiyet.erkek, 'yas': 22, 'boy': 185, 'kilo': 90, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Zehra', 'cinsiyet': Cinsiyet.kadin, 'yas': 40, 'boy': 158, 'kilo': 85, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Kemal', 'cinsiyet': Cinsiyet.erkek, 'yas': 55, 'boy': 172, 'kilo': 105, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},
  {'ad': 'Elif', 'cinsiyet': Cinsiyet.kadin, 'yas': 25, 'boy': 170, 'kilo': 70, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Murat', 'cinsiyet': Cinsiyet.erkek, 'yas': 35, 'boy': 178, 'kilo': 98, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Sibel', 'cinsiyet': Cinsiyet.kadin, 'yas': 32, 'boy': 166, 'kilo': 78, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hafifAktif},

  // GRUP 2: Kilo Alma (Bulk) - Çeşitli Aktivite Seviyeleri
  {'ad': 'Burak', 'cinsiyet': Cinsiyet.erkek, 'yas': 25, 'boy': 190, 'kilo': 75, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Buse', 'cinsiyet': Cinsiyet.kadin, 'yas': 23, 'boy': 170, 'kilo': 50, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Hakan', 'cinsiyet': Cinsiyet.erkek, 'yas': 32, 'boy': 178, 'kilo': 65, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Selin', 'cinsiyet': Cinsiyet.kadin, 'yas': 29, 'boy': 168, 'kilo': 52, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Ozan', 'cinsiyet': Cinsiyet.erkek, 'yas': 20, 'boy': 182, 'kilo': 68, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Pınar', 'cinsiyet': Cinsiyet.kadin, 'yas': 26, 'boy': 164, 'kilo': 48, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Cem', 'cinsiyet': Cinsiyet.erkek, 'yas': 28, 'boy': 185, 'kilo': 70, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Gizem', 'cinsiyet': Cinsiyet.kadin, 'yas': 24, 'boy': 172, 'kilo': 55, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Tolga', 'cinsiyet': Cinsiyet.erkek, 'yas': 30, 'boy': 188, 'kilo': 72, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Neslihan', 'cinsiyet': Cinsiyet.kadin, 'yas': 27, 'boy': 166, 'kilo': 51, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},

  // GRUP 3: Kilo Koruma (Maintenance)
  {'ad': 'Deniz', 'cinsiyet': Cinsiyet.kadin, 'yas': 38, 'boy': 162, 'kilo': 58, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Emre', 'cinsiyet': Cinsiyet.erkek, 'yas': 40, 'boy': 180, 'kilo': 82, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Tuğba', 'cinsiyet': Cinsiyet.kadin, 'yas': 34, 'boy': 168, 'kilo': 62, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Barış', 'cinsiyet': Cinsiyet.erkek, 'yas': 36, 'boy': 176, 'kilo': 78, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Canan', 'cinsiyet': Cinsiyet.kadin, 'yas': 42, 'boy': 160, 'kilo': 60, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.hareketsiz},

  // GRUP 4: Kas Kazanıp Kilo Al (Lean Bulk)
  {'ad': 'Genç Sporcu', 'cinsiyet': Cinsiyet.kadin, 'yas': 19, 'boy': 175, 'kilo': 60, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Fitness Adnan', 'cinsiyet': Cinsiyet.erkek, 'yas': 24, 'boy': 183, 'kilo': 73, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Sporcu Melis', 'cinsiyet': Cinsiyet.kadin, 'yas': 22, 'boy': 169, 'kilo': 58, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Crossfit Can', 'cinsiyet': Cinsiyet.erkek, 'yas': 27, 'boy': 181, 'kilo': 76, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Bikini Tulin', 'cinsiyet': Cinsiyet.kadin, 'yas': 25, 'boy': 167, 'kilo': 57, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},

  // GRUP 5: Kas Kazanıp Kilo Ver (Cut/Recomp)
  {'ad': 'Definisyon Ali', 'cinsiyet': Cinsiyet.erkek, 'yas': 29, 'boy': 177, 'kilo': 88, 'hedef': Hedef.kasKazanKiloVer, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Cut Aylin', 'cinsiyet': Cinsiyet.kadin, 'yas': 31, 'boy': 165, 'kilo': 68, 'hedef': Hedef.kasKazanKiloVer, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Recomp Mert', 'cinsiyet': Cinsiyet.erkek, 'yas': 33, 'boy': 179, 'kilo': 85, 'hedef': Hedef.kasKazanKiloVer, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Shred Damla', 'cinsiyet': Cinsiyet.kadin, 'yas': 28, 'boy': 163, 'kilo': 65, 'hedef': Hedef.kasKazanKiloVer, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Bodybuilder Kaan', 'cinsiyet': Cinsiyet.erkek, 'yas': 26, 'boy': 184, 'kilo': 92, 'hedef': Hedef.kasKazanKiloVer, 'aktivite': AktiviteSeviyesi.cokAktif},

  // GRUP 6: ÖZEL DURUMLAR - Yaşlı Bireyler (55+)
  {'ad': 'Yaşlı Adam', 'cinsiyet': Cinsiyet.erkek, 'yas': 65, 'boy': 170, 'kilo': 85, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},
  {'ad': 'Mature Hanım', 'cinsiyet': Cinsiyet.kadin, 'yas': 62, 'boy': 156, 'kilo': 72, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Senior Erkek', 'cinsiyet': Cinsiyet.erkek, 'yas': 58, 'boy': 174, 'kilo': 90, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Yaşlı Kadın', 'cinsiyet': Cinsiyet.kadin, 'yas': 60, 'boy': 159, 'kilo': 68, 'hedef': Hedef.formdaKal, 'aktivite': AktiviteSeviyesi.hareketsiz},

  // GRUP 7: ÖZEL DURUMLAR - Genç Bireyler (16-20)
  {'ad': 'Genç Adam', 'cinsiyet': Cinsiyet.erkek, 'yas': 18, 'boy': 186, 'kilo': 70, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Genç Kız', 'cinsiyet': Cinsiyet.kadin, 'yas': 17, 'boy': 161, 'kilo': 48, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Teen Sporcu', 'cinsiyet': Cinsiyet.erkek, 'yas': 19, 'boy': 180, 'kilo': 68, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Genç Atlet', 'cinsiyet': Cinsiyet.kadin, 'yas': 18, 'boy': 173, 'kilo': 56, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},

  // GRUP 8: ÖZEL DURUMLAR - Obezite ve Aşırı Kilo
  {'ad': 'Obez Birey', 'cinsiyet': Cinsiyet.erkek, 'yas': 38, 'boy': 170, 'kilo': 130, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},
  {'ad': 'Kilolu Hanım', 'cinsiyet': Cinsiyet.kadin, 'yas': 45, 'boy': 155, 'kilo': 95, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},
  {'ad': 'Aşırı Kilolu', 'cinsiyet': Cinsiyet.erkek, 'yas': 42, 'boy': 168, 'kilo': 115, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'Obez Kadın', 'cinsiyet': Cinsiyet.kadin, 'yas': 39, 'boy': 162, 'kilo': 105, 'hedef': Hedef.kiloVermek, 'aktivite': AktiviteSeviyesi.hareketsiz},

  // GRUP 9: ÖZEL DURUMLAR - Aşırı Zayıf (BMI <18.5)
  {'ad': 'Zayıf Erkek', 'cinsiyet': Cinsiyet.erkek, 'yas': 21, 'boy': 190, 'kilo': 62, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.hafifAktif},
  {'ad': 'İnce Kız', 'cinsiyet': Cinsiyet.kadin, 'yas': 24, 'boy': 168, 'kilo': 45, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.ortaAktif},
  {'ad': 'Çok Zayıf', 'cinsiyet': Cinsiyet.erkek, 'yas': 26, 'boy': 185, 'kilo': 58, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Underweight', 'cinsiyet': Cinsiyet.kadin, 'yas': 23, 'boy': 174, 'kilo': 50, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.ortaAktif},

  // GRUP 10: MEGA KALORİ TEST GRUPLARI - Yüksek Kalori İhtiyaçları (3000+ kcal)
  {'ad': 'Mega Bulk', 'cinsiyet': Cinsiyet.erkek, 'yas': 23, 'boy': 195, 'kilo': 85, 'hedef': Hedef.kiloAlmak, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Power Lifter', 'cinsiyet': Cinsiyet.erkek, 'yas': 29, 'boy': 188, 'kilo': 95, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
  {'ad': 'Strong Woman', 'cinsiyet': Cinsiyet.kadin, 'yas': 27, 'boy': 178, 'kilo': 70, 'hedef': Hedef.kasKazanKiloAl, 'aktivite': AktiviteSeviyesi.cokAktif},
];

// Basit makro hesaplayıcı (Harris-Benedict) - TİP GÜVENLİ VERSİYON
Map<String, double> makroHesapla(KullaniciProfili profil) {
  double bmr;
  if (profil.cinsiyet == Cinsiyet.erkek) {
    bmr = 88.362 + (13.397 * profil.mevcutKilo.toDouble()) + (4.799 * profil.boy.toDouble()) - (5.677 * profil.yas.toDouble());
  } else {
    bmr = 447.593 + (9.247 * profil.mevcutKilo.toDouble()) + (3.098 * profil.boy.toDouble()) - (4.330 * profil.yas.toDouble());
  }

  double aktiviteCarpan;
  switch (profil.aktiviteSeviyesi) {
    case AktiviteSeviyesi.hareketsiz: aktiviteCarpan = 1.2; break;
    case AktiviteSeviyesi.hafifAktif: aktiviteCarpan = 1.375; break;
    case AktiviteSeviyesi.ortaAktif: aktiviteCarpan = 1.55; break;
    case AktiviteSeviyesi.cokAktif: aktiviteCarpan = 1.725; break;
  }

  double tdee = bmr * aktiviteCarpan;

  switch (profil.hedef) {
    case Hedef.kiloVermek: tdee -= 500; break;
    case Hedef.kiloAlmak: tdee += 500; break;
    case Hedef.kasKazanKiloAl: tdee += 300; break;
    case Hedef.kasKazanKiloVer: tdee -= 300; break;
    default: break;
  }

  // Protein: 1.8g/kg, Yağ: %25, Kalan Karbonhidrat
  double protein = profil.mevcutKilo.toDouble() * 1.8;
  double yag = (tdee * 0.25) / 9;
  double karb = (tdee - (protein * 4) - (yag * 9)) / 4;

  return {'kalori': tdee, 'protein': protein, 'karb': karb, 'yag': yag};
}


Future<void> main() async {
  print('🏋️‍♂️ STRES TESTİ BAŞLATILIYOR: 50 FARKLI PROFİL İLE 7 GÜNLÜK PLAN OLUŞTURMA 🏋️‍♀️');

  try {
    // 1. Hive'ı Başlat (Flutter'dan bağımsız)
    final scriptDir = p.dirname(Platform.script.toFilePath());
    Hive.init(p.join(scriptDir, 'hive_data'));

    // Hive Adaptörlerini Kaydet
    if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
      Hive.registerAdapter(KullaniciHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    // Gerekli box'ı aç
    await Hive.openBox<YemekHiveModel>('yemekler');

    final aiServisi = AIBeslenmeServisi();
    int basariliPlan = 0;
    int hataliPlan = 0;

    for (int i = 0; i < testProfilleri.length; i++) {
      final profilData = testProfilleri[i];
      final profil = KullaniciProfili(
        id: 'test_$i',
        ad: profilData['ad'],
        soyad: 'Test',
        yas: profilData['yas'], // yaş int kalır
        boy: profilData['boy'].toDouble(),
        mevcutKilo: profilData['kilo'].toDouble(),
        cinsiyet: profilData['cinsiyet'],
        aktiviteSeviyesi: profilData['aktivite'],
        hedef: profilData['hedef'],
        diyetTipi: DiyetTipi.normal,
        kayitTarihi: DateTime.now(),
      );

      final hedefler = makroHesapla(profil);
      print('\n\n--- 👨‍💻 Profil ${i + 1}/${testProfilleri.length}: ${profil.ad} (${profil.hedef.name}) ---');
      print('Hedefler -> Kalori: ${hedefler['kalori']!.toStringAsFixed(0)}, P: ${hedefler['protein']!.toStringAsFixed(0)}g, K: ${hedefler['karb']!.toStringAsFixed(0)}g, Y: ${hedefler['yag']!.toStringAsFixed(0)}g');
      print('--------------------------------------------------');

      try {
        final List<GunlukPlan> haftalikPlan = await aiServisi.haftalikPlanOlustur(
          hedefKalori: hedefler['kalori']!,
          hedefProtein: hedefler['protein']!,
          hedefKarb: hedefler['karb']!,
          hedefYag: hedefler['yag']!,
          hedef: profil.hedef,
          baslangicTarihi: DateTime.now(),
        );

        // Sonuçları analiz et
        bool haftaBasarili = true;
        for (int j = 0; j < haftalikPlan.length; j++) {
          final gunlukPlan = haftalikPlan[j];
          final kaloriSapma = ((gunlukPlan.toplamKalori - hedefler['kalori']!) / hedefler['kalori']! * 100).abs();
          final proteinSapma = ((gunlukPlan.toplamProtein - hedefler['protein']!) / hedefler['protein']! * 100).abs();
          
          String sonuc = '✅';
          if (kaloriSapma > 15 || proteinSapma > 20) {
            sonuc = '❌';
            haftaBasarili = false;
          }
          print('  Gün ${j + 1}: ${sonuc} | Kalori: ${gunlukPlan.toplamKalori.toStringAsFixed(0)} (Sapma: ${kaloriSapma.toStringAsFixed(1)}%) | Protein: ${gunlukPlan.toplamProtein.toStringAsFixed(0)}g (Sapma: ${proteinSapma.toStringAsFixed(1)}%)');
        }

        if (haftaBasarili) {
          basariliPlan++;
          print('------------------- SONUÇ: BAŞARILI -------------------');
        } else {
          hataliPlan++;
          print('------------------- SONUÇ: BAŞARISIZ (Yüksek Sapma) -------------------');
        }

      } catch (e) {
        hataliPlan++;
        print('------------------- SONUÇ: KRİTİK HATA -------------------');
        print(e);
      }
       await Future.delayed(Duration(seconds: 1)); // API limitlerini aşmamak için bekleme
    }

    print('\n\n========== STRES TESTİ TAMAMLANDI ==========');
    print('✅ Başarılı Profil Sayısı: $basariliPlan');
    print('❌ Hatalı/Başarısız Profil Sayısı: $hataliPlan');
    print('===========================================');

  } catch (e, stackTrace) {
    print('\n❌ KRİTİK HATA: Script başlatılırken sorun oluştu.');
    print(e);
    print(stackTrace);
  } finally {
    await Hive.close();
    print('\n🚪 Hive bağlantısı kapatıldı.');
  }
}
