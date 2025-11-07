// ============================================================================
// lib/domain/services/yemek_onay_servisi.dart
// YEMEK ONAY VE RAPORLAMA SERVİSİ
// ============================================================================

import '../entities/yemek_onay_sistemi.dart';
import '../../data/local/hive_service.dart';
import '../../core/utils/app_logger.dart';

class YemekOnayServisi {
  /// Günün yemek onay durumunu getir
  static Future<GunlukOnayDurumu?> gunlukOnayDurumuGetir(DateTime tarih) async {
    try {
      final onayVerisi = await HiveService.yemekOnayVerisiGetir(tarih);
      
      if (onayVerisi == null) {
        // İlk defa oluşturuluyorsa
        return GunlukOnayDurumu(
          tarih: tarih,
          yemekDurumlari: {},
          sonGuncelleme: DateTime.now(),
        );
      }

      return onayVerisi;
    } catch (e) {
      AppLogger.error('Günlük onay durumu getirme hatası: $e');
      return null;
    }
  }

  /// Yemeği yedi olarak işaretle
  static Future<bool> yedimOlarakIsaretle({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    try {
      final mevcutDurum = await gunlukOnayDurumuGetir(tarih);
      if (mevcutDurum == null) return false;

      final yemekDurumu = mevcutDurum.yemekDurumu(yemekId) ?? 
          YemekOnayVerisi(
            yemekId: yemekId,
            tarih: tarih,
            durum: YemekDurumu.bekliyor,
            degistirilebilir: true,
          );

      final yeniDurum = yemekDurumu.yediOlarakIsaretle(notlar: notlar);
      final gunlukDurum = mevcutDurum.yemekDurumunuGuncelle(yemekId, yeniDurum);

      await HiveService.yemekOnayVerisiKaydet(tarih, gunlukDurum);
      
      AppLogger.info('✅ Yemek yendi olarak işaretlendi: $yemekId');
      return true;
    } catch (e) {
      AppLogger.error('Yemek yedim işaretleme hatası: $e');
      return false;
    }
  }

  /// Yemeği onayla ve kilitle
  static Future<bool> yemegiOnayla({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    try {
      final mevcutDurum = await gunlukOnayDurumuGetir(tarih);
      if (mevcutDurum == null) return false;

      final yemekDurumu = mevcutDurum.yemekDurumu(yemekId);
      if (yemekDurumu == null) return false;

      final yeniDurum = yemekDurumu.onayla(notlar: notlar);
      final gunlukDurum = mevcutDurum.yemekDurumunuGuncelle(yemekId, yeniDurum);

      await HiveService.yemekOnayVerisiKaydet(tarih, gunlukDurum);
      
      // 🎯 RAPORLAMA: Onaylanan yemeği rapor için kaydet
      await _onayliYemegiRaporaEkle(yemekId, tarih, yeniDurum);
      
      AppLogger.success('🔒 Yemek onaylandı ve kilitlendi: $yemekId');
      return true;
    } catch (e) {
      AppLogger.error('Yemek onaylama hatası: $e');
      return false;
    }
  }

  /// Yemeği atla
  static Future<bool> yemegiAtla({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    try {
      final mevcutDurum = await gunlukOnayDurumuGetir(tarih);
      if (mevcutDurum == null) return false;

      final yemekDurumu = mevcutDurum.yemekDurumu(yemekId) ??
          YemekOnayVerisi(
            yemekId: yemekId,
            tarih: tarih,
            durum: YemekDurumu.bekliyor,
            degistirilebilir: true,
          );

      final yeniDurum = yemekDurumu.atla(notlar: notlar);
      final gunlukDurum = mevcutDurum.yemekDurumunuGuncelle(yemekId, yeniDurum);

      await HiveService.yemekOnayVerisiKaydet(tarih, gunlukDurum);
      
      // 📊 RAPORLAMA: Atlanan yemeği rapor için kaydet
      await _atlananYemegiRaporaEkle(yemekId, tarih, yeniDurum);
      
      AppLogger.info('⏭️ Yemek atlandı ve raporlandı: $yemekId');
      return true;
    } catch (e) {
      AppLogger.error('Yemek atlama hatası: $e');
      return false;
    }
  }

  /// Yemek durumunu sıfırla
  static Future<bool> yemekDurumunuSifirla({
    required DateTime tarih,
    required String yemekId,
  }) async {
    try {
      final mevcutDurum = await gunlukOnayDurumuGetir(tarih);
      if (mevcutDurum == null) return false;

      final yemekDurumu = mevcutDurum.yemekDurumu(yemekId);
      if (yemekDurumu == null) return false;

      // Sadece değiştirilebilir olanları sıfırla
      if (!yemekDurumu.degistirilebilir) {
        AppLogger.warning('⚠️ Değiştirilemez yemek sıfırlanamaz: $yemekId');
        return false;
      }

      final yeniDurum = yemekDurumu.sifirla();
      final gunlukDurum = mevcutDurum.yemekDurumunuGuncelle(yemekId, yeniDurum);

      await HiveService.yemekOnayVerisiKaydet(tarih, gunlukDurum);
      
      AppLogger.info('🔄 Yemek sıfırlandı: $yemekId');
      return true;
    } catch (e) {
      AppLogger.error('Yemek sıfırlama hatası: $e');
      return false;
    }
  }

  /// Belirli bir yemeğin durumunu getir
  static Future<YemekDurumu?> yemekDurumuGetir({
    required DateTime tarih,
    required String yemekId,
  }) async {
    try {
      final gunlukDurum = await gunlukOnayDurumuGetir(tarih);
      if (gunlukDurum == null) return null;

      final yemekDurumu = gunlukDurum.yemekDurumu(yemekId);
      return yemekDurumu?.durum;
    } catch (e) {
      AppLogger.error('Yemek durumu getirme hatası: $e');
      return null;
    }
  }

  /// ⭐ ALIAS METODLARI (Geriye dönük uyumluluk için)
  
  /// Alias: yemekYedi
  static Future<bool> yemekYedi({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    return yedimOlarakIsaretle(tarih: tarih, yemekId: yemekId, notlar: notlar);
  }

  /// Alias: yemekOnayla
  static Future<bool> yemekOnayla({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    return yemegiOnayla(tarih: tarih, yemekId: yemekId, notlar: notlar);
  }

  /// Alias: yemekAtla
  static Future<bool> yemekAtla({
    required DateTime tarih,
    required String yemekId,
    String? notlar,
  }) async {
    return yemegiAtla(tarih: tarih, yemekId: yemekId, notlar: notlar);
  }

  /// Alias: haftalikUyumRaporu
  static Future<Map<String, dynamic>> haftalikUyumRaporu({
    required DateTime baslangicTarihi,
  }) async {
    return haftalikRaporOlustur(baslangicTarihi: baslangicTarihi);
  }

  /// Haftalık rapor oluştur
  static Future<Map<String, dynamic>> haftalikRaporOlustur({
    required DateTime baslangicTarihi,
  }) async {
    try {
      final rapor = <String, dynamic>{};
      int toplamYemek = 0;
      int onaylananYemek = 0;
      int atlananYemek = 0;
      double toplamKalori = 0;

      // 7 günlük veriyi topla
      for (int gun = 0; gun < 7; gun++) {
        final tarih = DateTime(
          baslangicTarihi.year,
          baslangicTarihi.month,
          baslangicTarihi.day + gun,
        );

        final plan = await HiveService.planGetir(tarih);
        final gunlukDurum = await gunlukOnayDurumuGetir(tarih);
        
        if (plan != null) {
          // 🔥 FIX: Toplam yemek sayısını PLAN'dan al, onay durumundan değil!
          toplamYemek += plan.ogunler.length; // Bu günkü planlanmış tüm yemekler
          
          if (gunlukDurum != null) {
            // Onay durumu varsa, onaylanan/atlanan sayıları ekle
            onaylananYemek += gunlukDurum.onaylananSayisi;
            atlananYemek += gunlukDurum.atlananSayisi;

            // Günlük planı al ve kalorileri topla
            for (final yemek in plan.ogunler) {
              final yemekDurumu = gunlukDurum.yemekDurumu(yemek.id.toString());
              if (yemekDurumu?.yenmis == true) {
                toplamKalori += yemek.kalori.round();
              }
            }
          } else {
            // Onay durumu yoksa, bu gün için 0 onay/atlama say
            AppLogger.warning('⚠️ ${tarih.day}.${tarih.month} için onay durumu yok');
          }
        } else {
          // Plan yoksa, bu günü atla
          AppLogger.warning('⚠️ ${tarih.day}.${tarih.month} için plan yok');
        }
      }

      final uyumYuzdesi = toplamYemek > 0 ? (onaylananYemek / toplamYemek) * 100 : 0.0;

      rapor['toplamYemek'] = toplamYemek;
      rapor['onaylananYemek'] = onaylananYemek;
      rapor['atlananYemek'] = atlananYemek;
      rapor['uyumYuzdesi'] = uyumYuzdesi;
      rapor['toplamKalori'] = toplamKalori;
      rapor['gunlukOrtalamaKalori'] = toplamKalori / 7;
      rapor['baslangicTarihi'] = baslangicTarihi.toIso8601String(); // ✅ String'e çevir
      rapor['bitisTarihi'] = baslangicTarihi.add(const Duration(days: 6)).toIso8601String(); // ✅ String'e çevir

      AppLogger.success('📊 Haftalık rapor oluşturuldu: %${uyumYuzdesi.toStringAsFixed(1)} uyum');
      return rapor;
    } catch (e) {
      AppLogger.error('Haftalık rapor oluşturma hatası: $e');
      return {};
    }
  }

  /// 🔒 ÖZEL: Onaylanan yemeği rapor sistemine ekle
  static Future<void> _onayliYemegiRaporaEkle(
    String yemekId, 
    DateTime tarih, 
    YemekOnayVerisi onayVerisi
  ) async {
    try {
      // Yemek detaylarını al
      final plan = await HiveService.planGetir(tarih);
      if (plan == null) return;

      final yemek = plan.ogunler.firstWhere(
        (y) => y.id.toString() == yemekId,
        orElse: () => throw Exception('Yemek bulunamadı'),
      );

      // Rapor verisi oluştur
      final raporVerisi = {
        'yemekId': yemekId,
        'yemekAdi': yemek.ad,
        'ogunTipi': yemek.ogun.name,
        'tarih': tarih.toIso8601String(),
        'kalori': yemek.kalori,
        'protein': yemek.protein,
        'karbonhidrat': yemek.karbonhidrat,
        'yag': yemek.yag,
        'onayTarihi': onayVerisi.onayTarihi?.toIso8601String(),
        'notlar': onayVerisi.notlar,
        'malzemeler': yemek.malzemeler,
      };

      // Raporu kaydet (Hive'da ayrı bir box'ta)
      await HiveService.raporVerisiKaydet(tarih, raporVerisi);
      
      AppLogger.success('📈 Onaylı yemek rapora eklendi: ${yemek.ad}');
    } catch (e) {
      AppLogger.error('Rapor ekleme hatası: $e');
    }
  }

  /// 🔒 ÖZEL: Atlanan yemeği rapor sistemine ekle
  static Future<void> _atlananYemegiRaporaEkle(
    String yemekId,
    DateTime tarih,
    YemekOnayVerisi atlanmaVerisi
  ) async {
    try {
      // Yemek detaylarını al
      final plan = await HiveService.planGetir(tarih);
      if (plan == null) return;

      final yemek = plan.ogunler.firstWhere(
        (y) => y.id.toString() == yemekId,
        orElse: () => throw Exception('Yemek bulunamadı'),
      );

      // Rapor verisi oluştur
      final raporVerisi = {
        'yemekId': yemekId,
        'yemekAdi': yemek.ad,
        'ogunTipi': yemek.ogun.name,
        'tarih': tarih.toIso8601String(),
        'kalori': yemek.kalori,
        'protein': yemek.protein,
        'karbonhidrat': yemek.karbonhidrat,
        'yag': yemek.yag,
        'atlanmaTarihi': atlanmaVerisi.onayTarihi?.toIso8601String(),
        'notlar': atlanmaVerisi.notlar,
        'malzemeler': yemek.malzemeler,
        'durum': 'atlandi', // ❌ Atlandı
        'uyumSkoru': 0, // Sıfır uyum
        'kayipKalori': yemek.kalori, // Kaçırılan kalori
      };

      // Raporu kaydet (Hive'da ayrı bir box'ta)
      await HiveService.raporVerisiKaydet(tarih, raporVerisi);
      
      AppLogger.warning('📊 Atlanan yemek rapora eklendi: ${yemek.ad} (-${yemek.kalori.toStringAsFixed(0)} kcal)');
    } catch (e) {
      AppLogger.error('Atlanan yemek rapor ekleme hatası: $e');
    }
  }

  /// Günlük özet oluştur
  static Future<Map<String, dynamic>> gunlukOzetOlustur(DateTime tarih) async {
    try {
      final gunlukDurum = await gunlukOnayDurumuGetir(tarih);
      if (gunlukDurum == null) return {};

      final plan = await HiveService.planGetir(tarih);
      double planlananKalori = 0;
      double alinanKalori = 0;

      if (plan != null) {
        for (final yemek in plan.ogunler) {
          planlananKalori += yemek.kalori;
          
          final yemekDurumu = gunlukDurum.yemekDurumu(yemek.id.toString());
          if (yemekDurumu?.yenmis == true) {
            alinanKalori += yemek.kalori;
          }
        }
      }

      return {
        'tarih': tarih.toIso8601String(),
        'planlananYemek': plan?.ogunler.length ?? 0,
        'yenilenYemek': gunlukDurum.yenmisSayisi,
        'atlananYemek': gunlukDurum.atlananSayisi,
        'onaylananYemek': gunlukDurum.onaylananSayisi,
        'uyumYuzdesi': gunlukDurum.uyumYuzdesi,
        'planlananKalori': planlananKalori,
        'alinanKalori': alinanKalori,
        'kaloriUyumu': planlananKalori > 0 ? (alinanKalori / planlananKalori) * 100 : 0,
        'gunDurumu': gunlukDurum.gunDurumu,
      };
    } catch (e) {
      AppLogger.error('Günlük özet oluşturma hatası: $e');
      return {};
    }
  }
}