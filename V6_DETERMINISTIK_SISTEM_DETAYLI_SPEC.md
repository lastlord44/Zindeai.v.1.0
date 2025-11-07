# 🚨 ZİNDE AI V6.0 DETERMİNİSTİK SİSTEM SPECİFİKASYONU

## 📊 MEVCUT DURUM ANALİZİ - KRİTİK SORUNLAR

### 🔴 PROBLEM 1: LLM MAKRO HESAPLAMA FELAKETI
**Gözlemlenen Durumlar:**
```
❌ Zayıf Erkek (62kg, 190cm): Protein %95.4 AŞIM (Hedef: 112g → LLM Üretimi: 180g)
❌ Mega Bulk (85kg, 195cm): Protein %60.9 AŞIM (Hedef: 153g → LLM Üretimi: 218g)  
❌ İnce Kız (45kg, 168cm): Protein %62.0 AŞIM (Hedef: 81g → LLM Üretimi: 131g)
```

**Kök Sebep:** LLM hesap yapmaya çalışıyor, **hallüsinasyon** üretiyor!

### 🔴 PROBLEM 2: ARA ÖĞÜN MADNESİ
**Gözlemlenen Durumlar:**
- Ara öğünlerde **protein patlaması** (günlük hedefin %40'ı tek ara öğünde)
- Karbonhidrat **drastik eksikliği** (%16-38 arası sapma)
- Makro **dağılım** tamamen bozuk (breakfast: 150g protein, dinner: 20g protein gibi)

**Kök Sebep:** LLM meal planning'de **makro dengeleme** yapamıyor!

### 🔴 PROBLEM 3: YÜKSEK KALORİ PROFİL ÇÖKÜŞÜ (3000+ kcal)
**Gözlemlenen Durumlar:**
```
❌ Power Lifter: 4146 kcal oluşturdu (%33.9 protein aşım) 
❌ Strong Woman: 3232 kcal oluşturdu (%38.2 protein aşım)
❌ Çok Zayıf: 3587 kcal oluşturdu (%95.4 protein aşım)
```

**Kök Sebep:** Yüksek kalori = LLM **kontrolü tamamen kaybediyor**!

### 🔴 PROBLEM 4: DB STANDARDIZASYON KABUSU
**Gözlemlenen Durumlar:**
- **Pişmiş/çiğ** karışık (100g çiğ pirinç vs 100g pişmiş pirinç)
- **Porsiyon belirsizliği** (1 adet vs 100g vs 1 kase)
- **Lif/doymuş yağ** verileri eksik
- **Unit conversion** hataları

### 🔴 PROBLEM 5: TOLERANS KONTROLSÜZLÜĞÜ
**Diyetisyen Standardı:** ±15% kalori, ±20% protein
**Gerçek Durum:** %20-95 arası aşımlar **normal** kabul ediliyor!

---

## 🎯 MEVCUT ARCHİTECTURE ANALİZİ

### 📱 FLUTTER APP STRUCTURE
```
lib/
├── domain/entities/
│   ├── kullanici_profili.dart    # KullaniciProfili(boy: double, kilo: double, yas: int)
│   ├── hedef.dart               # enum Hedef {kiloVermek, kiloAlmak, kasKazanKiloAl...}
│   └── gunluk_plan.dart         # GunlukPlan(toplamKalori, toplamProtein...)
├── domain/services/
│   └── ai_beslenme_servisi.dart # MEVCUt V5.3 - SORUNLU!
├── data/models/
│   └── yemek_hive_model.dart    # YemekHiveModel(mealId, calorie, proteinG...)
└── data/local/
    └── hive_service.dart        # 6565 yemek veritabanı
```

### 🤖 MEVCUT AI SERVİS PROBLEMLERİ
**ai_beslenme_servisi.dart V5.3 Issues:**
1. **LLM'e hesap yaptırıyor** → Güvenilmez sonuçlar
2. **Doğrulama katmanı yok** → Sapmalar kontrolsüz
3. **Adjustment mekanizması yok** → Hatalı çıktı = başarısız plan
4. **DB değerleri override** → LLM kendi makrolarını uyduruyor
5. **Tolerance belirsiz** → Model hedef bilmiyor

---

## 🚀 İSTENEN V6.0 DETERMİNİSTİK ARCHİTECTURE

### 1️⃣ DETERMINISTIK MAKRO VALIDATOR
**Lokasyon:** `lib/core/validators/macro_validator.dart`

**Fonksiyonalite:**
```dart
// BMR Hesaplayıcı (Mifflin-St Jeor Formula)
double calculateBMR({required double weightKg, required double heightCm, 
                     required int age, required Gender gender});

// TDEE Hesaplayıcı  
double calculateTDEE({required double bmr, required ActivityLevel activity});

// Makro Hedef Hesaplayıcı
MacroTargets calculateMacroTargets({required double tdee, required Goal goal, 
                                   required double weightKg});

// Tolerans Kontrolü
bool withinTolerance({required MacroSummary actual, required MacroTargets target,
                     double calorieTolerancePct = 0.05, double proteinTolerancePct = 0.15});
```

**Türk Fitness Standartları:**
- **Protein:** 1.6-2.2 g/kg (bulk: 1.8-2.0 g/kg)
- **Yağ:** 0.8-1.0 g/kg veya %25-30 kalori
- **Karbonhidrat:** Kalan kalori
- **Lif:** ≥30g/gün
- **Tolerans:** ±5% kalori, ±15% protein

### 2️⃣ AUTO-CORRECTION ALGORITMASI  
**Lokasyon:** `lib/core/services/macro_adjuster.dart`

**Düzeltme Sırası (Priority Queue):**
1. **Karbonhidrat Sapması** → Pirinç/bulgur/yulaf gramını ayarla
2. **Yağ Sapması** → Zeytinyağı/fındık/avokado gramını ayarla  
3. **Protein Sapması** → Tavuk/balık/yumurta/whey gramını ayarla

**Algoritma:**
```dart
class MacroAdjuster {
  // 3 iterasyon deneme sistemi
  Future<MealPlan> adjustToTargets(MealPlan plan, MacroTargets targets) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      final current = calculateMacros(plan);
      if (withinTolerance(current, targets)) return plan;
      
      plan = adjustCarbs(plan, targets, current);
      plan = adjustFats(plan, targets, current);
      plan = adjustProteins(plan, targets, current);
    }
    throw MacroAdjustmentException();
  }
}
```

### 3️⃣ STANDARDIZE DB MANAGER
**Lokasyon:** `lib/core/services/db_standardizer.dart`

**DB Standardı:** 
- **Tek Standart:** 100g pişmiş bazlı
- **Required Fields:** kalori, protein, karbonhidrat, yağ, lif, doymuş_yağ
- **Türk Yemekleri:** İmam Bayıldı, Kıymalı Patlıcan, Bulgur Pilavı, vb.
- **Unit Conversion:** ml→g, adet→g conversion tabloları

```dart
class DbStandardizer {
  // Pişmiş/çiğ normalize et
  YemekModel standardizeToCooked(YemekModel raw);
  
  // Lif/doymuş yağ ekle
  YemekModel addMissingNutrients(YemekModel base);
  
  // Unit conversion
  double convertToGrams(String unit, double amount, String foodId);
}
```

### 4️⃣ JSON-ONLY LLM PROMPTING
**Lokasyon:** `lib/domain/services/ai_beslenme_servisi_v6.dart`

**System Prompt (Sıkı Kısıtlar):**
```
SEN BİR BESLENME MOTORU'SUN. HESAP YAPMA. Sadece verilen DB'den JSON üret.

KİSİTLAMALAR:
- Sadece DB'deki food_id'ları kullan
- Sadece gram cinsinden porsiyon ver
- Makro hesaplama YOK - ben yapacağım
- Türk mutfağı odaklı seçim yap
- Her ana öğünde ≥0.3g/kg protein

ÇIKTI FORMATI (sadece JSON):
{
  "meals": [
    {"name": "Kahvaltı", "items": [{"food_id": "yulaf_pis", "grams": 90}]},
    {"name": "Öğle", "items": [{"food_id": "tavuk_gogus_pis", "grams": 130}]}
  ]
}
```

**Input Schema:**
```dart
class LLMInput {
  final UserProfile profile;
  final MacroTargets targets;  
  final List<FoodItem> availableFoods;
  final MealConstraints constraints;
}
```

### 5️⃣ COMPREHENSIVE TEST SUITE
**Lokasyon:** `test/v6_deterministik_test.dart`

**Test Kategorileri:**
```dart
// Unit Tests
testMacroCalculations();        // BMR, TDEE, makro hesapları
testToleranceValidation();      // ±5% kalori, ±15% protein
testAutoAdjustment();          // Düzeltme algoritması

// Integration Tests  
testFullPipeline();            // Profil → JSON → Validate → Adjust
testTurkishCuisineCompliance(); // Türk mutfağı uygunluk
testHighCalorieProfiles();     // 3000+ kcal profiller

// Regression Tests
testProteinDeviation();        // Protein sapma kontrolü
testMealBalance();            // Öğün arası denge
testDatabaseConsistency();    // DB standardizasyon
```

---

## 📊 BAŞARI HEDEFLERİ & METRİKLER

### 🎯 PERFORMANCE TARGETS
- **Mevcut:** %31.5 başarı (50 profil test)
- **Hedef:** **%85+ başarı** (diyetisyen standardı)
- **Kritik Metrikler:**
  - Protein sapması: **<%20** (şu an %95'e kadar çıkıyor)
  - Kalori toleransı: **±5%** (şu an ±10% bile tutmuyor)
  - Yüksek kalori profil başarısı: **>%70** (şu an %0)

### ⚡ SYSTEM REQUIREMENTS
- **Performans:** <2sn plan oluşturma
- **Güvenilirlik:** %99.9 uptime
- **Tutarlılık:** Aynı profil → aynı makro hedefler
- **Çeşitlilik:** 7 günde maksimum 2 tekrar yemek

---

## 🔥 IMPLEMENTATION PRIORITY

### PHASE 1: FOUNDATION (Week 1)
1. **MacroValidator** → Deterministik hesaplamalar
2. **DbStandardizer** → 6565 yemeği standardize et
3. **Unit tests** → Hesap doğruluğunu garanti et

### PHASE 2: CORE SYSTEM (Week 2) 
4. **MacroAdjuster** → Otomatik düzeltme sistemi
5. **AIBeslenmeServisiV6** → JSON-only LLM integration
6. **Integration tests** → Full pipeline test

### PHASE 3: OPTIMIZATION (Week 3)
7. **Performance tuning** → <2sn response time
8. **Regression tests** → 50+ profil comprehensive test
9. **Production deployment** → %85+ başarı hedefi

---

## 🚨 KRİTİK BAŞARI FAKTÖRLERİ

1. **LLM'den hesap alma** - Sadece menü çeşitlendirme yaptır
2. **Tüm hesapları kendi kodunda yap** - Deterministik olmalı
3. **Her çıktıyı validate et** - Tolerans dışı = red flag
4. **Otomatik düzeltme** - Manuel müdahale gerektirmesin
5. **Kapsamlı test** - Edge case'leri yakala

Bu sistem ile **professional dietitian standard** tutturup **%85+ başarı** hedefine ulaşacağız!