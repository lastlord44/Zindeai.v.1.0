import '../entities/hedef.dart';
import '../entities/kullanici_profili.dart';
import '../entities/makro_hedefleri.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';

class MakroHesapla {
  /// BMR hesaplama (Mifflin-St Jeor)
  double bmrHesapla({
    required double kilo,
    required double boy,
    required int yas,
    required Cinsiyet cinsiyet,
  }) {
    double bmr;
    if (cinsiyet == Cinsiyet.erkek) {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) + 5;
    } else {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    }
    return bmr;
  }

  /// TDEE hesaplama
  double tdeeHesapla(double bmr, AktiviteSeviyesi aktivite) {
    final carpanlar = {
      AktiviteSeviyesi.hareketsiz: 1.2,
      AktiviteSeviyesi.hafifAktif: 1.375,
      AktiviteSeviyesi.ortaAktif: 1.55,
      AktiviteSeviyesi.cokAktif: 1.725,
    };

    final tdee = bmr * (carpanlar[aktivite] ?? 1.2);
    return tdee;
  }

  /// Hedefe göre kalori ayarla
  double hedefKaloriHesapla(double tdee, Hedef hedef) {
    double hedefKalori;
    switch (hedef) {
      case Hedef.kiloVermek:
        hedefKalori = tdee * AppConstants.kiloVerAcik; // %20 açık
        break;
      case Hedef.formdaKal:
        hedefKalori = tdee * AppConstants.formdaKalDenge; // Dengede
        break;
      case Hedef.kiloAlmak:
        hedefKalori = tdee * AppConstants.kiloAlFazlalik; // %10 fazlalık
        break;
      case Hedef.kasKazanKiloAl:
        hedefKalori =
            tdee * AppConstants.kasKazanKiloAlFazlalik; // %15 fazlalık
        break;
      case Hedef.kasKazanKiloVer:
        hedefKalori = tdee * AppConstants.kasKazanKiloVerAcik; // %15 açık
        break;
    }
    return hedefKalori;
  }

  /// Makro dağılımı hesapla
  MakroHedefleri makroDagilimHesapla({
    required double hedefKalori,
    required double mevcutKilo,
    required Hedef hedef,
    required AktiviteSeviyesi aktivite, // 🔥 AKTİVİTE SEVİYESİ EKLENDİ
  }) {
    double protein, yag, karbonhidrat;

    // 🔥🔥🔥 AKILLI PROTEİN HESAPLAMA (AKTİVİTE BAZLI) 🔥🔥🔥
    // Kilo başına protein çarpanını aktiviteye göre belirle
    final Map<AktiviteSeviyesi, double> proteinCarpanlari = {
      AktiviteSeviyesi.hareketsiz: 1.4,
      AktiviteSeviyesi.hafifAktif: 1.6,
      AktiviteSeviyesi.ortaAktif: 1.8,
      AktiviteSeviyesi.cokAktif: 2.2,
    };
    double bazProteinCarpani = proteinCarpanlari[aktivite] ?? 1.5;

    // Hedefe göre proteini ince ayarla
    if (hedef == Hedef.kasKazanKiloAl || hedef == Hedef.kasKazanKiloVer) {
      bazProteinCarpani += 0.2; // Kas hedefi için ekstra protein
    } else if (hedef == Hedef.kiloVermek) {
      bazProteinCarpani += 0.1; // Kilo verirken kas korumak için hafif artış
    }

    protein = mevcutKilo * bazProteinCarpani;

    // Yağ ve diğer makroları hedefe göre ayarla
    switch (hedef) {
      case Hedef.kiloVermek:
      case Hedef.kasKazanKiloVer:
        yag = mevcutKilo * 0.8; // Orta yağ
        break;
      case Hedef.formdaKal:
        yag = mevcutKilo * 1.0;
        break;
      case Hedef.kiloAlmak:
      case Hedef.kasKazanKiloAl:
        yag = mevcutKilo * 1.1;
        break;
    }

    // Kalan kalori karbonhidrattan
    final proteinKalori = protein * AppConstants.proteinKaloriPerGram;
    final yagKalori = yag * AppConstants.yagKaloriPerGram;
    final kalanKalori = hedefKalori - proteinKalori - yagKalori;
    karbonhidrat = kalanKalori / AppConstants.karbonhidratKaloriPerGram;

    // Negatif değerleri ve çok düşük karbonhidratı düzelt
    if (karbonhidrat < 50) {
      karbonhidrat = 100; // Minimum karb 100g
      yag = (hedefKalori -
              (protein * AppConstants.proteinKaloriPerGram) -
              (karbonhidrat * AppConstants.karbonhidratKaloriPerGram)) /
          AppConstants.yagKaloriPerGram;
    }

    final makrolar = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: protein.clamp(0, AppConstants.maxMakroGram),
      gunlukKarbonhidrat:
          karbonhidrat.clamp(50, AppConstants.maxMakroGram), // Min 50g karb
      gunlukYag: yag.clamp(0, AppConstants.maxMakroGram),
    );

    return makrolar;
  }

  /// Tam hesaplama
  MakroHedefleri tamHesaplama(KullaniciProfili profil) {
    try {
      final bmr = bmrHesapla(
        kilo: profil.mevcutKilo,
        boy: profil.boy,
        yas: profil.yas,
        cinsiyet: profil.cinsiyet,
      );

      final tdee = tdeeHesapla(bmr, profil.aktiviteSeviyesi);
      final hedefKalori = hedefKaloriHesapla(tdee, profil.hedef);
      final makrolar = makroDagilimHesapla(
        hedefKalori: hedefKalori,
        mevcutKilo: profil.mevcutKilo,
        hedef: profil.hedef,
        aktivite: profil.aktiviteSeviyesi, // 🔥 EKSİK PARAMETRE EKLENDİ
      );

      return makrolar;
    } catch (e, stackTrace) {
      AppLogger.error('Makro hesaplama hatası!', e, stackTrace);
      rethrow;
    }
  }
}
