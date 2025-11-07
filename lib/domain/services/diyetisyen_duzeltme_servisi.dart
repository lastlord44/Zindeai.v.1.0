// lib/domain/services/diyetisyen_duzeltme_servisi.dart
// 🔥 DİYETİSYEN DÜZELTME SİSTEMİ - AI/MOCK PLANLARINI DB İLE TAMAMLA

import 'dart:math';
import '../entities/gunluk_plan.dart';
import '../entities/yemek.dart';
import '../../core/utils/app_logger.dart';
import '../entities/hedef.dart'; // Hedef enum'ı için import

/// 🥗 DİYETİSYEN DÜZELTME SERVİSİ
/// AI/MOCK planlarını %10 tolerans içine getirmek için DB kullanarak düzeltir
class DiyetisyenDuzeltmeServisi {
  /// 🔧 PLANIN MAKRO VE ARA ÖĞÜNLER OYNAMA KISITLAMASI PLANI DÜZELT
  /// AI/MOCK planı al, %10 tolerans dışındaysa düzelt
  Future<GunlukPlan> planiDuzelt(GunlukPlan plan, Hedef hedef) async {
    try {
      AppLogger.info('🥗 DİYETİSYEN DÜZELTME başlıyor...');
      _logPlanDetaylari(plan, "Düzeltme Öncesi Plan");

      GunlukPlan duzeltilmisPlan = plan;
      int denemeSayisi = 0;
      const int maxDeneme = 5; // Sonsuz döngü riskine karşı

      // 🔥 ITERATIF DÜZELTME: Plan toleransa girene kadar tekrarla
      while (!duzeltilmisPlan.tumMakrolarToleranstaMi && denemeSayisi < maxDeneme) {
        denemeSayisi++;
        AppLogger.info('🔄 Düzeltme denemesi #$denemeSayisi...');

        final analizSonucu = _makroAcikFazlalikAnalizi(duzeltilmisPlan);
        _logAnalizSonucu(analizSonucu);
        
        if (_fazlaMakroVarMi(analizSonucu)) {
          AppLogger.debug('Fazla makro tespit edildi. Düzeltme başlıyor...');
          duzeltilmisPlan = _fazlaMakrolariDuzelt(duzeltilmisPlan, analizSonucu, hedef);
        } else if (_eksikMakroVarMi(analizSonucu)) {
          AppLogger.debug('Eksik makro tespit edildi. Tamamlama başlıyor...');
          duzeltilmisPlan = await _eksikMakrolariTamamla(duzeltilmisPlan, analizSonucu);
        } else {
          AppLogger.debug('Makro açığı/fazlası yok ama tolerans dışında. Döngüden çıkılıyor.');
          break;
        }
      }
      
      AppLogger.info('✨ DÜZELTME TAMAMLANDI! Final Plan:');
      _logPlanDetaylari(duzeltilmisPlan, "Düzeltme Sonrası Plan");

      if (denemeSayisi >= maxDeneme) {
        AppLogger.warning('⚠️ Düzeltme maksimum deneme sayısına ulaştı. Plan hedefe tam oturtulamadı.');
      }

      return duzeltilmisPlan;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Diyetisyen düzeltme hatası',
          error: e, stackTrace: stackTrace);
      return plan; // Hata durumunda orijinal planı döndür
    }
  }
  
  /// 📝 ANALİZ SONUCUNU LOGLA
  void _logAnalizSonucu(Map<String, double> analiz) {
    final logMesaji = analiz.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}')
        .join(', ');
    AppLogger.debug('📊 Makro Analizi: $logMesaji');
  }

  /// 📊 MAKRO AÇIK/FAZLALIK ANALİZİ
  Map<String, double> _makroAcikFazlalikAnalizi(GunlukPlan plan) {
    return {
      'kalori_fark': plan.toplamKalori - plan.makroHedefleri.gunlukKalori,
      'protein_fark': plan.toplamProtein - plan.makroHedefleri.gunlukProtein,
      'karb_fark':
          plan.toplamKarbonhidrat - plan.makroHedefleri.gunlukKarbonhidrat,
      'yag_fark': plan.toplamYag - plan.makroHedefleri.gunlukYag,
    };
  }

  /// ❓ FAZLA MAKRO VAR MI?
  bool _fazlaMakroVarMi(Map<String, double> analiz) {
    return analiz.values.any((fark) => fark > 0);
  }

  /// ❓ EKSİK MAKRO VAR MI?
  bool _eksikMakroVarMi(Map<String, double> analiz) {
    return analiz.values.any((fark) => fark < 0);
  }

  /// 🔻 FAZLA MAKROLARI DÜZELT (AKILLI STRATEJİ)
  GunlukPlan _fazlaMakrolariDuzelt(
      GunlukPlan plan, Map<String, double> analiz, Hedef hedef) {
    // 🔥 ULTRA PROFESYONEL DİYETİSYEN KURALI #1 🔥
    if (hedef == Hedef.kasKazanKiloAl || hedef == Hedef.kiloAlmak || hedef == Hedef.formdaKal) {
      // Eğer toplam kalori zaten hedefin altındaysa, KESİNLİKLE porsiyon küçültme.
      if (plan.toplamKalori <= plan.makroHedefleri.gunlukKalori) {
        AppLogger.info('🎯 HEDEF: ${hedef.aciklama}. Toplam kalori hedefin altında. Porsiyon küçültme işlemi ATLANDI.');
        return plan;
      }

      final kaloriFarki = analiz['kalori_fark'] ?? 0;
      final proteinFarki = analiz['protein_fark'] ?? 0;
      final kaloriFazlasiMakul = kaloriFarki > 0 && kaloriFarki < plan.makroHedefleri.gunlukKalori * 0.15;
      final proteinFazlasiMakul = proteinFarki > 0 && proteinFarki < plan.makroHedefleri.gunlukProtein * 0.20;

      // Eğer hem kalori hem de protein fazlası makul seviyedeyse, yine DOKUNMA.
      if (kaloriFazlasiMakul && proteinFazlasiMakul) {
        AppLogger.info('🎯 HEDEF: Kas Kazanma. Makul kalori (+${kaloriFarki.toInt()} kcal) ve protein (+${proteinFarki.toInt()}g) fazlası korundu.');
        return plan;
      }
    }
    
    // 1. En sorunlu makroyu bul (ancak bazı hedefler için protein fazlasını göz ardı et)
    Map<String, double> duzeltilecekAnaliz = Map.from(analiz);
    if (hedef == Hedef.kasKazanKiloAl) {
        // Bu hedeflerde protein fazlası sorun değil, hatta istenebilir.
        // Bu yüzden onu "sorunlu makro" listesinden çıkarıyoruz.
        if (duzeltilecekAnaliz['protein_fark']! > 0) {
            duzeltilecekAnaliz.remove('protein_fark');
        }
    }

    final sorunluMakroEntry = duzeltilecekAnaliz.entries
        .where((e) => e.value > 0)
        .reduce((a, b) => a.value > b.value ? a : b);
    final sorunluMakroAdi = sorunluMakroEntry.key.split('_').first;
    final fazlaMiktar = sorunluMakroEntry.value;

    // 2. Bu makroya en çok katkıda bulunan öğünü bul
    final ogunler = plan.ogunler.whereType<Yemek>().toList();
    if (ogunler.isEmpty) return plan;

    // 🔥 PROFESYONEL DOKUNUŞ: Kilo verirken proteini koru!
    // Eğer sorunlu makro kalori ise, en DÜŞÜK proteinli öğünü hedef al ki protein kaybı az olsun.
    Yemek hedefOgun;
    if (sorunluMakroAdi == 'kalori' && (hedef == Hedef.kiloVermek)) {
        hedefOgun = ogunler.reduce((a, b) => a.protein < b.protein ? a : b);
        AppLogger.info('🎯 HEDEF: Kilo Verme. Proteini korumak için en düşük proteinli öğün (${hedefOgun.ad}) hedef alınıyor.');
    } else {
        hedefOgun = ogunler.reduce((a, b) {
            final aDeger = a.makroDegeri(sorunluMakroAdi);
            final bDeger = b.makroDegeri(sorunluMakroAdi);
            return aDeger > bDeger ? a : b;
        });
    }

    // 3. Düzeltme oranını hesapla
    final hedefDeger = plan.makroHedefleri.makroDegeri(sorunluMakroAdi);
    final toleransSiniri =
        hedefDeger * (1 + GunlukPlan.kaloriToleransYuzdesi / 100);
    final mevcutToplam = hedefDeger + fazlaMiktar;
    final azaltilmasiGereken = mevcutToplam - toleransSiniri;

    final hedefOgunMakroDegeri = hedefOgun.makroDegeri(sorunluMakroAdi);
    if (hedefOgunMakroDegeri <= 0) {
      AppLogger.warning('⚠️ Hedef öğünün (${hedefOgun.ad}) sorunlu makro değeri (${sorunluMakroAdi}) sıfır veya negatif. Düzeltme atlanıyor.');
      if (plan.araOgun2 != null) return plan.copyWith(araOgun2: null);
      if (plan.araOgun1 != null) return plan.copyWith(araOgun1: null);
      return plan;
    }

    // 🔥 YENİ GÜVENLİ AZALTMA ORANI
    double azaltmaOrani = (azaltilmasiGereken / hedefOgunMakroDegeri);
    azaltmaOrani = azaltmaOrani.clamp(0.0, 0.3); // Agresif küçültmeyi engelle, max %30 azalt

    final carpan = 1.0 - azaltmaOrani;
    AppLogger.debug('📉 Azaltma detayı: Sorunlu Makro: $sorunluMakroAdi, Hedef Öğün: ${hedefOgun.ad}, Azaltma Oranı: ${azaltmaOrani.toStringAsFixed(2)}, Çarpan: ${carpan.toStringAsFixed(2)}');

    // 4. Sadece hedef öğünü ölçekle
    final yeniHedefOgun = _porsiyonAzalt(hedefOgun, carpan);

    // 🔥 ULTRA PROFESYONEL DİYETİSYEN KURALI #2 (GÜNCELLENDİ) 🔥
    // Eğer porsiyon anlamsız derecede küçüldüyse, tamamen kaldırmak yerine
    // daha uygun bir atıştırmalık ile değiştir.
    if (yeniHedefOgun.kalori < 50) {
      AppLogger.info('🗑️ Anlamsız porsiyon (${yeniHedefOgun.ad}) daha uygun bir alternatifle değiştiriliyor.');
      final eksikAnaliz = _makroAcikFazlalikAnalizi(plan.copyWithOgun(hedefOgun.id, null));
      final alternatifYemek = _enUygunAtistirmalikBul(eksikAnaliz);
      if (alternatifYemek != null) {
        return plan.copyWithOgun(hedefOgun.id, alternatifYemek.copyWith(ogun: hedefOgun.ogun));
      }
      // Alternatif bulunamazsa, öğünü kaldır.
      return plan.copyWithOgun(hedefOgun.id, null);
    }

    // 5. Planı yeni öğünle güncelle
    GunlukPlan yeniPlan = plan.copyWithOgun(hedefOgun.id, yeniHedefOgun);
    AppLogger.debug('🔄 Plan, ölçeklenmiş öğünle güncellendi: ${yeniHedefOgun.ad} (${yeniHedefOgun.kalori.toStringAsFixed(0)} kcal)');

    // 🔥🔥🔥 AKILLI DENGELEME SİSTEMİ (SENKRON) 🔥🔥🔥
    // Azaltma sonrası oluşan açığı anında doldurarak planın çökmesini engelle.
    final dengelemeAnalizi = _makroAcikFazlalikAnalizi(yeniPlan);
    if (_eksikMakroVarMi(dengelemeAnalizi)) {
      AppLogger.debug('📉 Porsiyon azaltma sonrası açık oluştu. Dengeleme için atıştırmalık ekleniyor...');
      // Bu mantık bir sonraki döngüde _eksikMakrolariTamamla tarafından zaten hallediliyor.
      // Bu yüzden burada ek bir işlem yapmaya gerek yok, döngüye güveniyoruz.
    }

    // 6. Hala tolerans dışındaysa, en küçük ara öğünü sil (SON ÇARE)
    final araAnaliz = _makroAcikFazlalikAnalizi(yeniPlan);
    if (_fazlaMakroVarMi(araAnaliz)) {
      AppLogger.warning('⚠️ Porsiyon azaltmaya rağmen hala fazla makro var. Son çare olarak en küçük ara öğün siliniyor.');
      if (yeniPlan.araOgun2 != null && (yeniPlan.araOgun1 == null || yeniPlan.araOgun2!.kalori < yeniPlan.araOgun1!.kalori)) {
        return yeniPlan.copyWith(araOgun2: null);
      }
      if (yeniPlan.araOgun1 != null) {
        return yeniPlan.copyWith(araOgun1: null);
      }
    }

    return yeniPlan;
  }

  /// 📉 PORSİYON AZALT (AKILLI)
  Yemek _porsiyonAzalt(Yemek yemek, double carpan) {
    final yeniMalzemeler = _akilliMalzemeOlcekle(yemek, carpan);
    return yemek.copyWith(
      kalori: yemek.kalori * carpan,
      protein: yemek.protein * carpan,
      karbonhidrat: yemek.karbonhidrat * carpan,
      yag: yemek.yag * carpan,
      malzemeler: yeniMalzemeler,
    );
  }

  /// 🔼 EKSİK MAKROLARI TAMAMLA (DB'den yemek ekle) - YENİ STRATEJİ
  Future<GunlukPlan> _eksikMakrolariTamamla(
      GunlukPlan plan, Map<String, double> analiz) async {
    final eksikler = {
      'kalori': (analiz['kalori_fark'] ?? 0.0).abs(),
      'protein': (analiz['protein_fark'] ?? 0.0).abs(),
      'karb': (analiz['karb_fark'] ?? 0.0).abs(),
      'yag': (analiz['yag_fark'] ?? 0.0).abs(),
    };

    // 🔥 GÜNCELLENMİŞ MANTIK: Önce boş slotları doldur.
    if (plan.araOgun1 == null) {
      final eklenecekYemek = _enUygunAtistirmalikBul(eksikler, OgunTipi.araOgun1);
      if (eklenecekYemek == null) return plan;
      AppLogger.debug('➕ Boş Ara Öğün 1 dolduruluyor: ${eklenecekYemek.ad}');
      return plan.copyWith(araOgun1: eklenecekYemek.copyWith(ogun: OgunTipi.araOgun1));
    }
    if (plan.araOgun2 == null) {
      final eklenecekYemek = _enUygunAtistirmalikBul(eksikler, OgunTipi.araOgun2);
      if (eklenecekYemek == null) return plan;
      AppLogger.debug('➕ Boş Ara Öğün 2 dolduruluyor: ${eklenecekYemek.ad}');
      return plan.copyWith(araOgun2: eklenecekYemek.copyWith(ogun: OgunTipi.araOgun2));
    }
    if (plan.geceAtistirma == null && plan.makroHedefleri.gunlukKalori >= 2800) {
      final eklenecekYemek = _enUygunAtistirmalikBul(eksikler, OgunTipi.geceAtistirma);
      if (eklenecekYemek == null) return plan;
      AppLogger.debug('➕ Boş Gece Atıştırması dolduruluyor: ${eklenecekYemek.ad}');
      return plan.copyWith(geceAtistirma: eklenecekYemek.copyWith(ogun: OgunTipi.geceAtistirma));
    }

    // Boş slot yoksa, en uygunsuz öğünü (hedefe en uzak olanı) değiştir.
    final ogunler = plan.ogunler.whereType<Yemek>().toList();
    if (ogunler.isEmpty) return plan;

    Yemek degistirilecekOgun = ogunler.first;
    double enKotuSkor = -1;

    for (final ogun in ogunler) {
      final kaloriFark = (ogun.kalori - plan.makroHedefleri.gunlukKalori * 0.2).abs(); // Örnek bir hedef
      if (kaloriFark > enKotuSkor) {
        enKotuSkor = kaloriFark;
        degistirilecekOgun = ogun;
      }
    }
    
    final eklenecekYemek = _enUygunAtistirmalikBul(eksikler, degistirilecekOgun.ogun);
    if (eklenecekYemek == null) return plan;

    AppLogger.info('🔄 Boş slot yok. En uygunsuz öğün (${degistirilecekOgun.ad}) yeni atıştırmalıkla değiştiriliyor.');
    final yeniYemek = eklenecekYemek.copyWith(ogun: degistirilecekOgun.ogun);
    return plan.copyWithOgun(degistirilecekOgun.id, yeniYemek);
  }

  /// 💯 EN UYGUN ATIŞTIRMALIK BUL (SKORLAMA SİSTEMİ)
  Yemek? _enUygunAtistirmalikBul(Map<String, double> eksikler, [OgunTipi? ogunTipi]) {
    final atistirmaliklar = _tumAtistirmaliklar(ogunTipi);
    if (atistirmaliklar.isEmpty) {
      AppLogger.warning('⚠️ Uygun atıştırmalık bulunamadı. Öğün Tipi: ${ogunTipi?.name}');
      return null;
    }

    Yemek? enIyiSecim;
    double enIyiSkor = double.infinity;

    for (final atistirmalik in atistirmaliklar) {
      final kaloriFark =
          pow(atistirmalik['kalori']! - eksikler['kalori']!, 2).toDouble();
      final proteinFark =
          pow(atistirmalik['protein']! - eksikler['protein']!, 2).toDouble() *
              4;
      final karbFark =
          pow(atistirmalik['karb']! - eksikler['karb']!, 2).toDouble() * 2;
      final yagFark =
          pow(atistirmalik['yag']! - eksikler['yag']!, 2).toDouble();

      final skor = kaloriFark + proteinFark + karbFark + yagFark;

      if (skor < enIyiSkor) {
        enIyiSkor = skor;
        enIyiSecim = Yemek(
          id: 'diyetisyen_ek_${DateTime.now().millisecondsSinceEpoch}',
          ad: atistirmalik['ad'] as String,
          ogun: OgunTipi.araOgun2, // Bu geçici, sonra üzerine yazılacak
          kalori: atistirmalik['kalori'] as double,
          protein: atistirmalik['protein'] as double,
          karbonhidrat: atistirmalik['karb'] as double,
          yag: atistirmalik['yag'] as double,
          malzemeler: atistirmalik['malzemeler'] != null ? List<String>.from(atistirmalik['malzemeler'] as List) : [],
          hazirlamaSuresi: 3,
          zorluk: Zorluk.kolay,
          etiketler: ['diyetisyen-ekledi', 'dengeli-atıştırmalık'],
        );
      }
    }
    return enIyiSecim;
  }

  /// 📚 TÜM ATIŞTIRMALIKLAR LİSTESİ (YENİLENDİ VE ZENGİNLEŞTİRİLDİ)
  List<Map<String, dynamic>> _tumAtistirmaliklar([OgunTipi? ogunTipi]) {
    final List<Map<String, dynamic>> tumListe = [
      // Yüksek Proteinli Seçenekler (Ara öğünler için daha uygun)
      {'ad': 'Süzme Yoğurt & Ceviz', 'protein': 20.0, 'karb': 8.0, 'yag': 15.0, 'kalori': 247.0, 'malzemeler': ['Süzme Yoğurt (200g)', 'Ceviz (5 adet)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Cottage Peynir & Badem', 'protein': 25.0, 'karb': 5.0, 'yag': 10.0, 'kalori': 210.0, 'malzemeler': ['Cottage Peyniri (150g)', 'Badem (10 adet)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Hindi Füme & Salatalık', 'protein': 18.0, 'karb': 3.0, 'yag': 4.0, 'kalori': 120.0, 'malzemeler': ['Hindi Füme (80g)', 'Salatalık (1 adet)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Ton Balığı & Kraker', 'protein': 22.0, 'karb': 15.0, 'yag': 8.0, 'kalori': 220.0, 'malzemeler': ['Ton Balığı (light, 100g)', 'Tam Buğday Kraker (4 adet)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Protein Shake (Süt ile)', 'protein': 28.0, 'karb': 12.0, 'yag': 5.0, 'kalori': 205.0, 'malzemeler': ['Whey Protein (1 ölçek)', 'Süt (200ml)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},

      // Dengeli Makro Seçenekleri (Tüm atıştırmalık saatlerine uygun)
      {'ad': 'Elma & Fıstık Ezmesi', 'protein': 8.0, 'karb': 25.0, 'yag': 16.0, 'kalori': 276.0, 'malzemeler': ['Elma (1 orta)', 'Fıstık Ezmesi (2 YK)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Muz & Yoğurt', 'protein': 12.0, 'karb': 35.0, 'yag': 3.0, 'kalori': 215.0, 'malzemeler': ['Muz (1 orta)', 'Yoğurt (150g)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Yulaf Ezmesi & Süt', 'protein': 10.0, 'karb': 30.0, 'yag': 8.0, 'kalori': 232.0, 'malzemeler': ['Yulaf Ezmesi (40g)', 'Süt (150ml)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Avokado Tost', 'protein': 10.0, 'karb': 25.0, 'yag': 15.0, 'kalori': 275.0, 'malzemeler': ['Avokado (1/2 adet)', 'Tam Buğday Ekmeği (1 dilim)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2]},
      {'ad': 'Labne & Ceviz & Bal', 'protein': 10.0, 'karb': 18.0, 'yag': 14.0, 'kalori': 242.0, 'malzemeler': ['Labne (100g)', 'Ceviz (6 adet)', 'Bal (1 tatlı kaşığı)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},

      // Düşük Kalorili & Hafif Seçenekler (Özellikle gece için ideal)
      {'ad': 'Salatalık & Domates & Peynir', 'protein': 8.0, 'karb': 6.0, 'yag': 7.0, 'kalori': 119.0, 'malzemeler': ['Salatalık (1 adet)', 'Domates (1 adet)', 'Beyaz Peynir (30g)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Yeşil Elma & Tarçın', 'protein': 1.0, 'karb': 22.0, 'yag': 1.0, 'kalori': 101.0, 'malzemeler': ['Yeşil Elma (1 adet)', 'Tarçın (1 çay kaşığı)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Havuç & Humus', 'protein': 5.0, 'karb': 15.0, 'yag': 8.0, 'kalori': 152.0, 'malzemeler': ['Havuç (2 adet)', 'Humus (2 YK)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Sade Kefir & Leblebi', 'protein': 10.0, 'karb': 18.0, 'yag': 4.0, 'kalori': 148.0, 'malzemeler': ['Kefir (200ml)', 'Sarı Leblebi (30g)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
      {'ad': 'Meyveli Kefir Smoothie', 'protein': 8.0, 'karb': 25.0, 'yag': 3.0, 'kalori': 159.0, 'malzemeler': ['Kefir (150ml)', 'Donmuş Meyve (80g)'], 'uygunOgun': [OgunTipi.araOgun1, OgunTipi.araOgun2, OgunTipi.geceAtistirma]},
    ];

    if (ogunTipi == null) {
      return tumListe;
    }

    return tumListe.where((element) {
      final List<OgunTipi> uygunOgunler = element['uygunOgun'] as List<OgunTipi>;
      return uygunOgunler.contains(ogunTipi);
    }).toList();
  }

  /// 🔧 AKILLI MALZEME ÖLÇEKLE
  List<String> _akilliMalzemeOlcekle(Yemek yemek, double carpan) {
    List<String> yeniMalzemeler = [];
    Set<String> islenenMalzemeler = {};

    const varsayilanMiktarlar = {
      'yumurta': '(1 adet)',
      'roka': '(50g)',
      'marul': '(50g)',
      'salatalık': '(1 adet)',
      'domates': '(1 adet)',
      'zeytin': '(10 adet)',
      'soğan': '(0.25 adet)',
      'biber': '(1 adet)',
      'limon': '(0.5 adet)',
    };

    for (var malzeme in yemek.malzemeler) {
      String islenecekMalzeme = malzeme;
      final malzemeLower = malzeme.toLowerCase().trim();
      bool miktarVar = RegExp(r'\d').hasMatch(malzeme);

      if (!miktarVar) {
        for (var entry in varsayilanMiktarlar.entries) {
          if (malzemeLower.contains(entry.key)) {
            islenecekMalzeme = '${malzeme.trim()} ${entry.value}';
            break;
          }
        }
      }

      final olcekliMalzeme = _tekMalzemeOlcekle(islenecekMalzeme, carpan);
      if (olcekliMalzeme.isNotEmpty) {
        yeniMalzemeler.add(olcekliMalzeme);
        final anaMalzemeAdi = _anaMalzemeyiBul(olcekliMalzeme);
        if (anaMalzemeAdi != null) {
          islenenMalzemeler.add(anaMalzemeAdi.toLowerCase());
        }
      }
    }

    final anahtarKelimeler = _yemekAdindanAnahtarKelimeBul(yemek.ad);

    for (var kelime in anahtarKelimeler) {
      final kelimeLower = kelime.toLowerCase();
      if (!islenenMalzemeler.contains(kelimeLower)) {
        final varsayilanMiktar = (150 * carpan).round();
        if (varsayilanMiktar > 0) {
          yeniMalzemeler.insert(0, '$kelime (${varsayilanMiktar}g)');
        }
      }
    }

    return yeniMalzemeler;
  }

  /// Yemek adından potansiyel ana malzemeleri çıkarır
  List<String> _yemekAdindanAnahtarKelimeBul(String yemekAdi) {
    const kaynaklar = [
      'Tavuk',
      'Biftek',
      'Köfte',
      'Balık',
      'Somon',
      'Ton',
      'Hindi',
      'Yumurta',
      'Nohut',
      'Mercimek',
      'Fasulye',
      'Bulgur',
      'Pirinç',
      'Makarna',
      'Yulaf',
      'Kinoa',
      'Çipura',
      'Levrek',
      'Hamsi',
      'Börülce',
      'Barbunya',
      'Karnıyarık',
      'İmambayıldı',
      'Pancake',
      'Midye',
      'Salatalık',
      'Smoothie'
    ];

    return kaynaklar
        .where((k) => yemekAdi.toLowerCase().contains(k.toLowerCase()))
        .toList();
  }

  /// Malzeme string'inden ana malzemeyi bulur
  String? _anaMalzemeyiBul(String malzeme) {
    final match = RegExp(r'^\s*([a-zA-ZğüşıöçĞÜŞIÖÇ\s]+)').firstMatch(malzeme);
    if (match != null) {
      final parcalar = match.group(1)!.toLowerCase().split(' ');
      if (parcalar.isNotEmpty) return parcalar.first;
    }
    return null;
  }

  /// Tek bir malzeme string'ini ölçekler
  String _tekMalzemeOlcekle(String malzeme, double carpan) {
    final regex =
        RegExp(r'^(.*?)\s*\((\d+(?:\.\d+)?)\s*([a-zA-ZğüşıöçĞÜŞIÖÇ]+)\)(.*)$');
    final match = regex.firstMatch(malzeme);

    if (match != null) {
      final besinAdi = match.group(1)!.trim();
      final miktar = double.tryParse(match.group(2)!) ?? 100;
      final birim = match.group(3)!.trim();
      final gerisi = match.group(4)?.trim() ?? '';

      double yeniMiktar;
      if (birim.toLowerCase() == 'adet' ||
          birim.toLowerCase() == 'yk' ||
          birim.toLowerCase() == 'tsp') {
        yeniMiktar = miktar * carpan;
        if (yeniMiktar < 0.25) return '';
        final formattedMiktar =
            yeniMiktar.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        return '$besinAdi ($formattedMiktar $birim)$gerisi'.trim();
      } else {
        yeniMiktar = (miktar * carpan).roundToDouble();
        if (yeniMiktar <= 0) return '';
        return '$besinAdi (${yeniMiktar.round()} $birim)$gerisi'.trim();
      }
    }

    return malzeme;
  }
  
  /// 📋 Planın detaylarını loglar (TEK SATIR FORMATINDA)
  void _logPlanDetaylari(GunlukPlan plan, String baslik) {
    AppLogger.info('📋 $baslik:');
    for (final yemek in plan.ogunler) {
      if (yemek != null) {
        final makroStr = 'P:${yemek.protein.toStringAsFixed(0)}g, K:${yemek.karbonhidrat.toStringAsFixed(0)}g, Y:${yemek.yag.toStringAsFixed(0)}g';
        AppLogger.info('  🍽️ ${yemek.ogun.name.toUpperCase()}: ${yemek.ad} (${yemek.kalori.toStringAsFixed(0)} kcal | $makroStr)');
        // 🔥 KULLANICI TALEBİ: Malzemeleri ve miktarlarını logla
        if (yemek.malzemeler.isNotEmpty) {
          AppLogger.debug('     - Malzemeler: ${yemek.malzemeler.join(" | ")}');
        }
      }
    }
    final toplamMakroStr = 'TOPLAM: ${plan.toplamKalori.toStringAsFixed(0)} kcal, P:${plan.toplamProtein.toStringAsFixed(0)}g, K:${plan.toplamKarbonhidrat.toStringAsFixed(0)}g, Y:${plan.toplamYag.toStringAsFixed(0)}g';
    AppLogger.info('  📊 $toplamMakroStr');
  }
}
