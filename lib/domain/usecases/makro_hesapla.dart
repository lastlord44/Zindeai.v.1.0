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
    AppLogger.debug('BMR hesaplanıyor: kilo=$kilo, boy=$boy, yas=$yas');
    
    double bmr;
    if (cinsiyet == Cinsiyet.erkek) {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) + 5;
    } else {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    }
    
    AppLogger.info('BMR hesaplandı: ${bmr.toStringAsFixed(0)} kcal');
    return bmr;
  }

  /// TDEE hesaplama
  double tdeeHesapla(double bmr, AktiviteSeviyesi aktivite) {
    AppLogger.debug('TDEE hesaplanıyor: bmr=$bmr, aktivite=${aktivite.aciklama}');
    
    final carpanlar = {
      AktiviteSeviyesi.hareketsiz: 1.2,
      AktiviteSeviyesi.hafifAktif: 1.375,
      AktiviteSeviyesi.ortaAktif: 1.55,
      AktiviteSeviyesi.cokAktif: 1.725,
      AktiviteSeviyesi.ekstraAktif: 1.9,
    };
    
    final tdee = bmr * (carpanlar[aktivite] ?? 1.2);
    AppLogger.info('TDEE hesaplandı: ${tdee.toStringAsFixed(0)} kcal');
    return tdee;
  }

  /// Hedefe göre kalori ayarla
  double hedefKaloriHesapla(double tdee, Hedef hedef) {
    AppLogger.debug('Hedef kalori hesaplanıyor: tdee=$tdee, hedef=${hedef.aciklama}');
    
    double hedefKalori;
    switch (hedef) {
      case Hedef.kiloVer:
        hedefKalori = tdee * AppConstants.kiloVerAcik; // %20 açık
        break;
      case Hedef.kasKazanKiloVer:
        hedefKalori = tdee * AppConstants.kasKazanKiloVerAcik; // %15 açık
        break;
      case Hedef.formdaKal:
        hedefKalori = tdee * AppConstants.formdaKalDenge; // Dengede
        break;
      case Hedef.kiloAl:
        hedefKalori = tdee * AppConstants.kiloAlFazlalik; // %10 fazlalık
        break;
      case Hedef.kasKazanKiloAl:
        hedefKalori = tdee * AppConstants.kasKazanKiloAlFazlalik; // %15 fazlalık
        break;
    }
    
    AppLogger.info('Hedef kalori hesaplandı: ${hedefKalori.toStringAsFixed(0)} kcal');
    return hedefKalori;
  }

  /// Makro dağılımı hesapla
  MakroHedefleri makroDagilimHesapla({
    required double hedefKalori,
    required double mevcutKilo,
    required Hedef hedef,
  }) {
    AppLogger.debug('Makro dağılımı hesaplanıyor...');
    
    double protein, yag, karbonhidrat;

    // ⭐ DÜZELTİLMİŞ MAKRO DEĞERLERİ (Protein ve Yağ arttırıldı)
    switch (hedef) {
      case Hedef.kiloVer:
        protein = mevcutKilo * 2.2; // Yüksek protein (kas koruma)
        yag = mevcutKilo * 0.8; // Orta yağ
        break;
      
      case Hedef.kasKazanKiloVer:
        protein = mevcutKilo * 2.5; // Çok yüksek protein
        yag = mevcutKilo * 0.7; // Düşük yağ
        break;
      
      case Hedef.formdaKal:
        protein = mevcutKilo * 2.0; // ⬆️ ARTIRILDI (1.8 → 2.0)
        yag = mevcutKilo * 1.0; // ⬆️ ARTIRILDI (0.9 → 1.0)
        break;
      
      case Hedef.kiloAl:
        protein = mevcutKilo * 2.0; // ⬆️ ARTIRILDI (1.6 → 2.0)
        yag = mevcutKilo * 1.1; // ⬆️ ARTIRILDI (1.0 → 1.1)
        break;
      
      case Hedef.kasKazanKiloAl:
        protein = mevcutKilo * 2.2; // ⬆️ ARTIRILDI (2.0 → 2.2)
        yag = mevcutKilo * 1.2; // ⬆️ ARTIRILDI (1.0 → 1.2)
        break;
    }

    // Kalan kalori karbonhidrattan
    final proteinKalori = protein * AppConstants.proteinKaloriPerGram;
    final yagKalori = yag * AppConstants.yagKaloriPerGram;
    final kalanKalori = hedefKalori - proteinKalori - yagKalori;
    karbonhidrat = kalanKalori / AppConstants.karbonhidratKaloriPerGram;

    // Negatif değerleri ve çok düşük karbonhidratı düzelt
    if (karbonhidrat < 50) {
      AppLogger.warning('Karbonhidrat çok düşük! Makrolar yeniden ayarlanıyor...');
      karbonhidrat = 100; // Minimum karb 100g
      yag = (hedefKalori - (protein * AppConstants.proteinKaloriPerGram) - (karbonhidrat * AppConstants.karbonhidratKaloriPerGram)) / AppConstants.yagKaloriPerGram;
    }

    final makrolar = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: protein.clamp(0, AppConstants.maxMakroGram),
      gunlukKarbonhidrat: karbonhidrat.clamp(50, AppConstants.maxMakroGram), // Min 50g karb
      gunlukYag: yag.clamp(0, AppConstants.maxMakroGram),
      olusturmaTarihi: DateTime.now(),
    );

    AppLogger.info('Makrolar hesaplandı:');
    AppLogger.info('  Kalori: ${makrolar.gunlukKalori.toStringAsFixed(0)} kcal');
    AppLogger.info('  Protein: ${makrolar.gunlukProtein.toStringAsFixed(0)} g');
    AppLogger.info('  Karb: ${makrolar.gunlukKarbonhidrat.toStringAsFixed(0)} g');
    AppLogger.info('  Yağ: ${makrolar.gunlukYag.toStringAsFixed(0)} g');

    return makrolar;
  }

  /// Tam hesaplama
  MakroHedefleri tamHesaplama(KullaniciProfili profil) {
    try {
      AppLogger.info('========================================');
      AppLogger.info('MAKRO HESAPLAMA BAŞLADI');
      AppLogger.info('Kullanıcı: ${profil.ad} ${profil.soyad}');
      AppLogger.info('========================================');

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
      );

      AppLogger.info('========================================');
      AppLogger.info('MAKRO HESAPLAMA TAMAMLANDI');
      AppLogger.info('========================================');

      return makrolar;
    } catch (e, stackTrace) {
      AppLogger.error('Makro hesaplama hatası!', e, stackTrace);
      rethrow;
    }
  }
}
