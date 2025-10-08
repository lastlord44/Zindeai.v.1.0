// Whey protein içeren yemekleri JSON dosyalarından temizle
import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧹 Whey protein temizleme başladı...\n');
  
  final kahvaltiDosyalari = [
    'assets/data/kahvalti_batch_01.json',
    'assets/data/kahvalti_batch_02.json',
    'assets/data/kahvalti.json',
  ];
  
  int toplamSilinen = 0;
  
  for (final dosyaYolu in kahvaltiDosyalari) {
    final dosya = File(dosyaYolu);
    
    if (!dosya.existsSync()) {
      print('⚠️  Dosya bulunamadı: $dosyaYolu');
      continue;
    }
    
    print('📂 İşleniyor: $dosyaYolu');
    
    // JSON'u oku
    final jsonString = await dosya.readAsString();
    final List<dynamic> yemekler = json.decode(jsonString);
    
    final oncekiSayi = yemekler.length;
    
    // Whey protein içermeyenleri filtrele
    final temizYemekler = yemekler.where((yemek) {
      // Ingredients null ise veya list değilse, atla
      if (yemek['ingredients'] == null || yemek['ingredients'] is! List) {
        return false;
      }
      
      final malzemeler = yemek['ingredients'] as List<dynamic>;
      
      // Whey protein içeriyor mu kontrol et
      final wheyIceriyor = malzemeler.any((malzeme) {
        final malzemeStr = malzeme.toString().toLowerCase();
        return malzemeStr.contains('whey') || 
               malzemeStr.contains('protein tozu') ||
               malzemeStr.contains('protein powder');
      });
      
      return !wheyIceriyor; // Whey içermeyenleri al
    }).toList();
    
    final silinen = oncekiSayi - temizYemekler.length;
    toplamSilinen += silinen;
    
    print('  ✂️  Silindi: $silinen yemek');
    print('  ✅ Kalan: ${temizYemekler.length} yemek\n');
    
    // Temiz JSON'u kaydet
    final temizJson = JsonEncoder.withIndent('  ').convert(temizYemekler);
    await dosya.writeAsString(temizJson);
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ TEMİZLİK TAMAMLANDI');
  print('📊 Toplam silinen: $toplamSilinen whey protein içeren yemek');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  print('🔄 Şimdi migration çalıştır:');
  print('   dart migration_yukle.dart');
}
