import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';

/// 🔥 SÜPER AGRESİF TEMİZLİK - TÜM SAÇMALIK MALZEMELERİ YOK ET!
void main() async {
  print('🔥 SÜPER AGRESİF TEMİZLİK BAŞLIYOR - HİÇ MERHAMET YOK!\n');
  
  try {
    print('1️⃣ HİVE BAŞLATMA:');
    Hive.init('.');
    Hive.registerAdapter(YemekHiveModelAdapter());
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    print('   ✅ Hive başlatıldı - Yemek sayısı: ${box.length}');
    
    print('\n2️⃣ SÜPER AGRESİF YASAK LİSTE OLUŞTURMA:');
    
    // ÇOK KAPSAMLI YASAK LİSTE - HİÇBİRİNİ İSTEMİYORUZ!
    final yasakMalzemeler = [
      // Baharatlar
      'tuz', 'karabiber', 'kara biber', 'sumak', 'kimyon', 'pul biber',
      'kırmızı pul biber', 'isot', 'paprika', 'oregano', 'kekik', 'biberiye',
      'tarçın', 'karanfil', 'yenibahar', 'köri', 'curry', 'defne yaprağı',
      'defne', 'çörek otu', 'susam', 'haşhaş',
      
      // Otlar ve yapraklar
      'nane', 'maydanoz', 'dereotu', 'roka', 'tere', 'fesleğen',
      
      // Garnitürler ve soslar
      'limon', 'nar ekşisi', 'sirke', 'elma sirkesi', 'balzamik sirke',
      'soya sosu', 'hardal', 'ketçap', 'mayonez',
      
      // Minimal sebzeler
      'sarımsak', 'soğan', 'yeşil soğan', 'kırmızı soğan',
      'sivri biber', 'dolma biber', 'salatalık', 'turşu', 'kapari',
      'zeytin', 'yeşil zeytin', 'siyah zeytin', 'kornişon',
      
      // Tuz türleri
      'limon tuzu', 'deniz tuzu', 'himalaya tuzu', 'çakıl tuzu',
    ];
    
    print('   📋 Yasak malzeme sayısı: ${yasakMalzemeler.length}');
    
    print('\n3️⃣ SÜPER AGRESİF TEMİZLİK İŞLEMİ:');
    
    int temizlenenYemek = 0;
    int kaldirilanMalzeme = 0;
    final ornekTemizlik = <String>[];
    
    for (final yemek in box.values) {
      if (yemek.ingredients == null || yemek.ingredients!.isEmpty) continue;
      
      final eskiMalzemeler = List<String>.from(yemek.ingredients!);
      final temizMalzemeler = <String>[];
      int yemektenKaldirilan = 0;
      
      for (final malzeme in eskiMalzemeler) {
        final malzemeLower = malzeme.toLowerCase().trim();
        
        bool yasakMi = false;
        
        // 1. YASAK KELİME KONTROLÜ
        for (final yasak in yasakMalzemeler) {
          if (malzemeLower.contains(yasak)) {
            yasakMi = true;
            break;
          }
        }
        
        // 2. KÜÇÜK MİKTAR KONTROLÜ - 1'den küçük her şey SİLİNSİN!
        final sayiRegex = RegExp(r'(\d+(?:\.\d+)?)\s*adet|(\d+(?:\.\d+)?)\s*g\)|(\d+(?:\.\d+)?)\s*ml');
        final sayiMatch = sayiRegex.firstMatch(malzemeLower);
        if (sayiMatch != null) {
          final sayiStr = sayiMatch.group(1) ?? sayiMatch.group(2) ?? sayiMatch.group(3);
          final sayi = double.tryParse(sayiStr ?? '');
          if (sayi != null && sayi < 1.0) {
            yasakMi = true; // 1'den küçük miktarlar YASAK!
          }
        }
        
        // 3. BOŞLUK VE SAÇMALIK KONTROLÜ
        if (malzemeLower.trim().isEmpty || 
            malzemeLower.length < 3 ||
            malzemeLower.contains('0.') ||
            malzemeLower.contains('(0') ||
            malzemeLower.startsWith('|') ||
            malzemeLower.endsWith('|')) {
          yasakMi = true;
        }
        
        if (!yasakMi) {
          temizMalzemeler.add(malzeme);
        } else {
          yemektenKaldirilan++;
          kaldirilanMalzeme++;
        }
      }
      
      if (yemektenKaldirilan > 0) {
        yemek.ingredients = temizMalzemeler;
        temizlenenYemek++;
        
        if (ornekTemizlik.length < 10) {
          ornekTemizlik.add('${yemek.mealName}: $yemektenKaldirilan saçmalık kaldırıldı');
        }
        
        // Hive'a kaydet
        await box.put(yemek.mealId!, yemek);
      }
    }
    
    print('   📊 Süper agresif temizlik sonucu:');
    print('   🧹 Temizlenen yemek: $temizlenenYemek adet');
    print('   🗑️ Kaldırılan saçmalık: $kaldirilanMalzeme adet');
    
    if (ornekTemizlik.isNotEmpty) {
      print('   📋 Örnek temizlik işlemleri:');
      ornekTemizlik.forEach((ornek) {
        print('   🔥 $ornek');
      });
    }
    
    print('\n4️⃣ YEMEK İSİMLERİNDEN DE SAÇMALIKLARI KALDIR:');
    
    int yemekIsmiTemizlenen = 0;
    
    for (final yemek in box.values) {
      if (yemek.mealName == null) continue;
      
      String temizIsim = yemek.mealName!;
      bool degisti = false;
      
      // Yemek isminden yasak kelimeleri kaldır
      for (final yasak in yasakMalzemeler) {
        final pattern = RegExp('\\+\\s*$yasak|$yasak\\s*\\+|\\s+$yasak\\s+', caseSensitive: false);
        if (temizIsim.contains(pattern)) {
          temizIsim = temizIsim.replaceAll(pattern, '');
          degisti = true;
        }
      }
      
      // Fazla boşlukları ve + işaretlerini temizle
      temizIsim = temizIsim.replaceAll(RegExp(r'\s+\+\s+'), ' + ');
      temizIsim = temizIsim.replaceAll(RegExp(r'\+\s*\+'), '+');
      temizIsim = temizIsim.replaceAll(RegExp(r'^\s*\+\s*|\s*\+\s*$'), '');
      temizIsim = temizIsim.replaceAll(RegExp(r'\s+'), ' ');
      temizIsim = temizIsim.trim();
      
      if (degisti && temizIsim.isNotEmpty) {
        yemek.mealName = temizIsim;
        yemekIsmiTemizlenen++;
        await box.put(yemek.mealId!, yemek);
      }
    }
    
    print('   📊 Temizlenen yemek ismi: $yemekIsmiTemizlenen adet');
    
    print('\n5️⃣ FİNAL KONTROL - KALAN SAÇMALIKLAR:');
    
    int kalanSacmalik = 0;
    final kalanOrnekler = <String>[];
    
    for (final yemek in box.values) {
      if (yemek.ingredients == null) continue;
      
      for (final malzeme in yemek.ingredients!) {
        final malzemeLower = malzeme.toLowerCase();
        
        // Yasak kelime kontrolü
        for (final yasak in yasakMalzemeler) {
          if (malzemeLower.contains(yasak)) {
            kalanSacmalik++;
            if (kalanOrnekler.length < 5) {
              kalanOrnekler.add('${yemek.mealName}: "$malzeme"');
            }
            break;
          }
        }
        
        // Küçük miktar kontrolü
        if (malzemeLower.contains('0.') || malzemeLower.contains('(0')) {
          kalanSacmalik++;
          if (kalanOrnekler.length < 5) {
            kalanOrnekler.add('${yemek.mealName}: "$malzeme"');
          }
        }
      }
    }
    
    print('   🔍 Final kontrol sonucu:');
    print('   📊 Kalan saçmalık: $kalanSacmalik adet');
    
    if (kalanOrnekler.isNotEmpty) {
      print('   ⚠️ Örnek kalan saçmalıklar:');
      kalanOrnekler.forEach((kalan) {
        print('   🚨 $kalan');
      });
    } else {
      print('   ✅ HİÇBİR SAÇMALIK KALMADI - TAM TEMİZLİK!');
    }
    
    print('\n✅ SÜPER AGRESİF TEMİZLİK TAMAMLANDI!');
    print('🎯 SONUÇ ÖZETİ:');
    print('  🧹 $temizlenenYemek yemek süper agresif temizlendi');
    print('  🗑️ $kaldirilanMalzeme saçmalık malzeme yok edildi');
    print('  📝 $yemekIsmiTemizlenen yemek ismi düzeltildi');
    print('  🚨 $kalanSacmalik saçmalık kaldı (ideal: 0)');
    
    if (kalanSacmalik == 0) {
      print('  🎉 MÜKEMMELLİK! SİSTEM TAM TEMİZ!');
    }
    
  } catch (e, stackTrace) {
    print('❌ Süper agresif temizlik hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}