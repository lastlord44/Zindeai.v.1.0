// lib/core/services/pollinations_ai_service.dart
// Pollinations.ai API Service - FREE AI Chat Integration

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/hedef.dart';

/// Pollinations AI Kategorileri
enum AICategory {
  supplement, // Supplement danışmanlığı
  nutrition, // Beslenme danışmanlığı
  training, // Antrenman danışmanlığı
  general, // Genel sağlık
}

/// Pollinations AI Service
class PollinationsAIService {
  static const String baseUrl = 'https://text.pollinations.ai';
  static const String openaiEndpoint = '$baseUrl/openai';

  /// Kategori bazlı sistem promptları
  static final Map<AICategory, String> systemPrompts = {
    AICategory.supplement: '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi spor beslenme ve supplement uzmanısın. Adın Dr. Ahmet Yılmaz.

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

    AICategory.nutrition: '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi diyetisyenlerinden birisin. Adın Uzm. Dyt. Ayşe Demir.

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

    AICategory.training: '''Sen 30 yıllık deneyime sahip, Türkiye'nin en iyi fitness antrenörlerinden birisin. Adın Hakan Kaya.

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

    AICategory.general: '''Sen 30 yıllık deneyime sahip, genel sağlık ve wellness uzmanısın. Adın Dr. Zeynep Aydın.

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
  };

  /// Kategori ikonları
  static final Map<AICategory, String> categoryEmojis = {
    AICategory.supplement: '💊',
    AICategory.nutrition: '🥗',
    AICategory.training: '💪',
    AICategory.general: '🏥',
  };

  /// AI'dan yanıt al (OpenAI uyumlu endpoint)
  static Future<String> getResponse({
    required String userMessage,
    required AICategory category,
    List<Map<String, String>>? conversationHistory,
    KullaniciProfili? userProfile,
  }) async {
    try {
      AppLogger.info('🤖 AI Request: $userMessage (Category: ${category.name})');

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
          'temperature': 1.0, // API sadece varsayılan değer olan 1.0'ı destekliyor
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        
        AppLogger.success('✅ AI Response received: ${aiResponse.substring(0, 50)}...');
        return aiResponse.trim();
      } else {
        AppLogger.error('❌ AI API Error: ${response.statusCode} - ${response.body}');
        return '❌ Üzgünüm, şu anda yanıt veremiyorum. Lütfen tekrar dene.';
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ AI Service Exception', error: e, stackTrace: stackTrace);
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
      case Hedef.kiloVer:
        return 'Kilo Vermek';
      case Hedef.kiloAl:
        return 'Kilo Almak';
      case Hedef.formdaKal:
        return 'Formda Kalmak';
      case Hedef.kasKazanKiloAl:
        return 'Kas Kazanıp Kilo Almak';
      case Hedef.kasKazanKiloVer:
        return 'Kas Kazanıp Kilo Vermek';
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
      case AktiviteSeviyesi.ekstraAktif:
        return 'Ekstra Aktif (Günde 2 antrenman)';
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
