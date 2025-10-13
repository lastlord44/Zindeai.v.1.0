# 🎯 ZİNDEAI - Kişiselleştirilmiş Fitness & Beslenme Asistanı

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0-orange.svg)]()

## 📱 Proje Hakkında

**ZindeAI**, kişiselleştirilmiş fitness ve beslenme asistanı olarak geliştirilmiş, **Flutter** tabanlı modern bir mobil uygulamadır. Proje, **genetik algoritma** ile akıllı öğün planlaması, **malzeme bazlı alternatif sistem** ve **AI chatbot** entegrasyonu gibi gelişmiş özellikler içermektedir.

### 🏆 Ana Özellikler

- 🧬 **Genetik Algoritma ile Öğün Planlama** - 100 popülasyon, 50 jenerasyon ile optimal plan oluşturma
- 🤖 **AI Chatbot Entegrasyonu** - Profil bazlı kişiselleştirilmiş öneriler
- 🔄 **Malzeme Bazlı Alternatif Sistem** - 150+ besin veritabanı ile akıllı alternatifler
- 💾 **Hive Local Storage** - Offline çalışma desteği
- 📊 **Makro Takibi** - Kalori, protein, karbonhidrat, yağ hesaplama
- 🎨 **Modern UI/UX** - Material 3 tasarım, responsive arayüz

## 🚀 Teknoloji Stack

- **Framework:** Flutter 3.x
- **Dil:** Dart 3.x
- **Mimari:** Clean Architecture + BLoC Pattern
- **Veritabanı:** Hive (NoSQL Local Storage)
- **State Management:** flutter_bloc
- **AI Entegrasyonu:** Pollinations AI API

## 📊 Proje İstatistikleri

- **Toplam Dosya:** 155+ dosya
- **Toplam Kod:** ~190,000 satır
- **Yemek Veritabanı:** 2300+ yemek
- **Besin Malzemesi:** 4000+ malzeme
- **Geliştirme Süresi:** 3+ ay
- **Proje Maturity:** Beta (v0.9)

## 🏗️ Mimari Yapı

```
lib/
├── presentation/     # UI Layer (Widgets, Pages, BLoC)
├── domain/          # Business Logic (Entities, UseCases)
├── data/            # Data Layer (Models, DataSources)
└── core/            # Shared Utilities
```

## 🎯 Öne Çıkan Özellikler

### 🧬 Genetik Algoritma ile Öğün Planlama
- **Popülasyon:** 100 birey
- **Jenerasyon:** 50
- **Fitness Skoru:** 0-100 (makro hedeflerine göre)
- **Çeşitlilik Mekanizması:** Son 7 günlük yemek geçmişi
- **Plan Oluşturma Süresi:** ~500ms

### 🤖 AI Chatbot Entegrasyonu
- **4 Kategori:** Supplement, Beslenme, Antrenman, Genel
- **Profil Bazlı:** Yaş, kilo, boy, hedef bilgilerine göre kişiselleştirilmiş öneriler
- **Pollinations AI API** entegrasyonu

### 🔄 Alternatif Besin Sistemi
- **Malzeme Bazlı:** "200g tavuk göğsü" → Balık, hindi, et alternatifleri
- **Yemek Bazlı:** Aynı öğün tipinde farklı yemekler
- **150+ Besin Veritabanı**

### 💾 Hive Local Storage
- **NoSQL Database:** Hızlı okuma/yazma
- **Type-safe Models:** HiveType adapterleri
- **Offline-first:** İnternet olmadan çalışma
- **Migration Desteği**

## 📱 Kullanıcı Deneyimi

### Modern UI/UX
- Material 3 tasarım
- Renkli ve görsel zengin kartlar
- Bottom sheet kullanımı
- Emoji kullanımı (friendly)
- Progress bar'lar (makro takibi)

### Navigasyon
- Bottom navigation bar (4 sekme)
- Haftalık takvim ile kolay tarih geçişi
- Modal bottom sheet'ler
- Pull-to-refresh desteği

## 📊 Performans Metrikleri

| Metrik | Değer | Hedef | Durum |
|--------|-------|-------|-------|
| App Başlangıç | ~2s | <3s | ✅ |
| Plan Oluşturma | ~500ms | <1s | ✅ |
| Hive Okuma | ~5ms | <10ms | ✅ |
| Hive Yazma | ~10ms | <20ms | ✅ |
| UI Render | 60fps | 60fps | ✅ |
| Memory Usage | ~100MB | <150MB | ✅ |

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Git

### Adımlar

1. **Repository'yi klonlayın:**
```bash
git clone https://github.com/yourusername/zindeai.git
cd zindeai
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Hive adapter'larını oluşturun:**
```bash
flutter packages pub run build_runner build
```

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```

## 📋 Bağımlılıklar

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.65.0
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

## 🎯 Roadmap

### Kısa Vadeli (1-2 Hafta)
- [ ] FAZ 8'i %100 tamamla
- [ ] Kritik bug'ları düzelt
- [ ] Test coverage başlat

### Orta Vadeli (1-2 Ay)
- [ ] FAZ 9-10'u tamamla
- [ ] Test coverage %60+
- [ ] Production-ready hale getir

### Uzun Vadeli (3-6 Ay)
- [ ] Backend entegrasyonu
- [ ] AI/ML features
- [ ] Social features
- [ ] App store release

## 🐛 Bilinen Sorunlar

1. **Tolerans Sistemi** - Bazı durumlarda makro sapma toleransı aşılabiliyor
2. **AlternatifBesinBottomSheet** - Entegrasyon hatası mevcut
3. **Test Coverage** - Unit testler eksik

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**ZindeAI Development Team**
- **Framework:** Flutter
- **AI Integration:** Pollinations AI
- **Architecture:** Clean Architecture + BLoC

## 📞 İletişim

- **GitHub:** [ZindeAI Repository](https://github.com/yourusername/zindeai)
- **Issues:** [GitHub Issues](https://github.com/yourusername/zindeai/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/zindeai/discussions)

## 🎉 Teşekkürler

- Flutter ekibine harika framework için
- Hive ekibine hızlı NoSQL database için
- Pollinations AI ekibine AI entegrasyonu için
- Tüm açık kaynak katkıcılarına

---

**ZindeAI** - Kişiselleştirilmiş Fitness & Beslenme Asistanı 🎯

*"Sağlıklı yaşamın anahtarı, doğru beslenme ve düzenli antrenmandır."*