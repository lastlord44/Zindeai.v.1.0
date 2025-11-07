import 'package:flutter_test/flutter_test.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/data/local/hive_service.dart';
import 'package:zinde_ai/domain/entities/hedef.dart';
import 'package:zinde_ai/domain/entities/kullanici_profili.dart';
import 'package:zinde_ai/domain/entities/yemek.dart'; // Eksik import
import 'package:zinde_ai/domain/services/ai_beslenme_servisi.dart';
import 'package:zinde_ai/domain/usecases/makro_hesapla.dart';
import 'package:zinde_ai/core/utils/yemek_migration_3000.dart'; // 🔥 YENİ: Migration için import

void main() {
  // 🔥 TEST ORTAMI İÇİN KRİTİK BAŞLATMA
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Testler için Hive'ı geçici bir dizinde (in-memory) başlat.
    await HiveService.init(isTest: true);
    
    // 🔥 YENİ: Test veritabanını yemek verileriyle doldur.
    await YemekMigration3000.yukle();

    // Log seviyesini en detaylıya ayarla
    AppLogger.init(level: LogLevel.debug);
  });

  test('Kapsamlı Stres Testi: 20 Farklı Profil İçin Diyet Planı Oluşturma',
      () async {
    final aiBeslenmeServisi = AIBeslenmeServisi();
    final makroHesapla = MakroHesapla();

    final profiller = _profilListesiOlustur();

    for (int i = 0; i < profiller.length; i++) {
      final profil = profiller[i];
      print('\n' + '=' * 80);
      print(
          '🧪 TEST BAŞLIYOR: Profil ${i + 1}/${profiller.length} - ${profil.ad} (${profil.hedef.aciklama})');
      print('=' * 80);

      final makroHedefleri = makroHesapla.tamHesaplama(profil);

      final gunlukPlan = await aiBeslenmeServisi.gunlukPlanOlustur(
        hedefKalori: makroHedefleri.gunlukKalori,
        hedefProtein: makroHedefleri.gunlukProtein,
        hedefKarb: makroHedefleri.gunlukKarbonhidrat,
        hedefYag: makroHedefleri.gunlukYag,
        hedef: profil.hedef,
        kisitlamalar: profil.tumKisitlamalar,
      );

      // Sonuçları Doğrula (Basit Kontroller)
      expect(gunlukPlan, isNotNull);
      expect(gunlukPlan.ogunler.isNotEmpty, isTrue);

      // Kahvaltıda kahvaltılık mı var?
      final kahvaltiYemegi = gunlukPlan.kahvalti;
      expect(kahvaltiYemegi, isNotNull,
          reason: '${profil.ad} için kahvaltı oluşturulamadı.');
      if (kahvaltiYemegi != null) {
        expect(kahvaltiYemegi.ogun, OgunTipi.kahvalti,
            reason:
                'Kahvaltı slotuna ${kahvaltiYemegi.ogun.name} tipi bir yemek atandı!');
      }

      // Ara öğünlerde ana yemek var mı?
      final araOgun1 = gunlukPlan.araOgun1;
      if (araOgun1 != null) {
        expect(araOgun1.ogun, OgunTipi.araOgun1,
            reason:
                'Ara Öğün 1 slotuna ${araOgun1.ogun.name} tipi bir yemek atandı!');
      }

      final araOgun2 = gunlukPlan.araOgun2;
      if (araOgun2 != null) {
        expect(araOgun2.ogun, OgunTipi.araOgun2,
            reason:
                'Ara Öğün 2 slotuna ${araOgun2.ogun.name} tipi bir yemek atandı!');
      }

      print(
          '✅ TEST TAMAMLANDI: Profil ${i + 1}/${profiller.length} - ${profil.ad}');
    }
  });
}

List<KullaniciProfili> _profilListesiOlustur() {
  return [
    // Kilo Verme Senaryoları
    KullaniciProfili(
        id: '1',
        ad: 'Ali',
        soyad: 'Yılmaz',
        yas: 30,
        cinsiyet: Cinsiyet.erkek,
        boy: 180,
        mevcutKilo: 95,
        hedefKilo: 85,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '2',
        ad: 'Ayşe',
        soyad: 'Kaya',
        yas: 28,
        cinsiyet: Cinsiyet.kadin,
        boy: 165,
        mevcutKilo: 70,
        hedefKilo: 60,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: ['laktoz'],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '3',
        ad: 'Mehmet',
        soyad: 'Demir',
        yas: 45,
        cinsiyet: Cinsiyet.erkek,
        boy: 175,
        mevcutKilo: 110,
        hedefKilo: 90,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.hareketsiz,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '4',
        ad: 'Zeynep',
        soyad: 'Çelik',
        yas: 35,
        cinsiyet: Cinsiyet.kadin,
        boy: 170,
        mevcutKilo: 80,
        hedefKilo: 70,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: ['fındık'],
        kayitTarihi: DateTime.now()),

    // Kilo Almak Senaryoları
    KullaniciProfili(
        id: '5',
        ad: 'Mustafa',
        soyad: 'Şahin',
        yas: 22,
        cinsiyet: Cinsiyet.erkek,
        boy: 185,
        mevcutKilo: 70,
        hedefKilo: 80,
        hedef: Hedef.kiloAlmak,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '6',
        ad: 'Elif',
        soyad: 'Turan',
        yas: 25,
        cinsiyet: Cinsiyet.kadin,
        boy: 160,
        mevcutKilo: 48,
        hedefKilo: 55,
        hedef: Hedef.kiloAlmak,
        aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
        diyetTipi: DiyetTipi.vejetaryen,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),

    // Formda Kalma Senaryoları
    KullaniciProfili(
        id: '7',
        ad: 'Emre',
        soyad: 'Aydın',
        yas: 32,
        cinsiyet: Cinsiyet.erkek,
        boy: 178,
        mevcutKilo: 78,
        hedefKilo: 78,
        hedef: Hedef.formdaKal,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '8',
        ad: 'Fatma',
        soyad: 'Öztürk',
        yas: 40,
        cinsiyet: Cinsiyet.kadin,
        boy: 168,
        mevcutKilo: 65,
        hedefKilo: 65,
        hedef: Hedef.formdaKal,
        aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),

    // Kas Kazanma + Kilo Alma Senaryoları
    KullaniciProfili(
        id: '9',
        ad: 'Hakan',
        soyad: 'Kurt',
        yas: 26,
        cinsiyet: Cinsiyet.erkek,
        boy: 182,
        mevcutKilo: 75,
        hedefKilo: 85,
        hedef: Hedef.kasKazanKiloAl,
        aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '10',
        ad: 'Selin',
        soyad: 'Polat',
        yas: 29,
        cinsiyet: Cinsiyet.kadin,
        boy: 172,
        mevcutKilo: 58,
        hedefKilo: 64,
        hedef: Hedef.kasKazanKiloAl,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),

    // Kas Kazanma + Kilo Verme Senaryoları
    KullaniciProfili(
        id: '11',
        ad: 'Okan',
        soyad: 'Sarı',
        yas: 33,
        cinsiyet: Cinsiyet.erkek,
        boy: 177,
        mevcutKilo: 88,
        hedefKilo: 80,
        hedef: Hedef.kasKazanKiloVer,
        aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),
    KullaniciProfili(
        id: '12',
        ad: 'Buse',
        soyad: 'Doğan',
        yas: 27,
        cinsiyet: Cinsiyet.kadin,
        boy: 165,
        mevcutKilo: 68,
        hedefKilo: 62,
        hedef: Hedef.kasKazanKiloVer,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now()),

    // Ekstra Senaryolar
    KullaniciProfili(
        id: '13',
        ad: 'Vegan Veli',
        yas: 28,
        cinsiyet: Cinsiyet.erkek,
        boy: 180,
        mevcutKilo: 75,
        hedefKilo: 80,
        hedef: Hedef.kasKazanKiloAl,
        aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
        diyetTipi: DiyetTipi.vegan,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Yılmaz'),
    KullaniciProfili(
        id: '14',
        ad: 'Pescetarian Pınar',
        yas: 31,
        cinsiyet: Cinsiyet.kadin,
        boy: 168,
        mevcutKilo: 62,
        hedefKilo: 60,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Deniz'),
    KullaniciProfili(
        id: '15',
        ad: 'Hareketsiz Hasan',
        yas: 50,
        cinsiyet: Cinsiyet.erkek,
        boy: 170,
        mevcutKilo: 90,
        hedefKilo: 80,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.hareketsiz,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Duran'),
    KullaniciProfili(
        id: '16',
        ad: 'Çok Aktif Zeynep',
        yas: 24,
        cinsiyet: Cinsiyet.kadin,
        boy: 165,
        mevcutKilo: 55,
        hedefKilo: 58,
        hedef: Hedef.kiloAlmak,
        aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Koşan'),
    KullaniciProfili(
        id: '17',
        ad: 'Alerjik Ahmet',
        yas: 38,
        cinsiyet: Cinsiyet.erkek,
        boy: 182,
        mevcutKilo: 85,
        hedefKilo: 85,
        hedef: Hedef.formdaKal,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: ['yumurta', 'süt', 'ceviz'],
        kayitTarihi: DateTime.now(),
        soyad: 'Kaçar'),
    KullaniciProfili(
        id: '18',
        ad: 'Glutensiz Gizem',
        yas: 29,
        cinsiyet: Cinsiyet.kadin,
        boy: 169,
        mevcutKilo: 63,
        hedefKilo: 60,
        hedef: Hedef.kiloVermek,
        aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Sağlam'),
    KullaniciProfili(
        id: '19',
        ad: 'Kilo Almak İsteyen Vejetaryen',
        yas: 21,
        cinsiyet: Cinsiyet.erkek,
        boy: 190,
        mevcutKilo: 70,
        hedefKilo: 80,
        hedef: Hedef.kiloAlmak,
        aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
        diyetTipi: DiyetTipi.vejetaryen,
        manuelAlerjiler: [],
        kayitTarihi: DateTime.now(),
        soyad: 'Yeşil'),
    KullaniciProfili(
        id: '20',
        ad: 'Formda Kalmak İsteyen Pescetarian',
        yas: 45,
        cinsiyet: Cinsiyet.kadin,
        boy: 162,
        mevcutKilo: 58,
        hedefKilo: 58,
        hedef: Hedef.formdaKal,
        aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
        diyetTipi: DiyetTipi.normal,
        manuelAlerjiler: ['karides'],
        kayitTarihi: DateTime.now(),
        soyad: 'Balıkçı'),
  ];
}
