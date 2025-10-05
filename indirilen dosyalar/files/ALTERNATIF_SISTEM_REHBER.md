# 🔄 ALTERNATİF BESİN SİSTEMİ - KULLANIM REHBERİ

## 📋 ÖZELLİK

Kullanıcının alerjisi/kısıtlaması olan veya bulamadığı besinler için **otomatik alternatif önerisi** sistemi.

### Örnekler:
```
❌ 10 Badem (Ceviz alerjiniz var)
   ↓
🔄 Alternatifler:
   ✅ 13 Fındık (Benzer yağ profili) - 180 kcal
   ✅ 6 Ceviz (Yüksek Omega-3) - 185 kcal
   ✅ 15 Antep Fıstığı (Daha yüksek protein) - 160 kcal
```

---

## 📦 JSON YAPISI

### Örnek 1: Kuruyemiş ile Ara Öğün

```json
{
  "id": "ara_ogun_1_001",
  "ad": "10 Badem + 1 Elma",
  "kategori": "ara_ogun_1",
  "hazirlamaSuresi": 0,
  "zorluk": "kolay",
  "besinler": [
    {
      "ad": "Badem",
      "miktar": 10,
      "birim": "adet",
      "alternatifler": [
        {
          "ad": "Fındık",
          "miktar": 13,
          "birim": "adet",
          "kalori": 180,
          "protein": 4.2,
          "karbonhidrat": 5.0,
          "yag": 17.0,
          "neden": "Benzer yağ ve protein profili"
        },
        {
          "ad": "Ceviz",
          "miktar": 6,
          "birim": "adet",
          "kalori": 185,
          "protein": 4.3,
          "karbonhidrat": 3.9,
          "yag": 18.5,
          "neden": "Yüksek Omega-3 içeriği"
        },
        {
          "ad": "Antep Fıstığı",
          "miktar": 15,
          "birim": "adet",
          "kalori": 160,
          "protein": 6.0,
          "karbonhidrat": 8.0,
          "yag": 13.0,
          "neden": "Daha yüksek protein"
        },
        {
          "ad": "Kaju",
          "miktar": 12,
          "birim": "adet",
          "kalori": 155,
          "protein": 5.2,
          "karbonhidrat": 9.0,
          "yag": 12.0,
          "neden": "Daha yumuşak tat"
        }
      ]
    },
    {
      "ad": "Elma",
      "miktar": 1,
      "birim": "adet",
      "alternatifler": [
        {
          "ad": "Armut",
          "miktar": 1,
          "birim": "adet",
          "kalori": 57,
          "protein": 0.4,
          "karbonhidrat": 15.0,
          "yag": 0.1,
          "neden": "Benzer lif içeriği"
        },
        {
          "ad": "Portakal",
          "miktar": 1,
          "birim": "adet",
          "kalori": 47,
          "protein": 0.9,
          "karbonhidrat": 12.0,
          "yag": 0.1,
          "neden": "Yüksek C vitamini"
        },
        {
          "ad": "Mandalina",
          "miktar": 2,
          "birim": "adet",
          "kalori": 47,
          "protein": 0.8,
          "karbonhidrat": 12.0,
          "yag": 0.3,
          "neden": "Portatif ve pratik"
        }
      ]
    }
  ],
  "toplamKalori": 230,
  "toplamProtein": 6.0,
  "toplamKarbonhidrat": 21.0,
  "toplamYag": 15.0
}
```

### Örnek 2: Protein Bar Alternatifi

```json
{
  "id": "ara_ogun_2_015",
  "ad": "Protein Bar",
  "kategori": "ara_ogun_2",
  "besinler": [
    {
      "ad": "Protein Bar",
      "miktar": 1,
      "birim": "adet",
      "alternatifler": [
        {
          "ad": "Ev Yapımı Enerji Topu",
          "miktar": 2,
          "birim": "adet",
          "kalori": 200,
          "protein": 8.0,
          "karbonhidrat": 22.0,
          "yag": 9.0,
          "neden": "Doğal ve katkısız"
        },
        {
          "ad": "Yulaflı Protein Kurabiye",
          "miktar": 2,
          "birim": "adet",
          "kalori": 190,
          "protein": 10.0,
          "karbonhidrat": 20.0,
          "yag": 7.0,
          "neden": "Ev yapımı alternatif"
        },
        {
          "ad": "10 Badem + 1 Muz",
          "miktar": 1,
          "birim": "porsiyon",
          "kalori": 205,
          "protein": 6.0,
          "karbonhidrat": 27.0,
          "yag": 15.0,
          "neden": "Doğal besinlerle"
        }
      ]
    }
  ]
}
```

### Örnek 3: Süt Ürünleri Alternatifi (Vegan için)

```json
{
  "id": "kahvalti_1_010",
  "ad": "Yoğurt + Granola",
  "besinler": [
    {
      "ad": "Yoğurt",
      "miktar": 200,
      "birim": "gram",
      "alternatifler": [
        {
          "ad": "Badem Yoğurdu (Vegan)",
          "miktar": 200,
          "birim": "gram",
          "kalori": 80,
          "protein": 1.5,
          "karbonhidrat": 7.0,
          "yag": 5.0,
          "neden": "Laktozsuz ve vegan"
        },
        {
          "ad": "Soya Yoğurdu",
          "miktar": 200,
          "birim": "gram",
          "kalori": 100,
          "protein": 6.0,
          "karbonhidrat": 12.0,
          "yag": 3.0,
          "neden": "Yüksek protein vegan alternatif"
        },
        {
          "ad": "Kefir",
          "miktar": 200,
          "birim": "ml",
          "kalori": 120,
          "protein": 6.6,
          "karbonhidrat": 9.0,
          "yag": 7.0,
          "neden": "Probiyotik açısından zengin"
        }
      ]
    }
  ]
}
```

---

## 🚀 KULLANIM

### 1. Model Ekle

```dart
// lib/data/models/meal.dart içine ekle:

class BesinIcerigi {
  final String ad;
  final double miktar;
  final String birim;
  final List<AlternatifBesin> alternatifler;

  const BesinIcerigi({
    required this.ad,
    required this.miktar,
    required this.birim,
    this.alternatifler = const [],
  });

  factory BesinIcerigi.fromJson(Map<String, dynamic> json) {
    final alternatiflerJson = json['alternatifler'] as List<dynamic>?;
    final alternatifler = alternatiflerJson
        ?.map((a) => AlternatifBesin.fromJson(a as Map<String, dynamic>))
        .toList() ?? [];

    return BesinIcerigi(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      alternatifler: alternatifler,
    );
  }
}

class AlternatifBesin {
  final String ad;
  final double miktar;
  final String birim;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final String neden;

  const AlternatifBesin({
    required this.ad,
    required this.miktar,
    required this.birim,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.neden,
  });

  factory AlternatifBesin.fromJson(Map<String, dynamic> json) {
    return AlternatifBesin(
      ad: json['ad'] as String,
      miktar: (json['miktar'] as num).toDouble(),
      birim: json['birim'] as String,
      kalori: (json['kalori'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      karbonhidrat: (json['karbonhidrat'] as num).toDouble(),
      yag: (json['yag'] as num).toDouble(),
      neden: json['neden'] as String,
    );
  }
}
```

### 2. Yemek Detay Sayfasında Kullan

```dart
// lib/presentation/pages/meal_detail_page.dart

class MealDetailPage extends StatelessWidget {
  final Meal meal;
  final List<String> kullaniciKisitlamalari;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Malzemeler bölümü
          ...meal.besinler.map((besin) {
            // Kısıtlama kontrolü
            final kisitlamali = kullaniciKisitlamalari.any(
              (k) => besin.ad.toLowerCase().contains(k.toLowerCase()),
            );

            if (kisitlamali && besin.alternatifler.isNotEmpty) {
              // ⚠️ KISITLAMALI - ALTERNATİF GÖSTER
              return _buildKisitlamaliBesin(context, besin);
            } else {
              // ✅ NORMAL
              return _buildNormalBesin(besin);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildKisitlamaliBesin(BuildContext context, BesinIcerigi besin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          // Orijinal besin (çizili)
          Text(
            '${besin.miktar} ${besin.birim} ${besin.ad}',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          
          // Alternatif göster butonu
          ElevatedButton(
            onPressed: () {
              AlternatifBesinBottomSheet.goster(
                context,
                orijinalBesinAdi: besin.ad,
                orijinalMiktar: besin.miktar,
                orijinalBirim: besin.birim,
                alternatifler: besin.alternatifler,
                alerjiNedeni: 'Bu besinde alerjiniz var',
              );
            },
            child: Text('🔄 Alternatif Göster'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Otomatik Alternatif Üretme (JSON'da yoksa)

```dart
// Eğer JSON'da alternatif yoksa, otomatik üret:

if (besin.alternatifler.isEmpty) {
  final otomatikAlternatifler = AlternatifOneriServisi.otomatikAlternatifUret(
    besin.ad,
    besin.miktar,
    besin.birim,
  );
  
  if (otomatikAlternatifler.isNotEmpty) {
    // Alternatif göster
    AlternatifBesinBottomSheet.goster(...);
  }
}
```

---

## 📊 DESTEKLENEN BESİN KATEGORİLERİ

### Kuruyemişler
- Badem → Fındık, Ceviz, Antep Fıstığı, Kaju
- Ceviz → Badem, Pekan Cevizi
- Fındık → Badem, Kaju

### Meyveler
- Elma → Armut, Portakal, Mandalina
- Muz → Hurma, Kuru İncir
- Portakal → Mandalina, Greyfurt

### Süt Ürünleri
- Yoğurt → Kefir, Ayran, Badem Yoğurdu (vegan)
- Süt → Badem Sütü, Yulaf Sütü, Soya Sütü

### Protein Kaynakları
- Tavuk → Hindi, Tofu (vegan)
- Yumurta → Lor Peyniri, Tofu Scramble (vegan)

### Karbonhidrat Kaynakları
- Ekmek → Ezine Ekmeği, Yulaf Ekmeği, Tam Buğday

---

## 🎯 UI AKIŞI

### 1. Kullanıcı Profili Ayarları
```
Diyet Tipi: Vegan
Manuel Alerjiler: Ceviz, Soya
```

### 2. Ara Öğün Seçimi
```
🍎 Ara Öğün 1 Önerileri

✅ 10 Badem + 1 Elma (230 kcal)
   [Detayları Gör]

❌ 6 Ceviz + 1 Muz (Ceviz alerjiniz var)
   [Alternatif Göster]
```

### 3. Alternatif Bottom Sheet
```
┌─────────────────────────────────────┐
│ ⚠️  Bu besini yiyemezsiniz          │
│    Ceviz alerjiniz var              │
│                                     │
│ ❌ 6 adet Ceviz                     │
│                                     │
│ 🔄 Alternatif Besinler              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✅ 10 adet Badem                │ │
│ │    Benzer yağ profili           │ │
│ │    🔥 170kcal 💪 6g 🍚 6g 🥑 15g │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✅ 13 adet Fındık               │ │
│ │    Benzer besin değeri          │ │
│ │    🔥 180kcal 💪 4.2g 🍚 5g 🥑 17g│ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Kapat]                             │
└─────────────────────────────────────┘
```

### 4. Seçim Sonrası
```
✅ Fındık seçildi (13 adet)

Öğününüz güncellendi:
  13 Fındık + 1 Elma
  Toplam: 235 kcal
```

---

## 🔧 GELİŞTİRME ÖNERİLERİ

### 1. Akıllı Öneriler
```dart
// Kullanıcının geçmiş tercihlerini öğren
if (kullanici.sıkcaTercihEdiyor('Fındık')) {
  // Fındığı listenin en üstüne çıkar
  alternatifler.sort((a, b) {
    if (a.ad == 'Fındık') return -1;
    if (b.ad == 'Fındık') return 1;
    return 0;
  });
}
```

### 2. Favori Alternatifler
```dart
// Kullanıcı bir alternatifi sık seçerse, kaydet
await HiveService.favorilereEkle(
  orijinalBesin: 'Badem',
  alternatif: 'Fındık',
);

// Bir dahaki sefere direkt öner
if (favoriAlternatif != null) {
  showDialog(
    context: context,
    child: AlertDialog(
      title: Text('Önceden Fındık seçmiştin'),
      content: Text('Yine Fındık kullanayım mı?'),
      actions: [
        TextButton(child: Text('Hayır'), onPressed: ...),
        ElevatedButton(child: Text('Evet'), onPressed: ...),
      ],
    ),
  );
}
```

### 3. Toplu Alternatif Değiştirme
```dart
// Bir öğündeki TÜM kısıtlamalı besinleri değiştir
ElevatedButton(
  onPressed: () {
    final degisiklikler = meal.besinler
        .where((b) => kullaniciKisitlamalari.contains(b.ad))
        .map((b) => b.alternatifler.first)
        .toList();
    
    showDialog(
      content: Text('${degisiklikler.length} besin alternatifiyle değiştirilsin mi?'),
    );
  },
  child: Text('Tüm Alerjileri Değiştir'),
)
```

---

## ✅ SONUÇ

Bu sistem ile:
- ✅ Kullanıcı ara öğünlerdeki alerjilerini görebilir
- ✅ Anında alternatif önerileri alır
- ✅ Tek tıkla değiştirebilir
- ✅ Besin değerleri korunur
- ✅ Makro dengeleri bozulmaz

**Şimdi bu sistemi ekleyip FAZ 4-10'a geçelim mi?** 🚀
