import 'package:flutter/material.dart';

// ============================================================================
// ALTERNATİF BESİN BOTTOM SHEET
// ============================================================================

class AlternatifBesinBottomSheet extends StatelessWidget {
  final String orijinalBesinAdi;
  final double orijinalMiktar;
  final String orijinalBirim;
  final List<AlternatifBesin> alternatifler;
  final String alerjiNedeni; // "Ceviz alerjiniz var" veya "Bulamıyorum"

  const AlternatifBesinBottomSheet({
    Key? key,
    required this.orijinalBesinAdi,
    required this.orijinalMiktar,
    required this.orijinalBirim,
    required this.alternatifler,
    required this.alerjiNedeni,
  }) : super(key: key);

  static void goster(
    BuildContext context, {
    required String orijinalBesinAdi,
    required double orijinalMiktar,
    required String orijinalBirim,
    required List<AlternatifBesin> alternatifler,
    required String alerjiNedeni,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlternatifBesinBottomSheet(
        orijinalBesinAdi: orijinalBesinAdi,
        orijinalMiktar: orijinalMiktar,
        orijinalBirim: orijinalBirim,
        alternatifler: alternatifler,
        alerjiNedeni: alerjiNedeni,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Başlık
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bu besini yiyemezsiniz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alerjiNedeni,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Orijinal besin
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${orijinalMiktar.toStringAsFixed(0)} $orijinalBirim $orijinalBesinAdi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alternatifler listesi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Row(
                  children: [
                    Icon(Icons.autorenew, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Alternatif Besinler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...alternatifler.map((alt) => _buildAlternatifCard(context, alt)),

                const SizedBox(height: 80), // Alt boşluk
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternatifCard(BuildContext context, AlternatifBesin alternatif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context, alternatif);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ ${alternatif.ad} seçildi (${alternatif.miktar.toStringAsFixed(0)} ${alternatif.birim})',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst kısım
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${alternatif.miktar.toStringAsFixed(0)} ${alternatif.birim} ${alternatif.ad}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alternatif.neden,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Besin değerleri
                Row(
                  children: [
                    _buildNutrientBadge(
                      '🔥',
                      '${alternatif.kalori.toStringAsFixed(0)} kcal',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildNutrientBadge(
                      '💪',
                      '${alternatif.protein.toStringAsFixed(1)}g',
                      Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildNutrientBadge(
                      '🍚',
                      '${alternatif.karbonhidrat.toStringAsFixed(1)}g',
                      Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildNutrientBadge(
                      '🥑',
                      '${alternatif.yag.toStringAsFixed(1)}g',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// YEMEK DETAY SAYFASINDA KULLANIM
// ============================================================================

class MealDetailPage extends StatelessWidget {
  final Meal meal;
  final List<String> kullaniciKisitlamalari;

  const MealDetailPage({
    Key? key,
    required this.meal,
    required this.kullaniciKisitlamalari,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.ad),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Yemek bilgileri...
          
          // Malzemeler bölümü
          const SizedBox(height: 24),
          const Text(
            '🥗 Malzemeler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Her malzeme için
          ...meal.besinIcerikleri.map((besin) {
            // Kısıtlama kontrolü
            final kisitlamali = kullaniciKisitlamalari.any(
              (k) => besin.ad.toLowerCase().contains(k.toLowerCase()),
            );

            if (kisitlamali) {
              // ⚠️ KISITLAMALI BESİN - ALTERNATİF GÖSTER
              return _buildKisitlamalıBesinCard(context, besin);
            } else {
              // ✅ NORMAL BESİN
              return _buildNormalBesinCard(besin);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildKisitlamalıBesinCard(BuildContext context, BesinIcerigi besin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${besin.miktar.toStringAsFixed(0)} ${besin.birim} ${besin.ad}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            '⚠️ Bu besinde kısıtlamanız var',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade800,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Alternatif göster butonu
          ElevatedButton.icon(
            onPressed: () {
              // Alternatif üret
              final alternatifler = AlternatifOneriServisi.otomatikAlternatifUret(
                besin.ad,
                besin.miktar,
                besin.birim,
              );

              if (alternatifler.isEmpty) {
                // Alternatif yoksa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('😔 Bu besin için alternatif bulunamadı'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                // Bottom sheet göster
                AlternatifBesinBottomSheet.goster(
                  context,
                  orijinalBesinAdi: besin.ad,
                  orijinalMiktar: besin.miktar,
                  orijinalBirim: besin.birim,
                  alternatifler: alternatifler,
                  alerjiNedeni: _alerjiNedeniBul(besin.ad),
                );
              }
            },
            icon: const Icon(Icons.autorenew),
            label: const Text('Alternatif Göster'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalBesinCard(BesinIcerigi besin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${besin.miktar.toStringAsFixed(0)} ${besin.birim} ${besin.ad}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _alerjiNedeniBul(String besinAdi) {
    final besinKucuk = besinAdi.toLowerCase();
    
    // Kullanıcının kısıtlamalarında varsa
    for (final kisitlama in kullaniciKisitlamalari) {
      if (besinKucuk.contains(kisitlama.toLowerCase())) {
        return '$kisitlama alerjiniz/kısıtlamanız var';
      }
    }
    
    return 'Bu besini tüketemezsiniz';
  }
}
