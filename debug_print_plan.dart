import 'dart:io';
import 'dart:convert'; // JSON decode için eklendi
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

// Proje modellerini import et
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/domain/entities/yemek.dart'; // For OgunTipi enum

// Bu script, belirtilen tarih için Hive'da kayıtlı olan günlük planı okur ve detaylarını yazdırır.
// KULLANIM: dart run debug_print_plan.dart

void printMealDetails(String mealName, String? mealJson) {
  if (mealJson == null || mealJson.isEmpty) {
    print('$mealName: (Boş)');
    print('---');
    return;
  }
  try {
    final Map<String, dynamic> jsonMap = json.decode(mealJson);
    final meal = YemekHiveModel.fromJson(jsonMap);

    print('$mealName: ${meal.mealName}');
    print('  - Kalori: ${meal.calorie?.toStringAsFixed(1)} kcal');
    print('  - Protein: ${meal.proteinG?.toStringAsFixed(1)} g');
    print('  - Karbonhidrat: ${meal.carbG?.toStringAsFixed(1)} g');
    print('  - Yağ: ${meal.fatG?.toStringAsFixed(1)} g');
    print('  - Malzemeler:');
    meal.ingredients?.forEach((ing) => print('    - $ing'));
    print('---');
  } catch (e) {
    print('$mealName: (JSON Parse Hatası: $e)');
    print('---');
  }
}

double _calculateTotal(GunlukPlanHiveModel plan, String Function(YemekHiveModel) getter) {
  double total = 0;
  final meals = [
    plan.kahvaltiJson,
    plan.araOgun1Json,
    plan.ogleYemegiJson,
    plan.araOgun2Json,
    plan.aksamYemegiJson,
    plan.geceAtistirmaJson,
  ];
  for (var mealJson in meals) {
    if (mealJson != null && mealJson.isNotEmpty) {
      try {
        final meal = YemekHiveModel.fromJson(json.decode(mealJson));
        total += double.tryParse(getter(meal)) ?? 0.0;
      } catch (e) {
        // ignore
      }
    }
  }
  return total;
}


Future<void> main() async {
  print('🔍 Kayıtlı planı okuma scripti başlatılıyor...');

  try {
    // 1. Hive'ı Başlat
    final scriptDir = p.dirname(Platform.script.toFilePath());
    Hive.init(p.join(scriptDir, 'hive_data'));

    // Hive Adaptörlerini Kaydet
    if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
      Hive.registerAdapter(KullaniciHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
      Hive.registerAdapter(GunlukPlanHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    print('✅ Hive adaptörleri başarıyla kaydedildi.');

    // 2. Planlar Box'ını Aç
    final planBox = await Hive.openBox<GunlukPlanHiveModel>('planlar');
    print('✅ Planlar kutusu (box) açıldı.');

    // 3. Belirtilen Tarih İçin Planı Oku
    final targetDate = DateTime(2025, 11, 6);
    // ID'yi manuel olarak oluştur (GunlukPlan entity'sindeki mantığa göre)
    final planId = 'plan_${targetDate.toIso8601String().substring(0, 10)}';
    GunlukPlanHiveModel? plan;
    try {
      plan = planBox.values.firstWhere((p) => p.tarih.year == targetDate.year && p.tarih.month == targetDate.month && p.tarih.day == targetDate.day);
    } catch (e) {
      plan = null;
    }


    if (plan == null) {
      print('❌ HATA: ${targetDate.toIso8601String().substring(0, 10)} tarihi için kayıtlı plan bulunamadı.');
    } else {
      print('\n\n--- 📅 GÜNLÜK PLAN DETAYLARI (${plan.id}) ---\n');
      
      printMealDetails('🍳 Kahvaltı', plan.kahvaltiJson);
      printMealDetails('🍎 Ara Öğün 1', plan.araOgun1Json);
      printMealDetails('🍽️ Öğle Yemeği', plan.ogleYemegiJson);
      printMealDetails('🥤 Ara Öğün 2', plan.araOgun2Json);
      printMealDetails('🌙 Akşam Yemeği', plan.aksamYemegiJson);
      printMealDetails('🌃 Gece Atıştırma', plan.geceAtistirmaJson);

      // Makroları manuel olarak hesapla
      final toplamKalori = _calculateTotal(plan, (m) => m.calorie.toString());
      final toplamProtein = _calculateTotal(plan, (m) => m.proteinG.toString());
      final toplamKarb = _calculateTotal(plan, (m) => m.carbG.toString());
      final toplamYag = _calculateTotal(plan, (m) => m.fatG.toString());

      print('📊 TOPLAM MAKROLAR (Hesaplanan):');
      print('  - Kalori: ${toplamKalori.toStringAsFixed(1)} kcal');
      print('  - Protein: ${toplamProtein.toStringAsFixed(1)} g');
      print('  - Karbonhidrat: ${toplamKarb.toStringAsFixed(1)} g');
      print('  - Yağ: ${toplamYag.toStringAsFixed(1)} g');
      print('\n--- PLAN DETAYLARI SONU ---');
    }

  } catch (e, stackTrace) {
    print('\n❌ KRİTİK HATA: Script sırasında beklenmedik bir sorun oluştu.');
    print(e);
    print(stackTrace);
  } finally {
    await Hive.close();
    print('\n🚪 Hive bağlantısı kapatıldı. Script sonlandırıldı.');
  }
}
