// ============================================================================
// lib/domain/services/su_onerisi_servisi.dart
// GÜNLÜK SU ÖNERİSİ SERVİSİ (Makrolara Göre Hesaplama)
// ============================================================================

import '../entities/kullanici_profili.dart';
import '../entities/gunluk_plan.dart';
import '../entities/su_onerisi.dart';
import '../entities/hedef.dart';
import '../../core/utils/app_logger.dart';

class SuOnerisiServisi {
  
  /// Günlük su ihtiyacı hesapla (makrolara göre)
  static SuOnerisi gunlukSuIhtiyaciHesapla({
    required KullaniciProfili kullanici,
    required GunlukPlan plan,
    double? mevcutKilo,
  }) {
    try {
      AppLogger.info('💧 Su ihtiyacı hesaplanıyor...');
      
      final kilo = mevcutKilo ?? kullanici.mevcutKilo;
      
      // 1. TEMEL SU İHTİYACI (35ml/kg)
      double temelSu = (kilo * 35) / 1000; // Litre cinsinden
      
      // 2. AKTİVİTE BAZLI EK
      double aktiviteEk = _aktiviteEkiHesapla(kullanici.aktiviteSeviyesi);
      
      // 3. MAKRO BAZLI EK İHTİYAÇLAR
      final makroEk = _makroBazliSuEki(plan);
      
      // 4. HEDEF BAZLI EK
      double hedefEk = _hedefBazliSuEki(kullanici.hedef);
      
      // 5. YAŞ VE CİNSİYET DÜZELTMESİ
      double yasCinsiyetDuzeltme = _yasCinsiyetDuzeltmesi(kullanici.yas, kullanici.cinsiyet);
      
      // TOPLAM SU İHTİYACI
      double toplamSu = temelSu + aktiviteEk + makroEk + hedefEk + yasCinsiyetDuzeltme;
      
      // Minimum 1.5L, maksimum 4.5L sınırları
      toplamSu = toplamSu.clamp(1.5, 4.5);
      
      // SAATLIK DAĞILIM
      final saatlikDagitim = _saatlikDagitimHesapla(toplamSu);
      
      // AÇIKLAMA VE TAVSİYELER
      final aciklama = _suAciklamasiOlustur(toplamSu, kullanici, plan);
      final tavsiyeler = _suTavsiyelerOlustur(toplamSu, kullanici);
      
      AppLogger.success('✅ Su ihtiyacı hesaplandı: ${toplamSu.toStringAsFixed(1)}L');
      
      return SuOnerisi(
        gunlukIhtiyac: toplamSu,
        temelIhtiyac: temelSu,
        aktiviteEk: aktiviteEk,
        makroEk: makroEk,
        hedefEk: hedefEk,
        saatlikDagitim: saatlikDagitim,
        aciklama: aciklama,
        tavsiyeler: tavsiyeler,
        hesaplamaTarihi: DateTime.now(),
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Su ihtiyacı hesaplama hatası', error: e, stackTrace: stackTrace);
      
      // Hata durumunda varsayılan değer döndür
      return SuOnerisi(
        gunlukIhtiyac: 2.5,
        temelIhtiyac: 2.0,
        aktiviteEk: 0.3,
        makroEk: 0.2,
        hedefEk: 0.0,
        saatlikDagitim: _saatlikDagitimHesapla(2.5),
        aciklama: 'Standart su önerisi: günlük 2.5 litre',
        tavsiyeler: ['Günde en az 8 bardak su için'],
        hesaplamaTarihi: DateTime.now(),
      );
    }
  }
  
  /// Aktivite seviyesine göre ek su hesapla
  static double _aktiviteEkiHesapla(AktiviteSeviyesi aktivite) {
    switch (aktivite) {
      case AktiviteSeviyesi.hareketsiz:
        return 0.0; // Ek yok
      case AktiviteSeviyesi.hafifAktif:
        return 0.3; // +300ml
      case AktiviteSeviyesi.ortaAktif:
        return 0.5; // +500ml
      case AktiviteSeviyesi.cokAktif:
        return 0.7; // +700ml
    }
  }
  
  /// Makrolara göre su eki hesapla
  static double _makroBazliSuEki(GunlukPlan plan) {
    double makroEk = 0.0;
    
    // Protein eki: Her 1g protein için +3ml su
    makroEk += (plan.toplamProtein * 3) / 1000;
    
    // Yüksek kalori eki: 2500 kcal üzerinde her 100 kcal için +50ml
    if (plan.toplamKalori > 2500) {
      final ekKalori = plan.toplamKalori - 2500;
      makroEk += (ekKalori / 100) * 0.05;
    }
    
    // Yüksek karbonhidrat eki: 300g üzerinde her 50g için +100ml
    if (plan.toplamKarbonhidrat > 300) {
      final ekKarb = plan.toplamKarbonhidrat - 300;
      makroEk += (ekKarb / 50) * 0.1;
    }
    
    return makroEk;
  }
  
  /// Hedef bazlı su eki
  static double _hedefBazliSuEki(Hedef hedef) {
    switch (hedef) {
      case Hedef.kiloVermek:
        return 0.3; // Metabolizmayı hızlandırmak için
      case Hedef.kiloAlmak:
        return 0.2; // Kilo alma için
      case Hedef.kasKazanKiloAl:
        return 0.5; // Hem kas hem kilo için
      case Hedef.kasKazanKiloVer:
        return 0.4; // Kas kazan kilo ver için
      case Hedef.formdaKal:
        return 0.0; // Standart
    }
  }
  
  /// Yaş ve cinsiyet düzeltmesi
  static double _yasCinsiyetDuzeltmesi(int yas, Cinsiyet cinsiyet) {
    double duzeltme = 0.0;
    
    // Yaş düzeltmesi
    if (yas < 25) {
      duzeltme += 0.2; // Gençler daha fazla su gerektirir
    } else if (yas > 50) {
      duzeltme -= 0.1; // Yaşlılarda biraz azalır
    }
    
    // Cinsiyet düzeltmesi
    if (cinsiyet == Cinsiyet.erkek) {
      duzeltme += 0.2; // Erkekler genelde daha fazla su içer
    }
    
    return duzeltme;
  }
  
  /// Saatlik dağılım hesapla
  static Map<int, double> _saatlikDagitimHesapla(double toplamSu) {
    // Su içme saatleri ve oranları (sabah daha fazla, gece daha az)
    final saatlikOranlar = {
      7: 0.15,   // Sabah uyanınca
      9: 0.10,   // Kahvaltı sonrası
      11: 0.10,  // Ara
      13: 0.15,  // Öğle yemeği ile
      15: 0.10,  // Öğleden sonra
      17: 0.10,  // Akşam öncesi
      19: 0.15,  // Akşam yemeği ile
      21: 0.10,  // Akşam
      23: 0.05,  // Yatmadan önce (az)
    };
    
    final saatlikDagitim = <int, double>{};
    for (final entry in saatlikOranlar.entries) {
      saatlikDagitim[entry.key] = (toplamSu * entry.value);
    }
    
    return saatlikDagitim;
  }
  
  /// Su açıklaması oluştur
  static String _suAciklamasiOlustur(double toplamSu, KullaniciProfili kullanici, GunlukPlan plan) {
    if (toplamSu < 2.0) {
      return 'Temel hidrasyon: ${toplamSu.toStringAsFixed(1)}L günlük su ihtiyacınız var.';
    } else if (toplamSu < 2.5) {
      return 'Standart hidrasyon: ${toplamSu.toStringAsFixed(1)}L ile sağlıklı kalabilirsiniz.';
    } else if (toplamSu < 3.5) {
      return 'Aktif yaşam: ${kullanici.aktiviteSeviyesi.aciklama} seviyeniz için ${toplamSu.toStringAsFixed(1)}L uygun.';
    } else {
      return 'Yüksek performans: ${toplamSu.toStringAsFixed(1)}L ile maksimum performansı hedefliyorsunuz!';
    }
  }
  
  /// Su tavsiyeleri oluştur
  static List<String> _suTavsiyelerOlustur(double toplamSu, KullaniciProfili kullanici) {
    final tavsiyeler = <String>[];
    
    // Temel tavsiyeler
    tavsiyeler.add('🌅 Güne 1 bardak ilık su ile başlayın');
    tavsiyeler.add('🍽️ Yemeklerden 30 dk önce su için');
    
    // Su miktarına göre özel tavsiyeler
    if (toplamSu > 3.0) {
      tavsiyeler.add('🏃‍♂️ Yüksek su ihtiyacınız var - sık sık için');
      tavsiyeler.add('⏰ Saatlik hatırlatıcı kurun');
    } else {
      tavsiyeler.add('📱 Su içme uygulaması kullanabilirsiniz');
    }
    
    // Aktivite seviyesine göre
    if (kullanici.aktiviteSeviyesi == AktiviteSeviyesi.cokAktif) {
      tavsiyeler.add('💪 Antrenman öncesi/sonrası ekstra su alın');
      tavsiyeler.add('🧂 Elektrolit dengesi için biraz tuz ekleyin');
    }
    
    // Hedefe göre
    if (kullanici.hedef == Hedef.kiloVermek) {
      tavsiyeler.add('🔥 Su metabolizmanızı hızlandırır - tok hissettir');
    } else if (kullanici.hedef == Hedef.kasKazanKiloAl) {
      tavsiyeler.add('💪 Kas sentezi için protein öğünlerinde su artırın');
    }
    
    // Yaşa göre
    if (kullanici.yas > 50) {
      tavsiyeler.add('👴 Su hissiyatınız azalmış olabilir - düzenli için');
    } else if (kullanici.yas < 25) {
      tavsiyeler.add('🌟 Genç metabolizmanız için bol su gerekli');
    }
    
    // Son tavsiyek
    tavsiyeler.add('🚰 Temiz, filtreli su tercih edin');
    tavsiyeler.add('🌙 Yatmadan 2 saat önce son su alımınızı yapın');
    
    return tavsiyeler.take(6).toList(); // Maksimum 6 tavsiye
  }
  
  /// Hızlı su önerisi (basit hesaplama)
  static double hizliSuOnerisi(double kilo, {AktiviteSeviyesi? aktivite}) {
    double temel = (kilo * 35) / 1000; // 35ml/kg
    
    // Aktivite eki
    double aktiviteEk = 0.0;
    if (aktivite != null) {
      aktiviteEk = _aktiviteEkiHesapla(aktivite);
    }
    
    return (temel + aktiviteEk).clamp(1.5, 4.5);
  }
  
  /// Su içme zamanları öner
  static List<String> suIcmeZamanlari(double gunlukSu) {
    final zamanlar = <String>[];
    final bardakSayisi = (gunlukSu * 4).round(); // 1 bardak = 250ml
    
    zamanlar.add('07:00 - Güne başlarken (1-2 bardak)');
    zamanlar.add('09:00 - Kahvaltı sonrası (1 bardak)');
    zamanlar.add('11:00 - Ara (1 bardak)');
    zamanlar.add('13:00 - Öğle yemeği ile (1-2 bardak)');
    zamanlar.add('15:00 - Öğleden sonra (1 bardak)');
    zamanlar.add('17:00 - Akşam öncesi (1 bardak)');
    zamanlar.add('19:00 - Akşam yemeği ile (1-2 bardak)');
    zamanlar.add('21:00 - Akşam (1 bardak)');
    
    if (bardakSayisi > 10) {
      zamanlar.add('Ek: Her saat başı 1 bardak su için');
    }
    
    return zamanlar;
  }
}
