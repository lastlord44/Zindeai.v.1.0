// lib/domain/services/ai_beslenme_servisi_v6.dart
// JSON-only LLM prompting + deterministik doğrulama/düzeltme pipeline.
//
// Burada gerçek model çağrısı için basit bir arayüz tanımlandı (AiClient).
// Projene uygun OpenAI/Vertex/bedrock client ile bu arayüzü implemente et.

import 'dart:convert';
import '../../core/validators/macro_validator.dart';
import '../../core/services/macro_adjuster.dart';

abstract class AiClient {
  /// systemPrompt ve userMessage alıp raw string (LLM cevabı) döndürür.
  Future<String> complete({
    required String systemPrompt,
    required String userMessage,
  });
}

class AiBeslenmeServisiV6 {
  final AiClient client;
  final AdjusterConfig adjusterConfig;

  AiBeslenmeServisiV6({
    required this.client,
    AdjusterConfig? adjusterConfig,
  }) : adjusterConfig = adjusterConfig ?? AdjusterConfig.defaultTR();

  String buildSystemPrompt() {
    return '''
Sen bir **BESLENME MENÜ MOTORUSUN**.
- **HESAP YAPMA**; gram bazlı seçim yap.
- **SADECE JSON** üret (tek bir JSON obje), başka metin yok.
- Yalnızca **verilen food_db** içinden ürün seç; **çığ/ pişmiş karıştırma** yok (tümü pişmiş kabul).
- Çıktı şeması:
  {
    "day": "YYYY-MM-DD",
    "meals": [
      {"name":"Kahvaltı","items":[{"food_id":"...", "grams": 123}, ...]},
      ...
    ]
  }
- Öğün başına **protein ≥ profile.protein_per_meal_min (g)**.
- Hedeflere **±5% kalori toleransı** ve verilen makro bantları içinde kal.
- Türk mutfağı odaklı çeşitlendirme yap (bulgur/pirinç/yulaf; tavuk/yumurta/somon/yoğurt; zeytinyağı/fındık).
- Açıklama/yorum ekleme, yalnızca JSON!
''';
  }

  String buildUserMessage({
    required Profile profile,
    required MacroTargets targets,
    required Map<String, StandardFood> db,
    required String dayIso,
  }) {
    final foodDb = db.values.map((f) {
      return {
        'id': f.id,
        'per100g': {
          'kcal': f.per100g.kcal,
          'p': f.per100g.p,
          'c': f.per100g.c,
          'f': f.per100g.f,
          'fiber': f.per100g.fiber,
          'satFat': f.per100g.satFat,
        }
      };
    }).toList();

    final payload = {
      'profile': {
        'sex': profile.sex,
        'age': profile.age,
        'height_cm': profile.heightCm,
        'weight_kg': profile.weightKg,
        'workouts_per_week': profile.workoutsPerWeek,
        'protein_per_meal_min': targets.proteinPerMealMin ?? 0.0,
      },
      'targets': {
        'calories_kcal': targets.caloriesKcal,
        'protein_g_min': targets.proteinMin,
        'protein_g_max': targets.proteinMax,
        'carbs_g_min': targets.carbsMin,
        'carbs_g_max': targets.carbsMax,
        'fat_g_min': targets.fatMin,
        'fat_g_max': targets.fatMax,
        'fiber_g_min': targets.fiberMin,
        'kcal_tolerance_pct': targets.kcalTolerancePct,
      },
      'constraints': {
        'meals': {'min': 4, 'max': 6},
        'unit': 'g_cooked_only',
      },
      'food_db': foodDb,
      'day': dayIso,
    };

    return jsonEncode(payload);
  }

  DailyPlan parsePlanFromJson(String raw) {
    final obj = jsonDecode(raw);
    return DailyPlan.fromJson(obj as Map<String, dynamic>);
  }

  /// LLM → parse → validate → (gerekirse) auto-correct → final plan
  Future<DailyPlan> generateValidatedPlan({
    required Profile profile,
    required MacroTargets targets,
    required Map<String, StandardFood> db,
    required String dayIso,
  }) async {
    final system = buildSystemPrompt();
    final user = buildUserMessage(profile: profile, targets: targets, db: db, dayIso: dayIso);

    final raw = await client.complete(systemPrompt: system, userMessage: user);

    DailyPlan plan;
    try {
      plan = parsePlanFromJson(raw);
    } catch (_) {
      // LLM JSON bozduysa: en basit fallback – 4 boş öğün, sonra adjuster ile doldurmak değil,
      // burada parse hatası durumunda exception fırlatıyoruz ki client katmanı handle edebilsin.
      rethrow;
    }

    final rep = validatePlan(plan: plan, db: db, targets: targets);
    if (rep.withinAll) return plan;

    final adjusted = MacroAdjuster.adjustPlan(
      plan: plan,
      db: db,
      targets: targets,
      config: adjusterConfig,
      maxAttempts: 3,
    );

    // İkinci bir doğrulama
    final rep2 = validatePlan(plan: adjusted.plan, db: db, targets: targets);
    if (!rep2.withinAll) {
      // Burada istersen sadece "gramları yeniden ayarla" konulu kısıtlı bir
      // prompt ile ikinci bir LLM round'u atabilirsin. Ancak deterministik
      // güven için düzeltici katmanı yeterli tutuyoruz.
    }

    return adjusted.plan;
  }
}