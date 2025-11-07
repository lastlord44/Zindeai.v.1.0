import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧹 TÜM YABANCI BESİNLERİ VE BOZUK MALZEMELERİ TEMİZLİYORUM\n');
  
  // YASAK KELİMELER - Batı/Yabancı besinler
  final yasaklar = [
    'tempeh', 'tempah', 'tofu', 'somon', 'salmon',
    'quinoa', 'kinoa', 'açai', 'acai', 'chia',
    'kale', 'edamame', 'hummus', 'falafel',
    'varyasyon', 'variation', // Bozuk isimler
  ];
  
  final files = [
    'kahvalti_saglikli_150.json',
    'ara_ogun_1_saglikli_150.json',
    'ogle_yemegi_saglikli_150.json',
    'ara_ogun_2_saglikli_150.json',
    'aksam_yemegi_saglikli_150.json',
  ];
  
  int toplamSilinen = 0;
  
  for (final file in files) {
    final path = 'assets/data/$file';
    final f = File(path);
    if (!await f.exists()) continue;
    
    print('📂 $file işleniyor...');
    
    final content = await f.readAsString();
    List<dynamic> data = json.decode(content);
    final onceki = data.length;
    
    // Yabancı besin ve bozuk malzeme içerenleri filtrele
    data = data.where((yemek) {
      final name = (yemek['meal_name'] ?? '').toString().toLowerCase();
      final malzemeler = (yemek['malzemeler'] as List?)?.join(' ').toLowerCase() ?? '';
      final combined = '$name $malzemeler';
      
      // Yasak kelime kontrolü
      for (final yasak in yasaklar) {
        if (combined.contains(yasak)) {
          print('  ❌ Silindi: ${yemek['meal_name']}');
          return false;
        }
      }
      
      // Bozuk malzeme kontrolü (sadece sayı + birim içerenler)
      if (malzemeler.contains('taze g') || 
          malzemeler.contains('taze dilim') ||
          malzemeler.contains('taze adet') ||
          combined.contains('varyasyon')) {
        print('  ❌ Bozuk malzeme: ${yemek['meal_name']}');
        return false;
      }
      
      return true;
    }).toList();
    
    final silinen = onceki - data.length;
    toplamSilinen += silinen;
    
    if (silinen > 0) {
      // meal_id'leri yeniden numaralandır
      for (int i = 0; i < data.length; i++) {
        final prefix = file.contains('kahvalti') ? 'kah' :
                      file.contains('ara_ogun_1') ? 'ara1' :
                      file.contains('ogle') ? 'ogle' :
                      file.contains('ara_ogun_2') ? 'ara2' : 'aksam';
        data[i]['meal_id'] = '${prefix}_${(i + 1).toString().padLeft(3, '0')}';
      }
      
      await f.writeAsString(JsonEncoder.withIndent('  ').convert(data));
      print('  ✅ $silinen yemek silindi (${onceki} → ${data.length})\n');
    } else {
      print('  ✅ Temiz\n');
    }
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ TEMİZLEME TAMAMLANDI!');
  print('📊 Toplam silinen: $toplamSilinen yemek');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}