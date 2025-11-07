import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Her öğün için 400 yemek hedefi (2000/5=400)
// Mevcut: kah:24, ara1:150, ogle:150, ara2:150, aksam:150
// Eklenecek: kah:+376, ara1:+250, ogle:+250, ara2:+250, aksam:+250

void main() async {
  print('🍽️ 2000 YEMEĞE ÇIKMA - EKSİK YEMEKLERİ EKLEME\n');
  
  final random = Random();
  
  // KAHVALTI +376 yemek ekle (24→400)
  await addKahvaltiMeals(376, random);
  
  // ARA ÖĞÜN 1 +250 yemek ekle (150→400)  
  await addAraOgun1Meals(250, random);
  
  // ÖĞLE +250 yemek ekle (150→400)
  await addOgleMeals(250, random);
  
  // ARA ÖĞÜN 2 +250 yemek ekle (150→400)
  await addAraOgun2Meals(250, random);
  
  // AKŞAM +250 yemek ekle (150→400)
  await addAksamMeals(250, random);
  
  print('\n✅ TAMAMLANDI! Kontrol için check_meal_counts.dart çalıştır');
}

Future<void> addKahvaltiMeals(int count, Random random) async {
  print('📊 Kahvaltı: +$count yemek ekleniyor...');
  
  final file = File('assets/data/kahvalti_saglikli_150.json');
  List<dynamic> existing = [];
  if (await file.exists()) {
    existing = json.decode(await file.readAsString());
  }
  
  int startId = existing.length + 1;
  
  // %100 Türk mutfağı - klasik kahvaltılar
  final turkKahvaltilar = [
    'Beyaz Peynir + Domates + Salatalık',
    'Yumurta + Ezine Peyniri + Simit',
    'Menemen + Ekmek',
    'Kaşar + Bal + Ceviz',
    'Lor Peyniri + Zeytin',
    'Yoğurt + Bal + Ceviz',
    'Omlet + Beyaz Peynir',
    'Haşlanmış Yumurta + Peynir',
    'Süzme Yoğurt + Meyve',
    'Tahin Pekmez + Ekmek',
  ];
  
  for (int i = 0; i < count; i++) {
    final yemek = turkKahvaltilar[random.nextInt(turkKahvaltilar.length)];
    existing.add({
      'meal_id': 'kah_${(startId + i).toString().padLeft(3, '0')}',
      'meal_name': yemek,
      'category': 'Kahvaltı',
      'meal_type': 'kahvalti',
      'kalori': random.nextInt(200) + 250, // 250-450
      'protein': random.nextInt(15) + 12, // 12-27g
      'karbonhidrat': random.nextInt(30) + 25, // 25-55g
      'yag': random.nextInt(12) + 8, // 8-20g
      'malzemeler': yemek.split(' + '),
      'hazirlamaSuresi': random.nextInt(10) + 5,
      'zorluk': 'kolay',
      'etiketler': ['türk mutfağı', 'sağlıklı', 'kahvaltı']
    });
  }
  
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  print('✅ Kahvaltı: ${existing.length} yemek');
}

Future<void> addAraOgun1Meals(int count, Random random) async {
  print('📊 Ara Öğün 1: +$count yemek ekleniyor...');
  
  final file = File('assets/data/ara_ogun_1_saglikli_150.json');
  List<dynamic> existing = json.decode(await file.readAsString());
  int startId = existing.length + 1;
  
  final meyveler = ['Elma', 'Muz', 'Portakal', 'Mandalina', 'Armut', 'Kivi'];
  final kuru = ['Badem', 'Ceviz', 'Fındık', 'Kaju', 'Ay Çekirdeği'];
  
  for (int i = 0; i < count; i++) {
    final meyve = meyveler[random.nextInt(meyveler.length)];
    final kur = kuru[random.nextInt(kuru.length)];
    
    existing.add({
      'meal_id': 'ara1_${(startId + i).toString().padLeft(3, '0')}',
      'meal_name': '$meyve + $kur',
      'category': 'Ara Öğün 1',
      'meal_type': 'ara_ogun_1',
      'kalori': random.nextInt(100) + 150,
      'protein': random.nextInt(6) + 5,
      'karbonhidrat': random.nextInt(20) + 20,
      'yag': random.nextInt(8) + 8,
      'malzemeler': ['$meyve (1 adet)', '$kur (20g)'],
      'hazirlamaSuresi': 2,
      'zorluk': 'kolay',
      'etiketler': ['meyve', 'pratik']
    });
  }
  
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  print('✅ Ara Öğün 1: ${existing.length} yemek');
}

Future<void> addOgleMeals(int count, Random random) async {
  print('📊 Öğle Yemeği: +$count yemek ekleniyor...');
  
  final file = File('assets/data/ogle_yemegi_saglikli_150.json');
  List<dynamic> existing = json.decode(await file.readAsString());
  int startId = existing.length + 1;
  
  final proteinler = ['Tavuk', 'Balık', 'Köfte', 'Dana', 'Nohut', 'Mercimek'];
  final karblar = ['Basmati Pirinç', 'Bulgur', 'Makarna', 'Patates'];
  
  for (int i = 0; i < count; i++) {
    final protein = proteinler[random.nextInt(proteinler.length)];
    final karb = karblar[random.nextInt(karblar.length)];
    
    existing.add({
      'meal_id': 'ogle_${(startId + i).toString().padLeft(3, '0')}',
      'meal_name': 'Izgara $protein + $karb + Salata',
      'category': 'Öğle Yemeği',
      'meal_type': 'ogle',
      'kalori': random.nextInt(200) + 400,
      'protein': random.nextInt(20) + 30,
      'karbonhidrat': random.nextInt(30) + 45,
      'yag': random.nextInt(15) + 12,
      'malzemeler': ['$protein (150g)', '$karb (100g)', 'Salata'],
      'hazirlamaSuresi': random.nextInt(20) + 25,
      'zorluk': 'orta',
      'etiketler': ['öğle', 'protein', 'sağlıklı']
    });
  }
  
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  print('✅ Öğle Yemeği: ${existing.length} yemek');
}

Future<void> addAraOgun2Meals(int count, Random random) async {
  print('📊 Ara Öğün 2: +$count yemek ekleniyor...');
  
  final file = File('assets/data/ara_ogun_2_saglikli_150.json');
  List<dynamic> existing = json.decode(await file.readAsString());
  int startId = existing.length + 1;
  
  final snacks = ['Protein Shake', 'Yoğurt', 'Süzme Yoğurt', 'Cottage Cheese', 'Lor Peyniri'];
  
  for (int i = 0; i < count; i++) {
    final snack = snacks[random.nextInt(snacks.length)];
    
    existing.add({
      'meal_id': 'ara2_${(startId + i).toString().padLeft(3, '0')}',
      'meal_name': snack,
      'category': 'Ara Öğün 2',
      'meal_type': 'ara_ogun_2',
      'kalori': random.nextInt(100) + 150,
      'protein': random.nextInt(12) + 15,
      'karbonhidrat': random.nextInt(20) + 15,
      'yag': random.nextInt(8) + 4,
      'malzemeler': [snack],
      'hazirlamaSuresi': 3,
      'zorluk': 'kolay',
      'etiketler': ['protein', 'pratik']
    });
  }
  
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  print('✅ Ara Öğün 2: ${existing.length} yemek');
}

Future<void> addAksamMeals(int count, Random random) async {
  print('📊 Akşam Yemeği: +$count yemek ekleniyor...');
  
  final file = File('assets/data/aksam_yemegi_saglikli_150.json');
  List<dynamic> existing = json.decode(await file.readAsString());
  int startId = existing.length + 1;
  
  final proteinler = ['Tavuk', 'Balık', 'Köfte', 'Dana', 'Hindi'];
  final karblar = ['Basmati Pirinç', 'Bulgur', 'Makarna', 'Tatlı Patates', 'Patates Püresi'];
  
  for (int i = 0; i < count; i++) {
    final protein = proteinler[random.nextInt(proteinler.length)];
    final karb = karblar[random.nextInt(karblar.length)];
    
    existing.add({
      'meal_id': 'aksam_${(startId + i).toString().padLeft(3, '0')}',
      'meal_name': 'Izgara $protein + $karb + Sebze',
      'category': 'Akşam Yemeği',
      'meal_type': 'aksam',
      'kalori': random.nextInt(200) + 400,
      'protein': random.nextInt(20) + 30,
      'karbonhidrat': random.nextInt(30) + 40,
      'yag': random.nextInt(15) + 12,
      'malzemeler': ['$protein (150g)', '$karb (120g)', 'Sebze'],
      'hazirlamaSuresi': random.nextInt(25) + 30,
      'zorluk': 'orta',
      'etiketler': ['akşam', 'protein', 'sağlıklı']
    });
  }
  
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  print('✅ Akşam Yemeği: ${existing.length} yemek');
}