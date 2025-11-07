// ============================================================================
// MEGA YEMEK VERİTABANI OLUŞTURUCU - FİNAL SÜRÜM
// AMAÇ: Programatik olarak binlerce sağlıklı, ekonomik ve pratik Türk yemeği üretmek
//       ve doğrudan Hive veritabanına kaydetmek.
// ÇALIŞTIRMA: dart run scripts/mega_yemek_db_generator.dart
// ============================================================================

import 'dart:io';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

// Proje dosyalarını import etmek için yolu ayarlıyoruz.
// Bu script proje kök dizininden çalıştırılmalıdır.
import '../lib/domain/entities/yemek.dart';
import '../lib/data/models/yemek_hive_model.dart';
// 🔥 Hata: HiveService, Flutter'a bağımlı olduğu için (hive_flutter), saf Dart script'inde kullanılamaz.
// import '../lib/data/local/hive_service.dart';

// ============================================================================
// YASAKLI ÜRÜNLER LİSTESİ (KARA LİSTE)
// ============================================================================
const Set<String> ZARARLI_MALZEMELER = {
  'salam', 'sosis', 'sucuk', 'pastırma', 'işlenmiş et',
  'beyaz un', 'beyaz ekmek', 'beyaz pirinç', 'makarna (beyaz un)',
  'şeker', 'glikoz şurubu', 'fruktoz şurubu', 'mısır şurubu',
  'margarin', 'trans yağ', 'palm yağı',
  'hazır çorba', 'bulyon', 'hazır sos',
  'krem şanti', 'hazır puding',
  'gazlı içecek', 'kolalı içecek', 'enerji içeceği',
  'cips', 'patates kızartması',
  'pizza', 'hamburger (fast food)',
  'şekerleme', 'gofret', 'çikolata (sütlü)',
};

// ============================================================================
// SAĞLIKLI TÜRK MUTFAĞI BİLEŞENLERİ
// ============================================================================
const List<String> PROTEIN_KAYNAKLARI = [
  'Tavuk Göğsü', 'Tavuk But', 'Hindi Göğsü', 'Dana Kıyma (yağsız)', 'Dana Kuşbaşı',
  'Mercimek (kırmızı)', 'Mercimek (yeşil)', 'Nohut', 'Fasulye (kuru)', 'Yumurta',
  'Süzme Yoğurt', 'Yoğurt', 'Lor Peyniri', 'Beyaz Peynir', 'Somon', 'Levrek',
  'Çipura', 'Hamsi', 'Ton Balığı (suda)',
];
const List<String> KARBONHIDRAT_KAYNAKLARI = [
  'Bulgur', 'Karabuğday (greçka)', 'Kinoa', 'Tam Buğday Ekmeği', 'Yulaf Ekmeği',
  'Çavdar Ekmeği', 'Yulaf Ezmesi', 'Patates (haşlama/fırın)', 'Tatlı Patates',
  'Mısır (haşlama)', 'Esmer Pirinç',
];
const List<String> SEBZE_KAYNAKLARI = [
  'Domates', 'Salatalık', 'Biber (yeşil/kırmızı)', 'Soğan', 'Sarımsak', 'Marul',
  'Roka', 'Maydanoz', 'Dereotu', 'Nane', 'Ispanak', 'Pazı', 'Brokoli',
  'Karnabahar', 'Patlıcan', 'Kabak', 'Havuç', 'Turp', 'Lahana (beyaz/kırmızı)', 'Mantar',
];
const List<String> SAGLIKLI_YAG_KAYNAKLARI = [
  'Zeytinyağı', 'Ceviz', 'Badem', 'Fındık', 'Avokado', 'Zeytin', 'Tahin',
];
const List<String> MEYVE_KAYNAKLARI = [
  'Elma', 'Armut', 'Muz', 'Portakal', 'Çilek', 'Böğürtlen', 'Ahududu',
  'Karpuz', 'Kavun', 'Erik', 'Kayısı', 'Şeftali',
];

// ============================================================================
// MAKRO HESAPLAMA MOTORU (AIBeslenmeServisi'nden adapte edildi)
// ============================================================================
class MakroMotoru {
  static Map<String, double> _besin100gDegerleri(String besinAdi) {
    final adLower = besinAdi.toLowerCase();
    if (adLower.contains('tavuk göğ')) return {'kalori': 165, 'protein': 31, 'karb': 0, 'yag': 3.6};
    if (adLower.contains('tavuk')) return {'kalori': 190, 'protein': 29, 'karb': 0, 'yag': 7.4};
    if (adLower.contains('hindi')) return {'kalori': 189, 'protein': 29, 'karb': 0, 'yag': 7};
    if (adLower.contains('dana')) return {'kalori': 250, 'protein': 26, 'karb': 0, 'yag': 15};
    if (adLower.contains('mercimek')) return {'kalori': 116, 'protein': 9, 'karb': 20, 'yag': 0.4};
    if (adLower.contains('nohut')) return {'kalori': 139, 'protein': 8, 'karb': 27, 'yag': 2.1};
    if (adLower.contains('fasulye')) return {'kalori': 127, 'protein': 8, 'karb': 22, 'yag': 0.5};
    if (adLower.contains('yumurta')) return {'kalori': 155, 'protein': 13, 'karb': 1.1, 'yag': 11};
    if (adLower.contains('süzme yoğurt')) return {'kalori': 60, 'protein': 10, 'karb': 4, 'yag': 0.4};
    if (adLower.contains('yoğurt')) return {'kalori': 61, 'protein': 3.5, 'karb': 4.7, 'yag': 3.3};
    if (adLower.contains('lor peyniri')) return {'kalori': 98, 'protein': 11, 'karb': 5, 'yag': 4};
    if (adLower.contains('beyaz peynir')) return {'kalori': 270, 'protein': 18, 'karb': 3, 'yag': 21};
    if (adLower.contains('somon')) return {'kalori': 206, 'protein': 22, 'karb': 0, 'yag': 13};
    if (adLower.contains('levrek') || adLower.contains('çipura') || adLower.contains('hamsi')) return {'kalori': 97, 'protein': 18, 'karb': 0, 'yag': 2.0};
    if (adLower.contains('ton balığı (suda)')) return {'kalori': 116, 'protein': 26, 'karb': 0, 'yag': 1};
    if (adLower.contains('bulgur')) return {'kalori': 342, 'protein': 12, 'karb': 76, 'yag': 1.3};
    if (adLower.contains('karabuğday')) return {'kalori': 343, 'protein': 13, 'karb': 72, 'yag': 3.4};
    if (adLower.contains('kinoa')) return {'kalori': 368, 'protein': 14, 'karb': 64, 'yag': 6};
    if (adLower.contains('ekmek')) return {'kalori': 265, 'protein': 9, 'karb': 49, 'yag': 3.2};
    if (adLower.contains('yulaf')) return {'kalori': 389, 'protein': 17, 'karb': 66, 'yag': 7};
    if (adLower.contains('patates')) return {'kalori': 77, 'protein': 2, 'karb': 17, 'yag': 0.1};
    if (adLower.contains('esmer pirinç')) return {'kalori': 111, 'protein': 2.6, 'karb': 23, 'yag': 0.9};
    if (adLower.contains('domates') || adLower.contains('salatalık') || adLower.contains('biber') || adLower.contains('ıspanak') || adLower.contains('marul')) return {'kalori': 20, 'protein': 1, 'karb': 4, 'yag': 0.2};
    if (adLower.contains('zeytinyağı')) return {'kalori': 884, 'protein': 0, 'karb': 0, 'yag': 100};
    if (adLower.contains('ceviz') || adLower.contains('badem') || adLower.contains('fındık')) return {'kalori': 600, 'protein': 15, 'karb': 20, 'yag': 55};
    if (adLower.contains('elma') || adLower.contains('armut')) return {'kalori': 55, 'protein': 0.3, 'karb': 14, 'yag': 0.2};
    if (adLower.contains('muz')) return {'kalori': 89, 'protein': 1.1, 'karb': 23, 'yag': 0.3};
    return {'kalori': 100, 'protein': 10, 'karb': 10, 'yag': 3}; // Fallback
  }

  static Map<String, double> gercekMakroHesapla(List<String> malzemeler) {
    double toplamKalori = 0.0, toplamProtein = 0.0, toplamKarb = 0.0, toplamYag = 0.0;
    for (final malzeme in malzemeler) {
      final malzemeLower = malzeme.toLowerCase();
      double miktar = 100;
      final parantezRegex = RegExp(r'\((\d+)\s*g\)$');
      var match = parantezRegex.firstMatch(malzeme);
      if (match != null) {
        miktar = double.tryParse(match.group(1)!) ?? 100;
      }
      final besinDegerleri = _besin100gDegerleri(malzemeLower);
      final carpan = miktar / 100.0;
      toplamKalori += besinDegerleri['kalori']! * carpan;
      toplamProtein += besinDegerleri['protein']! * carpan;
      toplamKarb += besinDegerleri['karb']! * carpan;
      toplamYag += besinDegerleri['yag']! * carpan;
    }
    return {'kalori': toplamKalori, 'protein': toplamProtein, 'karb': toplamKarb, 'yag': toplamYag};
  }
}

// ============================================================================
// YEMEK ÜRETİM MOTORU
// ============================================================================
class MegaYemekGenerator {
  final Random _random = Random();
  final Uuid _uuid = Uuid();
  int _uretilenYemekSayisi = 0;

  Future<void> generateAndSave(int hedefSayi) async {
    print("🔥 Mega Yemek Veritabanı Oluşturucu Başlatılıyor...");
    print("🎯 Hedef: $hedefSayi adet yeni yemek üretilecek.");

    // Öğünlere göre üretim yüzdeleri
    final Map<OgunTipi, double> ogunYuzdeleri = {
      OgunTipi.kahvalti: 0.15,
      OgunTipi.ogle: 0.30,
      OgunTipi.aksam: 0.30,
      OgunTipi.araOgun1: 0.125,
      OgunTipi.araOgun2: 0.125,
    };

    for (final entry in ogunYuzdeleri.entries) {
      final ogun = entry.key;
      final ogunHedefSayi = (hedefSayi * entry.value).round();
      print("\n--- ${ogun.ad} için $ogunHedefSayi adet yemek üretiliyor ---");

      for (int i = 0; i < ogunHedefSayi; i++) {
        Yemek? yeniYemek;
        switch (ogun) {
          case OgunTipi.kahvalti:
            yeniYemek = _generateKahvalti();
            break;
          case OgunTipi.ogle:
          case OgunTipi.aksam:
            yeniYemek = _generateAnaOgun(ogun);
            break;
          case OgunTipi.araOgun1:
          case OgunTipi.araOgun2:
            yeniYemek = _generateAraOgun(ogun);
            break;
          default:
            break;
        }

        if (yeniYemek != null) {
          final box = Hive.box<YemekHiveModel>('yemekler');
          final model = YemekHiveModel.fromEntity(yeniYemek);
          // 🔥 FIX: HiveService yerine doğrudan box'a yaz.
          await box.put(model.mealId, model);
          _uretilenYemekSayisi++;
          stdout.write("\r✅ Üretilen Toplam Yemek: $_uretilenYemekSayisi / $hedefSayi");
        }
      }
    }
    print("\n\n🎉 Üretim tamamlandı! Toplam $_uretilenYemekSayisi adet yemek Hive'a kaydedildi.");
  }

  Yemek _generateAnaOgun(OgunTipi ogun) {
    final protein = PROTEIN_KAYNAKLARI[_random.nextInt(PROTEIN_KAYNAKLARI.length)];
    final karb = KARBONHIDRAT_KAYNAKLARI[_random.nextInt(KARBONHIDRAT_KAYNAKLARI.length)];
    final sebze1 = SEBZE_KAYNAKLARI[_random.nextInt(SEBZE_KAYNAKLARI.length)];
    final sebze2 = SEBZE_KAYNAKLARI[_random.nextInt(SEBZE_KAYNAKLARI.length)];
    final yag = SAGLIKLI_YAG_KAYNAKLARI[_random.nextInt(SAGLIKLI_YAG_KAYNAKLARI.length)];

    final pMiktar = 120 + _random.nextInt(6) * 10; // 120-170g
    final kMiktar = 70 + _random.nextInt(4) * 10;  // 70-100g
    final sMiktar = 80 + _random.nextInt(5) * 10;  // 80-120g
    final yMiktar = 5 + _random.nextInt(6);        // 5-10g

    final malzemeler = [
      '$protein (${pMiktar}g)',
      '$karb (${kMiktar}g)',
      '$sebze1 (${sMiktar ~/ 2}g)',
      '$sebze2 (${sMiktar ~/ 2}g)',
      '$yag (${yMiktar}g)',
    ];

    final makrolar = MakroMotoru.gercekMakroHesapla(malzemeler);
    final ad = "Fırında $protein, $karb ve $sebze1 Salatası";

    return Yemek(
      id: _uuid.v4(),
      ad: ad,
      ogun: ogun,
      kalori: makrolar['kalori']!,
      protein: makrolar['protein']!,
      karbonhidrat: makrolar['karb']!,
      yag: makrolar['yag']!,
      malzemeler: malzemeler,
      hazirlamaSuresi: 20 + _random.nextInt(21), // 20-40 dk
      zorluk: Zorluk.values[_random.nextInt(Zorluk.values.length)],
      etiketler: ['sağlıklı', 'türk mutfağı', 'ekonomik'],
      proteinKaynagi: protein,
    );
  }

  Yemek _generateKahvalti() {
    final protein = ['Yumurta', 'Lor Peyniri', 'Beyaz Peynir', 'Süzme Yoğurt'][_random.nextInt(4)];
    final karb = ['Yulaf Ezmesi', 'Tam Buğday Ekmeği'][_random.nextInt(2)];
    final yag = ['Ceviz', 'Badem', 'Zeytin', 'Avokado'][_random.nextInt(4)];
    final sebze = ['Domates', 'Salatalık', 'Roka', 'Biber (yeşil/kırmızı)'][_random.nextInt(4)];

    final pMiktar = (protein == 'Yumurta') ? 100 : (60 + _random.nextInt(5) * 10); // 2 yumurta veya 60-100g peynir
    final kMiktar = (karb == 'Yulaf Ezmesi') ? 50 : 60; // 50g yulaf veya 2 dilim ekmek
    final yMiktar = 15 + _random.nextInt(16); // 15-30g
    final sMiktar = 80 + _random.nextInt(5) * 10; // 80-120g

    final malzemeler = [
      '$protein (${pMiktar}g)',
      '$karb (${kMiktar}g)',
      '$yag (${yMiktar}g)',
      '$sebze (${sMiktar}g)',
    ];

    final makrolar = MakroMotoru.gercekMakroHesapla(malzemeler);
    final ad = "$protein ve $yag ile $karb Kahvaltısı";

    return Yemek(
      id: _uuid.v4(),
      ad: ad,
      ogun: OgunTipi.kahvalti,
      kalori: makrolar['kalori']!,
      protein: makrolar['protein']!,
      karbonhidrat: makrolar['karb']!,
      yag: makrolar['yag']!,
      malzemeler: malzemeler,
      hazirlamaSuresi: 10 + _random.nextInt(11), // 10-20 dk
      zorluk: Zorluk.kolay,
      etiketler: ['sağlıklı', 'pratik', 'kahvaltı'],
      proteinKaynagi: protein,
    );
  }

  Yemek _generateAraOgun(OgunTipi ogun) {
    final anaMalzeme = ['Süzme Yoğurt', 'Elma', 'Muz', 'Badem', 'Ceviz'][_random.nextInt(5)];
    final ekMalzeme = MEYVE_KAYNAKLARI[_random.nextInt(MEYVE_KAYNAKLARI.length)];
    
    final anaMiktar = 100 + _random.nextInt(6) * 10; // 100-150g
    final ekMiktar = 50 + _random.nextInt(6) * 10; // 50-100g

    final malzemeler = [
      '$anaMalzeme (${anaMiktar}g)',
      '$ekMalzeme (${ekMiktar}g)',
    ];

    final makrolar = MakroMotoru.gercekMakroHesapla(malzemeler);
    final ad = "$anaMalzeme ve $ekMalzeme";

    return Yemek(
      id: _uuid.v4(),
      ad: ad,
      ogun: ogun,
      kalori: makrolar['kalori']!,
      protein: makrolar['protein']!,
      karbonhidrat: makrolar['karb']!,
      yag: makrolar['yag']!,
      malzemeler: malzemeler,
      hazirlamaSuresi: 5,
      zorluk: Zorluk.kolay,
      etiketler: ['sağlıklı', 'ara öğün', 'pratik'],
      proteinKaynagi: anaMalzeme.contains('Yoğurt') ? 'Süt Ürünü' : 'Kuruyemiş/Meyve',
    );
  }
}

// ============================================================================
// ANA ÇALIŞTIRMA FONKSİYONU
// ============================================================================
Future<void> main(List<String> args) async {
  // Komut satırından hedef sayıyı al, yoksa varsayılan olarak 4000 kullan
  final hedefSayi = (args.isNotEmpty && int.tryParse(args[0]) != null) ? int.parse(args[0]) : 4000;

  // Hive'ı bağımsız bir script olarak başlat
  final scriptPath = Platform.script.toFilePath();
  final projectRoot = path.dirname(path.dirname(scriptPath));
  final hivePath = path.join(projectRoot, 'hive_data');
  
  try {
    Hive.init(hivePath);
    print("Hive veritabanı yolu: $hivePath");
  } catch (e) {
    print("Hive zaten başlatılmış olabilir, devam ediliyor...");
  }

  // Adapter'ları kaydet
  if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
    Hive.registerAdapter(YemekHiveModelAdapter());
  }
  // 🔥 FIX: Bu script sadece Yemek modeli ile ilgilenir, diğer adapter'lara gerek yok.
  /*
  if (!Hive.isAdapterRegistered(GunlukPlanHiveModelAdapter().typeId)) {
    Hive.registerAdapter(GunlukPlanHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(KullaniciHiveModelAdapter().typeId)) {
    Hive.registerAdapter(KullaniciHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TamamlananAntrenmanHiveModelAdapter().typeId)) {
    Hive.registerAdapter(TamamlananAntrenmanHiveModelAdapter());
  }
  */

  // Box'ları aç
  if (!Hive.isBoxOpen('yemekler')) {
    await Hive.openBox<YemekHiveModel>('yemekler');
  }

  final generator = MegaYemekGenerator();
  await generator.generateAndSave(hedefSayi);

  // Hive'ı kapat
  await Hive.close();
  print("✅ Hive bağlantısı kapatıldı.");
}
