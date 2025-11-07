# GPT-5 PRO: 8 HAFTALıK TÜRk DİYETİSYEN PLANı

## 🎯 PROF1L B1LG1LER1
```json
{
  "kullanici_profil": {
    "demografik": {
      "yas": 28,
      "cinsiyet": "Erkek",
      "boy": 180,
      "kilo": 75,
      "bmi": 23.1,
      "aktivite_seviyesi": "Orta Aktif",
      "antrenman": "Haftada 3-4 gün ağırlık + 2 gün kardiyo"
    },
    "hedef": {
      "tip": "Lean Bulk + Maintenance",
      "aciklama": "Yavaş kas kazanımı, yağ oranını koruma",
      "sure": "8 hafta"
    },
    "beslenme_hedefleri": {
      "gunluk_kalori": 2400,
      "protein": {
        "gram": 150,
        "kalori": 600,
        "yuzde": 25
      },
      "karbonhidrat": {
        "gram": 300,
        "kalori": 1200,
        "yuzde": 50
      },
      "yag": {
        "gram": 67,
        "kalori": 600,
        "yuzde": 25
      }
    },
    "ogun_dagilimi": {
      "kahvalti": 400, // kcal
      "ara_ogun_1": 300,
      "ogle": 500,  
      "ara_ogun_2": 350,
      "aksam": 550,
      "gece_atistirma": 300
    }
  }
}
```

## 🇹🇷 TÜRk D1YET1SYEN STANDARTLARI

### Kültürel Gereksinimler:
- **Türk mutfağı ağırlıklı** (70% geleneksel, 30% modern)
- **Ekonomik yemekler** (orta gelir seviyesi)
- **Mevsimsel ürünler** (kış-bahar geçişi)
- **Aile dostu** yemekler
- **İş hayatı uyumlu** (ofiste yenebilir)

### Beslenme Kuralları:
- **Kahvaltı:** Türk kahvaltısı temel alınarak
- **Öğle:** İş molası uyumlu (30-45 dk)
- **Akşam:** Aile yemeği tarzı
- **Ara öğünler:** Pratik, taşınabilir
- **Gece:** Hafif, sindirim dostu

## 📋 8 HAFTALIK PLAN YAPISI

### Format:
```json
{
  "hafta_1": {
    "pazartesi": {
      "kahvalti": {
        "yemek_adi": "Menemen + Peynir + Zeytin",
        "malzemeler": [
          {"ad": "Yumurta", "miktar": 2, "birim": "adet", "kcal": 140, "protein": 12, "karb": 1, "yag": 10},
          {"ad": "Domates", "miktar": 100, "birim": "gr", "kcal": 18, "protein": 1, "karb": 4, "yag": 0},
          {"ad": "Beyaz peynir", "miktar": 50, "birim": "gr", "kcal": 132, "protein": 11, "karb": 1, "yag": 10}
        ],
        "toplam": {"kcal": 400, "protein": 25, "karb": 20, "yag": 22},
        "hazirlik_suresi": "10 dk",
        "tarif_notu": "Menemen közde pişirilir, yanına tam tahıllı ekmek"
      }
    }
  }
}
```

## 🔥 GPT-5 PRO TALMAT1

**GÖREV:** 8 haftalık, günlük 6 öğün, her gün farklı yemek olan mega beslenme planı oluştur.

**DETAYLAR:**
- **Toplam:** 8 hafta x 7 gün x 6 öğün = **336 farklı yemek**
- **Her yemek:** Malzeme detayları, gramajlar, makro değerler
- **Türk diyetisyeni** standardında
- **Çeşitlilik:** Hiçbir yemek tekrar etmesin
- **Mevsimsel:** Mart-Nisan aylarına uygun
- **Ekonomik:** Orta gelir seviyesine uygun

**ÖNEMLİ KURALLAR:**
1. **Her malzeme için:** Ad, miktar, birim, kcal, protein, karb, yağ
2. **Her öğün için:** Toplam makro hesapları
3. **Her gün için:** Günlük makro toplamları doğrula  
4. **Haftalık:** Toplam kalori kontrolü
5. **8 hafta:** Progressif gelişim (1. hafta basit → 8. hafta çeşitli)

**JSON YAPISINI KORU:**
- Dosya boyutu optimize et
- Gereksiz açıklamalar ekleme
- Sadece gerekli dataları ver
- 300 yemeklik hedef

**KALİTE KONTROL:**
- Günlük 2400 kcal ±50
- Protein 150g ±10  
- Karb 300g ±20
- Yağ 67g ±8

**ÇIKTI:** `turk_diyetisyen_8_haftalik_mega_plan.json`