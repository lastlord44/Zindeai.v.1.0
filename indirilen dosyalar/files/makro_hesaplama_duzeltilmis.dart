// ============================================================================
// MAKRO HESAPLAMA SERVİSİ - DÜZELTİLMİŞ VERSİYON
// ============================================================================

import 'package:equatable/equatable.dart';

// Enums
enum Hedef {
  kiloVer('Kilo Ver'),
  kiloAl('Kilo Al'),
  formdaKal('Formda Kal'),
  kasKazanKiloAl('Kas Kazan + Kilo Al'),
  kasKazanKiloVer('Kas Kazan + Kilo Ver');

  final String aciklama;
  const Hedef(this.aciklama);
}

enum AktiviteSeviyesi {
  hareketsiz('Hareketsiz (Ofis işi)'),
  hafifAktif('Hafif Aktif (Haftada 1-3 gün)'),
  ortaAktif('Orta Aktif (Haftada 3-5 gün)'),
  cokAktif('Çok Aktif (Haftada 6-7 gün)'),
  ekstraAktif('Ekstra Aktif (Günde 2 antrenman)');

  final String aciklama;
  const AktiviteSeviyesi(this.aciklama);
}

enum Cinsiyet {
  erkek('Erkek'),
  kadin('Kadın');

  final String aciklama;
  const Cinsiyet(this.aciklama);
}

enum DiyetTipi {
  normal('Normal'),
  vejetaryen('Vejetaryen'),
  vegan('Vegan');

  final String aciklama;
  const DiyetTipi(this.aciklama);

  // Her diyet tipinin varsayılan alerjileri/kısıtlamaları
  List<String> get varsayilanKisitlamalar {
    switch (this) {
      case DiyetTipi.vejetaryen:
        return ['Et', 'Tavuk', 'Balık', 'Deniz Ürünleri'];
      case DiyetTipi.vegan:
        return [
          'Et',
          'Tavuk',
          'Balık',
          'Deniz Ürünleri',
          'Süt',
          'Peynir',
          'Yoğurt',
          'Yumurta',
          'Bal'
        ];
      case DiyetTipi.normal:
        return [];
    }
  }
}

// ============================================================================
// KULLANICI PROFİLİ - ALERJİ SİSTEMİ İLE
// ============================================================================

class KullaniciProfili extends Equatable {
  final String id;
  final String ad;
  final String soyad;
  final int yas;
  final Cinsiyet cinsiyet;
  final double boy; // cm
  final double mevcutKilo; // kg
  final double? hedefKilo; // kg
  final Hedef hedef;
  final AktiviteSeviyesi aktiviteSeviyesi;
  final DiyetTipi diyetTipi;
  
  // ⭐ YENİ: Alerji/Kısıtlama Sistemi
  final List<String> manuelAlerjiler; // Kullanıcının manuel eklediği
  final DateTime kayitTarihi;

  const KullaniciProfili({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.yas,
    required this.cinsiyet,
    required this.boy,
    required this.mevcutKilo,
    this.hedefKilo,
    required this.hedef,
    required this.aktiviteSeviyesi,
    this.diyetTipi = DiyetTipi.normal,
    this.manuelAlerjiler = const [],
    required this.kayitTarihi,
  });

  // ⭐ TÜM KISITLAMALARI BİRLEŞTİR (Diyet + Manuel)
  List<String> get tumKisitlamalar {
    final Set<String> kisitlamalar = {};
    
    // Diyet tipinden gelen kısıtlamalar
    kisitlamalar.addAll(diyetTipi.varsayilanKisitlamalar);
    
    // Manuel eklenen alerjiler
    kisitlamalar.addAll(manuelAlerjiler);
    
    return kisitlamalar.toList();
  }

  // ⭐ BİR YEMEĞİN YENEBİLİR OLUP OLMADIĞINI KONTROL ET
  bool yemekYenebilirMi(List<String> yemekIcerikleri) {
    final kisitlamalarKucuk = tumKisitlamalar.map((k) => k.toLowerCase()).toSet();
    
    for (final icerik in yemekIcerikleri) {
      if (kisitlamalarKucuk.contains(icerik.toLowerCase())) {
        return false; // Kısıtlama var, yenebilir değil
      }
    }
    return true; // Hiçbir kısıtlama yok
  }

  @override
  List<Object?> get props => [
        id,
        ad,
        soyad,
        yas,
        cinsiyet,
        boy,
        mevcutKilo,
        hedefKilo,
        hedef,
        aktiviteSeviyesi,
        diyetTipi,
        manuelAlerjiler,
        kayitTarihi,
      ];

  KullaniciProfili copyWith({
    String? id,
    String? ad,
    String? soyad,
    int? yas,
    Cinsiyet? cinsiyet,
    double? boy,
    double? mevcutKilo,
    double? hedefKilo,
    Hedef? hedef,
    AktiviteSeviyesi? aktiviteSeviyesi,
    DiyetTipi? diyetTipi,
    List<String>? manuelAlerjiler,
    DateTime? kayitTarihi,
  }) {
    return KullaniciProfili(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      soyad: soyad ?? this.soyad,
      yas: yas ?? this.yas,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      boy: boy ?? this.boy,
      mevcutKilo: mevcutKilo ?? this.mevcutKilo,
      hedefKilo: hedefKilo ?? this.hedefKilo,
      hedef: hedef ?? this.hedef,
      aktiviteSeviyesi: aktiviteSeviyesi ?? this.aktiviteSeviyesi,
      diyetTipi: diyetTipi ?? this.diyetTipi,
      manuelAlerjiler: manuelAlerjiler ?? this.manuelAlerjiler,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
    );
  }
}

// ============================================================================
// MAKRO HEDEFLERİ
// ============================================================================

class MakroHedefleri extends Equatable {
  final double gunlukKalori;
  final double gunlukProtein; // gram
  final double gunlukKarbonhidrat; // gram
  final double gunlukYag; // gram
  final DateTime olusturmaTarihi;

  const MakroHedefleri({
    required this.gunlukKalori,
    required this.gunlukProtein,
    required this.gunlukKarbonhidrat,
    required this.gunlukYag,
    required this.olusturmaTarihi,
  });

  @override
  List<Object?> get props => [
        gunlukKalori,
        gunlukProtein,
        gunlukKarbonhidrat,
        gunlukYag,
        olusturmaTarihi,
      ];

  Map<String, dynamic> toMap() {
    return {
      'gunlukKalori': gunlukKalori,
      'gunlukProtein': gunlukProtein,
      'gunlukKarbonhidrat': gunlukKarbonhidrat,
      'gunlukYag': gunlukYag,
      'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '''
📊 Günlük Makro Hedefleri:
   🔥 Kalori: ${gunlukKalori.toStringAsFixed(0)} kcal
   🥩 Protein: ${gunlukProtein.toStringAsFixed(0)} g (${(gunlukProtein * 4 / gunlukKalori * 100).toStringAsFixed(0)}%)
   🍚 Karbonhidrat: ${gunlukKarbonhidrat.toStringAsFixed(0)} g (${(gunlukKarbonhidrat * 4 / gunlukKalori * 100).toStringAsFixed(0)}%)
   🥑 Yağ: ${gunlukYag.toStringAsFixed(0)} g (${(gunlukYag * 9 / gunlukKalori * 100).toStringAsFixed(0)}%)
''';
  }
}

// ============================================================================
// MAKRO HESAPLAMA SERVİSİ - DÜZELTİLMİŞ
// ============================================================================

class MakroHesapla {
  /// BMR hesaplama (Mifflin-St Jeor)
  double bmrHesapla({
    required double kilo,
    required double boy,
    required int yas,
    required Cinsiyet cinsiyet,
  }) {
    print('🔢 BMR hesaplanıyor: kilo=$kilo, boy=$boy, yas=$yas');

    double bmr;
    if (cinsiyet == Cinsiyet.erkek) {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) + 5;
    } else {
      bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    }

    print('✅ BMR: ${bmr.toStringAsFixed(0)} kcal');
    return bmr;
  }

  /// TDEE hesaplama
  double tdeeHesapla(double bmr, AktiviteSeviyesi aktivite) {
    print('🏃 TDEE hesaplanıyor: bmr=$bmr, aktivite=${aktivite.aciklama}');

    final carpanlar = {
      AktiviteSeviyesi.hareketsiz: 1.2,
      AktiviteSeviyesi.hafifAktif: 1.375,
      AktiviteSeviyesi.ortaAktif: 1.55,
      AktiviteSeviyesi.cokAktif: 1.725,
      AktiviteSeviyesi.ekstraAktif: 1.9,
    };

    final tdee = bmr * (carpanlar[aktivite] ?? 1.2);
    print('✅ TDEE: ${tdee.toStringAsFixed(0)} kcal');
    return tdee;
  }

  /// Hedefe göre kalori ayarla
  double hedefKaloriHesapla(double tdee, Hedef hedef) {
    print('🎯 Hedef kalori hesaplanıyor: tdee=$tdee, hedef=${hedef.aciklama}');

    double hedefKalori;
    switch (hedef) {
      case Hedef.kiloVer:
        hedefKalori = tdee * 0.80; // %20 açık
        break;
      case Hedef.kasKazanKiloVer:
        hedefKalori = tdee * 0.85; // %15 açık
        break;
      case Hedef.formdaKal:
        hedefKalori = tdee; // Dengede
        break;
      case Hedef.kiloAl:
        hedefKalori = tdee * 1.10; // %10 fazlalık
        break;
      case Hedef.kasKazanKiloAl:
        hedefKalori = tdee * 1.15; // %15 fazlalık
        break;
    }

    print('✅ Hedef Kalori: ${hedefKalori.toStringAsFixed(0)} kcal');
    return hedefKalori;
  }

  /// ⭐ DÜZELTİLMİŞ: Makro dağılımı hesapla
  MakroHedefleri makroDagilimHesapla({
    required double hedefKalori,
    required double mevcutKilo,
    required Hedef hedef,
  }) {
    print('📊 Makro dağılımı hesaplanıyor...');

    double protein, yag, karbonhidrat;

    // ⚠️ ESKİ YANLIŞ DEĞERLER:
    // Kilo Al için: protein 1.6, yağ 1.0
    // SONUÇ: 120g protein, 75g yağ → DENGESİZ!

    // ✅ YENİ DOĞRU DEĞERLER:
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
        protein = mevcutKilo * 2.0; // ⬆️ Arttırıldı (1.8 → 2.0)
        yag = mevcutKilo * 1.0; // ⬆️ Arttırıldı (0.9 → 1.0)
        break;

      case Hedef.kiloAl:
        protein = mevcutKilo * 2.0; // ⬆️ ARTIRILDI (1.6 → 2.0)
        yag = mevcutKilo * 1.1; // ⬆️ ARTIRILDI (1.0 → 1.1)
        break;

      case Hedef.kasKazanKiloAl:
        protein = mevcutKilo * 2.2; // ⬆️ Arttırıldı (2.0 → 2.2)
        yag = mevcutKilo * 1.2; // ⬆️ Arttırıldı (1.0 → 1.2)
        break;
    }

    // Kalan kalori karbonhidrattan
    final proteinKalori = protein * 4;
    final yagKalori = yag * 9;
    final kalanKalori = hedefKalori - proteinKalori - yagKalori;
    karbonhidrat = kalanKalori / 4;

    // Negatif değerleri düzelt
    if (karbonhidrat < 50) {
      print('⚠️  Karbonhidrat çok düşük! Makrolar yeniden ayarlanıyor...');
      karbonhidrat = 100; // Minimum karb
      yag = (hedefKalori - (protein * 4) - (karbonhidrat * 4)) / 9;
    }

    final makrolar = MakroHedefleri(
      gunlukKalori: hedefKalori,
      gunlukProtein: protein.clamp(0, 999),
      gunlukKarbonhidrat: karbonhidrat.clamp(50, 999),
      gunlukYag: yag.clamp(0, 999),
      olusturmaTarihi: DateTime.now(),
    );

    print(makrolar);

    return makrolar;
  }

  /// Tam hesaplama
  MakroHedefleri tamHesaplama(KullaniciProfili profil) {
    try {
      print('\n' + '=' * 60);
      print('🎯 MAKRO HESAPLAMA BAŞLADI');
      print('👤 Kullanıcı: ${profil.ad} ${profil.soyad}');
      print('📏 Bilgiler: ${profil.yas} yaş, ${profil.mevcutKilo}kg, ${profil.boy}cm');
      print('🎯 Hedef: ${profil.hedef.aciklama}');
      print('=' * 60 + '\n');

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

      print('=' * 60);
      print('✅ MAKRO HESAPLAMA TAMAMLANDI');
      print('=' * 60 + '\n');

      return makrolar;
    } catch (e, stackTrace) {
      print('❌ Makro hesaplama hatası!');
      print('Hata: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }
}

// ============================================================================
// TEST KODLARI
// ============================================================================

void main() {
  print('\n🧪 TEST 1: SENIN ÖRNEĞİN (37 yaş, 75kg, kilo alma)');
  print('─' * 60);

  final hesaplama = MakroHesapla();

  final profil1 = KullaniciProfili(
    id: '1',
    ad: 'Test',
    soyad: 'Kullanıcı',
    yas: 37,
    cinsiyet: Cinsiyet.erkek,
    boy: 175, // Örnek boy (belirtmedin)
    mevcutKilo: 75,
    hedefKilo: 80,
    hedef: Hedef.kiloAl,
    aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
    kayitTarihi: DateTime.now(),
  );

  final makrolar1 = hesaplama.tamHesaplama(profil1);

  print('\n🧪 TEST 2: VEGAN + CEVIZ ALERJİSİ');
  print('─' * 60);

  final profil2 = KullaniciProfili(
    id: '2',
    ad: 'Ayşe',
    soyad: 'Vegan',
    yas: 28,
    cinsiyet: Cinsiyet.kadin,
    boy: 165,
    mevcutKilo: 60,
    hedefKilo: 55,
    hedef: Hedef.kiloVer,
    aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
    diyetTipi: DiyetTipi.vegan,
    manuelAlerjiler: ['Ceviz', 'Fındık'], // ⭐ Manuel alerji
    kayitTarihi: DateTime.now(),
  );

  print('\n📋 Diyet Tipi Kısıtlamaları:');
  print(profil2.diyetTipi.varsayilanKisitlamalar);

  print('\n📋 Manuel Alerjiler:');
  print(profil2.manuelAlerjiler);

  print('\n📋 TÜM KISITLAMALAR:');
  print(profil2.tumKisitlamalar);

  // Test yemekleri
  print('\n🍽️  YEMEK TESTLERİ:');

  final yemek1 = ['Tavuk', 'Pirinç', 'Salata'];
  print('Tavuk Pirinç: ${profil2.yemekYenebilirMi(yemek1) ? "✅ Yenebilir" : "❌ YASAKLI"}');

  final yemek2 = ['Nohut', 'Bulgur', 'Zeytinyağı'];
  print('Nohut Bulgur: ${profil2.yemekYenebilirMi(yemek2) ? "✅ Yenebilir" : "❌ YASAKLI"}');

  final yemek3 = ['Mercimek', 'Ceviz', 'Salata'];
  print('Mercimek Ceviz: ${profil2.yemekYenebilirMi(yemek3) ? "✅ Yenebilir" : "❌ YASAKLI (Ceviz alerjisi)"}');

  final yemek4 = ['Yumurta', 'Sebze'];
  print('Yumurta Sebze: ${profil2.yemekYenebilirMi(yemek4) ? "✅ Yenebilir" : "❌ YASAKLI (Vegan)"}');

  print('\n' + '=' * 60);
  print('✅ TÜM TESTLER TAMAMLANDI!');
  print('=' * 60);
}
