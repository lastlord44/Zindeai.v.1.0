// ============================================================================
// lib/domain/entities/su_onerisi.dart
// SU ÖNERİSİ VERİ MODELİ
// ============================================================================

class SuOnerisi {
  final double gunlukIhtiyac;      // Toplam günlük su ihtiyacı (litre)
  final double temelIhtiyac;       // Temel su ihtiyacı (35ml/kg)
  final double aktiviteEk;         // Aktivite seviyesine göre ek
  final double makroEk;            // Makrolara göre ek ihtiyaç
  final double hedefEk;            // Hedefe göre ek ihtiyaç
  final Map<int, double> saatlikDagitim; // Saatlik su dağılımı
  final String aciklama;           // Su ihtiyacının açıklaması
  final List<String> tavsiyeler;   // Su içme tavsiyeleri
  final DateTime hesaplamaTarihi;  // Hesaplanma tarihi
  
  const SuOnerisi({
    required this.gunlukIhtiyac,
    required this.temelIhtiyac,
    required this.aktiviteEk,
    required this.makroEk,
    required this.hedefEk,
    required this.saatlikDagitim,
    required this.aciklama,
    required this.tavsiyeler,
    required this.hesaplamaTarihi,
  });
  
  /// Bardak sayısı (1 bardak = 250ml)
  int get bardakSayisi => (gunlukIhtiyac * 4).round();
  
  /// Su ihtiyacının yüzdesel dağılımı
  Map<String, double> get yuzdeselDagitim => {
    'Temel İhtiyaç': (temelIhtiyac / gunlukIhtiyac) * 100,
    'Aktivite': (aktiviteEk / gunlukIhtiyac) * 100,
    'Makro': (makroEk / gunlukIhtiyac) * 100,
    'Hedef': (hedefEk / gunlukIhtiyac) * 100,
  };
  
  /// En yoğun su içme saati
  int get enYogunSaat {
    double maxMiktar = 0.0;
    int maxSaat = 7;
    
    saatlikDagitim.forEach((saat, miktar) {
      if (miktar > maxMiktar) {
        maxMiktar = miktar;
        maxSaat = saat;
      }
    });
    
    return maxSaat;
  }
  
  /// Su kategorisi (düşük, normal, yüksek)
  String get kategori {
    if (gunlukIhtiyac < 2.0) return 'Düşük';
    if (gunlukIhtiyac < 3.0) return 'Normal';
    if (gunlukIhtiyac < 3.5) return 'Yüksek';
    return 'Çok Yüksek';
  }
  
  /// Günlük su hedefi renk kodu
  String get renkKodu {
    if (gunlukIhtiyac < 2.0) return '#FF9800'; // Turuncu - dikkat
    if (gunlukIhtiyac < 3.0) return '#4CAF50'; // Yeşil - normal
    if (gunlukIhtiyac < 3.5) return '#2196F3'; // Mavi - aktif
    return '#9C27B0'; // Mor - yüksek performans
  }
  
  @override
  String toString() {
    return 'SuOnerisi(günlük: ${gunlukIhtiyac.toStringAsFixed(1)}L, bardak: $bardakSayisi, kategori: $kategori)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuOnerisi &&
          runtimeType == other.runtimeType &&
          gunlukIhtiyac == other.gunlukIhtiyac &&
          hesaplamaTarihi == other.hesaplamaTarihi;

  @override
  int get hashCode => gunlukIhtiyac.hashCode ^ hesaplamaTarihi.hashCode;
}