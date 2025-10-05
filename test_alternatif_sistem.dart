import 'lib/domain/services/alternatif_oneri_servisi.dart';

void main() {
  print('========================================');
  print('ALTERNATİF BESİN SİSTEMİ - KAPSAMLI TEST');
  print('========================================');
  print('');

  // TEST 1: Kuruyemiş (13 adet fındık)
  print('TEST 1: 13 adet fındık');
  print('Beklenen: ~8 adet badem (107 kcal)');
  var sonuc1 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Fındık',
    miktar: 13,
    birim: 'adet',
  );
  print('Gerçek: ${sonuc1.isNotEmpty ? "${sonuc1[0].miktar.toStringAsFixed(0)} ${sonuc1[0].birim} ${sonuc1[0].ad} (${sonuc1[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 2: Kuruyemiş (10 adet badem)
  print('TEST 2: 10 adet badem');
  print('Beklenen: ~16 adet fındık (134 kcal)');
  var sonuc2 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Badem',
    miktar: 10,
    birim: 'adet',
  );
  print('Gerçek: ${sonuc2.isNotEmpty ? "${sonuc2[0].miktar.toStringAsFixed(0)} ${sonuc2[0].birim} ${sonuc2[0].ad} (${sonuc2[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 3: Meyve (1 adet muz)
  print('TEST 3: 1 adet muz');
  print('Beklenen: 1 adet elma (95 kcal)');
  var sonuc3 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Muz',
    miktar: 1,
    birim: 'adet',
  );
  print('Gerçek: ${sonuc3.isNotEmpty ? "${sonuc3[0].miktar.toStringAsFixed(0)} ${sonuc3[0].birim} ${sonuc3[0].ad} (${sonuc3[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 4: Meyve (1 adet elma)
  print('TEST 4: 1 adet elma');
  print('Beklenen: 1 adet muz (105 kcal)');
  var sonuc4 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Elma',
    miktar: 1,
    birim: 'adet',
  );
  print('Gerçek: ${sonuc4.isNotEmpty ? "${sonuc4[0].miktar.toStringAsFixed(0)} ${sonuc4[0].birim} ${sonuc4[0].ad} (${sonuc4[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 5: Süt ürünü (200 ml süt) - KRİTİK!
  print('TEST 5: 200 ml süt - KRİTİK!');
  print('Beklenen: 140 gram yoğurt (83 kcal)');
  var sonuc5 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Süt',
    miktar: 200,
    birim: 'ml',
  );
  print('Gerçek: ${sonuc5.isNotEmpty ? "${sonuc5[0].miktar.toStringAsFixed(0)} ${sonuc5[0].birim} ${sonuc5[0].ad} (${sonuc5[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 6: Süt ürünü (170 gram yoğurt)
  print('TEST 6: 170 gram yoğurt');
  print('Beklenen: 240 ml süt (101 kcal)');
  var sonuc6 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Yoğurt',
    miktar: 170,
    birim: 'gram',
  );
  print('Gerçek: ${sonuc6.isNotEmpty ? "${sonuc6[0].miktar.toStringAsFixed(0)} ${sonuc6[0].birim} ${sonuc6[0].ad} (${sonuc6[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 7: Protein (150 gram hindi) - KRİTİK!
  print('TEST 7: 150 gram hindi - KRİTİK!');
  print('Beklenen: 120 gram tavuk (198 kcal)');
  var sonuc7 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Hindi',
    miktar: 150,
    birim: 'gram',
  );
  print('Gerçek: ${sonuc7.isNotEmpty ? "${sonuc7[0].miktar.toStringAsFixed(0)} ${sonuc7[0].birim} ${sonuc7[0].ad} (${sonuc7[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  // TEST 8: Protein (85 gram tavuk)
  print('TEST 8: 85 gram tavuk');
  print('Beklenen: 100 gram hindi (135 kcal)');
  var sonuc8 = AlternatifOneriServisi.otomatikAlternatifUret(
    besinAdi: 'Tavuk',
    miktar: 85,
    birim: 'gram',
  );
  print('Gerçek: ${sonuc8.isNotEmpty ? "${sonuc8[0].miktar.toStringAsFixed(0)} ${sonuc8[0].birim} ${sonuc8[0].ad} (${sonuc8[0].kalori.toStringAsFixed(1)} kcal)" : "ALTERNATİF YOK"}');
  print('');

  print('========================================');
  print('TEST TAMAMLANDI');
  print('========================================');
}
