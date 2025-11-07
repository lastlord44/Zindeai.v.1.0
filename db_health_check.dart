import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';

// Bu script, Hive'daki yemek veritabanını tarar ve makro değerleri
// (kalori, protein, karb, yağ) sıfır veya null olan yemekleri tespit eder ve siler.
// KULLANIM: dart run db_health_check.dart

Future<void> main() async {
  print('🩺 Veritabanı Sağlık Kontrolü Başlatılıyor...');

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

    // 2. Yemekler Box'ını Aç
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemek');
    print('✅ Yemekler kutusu (box) açıldı. Toplam ${yemekBox.length} yemek var.');

    final List<String> silinecekAnahtarlar = [];
    int hataliYemekSayisi = 0;

    print('\n🔍 Hatalı makro değerlerine sahip yemekler taranıyor...');

    for (var key in yemekBox.keys) {
      final yemek = yemekBox.get(key);
      if (yemek != null) {
        final bool kaloriHatali = (yemek.calorie ?? 0.0) <= 0.0;
        final bool proteinHatali = (yemek.proteinG ?? 0.0) <= 0.0;
        final bool karbHatali = (yemek.carbG ?? 0.0) <= 0.0;
        final bool yagHatali = (yemek.fatG ?? 0.0) <= 0.0;

        // Eğer ana makrolardan en az biri sıfırsa, hatalı kabul et
        if (kaloriHatali && proteinHatali && karbHatali && yagHatali) {
          hataliYemekSayisi++;
          print('  - ❗ Hatalı Bulundu: ID=${yemek.mealId}, Ad=${yemek.mealName}');
          print('    (Kalori: ${yemek.calorie}, Protein: ${yemek.proteinG}, Karb: ${yemek.carbG}, Yağ: ${yemek.fatG})');
          silinecekAnahtarlar.add(key);
        }
      }
    }

    if (silinecekAnahtarlar.isEmpty) {
      print('\n✅ Sağlık kontrolü tamamlandı. Hatalı makro değerine sahip yemek bulunamadı.');
    } else {
      print('\n🗑️ Toplam $hataliYemekSayisi adet hatalı yemek bulundu ve siliniyor...');
      await yemekBox.deleteAll(silinecekAnahtarlar);
      print('✅ Hatalı yemekler başarıyla veritabanından silindi.');
    }

    // --- Belirli Bir Yemeği Kontrol Et ---
    print('\n🕵️  "Ton Balıklı Yoğurtlu Salata" yemeği aranıyor...');
    bool bulundu = false;
    for (var key in yemekBox.keys) {
      final yemek = yemekBox.get(key);
      if (yemek != null && yemek.mealName == 'Ton Balıklı Yoğurtlu Salata') {
        print('  - ✅ BULUNDU: ID=${yemek.mealId}, Ad=${yemek.mealName}');
        print('    (DB\'deki ORİJİNAL Değerler) -> Kalori: ${yemek.calorie}, Protein: ${yemek.proteinG}, Karb: ${yemek.carbG}, Yağ: ${yemek.fatG}');
        bulundu = true;
        break; // İlk bulduğumuzda duralım
      }
    }
    if (!bulundu) {
      print('  - ❌ "Ton Balıklı Yoğurtlu Salata" veritabanında bulunamadı.');
    }
    // --- Kontrol Sonu ---

    print('\n📊 Veritabanı Son Durumu:');
    print('  - Toplam Yemek: ${yemekBox.length}');

  } catch (e, stackTrace) {
    print('\n❌ KRİTİK HATA: Script sırasında beklenmedik bir sorun oluştu.');
    print(e);
    print(stackTrace);
  } finally {
    await Hive.close();
    print('\n🚪 Hive bağlantısı kapatıldı. Script sonlandırıldı.');
  }
}
