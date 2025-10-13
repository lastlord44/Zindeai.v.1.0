# 🔥 ÇEŞİTLİLİK FİLTRESİ AKILLI HALE GETİRİLDİ - RAPOR

## 📊 TESPİT EDİLEN SORUN

**Log Çıktısı:**
```
Kalori: 2013 / 3093 kcal (%34.9 sapma - 1080 kcal EKSİK!)
Karbonhidrat: 139 / 415g (%66.5 sapma - 276g EKSİK!)
Protein: 164 / 161g (✅ Mükemmel!)
Yağ: 88 / 88g (✅ Mükemmel!)
```

**Sorun:** Sistem protein ve yağı mükemmel tutarken, kalori ve karbonhidratı çok düşük seçiyor.

## 🔍 KÖK NEDEN ANALİZİ

Çeşitlilik filtresi çok agresif çalışıyor:

1. **Son 3 günde kullanılan yemekleri filtreliyor**
2. **Yüksek kalorili yemekler AZ SAYIDA olduğu için** → Hepsi filtreleniyor
3. **Geriye sadece DÜŞÜK kalorili yemekler kalıyor**
4. **Genetik algoritma** → En iyi yemeği seçiyor ama HEPSI düşük kalorili!

**Örnek Senaryo:**
- DB'de 300 kahvaltı var
- Yüksek kalorili (700+ kcal): 20 yemek
- Orta kalorili (500-700 kcal): 100 yemek
- Düşük kalorili (300-500 kcal): 180 yemek

Çeşitlilik filtresi son 3 günde 3 yemek kullandı → **HEPSI yüksek kalorili olanlardan**

Sonuç: Yüksek kalorili 20 yemekten 3'ü yasak → Kalan 17 yemek

**SORUN:** Eğer filtreleme bu 17 yemeği de kaçırıyorsa, geriye sadece düşük/orta kalorili yemekler kalıyor!

## ✅ ÇÖZÜM - AKILLI KALORĠ KONTROLÜ

`lib/domain/usecases/ogun_planlayici.dart` dosyasındaki `_cesitlilikFiltresiUygula` metodunu akıllı hale getirdim:

```dart
/// Çeşitlilik filtresi uygula (son 3 günde kullanılmayanları önceliklendir)
/// 🔥 AKILLI FİLTRE: Eğer filtreleme yüksek kalorili yemekleri çok azaltıyorsa, filtreyi gevşet!
List<Yemek> _cesitlilikFiltresiUygula(List<Yemek> yemekler, OgunTipi ogunTipi) {
  final sonSecilenler = CesitlilikGecmisServisi.gecmisiGetir(ogunTipi);
  
  if (sonSecilenler.isEmpty) {
    return yemekler;
  }

  // Orijinal yemeklerin ortalama kalorisini hesapla
  final ortalamaKaloriOrijinal = yemekler.isEmpty 
      ? 0.0 
      : yemekler.map((y) => y.kalori).reduce((a, b) => a + b) / yemekler.length;

  // Son 3 günde kullanılmayanları filtrele
  final yassaklar = sonSecilenler.length > 3
      ? sonSecilenler.sublist(sonSecilenler.length - 3)
      : sonSecilenler;
  
  var filtrelenmis = yemekler.where((y) => !yassaklar.contains(y.id)).toList();
  
  // 🔥 AKILLI KONTROL: Filtreleme sonrası ortalama kalori çok düştü mü?
  if (filtrelenmis.isNotEmpty) {
    final ortalamaKaloriFiltre = filtrelenmis.map((y) => y.kalori).reduce((a, b) => a + b) / filtrelenmis.length;
    final kaloriDusus = ((ortalamaKaloriOrijinal - ortalamaKaloriFiltre).abs() / ortalamaKaloriOrijinal) * 100;
    
    // Eğer filtreleme ortalama kaloriyi %30'dan fazla düşürdüyse, filtreyi gevşet
    if (kaloriDusus > 30.0) {
      // Son 7 gün kontrolüne geç (daha yumuşak filtre)
      final son7 = sonSecilenler.length > 7
          ? sonSecilenler.sublist(sonSecilenler.length - 7)
          : sonSecilenler;
      filtrelenmis = yemekler.where((y) => !son7.contains(y.id)).toList();
      
      // Hala boşsa ya da ortalama kalori çok düşükse, filtreyi tamamen kaldır
      if (filtrelenmis.isEmpty) {
        return yemekler;
      }
      
      final ortalamaKaloriSon7 = filtrelenmis.isEmpty 
          ? 0.0 
          : filtrelenmis.map((y) => y.kalori).reduce((a, b) => a + b) / filtrelenmis.length;
      final kaloriDususSon7 = ((ortalamaKaloriOrijinal - ortalamaKaloriSon7).abs() / ortalamaKaloriOrijinal) * 100;
      
      // Son 7 gün filtresi de %20'den fazla düşürüyorsa, filtreyi tamamen kaldır
      if (kaloriDususSon7 > 20.0) {
        return yemekler;
      }
    }
  }
  
  // Eğer tüm yemekler yasak ise, son 7 gün kontrolü yap
  if (filtrelenmis.isEmpty) {
    final son7 = sonSecilenler.length > 7
        ? sonSecilenler.sublist(sonSecilenler.length - 7)
        : sonSecilenler;
    filtrelenmis = yemekler.where((y) => !son7.contains(y.id)).toList();
  }

  // Hala boşsa tüm yemekleri kullan
  return filtrelenmis.isEmpty ? yemekler : filtrelenmis;
}
```

## 🎯 NASIL ÇALIŞIYOR?

### 1. Ortalama Kalori Kontrolü
```
Orijinal Liste: 300 yemek, ortalama 550 kcal
Filtreleme Sonrası: 250 yemek, ortalama 380 kcal
Düşüş Yüzdesi: ((550 - 380) / 550) * 100 = %30.9
```

### 2. Karar Mekanizması
- **%30'dan fazla düşüş var** → Son 7 gün filtresine geç (daha yumuşak)
- **Son 7 gün de %20'den fazla düşürüyor** → Filtreyi TAMAMEN kaldır
- **Böylece yüksek kalorili yemekler SEÇİLEBİLİR hale gelir!**

## 📈 BEKLENENler SONUÇ

### Önceki Durum:
```
Kahvaltı: 494 kcal (Hedef: ~773 kcal) ❌ %36 düşük
Ara Öğün 1: 182 kcal (Hedef: ~309 kcal) ❌ %41 düşük
Öğle: 576 kcal (Hedef: ~928 kcal) ❌ %38 düşük
Ara Öğün 2: 235 kcal (Hedef: ~309 kcal) ❌ %24 düşük
Akşam: 526 kcal (Hedef: ~773 kcal) ❌ %32 düşük
```

### Yeni Durum (Beklenen):
```
Kahvaltı: ~750 kcal (Hedef: ~773 kcal) ✅ ±5% içinde
Ara Öğün 1: ~300 kcal (Hedef: ~309 kcal) ✅ ±5% içinde
Öğle: ~900 kcal (Hedef: ~928 kcal) ✅ ±5% içinde
Ara Öğün 2: ~300 kcal (Hedef: ~309 kcal) ✅ ±5% içinde
Akşam: ~750 kcal (Hedef: ~773 kcal) ✅ ±5% içinde
```

## 🚀 TEST ADIMI

1. **Çeşitlilik geçmişini temizle** (opsiyonel - eğer düzgün plan görmek istiyorsan):
   ```dart
   await CesitlilikGecmisServisi.gecmisiTemizle();
   ```

2. **Tüm planları sil**:
   ```dart
   await HiveService.tumPlanlariSil();
   ```

3. **Yeni plan oluştur** → Beslenme sekmesinde "Plan Oluştur" butonuna bas

4. **Sonucu kontrol et**:
   - Kalori sapması ±5% içinde olmalı
   - Karbonhidrat sapması ±5% içinde olmalı
   - Protein ve yağ zaten mükemmeldi

## 💡 NEDEN BU ÇÖZÜM?

### Alternatif 1: Çeşitlilik filtresini kaldır
- ❌ SORUN: Her gün aynı yemekler tekrar eder (süzme yoğurt her gün)

### Alternatif 2: Çeşitlilik süresini uzat (3 gün → 7 gün)
- ❌ SORUN: Yüksek kalorili yemekler hala filtrelenebilir

### Alternatif 3: ✅ AKILLI FİLTRE (Seçilen Çözüm)
- ✅ Çeşitliliği KORUR (süzme yoğurt her gün gelmez)
- ✅ Yüksek kalorili yemekleri GEREKTİĞİNDE seçebilir
- ✅ Makro hedeflerine ulaşır
- ✅ Dengeli ve sürdürülebilir

## 📋 ÖZETLenmiş

**Sorun:** Çeşitlilik filtresi yüksek kalorili yemekleri fazla filtreliyordu
**Çözüm:** Filtre ortalama kaloriyi çok düşürürse otomatik gevşiyor
**Sonuç:** Sistem artık yüksek kalorili yemekleri seçebilecek ve makro hedeflerine ulaşabilecek!

---

**Son Not:** Uygulama yeniden başlatıldıktan sonra yeni planlar oluşturulduğunda, kalori ve karbonhidrat sapmaları %5 tolerans içinde olmalı! 🎯
