import 'package:hive_flutter/hive_flutter.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

/// 🔍 AI Yemek Seçimi Sorunu Analizi
void main() async {
  print('🔍 AI YEMEK SEÇİMİ SORUNU ANALİZİ BAŞLIYOR...\n');
  
  try {
    // Hive başlat
    await Hive.initFlutter();
    Hive.registerAdapter(YemekHiveModelAdapter());
    await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('1️⃣ TEMEL VERİTABANI DURUMU:');
    final toplamYemekSayisi = await HiveService.yemekSayisi();
    print('   📊 Toplam yemek sayısı: $toplamYemekSayisi');
    
    if (toplamYemekSayisi == 0) {
      print('   ❌ VERİTABANI BOŞ! Migration gerekli.\n');
      return;
    }
    
    print('\n2️⃣ KATEGORİ DAĞILIMI:');
    final kategoriSayilari = await HiveService.kategoriSayilari();
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 $kategori: $sayi adet');
    });
    
    print('\n3️⃣ ÖGUN TİPİ ANALİZİ:');
    final tumYemekler = await HiveService.tumYemekleriGetir();
    
    final ogunDagilimi = <OgunTipi, int>{};
    for (var yemek in tumYemekler) {
      ogunDagilimi[yemek.ogun] = (ogunDagilimi[yemek.ogun] ?? 0) + 1;
    }
    
    for (var ogunTipi in OgunTipi.values) {
      final sayi = ogunDagilimi[ogunTipi] ?? 0;
      print('   🍽️ ${ogunTipi.name}: $sayi adet ${sayi == 0 ? "❌ BOŞ!" : "✅"}');
    }
    
    print('\n4️⃣ AI ALGORİTMA MANUEL TEST:');
    
    // Her öğün tipinde örnek yemekleri kontrol et
    for (var ogunTipi in OgunTipi.values) {
      final ogunYemekleri = tumYemekler.where((y) => y.ogun == ogunTipi).toList();
      
      print('   🔍 ${ogunTipi.name} test:');
      print('      📊 Havuz boyutu: ${ogunYemekleri.length}');
      
      if (ogunYemekleri.isNotEmpty) {
        // İlk 3 örneği göster
        final ornekler = ogunYemekleri.take(3);
        for (var i = 0; i < ornekler.length; i++) {
          final yemek = ornekler.elementAt(i);
          print('      ${i + 1}. ${yemek.ad} (${yemek.kalori.toInt()}kcal)');
        }
        print('      ✅ YemekSecimi için uygun');
      } else {
        print('      ❌ BOŞ! Fallback devreye girecek');
      }
    }
    
    print('\n5️⃣ KISITLAMALARSİZ TEST:');
    
    // Boş kısıtlamalarla test
    final kisitlamalar = <String>[];
    final Map<OgunTipi, List<Yemek>> ogunYemekleri = {};
    
    for (var yemek in tumYemekler) {
      if (yemek.kisitlamayaUygunMu(kisitlamalar)) {
        (ogunYemekleri[yemek.ogun] ??= []).add(yemek);
      }
    }
    
    for (var ogunTipi in OgunTipi.values) {
      final liste = ogunYemekleri[ogunTipi] ?? [];
      print('   🍽️ ${ogunTipi.name}: ${liste.length} adet ${liste.isEmpty ? "❌ KISITLAMA SONRASI BOŞ!" : "✅"}');
    }
    
    print('\n6️⃣ ÖRNEK YEMEKLERİN DETAYI:');
    
    // Her öğünden ilk yemeği detaylı göster
    for (var ogunTipi in OgunTipi.values) {
      final liste = ogunYemekleri[ogunTipi] ?? [];
      if (liste.isNotEmpty) {
        final yemek = liste.first;
        print('   🍽️ ${ogunTipi.name} ÖRNEĞİ:');
        print('      📝 Ad: ${yemek.ad}');
        print('      🏷️ ID: ${yemek.id}');
        print('      📊 Makrolar: ${yemek.kalori.toInt()}kcal, P:${yemek.protein.toInt()}g, C:${yemek.karbonhidrat.toInt()}g, Y:${yemek.yag.toInt()}g');
        print('      🧄 Malzemeler: ${yemek.malzemeler.take(2).join(", ")}${yemek.malzemeler.length > 2 ? "..." : ""}');
      }
    }
    
    print('\n📋 SONUÇ:');
    if (ogunDagilimi.values.any((sayi) => sayi == 0)) {
      print('❌ SORUN TESPİT EDİLDİ: Bazı öğün tipleri BOŞ!');
      print('   Fallback yemek (Izgara Tavuk) kullanılacak.');
    } else {
      print('✅ Veritabanı durumu normal görünüyor.');
      print('   Sorun başka bir yerde olabilir (filtreleme, skor hesaplama, vs.)');
    }
    
  } catch (e, stackTrace) {
    print('❌ Hata: $e');
    print('Stack: $stackTrace');
  } finally {
    await Hive.close();
  }
}
