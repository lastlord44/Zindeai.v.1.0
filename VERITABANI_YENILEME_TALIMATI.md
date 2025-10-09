# ⚠️ ACİL: VERİTABANI YENİLEME TALİMATI

## 🔥 SORUN NEDİR?

**Ara Öğün 2'de sadece süzme yoğurt geliyor** çünkü:

1. `ara_ogun_toplu_120.json` dosyasındaki 120 yemek **yanlış kategoride** (Ara Öğün 1) kayıtlı
2. Migration kodu **düzeltildi** ama **mevcut veritabanı eski verilerle dolu**
3. Kod değişikliği yapıldı ama **veritabanı temizlenip yeniden yüklenmedi**

## ✅ ÇÖZÜM: MAINTENANCE PAGE KULLAN

### Adım 1: Maintenance Page'i Aç
1. Uygulamayı çalıştır: `flutter run`
2. Profil sayfasından veya debug menüsünden **Maintenance Page**'i aç
   - Eğer direkt erişim yoksa, route'u ekle veya debug menüsüne ekle

### Adım 2: Veritabanını Temizle ve Yeniden Yükle
1. **"🔄 DB Temizle ve Yeniden Yükle"** butonuna bas
2. İşlem tamamlanana kadar bekle (30 saniye - 1 dakika)
3. "✅ Migration başarıyla tamamlandı!" mesajını gör

### Adım 3: Sonucu Kontrol Et
Migration tamamlandığında şu istatistikleri göreceksin:

```
Kategori Dağılımı:
├─ Kahvaltı: 300+ yemek
├─ Ara Öğün 1: 50+ yemek
├─ Ara Öğün 2: 120+ yemek  ← 🔥 BU ARTTI!
├─ Öğle Yemeği: 300+ yemek
├─ Akşam Yemeği: 450+ yemek
└─ Gece Atıştırması: 20+ yemek
```

**ÖNCESİ:** Ara Öğün 2: ~10 yemek (sadece süzme yoğurt vb.)
**SONRASI:** Ara Öğün 2: 120+ yemek (çok çeşitli ara öğünler!)

## 🔧 NE DEĞİŞTİ?

### `lib/core/utils/yemek_migration_guncel.dart` - Satır 240
```dart
// ÖNCEDEN (YANLIŞ):
if (dosyaLower.contains('ara_ogun_toplu'))
  return 'Ara Öğün 1'; // ❌ YANLIŞTI!

// ŞİMDİ (DOĞRU):
if (dosyaLower.contains('ara_ogun_toplu'))
  return 'Ara Öğün 2'; // ✅ DÜZELTİLDİ!
```

Bu değişiklik sayesinde `ara_ogun_toplu_120.json` dosyasındaki 120 yemek artık **Ara Öğün 2** kategorisine yüklenecek.

## ⚡ HIZLI ERİŞİM İÇİN (Opsiyonel)

Eğer MaintenancePage'e erişim yoksa, `lib/main.dart` veya ana route dosyasına ekle:

```dart
// Debug menüsüne veya drawer'a ekle:
ListTile(
  leading: Icon(Icons.build),
  title: Text('🔧 Maintenance'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenancePage(),
      ),
    );
  },
),
```

## 📊 SONUÇ

Migration tamamlandıktan sonra:
- ✅ Ara Öğün 2'de 120+ farklı yemek seçeneği olacak
- ✅ Sadece süzme yoğurt gelme sorunu çözülecek
- ✅ Genetik algoritma daha fazla seçenekle daha iyi planlar yapacak

---

**ŞİMDİ YAPILACAK:** Uygulamayı aç → MaintenancePage → "DB Temizle ve Yeniden Yükle" ✅
