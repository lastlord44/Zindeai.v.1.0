// ============================================================================
// 🚨 HAFTALİK PLAN STRES TESTİ - STANDALONE VERSİYON
// ============================================================================
// V5.3 RADİKAL FİX sistemi için 20 farklı profil ile kapsamlı test
// Hedef: %85+ başarı oranı (diyetisyen toleransı: ±15%)

import 'dart:io';
import 'dart:math';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/usecases/makro_hesapla.dart';
import 'lib/domain/services/ai_beslenme_servisi_v5_3_radical_fix.dart';
import 'lib/domain/entities/kullanici_profili.dart';
import 'lib/domain/entities/hedef.dart';
import 'lib/domain/entities/gunluk_plan.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  print('🚀 === HAFTALİK PLAN STRES TESTİ BAŞLATIYOR ===');
  
  try {
    // 🔧 Sistem hazırlığı
    await HiveService.init();
    final aiServisi = AIBeslenmeServisiV53RadikalFix();
    final makroHesapla = MakroHesapla();
    
    // 🎯 Test profilleri oluştur
    final testProfileri = _20FarkliProfilOlustur();
    
    int basariliPlanSayisi = 0;
    final List<Map<String, dynamic>> detayliRapor = [];

    print('🔥 === 20 PROFİL STRES TESTİ BAŞLADI ===');
    print('🎯 HEDEF: DİYETİSYEN STANDARDI (±15% tolerans)');
    
    for (int i = 0; i < testProfileri.length; i++) {
      final profil = testProfileri[i];
      print('');
      print('📋 === PROFİL ${i + 1}/20 TEST EDİLİYOR ===');
      print('👤 ${profil.ad}: ${profil.yas}yaş, ${profil.cinsiyet.aciklama}, ${profil.boy.toInt()}cm, ${profil.mevcutKilo.toInt()}kg');
      print('🎯 Hedef: ${profil.hedef.aciklama} | Aktivite: ${profil.aktiviteSeviyesi.aciklama}');
      print('🥗 Diyet: ${profil.diyetTipi.aciklama}');

      try {
        // Makro hedefleri hesapla
        final makroHedefleri = makroHesapla.tamHesaplama(profil);
        
        print('🎯 HESAPLANAN MAKRO HEDEFLERİ:');
        print('   🔥 Kalori: ${makroHedefleri.gunlukKalori.toInt()} kcal');
        print('   🥩 Protein: ${makroHedefleri.gunlukProtein.toInt()}g');
        print('   🍞 Karb: ${makroHedefleri.gunlukKarbonhidrat.toInt()}g');
        print('   🧈 Yağ: ${makroHedefleri.gunlukYag.toInt()}g');

        // 7 günlük haftalık plan oluştur
        final haftalikPlanlar = <GunlukPlan>[];
        int gunlukBasariSayisi = 0;

        for (int gun = 0; gun < 7; gun++) {
          final gunTarihi = DateTime.now().add(Duration(days: gun));
          
          print('   📅 Gün ${gun + 1} planlanıyor...');
          
          final gunlukPlan = await aiServisi.gunlukPlanOlustur(
            hedefKalori: makroHedefleri.gunlukKalori,
            hedefProtein: makroHedefleri.gunlukProtein,
            hedefKarb: makroHedefleri.gunlukKarbonhidrat,
            hedefYag: makroHedefleri.gunlukYag,
            hedef: profil.hedef,
            kisitlamalar: profil.tumKisitlamalar,
            tarih: gunTarihi,
          );

          haftalikPlanlar.add(gunlukPlan);

          // Günlük tolerans kontrolü
          final gunlukBasarili = _diyetisyenToleransKontrol(
            gercekKalori: gunlukPlan.toplamKalori,
            gercekProtein: gunlukPlan.toplamProtein,
            gercekKarb: gunlukPlan.toplamKarbonhidrat,
            gercekYag: gunlukPlan.toplamYag,
            hedefKalori: makroHedefleri.gunlukKalori,
            hedefProtein: makroHedefleri.gunlukProtein,
            hedefKarb: makroHedefleri.gunlukKarbonhidrat,
            hedefYag: makroHedefleri.gunlukYag,
          );

          if (gunlukBasarili) gunlukBasariSayisi++;

          print('   📅 Gün ${gun + 1}: ${gunlukBasarili ? "✅ BAŞARILI" : "❌ BAŞARISIZ"}');
          print('      📊 K:${gunlukPlan.toplamKalori.toInt()}/${makroHedefleri.gunlukKalori.toInt()} P:${gunlukPlan.toplamProtein.toInt()}g/${makroHedefleri.gunlukProtein.toInt()}g C:${gunlukPlan.toplamKarbonhidrat.toInt()}g/${makroHedefleri.gunlukKarbonhidrat.toInt()}g Y:${gunlukPlan.toplamYag.toInt()}g/${makroHedefleri.gunlukYag.toInt()}g');
        }

        // Haftalık başarı oranı hesapla
        final haftalikBasariOrani = (gunlukBasariSayisi / 7.0) * 100;
        final profilBasarili = haftalikBasariOrani >= 70; // Diyetisyen standardı: En az %70 başarı

        if (profilBasarili) basariliPlanSayisi++;

        // Haftalık ortalama hesapla
        final haftalikOrtKalori = haftalikPlanlar.map((p) => p.toplamKalori).reduce((a, b) => a + b) / 7;
        final haftalikOrtProtein = haftalikPlanlar.map((p) => p.toplamProtein).reduce((a, b) => a + b) / 7;
        final haftalikOrtKarb = haftalikPlanlar.map((p) => p.toplamKarbonhidrat).reduce((a, b) => a + b) / 7;
        final haftalikOrtYag = haftalikPlanlar.map((p) => p.toplamYag).reduce((a, b) => a + b) / 7;

        print('');
        print('📊 === PROFİL ${i + 1} HAFTALİK SONUÇ ===');
        print('🎯 Haftalık Başarı: ${gunlukBasariSayisi}/7 gün (${haftalikBasariOrani.toStringAsFixed(1)}%)');
        print('📈 Haftalık Ortalama:');
        print('   🔥 Kalori: ${haftalikOrtKalori.toInt()}/${makroHedefleri.gunlukKalori.toInt()} (${((haftalikOrtKalori/makroHedefleri.gunlukKalori-1)*100).toStringAsFixed(1)}%)');
        print('   🥩 Protein: ${haftalikOrtProtein.toInt()}g/${makroHedefleri.gunlukProtein.toInt()}g (${((haftalikOrtProtein/makroHedefleri.gunlukProtein-1)*100).toStringAsFixed(1)}%)');
        print('   🍞 Karb: ${haftalikOrtKarb.toInt()}g/${makroHedefleri.gunlukKarbonhidrat.toInt()}g (${((haftalikOrtKarb/makroHedefleri.gunlukKarbonhidrat-1)*100).toStringAsFixed(1)}%)');
        print('   🧈 Yağ: ${haftalikOrtYag.toInt()}g/${makroHedefleri.gunlukYag.toInt()}g (${((haftalikOrtYag/makroHedefleri.gunlukYag-1)*100).toStringAsFixed(1)}%)');
        print('🏆 DURUM: ${profilBasarili ? "✅ BAŞARILI" : "❌ BAŞARISIZ"}');

        // Detaylı rapor için kaydet
        detayliRapor.add({
          'profil': '${profil.ad} - ${profil.hedef.aciklama}',
          'hedefKalori': makroHedefleri.gunlukKalori.toInt(),
          'gercekKalori': haftalikOrtKalori.toInt(),
          'haftalikBasariOrani': haftalikBasariOrani,
          'basarili': profilBasarili,
          'detaylar': {
            'yas': profil.yas,
            'cinsiyet': profil.cinsiyet.aciklama,
            'boy': profil.boy,
            'kilo': profil.mevcutKilo,
            'aktivite': profil.aktiviteSeviyesi.aciklama,
            'diyet': profil.diyetTipi.aciklama,
          }
        });

      } catch (e, stackTrace) {
        print('❌ PROFİL ${i + 1} TEST HATASI: $e');
        print('Stack trace: $stackTrace');
        
        detayliRapor.add({
          'profil': '${profil.ad} - ${profil.hedef.aciklama}',
          'hata': e.toString(),
          'basarili': false,
          'haftalikBasariOrani': 0.0,
        });
      }
    }

    final genel_basari_orani = (basariliPlanSayisi / testProfileri.length) * 100;

    // FİNAL RAPORU
    print('');
    print('🎉 === HAFTALİK PLAN STRES TESTİ FİNAL RAPORU ===');
    print('📊 GENEL BAŞARI ORANI: $basariliPlanSayisi/${testProfileri.length} (${genel_basari_orani.toStringAsFixed(1)}%)');
    
    if (genel_basari_orani >= 85) {
      print('🏆 MÜKEMMEL! DİYETİSYEN STANDARDI SAĞLANDI!');
    } else if (genel_basari_orani >= 70) {
      print('✅ İYİ! Kabul edilebilir seviye.');
    } else if (genel_basari_orani >= 50) {
      print('⚠️ ORTA! Gelişim gerekli.');
    } else {
      print('❌ KRİTİK DURUM! Sistem revizyonu şart!');
    }

    print('');
    print('📈 DETAYLI BAŞARI ANALİZİ:');
    
    // Hedef türlerine göre başarı analizi
    final hedefBasarilari = <String, List<bool>>{};
    for (final rapor in detayliRapor) {
      if (rapor['hata'] == null) {
        final profil = rapor['profil'] as String;
        final hedefTuru = profil.split(' - ')[1];
        hedefBasarilari[hedefTuru] ??= [];
        hedefBasarilari[hedefTuru]!.add(rapor['basarili'] as bool);
      }
    }

    hedefBasarilari.forEach((hedef, basarilar) {
      final basariSayisi = basarilar.where((b) => b).length;
      final oran = (basariSayisi / basarilar.length) * 100;
      print('   🎯 $hedef: $basariSayisi/${basarilar.length} (${oran.toStringAsFixed(1)}%)');
    });

    // Test sonucu değerlendirmesi
    print('');
    if (genel_basari_orani >= 70) {
      print('✅ SONUÇ: Diyetisyen standardı SAĞLANDI! (%${genel_basari_orani.toStringAsFixed(1)} başarı)');
    } else {
      print('❌ SONUÇ: Diyetisyen standardı sağlanamadı. En az %70 başarı bekleniyor, mevcut: %${genel_basari_orani.toStringAsFixed(1)}');
    }
    
    if (genel_basari_orani < 85) {
      print('⚠️ HEDEF %85+ BAŞARI ORANI TUTMADI! Sistem optimizasyonu gerekli.');
    }
    
    print('');
    print('🎉 === STRES TESTİ TAMAMLANDI ===');
    
  } catch (e, stackTrace) {
    print('❌ STRES TESTİ KRİTİK HATA: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// 20 farklı profil oluştur - GERÇEK VERİ YAPISI ile
List<KullaniciProfili> _20FarkliProfilOlustur() {
  final Random rnd = Random(42); // Sabit seed ile reproducible test
  
  return [
    // 1. Cut Profile - Genç Kadın
    KullaniciProfili(
      id: '1',
      ad: 'Ayşe',
      soyad: 'Cut',
      yas: 25,
      boy: 165.0,
      mevcutKilo: 70.0,
      hedefKilo: 60.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 2. Bulk Profile - Genç Erkek
    KullaniciProfili(
      id: '2',
      ad: 'Mehmet',
      soyad: 'Bulk',
      yas: 28,
      boy: 180.0,
      mevcutKilo: 75.0,
      hedefKilo: 85.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 3. Lean Bulk - Kas + Kilo
    KullaniciProfili(
      id: '3',
      ad: 'Emre',
      soyad: 'LeanBulk',
      yas: 30,
      boy: 175.0,
      mevcutKilo: 70.0,
      hedefKilo: 75.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 4. Cut + Kas Koruma
    KullaniciProfili(
      id: '4',
      ad: 'Zeynep',
      soyad: 'CutMuscle',
      yas: 27,
      boy: 170.0,
      mevcutKilo: 65.0,
      hedefKilo: 58.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloVer,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 5. Maintenance - Formu Koruma
    KullaniciProfili(
      id: '5',
      ad: 'Can',
      soyad: 'Maintenance',
      yas: 35,
      boy: 178.0,
      mevcutKilo: 80.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.formdaKal,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 6. Vejetaryen Cut
    KullaniciProfili(
      id: '6',
      ad: 'Selin',
      soyad: 'VegCut',
      yas: 26,
      boy: 162.0,
      mevcutKilo: 68.0,
      hedefKilo: 60.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.vejetaryen,
      kayitTarihi: DateTime.now(),
    ),

    // 7. Vegan Bulk
    KullaniciProfili(
      id: '7',
      ad: 'Arda',
      soyad: 'VeganBulk',
      yas: 29,
      boy: 182.0,
      mevcutKilo: 72.0,
      hedefKilo: 80.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloAlmak,
      diyetTipi: DiyetTipi.vegan,
      kayitTarihi: DateTime.now(),
    ),

    // 8. Hareketsiz Cut
    KullaniciProfili(
      id: '8',
      ad: 'Fatma',
      soyad: 'SedentaryCut',
      yas: 32,
      boy: 160.0,
      mevcutKilo: 75.0,
      hedefKilo: 65.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.hareketsiz,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 9. Çok Aktif Maintenance
    KullaniciProfili(
      id: '9',
      ad: 'Burak',
      soyad: 'ActiveMain',
      yas: 24,
      boy: 185.0,
      mevcutKilo: 82.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.formdaKal,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 10. Orta Yaş Cut
    KullaniciProfili(
      id: '10',
      ad: 'Hülya',
      soyad: 'MiddleAgeCut',
      yas: 42,
      boy: 158.0,
      mevcutKilo: 72.0,
      hedefKilo: 62.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 11. Genç Kız Kas Yapma
    KullaniciProfili(
      id: '11',
      ad: 'Deniz',
      soyad: 'YoungMuscle',
      yas: 22,
      boy: 168.0,
      mevcutKilo: 55.0,
      hedefKilo: 60.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloAl,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 12. Uzun Boylu Bulk
    KullaniciProfili(
      id: '12',
      ad: 'Kaan',
      soyad: 'TallBulk',
      yas: 26,
      boy: 195.0,
      mevcutKilo: 85.0,
      hedefKilo: 95.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kiloAlmak,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 13. Alerjili Profil
    KullaniciProfili(
      id: '13',
      ad: 'Elif',
      soyad: 'Allergy',
      yas: 28,
      boy: 165.0,
      mevcutKilo: 62.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.formdaKal,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: ['Fındık', 'Badem'],
      kayitTarihi: DateTime.now(),
    ),

    // 14. Mega Bulk - Çok Yüksek Kalori
    KullaniciProfili(
      id: '14',
      ad: 'Oğuz',
      soyad: 'MegaBulk',
      yas: 24,
      boy: 190.0,
      mevcutKilo: 90.0,
      hedefKilo: 105.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 15. Agresif Cut
    KullaniciProfili(
      id: '15',
      ad: 'İrem',
      soyad: 'AggressiveCut',
      yas: 29,
      boy: 163.0,
      mevcutKilo: 78.0,
      hedefKilo: 58.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloVer,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 16. Hafif Aktif Bulk
    KullaniciProfili(
      id: '16',
      ad: 'Batuhan',
      soyad: 'LightBulk',
      yas: 31,
      boy: 177.0,
      mevcutKilo: 68.0,
      hedefKilo: 75.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.kiloAlmak,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 17. Orta Yaş Maintenance
    KullaniciProfili(
      id: '17',
      ad: 'Serap',
      soyad: 'MiddleMain',
      yas: 45,
      boy: 164.0,
      mevcutKilo: 65.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.hafifAktif,
      hedef: Hedef.formdaKal,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 18. Kısa Cut
    KullaniciProfili(
      id: '18',
      ad: 'Merve',
      soyad: 'ShortCut',
      yas: 25,
      boy: 155.0,
      mevcutKilo: 65.0,
      hedefKilo: 55.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kiloVermek,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 19. Power Bulk - Güçlü
    KullaniciProfili(
      id: '19',
      ad: 'Barış',
      soyad: 'PowerBulk',
      yas: 27,
      boy: 183.0,
      mevcutKilo: 88.0,
      hedefKilo: 95.0,
      cinsiyet: Cinsiyet.erkek,
      aktiviteSeviyesi: AktiviteSeviyesi.cokAktif,
      hedef: Hedef.kasKazanKiloAl,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),

    // 20. Balanced Cut
    KullaniciProfili(
      id: '20',
      ad: 'Ceren',
      soyad: 'BalancedCut',
      yas: 33,
      boy: 167.0,
      mevcutKilo: 70.0,
      hedefKilo: 63.0,
      cinsiyet: Cinsiyet.kadin,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      hedef: Hedef.kasKazanKiloVer,
      diyetTipi: DiyetTipi.normal,
      kayitTarihi: DateTime.now(),
    ),
  ];
}

/// Diyetisyen tolerans kontrolü - ±15% standart
bool _diyetisyenToleransKontrol({
  required double gercekKalori,
  required double gercekProtein,
  required double gercekKarb,
  required double gercekYag,
  required double hedefKalori,
  required double hedefProtein,
  required double hedefKarb,
  required double hedefYag,
}) {
  const double tolerans = 0.15; // ±15%

  // Her makro için tolerans kontrolü
  final kaloriOK = (gercekKalori - hedefKalori).abs() / hedefKalori <= tolerans;
  final proteinOK = hedefProtein > 0 
      ? (gercekProtein - hedefProtein).abs() / hedefProtein <= tolerans
      : true;
  final karbOK = hedefKarb > 0 
      ? (gercekKarb - hedefKarb).abs() / hedefKarb <= tolerans
      : true;
  final yagOK = hedefYag > 0 
      ? (gercekYag - hedefYag).abs() / hedefYag <= tolerans
      : true;

  // TÜM MAKROLAR tolerance'ı sağlamalı
  return kaloriOK && proteinOK && karbOK && yagOK;
}