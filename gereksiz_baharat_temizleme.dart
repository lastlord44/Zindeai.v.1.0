import 'package:zinde_ai/data/local/hive_service.dart';
import 'package:zinde_ai/data/models/yemek_hive_model.dart';
import 'package:zinde_ai/core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  AppLogger.init(level: LogLevel.debug);
  
  // Hive'ı başlatmak için geçici bir yol kullanıyoruz, çünkü bu bir script.
  // Gerçek uygulama yolunuza göre bunu ayarlamanız gerekebilir.
  await HiveService.init(path: './');

  final yemekBox = Hive.box<YemekHiveModel>('yemekler');
  if (yemekBox.isEmpty) {
    AppLogger.error('Yemek kutusu boş. Migration çalıştırılmamış olabilir.');
    return;
  }

  AppLogger.info('🧹 Baharat ve garnitür temizleme işlemi başlıyor...');
  AppLogger.info('Toplam ${yemekBox.length} yemek kontrol edilecek.');

  final baharatlar = ['tuz', 'karabiber', 'pul biber', 'nane', 'kekik', 'kimyon', 'fesleğen', 'limon', 'sumak', 'defne', 'su', 'sirke', 'maydanoz', 'dereotu', 'roka'];
  int temizlenenYemekSayisi = 0;
  int silinenMalzemeSayisi = 0;

  final Map<String, YemekHiveModel> guncellenecekYemekler = {};

  for (var yemek in yemekBox.values) {
    final orijinalMalzemeler = List<String>.from(yemek.ingredients ?? []);
    final yeniMalzemeler = (yemek.ingredients ?? [])
        .where((malzeme) => !baharatlar.any((baharat) => malzeme.toLowerCase().contains(baharat)))
        .toList();

    if (orijinalMalzemeler.length != yeniMalzemeler.length) {
      temizlenenYemekSayisi++;
      silinenMalzemeSayisi += (orijinalMalzemeler.length - yeniMalzemeler.length);
      
      AppLogger.debug('🗑️ Temizleniyor: ${yemek.mealName}');
      AppLogger.debug('   - ESKİ: ${orijinalMalzemeler.join(" | ")}');
      AppLogger.debug('   - YENİ: ${yeniMalzemeler.join(" | ")}');
      
      final guncelYemek = YemekHiveModel(
        // Mevcut yemeğin tüm alanlarını kopyala
        mealId: yemek.mealId,
        mealName: yemek.mealName,
        category: yemek.category,
        calorie: yemek.calorie,         // Düzeltildi: calories -> calorie
        proteinG: yemek.proteinG,       // Düzeltildi: protein -> proteinG
        carbG: yemek.carbG,             // Düzeltildi: carbohydrates -> carbG
        fatG: yemek.fatG,               // Düzeltildi: fat -> fatG
        fiberG: yemek.fiberG,           // Eklendi
        goalTag: yemek.goalTag,         // Eklendi
        difficulty: yemek.difficulty,
        prepTimeMin: yemek.prepTimeMin, // Düzeltildi: preparationTime -> prepTimeMin
        recipe: yemek.recipe,           // Eklendi
        imageUrl: yemek.imageUrl,       // Eklendi
        tags: yemek.tags,               // Eklendi
        alternatives: yemek.alternatives, // Eklendi
        isFavorite: yemek.isFavorite,
        proteinSource: yemek.proteinSource,
        
        // Sadece malzemeler listesini güncelle
        ingredients: yeniMalzemeler,
      );
      guncellenecekYemekler[yemek.mealId!] = guncelYemek;
    }
  }

  for (var entry in guncellenecekYemekler.entries) {
    await yemekBox.put(entry.key, entry.value);
  }

  AppLogger.success('✨ TEMİZLİK TAMAMLANDI! ✨');
  AppLogger.info('------------------------------------');
  AppLogger.info('📊 Toplam $temizlenenYemekSayisi yemek güncellendi.');
  AppLogger.info('🗑️ Toplam $silinenMalzemeSayisi adet gereksiz malzeme silindi.');
  AppLogger.info('------------------------------------');

  await Hive.close();
}
