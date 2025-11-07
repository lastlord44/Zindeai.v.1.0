import 'dart:convert';
import 'dart:io';

void main() async {
  final files = [
    'kahvalti_saglikli_150.json',
    'ara_ogun_1_saglikli_150.json',
    'ogle_yemegi_saglikli_150.json',
    'ara_ogun_2_saglikli_150.json',
    'aksam_yemegi_saglikli_150.json',
  ];
  
  int total = 0;
  
  print('📊 MEVCUT YEMEK SAYILARI:\n');
  
  for (final file in files) {
    final path = 'assets/data/$file';
    final f = File(path);
    if (await f.exists()) {
      final content = await f.readAsString();
      final List<dynamic> data = json.decode(content);
      print('$file: ${data.length} yemek');
      total += data.length;
    } else {
      print('$file: BULUNAMADI');
    }
  }
  
  print('\n📊 TOPLAM: $total yemek');
  print('🎯 HEDEF: 2000 yemek');
  print('➕ EKSİK: ${2000 - total} yemek');
}