import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/data/models/yemek_hive_model.dart';
import 'lib/data/local/hive_service.dart';
import 'lib/domain/services/ai_beslenme_servisi.dart';
import 'lib/domain/entities/hedef.dart';
import 'lib/core/utils/app_logger.dart';

/// 🧪 AI Fix Testi - Çeşitlilik sorunu düzeltildi mi?
void main() async {
  print('🧪 AI FIX TESTİ BAŞLIYOR...\n');
  
  final tempDir = Directory.systemTemp.createTempSync();
  
  try {
    // Hive'ı geçici bir dizinde başlat
    await HiveService.init(path: tempDir.path);
    // Adapter'lar HiveService içinde register ediliyor olmalı,
    // ama emin olmak için burada da register edebiliriz.
    // Eğer HiveService.init içinde zaten varsa, bu satır zararsızdır.
    if (!Hive.isAdapterRegistered(YemekHiveModelAdapter().typeId)) {
      Hive.registerAdapter(YemekHiveModelAdapter());
    }
    
    final aiServisi = AIBeslenmeServisi();
    
    print('1️⃣ TEMEL BİLGİLER:');
    final toplamYemek = await HiveService.yemekSayisi();
    print('   📊 Toplam yemek sayısı: $toplamYemek');
    
    print('\n2️⃣ AI ALGORİTMA TESTİ:');
    print('   🎯 Hedef: 3000 kcal | P:150g | C:400g | Y:100g');
    
    // Test parametreleri
    const hedefKalori = 3000.0;
    const hedefProtein = 150.0;
    const hedefKarb = 400.0;
    const hedefYag = 100.0;
    final hedef = Hedef.kasKazanKiloAl;
    final kisitlamalar = <String>[];
    final tarih = DateTime.now();
    
    // Plan oluştur
    print('   ⚡ Plan oluşturuluyor...');
    final gunlukPlan = await aiServisi.gunlukPlanOlustur(
      hedefKalori: hedefKalori,
      hedefProtein: hedefProtein,
      hedefKarb: hedefKarb,
      hedefYag: hedefYag,
      hedef: hedef,
      kisitlamalar: kisitlamalar,
      tarih: tarih,
    );
    
    print('\n3️⃣ OLUŞTURULAN PLAN:');
    print('   🍽️ KAHVALTI: ${gunlukPlan.kahvalti?.ad ?? "YOK"} (${gunlukPlan.kahvalti?.kalori.toInt() ?? 0}kcal)');
    print('   🍽️ ARA ÖĞÜN 1: ${gunlukPlan.araOgun1?.ad ?? "YOK"} (${gunlukPlan.araOgun1?.kalori.toInt() ?? 0}kcal)');
    print('   🍽️ ÖĞLE: ${gunlukPlan.ogleYemegi?.ad ?? "YOK"} (${gunlukPlan.ogleYemegi?.kalori.toInt() ?? 0}kcal)');
    print('   🍽️ ARA ÖĞÜN 2: ${gunlukPlan.araOgun2?.ad ?? "YOK"} (${gunlukPlan.araOgun2?.kalori.toInt() ?? 0}kcal)');
    print('   🍽️ AKŞAM: ${gunlukPlan.aksamYemegi?.ad ?? "YOK"} (${gunlukPlan.aksamYemegi?.kalori.toInt() ?? 0}kcal)');
    
    print('\n4️⃣ MAKRO ÖZET:');
    print('   📊 TOPLAM: ${gunlukPlan.toplamKalori.toInt()}kcal | P:${gunlukPlan.toplamProtein.toInt()}g | C:${gunlukPlan.toplamKarbonhidrat.toInt()}g | Y:${gunlukPlan.toplamYag.toInt()}g');
    
    print('\n5️⃣ ÇEŞİTLİLİK TESTİ:');
    final yemekAdlari = <String>[];
    if (gunlukPlan.kahvalti != null) yemekAdlari.add(gunlukPlan.kahvalti!.ad);
    if (gunlukPlan.araOgun1 != null) yemekAdlari.add(gunlukPlan.araOgun1!.ad);
    if (gunlukPlan.ogleYemegi != null) yemekAdlari.add(gunlukPlan.ogleYemegi!.ad);
    if (gunlukPlan.araOgun2 != null) yemekAdlari.add(gunlukPlan.araOgun2!.ad);
    if (gunlukPlan.aksamYemegi != null) yemekAdlari.add(gunlukPlan.aksamYemegi!.ad);
    
    final benzersizYemekSayisi = yemekAdlari.toSet().length;
    final toplamOgun = yemekAdlari.length;
    
    print('   🔄 Toplam öğün: $toplamOgun');
    print('   🎯 Benzersiz yemek: $benzersizYemekSayisi');
    print('   📈 Çeşitlilik oranı: ${(benzersizYemekSayisi / toplamOgun * 100).toStringAsFixed(1)}%');
    
    // Fallback kontrolü
    bool fallbackKullanildi = yemekAdlari.any((ad) => ad.contains('Izgara Tavuk'));
    
    print('\n6️⃣ SONUÇ ANALİZİ:');
    if (fallbackKullanildi) {
      print('   ❌ SORUN DEVAM EDİYOR: Fallback yemek (Izgara Tavuk) kullanılıyor!');
      print('      Bu, öğün havuzlarının hala boş geldiği anlamına geliyor.');
    } else if (benzersizYemekSayisi < toplamOgun) {
      print('   ⚠️ KISMI ÇÖZÜM: Fallback yok ama çeşitlilik yetersiz.');
      print('      Aynı yemekler tekrar ediyor. Çeşitlilik algoritması iyileştirilebilir.');
    } else {
      print('   ✅ TAM ÇÖZÜM: Her öğün farklı yemek, fallback yok!');
    }
    
    // ALTERNATİF YEMEK TESTİ
    print('\n7️⃣ ALTERNATİF YEMEK TESTİ:');
    if (gunlukPlan.kahvalti != null) {
      print('   🔄 ${gunlukPlan.kahvalti!.ad} için alternatifler getiriliyor...');
      final alternatifler = await aiServisi.alternatifleriGetir(gunlukPlan.kahvalti!);
      print('   📋 Bulunan alternatif sayısı: ${alternatifler.length}');
      for (int i = 0; i < alternatifler.length && i < 3; i++) {
        final alt = alternatifler[i];
        print('      ${i + 1}. ${alt.ad} (${alt.kalori.toInt()}kcal)');
      }
    }
    
    await HiveService.close();
    
  } catch (e, stackTrace) {
    print('❌ Test hatası: $e');
    print('Stack: $stackTrace');
  } finally {
    // Test bittiğinde geçici dizini ve içeriğini temizle
    try {
      await HiveService.close();
      tempDir.deleteSync(recursive: true);
      print('\n🧹 Geçici test veritabanı temizlendi.');
    } catch (e) {
      print('🧹 Temizlik sırasında hata: $e');
    }
  }
}
