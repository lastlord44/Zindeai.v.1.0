# 🤖 AI ENTEGRASYON PLANI - ZİNDE AI BESLENME UYGULAMASI

## 🎯 STRATEJİK KARAR
DB migration sorunları nedeniyle **YAPAY ZEKA TABanLI SİSTEME** geçiş kararı alındı.

## 📋 MEVCUT DURUM
- ✅ Tolerans sistemi çalışıyor (%15 kalori, %10 protein/karb/yağ)
- ✅ UI bileşenleri hazır
- ❌ DB migration karmaşık ve sorunlu
- ❌ Plan oluştur butonu tepki vermiyor

## 🚀 YENİ MİMARİ: AI TABanLI SİSTEM

### **1. TOLERANS SİSTEMİ KORUNUR** ✅
```dart
// Bu kodlar KORUNACAK - çalışıyor!
GunlukPlan.kaloriToleransYuzdesi = 15.0  // %15
GunlukPlan.proteinToleransYuzdesi = 10.0 // %10
GunlukPlan.karbonhidratToleransYuzdesi = 10.0 // %10
GunlukPlan.yagToleransYuzdesi = 10.0 // %10
```

### **2. DB SİSTEMİ PASİF** ❌
- JSON migration devre dışı
- Hive veritabanı kullanılmayacak
- Önceden hazırlanan yemek verileri manuel entegre edilecek

### **3. AI SERVİSİ DEVREYE GİRECEK** 🤖

#### **A. AI BESLENme Servisi**
```dart
class AIBeslenmeServisi {
  // AI'dan beslenme planı al
  Future<GunlukPlan> gunlukPlanOlustur({
    required double hedefKalori,
    required double hedefProtein,
    required double hedefKarb,
    required double hedefYag,
    List<String> kisitlamalar = const [],
    DateTime? tarih,
  });
  
  // AI'dan antrenman planı al
  Future<AntrenmanPlani> antrenmanPlaniOlustur({
    required String hedefTipi,
    required int haftalikSeans,
    required String deneyimSeviyesi,
  });
}
```

#### **B. PROMPT TEMPLATE**
```
Sen profesyonel diyetisyen ve fitness uzmanısın.

Hedefler:
- Kalori: {hedef_kalori} kcal
- Protein: {hedef_protein}g  
- Karbonhidrat: {hedef_karb}g
- Yağ: {hedef_yag}g

Tolerans: Kalori ±15%, diğerleri ±10%

JSON formatında günlük plan oluştur:
{
  "kahvalti": {"ad": "...", "kalori": 0, "protein": 0, "karbonhidrat": 0, "yag": 0, "malzemeler": []},
  "araOgun1": {...},
  "ogleYemegi": {...},
  "araOgun2": {...}, 
  "aksamYemegi": {...}
}

Kurallar:
- Balık/et ASLA kahvaltıda olmasın!
- Türk mutfağı odaklı
- Gerçekçi porsiyonlar
- Tolerans aşılmasın
```

## 🔧 TEKNİK ENTEGRASYON ADIMLAR

### **ADIM 1: AI Servisi Oluştur**
```dart
// lib/domain/services/ai_beslenme_servisi.dart
class AIBeslenmeServisi {
  static const String API_KEY = 'your-openai-key';
  static const String BASE_URL = 'https://api.openai.com/v1/chat/completions';
  
  Future<GunlukPlan> planOlustur(Map<String, dynamic> hedefler) async {
    // AI API çağrısı
    // JSON response parse et
    // GunlukPlan nesnesine çevir
    // Tolerans kontrol et
    return gunlukPlan;
  }
}
```

### **ADIM 2: Mevcut OgunPlanlayici'yı Değiştir**
```dart
// lib/domain/usecases/ogun_planlayici.dart
class OgunPlanlayici {
  final AIBeslenmeServisi _aiServisi = AIBeslenmeServisi();
  
  Future<GunlukPlan> gunlukPlanOlustur(...) async {
    // DB yerine AI'dan plan al
    return await _aiServisi.planOlustur(hedefler);
  }
}
```

### **ADIM 3: UI Güncellemesi**
- Plan oluştur butonu AI çağrısı yapacak
- Loading indicator ekle
- Hata durumları handle et

### **ADIM 4: Antrenman Entegrasyonu**
```dart
class AntrenmanPlaniServisi {
  Future<List<Egzersiz>> haftalikPlan(...) async {
    // AI'dan antrenman programı al
  }
}
```

## 📊 AVANTAJLAR

✅ **DB Migration Sorunu Yok**: JSON/Hive karmaşası biter
✅ **Güncel İçerik**: AI sürekli güncel yemekler önerir  
✅ **Kişiselleştirme**: Her kullanıcıya özel planlar
✅ **Esnek Sistem**: Yeni özellikler kolay eklenir
✅ **Tolerans Korunur**: Mevcut tolerans sistemi çalışmaya devam eder

## 🎯 SONUÇ

DB tabanlı sistemden **AI tabanlı sisteme** geçiş:
1. **Tolerans sistemi korunur** (çalışıyor)
2. **DB migration pasife alınır** (sorunlu)  
3. **AI servis devreye girer** (esnek + güncel)
4. **Kullanıcı deneyimi iyileşir** (hızlı + akıllı)

**SONRAKİ ADIM**: OpenAI/Claude API entegrasyonu başlat!