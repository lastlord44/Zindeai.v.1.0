// DB DURUM ANALİZ SCRIPTI
import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';

Future<void> main() async {
  print('📊 === HIVE DB DURUM ANALİZİ ===\n');
  
  try {
    // Hive setup
    Hive.init('./hive_data');
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('🗂️  BOX BİLGİLERİ:');
    print('   Box ismi: ${box.name}');
    print('   Box path: ${box.path}');
    print('   Toplam entry: ${box.length}');
    print('   Box açık mı: ${box.isOpen}');
    
    if (box.isEmpty) {
      print('\n❌ BOX TAMAMEN BOŞ! Migration çalışmamış.');
      print('   🔄 Yemek verilerini yeniden yüklemek gerek.\n');
      await box.close();
      return;
    }
    
    print('\n📈 VERİ KALİTE ANALİZİ:');
    
    int toplamYemek = 0;
    int gecerliYemek = 0;
    int bozukYemek = 0;
    int dusukKaloriYemek = 0;
    int yuksekKaloriYemek = 0;
    
    final kategoriler = <String, int>{};
    final kaloriDagilimi = <String, int>{};
    
    for (var model in box.values) {
      toplamYemek++;
      
      try {
        final yemek = model.toEntity();
        
        // Kalori analizi
        if (yemek.kalori <= 0) {
          bozukYemek++;
          continue;
        }
        if (yemek.kalori < 50) {
          dusukKaloriYemek++;
        }
        if (yemek.kalori > 1000) {
          yuksekKaloriYemek++;
        }
        
        gecerliYemek++;
        
        // Kategori analizi
        final kategori = model.category ?? 'Bilinmeyen';
        kategoriler[kategori] = (kategoriler[kategori] ?? 0) + 1;
        
        // Kalori dağılımı
        String kaloriGrubu;
        if (yemek.kalori < 100) kaloriGrubu = '0-100';
        else if (yemek.kalori < 300) kaloriGrubu = '100-300';
        else if (yemek.kalori < 500) kaloriGrubu = '300-500';
        else if (yemek.kalori < 800) kaloriGrubu = '500-800';
        else kaloriGrubu = '800+';
        
        kaloriDagilimi[kaloriGrubu] = (kaloriDagilimi[kaloriGrubu] ?? 0) + 1;
        
      } catch (e) {
        bozukYemek++;
        print('   ⚠️ Bozuk entity: $e');
      }
    }
    
    print('   ✅ Geçerli yemek: $gecerliYemek');
    print('   ❌ Bozuk yemek: $bozukYemek');
    print('   ⚡ Düşük kalori (<50): $dusukKaloriYemek');
    print('   🔥 Yüksek kalori (>1000): $yuksekKaloriYemek');
    
    final basariOrani = (gecerliYemek / toplamYemek * 100);
    print('   📊 Başarı oranı: ${basariOrani.toStringAsFixed(1)}%');
    
    print('\n🏷️  KATEGORİ DAĞILIMI:');
    kategoriler.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(10).forEach((entry) {
        print('   ${entry.key}: ${entry.value} yemek');
      });
    
    print('\n📈 KALORİ DAĞILIMI:');
    kaloriDagilimi.entries.forEach((entry) {
      print('   ${entry.key} kcal: ${entry.value} yemek');
    });
    
    // Örnek yemekler
    print('\n🍽️  ÖRNEK YEMeKLER:');
    int ornekSayac = 0;
    for (var model in box.values) {
      if (ornekSayac >= 5) break;
      try {
        final yemek = model.toEntity();
        if (yemek.kalori > 0) {
          print('   ${ornekSayac + 1}. ${yemek.ad} - ${yemek.kalori.toInt()} kcal (${model.category ?? "?"})');
          ornekSayac++;
        }
      } catch (e) {
        // Skip bozuk yemekler
      }
    }
    
    print('\n🎯 SONUÇ:');
    if (basariOrani >= 80) {
      print('   ✅ DB DURUMU İYİ - Yemekler kullanılabilir');
      print('   🚀 V5.1 sistemi ile test edilebilir');
    } else if (basariOrani >= 50) {
      print('   ⚠️ DB DURUMU ORTA - Bazı temizlemeler gerek');
      print('   🔧 Bozuk verileri filtrele veya temizle');
    } else {
      print('   ❌ DB DURUMU KÖTÜ - Yeniden migration gerek');
      print('   🔄 Tüm verileri sıfırdan yükle');
    }
    
    await box.close();
    
  } catch (e, stack) {
    print('❌ ANALIZ HATASI: $e');
    print('Stack: $stack');
  }
  
  print('\n=============================');
}