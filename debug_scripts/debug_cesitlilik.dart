 simport 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/datasources/yemek_hive_data_source.dart';
import 'lib/domain/entities/yemek.dart';
import 'lib/core/services/cesitlilik_gecmis_servisi.dart';
import 'lib/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı başlat
  await Hive.initFlutter();
  await HiveService.init();
  
  print('\n🔍 =============== ÇEŞİTLİLİK SORUNU DEBUG ===============\n');
  
  // 1. Çeşitlilik geçmişini kontrol et
  print('📋 1) ÇEŞİTLİLİK GEÇMİŞİ KONTROLÜ:');
  print('─' * 60);
  
  for (final ogunTipi in OgunTipi.values) {
    final gecmis = CesitlilikGecmisServisi.gecmisiGetir(ogunTipi);
    final ogunAdi = ogunTipi.toString().split('.').last;
    print('[$ogunAdi] Geçmiş boyutu: ${gecmis.length}');
    if (gecmis.isNotEmpty) {
      print('  Son 5 yemek: ${gecmis.take(5).join(", ")}');
    } else {
      print('  ⚠️ GEÇMİŞ BOŞ!');
    }
  }
  
  // 2. SOMON yemeklerini bul
  print('\n🐟 2) SOMON YEMEKLERİ ANALİZİ:');
  print('─' * 60);
  
  final dataSource = YemekHiveDataSource();
  final tumYemekler = await dataSource.tumYemekleriYukle();
  
  final somonYemekleri = <String, List<Yemek>>{};
  
  for (final entry in tumYemekler.entries) {
    final ogunTipi = entry.key;
    final yemekler = entry.value;
    
    final somonlar = yemekler.where((y) => 
      y.ad.toLowerCase().contains('somon')
    ).toList();
    
    if (somonlar.isNotEmpty) {
      somonYemekleri[ogunTipi.toString().split('.').last] = somonlar;
    }
  }
  
  if (somonYemekleri.isEmpty) {
    print('❌ Hiç SOMON yemeği bulunamadı!');
  } else {
    for (final entry in somonYemekleri.entries) {
      print('[${entry.key}] ${entry.value.length} adet somon yemeği:');
      for (final yemek in entry.value) {
        print('  - ${yemek.ad} (ID: ${yemek.id})');
      }
    }
  }
  
  // 3. Öğle-Akşam yemeklerinde aynı yemek var mı kontrol et
  print('\n🔄 3) ÖĞLE-AKŞAM TEKRAR KONTROLÜ:');
  print('─' * 60);
  
  final ogleYemekleri = tumYemekler[OgunTipi.ogle] ?? [];
  final aksamYemekleri = tumYemekler[OgunTipi.aksam] ?? [];
  
  int ayniYemekSayisi = 0;
  final ayniYemekler = <String>[];
  
  for (final ogleYemek in ogleYemekleri) {
    final ayni = aksamYemekleri.where((a) => a.id == ogleYemek.id).toList();
    if (ayni.isNotEmpty) {
      ayniYemekSayisi++;
      ayniYemekler.add('${ogleYemek.ad} (${ogleYemek.id})');
    }
  }
  
  print('Öğle yemekleri: ${ogleYemekleri.length}');
  print('Akşam yemekleri: ${aksamYemekleri.length}');
  print('Aynı ID\'li yemekler: $ayniYemekSayisi');
  
  if (ayniYemekSayisi > 0) {
    print('\n⚠️ UYARI: Şu yemekler hem öğle hem akşam kategorisinde:');
    for (final yemek in ayniYemekler.take(10)) {
      print('  - $yemek');
    }
    if (ayniYemekler.length > 10) {
      print('  ... ve ${ayniYemekler.length - 10} yemek daha');
    }
  }
  
  // 4. Rastgele 5 plan oluştur ve tekrar olup olmadığını kontrol et
  print('\n🎲 4) TEST: 5 RASTGELE PLAN OLUŞTUR (SOMON KONTROLÜ):');
  print('─' * 60);
  
  int somonSayisi = 0;
  int ogleAksamAyniSayisi = 0;
  
  for (int i = 1; i <= 5; i++) {
    // Rastgele öğle ve akşam seç (basit)
    final ogleIndex = DateTime.now().millisecondsSinceEpoch % ogleYemekleri.length;
    final aksamIndex = (DateTime.now().millisecondsSinceEpoch + i) % aksamYemekleri.length;
    
    final ogle = ogleYemekleri[ogleIndex];
    final aksam = aksamYemekleri[aksamIndex];
    
    final ogleSomon = ogle.ad.toLowerCase().contains('somon');
    final aksamSomon = aksam.ad.toLowerCase().contains('somon');
    
    print('Plan $i:');
    print('  Öğle: ${ogle.ad}${ogleSomon ? " 🐟" : ""}');
    print('  Akşam: ${aksam.ad}${aksamSomon ? " 🐟" : ""}');
    
    if (ogleSomon || aksamSomon) somonSayisi++;
    if (ogle.id == aksam.id) {
      ogleAksamAyniSayisi++;
      print('  ⚠️ ÖĞLE VE AKŞAM AYNI YEMEK!');
    }
  }
  
  print('\nÖzet:');
  print('  Somon içeren planlar: $somonSayisi/5');
  print('  Öğle-Akşam aynı olan planlar: $ogleAksamAyniSayisi/5');
  
  print('\n' + '=' * 60);
  print('✅ Debug tamamlandı!\n');
}
