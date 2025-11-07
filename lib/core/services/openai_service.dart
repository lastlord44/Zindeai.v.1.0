// lib/core/services/openai_service.dart
// OpenAI API Service - Direkt OpenAI Entegrasyonu

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

/// OpenAI API Service
class OpenAIService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String chatEndpoint = '$baseUrl/chat/completions';
  
  // ⚠️ API KEY: Environment variable'dan al
  static String get apiKey {
    // TODO: .env dosyasından veya secure storage'dan al
    const key = String.fromEnvironment('OPENAI_API_KEY');
    if (key.isEmpty) {
      throw Exception('OPENAI_API_KEY environment variable boş!');
    }
    return key;
  }

  /// OpenAI ile günlük plan al (5 öğün)
  static Future<String?> getGunlukFullPlan({
    required double gunlukKalori,
    required double gunlukProtein,
    required double gunlukKarb,
    required double gunlukYag,
    Set<String>? excludedMeals,
  }) async {
    const maxRetries = 3;
    const timeoutDuration = Duration(seconds: 30);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        AppLogger.info('🤖 OpenAI: GÜNLÜK FULL plan alınıyor... (Deneme $attempt/$maxRetries)');

        final now = DateTime.now();
        final randomSeed = '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}'.hashCode.abs() % 999999;
        
        String excludedMealsPrompt = '';
        if (excludedMeals != null && excludedMeals.isNotEmpty) {
          final excludedList = excludedMeals.take(10).join(', ');
          excludedMealsPrompt = '🚫 BU YEMEKLER YASAKLI: $excludedList\n\n';
        }

        // 🔥 OPTİMİZE EDİLMİŞ PROMPT - Karbonhidrat vurgusu güçlü
        final prompt = '''$excludedMealsPrompt🚨 SEED #$randomSeed - HAYATI GÖREV!

📊 GÜNLÜK HEDEFLER (MUTLAKA ULAŞ!):
• Kalori: ${gunlukKalori.toStringAsFixed(0)} kcal
• Protein: ${gunlukProtein.toStringAsFixed(0)}g
• 🔥 KARBONHİDRAT: ${gunlukKarb.toStringAsFixed(0)}g ← EN KRİTİK!
• Yağ: ${gunlukYag.toStringAsFixed(0)}g

🚨 KARBONHİDRAT UYARISI:
${gunlukKarb.toStringAsFixed(0)}g karbonhidrata ULAŞMAZSAN BAŞARISIZLIK!

HER ÖĞÜNE BOL KARBONHİDRAT:
- Kahvaltı: 6-8 dilim ekmek + bal
- Ara öğün 1: Muz + granola
- Öğle: 200-250g pirinç/bulgur + ekmek
- Ara öğün 2: Meyve + bisküvi
- Akşam: 150-200g pirinç/bulgur + ekmek

📊 BESİN DEĞERLERİ (100g):
• Pirinç (pişmiş): 130 kcal, 3g P, 28g C
• Bulgur (pişmiş): 83 kcal, 3g P, 19g C
• Ekmek (1 dilim 35g): 92 kcal, 3g P, 17g C
• Tavuk göğsü: 165 kcal, 31g P, 0g C
• Yumurta (1 adet): 78 kcal, 6.5g P, 0.5g C
• Somon (100g): 206 kcal, 22g P, 0g C

ÖRNEKLER:
✅ "6 yumurta + 8 dilim ekmek + 250g pirinç"
❌ "2 yumurta + 2 dilim ekmek" (KARB ÇOK AZ!)

📋 JSON DÖNDÜR (5 öğün):
{
  "kahvalti": {
    "yemek_adi": "İsim",
    "malzemeler": ["...", "..."],
    "kalori": 650.2,
    "protein": 35.7,
    "karbonhidrat": 95.3,
    "yag": 18.4
  },
  "ara_ogun_1": {...},
  "ogle": {...},
  "ara_ogun_2": {...},
  "aksam": {...}
}

🔥 KONTROL: Toplam karbonhidrat ${gunlukKarb.toStringAsFixed(0)}g'a ulaştı mı?
SADECE JSON döndür!''';

        final response = await http.post(
          Uri.parse(chatEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: json.encode({
            'model': 'gpt-4o', // En iyi model
            'messages': [
              {
                'role': 'system',
                'content': 'Sen USDA/TurkDEP sertifikalı diyetisyensin. SADECE gerçek değerleri kullanırsın. ASLA tahmin yapmazsın.'
              },
              {
                'role': 'user',
                'content': prompt,
              },
            ],
            'temperature': 0.7,
            'max_tokens': 2000,
          }),
        ).timeout(
          timeoutDuration,
          onTimeout: () {
            AppLogger.error('⏱️ OpenAI timeout (Deneme $attempt/$maxRetries)');
            throw TimeoutException('API timeout', timeoutDuration);
          },
        );

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            final result = data['choices'][0]['message']['content'] as String;
            AppLogger.success('✅ OpenAI planı başarıyla alındı (Deneme $attempt/$maxRetries)');
            return result;
          } catch (parseError) {
            AppLogger.error('❌ JSON parse hatası (Deneme $attempt/$maxRetries)', error: parseError);
            
            if (attempt < maxRetries) {
              await Future.delayed(Duration(seconds: attempt * 2));
              continue;
            }
          }
        } else {
          AppLogger.warning('⚠️ OpenAI hata: ${response.statusCode} (Deneme $attempt/$maxRetries)');
          
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
        }
        
      } catch (e, stackTrace) {
        AppLogger.error('❌ OpenAI hatası (Deneme $attempt/$maxRetries)', error: e, stackTrace: stackTrace);
        
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }
      }
    }
    
    AppLogger.error('❌ OpenAI: $maxRetries deneme başarısız!');
    return null;
  }
}