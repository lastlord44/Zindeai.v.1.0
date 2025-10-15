// ============================================================================
// lib/domain/services/yemek_onay_servisi.dart
// YEMEK ONAY SİSTEMİ SERVİSİ - YEDIM/YEMEDIM + ONAY SİSTEMİ
// ============================================================================

import '../../data/local/hive_service.dart';
import '../entities/yemek_onay_sistemi.dart';
import '../../core/utils/app_logger.dart';

class YemekOnayServisi {
  
  /// Günlük onay durumunu getir
  static Future<GunlukOnayDurumu> gunlukOnayDurumuGetir(DateTime tarih) async {
    try {
      AppLogger.info('📋 Günlük onay durumu getiriliyor: ${_tarihString(tarih)}');
      
      // Plan al
      final plan = await HiveService.planGetir(tarih);
      if (plan == null) {
        AppLogger.warning('⚠️ Plan bulunamadı, boş durum döndürülüyor');
        return GunlukOnayDurumu(
          tarih: tarih,
          yemekDurumlari: {},
          sonGuncelleme: DateTime.now(),
        );
      }
      
      // Mevcut durumları al (eski sistem uyumlu)
      final eskiTamamlananlar = await HiveService.tamamlananOgunleriGetir(tarih);
      
      // Yeni onay sistemi durumlarını al
      final onayDurumlari = await _onayDurumlariniGetir(tarih);
      
      final yemekDurumlari = <String, YemekOnayVerisi>{};
      
      // Her yemek için durum oluştur
      for (final yemek in plan.ogunler) {
        if (yemek == null) continue;
        
        // Mevcut onay durumunu kontrol et
        YemekOnayVerisi durum;
        
        if (onayDurumlari.containsKey(yemek.id)) {
          // Yeni sistemde var
          durum = onayDurumlari[yemek.id]!;
        } else {
          // Eski sistemden migrate et
          final eskiDurum = eskiTamamlananlar[yemek.id] ?? false;
          
          durum = YemekOnayVerisi(
            yemekId: yemek.id,
            tarih: tarih,
            durum: eskiDurum ? YemekDurumu.yedi : YemekDurumu.bekliyor,
            yemeTarihi: eskiDurum ? DateTime.now() : null,
            degistirilebilir: true, // Eski sistem verisi, değiştirilebilir
          );
        }
        
        yemekDurumlari[yemek.id] = durum;
      }
      
      final gunlukDurum = GunlukOnayDurumu(
        tarih: tarih,
        yemekDurumlari: yemekDurumlari,
        sonGuncelleme: DateTime.now(),
      );
      
      AppLogger.success('✅ Günlük onay durumu: ${gunlukDurum.uyumYuzdesi.toStringAsFixed(1)}% uyum');
      return gunlukDurum;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Günlük onay durumu getirme hatası', error: e, stackTrace: stackTrace);
      
      return GunlukOnayDurumu(
        tarih: tarih,
        yemekDurumlari: {},
        sonGuncelleme: DateTime.now(),
      );
    }
  }
  
  /// Yemek durumunu güncelle ve kaydet
  static Future<bool> yemekDurumunuGuncelle({
    required String yemekId,
    required DateTime tarih,
    required YemekOnayVerisi yeniDurum,
  }) async {
    try {
      AppLogger.info('🔄 Yemek durumu güncelleniyor: $yemekId -> ${yeniDurum.durum.aciklama}');
      
      // Mevcut durumları al
      final mevcutOnayDurumlari = await _onayDurumlariniGetir(tarih);
      
      // Durumu güncelle
      mevcutOnayDurumlari[yemekId] = yeniDurum;
      
      // Kaydet
      await _onayDurumlariniKaydet(tarih, mevcutOnayDurumlari);
      
      // Eski sistem ile uyumluluk için (legacy support)
      await _eskiSistemIleSync(tarih, mevcutOnayDurumlari);
      
      AppLogger.success('✅ Yemek durumu güncellendi: ${yeniDurum.durum.aciklama}');
      return true;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek durumu güncelleme hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Yemeği "yedi" olarak işaretle
  static Future<bool> yemekYedi({
    required String yemekId,
    required DateTime tarih,
    String? notlar,
  }) async {
    try {
      // Mevcut durumu al
      final mevcutDurum = await _yemekDurumuGetir(yemekId, tarih);
      
      // Değiştirilebilir mi kontrol et
      if (mevcutDurum != null && !mevcutDurum.degistirilebilir) {
        AppLogger.warning('⚠️ Yemek zaten onaylanmış, değiştirilemiyor: $yemekId');
        return false;
      }
      
      // Yedi olarak işaretle
      final yeniDurum = (mevcutDurum ?? YemekOnayVerisi(
        yemekId: yemekId,
        tarih: tarih,
        durum: YemekDurumu.bekliyor,
        degistirilebilir: true,
      )).yediOlarakIsaretle(notlar: notlar);
      
      return await yemekDurumunuGuncelle(
        yemekId: yemekId,
        tarih: tarih,
        yeniDurum: yeniDurum,
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek yedi işaretleme hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Yemeği onayla (artık değiştirilemesin)
  static Future<bool> yemekOnayla({
    required String yemekId,
    required DateTime tarih,
    String? notlar,
  }) async {
    try {
      // Mevcut durumu al
      final mevcutDurum = await _yemekDurumuGetir(yemekId, tarih);
      
      if (mevcutDurum == null) {
        AppLogger.warning('⚠️ Yemek durumu bulunamadı: $yemekId');
        return false;
      }
      
      // Zaten onaylanmış mı?
      if (mevcutDurum.onaylanmisMi) {
        AppLogger.info('ℹ️ Yemek zaten onaylanmış: $yemekId');
        return true;
      }
      
      // Onayla
      final yeniDurum = mevcutDurum.onayla(notlar: notlar);
      
      return await yemekDurumunuGuncelle(
        yemekId: yemekId,
        tarih: tarih,
        yeniDurum: yeniDurum,
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek onaylama hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Yemeği atla
  static Future<bool> yemekAtla({
    required String yemekId,
    required DateTime tarih,
    String? notlar,
  }) async {
    try {
      // Mevcut durumu al
      final mevcutDurum = await _yemekDurumuGetir(yemekId, tarih);
      
      // Değiştirilebilir mi kontrol et
      if (mevcutDurum != null && !mevcutDurum.degistirilebilir) {
        AppLogger.warning('⚠️ Yemek zaten onaylanmış, değiştirilemiyor: $yemekId');
        return false;
      }
      
      // Atla
      final yeniDurum = (mevcutDurum ?? YemekOnayVerisi(
        yemekId: yemekId,
        tarih: tarih,
        durum: YemekDurumu.bekliyor,
        degistirilebilir: true,
      )).atla(notlar: notlar);
      
      return await yemekDurumunuGuncelle(
        yemekId: yemekId,
        tarih: tarih,
        yeniDurum: yeniDurum,
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek atlama hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Yemek durumunu sıfırla
  static Future<bool> yemekDurumunuSifirla({
    required String yemekId,
    required DateTime tarih,
  }) async {
    try {
      // Mevcut durumu al
      final mevcutDurum = await _yemekDurumuGetir(yemekId, tarih);
      
      // Değiştirilebilir mi kontrol et
      if (mevcutDurum != null && !mevcutDurum.degistirilebilir) {
        AppLogger.warning('⚠️ Yemek zaten onaylanmış, sıfırlanamıyor: $yemekId');
        return false;
      }
      
      // Sıfırla
      final yeniDurum = (mevcutDurum ?? YemekOnayVerisi(
        yemekId: yemekId,
        tarih: tarih,
        durum: YemekDurumu.bekliyor,
        degistirilebilir: true,
      )).sifirla();
      
      return await yemekDurumunuGuncelle(
        yemekId: yemekId,
        tarih: tarih,
        yeniDurum: yeniDurum,
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Yemek durumu sıfırlama hatası', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Haftalık uyum raporu oluştur
  static Future<Map<DateTime, GunlukOnayDurumu>> haftalikUyumRaporu({
    required DateTime baslangicTarihi,
  }) async {
    try {
      AppLogger.info('📊 Haftalık uyum raporu oluşturuluyor...');
      
      final rapor = <DateTime, GunlukOnayDurumu>{};
      
      for (int gun = 0; gun < 7; gun++) {
        final tarih = baslangicTarihi.add(Duration(days: gun));
        final gunlukDurum = await gunlukOnayDurumuGetir(tarih);
        rapor[tarih] = gunlukDurum;
      }
      
      AppLogger.success('✅ Haftalık uyum raporu oluşturuldu: ${rapor.length} gün');
      return rapor;
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Haftalık uyum raporu hatası', error: e, stackTrace: stackTrace);
      return {};
    }
  }
  
  /// Belirli bir yemeğin durumunu getir (private)
  static Future<YemekOnayVerisi?> _yemekDurumuGetir(String yemekId, DateTime tarih) async {
    final durumlar = await _onayDurumlariniGetir(tarih);
    return durumlar[yemekId];
  }
  
  /// Onay durumlarını Hive'dan getir (private)
  static Future<Map<String, YemekOnayVerisi>> _onayDurumlariniGetir(DateTime tarih) async {
    try {
      final box = await _onayBoxiniAc();
      final key = 'onay_${_tarihAnahtari(tarih)}';
      final data = box.get(key);
      
      if (data == null) return {};
      
      // Map<String, dynamic>'den Map<String, YemekOnayVerisi>'na dönüştür
      final durumlar = <String, YemekOnayVerisi>{};
      for (final entry in (data as Map).entries) {
        try {
          durumlar[entry.key] = _jsonToYemekOnayVerisi(entry.value);
        } catch (e) {
          AppLogger.warning('⚠️ Onay verisi parse hatası: ${entry.key} - $e');
        }
      }
      
      return durumlar;
      
    } catch (e) {
      AppLogger.error('❌ Onay durumları getirme hatası', error: e);
      return {};
    }
  }
  
  /// Onay durumlarını Hive'a kaydet (private)
  static Future<void> _onayDurumlariniKaydet(DateTime tarih, Map<String, YemekOnayVerisi> durumlar) async {
    try {
      final box = await _onayBoxiniAc();
      final key = 'onay_${_tarihAnahtari(tarih)}';
      
      // Map<String, YemekOnayVerisi>'nı Map<String, Map>'e dönüştür
      final dataMap = <String, Map<String, dynamic>>{};
      for (final entry in durumlar.entries) {
        dataMap[entry.key] = _yemekOnayVerisiToJson(entry.value);
      }
      
      await box.put(key, dataMap);
      
    } catch (e) {
      AppLogger.error('❌ Onay durumları kaydetme hatası', error: e);
    }
  }
  
  /// Eski sistem ile senkronize et (backward compatibility)
  static Future<void> _eskiSistemIleSync(DateTime tarih, Map<String, YemekOnayVerisi> onayDurumlari) async {
    try {
      // Eski sistem için boolean map oluştur
      final eskiMap = <String, bool>{};
      
      for (final entry in onayDurumlari.entries) {
        eskiMap[entry.key] = entry.value.yenmis;
      }
      
      // Eski sisteme kaydet
      await HiveService.tamamlananOgunleriKaydet(tarih, eskiMap);
      
    } catch (e) {
      AppLogger.error('❌ Eski sistem sync hatası', error: e);
    }
  }
  
  /// Onay box'ını aç (private)
  static Future<dynamic> _onayBoxiniAc() async {
    // HiveService içindeki favori box'ı kullan
    return await HiveService.init().then((_) => 
        // Favori box zaten açıldığından, onu kullan
        HiveService
    );
  }
  
  /// YemekOnayVerisi -> JSON (private)
  static Map<String, dynamic> _yemekOnayVerisiToJson(YemekOnayVerisi durum) {
    return {
      'yemekId': durum.yemekId,
      'tarih': durum.tarih.millisecondsSinceEpoch,
      'durum': durum.durum.name,
      'yemeTarihi': durum.yemeTarihi?.millisecondsSinceEpoch,
      'onayTarihi': durum.onayTarihi?.millisecondsSinceEpoch,
      'notlar': durum.notlar,
      'degistirilebilir': durum.degistirilebilir,
    };
  }
  
  /// JSON -> YemekOnayVerisi (private)
  static YemekOnayVerisi _jsonToYemekOnayVerisi(Map<String, dynamic> json) {
    return YemekOnayVerisi(
      yemekId: json['yemekId'] ?? '',
      tarih: DateTime.fromMillisecondsSinceEpoch(json['tarih'] ?? 0),
      durum: YemekDurumu.values.firstWhere(
        (d) => d.name == json['durum'],
        orElse: () => YemekDurumu.bekliyor,
      ),
      yemeTarihi: json['yemeTarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['yemeTarihi'])
          : null,
      onayTarihi: json['onayTarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['onayTarihi'])
          : null,
      notlar: json['notlar'],
      degistirilebilir: json['degistirilebilir'] ?? true,
    );
  }
  
  /// Tarih anahtarı oluştur (private)
  static String _tarihAnahtari(DateTime tarih) {
    return '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';
  }
  
  /// Tarih string'i (private)
  static String _tarihString(DateTime tarih) {
    return '${tarih.day}.${tarih.month}.${tarih.year}';
  }
  
  /// Tüm onay verilerini temizle (debug/test amaçlı)
  static Future<void> tumOnayVerileriniTemizle() async {
    try {
      // Bu implementasyon daha sonra eklenebilir
      AppLogger.info('🗑️ Onay verileri temizleme fonksiyonu henüz implement edilmedi');
    } catch (e) {
      AppLogger.error('❌ Onay verileri temizleme hatası', error: e);
    }
  }
  
  /// Haftalık özet istatistikler
  static Future<Map<String, dynamic>> haftalikOzetIstatistikler({
    required DateTime baslangicTarihi,
  }) async {
    try {
      final rapor = await haftalikUyumRaporu(baslangicTarihi: baslangicTarihi);
      
      double toplamUyum = 0;
      int toplamOnaylanan = 0;
      int toplamYemek = 0;
      int toplamAtlanan = 0;
      
      for (final gunlukDurum in rapor.values) {
        toplamUyum += gunlukDurum.uyumYuzdesi;
        toplamOnaylanan += gunlukDurum.onaylananSayisi;
        toplamYemek += gunlukDurum.toplamYemekSayisi;
        toplamAtlanan += gunlukDurum.atlananSayisi;
      }
      
      final ortalama = rapor.isNotEmpty ? toplamUyum / rapor.length : 0.0;
      
      return {
        'ortalamaUyum': ortalama,
        'toplamOnaylanan': toplamOnaylanan,
        'toplamYemek': toplamYemek,
        'toplamAtlanan': toplamAtlanan,
        'gunSayisi': rapor.length,
        'basariOrani': toplamYemek > 0 ? (toplamOnaylanan / toplamYemek) * 100 : 0.0,
      };
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ Haftalık özet istatistikler hatası', error: e, stackTrace: stackTrace);
      return {};
    }
  }
}