import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 YEMEK KONTROLÜ VE DÜZELTİLMESİ\n');
  
  // 1. Batı/yabancı besinleri tespit et ve temizle
  await removeForeignFoods();
  
  // 2. Tekrar eden yemekleri tespit et
  await findDuplicates();
  
  // 3. 1 haftalık plan simülasyonu (7 gün × 5 öğün = 35 yemek)
  await simulateWeeklyPlan();
}

Future<void> removeForeignFoods() async {
  print('📊 Batı/yabancı besinler temizleniyor...\n');
  
  final yabanci = ['tempeh', 'tofu', 'somon', 'quinoa', 'açai', 'acai', 'chia'];
  
  final files = [
    'kahvalti_saglikli_150.json',
    'ara_ogun_1_saglikli_150.json',
    'ogle_yemegi_saglikli_150.json',
    'ara_ogun_2_saglikli_150.json',
    'aksam_yemegi_saglikli_150.json',
  ];
  
  for (final file in files) {
    final path = 'assets/data/$file';
    final f = File(path);
    if (!await f.exists()) continue;
    
    final content = await f.readAsString();
    List<dynamic> data = json.decode(content);
    final onceki = data.length;
    
    // Yabancı besin içeren yemekleri filtrele
    data = data.where((yemek) {
      final name = (yemek['meal_name'] ?? '').toString().toLowerCase();
      final malzemeler = (yemek['malzemeler'] as List?)?.join(' ').toLowerCase() ?? '';
      
      for (final y in yabanci) {
        if (name.contains(y) || malzemeler.contains(y)) {
          return false; // Bu yemeği çıkar
        }
      }
      return true; // Bu yemeği koru
    }).toList();
    
    if (onceki != data.length) {
      print('$file: ${onceki - data.length} yabancı yemek temizlendi');
      await f.writeAsString(JsonEncoder.withIndent('  ').convert(data));
    }
  }
  
  print('');
}

Future<void> findDuplicates() async {
  print('📊 Tekrar eden yemekler kontrol ediliyor...\n');
  
  final files = {
    'Kahvaltı': 'kahvalti_saglikli_150.json',
    'Ara Öğün 1': 'ara_ogun_1_saglikli_150.json',
    'Öğle': 'ogle_yemegi_saglikli_150.json',
    'Ara Öğün 2': 'ara_ogun_2_saglikli_150.json',
    'Akşam': 'aksam_yemegi_saglikli_150.json',
  };
  
  for (final entry in files.entries) {
    final kategori = entry.key;
    final file = entry.value;
    final path = 'assets/data/$file';
    final f = File(path);
    if (!await f.exists()) continue;
    
    final content = await f.readAsString();
    List<dynamic> data = json.decode(content);
    
    // Aynı meal_name olan yemekleri bul
    final names = <String, int>{};
    for (final yemek in data) {
      final name = yemek['meal_name'] as String;
      names[name] = (names[name] ?? 0) + 1;
    }
    
    final duplicates = names.entries.where((e) => e.value > 1).toList();
    if (duplicates.isNotEmpty) {
      print('$kategori: ${duplicates.length} farklı yemek tekrar ediyor:');
      for (final d in duplicates.take(5)) {
        print('  "${d.key}": ${d.value} kez');
      }
      print('');
    } else {
      print('$kategori: ✅ Tüm yemekler benzersiz');
    }
  }
  
  print('');
}

Future<void> simulateWeeklyPlan() async {
  print('📊 1 Haftalık Plan Simülasyonu (7 gün × 5 öğün = 35 yemek)\n');
  
  final files = [
    'kahvalti_saglikli_150.json',
    'ara_ogun_1_saglikli_150.json',
    'ogle_yemegi_saglikli_150.json',
    'ara_ogun_2_saglikli_150.json',
    'aksam_yemegi_saglikli_150.json',
  ];
  
  // Her öğün için ilk 7 yemeği al (1 hafta için)
  for (int gun = 1; gun <= 7; gun++) {
    print('GÜN $gun:');
    
    for (final file in files) {
      final path = 'assets/data/$file';
      final f = File(path);
      if (!await f.exists()) continue;
      
      final content = await f.readAsString();
      List<dynamic> data = json.decode(content);
      
      if (data.length > gun - 1) {
        final yemek = data[gun - 1];
        final ogun = file.contains('kahvalti') ? 'Kahvaltı' :
                    file.contains('ara_ogun_1') ? 'Ara 1' :
                    file.contains('ogle') ? 'Öğle' :
                    file.contains('ara_ogun_2') ? 'Ara 2' : 'Akşam';
        print('  $ogun: ${yemek['meal_name']}');
      }
    }
    print('');
  }
  
  print('\n✅ 7 günlük plan simüle edildi - herhangi bir yemek tekrar ediyor mu kontrol et!');
}