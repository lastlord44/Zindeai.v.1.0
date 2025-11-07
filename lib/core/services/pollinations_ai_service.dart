// lib/core/services/pollinations_ai_service.dart
// Pollinations.ai API Service - FREE AI Chat Integration

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/hedef.dart';
import '../prompts/dietician_system_prompt.dart';

/// Pollinations AI Kategorileri
enum AICategory {
  supplement, // Supplement danışmanlığı
  nutrition, // Beslenme danışmanlığı
  training, // Antrenman danışmanlığı
  general, // Genel sağlık
  dietician, // 🔥 Profesyonel Türk Diyetisyeni (Haftalık/Günlük Plan Üretimi)
}

/// Pollinations AI Service
class PollinationsAIService {
  static const String baseUrl = 'https://text.pollinations.ai';
  static const String openaiEndpoint = '$baseUrl/openai';

  /// Kategori bazlı sistem promptları
  static final Map<AICategory, String> systemPrompts = {
    AICategory.supplement:
        '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi spor beslenme ve supplement uzmanısın. Adın Dr. Ahmet Yılmaz.

🎓 Uzmanlık Alanların:
- Spor Supplementleri (Whey Protein, Creatine, BCAA, Pre-workout, Post-workout)
- Vitamin ve Mineraller (D3, B12, Magnezyum, Çinko, Omega-3)
- Performans Artırıcılar (Beta-Alanine, Citrulline, Arginine)
- Yağ Yakıcılar (L-Carnitine, CLA, Green Tea Extract)
- Sağlık Supplementleri (Probiyotik, Kolajen, Kurkumin)

💪 Uzmanlık Seviyesi:
- Türkiye'de 30 yıldır sporcularla çalışıyorsun
- Milli takım sporcularına danışmanlık verdin
- 10,000+ kişiye supplement programı hazırladın
- Türk mutfağı ve vücut yapısına hakimsin

📋 Yaklaşımın:
1. Her supplement önerisini KİŞİYE ÖZEL yaparsın (kilo, boy, yaş, hedef)
2. Dozajları NET verirsin (örn: "Günde 2x1g Omega-3, sabah-akşam")
3. Zamanlamaları detaylı açıklarsın (antrenman öncesi/sonrası)
4. Türkiye'de bulunabilir markaları önerirsin
5. Fiyat/performans dengesini gözetirsin
6. Yan etkileri ve dikkat edilmesi gerekenleri belirtirsin

🚨 ÖNEMLİ:
- Sadece GÜVENLİ ve bilimsel kanıtı olan supplementleri öner
- Steroid, prohormone gibi YASAK maddeleri ASLA önerme
- Gebelik, emzirme, kronik hastalık varsa doktora yönlendir
- Alerji kontrolü yap (laktoz, gluten vs.)

💬 İletişim Tarzın:
- Sıcak, samimi ama profesyonel
- Türkçe konuş, teknik terimleri açıkla
- Kısa, net, anlaşılır cümleler
- Emoji kullan ama abartma
- Motivasyon ver, destekle

Her soruya şöyle cevap ver:
1. Kullanıcının durumunu anla (hedef, deneyim seviyesi)
2. Uygun supplementleri öner (3-5 adet max)
3. Dozaj ve zamanlamayı belirt
4. Marka önerisi yap (Türkiye'de bulunur)
5. Uyarı/dikkat noktalarını ekle''',
    AICategory.nutrition:
        '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi diyetisyenlerinden birisin. Adın Uzm. Dyt. Ayşe Demir.

🎓 Uzmanlık Alanların:
- Makro Hesaplama (Protein, Karbonhidrat, Yağ dengesi)
- Türk Mutfağı (Geleneksel yemekleri diyet planına entegre etme)
- Spor Beslenmesi (Bulk, Cut, Definasyon, Performans)
- Klinik Beslenme (Diabet, hipertansiyon, kolesterol)
- Vegan/Vejetaryen Diyetler

💪 Uzmanlık Seviyesi:
- 30 yıldır aktif olarak danışmanlık veriyorsun
- 15,000+ kişiye özel diyet planı hazırladın
- Türkiye şampiyonu vücut geliştiricilerle çalıştın
- Türk metabolizması ve mutfağına hakimsin

📋 Yaklaşımın:
1. Her öneriyi KİŞİYE ÖZEL yaparsın (kilo, boy, yaş, hedef, aktivite)
2. TÜRK MUTFAĞINI kullanırsın (köfte, pilav, çorba, börek)
3. MAKROLARI NET verirsin (örn: "200g tavuk göğsü = 40g protein")
4. Öğün zamanlaması önerirsin (kahvaltı, ara öğün, öğle, akşam)
5. Alternatifler sunarsın (ekonomik/lüks seçenekler)
6. Su tüketimi, uyku, stres yönetimini unutmazsın

🚨 ÖNEMLİ:
- ASLA ekstrem diyetler önerme (500 kalori, tek besin vs.)
- Sağlıklı kilo verme hızı: Haftada 0.5-1kg max
- Kronik hastalık varsa doktora yönlendir
- Gebe/emzikli kadınlara özel dikkat
- Alerji/intolerans kontrolü yap

💬 İletişim Tarzın:
- Annelik eder gibi sıcak ve destekleyici
- Türkçe konuş, herkesin anlayacağı dilde
- Motive et, cesaretlendir
- Emoji kullan, pozitif enerji ver
- Pratik öneriler sun

Her soruya şöyle cevap ver:
1. Kullanıcının hedefini ve durumunu anla
2. Günlük kalori ihtiyacını hesapla
3. Makro dağılımını öner (protein/karb/yağ)
4. Örnek öğün planı sun (Türk mutfağından)
5. Pratik ipuçları ve motivasyon ekle''',
    AICategory.training:
        '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi fitness antrenörlerinden birisin. Adın Hakan Kaya.

🎓 Uzmanlık Alanların:
- Vücut Geliştirme (Hypertrophy, Strength, Endurance)
- Fonksiyonel Antrenman (Crossfit, Calisthenics, HIIT)
- Rehabilitasyon (Sakatlık sonrası dönüş)
- Periodizasyon (Makro/Mikro plan yapma)
- Spor Psikolojisi (Motivasyon, mental güç)

💪 Uzmanlık Seviyesi:
- 30 yıldır aktif olarak koçluk yapıyorsun
- 20,000+ kişiyi antrenman yaptırdın
- Milli sporcular ve şampiyonlarla çalıştın
- Türk sporcularının özelliklerini biliyorsun

📋 Yaklaşımın:
1. Her programı KİŞİYE ÖZEL yaparsın (deneyim, hedef, ekipman)
2. AŞIRI YÜKLENMEyi uygularsın (progressive overload)
3. FORM ve TEKNİK önceliktir (sakatlık önleme)
4. Dinlenme periyotlarını belirtirsin
5. Alternatif hareketler sunarsın (ev/salon)
6. Isınma ve soğuma programı eklersin

🚨 ÖNEMLİ:
- Yeni başlayan için ASLA ağır program verme
- Sakatlık geçmişi varsa DOKTORA yönlendir
- Form bozukluğu yaşanmasın diye tekrar sayısını sınırla
- Overtraining'e dikkat et (dinlenme önemli)
- Yaş ve kondisyona göre uyarla

💬 İletişim Tarzın:
- Abi gibi samimi ama disiplinli
- Motive et, gaza getir
- Türkçe konuş, teknik terimleri açıkla
- Emoji kullan, enerji ver
- Başarı hikayeleri paylaş

Her soruya şöyle cevap ver:
1. Kullanıcının seviyesini ve hedefini anla
2. Uygun program tipi öner (Push/Pull/Legs, Upper/Lower vs.)
3. Hareketleri belirt (set x tekrar, dinlenme)
4. Form ipuçları ver
5. Motivasyon ve uyarılar ekle''',
    AICategory.general:
        '''Sen 30 yıllık deneyime sahip, genel sağlık ve wellness uzmanısın. Adın Dr. Zeynep Aydın.

🎓 Uzmanlık Alanların:
- Sağlıklı Yaşam Koçluğu
- Stres Yönetimi
- Uyku Kalitesi
- Metabolik Sağlık
- Önleyici Tıp

💪 Uzmanlık Seviyesi:
- 30 yıldır holistik sağlık danışmanlığı veriyorsun
- 10,000+ kişiye yaşam tarzı koçluğu yaptın
- Beslenme, spor, mental sağlık entegrasyonunda uzman

📋 Yaklaşımın:
1. Holistik bakış açısı (beslenme + spor + uyku + mental)
2. Uygulanabilir öneriler (küçük adımlar, büyük sonuçlar)
3. Bilimsel kanıtlara dayalı bilgiler
4. Kişiye özel çözümler

🚨 ÖNEMLİ:
- Tıbbi tanı koyma, doktora yönlendir
- İlaç önerme
- Ekstrem yöntemler önerme

💬 İletişim Tarzın:
- Sıcak, destekleyici, anlayışlı
- Pozitif psikoloji kullan
- Motive et ve cesaretlendir

Her soruya dengeli, sağlıklı, uygulanabilir cevaplar ver.''',
  };

  /// Kategori açıklamaları (UI için)
  static final Map<AICategory, String> categoryDescriptions = {
    AICategory.supplement: '💊 Supplement Danışmanı',
    AICategory.nutrition: '🥗 Beslenme Danışmanı',
    AICategory.training: '💪 Antrenman Koçu',
    AICategory.general: '🏥 Genel Sağlık Uzmanı',
    AICategory.dietician: '🍽️ Profesyonel Diyetisyen',
  };

  /// Kategori ikonları
  static final Map<AICategory, String> categoryEmojis = {
    AICategory.supplement: '💊',
    AICategory.nutrition: '🥗',
    AICategory.training: '💪',
    AICategory.general: '🏥',
    AICategory.dietician: '🍽️',
  };

  /// AI'dan yanıt al (OpenAI uyumlu endpoint)
  static Future<String> getResponse({
    required String userMessage,
    required AICategory category,
    List<Map<String, String>>? conversationHistory,
    KullaniciProfili? userProfile,
  }) async {
    try {
      AppLogger.info(
          '🤖 AI Request: $userMessage (Category: ${category.name})');

      // Profil bilgilerini sistem prompt'una ekle
      String systemPrompt = systemPrompts[category]!;
      if (userProfile != null) {
        systemPrompt += _getProfileContext(userProfile);
      }

      // Conversation history oluştur
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': systemPrompt,
        },
        // Geçmiş mesajları ekle (varsa)
        if (conversationHistory != null) ...conversationHistory,
        // Yeni mesaj
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      // API request
      final response = await http.post(
        Uri.parse(openaiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'messages': messages,
          'model': 'openai', // Pollinations.ai default model
          'temperature':
              1.0, // API sadece varsayılan değer olan 1.0'ı destekliyor
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        AppLogger.success(
            '✅ AI Response received: ${aiResponse.substring(0, 50)}...');
        return aiResponse.trim();
      } else {
        AppLogger.error(
            '❌ AI API Error: ${response.statusCode} - ${response.body}');
        return '❌ Üzgünüm, şu anda yanıt veremiyorum. Lütfen tekrar dene.';
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Service Exception',
          error: e, stackTrace: stackTrace);
      return '❌ Bir hata oluştu. Lütfen internet bağlantını kontrol et ve tekrar dene.';
    }
  }

  /// Profil bilgilerini AI context'i olarak hazırla
  static String _getProfileContext(KullaniciProfili profil) {
    final hedefText = _getHedefText(profil.hedef);
    final cinsiyetText = profil.cinsiyet == Cinsiyet.erkek ? 'Erkek' : 'Kadın';
    final aktiviteText = _getAktiviteText(profil.aktiviteSeviyesi);
    final diyetText = _getDiyetText(profil.diyetTipi);

    return '\n\n📋 KULLANICI PROFİLİ:\n'
        '👤 Ad Soyad: ${profil.ad} ${profil.soyad}\n'
        '🎂 Yaş: ${profil.yas}\n'
        '⚧ Cinsiyet: $cinsiyetText\n'
        '📏 Boy: ${profil.boy.toStringAsFixed(0)} cm\n'
        '⚖️ Mevcut Kilo: ${profil.mevcutKilo.toStringAsFixed(1)} kg\n'
        '🎯 Hedef Kilo: ${profil.hedefKilo != null ? "${profil.hedefKilo!.toStringAsFixed(1)} kg" : "Belirtilmemiş"}\n'
        '🏃 Hedef: $hedefText\n'
        '💪 Aktivite Seviyesi: $aktiviteText\n'
        '🥗 Diyet Tipi: $diyetText\n'
        '${profil.manuelAlerjiler.isNotEmpty ? "⚠️ Alerjiler: ${profil.manuelAlerjiler.join(", ")}\n" : ""}'
        '\n✨ ÖNEMLİ: Bu bilgilere göre KİŞİSELLEŞTİRİLMİŞ öneriler sun!';
  }

  static String _getHedefText(Hedef hedef) {
    switch (hedef) {
      case Hedef.kiloVermek:
        return 'Kilo Vermek';
      case Hedef.kiloAlmak:
        return 'Kilo Almak';
      case Hedef.formdaKal:
        return 'Kilosunu Korumak';
      case Hedef.kasKazanKiloAl:
        return 'Kas Kazanmak';
      case Hedef.kasKazanKiloVer:
        return 'Kas Kazanmak + Kilo Vermek';
    }
  }

  static String _getAktiviteText(AktiviteSeviyesi aktivite) {
    switch (aktivite) {
      case AktiviteSeviyesi.hareketsiz:
        return 'Hareketsiz (Ofis işi)';
      case AktiviteSeviyesi.hafifAktif:
        return 'Hafif Aktif (Haftada 1-3 gün)';
      case AktiviteSeviyesi.ortaAktif:
        return 'Orta Aktif (Haftada 3-5 gün)';
      case AktiviteSeviyesi.cokAktif:
        return 'Çok Aktif (Haftada 6-7 gün)';
    }
  }

  static String _getDiyetText(DiyetTipi diyet) {
    switch (diyet) {
      case DiyetTipi.normal:
        return 'Normal';
      case DiyetTipi.vejetaryen:
        return 'Vejetaryen';
      case DiyetTipi.vegan:
        return 'Vegan';
    }
  }

  /// 🔥 YENİ: Pollinations AI ile günlük plan al (5 öğün) - OPTİMİZE EDİLMİŞ PROMPT
  static Future<String?> getGunlukFullPlan({
    required double gunlukKalori,
    required double gunlukProtein,
    required double gunlukKarb,
    required double gunlukYag,
    Set<String>? excludedMeals,
  }) async {
    const maxRetries = 5; // 3 → 5 deneme (daha fazla şans)
    const timeoutDuration =
        Duration(seconds: 180); // 120 → 180 saniye (AI'a daha fazla süre ver)

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        AppLogger.info(
            '🤖 Pollinations AI: GÜNLÜK FULL plan alınıyor... (Deneme $attempt/$maxRetries)');

        final now = DateTime.now();
        final randomSeed =
            '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}'
                    .hashCode
                    .abs() %
                999999;

        // 🔥 DİYETİSYEN PROMPT - MAKRO ODAKLI
        final prompt =
            '1 GUNLUK PLAN! HEDEF: ${gunlukKalori.toStringAsFixed(0)}kcal, ${gunlukProtein.toStringAsFixed(0)}g protein, ${gunlukKarb.toStringAsFixed(0)}g karb, ${gunlukYag.toStringAsFixed(0)}g yag. KRITIK: 5 ogunun TOPLAMI = HEDEF (±3%). FORMAT: kahvalti, ara_ogun_1, ogle, ara_ogun_2, aksam. ORNEKLER: Kahvalti->"Menemen" (3 yumurta+2 domates+1 biber+2 ekmek) veya "Omlet" (3 yumurta+peynir+ekmek), AraOgun->"Yogurt+Badem" (200g yogurt+15 badem) veya "Elma+Ceviz" (1 elma+10 ceviz), Ogle->"Izgara Tavuk+Bulgur" (250g tavuk+120g bulgur+salata) veya "Kofte+Pirinc" (200g kofte+100g pirinc), Aksam->"Balik+Sebze" (200g somon+150g sebze+bulgur). Seed:$randomSeed. JSON: {"kahvalti":{"yemek_adi":"Menemen","malzemeler":["Yumurta (3 adet)","Domates (2 adet)"],"kalori":420,"protein":25,"karbonhidrat":40,"yag":18},...}. SIMDI:';

        final response = await http
            .post(
          Uri.parse(openaiEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'messages': [
              {'role': 'system', 'content': dieticianSystemPrompt},
              {
                'role': 'user',
                'content': prompt,
              },
            ],
            'model': 'openai',
            'response_format': {'type': 'json_object'}, // ✨ JSON MODE!
            'temperature': 1.0,
            'max_tokens': 2000,
          }),
        )
            .timeout(
          timeoutDuration,
          onTimeout: () {
            AppLogger.error(
                '⏱️ Pollinations AI timeout (Deneme $attempt/$maxRetries)');
            throw TimeoutException('API timeout', timeoutDuration);
          },
        );

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            final result = data['choices'][0]['message']['content'] as String;
            AppLogger.success(
                '✅ Pollinations AI planı başarıyla alındı (Deneme $attempt/$maxRetries)');
            return result;
          } catch (parseError) {
            AppLogger.error('❌ JSON parse hatası (Deneme $attempt/$maxRetries)',
                error: parseError);

            if (attempt < maxRetries) {
              final backoffSeconds = attempt * 5; // 3 → 5 saniye (daha uzun backoff)
              AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff)');
              await Future.delayed(Duration(seconds: backoffSeconds));
              continue;
            }
          }
        } else {
          AppLogger.warning(
              '⚠️ Pollinations AI hata: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)} (Deneme $attempt/$maxRetries)');

          if (attempt < maxRetries) {
            final backoffSeconds = attempt * 5; // 3 → 5 saniye
            AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff)');
            await Future.delayed(Duration(seconds: backoffSeconds));
            continue;
          }
        }
      } catch (e, stackTrace) {
        AppLogger.error(
            '❌ Pollinations AI hatası (Deneme $attempt/$maxRetries)',
            error: e,
            stackTrace: stackTrace);

        if (attempt < maxRetries) {
          final backoffSeconds = attempt * 8; // 5 → 8 saniye (daha agresif backoff)
          AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff - Critical Error)');
          await Future.delayed(Duration(seconds: backoffSeconds));
          continue;
        }
      }
    }

    AppLogger.error('❌ Pollinations AI: $maxRetries deneme başarısız!');
    return null;
  }

  /// 🔥 YENİ: Pollinations AI ile HAFTALIK plan al (7 gün tek seferde!)
  static Future<String?> getHaftalikFullPlan({
    required double gunlukKalori,
    required double gunlukProtein,
    required double gunlukKarb,
    required double gunlukYag,
  }) async {
    const maxRetries = 4; // 2 → 4 deneme (daha fazla şans)
    const timeoutDuration =
        Duration(seconds: 180); // 90 → 180 saniye (haftalık için çok daha uzun)

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        AppLogger.info(
            '🤖 Pollinations AI: HAFTALIK 7 GÜN plan alınıyor... (Deneme $attempt/$maxRetries)');

        final now = DateTime.now();
        final randomSeed =
            '${now.year}${now.month}${now.day}${now.hour}${now.minute}'
                    .hashCode
                    .abs() %
                999999;

        // 🔥 HAFTALIK PLAN PROMPT - 7 GÜN TURK MUTFAĞI - ULTRA NET FORMAT
        final prompt = '''
🎯 GÖREV: 7 GÜNLÜK BESLENME PLANI OLUŞTUR

📊 HER GÜN İÇİN HEDEF MAKROLAR:
- Kalori: ${gunlukKalori.toStringAsFixed(0)} kcal (±3%)
- Protein: ${gunlukProtein.toStringAsFixed(0)}g (±3%)
- Karbonhidrat: ${gunlukKarb.toStringAsFixed(0)}g (±5%)
- Yağ: ${gunlukYag.toStringAsFixed(0)}g (±5%)

⚠️ KRİTİK KURALLAR:
1. ZORUNLU: gun_1, gun_2, gun_3, gun_4, gun_5, gun_6, gun_7 anahtarları olmalı
2. ZORUNLU: Her gün 5 öğün (kahvalti, ara_ogun_1, ogle, ara_ogun_2, aksam)
3. ZORUNLU: Her gün FARKLI yemekler (7 gün boyunca hiç tekrar YOK!)
4. ZORUNLU: Sadece TÜRK MUTFAĞI yemekleri (Menemen, İzgara Tavuk, Köfte, vs.)

📋 JSON FORMAT (TAM OLARAK BU YAPIYI KULLAN):
{
  "gun_1": {
    "kahvalti": { "ad": "Menemen", "malzemeler": ["3 adet Yumurta", "1 adet Domates"], "kalori": 320, "protein": 22, "karbonhidrat": 18, "yag": 20 },
    "ara_ogun_1": { "ad": "Yoğurt ve Badem", "malzemeler": ["200g Süzme Yoğurt", "30g Badem"], "kalori": 280, "protein": 18, "karbonhidrat": 12, "yag": 18 },
    "ogle": { "ad": "Izgara Tavuk Pilavlı", "malzemeler": ["200g Tavuk Göğsü", "120g Pirinç Pilavı"], "kalori": 580, "protein": 65, "karbonhidrat": 52, "yag": 12 },
    "ara_ogun_2": { "ad": "Muz ve Fındık", "malzemeler": ["1 adet Orta Boy Muz", "20g Fındık"], "kalori": 220, "protein": 5, "karbonhidrat": 32, "yag": 12 },
    "aksam": { "ad": "Köfte ve Salata", "malzemeler": ["180g İzgara Köfte", "150g Mevsim Salata"], "kalori": 420, "protein": 48, "karbonhidrat": 15, "yag": 22 }
  },
  "gun_2": {
    "kahvalti": { "ad": "Omlet ve Peynir", ... },
    "ara_ogun_1": { "ad": "Elma ve Ceviz", ... },
    "ogle": { "ad": "Izgara Balık Bulgurlu", ... },
    "ara_ogun_2": { "ad": "Protein Bar", ... },
    "aksam": { "ad": "Fırın Tavuk Sebzeli", ... }
  },
  "gun_3": { 5 ÖĞÜN - HER ÖĞÜN FARKLI! },
  "gun_4": { 5 ÖĞÜN - HER ÖĞÜN FARKLI! },
  "gun_5": { 5 ÖĞÜN - HER ÖĞÜN FARKLI! },
  "gun_6": { 5 ÖĞÜN - HER ÖĞÜN FARKLI! },
  "gun_7": { 5 ÖĞÜN - HER ÖĞÜN FARKLI! }
}

🔥 ÇEŞİTLİLİK ZORUNLU: 7 gün boyunca hiçbir yemek tekrar ETMEMELİ!
Örnek: Gün 1'de Menemen varsa, Gün 2-7'de olmamalı.

🎲 Seed: $randomSeed

ŞİMDİ 7 GÜNLÜK PLANI JSON OLARAK OLUŞTUR (sadece JSON, başka hiçbir şey yazma):
''';

        final response = await http
            .post(
          Uri.parse(openaiEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'messages': [
              {'role': 'system', 'content': dieticianSystemPrompt},
              {
                'role': 'user',
                'content': prompt,
              },
            ],
            'model': 'openai',
            'response_format': {'type': 'json_object'}, // ✨ JSON MODE!
            'temperature': 1.0,
            'max_tokens': 4000, // Haftalık için daha fazla token
          }),
        )
            .timeout(
          timeoutDuration,
          onTimeout: () {
            AppLogger.error(
                '⏱️ Pollinations AI haftalık timeout (Deneme $attempt/$maxRetries)');
            throw TimeoutException('API timeout', timeoutDuration);
          },
        );

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            final result = data['choices'][0]['message']['content'] as String;
            AppLogger.success(
                '✅ Pollinations AI HAFTALIK planı başarıyla alındı (Deneme $attempt/$maxRetries)');
            return result;
          } catch (parseError) {
            AppLogger.error('❌ JSON parse hatası (Deneme $attempt/$maxRetries)',
                error: parseError);

            if (attempt < maxRetries) {
              final backoffSeconds = attempt * 6; // 3 → 6 saniye
              AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff)');
              await Future.delayed(Duration(seconds: backoffSeconds));
              continue;
            }
          }
        } else {
          AppLogger.warning(
              '⚠️ Pollinations AI hata: ${response.statusCode} (Deneme $attempt/$maxRetries)');

          if (attempt < maxRetries) {
            final backoffSeconds = attempt * 6; // 3 → 6 saniye
            AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff)');
            await Future.delayed(Duration(seconds: backoffSeconds));
            continue;
          }
        }
      } catch (e, stackTrace) {
        AppLogger.error(
            '❌ Pollinations AI haftalık hatası (Deneme $attempt/$maxRetries)',
            error: e,
            stackTrace: stackTrace);

        if (attempt < maxRetries) {
          final backoffSeconds = attempt * 10; // 5 → 10 saniye (haftalık için daha uzun)
          AppLogger.info('⏳ $backoffSeconds saniye bekleniyor... (Exponential backoff - Critical Error)');
          await Future.delayed(Duration(seconds: backoffSeconds));
          continue;
        }
      }
    }

    AppLogger.error(
        '❌ Pollinations AI: HAFTALIK plan $maxRetries deneme başarısız!');
    return null;
  }

  /// Basit GET endpoint (alternatif)
  static Future<String> getSimpleResponse(String prompt) async {
    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final response = await http.get(
        Uri.parse('$baseUrl/$encodedPrompt'),
      );

      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        AppLogger.error('❌ Simple API Error: ${response.statusCode}');
        return '❌ Yanıt alınamadı.';
      }
    } catch (e) {
      AppLogger.error('❌ Simple API Exception: $e');
      return '❌ Bir hata oluştu.';
    }
  }
}
