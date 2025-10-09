import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

/// 200 Ekonomik Ana Yemeği Hive DB'ye yükler
/// Kullanım: dart ekonomik_yemekler_yukle.dart
void main() async {
  print('🚀 Ekonomik yemekler yükleniyor...\n');

  await Hive.initFlutter();
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  final box = await Hive.openBox<YemekHiveModel>('yemekler');
  
  // Mevcut durum
  print('📊 Mevcut durum:');
  print('   Toplam yemek sayısı: ${box.length}');
  
  // JSON dosyasını oku
  final file = File('assets/data/ekonomik_ana_yemekler_200_temiz.json');
  if (!file.existsSync()) {
    print('❌ HATA: assets/data/ekonomik_ana_yemekler_200_temiz.json bulunamadı!');
    exit(1);
  }
  
  final jsonString = await file.readAsString();
  final List<dynamic> yemeklerJson = jsonDecode(jsonString);
  
  print('\n📥 JSON okundu: ${yemeklerJson.length} yemek bulundu');
  
  int eklenen = 0;
  int atlanan = 0;
  
  for (var yemekJson in yemeklerJson) {
    try {
      final id = yemekJson['id'] as String;
      
      // Zaten varsa atla
      if (box.containsKey(id)) {
        atlanan++;
        continue;
      }
      
      // Malzemeleri parse et (List<String> olarak)
      final malzemelerJson = yemekJson['malzemeler'] as List<dynamic>;
      final malzemeler = malzemelerJson.map((m) => m.toString()).toList();
      
      // Öğün tipini parse et
      OgunTipi ogun;
      switch (yemekJson['ogun'] as String) {
        case 'ogle':
          ogun = OgunTipi.ogle;
          break;
        case 'aksam':
          ogun = OgunTipi.aksam;
          break;
        default:
          print('⚠️ Bilinmeyen öğün: ${yemekJson['ogun']} - Atlanıyor');
          atlanan++;
          continue;
      }
      
      // Yemek entity oluştur
      final yemek = Yemek(
        id: id,
        ad: yemekJson['ad'] as String,
        ogun: ogun,
        kalori: (yemekJson['kalori'] as num).toDouble(),
        protein: (yemekJson['protein'] as num).toDouble(),
        karbonhidrat: (yemekJson['karbonhidrat'] as num).toDouble(),
        yag: (yemekJson['yag'] as num).toDouble(),
        malzemeler: malzemeler,
        hazirlamaSuresi: (yemekJson['hazirlamaSuresi'] as num?)?.toInt() ?? 30,
        zorluk: _parseZorluk(yemekJson['zorluk'] as String? ?? 'kolay'),
      );
      
      // Hive model'e çevir ve kaydet
      final model = YemekHiveModel.fromEntity(yemek);
      await box.put(id, model);
      eklenen++;
      
      if (eklenen % 20 == 0) {
        print('   ✓ $eklenen yemek eklendi...');
      }
    } catch (e) {
      print('❌ Hata (${yemekJson['id']}): $e');
      atlanan++;
    }
  }
  
  print('\n✅ Tamamlandı!');
  print('   📈 Eklenen: $eklenen yemek');
  print('   ⏭️ Atlanan: $atlanan yemek (zaten mevcut)');
  print('   📊 Yeni toplam: ${box.length} yemek');
  
  await box.close();
  await Hive.close();
}

/// Zorluk string'ini Zorluk enum'a çevirir
Zorluk _parseZorluk(String zorluk) {
  switch (zorluk.toLowerCase()) {
    case 'kolay':
      return Zorluk.kolay;
    case 'orta':
      return Zorluk.orta;
    case 'zor':
      return Zorluk.zor;
    default:
      return Zorluk.kolay; // Default kolay
  }
}
