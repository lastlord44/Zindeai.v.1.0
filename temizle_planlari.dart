import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zinde_ai/data/models/kullanici_hive_model.dart';
import 'package:zinde_ai/data/models/gunluk_plan_hive_model.dart';
import 'package:zinde_ai/data/models/yemek_hive_model.dart';

void main() async {
  print('🔄 Hive başlatılıyor...');
  
  // Hive'ı başlat (Flutter UI gerektirmeden)
  await Hive.initFlutter();
  
  // Adapter'ları kaydet
  Hive.registerAdapter(KullaniciHiveModelAdapter());
  Hive.registerAdapter(YemekHiveModelAdapter());
  
  // Box'ları aç
  await Hive.openBox<KullaniciHiveModel>('kullanici_box');
  final planlarBox = await Hive.openBox<GunlukPlanHiveModel>('planlar_box');
  final favoriBox = await Hive.openBox('favori_yemekler_box');
  await Hive.openBox<YemekHiveModel>('yemekler');
  final yemekOnayBox = await Hive.openBox('yemek_onay_box');
  final raporBox = await Hive.openBox('rapor_box');
  
  print('✅ Hive başlatıldı\n');
  
  // PLANLAR
  print('🗑️ PLANLAR SİLİNİYOR...');
  final planCount = planlarBox.length;
  await planlarBox.clear();
  print('   ✅ $planCount plan silindi');
  
  // ONAY VERİLERİ
  print('\n🗑️ ONAY VERİLERİ SİLİNİYOR...');
  final onayCount = yemekOnayBox.length;
  await yemekOnayBox.clear();
  print('   ✅ $onayCount onay verisi silindi');
  
  // TAMAMLANAN ÖĞÜNLER
  print('\n🗑️ TAMAMLANAN ÖĞÜNLER SİLİNİYOR...');
  final keys = favoriBox.keys
      .where((k) => k.toString().startsWith('tamamlanan_'))
      .toList();
  for (final key in keys) {
    await favoriBox.delete(key);
  }
  print('   ✅ ${keys.length} tamamlanan öğün kaydı silindi');
  
  // RAPOR VERİLERİ
  print('\n🗑️ RAPOR VERİLERİ SİLİNİYOR...');
  final raporCount = raporBox.length;
  await raporBox.clear();
  print('   ✅ $raporCount rapor verisi silindi');
  
  await Hive.close();
  
  print('\n' + '='*50);
  print('✅ TEMİZLİK TAMAMLANDI!');
  print('='*50);
  print('📊 Özet:');
  print('  ✓ $planCount plan silindi');
  print('  ✓ $onayCount onay verisi silindi');
  print('  ✓ ${keys.length} tamamlanan öğün silindi');
  print('  ✓ $raporCount rapor verisi silindi');
  print('\n🔄 ŞİMDİ NE YAPILACAK:');
  print('  1. Flutter uygulamasını HOT RESTART yapın (r tuşu)');
  print('  2. "Plan Oluştur" butonuna basın');
  print('  3. Yeni plan DOĞRU FORMATTA kaydedilecek!');
  print('='*50);
  
  exit(0);
}
