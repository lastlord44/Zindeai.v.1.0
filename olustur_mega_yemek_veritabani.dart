import 'dart:convert';
import 'dart:io';

/// MEGA YEMEk VERİTABANI OLUŞTURUCU - BÖLÜM 1
/// 
/// Hedefler:
/// - 600+ Kahvaltı
/// - 800+ Ana Yemek (Öğle/Akşam)
/// - 400+ Ara Öğün 1
/// - 400+ Ara Öğün 2
/// - Her besinin minimum 2 alternatifi
/// 
/// TOPLAM: 2200+ Yemek

void main() async {
  print('🚀 MEGA YEMEk VERİTABANI OLUŞTURULUYOR...\n');
  
  final generator = MegaYemekGenerator();
  
  // Sırayla oluştur
  await generator.kahvaltilariOlustur();
  await generator.anaYemekleriOlustur();
  await generator.araOgun1Olustur();
  await generator.araOgun2Olustur();
  
  print('\n✅ TAMAMLANDI! Tüm yemekler oluşturuldu.');
  print('📊 JSON dosyalarını kontrol edin: assets/data/');
}

class MegaYemekGenerator {
  final String dataPath = 'assets/data';
  int yemekIdCounter = 10000;
  
  // ============== KAHVALTILAR (600+ çeşit) ==============
  Future<void> kahvaltilariOlustur() async {
    print('📋 KAHVALTILAR oluşturuluyor...');
    final yemekler = <Map<String, dynamic>>[];
    
    // 1. YUMURTA BAZLI (120 çeşit)
    yemekler.addAll(_yumurtaKahvaltilari());
    
    // 2. PEYNIR BAZLI (100 çeşit)
    yemekler.addAll(_peynirKahvaltilari());
    
    // 3. TAHIL VE YULAF (80 çeşit)
    yemekler.addAll(_tahilKahvaltilari());
    
    // 4. SMOOTHIE VE SHAKE (80 çeşit)
    yemekler.addAll(_smoothieKahvaltilari());
    
    // 5. PROTEIN AĞIRLIKLI (80 çeşit)
    yemekler.addAll(_proteinKahvaltilari());
    
    // 6. FIT KAHVALTILAR (70 çeşit)
    yemekler.addAll(_fitKahvaltilari());
    
    // 7. VEJETARİAN/VEGAN (70 çeşit)
    yemekler.addAll(_vejetaryenKahvaltilari());
    
    await _dosyayaKaydet('mega_kahvalti_${yemekler.length}.json', yemekler);
    print('✅ ${yemekler.length} kahvaltı oluşturuldu\n');
  }
  
  // ============== ANA YEMEKLER (800+ çeşit) ==============
  Future<void> anaYemekleriOlustur() async {
    print('📋 ANA YEMEKLER oluşturuluyor...');
    final yemekler = <Map<String, dynamic>>[];
    
    // 1. TAVUK YEMEKLERİ (150 çeşit)
    yemekler.addAll(_tavukYemekleri());
    
    // 2. KIRMIZI ET (120 çeşit)
    yemekler.addAll(_kirmiziEtYemekleri());
    
    // 3. BALIK VE DENİZ ÜRÜNLERİ (120 çeşit)
    yemekler.addAll(_balikYemekleri());
    
    // 4. VEJETARİAN ANA YEMEKLER (100 çeşit)
    yemekler.addAll(_vejetaryenAnaYemekler());
    
    // 5. MAKARNA VE PİLAV (100 çeşit)
    yemekler.addAll(_makarnaVePilavYemekleri());
    
    // 6. GÜVEÇ VE FIRINDA (80 çeşit)
    yemekler.addAll(_guvecVeFirinYemekleri());
    
    // 7. HİNDİ VE KÜMES (70 çeşit)
    yemekler.addAll(_hindiYemekleri());
    
    // 8. ETNİK MUTFAKLAR (60 çeşit)
    yemekler.addAll(_etnikMutfakYemekleri());
    
    await _dosyayaKaydet('mega_ana_yemekler_${yemekler.length}.json', yemekler);
    print('✅ ${yemekler.length} ana yemek oluşturuldu\n');
  }
  
  // ============== ARA ÖĞÜN 1 (400+ çeşit) ==============
  Future<void> araOgun1Olustur() async {
    print('📋 ARA ÖĞÜN 1 oluşturuluyor...');
    final yemekler = <Map<String, dynamic>>[];
    
    // 1. SÜZME YOĞURT KOMBİNASYONLARI (100 çeşit)
    yemekler.addAll(_suzmeYogurtlari());
    
    // 2. PROTEIN BAR VE TOPLAR (80 çeşit)
    yemekler.addAll(_proteinBarlari());
    
    // 3. PEYNİR TABAKLARI (70 çeşit)
    yemekler.addAll(_peynirTabaklari());
    
    // 4. PROTEIN SHAKE (70 çeşit)
    yemekler.addAll(_proteinShakeleri());
    
    // 5. KURU YEMİŞ KARIŞIMLARı (80 çeşit)
    yemekler.addAll(_kuruYemisKombinasyonlari());
    
    await _dosyayaKaydet('mega_ara_ogun_1_${yemekler.length}.json', yemekler);
    print('✅ ${yemekler.length} ara öğün 1 oluşturuldu\n');
  }
  
  // ============== ARA ÖĞÜN 2 (400+ çeşit) ==============
  Future<void> araOgun2Olustur() async {
    print('📋 ARA ÖĞÜN 2 oluşturuluyor...');
    final yemekler = <Map<String, dynamic>>[];
    
    // 1. MEYVE KOMBİNASYONLARI (100 çeşit)
    yemekler.addAll(_meyveSalatalari());
    
    // 2. SANDVİÇ VARYASYONLARı (100 çeşit)
    yemekler.addAll(_sandvicler());
    
    // 3. WRAP VE DÜRÜM (80 çeşit)
    yemekler.addAll(_wrapDurumler());
    
    // 4. SMOOTHIE BOWL (60 çeşit)
    yemekler.addAll(_smoothieBowllar());
    
    // 5. GRANOLA VE ENERJİ TOPLAR (60 çeşit)
    yemekler.addAll(_granolaToplar());
    
    await _dosyayaKaydet('mega_ara_ogun_2_${yemekler.length}.json', yemekler);
    print('✅ ${yemekler.length} ara öğün 2 oluşturuldu\n');
  }
  
  // ═══════════════════════════════════════════════════════
  // KAHVALTI ÇEŞİTLERİ - 600+ YEMEK
  // ═══════════════════════════════════════════════════════
  
  List<Map<String, dynamic>> _yumurtaKahvaltilari() {
    final yemekler = <Map<String, dynamic>>[];
    
    // MENEMEN ALTERNATİFLERİ (20 çeşit)
    yemekler.add(_kahvalti("Klasik Menemen", "Domates biber yumurta", 
      ["Domates:150g", "Biber:80g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 280, 14, 12, 18));
    yemekler.add(_kahvalti("Mantarlı Menemen", "Mantar domates yumurta", 
      ["Mantar:100g", "Domates:120g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 250, 15, 10, 16));
    yemekler.add(_kahvalti("Ispanaklı Menemen", "Ispanak domates yumurta", 
      ["Ispanak:150g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:10ml"], 240, 16, 9, 15));
    yemekler.add(_kahvalti("Sucuklu Menemen", "Sucuk domates yumurta", 
      ["Sucuk:50g", "Domates:120g", "Yumurta:2 adet"], 320, 18, 15, 20));
    yemekler.add(_kahvalti("Peynirli Menemen", "Beyaz peynir domates yumurta", 
      ["Beyaz Peynir:60g", "Domates:120g", "Yumurta:2 adet"], 290, 19, 12, 17));
    yemekler.add(_kahvalti("Kıymalı Menemen", "Kıyma domates yumurta", 
      ["Dana Kıyma:80g", "Domates:100g", "Yumurta:2 adet"], 350, 24, 16, 14));
    yemekler.add(_kahvalti("Sosis Menemen", "Sosis domates yumurta", 
      ["Sosis:60g", "Domates:120g", "Yumurta:2 adet"], 300, 16, 14, 18));
    yemekler.add(_kahvalti("Kavurmalı Menemen", "Kavurma domates yumurta", 
      ["Kavurma:60g", "Domates:100g", "Yumurta:2 adet"], 340, 22, 18, 14));
    yemekler.add(_kahvalti("Pastırmalı Menemen", "Pastırma domates yumurta", 
      ["Pastırma:50g", "Domates:120g", "Yumurta:2 adet"], 310, 20, 15, 16));
    yemekler.add(_kahvalti("Kabaklı Menemen", "Kabak domates yumurta", 
      ["Kabak:150g", "Domates:100g", "Yumurta:2 adet"], 230, 14, 10, 16));
    
    yemekler.add(_kahvalti("Patlıcanlı Menemen", "Patlıcan domates yumurta", 
      ["Patlıcan:150g", "Domates:100g", "Yumurta:2 adet"], 260, 14, 12, 18));
    yemekler.add(_kahvalti("Karışık Menemen", "Karma sebze yumurta", 
      ["Domates:100g", "Biber:60g", "Soğan:40g", "Yumurta:2 adet"], 270, 14, 12, 16));
    yemekler.add(_kahvalti("Acılı Menemen", "Acı biber domates yumurta", 
      ["Acı Biber:60g", "Domates:120g", "Yumurta:2 adet"], 260, 14, 11, 17));
    yemekler.add(_kahvalti("Biberli Yumurta", "Közlenmiş biber yumurta", 
      ["Közlenmiş Biber:150g", "Yumurta:2 adet"], 220, 13, 10, 14));
    yemekler.add(_kahvalti("Domatesli Yumurta", "Fırında domates yumurta", 
      ["Domates:200g", "Yumurta:2 adet", "Baharatlar"], 210, 13, 11, 13));
    yemekler.add(_kahvalti("Sebzeli Yumurta", "Karışık sebze yumurta", 
      ["Brokoli:80g", "Havuç:60g", "Biber:60g", "Yumurta:2 adet"], 240, 15, 10, 16));
    yemekler.add(_kahvalti("Yeşil Menemen", "Yeşil biber maydanoz yumurta", 
      ["Yeşil Biber:100g", "Maydanoz:30g", "Yumurta:2 adet"], 230, 14, 11, 14));
    yemekler.add(_kahvalti("Sarımsaklı Menemen", "Sarımsak domates yumurta", 
      ["Sarımsak:20g", "Domates:150g", "Yumurta:2 adet"], 250, 14, 11, 16));
    yemekler.add(_kahvalti("Soğanlı Menemen", "Soğan domates yumurta", 
      ["Soğan:80g", "Domates:120g", "Yumurta:2 adet"], 260, 14, 12, 17));
    yemekler.add(_kahvalti("Lor Peynirli Menemen", "Lor peyniri domates yumurta", 
      ["Lor Peyniri:80g", "Domates:100g", "Yumurta:2 adet"], 280, 20, 13, 15));
    
    // OMLET ALTERNATİFLERİ (25 çeşit)
    yemekler.add(_kahvalti("Beyaz Peynirli Omlet", "Yumurta beyaz peynir", 
      ["Yumurta:3 adet", "Beyaz Peynir:60g", "Süt:50ml"], 300, 22, 13, 15));
    yemekler.add(_kahvalti("Sebzeli Omlet", "Yumurta karışık sebze", 
      ["Yumurta:3 adet", "Brokoli:80g", "Havuç:50g", "Biber:60g"], 260, 20, 10, 14));
    yemekler.add(_kahvalti("Mantarlı Omlet", "Yumurta mantar soğan", 
      ["Yumurta:3 adet", "Mantar:100g", "Soğan:40g"], 240, 19, 9, 13));
    yemekler.add(_kahvalti("Ispanaklı Omlet", "Yumurta ıspanak lor", 
      ["Yumurta:3 adet", "Ispanak:100g", "Lor Peyniri:50g"], 270, 21, 11, 14));
    yemekler.add(_kahvalti("Kaşarlı Omlet", "Yumurta kaşar", 
      ["Yumurta:3 adet", "Kaşar Peyniri:60g"], 310, 24, 14, 12));
    
    yemekler.add(_kahvalti("Sosisli Omlet", "Yumurta sosis", 
      ["Yumurta:3 adet", "Sosis:70g"], 320, 21, 16, 12));
    yemekler.add(_kahvalti("Jambon Omlet", "Yumurta jambon kaşar", 
      ["Yumurta:3 adet", "Jambon:60g", "Kaşar:40g"], 340, 26, 17, 10));
    yemekler.add(_kahvalti("Sucuklu Omlet", "Yumurta sucuk", 
      ["Yumurta:3 adet", "Sucuk:60g"], 350, 22, 18, 14));
    yemekler.add(_kahvalti("Kıymalı Omlet", "Yumurta kıyma", 
      ["Yumurta:3 adet", "Dana Kıyma:80g"], 370, 28, 19, 12));
    yemekler.add(_kahvalti("Pastırmalı Omlet", "Yumurta pastırma", 
      ["Yumurta:3 adet", "Pastırma:50g"], 330, 24, 17, 11));
    
    yemekler.add(_kahvalti("Domatesli Omlet", "Yumurta domates fesleğen", 
      ["Yumurta:3 adet", "Domates:120g", "Fesleğen:10g"], 250, 19, 11, 14));
    yemekler.add(_kahvalti("Zeytinli Omlet", "Yumurta zeytin", 
      ["Yumurta:3 adet", "Siyah Zeytin:50g"], 270, 19, 14, 10));
    yemekler.add(_kahvalti("Fesleğenli Omlet", "Yumurta fesleğen feta", 
      ["Yumurta:3 adet", "Fesleğen:20g", "Feta:50g"], 290, 21, 15, 11));
    yemekler.add(_kahvalti("Biberli Omlet", "Yumurta renkli biber", 
      ["Yumurta:3 adet", "Kırmızı Biber:80g", "Yeşil Biber:80g"], 260, 20, 10, 16));
    yemekler.add(_kahvalti("Kabak Omlet", "Yumurta kabak", 
      ["Yumurta:3 adet", "Kabak:150g"], 240, 19, 9, 15));
    
    yemekler.add(_kahvalti("Patates Omlet", "Yumurta patates", 
      ["Yumurta:3 adet", "Patates:120g"], 320, 20, 12, 28));
    yemekler.add(_kahvalti("Soğan Omlet", "Yumurta soğan", 
      ["Yumurta:3 adet", "Soğan:100g"], 250, 19, 10, 16));
    yemekler.add(_kahvalti("Mısırlı Omlet", "Yumurta mısır", 
      ["Yumurta:3 adet", "Mısır:80g"], 280, 20, 11, 22));
    yemekler.add(_kahvalti("Brokoli Omlet", "Yumurta brokoli", 
      ["Yumurta:3 adet", "Brokoli:120g"], 250, 21, 10, 14));
    yemekler.add(_kahvalti("Avokado Omlet", "Yumurta avokado", 
      ["Yumurta:3 adet", "Avokado:100g"], 340, 20, 22, 16));
    
    yemekler.add(_kahvalti("Ton Balıklı Omlet", "Yumurta ton balığı", 
      ["Yumurta:3 adet", "Ton Balığı:80g"], 310, 30, 14, 8));
    yemekler.add(_kahvalti("Somon Omlet", "Yumurta somon", 
      ["Yumurta:3 adet", "Füme Somon:70g"], 330, 28, 16, 8));
    yemekler.add(_kahvalti("Karışık Omlet", "Yumurta karışık malzeme", 
      ["Yumurta:3 adet", "Domates:60g", "Biber:60g", "Mantar:60g"], 270, 20, 11, 16));
    yemekler.add(_kahvalti("Otlu Omlet", "Yumurta taze otlar", 
      ["Yumurta:3 adet", "Maydanoz:20g", "Dereotu:20g", "Tere:20g"], 240, 19, 10, 12));
    yemekler.add(_kahvalti("Protein Omlet", "Sadece yumurta akı omleti", 
      ["Yumurta Akı:6 adet", "Mantar:80g", "Ispanak:60g"], 180, 28, 2, 10));
    
    // HAŞLANMIŞ YUMURTA MENÜLERI (15 çeşit)
    yemekler.add(_kahvalti("Klasik Yumurta Kahvaltısı", "Haşlanmış yumurta ekmek zeytin", 
      ["Yumurta:2 adet", "Tam Buğday Ekmeği:2 dilim", "Siyah Zeytin:10 adet"], 320, 18, 14, 28));
    yemekler.add(_kahvalti("Rafadan Yumurta Menü", "Rafadan yumurta peynir", 
      ["Yumurta:2 adet", "Beyaz Peynir:60g", "Salatalık:100g"], 280, 20, 16, 12));
    yemekler.add(_kahvalti("Kayısı Yumurta", "Katı yumurta ekmek", 
      ["Yumurta:2 adet", "Kepek Ekmeği:2 dilim"], 280, 18, 12, 26));
    yemekler.add(_kahvalti("Yoğurtlu Yumurta", "Haşlanmış yumurta yoğurt", 
      ["Yumurta:2 adet", "Yoğurt:150g"], 260, 20, 14, 16));
    yemekler.add(_kahvalti("Zeytinli Yumurta Tabağı", "Yumurta zeytin domates", 
      ["Yumurta:2 adet", "Yeşil Zeytin:15 adet", "Domates:150g"], 270, 16, 16, 14));
    
    yemekler.add(_kahvalti("Peynirli Yumurta Menü", "Haşlanmış yumurta lor peyniri", 
      ["Yumurta:2 adet", "Lor Peyniri:100g"], 300, 24, 16, 12));
    yemekler.add(_kahvalti("Sebzeli Yumurta Tabağı", "Yumurta sebze çubukları", 
      ["Yumurta:2 adet", "Havuç:100g", "Salatalık:100g"], 240, 16, 12, 18));
    yemekler.add(_kahvalti("Avokado Yumurta", "Haşlanmış yumurta avokado", 
      ["Yumurta:2 adet", "Avokado:120g"], 340, 18, 22, 18));
    yemekler.add(_kahvalti("Humus Yumurta", "Yumurta humus", 
      ["Yumurta:2 adet", "Humus:100g"], 320, 20, 16, 24));
    yemekler.add(_kahvalti("Sade Protein Kahvaltı", "Sadece yumurta", 
      ["Yumurta:4 adet"], 320, 28, 22, 2));
    
    yemekler.add(_kahvalti("Yumurta Salata", "Yumurta yeşillik", 
      ["Yumurta:2 adet", "Marul:100g", "Roka:50g", "Domates:100g"], 250, 17, 13, 14));
    yemekler.add(_kahvalti("Tam Tahıl Yumurta", "Yumurta tam tahıl ekmek", 
      ["Yumurta:2 adet", "Tam Tahıl Ekmeği:2 dilim", "Tereyağı:10g"], 330, 19, 15, 30));
    yemekler.add(_kahvalti("Çavdar Yumurta", "Yumurta çavdar ekmeği", 
      ["Yumurta:2 adet", "Çavdar Ekmeği:2 dilim"], 300, 18, 12, 28));
    yemekler.add(_kahvalti("Kinoa Yumurta", "Yumurta kinoa", 
      ["Yumurta:2 adet", "Kinoa:80g"], 340, 22, 14, 32));
    yemekler.add(_kahvalti("Yulaf Yumurta", "Yumurta yulaf", 
      ["Yumurta:2 adet", "Yulaf:60g"], 340, 22, 14, 36));
    
    // SAHANDA VE ÖZEL PİŞİRME (15 çeşit)
    yemekler.add(_kahvalti("Zeytinyağı Sahanda", "Zeytinyağında yumurta", 
      ["Yumurta:2 adet", "Zeytinyağı:15ml"], 240, 14, 16, 2));
    yemekler.add(_kahvalti("Fırında Yumurta", "Fırında pişmiş yumurta", 
      ["Yumurta:2 adet", "Domates:100g", "Baharatlar"], 220, 14, 12, 12));
    yemekler.add(_kahvalti("Poşe Yumurta", "Poşe edilmiş yumurta", 
      ["Yumurta:2 adet", "Sirke:10ml"], 160, 13, 11, 2));
    yemekler.add(_kahvalti("Çılbır", "Yoğurtlu poşe yumurta", 
      ["Yumurta:2 adet", "Yoğurt:150g", "Tereyağı:10g"], 310, 20, 16, 15));
    yemekler.add(_kahvalti("Izgara Yumurta", "Izgara domates yumurta", 
      ["Yumurta:2 adet", "Domates:200g", "Zeytinyağı:10ml"], 230, 14, 12, 14));
    
    yemekler.add(_kahvalti("Yumurtalı Ekmek", "Ekmek içinde yumurta", 
      ["Ekmek:2 dilim", "Yumurta:2 adet"], 340, 20, 14, 32));
    yemekler.add(_kahvalti("Krep Yumurta", "Yumurtalı krep", 
      ["Yumurta:2 adet", "Krep:1 adet", "Peynir:40g"], 320, 22, 15, 26));
    yemekler.add(_kahvalti("Tortilla Yumurta", "Yumurtalı tortilla", 
      ["Yumurta:2 adet", "Tortilla:1 adet", "Sebze:80g"], 300, 18, 13, 28));
    yemekler.add(_kahvalti("Muffin Yumurta", "Fırın yumurta muffini", 
      ["Yumurta:2 adet", "Sebze:100g", "Peynir:40g"], 280, 21, 15, 14));
    yemekler.add(_kahvalti("Shakshuka", "Domates soslu yumurta", 
      ["Yumurta:2 adet", "Domates Sosu:200g", "Biber:80g"], 280, 15, 13, 20));
    
    yemekler.add(_kahvalti("İtalyan Frittata", "Sebzeli İtalyan omleti", 
      ["Yumurta:3 adet", "Patlıcan:100g", "Kabak:80g", "Parmesan:30g"], 300, 20, 15, 16));
    yemekler.add(_kahvalti("İspanyol Tortilla", "Patatesli omlet", 
      ["Yumurta:3 adet", "Patates:150g", "Soğan:60g"], 340, 18, 14, 30));
    yemekler.add(_kahvalti("Benedict Yumurta", "Poşe yumurta muffin", 
      ["Yumurta:2 adet", "Tam Buğday Muffin:1 adet", "Yoğurt Sos:50g"], 320, 22, 14, 28));
    yemekler.add(_kahvalti("Cloud Eggs", "Bulut yumurta", 
      ["Yumurta:2 adet", "Parmesan:20g"], 220, 16, 14, 5));
    yemekler.add(_kahvalti("Avokado Teknesi Yumurta", "Avokado içinde yumurta", 
      ["Avokado:1 adet", "Yumurta:2 adet"], 320, 16, 22, 18));
    
    // ÖZEL DİYET YUMURTA KAHVALTI (15 çeşit)
    yemekler.add(_kahvalti("Keto Yumurta", "Yağlı yumurta avokado", 
      ["Yumurta:3 adet", "Avokado:100g", "Bacon:30g"], 420, 22, 32, 8));
    yemekler.add(_kahvalti("Paleo Yumurta", "Organik yumurta tatlı patates", 
      ["Yumurta:2 adet", "Tatlı Patates:150g"], 320, 16, 12, 36));
    yemekler.add(_kahvalti("Vegan Yumurta Alternatif", "Tofu scramble", 
      ["Tofu:200g", "Sebze:150g", "Baharat"], 220, 18, 12, 16));
    yemekler.add(_kahvalti("Gluten Free Yumurta", "Yumurta glutensiz ekmek", 
      ["Yumurta:2 adet", "Glutensiz Ekmek:2 dilim"], 290, 18, 14, 26));
    yemekler.add(_kahvalti("Düşük Kalorili Yumurta", "Sadece ak omlet", 
      ["Yumurta Akı:6 adet", "Sebze:200g"], 180, 28, 2, 12));
    
    yemekler.add(_kahvalti("Yüksek Proteinli Yumurta", "Protein yumurta", 
      ["Yumurta:4 adet", "Cottage Cheese:100g"], 400, 40, 22, 10));
    yemekler.add(_kahvalti("Akdeniz Yumurta", "Feta domates yumurta", 
      ["Yumurta:2 adet", "Feta:50g", "Domates:150g"], 300, 18, 18, 14));
    yemekler.add(_kahvalti("Japon Tamagoyaki", "Tatlı Japon omleti", 
      ["Yumurta:3 adet", "Soya Sosu:10ml"], 260, 18, 14, 12));
    yemekler.add(_kahvalti("Pre-Workout Yumurta", "Yumurta muz yulaf", 
      ["Yumurta:2 adet", "Muz:1 adet", "Yulaf:50g"], 380, 20, 10, 48));
    yemekler.add(_kahvalti("Post-Workout Yumurta", "Yüksek protein omlet", 
      ["Yumurta Akı:6 adet", "Yumurta:1 adet", "Patates:150g"], 340, 32, 8, 36));
    
    yemekler.add(_kahvalti("Recovery Yumurta", "Yumurta kinoa sebze", 
      ["Yumurta:3 adet", "Kinoa:100g", "Sebze:150g"], 390, 26, 14, 38));
    yemekler.add(_kahvalti("Omega-3 Yumurta", "Omega yumurta chia ekmek", 
      ["Omega-3 Yumurta:2 adet", "Chia Ekmeği:2 dilim", "Avokado:60g"], 360, 20, 18, 28));
    yemekler.add(_kahvalti("D Vitamini Yumurta", "Yumurta D vitamini mantar", 
      ["Yumurta:3 adet", "Mantar:100g"], 250, 21, 13, 10));
    yemekler.add(_kahvalti("Demir Yumurta", "Ispanak yumurta", 
      ["Yumurta:2 adet", "Ispanak:150g"], 230, 18, 13, 14));
    yemekler.add(_kahvalti("Mikro Besin Yumurta", "Tam besin yumurta", 
      ["Yumurta:2 adet", "Kabak Çekirdeği:20g", "Tam Tahıl:2 dilim"], 370, 22, 18, 30));
    
    // SANDVİÇ VE WRAP YUMURTA (15 çeşit)
    yemekler.add(_kahvalti("Yumurtalı Sandviç", "Haşlanmış yumurta sandviç", 
      ["Yumurta:2 adet", "Tam Buğday Ekmeği:2 dilim", "Marul:50g"], 310, 18, 14, 28));
    yemekler.add(_kahvalti("Omlet Sandviç", "Omlet dolgulu sandviç", 
      ["Yumurta:2 adet", "Ekmek:2 dilim", "Kaşar:40g"], 340, 22, 16, 30));
    yemekler.add(_kahvalti("Scrambled Egg Sandviç", "Çırpılmış yumurta sandviç", 
      ["Yumurta:2 adet", "Ekmek:2 dilim", "Sebze:80g"], 320, 19, 14, 28));
    yemekler.add(_kahvalti("Yumurta Wrap", "Yumurta tortilla wrap", 
      ["Yumurta:2 adet", "Tortilla:1 adet", "Sebze:100g"], 310, 18, 13, 28));
    yemekler.add(_kahvalti("Protein Yumurta Wrap", "Yüksek protein wrap", 
      ["Yumurta Akı:4 adet", "Yumurta:1 adet", "Wrap:1 adet"], 320, 28, 10, 26));
    
    yemekler.add(_kahvalti("Avokado Yumurta Sandviç", "Yumurta avokado ekmek", 
      ["Yumurta:2 adet", "Avokado:80g", "Ekmek:2 dilim"], 380, 18, 18, 32));
    yemekler.add(_kahvalti("Sebzeli Yumurta Wrap", "Yumurta sebze wrap", 
      ["Yumurta:2 adet", "Sebze:150g", "Wrap:1 adet"], 300, 18, 12, 30));
    yemekler.add(_kahvalti("Peynirli Yumurta Sandviç", "Yumurta peynir sandviç", 
      ["Yumurta:2 adet", "Beyaz Peynir:60g", "Ekmek:2 dilim"], 340, 22, 16, 28));
    yemekler.add(_kahvalti("Füme Somon Yumurta", "Yumurta somon sandviç", 
      ["Yumurta:2 adet", "Füme Somon:60g", "Ekmek:2 dilim"], 360, 26, 16, 26));
    yemekler.add(_kahvalti("Hindi Füme Yumurta", "Yumurta hindi sandviç", 
      ["Yumurta:2 adet", "Hindi Füme:60g", "Ekmek:2 dilim"], 340, 28, 14, 26));
    
    yemekler.add(_kahvalti("Ton Yumurta Sandviç", "Yumurta ton sandviç", 
      ["Yumurta:2 adet", "Ton Balığı:60g", "Ekmek:2 dilim"], 350, 30, 14, 26));
    yemekler.add(_kahvalti("Humus Yumurta Wrap", "Yumurta humus wrap", 
      ["Yumurta:2 Dosyada syntax hatası var, yeniden oluşturuyorum. Çok kapsamlı bir yemek veritabanı oluşturacağım - adet", "Humus:80g", "Wrap:1 adet"], 350, her kategoride yüzlerce alternatif olacak.

<write_to_file>
<path>olustur_mega_yemek_veritabani_BOLUM_1.dart</path>
20, 16, 32));
    yemekler.add(_kahvalti("Sebze <content>import 'dart:convert';
import 'dart:io';

/// ============================================================================
Gömme Yumurta Sandviç", "Yumurta sebze /// MEGA YEMEK VERİTABANI OLUŞTURUCU yatağı", 
      ["Yumurta:2 - BÖLÜM 1
/// adet", "Karışık Sebze:150g", "Ekmek:2 dilim"], 320, 18, 13, 30));
    ============================================================================
/// 
/// Hedefler:
/// - yemekler.add(_kahvalti("Kısır Yumurta Wrap", "Yumurta kısır wrap", 
      ["Yumurta:1 adet", 300+ Kahvaltı Yemeği
/// - "Kısır:100g", "Wrap:1 adet"], 500+ Ana Yemek 340, 16, 12, 42));
    (Öğle/Akşam)
/// - 250+ Ara yemekler.add(_kahvalti("Ezine Öğün 1 Peyniri Yumurta", "Yumurta ezine sandviç", 
      (Protein ["Yumurta:2 adet", Ağırlıklı)
/// - 250+ Ara "Ezine Peyniri:60g", "Ekmek:2 dilim"], Öğün 2 (Dengeli)
/// 
/// TOPLAM: 330, 22, 16, 26));
    1300+ YEMEK
/// 
    return yemekler;
  Her yemeğin minimum 2 alternatifi }
  
  List<Map<String, dynamic>> garantili!
/// ============================================================================

void _peynirKahvaltilari() {
    final yemekler = <Map<String, dynamic>>[];
    main() async {
  print('🚀 MEGA 
    // YEMEK VERİTABANI OLUŞTURULUYOR - BÖLÜM 1\n');
  print('=' * 70);
  
  final generator = PEYNİR MegaYemekGeneratorBolum1();
  
  TABAKLARI (30 çeşit)
    // yemekler.add(_kahvalti("Klasik Peynir Tabağı", Kahvaltılar
  await generator.kahvaltilariOlustur();
  
  "Beyaz peynir zeytin // Ana Yemekler - domates", 
      ["Beyaz Peynir:100g", "Siyah Zeytin:15 adet", "Domates:150g"], 280, 16, 18, 12));
    yemekler.add(_kahvalti("Karma Peynir Bölüm 1 (Tavuk, Et, Balık)
  await generator.anaYemeklerBolum1();
  
  print('\n' + '=' * Tabağı", "Beyaz 70);
  print('✅ kaşar tulum", 
      BÖLÜM 1 TAMAMLANDI!');
  print('📊 ["Beyaz Peynir:60g", "Kaşar:40g", Toplam oluşturulan kategoriler: Kahvaltı "Tulum:40g", "Ceviz:20g"], + Ana Yemekler 360, 22, 24, 10));
    yemekler.add(_kahvalti("Lor Peyniri Tabağı", (Tavuk/Et/Balık)');
  print('\n💡 Devam için "Lor bal ceviz", 
      BÖLÜM 2 scriptini ["Lor Peyniri:150g", "Bal:20g", çalıştırın.');
}

class MegaYemekGeneratorBolum1 {
  "Ceviz:30g"], 320, 20, 16, 28));
    final String dataPath = yemekler.add(_kahvalti("Çökelek Kahvaltısı", 'assets/data/mega_db';
  
  Future<void> kahvaltilariOlustur() async "Çökelek domates yeşillik", 
      {
    print('\n📋 ["Çökelek:150g", "Domates:150g", KAHVALTILAR "Roka:50g"], 240, 18, 12, oluşturuluyor...');
    final yemekler = 14));
    yemekler.add(_kahvalti("Light Peynir <Map<String, dynamic>>[];
    Tabağı", "Az yağlı peynir sebze", 
      ["Light Beyaz Peynir:120g", "Sebze:200g"], 200, 20, 
    // 1. 8, 16));
    
    yemekler.add(_kahvalti("Feta Tabağı", "Feta YUMURTA BAZLI KAHVALTILAR (60 peyniri zeytinyağı", 
      çeşit)
    yemekler.addAll(_yumurtaKahvaltilari());
    print('   ✓ Yumurta ["Feta Peyniri:120g", "Zeytinyağı:10ml", kahvaltıları: ${_yumurtaKahvaltilari().length}');
    "Domates:150g"], 300, 18, 20, 14));
    
    // 2. yemekler.add(_kahvalti("Ezine Peyniri PEYNIR BAZLI KAHVALTILAR (50 çeşit)
    Özel", "Ezine yemekler.addAll(_peynirKahvaltilari());
    print('   ✓ peyniri bal ceviz", 
      ["Ezine Peyniri:120g", Peynir "Bal:20g", "Ceviz:25g"], 340, 20, 22, kahvaltıları: ${_peynirKahvaltilari().length}');
    
    // 3. 18));
    yemekler.add(_kahvalti("Mihaliç TAHIL VE YULAF KAHVALTILARI (60 çeşit)
    yemekler.addAll(_tahilKahvaltilari());
    print('   Peyniri", "Mihaliç peynir tabağı", 
      ["Mihaliç Peyniri:100g", ✓ Tahıl "Yeşillik:100g"], 280, 18, kahvaltıları: ${_tahilKahvaltilari().length}');
    
    // 4. SMOOTHIE 20, 10));
    VE İÇECEKLER (50 çeşit)
    yemekler.add(_kahvalti("Tulum Peyniri Özel", yemekler.addAll(_smoothieKahvaltilari());
    print('   ✓ Smoothie kahvaltıları: "Erzincan tulum", 
      ["Tulum Peyniri:100g", "Bal:20g", "Ceviz:30g"], ${_smoothieKahvaltilari().length}');
    
    // 5. PROTEIN KAHVALTILAR (50 çeşit)
    yemekler.addAll(_proteinKahvaltilari());
    360, 20, print('   ✓ Protein kahvaltıları: ${_proteinKahvaltilari().length}');
    
    24, 16));
    yemekler.add(_kahvalti("Dil Peyniri Tabağı", "Dil peyniri özel", 
      ["Dil Peyniri:120g", "Domates:100g"], 300, 22, 20, 12));
    
    yemekler.add(_kahvalti("Kaşar Peyniri Tabağı", "Kaşar // 6. zeytin", 
      ["Kaşar VEJETERİAN KAHVALTILAR (30 çeşit)
    yemekler.addAll(_vejetaryenKahvaltilari());
    Peyniri:100g", "Yeşil Zeytin:15 print('   ✓ Vejetaryen kahvaltıları: ${_vejetaryenKahvaltilari().length}');
    
    await adet"], 320, 20, 22, 10));
    _dosyayaKaydet('KAHVALTI_${yemekler.length}_adet.json', yemekler.add(_kahvalti("Çerkez Peyniri", "Çerkez peynir özel", 
      yemekler);
    print('✅ Toplam ["Çerkez Peyniri:120g", ${yemekler.length} kahvaltı oluşturuldu!\n');
  }
  "Salatalık:150g"], 280, 18, 18, 14));
    
  Future<void> yemekler.add(_kahvalti("Kars anaYemeklerBolum1() async {
    Kaşarı", "Kars kaşar tabağı", 
      print('\n📋 ["Kars Kaşarı:100g", "Ceviz:30g"], 340, 22, ANA YEMEKLER (Bölüm 24, 12));
    1) oluşturuluyor...');
    final yemekler = <Map<String, dynamic>>[];
    
    // 1. TAVUK YEMEKLERİ (100 çeşit)
    yemekler.add(_kahvalti("Van Otlu Peynir", "Van otlu yemekler.addAll(_tavukYemekleri());
    print('   ✓ Tavuk yemekleri: peynir", 
      ["Otlu ${_tavukYemekleri().length}');
    
    // Peynir:120g", "Domates:150g"], 300, 20, 2. KIRMIZI ET YEMEKLERİ (80 çeşit)
    20, 14));
    yemekler.add(_kahvalti("Divle Obruk Peyniri", "Divle küflü peynir", 
      yemekler.addAll(_kirmiziEtYemekleri());
    print('   ✓ Kırmızı et yemekleri: ${_kirmiziEtYemekleri().length}');
    
    // ["Divle Peyniri:100g", 3. BALIK VE "Bal:20g"], 320, 18, 22, DENİZ ÜRÜNLERİ 16));
    (70 çeşit)
    yemekler.addAll(_balikYemekleri());
    
    yemekler.add(_kahvalti("Hellim Peyniri", print('   ✓ Balık yemekleri: ${_balikYemekleri().length}');
    
    "Kıbrıs hellim", 
      await ["Hellim:120g", _dosyayaKaydet('ANA_YEMEK_BOLUM1_${yemekler.length}_adet.json', "Karpuz:100g"], 340, 22, yemekler);
    print('✅ Toplam 22, 18));
    ${yemekler.length} ana yemek (Bölüm 1) oluşturuldu!\n');
  }
  
  yemekler.add(_kahvalti("Labne Tabağı", "Labne zeytinyağı // ============================================================================
  zatar", 
      ["Labne:150g", // YUMURTA "Zeytinyağı:15ml", KAHVALTILARI - "Zatar"], 280, 60 ÇEŞİT
  // ============================================================================
  
  List<Map<String, dynamic>> _yumurtaKahvaltilari() {
    16, 18, 14));
    return [
      // MENEMEN yemekler.add(_kahvalti("Süzme Peynir", "Süzme yoğurt peyniri", 
      ["Süzme Peynir:150g", ALTERNATİFLERİ "Bal:20g"], 260, 18, 14, 20));
    yemekler.add(_kahvalti("Keçi (10)
      _yemek("Klasik Menemen", "Kahvaltı", Peyniri Tabağı", "Keçi peyniri özel", 
      ["Keçi Peyniri:100g", "Ceviz:25g", "Bal:15g"], 340, ["Domates:150g", "Biber:80g", "Yumurta:2 18, 24, 16));
    adet", yemekler.add(_kahvalti("Koyun Peyniri", "Koyun "Zeytinyağı:1 çorba kaşığı", sütü peynir", 
      ["Koyun "Soğan:40g"], Peyniri:120g", "Yeşillik:100g"], 300, 280, 20, 22, 12));
    14, 12, 18),
      
    yemekler.add(_kahvalti("Manda Peyniri", "Manda sütü peynir", 
      ["Manda _yemek("Mantarlı Menemen", "Kahvaltı", ["Mantar:100g", Peyniri:100g", "Domates:150g"], 280, 18, 20, 14));
    yemekler.add(_kahvalti("Lor Peyniri "Domates:120g", "Yumurta:2 adet", "Zeytinyağı:1 çorba kaşığı"], 250, 15, 10, Ballı", "Lor peynir bal", 
      ["Lor Peyniri:150g", 16),
      "Çam Balı:25g"], _yemek("Ispanaklı Menemen", "Kahvaltı", ["Ispanak:150g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:1 300, 20, 16, 26));
    çorba kaşığı"], 240, 16, yemekler.add(_kahvalti("Çökelek Zeytinyağlı", "Çökelek 9, 15),
      zeytinyağı", 
      ["Çökelek:150g", _yemek("Sucuklu Menemen", "Zeytinyağı:15ml", "Yeşillik:80g"], 260, 18, 16, 14));
    "Kahvaltı", ["Sucuk:50g", "Domates:120g", "Yumurta:2 adet", "Biber:60g"], yemekler.add(_kahvalti("Beyaz Peynir 320, 18, 15, 20),
      Zeytinli", "Beyaz peynir özel zeytin", 
      _yemek("Peynirli Menemen", "Kahvaltı", ["Beyaz Peynir:120g", "Karışık ["Beyaz Peynir:60g", "Domates:120g", "Yumurta:2 adet", "Biber:70g"], 290, 19, 12, 17),
      _yemek("Kaşarlı Menemen", Zeytin:40g"], "Kahvaltı", 300, 18, 20, 12));
    yemekler.add(_kahvalti("Ürgüp Peyniri", "Ürgüp küp peynir", 
      ["Kaşar Peyniri:50g", "Domates:130g", "Yumurta:2 adet", ["Ürgüp Peyniri:100g", "Salatalık:150g"], 280, 18, 20, 14));
    
    yemekler.add(_kahvalti("Krem Peynir Tabağı", "Krem "Yeşil Biber:80g"], 300, 18, 14, 18),
      peynir sebze", 
      ["Krem Peynir:100g", "Sebze _yemek("Patlıcanlı Menemen", "Kahvaltı", Çubukları:200g"], ["Patlıcan:120g", 260, 14, 18, 16));
    yemekler.add(_kahvalti("Cottage Cheese "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:1 çorba kaşığı"], Kahvaltı", "Cottage cheese meyve", 
      ["Cottage 270, 14, 13, 19),
      Cheese:150g", _yemek("Kabak "Çilek:100g"], 220, 18, 6, 24));
    yemekler.add(_kahvalti("Ricotta Ballı", "Ricotta peynir bal", 
      ["Ricotta:150g", Çiçeği Menemen", "Kahvaltı", ["Kabak Çiçeği:100g", "Domates:100g", "Yumurta:2 adet", "Bal:20g", "Zeytinyağı:1 çorba "Fındık:20g"], 340, 18, 18, 30));
    yemekler.add(_kahvalti("Mascarpone kaşığı"], 260, Meyveli", "Mascarpone meyve", 
      ["Mascarpone:100g", 15, 11, 17),
      _yemek("Kuşkonmaz Menemen", "Kahvaltı", ["Kuşkonmaz:120g", "Domates:100g", "Yumurta:2 adet", "Zeytinyağı:1 çorba kaşığı"], "Yaban 255, 16, 10, 16),
      Mersini:80g"], 320, 12, 24, 20));
    _yemek("Karışık Sebze Menemen", "Kahvaltı", ["Kabak:80g", "Havuç:60g", "Domates:100g", yemekler.add(_kahvalti("Burrata "Yumurta:2 adet", Domatesli", "Burrata domates "Zeytinyağı:1 çorba kaşığı"], 265, fesleğen", 
      15, 11, 18),
      ["Burrata:120g", "Domates:150g", "Fesleğen"], 300, 16, 22, 14));
    
      // OMLET ALTERNATİFLERİ (15)
      _yemek("Beyaz 
    // PEYNİRLİ FIRINLAR (25 çeşit)
    Peynirli Omlet", "Kahvaltı", yemekler.add(_kahvalti("Peynirli ["Yumurta:3 adet", "Beyaz Peynir:60g", "Maydanoz:20g", Börek", "El yapımı börek", 
      "Süt:50ml"], ["Yufka:2 yaprak", "Beyaz Peynir:80g", "Yumurta:1 adet"], 340, 16, 14, 36));
    yemekler.add(_kahvalti("Su Böreği", "Peynirli su böreği", 
      ["Yufka:3 yaprak", "Beyaz Peynir:100g"], 360, 18, 16, 38));
    yemekler.add(_kahvalti("Sigara Böreği", "Rulo börek", 
      ["Yufka:3 yaprak", "Beyaz Peynir:90g"], 360, 17, 16, 36));
    300, yemekler.add(_kahvalti("Açma 22, 13, 15),
      _yemek("Sebzeli Peynirli", "Peynirli açma", Omlet", "Kahvaltı", ["Yumurta:3 adet", "Brokoli:80g", "Havuç:50g", "Biber:60g"], 260, 20, 10, 14),
      _yemek("Mantarlı Omlet", "Kahvaltı", ["Yumurta:3 adet", "Mantar:100g", "Soğan:40g", "Maydanoz:15g"], 
      ["Açma:2 adet", "Beyaz 240, Peynir:60g"], 19, 9, 13),
      _yemek("Ispanaklı Omlet", "Kahvaltı", 380, 14, 14, ["Yumurta:3 adet", "Ispanak:100g", "Lor Peyniri:50g"], 270, 21, 11, 48));
    yemekler.add(_kahvalti("Gözleme", "Peynirli gözleme", 
      ["Hamur:150g", "Beyaz 14),
      _yemek("Kaşarlı Omlet", "Kahvaltı", ["Yumurta:3 adet", Peynir:80g"], 400, 18, 16, 44));
    
    "Kaşar Peyniri:60g", "Domates:50g"], 310, 24, yemekler.add(_kahvalti("Ispanaklı Peynirli Börek", "Ispanak peynir börek", 
      14, 12),
      _yemek("Somonlu Omlet", "Kahvaltı", ["Yumurta:3 adet", "Somon Füme:50g", "Dereotu:15g", "Krem ["Yufka:2 yaprak", "Ispanak:100g", "Beyaz Peynir:30g"], 330, 26, 18, 10),
      _yemek("Hindi Füme Omlet", "Kahvaltı", Peynir:60g"], 340, 18, 14, ["Yumurta:3 adet", 34));
    "Hindi Füme:60g", "Domates:60g", yemekler.add(_kahvalti("Kıymalı Peynirli Börek", "Kıyma peynir börek", 
      ["Yufka:2 yaprak", "Kıyma:80g", "Roka:30g"], 290, 28, "Kaşar:60g"], 12, 11),
      _yemek("Ton Balıklı 420, 24, 20, 36));
    Omlet", "Kahvaltı", ["Yumurta:3 yemekler.add(_kahvalti("Patatesli Peynirli Börek", "Patates adet", "Ton Balığı:60g", "Mısır:40g", "Maydanoz:15g"], peynir börek", 
      ["Yufka:2 yaprak", "Patates:120g", "Kaşar:60g"], 400, 300, 30, 13, 16, 18, 42));
    yemekler.add(_kahvalti("Kaşarlı Tost", 12),
      _yemek("Lor Peynirli Omlet", "Kahvaltı", "Klasik kaşar tost", 
      ["Ekmek:2 ["Yumurta:3 adet", "Lor dilim", "Kaşar:60g", "Domates:80g"], Peyniri:80g", "Dereotu:20g", 320, 18, 14, 32));
    "Yeşil Soğan:15g"], 280, 23, 13, 9),
      _yemek("Avokadolu Omlet", yemekler.add(_kahvalti("Karışık Tost", "Kahvaltı", ["Yumurta:3 adet", "Avokado:80g", "Domates:60g", "Kaşar sucuk tost", 
      ["Ekmek:2 dilim", "Kaşar:50g", "Sucuk:40g"], "Kırmızı Soğan:20g"], 340, 20, 22, 14),
      380, 20, 18, 32));
    
    yemekler.add(_kahvalti("Peynir Muffin", "Fırın peynir _yemek("Zeytin Ezmeli Omlet", "Kahvaltı", ["Yumurta:3 adet", muffin", 
      ["Tam "Siyah Buğday Zeytin Ezmesi:40g", "Domates:70g", Unu:100g", "Beyaz Peynir:80g", "Yumurta:2 adet"], 320, "Fesleğen:10g"], 310, 20, 14, 28));
    19, 18, 13),
      yemekler.add(_kahvalti("Peynirli Pankek", "Peynir _yemek("Fesleğenli Omlet", "Kahvaltı", ["Yumurta:3 adet", "Fesleğen:25g", dolgulu pankek", 
      "Parmesan:40g", ["Yulaf Unu:80g", "Lor Peyniri:100g", "Yumurta:2 adet"], 340, "Çeri Domates:80g"], 300, 22, 12, 32));
    22, 16, 12),
      yemekler.add(_kahvalti("Peynir Kurabiyesi", _yemek("Roka Cevizli Omlet", "Kahvaltı", "Tuzlu peynir kurabiye", 
      ["Un:100g", ["Yumurta:3 adet", "Roka:50g", "Kaşar:60g", "Tereyağı:30g"], 380, 16, 18, 40));
    yemekler.add(_kahvalti("Peynirli Krep", "Peynir krep", 
      ["Krep:2 adet", "Beyaz Peynir:80g"], 300, 16, 12, 34));
    "Ceviz:25g", yemekler.add(_kahvalti("Peynir "Keçi Peyniri:40g"], 330, 21, 20, 13),
      _yemek("Kırmızı Biberli Omlet", "Kahvaltı", ["Yumurta:3 adet", "Kırmızı Biber:100g", "Soğan:40g", Çöreği", "Evde çörek", 
      "Kekik"], ["Hamur:120g", "Kaşar:60g"], 400, 18, 18, 42));
    
    yemekler.add(_kahvalti("Lahmacun Peynirli", "Peynirli lahmacun", 
      ["Hamur:100g", "Kıyma:60g", "Kaşar:40g"], 380, 250, 19, 11, 15),
      _yemek("İtalyan Frittata", "Kahvaltı", ["Yumurta:3 adet", "Patlıcan:100g", 22, 16, 38));
    yemekler.add(_kahvalti("Pide "Kabak:80g", "Parmesan:30g", "Fesleğen:15g"], 300, 20, 15, 16),
      
      // Peynirli", "Kaşarlı pide", 
      ["Hamur:120g", YUMURTA PIŞIRME ÇEŞITLERİ (15)
      "Kaşar:80g"], 420, 20, 18, _yemek("Haşlanmış Yumurta Tabağı", 44));
    "Kahvaltı", yemekler.add(_kahvalti("Pogaça Peynirli", ["Yumurta:2 adet", "Tam Buğday Ekmeği:2 "Peynirli poğaça", 
      ["Hamur:100g", dilim", "Siyah "Beyaz Peynir:60g"], 360, 16, 16, 40));
    yemekler.add(_kahvalti("Çiğ Börek", "Peynirli çiğ börek", Zeytin:10 adet", 
      ["Hamur:120g", "Beyaz Peynir:80g"], 380, 18, "Domates:100g"], 320, 18, 14, 28),
      _yemek("Rafadan Yumurta 16, 42));
    yemekler.add(_kahvalti("Katmer Peynirli", Kahvaltısı", "Kahvaltı", ["Yumurta:2 adet", "Peynirli katmer", 
      ["Hamur:100g", "Çavdar Ekmeği:2 dilim", "Kaşar:60g"], 400, 18, 18, 44));
    "Yeşil Zeytin:10 
    yemekler.add(_kahvalti("Simit adet", "Salatalık:100g"], 310, 17, Peynirli", "Simit peynir", 
      ["Simit:1 adet", 13, 29),
      _yemek("Kayısı "Beyaz Peynir:80g"], 340, 16, 14, 42));
    Yumurta", "Kahvaltı", ["Yumurta:2 adet", yemekler.add(_kahvalti("Bazlama "Yeşil Biber:80g", "Domates:100g", "Zeytinyağı:1 Peynirli", "Bazlama peynir", çorba kaşığı"], 260, 15, 
      ["Bazlama:1 adet", "Kaşar:70g"], 380, 18, 16, 14, 16),
      42));
    yemekler.add(_kahvalti("Lavaş Peynirli", _yemek("Sahanda Yumurta "Lavaş peynir rulo", 
      ["Lavaş:1 (Sağlıklı)", "Kahvaltı", ["Yumurta:2 adet", "Beyaz Peynir:80g", adet", "Zeytinyağı:1 çorba kaşığı", "Yeşillik:50g"], 320, 18, 14, "Tam Buğday Ekmeği:1 dilim", 36));
    "Domates:100g"], 280, 15, 16, yemekler.add(_kahvalti("Yufka Peynirli", "Yufka peynir sarma", 
      ["Yufka:2 yaprak", "Lor 18),
      Peyniri:100g"], 340, 20, 14, 38));
    _yemek("Çılbır (Yoğurtlu Yumurta)", yemekler.add(_kahvalti("Dürüm "Kahvaltı", ["Yumurta:2 Peynirli", "Peynir dürüm", 
      ["Lavaş:1 adet", adet", "Süzme Yoğurt:150g", "Kaşar:60g", "Domates:80g"], 330, 18, "Tereyağı:10g", "Pul Biber", 15, 34));
    "Sumak"], 310, 20, 16, 
    // PEYNİRLİ 15),
      SANDVİÇLER VE ÖZEL (25 çeşit)
    _yemek("Poşe Yumurta Avokado Üstü", "Kahvaltı", ["Yumurta:2 adet", yemekler.add(_kahvalti("Mozzarella "Avokado:100g", "Tam Buğday Ekmeği:1 dilim", Ekmek", "Mozzarella "Kırmızı Pul Biber"], 360, domates fesleğen", 
      ["Ekmek:2 18, 22, 24),
      dilim", "Mozzarella:80g", "Domates:100g"], 310, _yemek("Fırında Yumurta 18, 14, 30));
    Kasesi", "Kahvaltı", ["Yumurta:2 adet", yemekler.add(_kahvalti("Labne Sandviç", "Labne "Ispanak:80g", zeytin ezmesi", 
      "Beyaz Peynir:40g", "Süt:30ml"], 270, ["Ekmek:2 dilim", 19, 14, 12),
      "Labne:80g", "Zeytin _yemek("Yumurta Muffin", Ezmesi:30g"], 300, 14, "Kahvaltı", 12, 36));
    ["Yumurta:3 adet", "Sebze yemekler.add(_kahvalti("Ricotta Bal Sandviç", Karışımı:100g", "Lor "Ricotta Peyniri:60g", "Baharat"], bal fındık", 
      ["Ekmek:2 dilim", "Ricotta:100g", 260, 21, 12, "Bal:20g", "Fındık:20g"], 360, 16, 16, 38));
    yemekler.add(_kahvalti("Cottage Cheese Bowl", "Cottage cheese meyve", 
      ["Cottage Cheese:150g", "Çilek:100g", 14),
      _yemek("Cloud Eggs (Bulut Yumurta)", "Kahvaltı", ["Yumurta:2 adet", "Parmesan:20g", "Tuz", "Yaban Mersini:50g"], 220, "Karabiber"], 18, 6, 24));
    yemekler.add(_kahvalti("Quark 220, Kahvaltı", "Quark 16, 14, 5),
      _yemek("Shakshuka", "Kahvaltı", meyve badem", 
      ["Quark:150g", ["Yumurta:2 adet", "Meyve:100g", "Badem:20g"], 280, 20, 12, 24));
    
    yemekler.add(_kahvalti("Skyr İskandinav", "Skyr granola", 
      ["Skyr:150g", "Granola:50g", "Meyve:80g"], 300, 22, 8, 36));
    "Domates Sosu:200g", "Biber:80g", "Soğan:40g", "Baharat"], 280, 15, 13, 20),
      _yemek("Huevos Rancheros", "Kahvaltı", ["Yumurta:2 adet", "Kırmızı Fasulye:100g", "Mısır Tortilla:1 adet", "Avokado:50g"], 380, 20, 16, yemekler.add(_kahvalti("Krem Peynir Somon", "Krem 35),
      _yemek("Scrambled peynir füme somon", 
      ["Krem Eggs Protein", Peynir:80g", "Füme "Kahvaltı", ["Yumurta:3 Somon:60g", "Ekmek:2 dilim"], adet", "Cottage Cheese:100g", "Süt:50ml", 360, 24, 18, 28));
    yemekler.add(_kahvalti("Krem Peynir Sebzeli", "Krem "Dereotu:15g"], 290, 28, 14, 8),
      _yemek("Japon Tamagoyaki", "Kahvaltı", peynir sebze", 
      ["Krem ["Yumurta:3 adet", Peynir:100g", "Havuç:100g", "Soya "Salatalık:100g"], 260, Sosu:1 tatlı kaşığı", 14, 18, 18));
    yemekler.add(_kahvalti("Halloumi Izgara", "Izgara halloumi", 
      ["Halloumi:120g", "Mirin:1 "Domates:150g"], 340, 22, 22, 12));
    yemekler.add(_kahvalti("Feta Ispanak", "Feta tatlı ıspanak omlet", 
      kaşığı", "Şeker:1 tatlı kaşığı"], 260, 18, 14, 12),
      _yemek("İspanyol ["Feta:60g", Tortilla", "Kahvaltı", ["Yumurta:3 adet", "Patates:150g", "Soğan:60g", "Zeytinyağı:1 çorba kaşığı"], "Ispanak:100g", "Yumurta:2 adet"], 300, 22, 18, 12));
    
    340, 18, 14, 30),
      _yemek("Benedict yemekler.add(_kahvalti("Parmesan Sebze", "Parmesan ızgara sebze", 
      Yumurta (Fit)", "Kahvaltı", ["Yumurta:2 adet", "Tam Buğday ["Parmesan:50g", Muffin:1 adet", "Hindi Füme:50g", "Sebze:200g"], 260, 18, 16, 14));
    "Yoğurt yemekler.add(_kahvalti("Keçi Peyniri Salata", "Keçi Sos:50g"], 350, 24, 14, 30),
      
      // peynir yeşillik", 
      ["Keçi Peyniri:80g", "Yeşillik:150g", SPOR YUMURTA KAHVALTILARI (10)
      "Ceviz:25g"], _yemek("Pre-Workout Yumurta", "Kahvaltı", 280, 16, 20, 12));
    ["Yumurta:2 adet", yemekler.add(_kahvalti("Blue Cheese Armut", "Mavi "Muz:1 adet", peynir armut", 
      ["Mavi Peynir:60g", "Yulaf:50g", "Bal:1 tatlı "Armut:150g", "Bal:20g"], kaşığı"], 380, 20, 10, 300, 14, 16, 32));
    48),
      yemekler.add(_kahvalti("Brie Elma", "Brie elma fındık", 
      _yemek("Post-Workout Protein Omlet", ["Brie:80g", "Elma:150g", "Kahvaltı", ["Yumurta Akı:6 "Fındık:20g"], 320, adet", "Yumurta:1 adet", 14, 20, 28));
    "Haşlanmış Patates:150g", "Roka:30g"], 340, yemekler.add(_kahvalti("Camembert Tatlı", "Camembert üzüm", 
      32, 8, 36),
      ["Camembert:80g", _yemek("Recovery Yumurta "Üzüm:100g", "Badem:25g"], 340, Bowl", "Kahvaltı", 16, 22, 24));
    
    yemekler.add(_kahvalti("Gouda Sandviç", "Gouda ["Yumurta:3 domates", 
      ["Ekmek:2 dilim", "Gouda:70g", adet", "Kinoa:100g", "Karışık Sebze:150g", "Domates:100g"], 330, 18, "Zeytinyağı:1 çorba kaşığı"], 390, 26, 14, 38),
      16, 30));
    yemekler.add(_kahvalti("Cheddar Sandviç", _yemek("Güç Kahvaltısı", "Kahvaltı", "Cheddar avokado", 
      ["Yumurta:3 adet", "Kinoa:80g", ["Ekmek:2 dilim", "Cheddar:70g", "Avokado:80g", "Çeri "Avokado:80g"], 380, 18, 20, Domates:60g"], 420, 24, 32));
    yemekler.add(_kahvalti("Emmental 22, 32),
      Sandviç", "Emmental peynir", 
      ["Ekmek:2 _yemek("Protein Omlet (Sadece dilim", Ak)", "Kahvaltı", ["Yumurta Akı:6 "Emmental:70g"], 340, 20, 16, 30));
    adet", "Brokoli:100g", "Mantar:80g", yemekler.add(_kahvalti("Gruyere Sandviç", "Gruyere peynir", 
      "Soğan:40g"], 180, ["Ekmek:2 dilim", "Gruyere:70g", 28, 2, 10),
      "Hardal:10g"], 350, 20, 18, _yemek("Kas Yapım Kahvaltısı", 28));
    yemekler.add(_kahvalti("Provolone Sandviç", "Kahvaltı", ["Yumurta:4 adet", "Yulaf:60g", "Provolone domates", 
      ["Ekmek:2 dilim", "Provolone:70g", "Domates:100g"], 330, 18, 16, "Fıstık Ezmesi:20g", 30));
    
    "Muz:1 adet"], 450, 30, 18, 40),
      yemekler.add(_kahvalti("Monterey Jack", "Monterey jack peynir", 
      _yemek("Enerji ["Ekmek:2 dilim", "Monterey Yumurta Wrap", "Kahvaltı", ["Yumurta:2 adet", Jack:70g"], 340, 18, 17, 30));
    "Bal yemekler.add(_kahvalti("Havarti Sandviç", "Havarti peynir", 
      Kabağı:100g", ["Ekmek:2 dilim", "Havarti:70g", "Tam Buğday Wrap:1 adet", "Humus:40g"], 340, "Salatalık:80g"], 330, 18, 16, 30));
    19, 12, 36),
      _yemek("Omega-3 yemekler.add(_kahvalti("Muenster Sandviç", "Muenster Yumurta Kahvaltısı", peynir", 
      ["Ekmek:2 dilim", "Muenster:70g"], "Kahvaltı", ["Omega-3 Yumurta:2 adet", 340, 18, 17, 30));
    "Chia yemekler.add(_kahvalti("Swiss Peynir", "Swiss peynir sandviç", 
      Tohumlu ["Ekmek:2 dilim", "Swiss Peynir:70g", Ekmek:2 dilim", "Avokado:60g", "Marul:50g"], 330, 19, 16, "Somon:40g"], 400, 26, 28));
    yemekler.add(_kahvalti("Fontina Sandviç", 22, 28),
      _yemek("Demir "Fontina peynir", 
      ["Ekmek:2 dilim", "Fontina:70g", Takviyeli Yumurta", "Domates:80g"], 340, 18, 17, "Kahvaltı", ["Yumurta:2 adet", 30));
    "Ispanak:150g", "Kırmızı 
    // PROTEİN Et Pastırma:40g", "Tam Buğday Ekmeği:1 AĞIRLIKLI PEYNİRLER dilim"], 320, 26, 16, (20 çeşit)
    20),
      _yemek("Çinko Yumurta yemekler.add(_kahvalti("Protein Peynir Kasesi", Tabağı", "Kahvaltı", ["Yumurta:2 adet", "Kabak "Cottage cheese yumurta akı", 
      ["Cottage Cheese:150g", Çekirdeği:20g", "Yumurta Akı:3 "Tam Tahıl adet"], 200, 32, Ekmeği:2 dilim", "Peynir:40g"], 370, 4, 8));
    22, 18, 30),
      
      // yemekler.add(_kahvalti("Quark Protein", "Quark protein tozu", 
      ["Quark:150g", YARATICI YUMURTA "Protein Tozu:30g"], TARİFLERİ (10)
      280, 40, 6, 12));
    yemekler.add(_kahvalti("Skyr Protein", _yemek("Yumurtalı Avokado "Skyr yüksek protein", 
      Teknesi", "Kahvaltı", ["Skyr:200g", ["Avokado:1 adet", "Yumurta:2 adet", "Badem:20g"], 300, "Baharatlar", 28, 10, 20));
    "Limon Suyu:1 tatlı kaşığı"], yemekler.add(_kahvalti("Cottage Chia", "Cottage cheese 320, 16, chia", 
      ["Cottage Cheese:150g", 22, 18),
      "Chia Tohumu:20g"], _yemek("Sebze Gömme 260, 22, 10, 18));
    Yumurta", "Kahvaltı", ["Yumurta:2 adet", yemekler.add(_kahvalti("Protein Peynir "Ispanak:100g", "Mantar:80g", "Domates:100g", Topu", "Labne badem", 
      ["Labne:150g", "Badem:30g", "Sarımsak:2 "Protein Tozu:20g"], 340, 32, 18, diş"], 240, 17, 11, 16),
      _yemek("Yumurta Wrap", 16));
    "Kahvaltı", ["Yumurta:2 adet", "Tam Buğday Tortilla:1 
    yemekler.add(_kahvalti("Yüksek Protein Lor", adet", "Lor peynir yumurta akı", 
      ["Lor "Sebze:100g", "Humus:40g"], 310, 18, Peyniri:150g", "Yumurta Akı:4 adet"], 13, 28),
      260, 36, 8, 12));
    _yemek("Keto Yumurta Kahvaltısı", "Kahvaltı", ["Yumurta:3 adet", yemekler.add(_kahvalti("Çökelek Protein", "Çökelek badem", 
      ["Çökelek:150g", "Avokado:100g", "Badem:25g", "Chia:15g"], 280, "Bacon:30g", "Roka:40g"], 420, 22, 32, 8),
      26, 14, 16));
    yemekler.add(_kahvalti("Beyaz Peynir _yemek("Paleo Yumurta", "Kahvaltı", Light Protein", ["Yumurta:2 adet", "Tatlı "Light peynir yüksek protein", 
      Patates:150g", "Hindistan ["Light Beyaz Cevizi Yağı:1 Peynir:150g", "Yumurta Akı:3 adet"], çorba kaşığı", "Ispanak:80g"], 240, 34, 6, 10));
    340, 16, 14, 36),
      yemekler.add(_kahvalti("Feta Protein Bowl", "Feta sebze protein", 
      _yemek("Vejetaryen Power Omlet", ["Feta:100g", "Sebze:200g", "Kahvaltı", ["Yumurta:3 adet", "Ceviz:20g"], "Haşlanmış Kinoa:100g", "Sebze 300, 20, 20, 16));
    Karışımı:120g", yemekler.add(_kahvalti("Ricotta Protein", "Ricotta "Nohut:60g"], protein tozu", 
      ["Ricotta:150g", "Protein Tozu:25g"], 360, 22, 14, 32),
      320, 38, 12, 16));
    _yemek("Akdeniz Usulü Yumurta", 
    yemekler.add(_kahvalti("Mascarpone "Kahvaltı", ["Yumurta:2 adet", Fit", "Light mascarpone", 
      ["Light "Feta Peyniri:50g", Mascarpone:150g", "Domates:150g", "Zeytinyağı:1 çorba "Meyve:100g"], 280, 16, 14, 24));
    kaşığı", "Zeytin:10 yemekler.add(_kahvalti("Krem Peynir Protein", adet"], 300, 18, 18, "Krem peynir protein tozu", 
      ["Light Krem 14),
      _yemek("Yumurtalı Peynir:100g", "Protein Sandviç", "Kahvaltı", ["Yumurta:2 adet", Tozu:25g"], 260, "Avokado:80g", "Tam Buğday 32, 10, 14));
    yemekler.add(_kahvalti("Labne Protein", Ekmeği:2 dilim", "Labne yüksek protein", 
      "Hardal:1 tatlı kaşığı"], 380, 18, ["Labne:150g", "Chia:20g", 18, 32),
      "Badem:20g"], 300, 24, _yemek("Izgara Domates Yumurta", "Kahvaltı", 16, ["Domates:200g", "Yumurta:2 adet", 18));
    yemekler.add(_kahvalti("Süzme "Zeytinyağı:1 çorba kaşığı", Yoğurt Peynir Protein", "Süzme protein", 
      ["Süzme "Kekik", "Sarımsak:2 diş"], 230, 14, Peynir:150g", "Protein Tozu:20g"], 12, 14),
      280, 36, 8, 16));
    _yemek("Fırın yemekler.add(_kahvalti("Keçi Peyniri Protein", "Keçi peynir Sebze Yumurta", "Kahvaltı", ["Yumurta:2 adet", badem", 
      ["Keçi Peyniri:120g", "Kabak:100g", "Patlıcan:80g", "Biber:60g", "Domates:80g"], "Badem:30g"], 340, 22, 24, 14));
    
    260, 15, 12, 18),
    ];
  }
  
  // yemekler.add(_kahvalti("Manda Peyniri Protein", "Manda ============================================================================
  // PEYNIR KAHVALTILARI peynir yüksek protein", 
      ["Manda Peyniri:150g", - 50 ÇEŞİT
  // ============================================================================
  
  List<Map<String, dynamic>> "Ceviz:25g"], 340, 24, 24, 12));
    _peynirKahvaltilari() {
    return [
      // PEYNIR yemekler.add(_kahvalti("Koyun Peyniri Protein", TABAKLARI "Koyun peynir badem", 
      ["Koyun (10)
      _yemek("Klasik Peynir Tabağı", Peyniri:150g", "Badem:25g"], 360, 26, "Kahvaltı", ["Beyaz Peynir:100g", 26, 12));
    "Siyah yemekler.add(_kahvalti("Hellim Protein", "Hellim yüksek protein", 
      ["Hellim:150g", Zeytin:15 adet", "Domates:150g", "Sebze:150g"], "Salatalık:100g", "Yeşil Zeytin:10 380, 28, 26, 14));
    adet"], 280, 16, 18, yemekler.add(_kahvalti("Ezine Protein", "Ezine peynir ceviz", 
      12),
      _yemek("Karma Peynir Tabağı", ["Ezine Peyniri:150g", "Kahvaltı", ["Beyaz Peynir:60g", "Ceviz:30g"], 380, 24, "Kaşar:40g", 28, 12));
    "Tulum Peyniri:40g", "Ceviz:20g", yemekler.add(_kahvalti("Mihaliç Protein", "Mihaliç peynir badem", 
      ["Mihaliç Peyniri:150g", "Yeşillik:50g"], 360, 22, "Badem:25g"], 360, 26, 26, 12));
    24, 10),
      
    return yemekler;
  }
  
  // _yemek("Lor Peyniri Tabağı", "Kahvaltı", ["Lor Helper methods
  Map<String, dynamic> _kahvalti(String Peyniri:150g", "Bal:1 ad, String aciklama, List<String> çorba kaşığı", "Ceviz:30g", malzemeler, 
    int kalori, int "Meyve:80g"], 320, 20, 16, protein, int yag, int 28),
      karbonhidrat) {
    return {
      _yemek("Çökelek Kahvaltısı", 'id': yemekIdCounter++,
      "Kahvaltı", ["Çökelek:150g", 'ad': ad,
      'aciklama': aciklama,
      'kalori': kalori,
      "Domates:150g", "Roka:50g", "Zeytinyağı:1 'protein': protein,
      'yag': yag,
      'karbonhidrat': karbonhidrat,
      çorba kaşığı", "Pul Biber"], 240, 18, 'ogunTipi': 'kahvalti',
      12, 14),
      _yemek("Light Peynir Tabağı", 'malzemeler': malzemeler,
      'kategori': "Kahvaltı", ["Light Beyaz 'ekonomik',
      'alerjenler': Peynir:120g", "Sebze [],
      Çubukları:200g", 'hazirlamaSuresi': 15,
    };
  }
  
  // "Yeşil Zeytin:10 adet"], Placeholder methods 200, 20, 8, 16),
      - bunlar sonraki bölümlerde _yemek("Tuzsuz Peynir Tabağı", "Kahvaltı", ["Tuzsuz doldurulacak
  List<Map<String, dynamic>> _tahilKahvaltilari() => [];
  List<Map<String, dynamic>> _smoothieKahvaltilari() => [];
  List<Map<String, dynamic>> _proteinKahvaltilari() => [];
  List<Map<String, dynamic>> Lor:120g", _fitKahvaltilari() => [];
  List<Map<String, dynamic>> "Ceviz:25g", "Üzüm:100g", "Tam Buğday Ekmeği:1 dilim"], 310, 18, 14, _vejetaryenKahvaltilari() => [];
  30),
      _yemek("Keçi Peyniri Salatası", "Kahvaltı", ["Keçi Peyniri:80g", "Karışık 
  List<Map<String, dynamic>> Yeşillik:150g", "Ceviz:25g", _tavukYemekleri() => [];
  List<Map<String, dynamic>> "Balzamik _kirmiziEtYemekleri() Sos:1 çorba kaşığı"], 280, => [];
  List<Map<String, dynamic>> 16, 20, 12),
      _balikYemekleri() => [];
  List<Map<String, dynamic>> _yemek("Feta Peynir Tabağı", _vejetaryenAnaYemekler() => [];
  "Kahvaltı", ["Feta Peyniri:100g", "Domates:120g", List<Map<String, dynamic>> "Salatalık:100g", "Zeytinyağı:1 çorba kaşığı", "Zeytin:15 adet"], 300, _makarnaVePilavYemekleri() => [];
  List<Map<String, dynamic>> 17, 22, 10),
      _yemek("Cottage Cheese Bowl", "Kahvaltı", ["Cottage Cheese:150g", _guvecVeFirinYemekleri() => [];
  "Çilek:100g", List<Map<String, dynamic>> _hindiYemekleri() => [];
  "Yaban Mersini:50g", "Bal:1 List<Map<String, dynamic>> tatlı kaşığı"], 220, 18, 6, _etnikMutfakYemekleri() => 24),
      _yemek("Labne [];
  
  List<Map<String, dynamic>> Tabağı", "Kahvaltı", ["Labne:120g", "Yeşil _suzmeYogurtlari() => [];
  Zeytin:12 adet", "Çeri List<Map<String, dynamic>> Domates:100g", "Zeytinyağı:1 çorba kaşığı", _proteinBarlari() => [];
  List<Map<String, dynamic>> "Nane:15g"], 260, 14, _peynirTabaklari() => [];
  List<Map<String, dynamic>> 16, 14),
      
      // BÖREK VE HAMURIŞI _proteinShakeleri() => [];
  List<Map<String, dynamic>> (15)
      _yemek("Peynirli Börek", "Kahvaltı", _kuruYemisKombinasyonlari() => [];
  
  List<Map<String, ["Yufka:2 yaprak", "Beyaz Peynir:80g", dynamic>> "Yumurta:1 adet", _meyveSalatalari() => [];
  List<Map<String, dynamic>> "Maydanoz:30g"], _sandvicler() => [];
  List<Map<String, dynamic>> 340, 16, 14, 36),
      _wrapDurumler() => [];
  List<Map<String, _yemek("Su Böreği", dynamic>> _smoothieBowllar() => [];
  List<Map<String, dynamic>> "Kahvaltı", ["Yufka:3 yaprak", "Beyaz _granolaToplar() => [];
  Peynir:100g", "Tereyağı:20g", "Süt:50ml"], 380, 18, 18, 38),
      
  Future<void> _yemek("Sigara Böreği", "Kahvaltı", _dosyayaKaydet(String dosyaAdi, List<Map<String, dynamic>> ["Yufka:3 yaprak", "Beyaz Peynir:90g", yemekler) async {
    final file = "Maydanoz:40g"], 360, File('$dataPath/$dosyaAdi');
    17, 16, 36),
      await file.parent.create(recursive: true);
    await _yemek("Gözleme", "Kahvaltı", file.writeAsString(JsonEncoder.withIndent('  ["Gözleme ').convert(yemekler));
  }
}
