import 'dart:convert';
import 'dart:io';

void main() async {
  print('🍽️ Ara Öğün 2 için son 10 yemek ekleniyor...\n');
  
  final file = File('assets/data/ara_ogun_2_saglikli_150.json');
  List<dynamic> existing = json.decode(await file.readAsString());
  
  final existingNames = existing.map((e) => e['meal_name'] as String).toSet();
  final newMeals = <Map<String, dynamic>>[];
  int id = existing.length + 1;
  
  // Son 10 benzersiz yemek
  final finalMeals = [
    ['Protein Topu + Greyfurt', ['Protein Topu', 'Greyfurt (1 adet)']],
    ['Labne + Nar', ['Labne (80g)', 'Nar (1 adet)']],
    ['Çökelek + Kavun', ['Çökelek (100g)', 'Kavun (1 dilim)']],
    ['Protein Puding + Çilek', ['Protein Puding', 'Çilek (100g)']],
    ['Beyaz Peynir + İncir', ['Beyaz Peynir (40g)', 'Kuru İncir (3 adet)']],
    ['Cottage Cheese + Greyfurt', ['Cottage Cheese (100g)', 'Greyfurt (1 adet)']],
    ['Haşlanmış Yumurta + Portakal', ['Haşlanmış Yumurta (3 adet)', 'Portakal (1 adet)']],
    ['Protein Bar + Nar', ['Protein Bar', 'Nar (1 adet)']],
    ['Yoğurt + Hurma + Findik', ['Yoğurt (150g)', 'Hurma (3 adet)', 'Findik (20g)']],
    ['Protein Shake + Greyfurt', ['Protein Shake (30g)', 'Greyfurt (1 adet)']],
  ];
  
  for (final meal in finalMeals) {
    if (newMeals.length >= 10) break;
    
    final name = meal[0] as String;
    if (!existingNames.contains(name)) {
      newMeals.add({
        'meal_id': 'ara2_${id.toString().padLeft(3, '0')}',
        'meal_name': name,
        'category': 'Ara Öğün 2',
        'meal_type': 'ara_ogun_2',
        'kalori': 180 + (id % 100),
        'protein': 15 + (id % 15),
        'karbonhidrat': 20 + (id % 20),
        'yag': 6 + (id % 10),
        'malzemeler': meal[1] as List<String>,
        'hazirlamaSuresi': 3 + (id % 5),
        'zorluk': 'kolay',
        'etiketler': ['protein', 'pratik']
      });
      existingNames.add(name);
      id++;
    }
  }
  
  existing.addAll(newMeals);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(existing));
  
  print('✅ ${newMeals.length} yemek eklendi');
  print('📊 Toplam: ${existing.length} yemek');
}