import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:zinde_ai/data/models/yemek_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SeedLoader {
  static const _path = 'assets/seeds/yemekler_core.json';

  static Future<void> loadCoreSeeds() async {
    AppLogger.info('🌱 Çekirdek veri tohumlama işlemi başlıyor...');
    try {
      final yemekBox = await Hive.openBox<YemekHiveModel>('yemekler');
      if (yemekBox.isNotEmpty) {
        AppLogger.warning('⚠️ "yemekler" kutusu zaten dolu. Tohumlama atlandı.');
        return;
      }

      final raw = await rootBundle.loadString(_path);
      final List<dynamic> list = jsonDecode(raw);
      int successCount = 0;

      for (final m in list) {
        if (!_isValid(m)) {
          AppLogger.error('❌ Geçersiz tohum verisi: ${m['id'] ?? 'ID YOK'}');
          continue;
        }

        final malzemeList = (m['malzemeler'] as List<dynamic>).cast<String>();
        final temizMalzemeler = _sanitizeIngredients(malzemeList);
        if (temizMalzemeler == null) {
          AppLogger.error('❌ Kritik malzeme hatası: ${m['id']} - ${m['ad']}');
          continue;
        }

        final model = YemekHiveModel.fromJson(m);
        await yemekBox.put(model.mealId, model);
        successCount++;
      }
      AppLogger.success('✅ $successCount adet çekirdek yemek başarıyla yüklendi.');
    } catch (e) {
      AppLogger.error('❌ Çekirdek veri yüklenirken kritik hata: $e');
    }
  }

  static bool _isValid(Map m) {
    final req = ['id','ad','kalori','proteinG','carbG','fatG','malzemeler'];
    for (final k in req) {
      if (!m.containsKey(k)) return false;
    }
    if (m['kalori'] <= 0) return false;
    return true;
  }

  static List<String>? _sanitizeIngredients(List<String> items) {
    final out = <String>[];

    for (final s in items) {
      final low = s.toLowerCase();

      if (low.contains('yumurta') && RegExp(r'\((?:\d+)\s*(g|ml)\)').hasMatch(low)) {
        return null;
      }

      if (!RegExp(r'\([\d.,]+\s*[a-zA-ZğüşıöçĞÜŞIÖÇ]+\)').hasMatch(s) && !low.contains('tutam') && !low.contains('dal')) {
         // Birimi olmayan ama izin verilenler (tutam, dal) dışındakileri reddet
        if(!low.contains('maydanoz') && !low.contains('tuz') && !low.contains('limon suyu')){
           return null;
        }
      }

      final m = RegExp(r'\((\d+)\s*(g|gr|gram|ml|mililitre|cc|kg|l|lt|litre)\)').firstMatch(low);
      if (m != null) {
        final numStr = m.group(1)!;
        final unit = m.group(2)!;
        final val = double.tryParse(numStr.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
        if (unit.startsWith('kg') && val > 1.0) return null;
        if ((unit == 'g' || unit == 'gr' || unit == 'gram') && val > 500) return null;
        if ((unit == 'ml' || unit == 'mililitre' || unit == 'cc') && val > 500) return null;
      }

      out.add(s);
    }
    return out;
  }
}
