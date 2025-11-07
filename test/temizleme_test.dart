import 'package:flutter_test/flutter_test.dart';
import '../gereksiz_baharat_temizleme.dart' as temizleme_script;

void main() {
  test('Gereksiz Baharatları Temizleme Scriptini Çalıştır', () async {
    // Temizleme scriptinin main fonksiyonunu çağır
    await temizleme_script.main();
    
    // Testin başarılı sayılması için basit bir beklenti ekleyelim.
    // Script hata fırlatmazsa bu test geçer.
    expect(true, isTrue);
  });
}
