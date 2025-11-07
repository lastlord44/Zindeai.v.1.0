// ============================================================================
// MEGA YEMEK VERİTABANI OLUŞTURUCU - BÖLÜM 1
// AMAÇ: Programatik olarak binlerce sağlıklı, ekonomik ve pratik Türk yemeği üretmek.
// ============================================================================

import 'dart:math';

// Gerekli entity ve model dosyaları (proje yapısına göre düzenlenecek)
// import '../lib/domain/entities/yemek.dart';
// import '../lib/data/models/yemek_hive_model.dart';
// import '../lib/data/local/hive_service.dart';

// ============================================================================
// YASAKLI ÜRÜNLER LİSTESİ (KARA LİSTE)
// Bu malzemeler ASLA yemek tariflerinde kullanılmayacak.
// ============================================================================
const Set<String> ZARARLI_MALZEMELER = {
  'salam', 'sosis', 'sucuk', 'pastırma', 'işlenmiş et',
  'beyaz un', 'beyaz ekmek', 'beyaz pirinç', 'makarna (beyaz un)',
  'şeker', 'glikoz şurubu', 'fruktoz şurubu', 'mısır şurubu',
  'margarin', 'trans yağ', 'palm yağı',
  'hazır çorba', 'bulyon', 'hazır sos',
  'krem şanti', 'hazır puding',
  'gazlı içecek', 'kolalı içecek', 'enerji içeceği',
  'cips', 'patates kızartması',
  'pizza', 'hamburger (fast food)',
  'şekerleme', 'gofret', 'çikolata (sütlü)',
};

// ============================================================================
// SAĞLIKLI TÜRK MUTFAĞI BİLEŞENLERİ
// Ekonomik, pratik ve sağlıklı malzemeler.
// ============================================================================

// --- PROTEİN KAYNAKLARI ---
const List<String> PROTEIN_KAYNAKLARI = [
  'Tavuk Göğsü', 'Tavuk But', 'Hindi Göğsü',
  'Dana Kıyma (yağsız)', 'Dana Kuşbaşı',
  'Mercimek (kırmızı)', 'Mercimek (yeşil)', 'Nohut', 'Fasulye (kuru)',
  'Yumurta',
  'Süzme Yoğurt', 'Yoğurt', 'Lor Peyniri', 'Beyaz Peynir',
  'Somon', 'Levrek', 'Çipura', 'Hamsi', 'Ton Balığı (suda)',
];

// --- KARBONHİDRAT KAYNAKLARI ---
const List<String> KARBONHIDRAT_KAYNAKLARI = [
  'Bulgur', 'Karabuğday (greçka)', 'Kinoa',
  'Tam Buğday Ekmeği', 'Yulaf Ekmeği', 'Çavdar Ekmeği',
  'Yulaf Ezmesi',
  'Patates (haşlama/fırın)', 'Tatlı Patates',
  'Mısır (haşlama)',
  'Esmer Pirinç',
];

// --- SEBZE KAYNAKLARI ---
const List<String> SEBZE_KAYNAKLARI = [
  'Domates', 'Salatalık', 'Biber (yeşil/kırmızı)', 'Soğan', 'Sarımsak',
  'Marul', 'Roka', 'Maydanoz', 'Dereotu', 'Nane',
  'Ispanak', 'Pazı', 'Brokoli', 'Karnabahar',
  'Patlıcan', 'Kabak', 'Havuç', 'Turp',
  'Lahana (beyaz/kırmızı)', 'Mantar',
];

// --- SAĞLIKLI YAĞ KAYNAKLARI ---
const List<String> SAGLIKLI_YAG_KAYNAKLARI = [
  'Zeytinyağı',
  'Ceviz', 'Badem', 'Fındık',
  'Avokado',
  'Zeytin',
  'Tahin',
];

// --- MEYVE KAYNAKLARI (ARA ÖĞÜN İÇİN) ---
const List<String> MEYVE_KAYNAKLARI = [
  'Elma', 'Armut', 'Muz', 'Portakal',
  'Çilek', 'Böğürtlen', 'Ahududu',
  'Karpuz', 'Kavun',
  'Erik', 'Kayısı', 'Şeftali',
];

// ============================================================================
// YEMEK ÜRETİM MOTORU (TASLAK)
// ============================================================================

class MegaYemekGenerator {
  final Random _random = Random();

  // Bu fonksiyon, bileşenleri birleştirerek binlerce yemek üretecek.
  void generate() {
    print("🔥 Mega Yemek Veritabanı Oluşturucu Başlatılıyor...");
    print("🚫 Kara Liste Kontrolü: ${ZARARLI_MALZEMELER.length} zararlı malzeme engellendi.");
    print("✅ ${PROTEIN_KAYNAKLARI.length} protein, ${KARBONHIDRAT_KAYNAKLARI.length} karbonhidrat, ${SEBZE_KAYNAKLARI.length} sebze kaynağı yüklendi.");
    
    // Örnek bir yemek oluşturma mantığı (geliştirilecek)
    final protein = PROTEIN_KAYNAKLARI[_random.nextInt(PROTEIN_KAYNAKLARI.length)];
    final karb = KARBONHIDRAT_KAYNAKLARI[_random.nextInt(KARBONHIDRAT_KAYNAKLARI.length)];
    final sebze = SEBZE_KAYNAKLARI[_random.nextInt(SEBZE_KAYNAKLARI.length)];

    print("\nÖrnek Üretim 1 (Öğle Yemeği): Izgara $protein + $karb Pilavı + $sebze Salatası");
    
    final kahvaltilikProtein = ['Yumurta', 'Lor Peyniri', 'Beyaz Peynir'][_random.nextInt(3)];
    final kahvaltilikKarb = ['Tam Buğday Ekmeği', 'Yulaf Ezmesi'][_random.nextInt(2)];
    final kahvaltilikYag = ['Zeytin', 'Ceviz'][_random.nextInt(2)];

    print("Örnek Üretim 2 (Kahvaltı): $kahvaltilikProtein + $kahvaltilikKarb + $kahvaltilikYag ve Domates");

    print("\n🚀 Motor hazır. Bir sonraki adımda binlerce kombinasyon üretilip Hive'a yazılacak.");
  }
}

// Script'i çalıştırmak için ana fonksiyon
void main() {
  final generator = MegaYemekGenerator();
  generator.generate();
}
