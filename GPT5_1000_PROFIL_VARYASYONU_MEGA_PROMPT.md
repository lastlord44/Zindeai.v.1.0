# MEGA PROMPT (v2 - Sadeleştirilmiş): ZindeAI için GPT-5 Pro ile 1000 Profil ve 10.000 Yemeklik Veritabanı

**GÖREV:** Sen, ZindeAI Flutter projesinin veri mimarisine %100 hakim, ultra profesyonel bir diyetisyen ve yazılım mimarısın. Görevin, proje için **hatasız** ve **doğrudan kullanılabilir** bir başlangıç veritabanı oluşturmak. Proje dışı hiçbir alan veya varsayım kabul edilemez. Sadece aşağıdaki modellere ve kurallara sadık kal.

**ANA KURAL:** Üreteceğin tüm JSON verileri, aşağıdaki Dart modellerine doğrudan `fromJson` ile parse edilebilir olmalı ve **hiçbir manuel düzeltme gerektirmemelidir**.

---

## 1. TEMEL VERİ MODELLERİ (SADELEŞTİRİLMİŞ)

JSON yapıların bu Dart sınıflarına tam olarak uymalıdır. Alan adları, veri tipleri ve enum değerleri birebir aynı olmalıdır.

### `KullaniciProfili` Modeli (Sadeleştirilmiş)

```dart
class KullaniciProfili {
  final String id;
  final String ad;
  final int yas;
  final double boy; // cm
  final double mevcutKilo; // kg
  final double? hedefKilo; // kg
  final Cinsiyet cinsiyet;
  final AktiviteSeviyesi aktiviteSeviyesi;
  final Hedef hedef;
  final DateTime kayitTarihi;
}
```

### `Yemek` Modeli (Sadeleştirilmiş)

```dart
class Yemek {
  final String id;
  final String ad;
  final OgunTipi ogun;
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final List<String> malzemeler;
  final int hazirlamaSuresi; // dakika
  final List<String> etiketler;
  final String? proteinKaynagi; // Ana Protein Kaynağı (örn: "Tavuk", "Somon", "Mercimek")
}
```

### `ENUM` Değerleri (JSON'da bu string değerler kullanılacak)

-   **`Cinsiyet`**: `erkek`, `kadin`
-   **`AktiviteSeviyesi`**: `hareketsiz`, `hafifAktif`, `ortaAktif`, `cokAktif`
-   **`Hedef`**: `kiloVermek`, `kiloAlmak`, `kasKazanKiloAl`, `kasKazanKiloVer`, `formdaKal`
-   **`OgunTipi`**: `kahvalti`, `araOgun1`, `ogle`, `araOgun2`, `aksam`, `geceAtistirma`

---

## 2. GÖREV ADIMLARI

### ADIM 1: 10.000 Adet Türk Yemeği Veritabanı Oluştur

-   **İçerik:** Sadece Türk mutfağına ait, çeşitli ve gerçekçi 10.000 adet yemek oluştur.
-   **Makro Hesaplaması:** Her yemeğin kalori ve makro değerleri (protein, karbonhidrat, yağ) porsiyon başına **gerçekçi ve doğru** bir şekilde hesaplanmalı. Malzemeler ve miktarlarıyla tutarlı olmalı.
-   **`proteinKaynagi` Alanı:** Her ana öğün (öğle, akşam) için bu alanı mutlaka doldur. Örnek: "Kuzu Eti", "Kırmızı Mercimek", "Hamsi", "Tavuk But".
-   **`id` Alanı:** Her yemek için benzersiz bir `id` oluştur (örn: `yemek_00001`, `yemek_00002`).
-   **`malzemeler` Alanı:** Malzemeleri "Malzeme Adı (Miktar Birim)" formatında yaz. Örnek: `["Kuru Fasulye (200 g)", "Soğan (1 adet)", "Domates Salçası (1 yk)"]`.
-   **`etiketler` Alanı:** `ekonomik`, `pratik`, `yoresel`, `dusuk_karb` gibi ilgili etiketleri ekle.
-   **ÇIKTI FORMATI:** Yemekleri, her birinde 300 adet `Yemek` nesnesi bulunan `List<Yemek>` formatında, birden çok JSON dosyası olarak ver. Dosya adları `yemekler_001.json`, `yemekler_002.json`, ..., `yemekler_034.json` şeklinde olmalıdır. Bu, sistemin şişmesini önlemek için **KRİTİKTİR**.

### ADIM 2: 1000 Adet Kullanıcı Profili Oluştur

-   **İçerik:** Türkiye'deki demografik yapıya uygun, geniş bir yelpazede 1200 adet kullanıcı profili oluştur.
-   **Varyasyonlar:**
    -   **Yaş:** 18-65 arası.
    -   **Cinsiyet:** %55 Erkek, %45 Kadın.
    -   **Kilo/Boy:** Zayıf, normal, kilolu, obez gibi farklı Vücut Kitle İndeksi (VKİ) aralıklarını kapsa.
    -   **`aktiviteSeviyesi` ve `hedef`:** Tüm kombinasyonları mantıklı oranlarda dağıt.
-   **`id` Alanı:** Her profil için benzersiz bir `id` oluştur (örn: `profil_0001`, `profil_0002`).
-   **ÇIKTI FORMATI:** `List<KullaniciProfili>` şeklinde tek bir `kullanici_profilleri.json` dosyası oluştur.

### ADIM 3: SON KONTROL VE DOĞRULAMA (PROFESYONEL DİYETİSYEN GÖZÜYLE)

Bu adım, önceki adımlarda ürettiğin tüm `Yemek` verileri için zorunlu bir kalite kontrol sürecidir.

1.  **Makro Tutarlılığı Kontrolü:** Ürettiğin her bir yemeği tekrar gözden geçir. Yemeğin `kalori`, `protein`, `karbonhidrat` ve `yag` değerleri, `malzemeler` listesindeki ürünlerin ve gramajlarının toplamıyla **matematiksel ve mantıksal olarak tutarlı mı?**
    *   **Örnek Hata:** `malzemeler: ["Tavuk Göğsü (200 g)"]` olan bir yemeğin `protein: 15` olamaz. 200g tavuk yaklaşık 45-50g protein içerir. Bu tür hataları ayıkla ve düzelt.
    *   **Örnek Hata:** `malzemeler: ["Zeytinyağı (2 yk)"]` olan bir yemeğin `yag: 2` olamaz. 2 yemek kaşığı yağ yaklaşık 25-30g yağ içerir. Bu tür bariz tutarsızlıkları gider.

2.  **Porsiyon Gerçekçiliği:** Malzeme gramajları gerçek bir öğün için mantıklı mı? Bir porsiyon çorba 2 litre, bir salata 5 gram olamaz. Porsiyonları ve gramajları bir Türk diyetisyenin gözüyle tekrar değerlendir.

**Bu kontrolü yapmadan ve verilerin doğruluğundan %100 emin olmadan nihai çıktıyı oluşturma.**

---

## 3. NİHAİ ÇIKTI

Tüm çıktıların **SADECE JSON** formatında olmasını istiyorum. Açıklama, yorum veya başka bir metin ekleme.

**İstenen Dosyalar:**

1.  `yemekler_001.json` ... `yemekler_034.json` (Her biri `List<Yemek>` formatında 300 yemek içerir)
2.  `kullanici_profilleri.json` (`List<KullaniciProfili>`)

Bu görev, projenin temelini oluşturacak. Senden beklentim, bir makinenin hassasiyetiyle bu devasa ve hatasız veritabanını oluşturmandır.
