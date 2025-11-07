import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

// Proje modellerini import et
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/models/kullanici_hive_model.dart';
import 'lib/data/models/gunluk_plan_hive_model.dart';
import 'lib/domain/entities/hedef.dart';

// Bu script, GPT-5 tarafından oluşturulan JSON verilerini okur ve Hive veritabanına migrate eder.
// KULLANIM: dart run migration_gpt5_final.dart

Future<void> main() async {
  print('🚀 GPT-5 Veritabanı Migration Başlatılıyor...');

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

    // 2. Mevcut Veritabanını Temizle
    print('🧹 Mevcut veritabanı temizleniyor...');
    await Hive.deleteBoxFromDisk('kullanici');
    await Hive.deleteBoxFromDisk('yemek');
    await Hive.deleteBoxFromDisk('planlar');
    await Hive.deleteBoxFromDisk('favori_yemekler');
    await Hive.deleteBoxFromDisk('cesitlilik_gecmis');
    print('✅ Tüm eski veriler silindi.');

    // 3. Box'ları Aç
    final kullaniciBox = await Hive.openBox<KullaniciHiveModel>('kullanici');
    final yemekBox = await Hive.openBox<YemekHiveModel>('yemek');
    print('✅ Hive kutuları (box) açıldı.');

    // JSON dosyalarının bulunduğu dizin
    final jsonDir = Directory(p.join(scriptDir, '../gpt5.pro.yemekler'));
    if (!await jsonDir.exists()) {
      print('❌ HATA: JSON dizini bulunamadı: ${jsonDir.path}');
      return;
    }
    print('📂 JSON kaynak dizini bulundu: ${jsonDir.path}');

    // 4. Kullanıcı Profillerini Yükle
    int profilSayac = 0;
    final profillerFile = File(p.join(jsonDir.path, 'kullanici_profilleri.json'));
    if (await profillerFile.exists()) {
      print('👤 Kullanıcı profilleri yükleniyor...');
      final profillerString = await profillerFile.readAsString();
      final List<dynamic> profillerJson = jsonDecode(profillerString);

      for (var profilJson in profillerJson) {
        try {
          // JSON'dan KullaniciHiveModel'e manuel dönüşüm
          final model = KullaniciHiveModel(
            id: profilJson['id']?.toString(),
            ad: profilJson['ad']?.toString(),
            yas: profilJson['yas'] as int?,
            boy: (profilJson['boy'] as num?)?.toDouble(),
            mevcutKilo: (profilJson['mevcutKilo'] as num?)?.toDouble(),
            hedefKilo: (profilJson['hedefKilo'] as num?)?.toDouble(),
            cinsiyet: profilJson['cinsiyet']?.toString(),
            aktiviteSeviyesi: profilJson['aktiviteSeviyesi']?.toString(),
            hedef: profilJson['hedef']?.toString(),
            kayitTarihi: DateTime.tryParse(profilJson['kayitTarihi'] ?? ''),
            // Prompt'tan kaldırılan alanlar için varsayılan değerler
            soyad: '',
            diyetTipi: DiyetTipi.normal.name,
            manuelAlerjiler: [],
          );
          await kullaniciBox.put(model.id, model);
          profilSayac++;
        } catch (e) {
          print('❌ Profil parse hatası: $profilJson -> $e');
        }
      }
      print('✅ $profilSayac adet kullanıcı profili başarıyla Hive\'a eklendi.');
    } else {
      print('⚠️ UYARI: kullanici_profilleri.json bulunamadı. Profiller yüklenmedi.');
    }

    // 5. Yemekleri Yükle
    int yemekSayac = 0;
    int dosyaSayac = 0;
    final yemekDosyalari = jsonDir.listSync()
      .where((f) => f is File && p.basename(f.path).startsWith('yemekler_'))
      .map((f) => f as File)
      .toList();
      
    yemekDosyalari.sort((a, b) => a.path.compareTo(b.path)); // Dosyaları sırala

    print('🍲 ${yemekDosyalari.length} adet yemek dosyası bulundu. Yükleme başlıyor...');

    for (final file in yemekDosyalari) {
      dosyaSayac++;
      print('  -> Dosya ${dosyaSayac}/${yemekDosyalari.length}: ${p.basename(file.path)} okunuyor...');
      final yemeklerString = await file.readAsString();
      final List<dynamic> yemeklerJson = jsonDecode(yemeklerString);

      for (var yemekJson in yemeklerJson) {
        try {
          // YemekHiveModel.fromJson kullanarak otomatik dönüşüm
          final model = YemekHiveModel.fromJson(yemekJson as Map<String, dynamic>);
          await yemekBox.put(model.mealId, model);
          yemekSayac++;
        } catch (e) {
          print('❌ Yemek parse hatası: $yemekJson -> $e');
        }
      }
    }
    print('✅ Toplam $yemekSayac adet yemek başarıyla Hive\'a eklendi.');

    // 6. Sonuç
    print('\n🎉 MIGRATION TAMAMLANDI! 🎉');
    print('---------------------------------');
    print('📊 Veritabanı Özeti:');
    print('  - Kullanıcı Profilleri: ${kullaniciBox.length}');
    print('  - Yemekler: ${yemekBox.length}');
    print('---------------------------------');

  } catch (e, stackTrace) {
    print('\n❌ KRİTİK HATA: Migration sırasında beklenmedik bir sorun oluştu.');
    print(e);
    print(stackTrace);
  } finally {
    await Hive.close();
    print('🚪 Hive bağlantısı kapatıldı. Script sonlandırıldı.');
  }
}
