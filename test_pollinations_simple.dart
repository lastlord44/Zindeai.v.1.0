// Basit Pollinations AI Testi (Flutter bağımlılığı YOK)
import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔬 POLLINATIONS AI BASIT TEST\n');
  
  // Test parametreleri
  final testKalori = 3000.0;
  final testProtein = 160.0;
  final testKarb = 400.0;
  final testYag = 85.0;
  
  print('📊 HEDEF MAKROLAR:');
  print('   Kalori: ${testKalori.toInt()} kcal');
  print('   Protein: ${testProtein.toInt()}g');
  print('   Karbonhidrat: ${testKarb.toInt()}g');
  print('   Yağ: ${testYag.toInt()}g\n');
  
  // Random seed (prompt'tan alındı)
  final now = DateTime.now();
  final randomSeed = '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}'.hashCode.abs() % 999999;
  final dayOfWeek = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'][now.weekday % 7];
  
  print('🎲 Random Seed: $randomSeed ($dayOfWeek)\n');
  
  // Simple English prompt to avoid Unicode issues
  final prompt = '''Create a 5-meal daily nutrition plan.

TARGETS:
- Calories: ${testKalori.toInt()} kcal
- Protein: ${testProtein.toInt()}g
- Carbs: ${testKarb.toInt()}g
- Fat: ${testYag.toInt()}g

RULES:
- Use REAL nutrition values (100g chicken = 31g protein)
- Adjust portions to meet targets (200g chicken if more protein needed)
- Create DIVERSE meals (no oatmeal smoothie, chicken rice prohibited!)
- Use decimal numbers (287.3, NOT 300)
- Return ONLY JSON

JSON FORMAT:
{
  "kahvalti": {"yemek_adi": "Eggs + Bread", "malzemeler": ["3 eggs", "2 bread"], "kalori": 287.3, "protein": 18.7, "karbonhidrat": 21.4, "yag": 15.2},
  "ara_ogun_1": {...},
  "ogle": {...},
  "ara_ogun_2": {...},
  "aksam": {...}
}

Create plan now with seed #$randomSeed (JSON ONLY):''';
  
  print('🚀 API\'ye istek gönderiliyor...\n');
  
  try {
    final startTime = DateTime.now();
    
    // HTTP request
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('https://text.pollinations.ai/openai'));
    request.headers.set('Content-Type', 'application/json');
    
    final requestBody = json.encode({
      'messages': [
        {'role': 'system', 'content': 'You are a certified nutritionist. Use ONLY real values.'},
        {'role': 'user', 'content': prompt},
      ],
      'model': 'openai',
      'temperature': 1.0,
      'max_tokens': 2000,
    });
    
    request.write(requestBody);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    final duration = DateTime.now().difference(startTime);
    
    print('⏱️  Süre: ${duration.inSeconds}s ${duration.inMilliseconds % 1000}ms');
    print('📡 Status Code: ${response.statusCode}\n');
    
    client.close();
    
    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      final aiResponse = data['choices'][0]['message']['content'] as String;
      
      print('✅ API RESPONSE ALINDI!\n');
      print('📝 RESPONSE (ilk 800 karakter):');
      print('─' * 60);
      print(aiResponse.substring(0, aiResponse.length > 800 ? 800 : aiResponse.length));
      print('─' * 60);
      print('\n📏 Toplam uzunluk: ${aiResponse.length} karakter\n');
      
      // JSON kontrolü
      if (aiResponse.contains('{') && aiResponse.contains('}')) {
        print('✅ JSON formatı tespit edildi\n');
        
        // Öğün kontrolü
        print('🍽️  ÖĞÜN KONTROLÜ:');
        final ogunler = ['kahvalti', 'ara_ogun_1', 'ogle', 'ara_ogun_2', 'aksam'];
        for (final ogun in ogunler) {
          if (aiResponse.contains(ogun)) {
            print('   ✓ $ogun bulundu');
          } else {
            print('   ✗ $ogun BULUNAMADI!');
          }
        }
        
        // Yasaklı yemek kontrolü
        print('\n🚫 YASAKLI YEMEK KONTROLÜ:');
        final yasaklilar = ['yulaflı smoothie', 'tavuklu pirinç', 'ton balıklı salata', 'yoğurt + meyve'];
        var yasakBulundu = false;
        for (final yasak in yasaklilar) {
          if (aiResponse.toLowerCase().contains(yasak.toLowerCase())) {
            print('   ⚠️  "$yasak" BULUNDU! (Yasaklı)');
            yasakBulundu = true;
          }
        }
        if (!yasakBulundu) {
          print('   ✓ Yasaklı yemek YOK - Çeşitlilik başarılı!');
        }
        
      } else {
        print('⚠️  JSON formatı tespit EDİLEMEDİ!');
      }
      
      print('\n' + '=' * 60);
      print('✅ TEST BAŞARILI - API ÇALIŞIYOR!');
      print('=' * 60);
      
    } else {
      print('❌ API HATASI: ${response.statusCode}');
      print('Response: $responseBody');
      exit(1);
    }
    
  } catch (e, stackTrace) {
    print('❌ TEST BAŞARISIZ!\n');
    print('Hata: $e\n');
    print('Stack Trace:');
    print(stackTrace);
    exit(1);
  }
}