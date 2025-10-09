import 'dart:convert';
import 'dart:io';

/// ============================================================================
/// MEGA YEMEK VERİTABANI OLUŞTURUCU - BÖLÜM 1/5
/// ============================================================================
/// 
/// HEDEF: 2000+ Yemek ve Ara Öğün
/// - 500+ Kahvaltı
/// - 800+ Ana Yemek (Öğle/Akşam)
/// - 400+ Ara Öğün 1 (Protein)
/// - 400+ Ara Öğün 2 (Dengeli)
/// 
/// Her yemeğin minimum 2-3 alternatifi garantili!
/// ============================================================================

void main() async {
  print('🚀 MEGA YEMEK VERİTABANI - BÖLÜM 1 BAŞLIYOR...\n');
  
  final generator = MegaYemekDB_Part1();
  
  // BÖLÜM 1: Kahvaltılar (200 yemek)
  await generator.kahvaltilariOlustur();
  
  print('\n✅ BÖLÜM 1 TAMAMLANDI!');
  print('📌 Devam için BÖLÜM 2 scriptini çalıştırın.');
}

class MegaYemekDB_Part1 {
  final String outputPath = 'assets/data/mega_db';
  int yemekId = 20000; // Mevcut yemeklerle çakışmamak için yüksek ID
  
  Future<void> kahvaltilariOlustur() async {
    print('\n📋 KAHVALTILAR oluşturuluyor...');
    final List<Map<String, dynamic>> yemekler = [];
    
    // 1. YUMURTA BAZLI KAHVALTILAR (80 yemek)
    print('   → Yumurta kahvaltıları...');
    yemekler.addAll(_yumurtaKahvaltilari());
    
    // 2. PEYNIR BAZLI KAHVALTILAR (60 yemek)
    print('   → Peynir kahvaltıları...');
    yemekler.addAll(_peynirKahvaltilari());
    
    // 3. TAHIL VE YULAF KAHVALTILAR (60 yemek)
    print('   → Tahıl kahvaltıları...');
    yemekler.addAll(_tahilKahvaltilari());
    
    await _kaydet('part1_kahvaltilar_${yemekler.length}.json', yemekler);
    print('✅ ${yemekler.length} kahvaltı oluşturuldu\n');
  }
  
  // ═══════════════════════════════════════════════════════
  // YUMURTA BAZLI KAHVALTILAR - 80 ÇEŞİT
  // ═══════════════════════════════════════════════════════
  
  List<Map<String, dynamic>> _yumurtaKahvaltilari() {
    return [
      // MENEMEN VARYASYONları (15 çeşit)
      _k("Klasik Menemen", "Domates biber yumurta", 
        ["Domates:150g", "Biber:80g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 280, 14, 12, 18),
      _k("Mantarlı Menemen", "Mantar domates yumurta", 
        ["Mantar:100g", "Domates:120g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 250, 15, 10, 16),
      _k("Ispanaklı Menemen", "Ispanak domates yumurta", 
        ["Ispanak:150g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 240, 16, 9, 15),
      _k("Sucuklu Menemen", "Sucuk domates yumurta", 
        ["Sucuk:50g", "Domates:120g", "Yumurta:2 adet", "Biber:60g"], 320, 18, 15, 20),
      _k("Peynirli Menemen", "Beyaz peynir domates yumurta", 
        ["Beyaz Peynir:60g", "Domates:120g", "Yumurta:2 adet", "Biber:70g"], 290, 19, 12, 17),
      _k("Kıymalı Menemen", "Kıyma domates yumurta", 
        ["Dana Kıyma:80g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 350, 24, 16, 14),
      _k("Kavurmalı Menemen", "Kavurma domates yumurta", 
        ["Kavurma:60g", "Domates:100g", "Yumurta:2 adet", "Biber:60g"], 340, 22, 18, 14),
      _k("Pastırmalı Menemen", "Pastırma domates yumurta", 
        ["Pastırma:50g", "Domates:120g", "Yumurta:2 adet", "Biber:60g"], 310, 20, 15, 16),
      _k("Patlıcanlı Menemen", "Patlıcan domates yumurta", 
        ["Patlıcan:150g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:15ml"], 260, 14, 12, 18),
      _k("Kabak Menemen", "Kabak domates yumurta", 
        ["Kabak:150g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 230, 14, 10, 16),
      _k("Acılı Menemen", "Acı biber domates yumurta", 
        ["Acı Biber:60g", "Domates:120g", "Yumurta:2 adet", "Yeşil Biber:60g"], 260, 14, 11, 17),
      _k("Lor Peynirli Menemen", "Lor peyniri domates yumurta", 
        ["Lor Peyniri:80g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 280, 20, 13, 15),
      _k("Soğanlı Menemen", "Soğan domates yumurta", 
        ["Soğan:80g", "Domates:120g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 260, 14, 12, 17),
      _k("Sarımsaklı Menemen", "Sarımsak domates yumurta", 
        ["Sarımsak:20g", "Domates:150g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 250, 14, 11, 16),
      _k("Köy Menemen", "Köy usulü sebzeli menemen", 
        ["Domates:100g", "Biber:60g", "Soğan:40g", "Yumurta:2 adet", "Tereyağı:15g"], 290, 15, 14, 16),
      
      // OMLET ÇEŞİTLERİ (20 çeşit)
      _k("Beyaz Peynirli Omlet", "Yumurta beyaz peynir", 
        ["Yumurta:3 adet", "Beyaz Peynir:60g", "Süt:50ml", "Maydanoz:10g"], 300, 22, 13, 15),
      _k("Kaşarlı Omlet", "Yumurta kaşar", 
        ["Yumurta:3 adet", "Kaşar Peyniri:60g", "Süt:30ml"], 310, 24, 14, 12),
      _k("Sebzeli Omlet", "Yumurta karışık sebze", 
        ["Yumurta:3 adet", "Brokoli:80g", "Havuç:50g", "Biber:60g"], 260, 20, 10, 14),
      _k("Mantarlı Omlet", "Yumurta mantar soğan", 
        ["Yumurta:3 adet", "Mantar:100g", "Soğan:40g", "Zeytinyağı:10ml"], 240, 19, 9, 13),
      _k("Ispanaklı Omlet", "Yumurta ıspanak lor", 
        ["Yumurta:3 adet", "Ispanak:100g", "Lor Peyniri:50g"], 270, 21, 11, 14),
      _k("Sosisli Omlet", "Yumurta sosis", 
        ["Yumurta:3 adet", "Sosis:70g", "Kaşar:30g"], 320, 21, 16, 12),
      _k("Sucuklu Omlet", "Yumurta sucuk", 
        ["Yumurta:3 adet", "Sucuk:60g", "Domates:60g"], 350, 22, 18, 14),
      _k("Jambon Omlet", "Yumurta jambon kaşar", 
        ["Yumurta:3 adet", "Jambon:60g", "Kaşar:40g"], 340, 26, 17, 10),
      _k("Kıymalı Omlet", "Yumurta kıyma", 
        ["Yumurta:3 adet", "Dana Kıyma:80g", "Soğan:30g"], 370, 28, 19, 12),
      _k("Pastırmalı Omlet", "Yumurta pastırma", 
        ["Yumurta:3 adet", "Pastırma:50g", "Biber:40g"], 330, 24, 17, 11),
      _k("Domatesli Omlet", "Yumurta domates fesleğen", 
        ["Yumurta:3 adet", "Domates:120g", "Fesleğen:10g"], 250, 19, 11, 14),
      _k("Zeytinli Omlet", "Yumurta siyah zeytin", 
        ["Yumurta:3 adet", "Siyah Zeytin:50g", "Kaşar:30g"], 270, 19, 14, 10),
      _k("Feta Omlet", "Yumurta feta peyniri", 
        ["Yumurta:3 adet", "Feta:60g", "Fesleğen:10g"], 290, 21, 15, 11),
      _k("Avokado Omlet", "Yumurta avokado", 
        ["Yumurta:3 adet", "Avokado:100g", "Domates:50g"], 340, 20, 22, 16),
      _k("Ton Balıklı Omlet", "Yumurta ton balığı", 
        ["Yumurta:3 adet", "Ton Balığı:80g", "Maydanoz:10g"], 310, 30, 14, 8),
      _k("Somon Füme Omlet", "Yumurta füme somon", 
        ["Yumurta:3 adet", "Füme Somon:70g", "Dereotu:10g"], 330, 28, 16, 8),
      _k("Kabak Omlet", "Yumurta kabak", 
        ["Yumurta:3 adet", "Kabak:150g", "Soğan:30g"], 240, 19, 9, 15),
      _k("Patates Omlet", "Yumurta patates", 
        ["Yumurta:3 adet", "Patates:120g", "Soğan:40g"], 320, 20, 12, 28),
      _k("Brokoli Omlet", "Yumurta brokoli kaşar", 
        ["Yumurta:3 adet", "Brokoli:120g", "Kaşar:40g"], 280, 23, 13, 14),
      _k("Mısırlı Omlet", "Yumurta mısır", 
        ["Yumurta:3 adet", "Mısır:80g", "Süt:40ml"], 280, 20, 11, 22),
      
      // HAŞLANMIŞ YUMURTA MENÜLERI (15 çeşit)
      _k("Klasik Haşlanmış Yumurta", "Yumurta ekmek zeytin", 
        ["Yumurta:2 adet", "Tam Buğday Ekmeği:2 dilim", "Siyah Zeytin:10 adet"], 320, 18, 14, 28),
      _k("Rafadan Yumurta Menü", "Rafadan yumurta peynir", 
        ["Yumurta:2 adet", "Beyaz Peynir:60g", "Salatalık:100g"], 280, 20, 16, 12),
      _k("Katı Yumurta Kahvaltı", "Katı yumurta ekmek", 
        ["Yumurta:2 adet", "Kepek Ekmeği:2 dilim", "Domates:100g"], 280, 18, 12, 26),
      _k("Yoğurtlu Yumurta", "Yumurta yoğurt", 
        ["Yumurta:2 adet", "Yoğurt:150g", "Zeytinyağı:5ml"], 260, 20, 14, 16),
      _k("Zeytinli Yumurta Tabağı", "Yumurta karma zeytin", 
        ["Yumurta:2 adet", "Yeşil Zeytin:10 adet", "Domates:150g"], 270, 16, 16, 14),
      _k("Peynirli Yumurta Tabağı", "Yumurta lor peyniri", 
        ["Yumurta:2 adet", "Lor Peyniri:100g", "Salatalık:80g"], 300, 24, 16, 12),
      _k("Sebzeli Yumurta Tabağı", "Yumurta sebze çubukları", 
        ["Yumurta:2 adet", "Havuç:100g", "Salatalık:100g", "Yeşil Biber:60g"], 240, 16, 12, 18),
      _k("Avokado Yumurta Tabağı", "Yumurta avokado", 
        ["Yumurta:2 adet", "Avokado:120g", "Zeytinyağı:5ml"], 340, 18, 22, 18),
      _k("Humus Yumurta", "Yumurta humus", 
        ["Yumurta:2 adet", "Humus:100g", "Tam Buğday Ekmeği:1 dilim"], 320, 20, 16, 24),
      _k("Yumurta Salata", "Yumurta yeşillik", 
        ["Yumurta:2 adet", "Marul:100g", "Roka:50g", "Domates:100g"], 250, 17, 13, 14),
      _k("Tam Tahıl Yumurta", "Yumurta tam tahıl ekmek", 
        ["Yumurta:2 adet", "Tam Tahıl Ekmeği:2 dilim", "Tereyağı:10g"], 330, 19, 15, 30),
      _k("Çavdar Yumurta", "Yumurta çavdar ekmeği", 
        ["Yumurta:2 adet", "Çavdar Ekmeği:2 dilim", "Beyaz Peynir:40g"], 320, 20, 13, 28),
      _k("Kinoa Yumurta", "Yumurta kinoa", 
        ["Yumurta:2 adet", "Kinoa:80g", "Zeytinyağı:10ml"], 340, 22, 14, 32),
      _k("Yulaf Yumurta", "Yumurta yulaf", 
        ["Yumurta:2 adet", "Yulaf:60g", "Süt:150ml"], 340, 22, 14, 36),
      _k("Protein Yumurta", "Sadece yumurta", 
        ["Yumurta:4 adet"], 320, 28, 22, 2),
      
      // ÖZEL PİŞİRME YÖNTEMLERİ (15 çeşit)
      _k("Zeytinyağı Sahanda", "Zeytinyağında sahanda yumurta", 
        ["Yumurta:2 adet", "Zeytinyağı:15ml", "Pul Biber"], 240, 14, 16, 2),
      _k("Fırın Yumurta", "Fırında pişmiş yumurta", 
        ["Yumurta:2 adet", "Domates:100g", "Kaşar:30g"], 270, 18, 15, 12),
      _k("Poşe Yumurta", "Poşe edilmiş yumurta", 
        ["Yumurta:2 adet", "Sirke:10ml", "Tam Buğday Ekmeği:1 dilim"], 200, 15, 12, 16),
      _k("Çılbır", "Yoğurtlu poşe yumurta", 
        ["Yumurta:2 adet", "Süzme Yoğurt:150g", "Tereyağı:10g"], 310, 20, 16, 15),
      _k("Izgara Yumurta", "Izgara domates yumurta", 
        ["Yumurta:2 adet", "Domates:200g", "Zeytinyağı:10ml"], 230, 14, 12, 14),
      _k("Yumurtalı Ekmek", "Ekmek içinde yumurta", 
        ["Ekmek:2 dilim", "Yumurta:2 adet", "Süt:30ml"], 340, 20, 14, 32),
      _k("Shakshuka", "Domates soslu yumurta", 
        ["Yumurta:2 adet", "Domates Sosu:200g", "Biber:80g"], 280, 15, 13, 20),
      _k("İtalyan Frittata", "Sebzeli İtalyan omleti", 
        ["Yumurta:3 adet", "Patlıcan:100g", "Kabak:80g", "Parmesan:30g"], 300, 20, 15, 16),
      _k("İspanyol Tortilla", "Patatesli omlet", 
        ["Yumurta:3 adet", "Patates:150g", "Soğan:60g"], 340, 18, 14, 30),
      _k("Benedict Yumurta", "Poşe yumurta muffin", 
        ["Yumurta:2 adet", "Tam Buğday Muffin:1 adet", "Yoğurt Sos:50g"], 320, 22, 14, 28),
      _k("Japon Tamagoyaki", "Tatlı Japon omleti", 
        ["Yumurta:3 adet", "Soya Sosu:10ml", "Şeker:5g"], 260, 18, 14, 12),
      _k("Huevos Rancheros", "Meksika usulü yumurta", 
        ["Yumurta:2 adet", "Fasulye:100g", "Tortilla:1 adet"], 350, 20, 14, 35),
      _k("Yumurta Muffin", "Fırın yumurta kekleri", 
        ["Yumurta:3 adet", "Sebze:100g", "Lor Peyniri:60g"], 260, 21, 12, 14),
      _k("Cloud Eggs", "Bulut yumurta", 
        ["Yumurta:2 adet", "Parmesan:20g", "Tuz Karabiber"], 220, 16, 14, 5),
      _k("Avokado Teknesi", "Avokado içinde yumurta", 
        ["Avokado:1 adet", "Yumurta:2 adet", "Baharatlar"], 320, 16, 22, 18),
      
      // SANDVİÇ VE WRAP (15 çeşit)
      _k("Yumurtalı Sandviç", "Haşlanmış yumurta sandviç", 
        ["Yumurta:2 adet", "Tam Buğday Ekmeği:2 dilim", "Marul:50g"], 310, 18, 14, 28),
      _k("Omlet Sandviç", "Omlet dolgulu sandviç", 
        ["Yumurta:2 adet", "Ekmek:2 dilim", "Kaşar:40g"], 340, 22, 16, 30),
      _k("Scrambled Egg Sandviç", "Çırpılmış yumurta sandviç", 
        ["Yumurta:2 adet", "Ekmek:2 dilim", "Sebze:80g"], 320, 19, 14, 28),
      _k("Yumurta Wrap", "Yumurta tortilla wrap", 
        ["Yumurta:2 adet", "Tortilla:1 adet", "Sebze:100g"], 310, 18, 13, 28),
      _k("Protein Yumurta Wrap", "Yüksek protein wrap", 
        ["Yumurta Akı:4 adet", "Yumurta:1 adet", "Wrap:1 adet"], 320, 28, 10, 26),
      _k("Avokado Yumurta Sandviç", "Yumurta avokado ekmek", 
        ["Yumurta:2 adet", "Avokado:80g", "Ekmek:2 dilim"], 380, 18, 18, 32),
      _k("Sebzeli Yumurta Wrap", "Yumurta sebze wrap", 
        ["Yumurta:2 adet", "Sebze:150g", "Wrap:1 adet"], 300, 18, 12, 30),
      _k("Peynirli Yumurta Sandviç", "Yumurta peynir sandviç", 
        ["Yumurta:2 adet", "Beyaz Peynir:60g", "Ekmek:2 dilim"], 340, 22, 16, 28),
      _k("Füme Somon Yumurta", "Yumurta somon sandviç", 
        ["Yumurta:2 adet", "Füme Somon:60g", "Ekmek:2 dilim"], 360, 26, 16, 26),
      _k("Hindi Füme Yumurta", "Yumurta hindi sandviç", 
        ["Yumurta:2 adet", "Hindi Füme:60g", "Ekmek:2 dilim"], 340, 28, 14, 26),
      _k("Ton Yumurta Sandviç", "Yumurta ton sandviç", 
        ["Yumurta:2 adet", "Ton Balığı:60g", "Ekmek:2 dilim"], 350, 30, 14, 26),
      _k("Humus Yumurta Wrap", "Yumurta humus wrap", 
        ["Yumurta:2 adet", "Humus:80g", "Wrap:1 adet"], 350, 20, 16, 32),
      _k("Kısır Yumurta Wrap", "Yumurta kısır wrap", 
        ["Yumurta:1 adet", "Kısır:100g", "Wrap:1 adet"], 340, 16, 12, 42),
      _k("Ezme Yumurta Sandviç", "Yumurta ezme sandviç", 
        ["Yumurta:2 adet", "Acuka:50g", "Ekmek:2 dilim"], 320, 18, 14, 30),
      _k("Yoğurt Soslu Yumurta Wrap", "Yumurta yoğurt sos wrap", 
        ["Yumurta:2 adet", "Yoğurt Sos:60g", "Wrap:1 adet"], 300, 19, 13, 26),
    ];
  }
  
  // ═══════════════════════════════════════════════════════
  // PEYNIR BAZLI KAHVALTILAR - 60 ÇEŞİT
  // ═══════════════════════════════════════════════════════
  
  List<Map<String, dynamic>> _peynirKahvaltilari() {
    return [
      // PEYNIR TABAKLARI (15 çeşit)
      _k("Klasik Peynir Tabağı", "Beyaz peynir zeytin domates", 
        ["Beyaz Peynir:100g", "Siyah Zeytin:15 adet", "Domates:150g"], 280, 16, 18, 12),
      _k("Karma Peynir Tabağı", "Beyaz kaşar tulum", 
        ["Beyaz Peynir:60g", "Kaşar:40g", "Tulum Peyniri:40g"], 360, 22, 24, 10),
      _k("Lor Peyniri Tabağı", "Lor bal ceviz", 
        ["Lor Peyniri:150g", "Bal:20g", "Ceviz:30g"], 320, 20, 16, 28),
      _k("Çökelek Kahvaltısı", "Çökelek domates yeşillik", 
        ["Çökelek:150g", "Domates:150g", "Roka:50g"], 240, 18, 12, 14),
      _k("Light Peynir Tabağı", "Az yağlı peynir sebze", 
        ["Light Beyaz Peynir:120g", "Sebze:200g"], 200, 20, 8, 16),
      _k("Feta Tabağı", "Feta peyniri zeytinyağı", 
        ["Feta Peyniri:120g", "Zeytinyağı:10ml", "Domates:150g"], 300, 18, 20, 14),
      _k("Ezine Peyniri Özel", "Ezine peyniri bal ceviz", 
        ["Ezine Peyniri:120g", "Bal:20g", "Ceviz:25g"], 340, 20, 22, 18),
      _k("Mihaliç Peyniri", "Mihaliç peynir tabağı", 
        ["Mihaliç Peyniri:100g", "Yeşillik:100g"], 280, 18, 20, 10),
      _k("Tulum Peyniri Özel", "Erzincan tulum bal ceviz", 
        ["Tulum Peyniri:100g", "Bal:20g", "Ceviz:30g"], 360, 20, 24, 16),
      _k("Kaşar Peyniri Tabağı", "Kaşar zeytin", 
        ["Kaşar Peyniri:100g", "Yeşil Zeytin:15 adet"], 320, 20, 22, 10),
      _k("Kars Kaşarı", "Kars kaşar tabağı", 
        ["Kars Kaşarı:100g", "Ceviz:30g"], 340, 22, 24, 12),
      _k("Van Otlu Peynir", "Van otlu peynir", 
        ["Otlu Peynir:120g", "Domates:150g"], 300, 20, 20, 14),
      _k("Divle Obruk Peyniri", "Divle küflü peynir bal", 
        ["Divle Peyniri:100g", "Bal:20g"], 320, 18, 22, 16),
      _k("Hellim Peyniri", "Kıbrıs hellim karpuz", 
        ["Hellim:120g", "Karpuz:100g"], 340, 22, 22, 18),
      _k("Labne Tabağı", "Labne zeytinyağı zatar", 
        ["Labne:150g", "Zeytinyağı:15ml", "Zatar"], 280, 16, 18, 14),
      
      // PEYNIRLI BÖREKLER (15 çeşit)
      _k("Peynirli Börek", "El yapımı yufka böreği", 
        ["Yufka:2 yaprak", "Beyaz Peynir:80g", "Yumurta:1 adet"], 340, 16, 14, 36),
      _k("Su Böreği", "Peynirli su böreği", 
        ["Yufka:3 yaprak", "Beyaz Peynir:100g", "Tereyağı:20g"], 380, 18, 18, 38),
      _k("Sigara Böreği", "Rulo peynirli börek", 
        ["Yufka:3 yaprak", "Beyaz Peynir:90g", "Maydanoz:40g"], 360, 17, 16, 36),
      _k("Açma Peynirli", "Peynirli açma", 
        ["Açma:2 adet", "Beyaz Peynir:60g", "Domates:80g"], 380, 14, 14, 48),
      _k("Gözleme", "Peynirli gözleme", 
        ["Hamur:150g", "Beyaz Peynir:80g", "Maydanoz:40g"], 400, 18, 16, 44),
      _k("Ispanaklı Peynirli Börek", "Ispanak peynir börek", 
        ["Yufka:2 yaprak", "Ispanak:100g", "Beyaz Peynir:60g"], 340, 18, 14, 34),
      _k("Patatesli Peynirli Börek", "Patates peynir börek", 
        ["Yufka:2 yaprak", "Patates:120g", "Kaşar:60g"], 400, 16, 18, 42),
      _k("Kıymalı Peynirli Börek", "Kıyma peynir börek", 
        ["Yufka:2 yaprak", "Kıyma:80g", "Kaşar:60g"], 420, 24, 20, 36),
      _k("Mantarlı Peynirli Börek", "Mantar peynir börek", 
        ["Yufka:2 yaprak", "Mantar:100g", "Beyaz Peynir:60g"], 330, 16, 13, 36),
      _k("Milföy Peynir", "Peynirli milföy", 
        ["Milföy:100g", "Kaşar:60g", "Yumurta:1 adet"], 370, 15, 18, 38),
      _k("Poğaça Peynirli", "Peynirli poğaça", 
        ["Hamur:100g", "Beyaz Peynir:60g", "Çörekotu:5g"], 360, 16, 16, 40),
      _k("Çiğ Börek", "Peynirli çiğ börek", 
        ["Hamur:120g", "Beyaz Peynir:80g"], 380, 18, 16, 42),
      _k("Katmer Peynirli", "Peynirli katmer", 
        ["Hamur:100g", "Kaşar:60g", "Tereyağı:20g"], 400, 18, 18, 44),
      _k("Simit Peynirli", "Simit peynir", 
        ["Simit:1 adet", "Beyaz Peynir:80g"], 340, 16, 14, 42),
      _k("Bazlama Peynirli", "Bazlama peynir", 
        ["Bazlama:1 adet", "Kaşar:70g"], 380, 18, 16, 42),
      
      // PEYNİRLİ SANDVİÇ VE TOST (15 çeşit)
      _k("Kaşarlı Tost", "Klasik kaşar tost", 
        ["Ekmek:2 dilim", "Kaşar:60g", "Domates:80g"], 320, 18, 14, 32),
      _k("Karışık Tost", "Kaşar sucuk tost", 
        ["Ekmek:2 dilim", "Kaşar:50g", "Sucuk:40g"], 380, 20, 18, 32),
      _k("Peynir Muffin", "Fırın peynir muffin", 
        ["Tam Buğday Unu:100g", "Beyaz Peynir:80g", "Yumurta:2 adet"], 320, 20, 14, 28),
      _k("Peynirli Pankek", "Peynir dolgulu pankek", 
        ["Yulaf Unu:80g", "Lor Peyniri:100g", "Yumurta:2 adet"], 340, 22, 12, 32),
      _k("Peynir Kurabiyesi", "Tuzlu peynir kurabiye", 
        ["Un:100g", "Kaşar:60g", "Tereyağı:30g"], 380, 16, 18, 40),
      _k("Peynirli Krep", "Peynir dolgulu krep", 
        ["Krep:2 adet", "Beyaz Peynir:80g", "Maydanoz:20g"], 300, 16, 12, 34),
      _k("Mozzarella Ekmek", "Mozzarella domates fesleğen", 
        ["Ekmek:2 dilim", "Mozzarella:80g", "Domates:100g"], 310, 18, 14, 30),
      Dosyada çok fazla syntax hatası var. _k("Labne Sandviç", "Labne Temizden başlayarak çok kapsamlı bir yemek veritabanı oluşturacağım. Token limiti nedeniyle bölüm bölüm çalışacak şekilde yapılandırıyorum.

<write_to_file>
<path>MEGA_YEMEK_PLAN.md</path>
<content># zeytin ezmesi sebze", 
        🍽️ MEGA YEMEK VERİTABANI PLANI

## 🎯 Hedef: 1500+ Yemek ve Ara Öğün

### 📊 Kategoriler ["Ekmek:2 dilim", ve Hedefler

"Labne:80g", "Zeytin Ezmesi:30g"], 300, 14, 12, 36),
      #### KAHVALTILAR (400+ yemek)
- _k("Ricotta Bal Sandviç", Yumurta "Ricotta peynir bal Bazlı: 80 çeşit
- Peynir Bazlı: 80 çeşit  
- Tahıl/Yulaf: 60 çeşit
- Smoothie/Shake: 60 çeşit
fındık", 
        ["Ekmek:2 - Protein dilim", "Ricotta:100g", "Bal:20g", "Fındık:20g"], 360, 16, 16, Ağırlıklı: 60 çeşit
38),
      _k("Cottage Cheese Bowl", "Cottage cheese meyve", 
        ["Cottage Cheese:150g", "Çilek:100g", "Yaban Mersini:50g"], 220, 18, - Fit/Sağlıklı: 6, 24),
      _k("Quark 60 çeşit

#### ANA YEMEKLER (600+ yemek)
Kahvaltı", "Quark - Tavuk: 120 çeşit
meyve badem", 
        ["Quark:150g", - Kırmızı Et: 100 çeşit
"Meyve:100g", "Badem:20g"], - Balık/Deniz Ürünleri: 100 280, 20, 12, çeşit
- 24),
      Vejetaryen: 80 çeşit
- Makarna/Pilav: 80 _k("Skyr İskandinav", "Skyr granola meyve", 
        ["Skyr:150g", "Granola:50g", çeşit
- Güveç/Fırın: 60 "Meyve:80g"], 300, 22, çeşit
- 8, 36),
      Hindi/Diğer: 60 çeşit

#### ARA _k("Krem ÖĞÜN 1 (300+ atıştırmalık)
Peynir Somon", "Krem peynir füme somon", 
        ["Krem Peynir:80g", "Füme Somon:60g", - Süzme "Ekmek:2 dilim"], Yoğurt Kombinasyonları: 360, 24, 18, 28),
      80 çeşit
_k("Halloumi Izgara", - Protein Bar/Top: 60 "Izgara halloumi domates", 
        ["Halloumi:120g", "Domates:150g", çeşit
- Peynir "Roka:50g"], 340, 22, 22, 12),
      _k("Feta Ispanak", "Feta Tabakları: 50 çeşit
- Protein Shake: 50 çeşit
ıspanak omlet", 
        - Kuru ["Feta:60g", "Ispanak:100g", Yemiş Karışımları: 60 çeşit

#### ARA ÖĞÜN 2 "Yumurta:2 adet"], 300, (300+ atıştırmalık)
- 22, 18, 12),
      
      // ÖZEL PEYNİRLER (15 çeşit)
      Meyve Kombinasyonları: 80 çeşit
- Sandviç/Tost: _k("Keçi Peyniri 80 çeşit
- Wrap/Dürüm: 60 çeşit
- Salatası", "Keçi Smoothie Bowl: 40 peyniri yeşillik ceviz", 
        ["Keçi Peyniri:80g", çeşit
- Granola/Enerji Top: 40 "Yeşillik:150g", çeşit

## 📝 "Ceviz:25g"], 280, Her 16, 20, 12),
      _k("Blue Cheese Yemeğin Özellikleri

✅ **Her yemeğin Armut", "Mavi peynir armut bal", 
        minimum 2-3 ["Mavi Peynir:60g", "Armut:150g", alternatifi**
✅ Malzeme "Bal:20g"], 300, 14, 16, 32),
      listesi
✅ Kalori, protein, yağ, _k("Brie Elma", karbonhidrat bilgisi
"Brie peynir elma fındık", 
        ✅ ["Brie:80g", "Elma:150g", "Fındık:20g"], 320, Kategori ve öğün tipi
✅ Hazırlama süresi

## 🔄 Bölümler

14, 20, 28),
      ### BÖLÜM _k("Camembert Tatlı", "Camembert üzüm badem", 
        ["Camembert:80g", "Üzüm:100g", "Badem:25g"], 1: Kahvaltılar (400)
- Script: 340, 16, 22, 24),
      `olustur_bolum1_kahvaltilar.dart`

### BÖLÜM 2: Ana Yemekler Tavuk _k("Gouda Sandviç", "Gouda domates sandviç", 
        (120)
- Script: `olustur_bolum2_tavuk.dart`

### BÖLÜM 3: ["Ekmek:2 Ana Yemekler Et (100)
- Script: `olustur_bolum3_et.dart`

dilim", "Gouda:70g", "Domates:100g"], 330, 18, ### BÖLÜM 4: Ana Yemekler Balık 16, 30),
      _k("Cheddar Sandviç", (100)
- Script: `olustur_bolum4_balik.dart`

### "Cheddar avokado sandviç", 
        ["Ekmek:2 BÖLÜM 5: Diğer Ana Yemekler (280)
- Script: dilim", "Cheddar:70g", `olustur_bolum5_diger_ana.dart`

"Avokado:80g"], 380, 18, ### BÖLÜM 6: Ara Öğün 1 (300)
- Script: 20, 32),
      _k("Emmental Sandviç", "Emmental `olustur_bolum6_ara1.dart`

### BÖLÜM 7: peynir sandviç", 
        ["Ekmek:2 dilim", Ara Öğün 2 (300)
- Script: "Emmental:70g", "Marul:50g"], `olustur_bolum7_ara2.dart`

## 340, 20, 16, 30),
      _k("Provolone 🚀 Toplam: 1600+ Sandviç", "Provolone domates sandviç", 
        ["Ekmek:2 dilim", "Provolone:70g", "Domates:100g"], 330, Yemek

Her 18, 16, 30),
      yemeğin 2-3 alternatifi olduğundan gerçek çeşitlilik _k("Gruyere Sandviç", çok daha fazla!
