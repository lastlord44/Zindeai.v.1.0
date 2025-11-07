import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 TEKRAR EDEN YEMEKLERİ TEMİZLEME\n');
  
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
    
    // Benzersiz yemekleri tut (ilk görüleni tut, diğerlerini sil)
    final seenNames = <String>{};
    final uniqueData = <dynamic>[];
    
    for (final yemek in data) {
      final name = yemek['meal_name'] as String;
      if (!seenNames.contains(name)) {
        seenNames.add(name);
        uniqueData.add(yemek);
      }
    }
    
    print('$file: ${onceki - uniqueData.length} duplicate silindi (${onceki} → ${uniqueData.length})');
    
    // meal_id'leri yeniden numaralandır
    for (int i = 0; i < uniqueData.length; i++) {
      final prefix = file.contains('kahvalti') ? 'kah' :
                    file.contains('ara_ogun_1') ? 'ara1' :
                    file.contains('ogle') ? 'ogle' :
                    file.contains('ara_ogun_2') ? 'ara2' : 'aksam';
      uniqueData[i]['meal_id'] = '${prefix}_${(i + 1).toString().padLeft(3, '0')}';
    }
    
    await f.writeAsString(JsonEncoder.withIndent('  ').convert(uniqueData));
  }
  
  print('\n✅ Tüm duplicate\'ler temizlendi!');
  print('\n📊 Yeni yemek sayısını kontrol et:');
  print('dart scripts/check_meal_counts.dart');
}