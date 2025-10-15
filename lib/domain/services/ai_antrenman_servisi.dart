// ============================================================================
// lib/domain/services/ai_antrenman_servisi.dart
// AI TABANLI ANTRENMAN PLANLAMA SERVİSİ
// ============================================================================

import 'dart:math';
import '../../core/utils/app_logger.dart';

/// Antrenman seviyesi enum'u
enum AntrenmanSeviyesi {
  baslangic('Başlangıç', '⭐'),
  orta('Orta', '⭐⭐'),
  ileri('İleri', '⭐⭐⭐'),
  uzman('Uzman', '⭐⭐⭐⭐');

  final String ad;
  final String emoji;
  const AntrenmanSeviyesi(this.ad, this.emoji);
}

/// Antrenman türü enum'u
enum AntrenmanTuru {
  kuvvet('Kuvvet', '💪'),
  kardiyo('Kardiyo', '🏃'),
  yoga('Yoga', '🧘'),
  pilates('Pilates', '🤸'),
  crossfit('CrossFit', '🏋️'),
  calisthenic('Calisthenic', '🤾'),
  stretching('Esnetme', '🤸‍♀️');

  final String ad;
  final String emoji;
  const AntrenmanTuru(this.ad, this.emoji);
}

/// Antrenman entity'si
class Antrenman {
  final String id;
  final String ad;
  final AntrenmanTuru tur;
  final AntrenmanSeviyesi seviye;
  final int sure; // dakika
  final int yakilanKalori;
  final List<String> hareketler;
  final List<String> ekipmanlar;
  final String aciklama;
  final List<String> etiketler;

  Antrenman({
    required this.id,
    required this.ad,
    required this.tur,
    required this.seviye,
    required this.sure,
    required this.yakilanKalori,
    required this.hareketler,
    required this.ekipmanlar,
    required this.aciklama,
    this.etiketler = const [],
  });
}

/// Haftalık antrenman planı
class HaftalikAntrenmanPlani {
  final String id;
  final DateTime baslangicTarihi;
  final List<Antrenman?> gunlukAntrenmanlar; // 7 günlük
  final AntrenmanSeviyesi hedefSeviye;
  final int hedefKalori;

  HaftalikAntrenmanPlani({
    required this.id,
    required this.baslangicTarihi,
    required this.gunlukAntrenmanlar,
    required this.hedefSeviye,
    required this.hedefKalori,
  });

  int get toplamKalori => gunlukAntrenmanlar
      .where((a) => a != null)
      .fold(0, (total, antrenman) => total + antrenman!.yakilanKalori);
}

class AIAntrenmanServisi {
  final Random _random = Random();

  /// 🏋️ AI ile kişiye özel antrenman planı oluştur
  Future<Antrenman> antrenmanPlaniOlustur({
    required AntrenmanTuru tur,
    required AntrenmanSeviyesi seviye,
    required int hedefSure, // dakika
    required int hedefKalori,
    List<String> kisitlamalar = const [],
    List<String> mevcutEkipmanlar = const [],
  }) async {
    try {
      AppLogger.info('🏋️ AI Antrenman: Kişiye özel plan oluşturuluyor...');

      // Mock antrenman oluştur (gerçek AI sonra gelecek)
      final antrenman = await _mockAntrenmanOlustur(
        tur: tur,
        seviye: seviye,
        hedefSure: hedefSure,
        hedefKalori: hedefKalori,
        kisitlamalar: kisitlamalar,
        mevcutEkipmanlar: mevcutEkipmanlar,
      );

      AppLogger.success('✅ AI Antrenman planı oluşturuldu: ${antrenman.ad}');
      return antrenman;
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Antrenman Hatası',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 📅 Haftalık antrenman programı oluştur
  Future<HaftalikAntrenmanPlani> haftalikAntrenmanPlaniOlustur({
    required AntrenmanSeviyesi seviye,
    required int haftalikHedefKalori,
    List<String> kisitlamalar = const [],
    DateTime? baslangicTarihi,
  }) async {
    try {
      AppLogger.info('📅 AI Haftalık Antrenman: Program oluşturuluyor...');

      final baslangic = baslangicTarihi ?? DateTime.now();
      final gunlukAntrenmanlar = <Antrenman?>[];

      // Haftalık program mantığı (dengeli dağılım)
      final antrenmanDagilimlari = [
        AntrenmanTuru.kuvvet, // Pazartesi
        AntrenmanTuru.kardiyo, // Salı
        null, // Çarşamba (dinlenme)
        AntrenmanTuru.kuvvet, // Perşembe
        AntrenmanTuru.yoga, // Cuma
        AntrenmanTuru.kardiyo, // Cumartesi
        null, // Pazar (dinlenme)
      ];

      for (int gun = 0; gun < 7; gun++) {
        final gunTuru = antrenmanDagilimlari[gun];

        if (gunTuru != null) {
          final antrenman = await antrenmanPlaniOlustur(
            tur: gunTuru,
            seviye: seviye,
            hedefSure: 45,
            hedefKalori: haftalikHedefKalori ~/ 5, // 5 antrenman günü
            kisitlamalar: kisitlamalar,
          );
          gunlukAntrenmanlar.add(antrenman);
        } else {
          gunlukAntrenmanlar.add(null); // Dinlenme günü
        }
      }

      final haftalikPlan = HaftalikAntrenmanPlani(
        id: '${baslangic.millisecondsSinceEpoch}',
        baslangicTarihi: baslangic,
        gunlukAntrenmanlar: gunlukAntrenmanlar,
        hedefSeviye: seviye,
        hedefKalori: haftalikHedefKalori,
      );

      AppLogger.success('✅ AI Haftalık Antrenman programı tamamlandı');
      return haftalikPlan;
    } catch (e) {
      AppLogger.error('❌ AI Haftalık Antrenman Hatası: $e');
      rethrow;
    }
  }

  /// 🔄 Antrenman alternatifleri üret (en az 2 adet)
  Future<List<Antrenman>> antrenmanAlternatifleriUret(
      Antrenman mevcutAntrenman) async {
    try {
      AppLogger.info(
          '🔄 AI Alternatif Antrenmanlar: ${mevcutAntrenman.ad} için alternatifler üretiliyor...');

      await Future.delayed(Duration(milliseconds: 600));

      // En az 2 alternatif üret
      final alternatifler = <Antrenman>[];

      // Alternatif 1: Benzer seviye, farklı hareket kombinasyonu
      final alternatif1 = await _mockAlternatifAntrenman(
        mevcutAntrenman,
        'Varyasyon 1',
        yakilanKaloriCarpan: 0.95,
        sureCarpan: 1.1,
      );
      alternatifler.add(alternatif1);

      // Alternatif 2: Aynı hedef, farklı yaklaşım
      final alternatif2 = await _mockAlternatifAntrenman(
        mevcutAntrenman,
        'Varyasyon 2',
        yakilanKaloriCarpan: 1.05,
        sureCarpan: 0.9,
      );
      alternatifler.add(alternatif2);

      // Alternatif 3: Bonus alternatif
      final alternatif3 = await _mockAlternatifAntrenman(
        mevcutAntrenman,
        'Express',
        yakilanKaloriCarpan: 1.2,
        sureCarpan: 0.7,
      );
      alternatifler.add(alternatif3);

      AppLogger.success(
          '✅ ${alternatifler.length} AI alternatif antrenman üretildi');
      return alternatifler;
    } catch (e) {
      AppLogger.error('❌ AI Antrenman Alternatifleri Hatası: $e');
      return [];
    }
  }

  /// Mock antrenman oluştur
  Future<Antrenman> _mockAntrenmanOlustur({
    required AntrenmanTuru tur,
    required AntrenmanSeviyesi seviye,
    required int hedefSure,
    required int hedefKalori,
    List<String> kisitlamalar = const [],
    List<String> mevcutEkipmanlar = const [],
  }) async {
    await Future.delayed(Duration(milliseconds: 800));

    // Antrenman türüne göre hareket havuzu
    final hareketHavuzu = _getHareketleriTureGore(tur, seviye);
    final rastgeleHareketler = _rastgeleHareketleriSec(hareketHavuzu, 5);

    final antrenmanAdi = _generateAntrenmanAdi(tur, seviye);

    return Antrenman(
      id: '${DateTime.now().millisecondsSinceEpoch}_${tur.name}',
      ad: antrenmanAdi,
      tur: tur,
      seviye: seviye,
      sure: hedefSure,
      yakilanKalori: hedefKalori,
      hareketler: rastgeleHareketler,
      ekipmanlar: _getEkipmanlariTureGore(tur),
      aciklama:
          'AI tarafından özelleştirilmiş ${tur.ad.toLowerCase()} antrenmanı',
      etiketler: ['ai-olusturulan', 'kisisellestirilmis', tur.name],
    );
  }

  /// Mock alternatif antrenman oluştur
  Future<Antrenman> _mockAlternatifAntrenman(
    Antrenman orijinal,
    String varyasyonAdi, {
    double yakilanKaloriCarpan = 1.0,
    double sureCarpan = 1.0,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));

    final hareketHavuzu =
        _getHareketleriTureGore(orijinal.tur, orijinal.seviye);
    final alternatifHareketler = _rastgeleHareketleriSec(hareketHavuzu, 5);

    return Antrenman(
      id: '${orijinal.id}_alt_$varyasyonAdi',
      ad: '${orijinal.ad} - $varyasyonAdi',
      tur: orijinal.tur,
      seviye: orijinal.seviye,
      sure: (orijinal.sure * sureCarpan).round(),
      yakilanKalori: (orijinal.yakilanKalori * yakilanKaloriCarpan).round(),
      hareketler: alternatifHareketler,
      ekipmanlar: orijinal.ekipmanlar,
      aciklama:
          'AI alternatif ${orijinal.tur.ad.toLowerCase()} antrenmanı - $varyasyonAdi',
      etiketler: [
        ...orijinal.etiketler,
        'alternatif',
        varyasyonAdi.toLowerCase()
      ],
    );
  }

  /// Antrenman türüne göre hareketler
  List<String> _getHareketleriTureGore(
      AntrenmanTuru tur, AntrenmanSeviyesi seviye) {
    switch (tur) {
      case AntrenmanTuru.kuvvet:
        return [
          'Squat',
          'Deadlift',
          'Bench Press',
          'Pull-up',
          'Push-up',
          'Barbell Row',
          'Overhead Press',
          'Dips',
          'Lunges',
          'Plank'
        ];
      case AntrenmanTuru.kardiyo:
        return [
          'Burpee',
          'Mountain Climber',
          'Jumping Jack',
          'High Knees',
          'Koşu',
          'Bisiklet',
          'Jump Rope',
          'Sprint',
          'Stairs',
          'HIIT'
        ];
      case AntrenmanTuru.yoga:
        return [
          'Sun Salutation',
          'Warrior Pose',
          'Tree Pose',
          'Child Pose',
          'Downward Dog',
          'Cobra',
          'Triangle',
          'Bridge',
          'Lotus',
          'Savasana'
        ];
      case AntrenmanTuru.pilates:
        return [
          'Hundred',
          'Roll Up',
          'Single Leg Circle',
          'Teaser',
          'Plank',
          'Swan',
          'Criss Cross',
          'Leg Pull',
          'Spine Stretch',
          'Seal'
        ];
      default:
        return ['Genel Hareket 1', 'Genel Hareket 2', 'Genel Hareket 3'];
    }
  }

  /// Rastgele hareket seç
  List<String> _rastgeleHareketleriSec(List<String> havuz, int sayi) {
    final secilmis = <String>[];
    final karisikHavuz = List.from(havuz)..shuffle(_random);

    for (int i = 0; i < sayi && i < karisikHavuz.length; i++) {
      secilmis.add(karisikHavuz[i]);
    }

    return secilmis;
  }

  /// Antrenman adı üret
  String _generateAntrenmanAdi(AntrenmanTuru tur, AntrenmanSeviyesi seviye) {
    final turAdilar = {
      AntrenmanTuru.kuvvet: ['Power', 'Strength', 'Muscle', 'Iron'],
      AntrenmanTuru.kardiyo: ['Cardio Blast', 'Fat Burn', 'Endurance', 'HIIT'],
      AntrenmanTuru.yoga: ['Flow', 'Balance', 'Harmony', 'Zen'],
    };

    final seviyeAdilar = {
      AntrenmanSeviyesi.baslangic: 'Beginner',
      AntrenmanSeviyesi.orta: 'Intermediate',
      AntrenmanSeviyesi.ileri: 'Advanced',
      AntrenmanSeviyesi.uzman: 'Expert',
    };

    final turSecenekleri = turAdilar[tur] ?? ['Workout'];
    final secilen = turSecenekleri[_random.nextInt(turSecenekleri.length)];

    return '$secilen ${seviyeAdilar[seviye]} Workout';
  }

  /// Ekipmanları türe göre getir
  List<String> _getEkipmanlariTureGore(AntrenmanTuru tur) {
    switch (tur) {
      case AntrenmanTuru.kuvvet:
        return ['Dumbbell', 'Barbell', 'Bench', 'Pull-up Bar'];
      case AntrenmanTuru.kardiyo:
        return ['Mat', 'Jump Rope', 'Timer'];
      case AntrenmanTuru.yoga:
        return ['Yoga Mat', 'Block', 'Strap'];
      case AntrenmanTuru.pilates:
        return ['Pilates Mat', 'Ball', 'Band'];
      default:
        return ['Ekipman gerekmez'];
    }
  }
}
