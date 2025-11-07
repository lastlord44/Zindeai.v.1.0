import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/domain/entities/yemek.dart';

/// 🔍 Pure Dart AI Yemek Seçimi Sorunu Analizi (Flutter UI'siz)
void main() async {
  print('🔍 PURE DART AI YEMEK SEÇİMİ SORUNU ANALİZİ BAŞLIYOR...\n');
  
  try {
    // Hive başlat (Pure Dart)
    final currentDir = Directory.current.path;
    final hiveDir = Directory('$currentDir/hive_data');
    if (!hiveDir.existsSync()) {
      print('❌ Hive dizini bulunamadı: ${hiveDir.path}');
      return;
    }
    
    Hive.init(hiveDir.path);
    Hive.registerAdapter(YemekHiveModelAdapter());
    
    // Box'ı aç
    final box = await Hive.openBox<YemekHiveModel>('yemekler');
    
    print('1️⃣ TEMEL VERİTABANI DURUMU:');
    print('   📂 Hive dizini: ${hiveDir.path}');
    print('   📊 Toplam yemek sayısı: ${box.length}');
    
    if (box.length == 0) {
      print('   ❌ VERİTABANI BOŞ! Migration gerekli.\n');
      await Hive.close();
      return;
    }
    
    print('\n2️⃣ KATEGORİ DAĞILIMI:');
    final kategoriSayilari = <String, int>{};
    for (var yemekModel in box.values) {
      final kategori = yemekModel.category ?? 'Bilinmeyen';
      kategoriSayilari[kategori] = (kategoriSayilari[kategori] ?? 0) + 1;
    }
    
    kategoriSayilari.forEach((kategori, sayi) {
      print('   📂 $kategori: $sayi adet');
    });
    
    print('\n3️⃣ ÖGUN TİPİ ANALİZİ:');
    final tumYemekler = <Yemek>[];
    for (var model in box.values) {
      try {
        tumYemekler.add(model.toEntity());
      } catch (e) {
        print('   ⚠️ Yemek parse hatası: $e');
      }
    }
    
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
        final ornekSayisi = ogunYemekleri.length > 3 ? 3 : ogunYemekleri.length;
        for (var i = 0; i < ornekSayisi; i++) {
          final yemek = ogunYemekleri[i];
          print('      ${i + 1}. ${yemek.ad} (${yemek.kalori.toInt()}kcal)');
        }
        print('      ✅ YemekSecimi için uygun');
      } else {
        print('      ❌ BOŞ! Fallback devreye girecek');
      }
    }
    
    print('\n5️⃣ KISITLAMALARSİZ FİLTRE TESTİ:');
    
    // Boş kısıtlamalarla test (extension method)
    final kisitlamalar = <String>[];
    final Map<OgunTipi, List<Yemek>> ogunYemekleri = {};
    
    for (var yemek in tumYemekler) {
      // Kısıtlama kontrolü (extension method çağrısı)
      try {
        if (yemek.kisitlamayaUygunMu(kisitlamalar)) {
          (ogunYemekleri[yemek.ogun] ??= []).add(yemek);
        }
      } catch (e) {
        print('   ⚠️ Kısıtlama kontrolü hatası: $e');
        // Kısıtlama kontrolü başarısız olursa yine de ekle
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
        final malzemeSayisi = yemek.malzemeler.length;
        final ilkIkiMalzeme = yemek.malzemeler.take(2).join(", ");
        print('      🧄 Malzemeler: $ilkIkiMalzeme${malzemeSayisi > 2 ? "... (toplam $malzemeSayisi)" : ""}');
      }
    }
    
    print('\n7️⃣ HİVE SERVICE KATEGORI GETİR TESTİ:');
    
    // kategoriYemekleriGetir metodu gibi test
    for (var ogunTipi in OgunTipi.values) {
      final ogunAdi = ogunTipi.name.toLowerCase();
      var kategoriyemekleri = <YemekHiveModel>[];
      
      try {
        kategoriyemekleri = box.values
            .where((yemek) => yemek.category?.toLowerCase() == ogunAdi)
            .toList();
        
        print('   📂 Kategori "${ogunAdi}" → ${kategoriyemekleri.length} adet');
        
        if (kategoriyemekleri.isNotEmpty) {
          final ilkYemek = kategoriyemekleri.first.toEntity();
          print('      örnek: ${ilkYemek.ad}');
        }
      } catch (e) {
        print('   ❌ Kategori getirme hatası "${ogunAdi}": $e');
      }
    }
    
    print('\n📋 SONUÇ:');
    if (ogunDagilimi.values.any((sayi) => sayi == 0)) {
      print('❌ SORUN TESPİT EDİLDİ: Bazı öğün tipleri BOŞ!');
      print('   Fallback yemek (Izgara Tavuk) kullanılacak.');
      print('   Eksik olan öğün tipleri:');
      for (var ogunTipi in OgunTipi.values) {
        if ((ogunDagilimi[ogunTipi] ?? 0) == 0) {
          print('   - ${ogunTipi.name}');
        }
      }
    } else {
      print('✅ Veritabanı öğün dağılımı normal görünüyor.');
      print('   Sorun başka bir yerde olabilir (kategori mapping, filtreleme, vs.)');
    }
    
    await Hive.close();
    
  } catch (e, stackTrace) {
    print('❌ Hata: $e');
    print('Stack: $stackTrace');
    try {
      await Hive.close();
    } catch (_) {}
  }
}