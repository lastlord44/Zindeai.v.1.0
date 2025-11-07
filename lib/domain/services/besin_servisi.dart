import '../../data/local/hive_service.dart';
import '../entities/besin_malzeme.dart';
import '../entities/yemek.dart';

class BesinServisi {
  Future<BesinMalzeme?> getBesinDegerleri(String besinAdi) async {
    // Hive'dan besin verilerini dinamik olarak çek
    final sonuclar = await HiveService.yemekAra(besinAdi);
    if (sonuclar.isNotEmpty) {
      final ilkYemek = sonuclar.first;
      // Burada Yemek entity'sini BesinMalzeme'ye dönüştürmemiz gerekiyor.
      // Şimdilik varsayımsal bir dönüşüm yapıyorum.
      // Eğer BesinMalzeme'nin tüm alanları Yemek'te yoksa, varsayılan değerler kullanılabilir.
      return BesinMalzeme(
        id: ilkYemek.id,
        ad: ilkYemek.ad,
        kalori100g: ilkYemek.kalori,
        protein100g: ilkYemek.protein,
        karbonhidrat100g: ilkYemek.karbonhidrat,
        yag100g: ilkYemek.yag,
        kategori: BesinKategorisi.protein, // Varsayılan veya çıkarım yapılmalı
        uygunOgunler: [ilkYemek.ogun],
        fiyat100g: 0, // Varsayılan
        ekonomik: false, // Varsayılan
      );
    }
    return null; // Bulunamazsa null döner
  }
}
