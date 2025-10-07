import 'package:flutter/material.dart';
import '../../domain/entities/yemek.dart';

class DetayliOgunCard extends StatelessWidget {
  final Yemek yemek;
  final bool tamamlandi;
  final VoidCallback onYedimPressed;
  final VoidCallback? onAlternatifPressed;
  final Function(Yemek yemek, String malzemeMetni, int malzemeIndex)? onMalzemeAlternatifiPressed;

  const DetayliOgunCard({
    Key? key,
    required this.yemek,
    required this.tamamlandi,
    required this.onYedimPressed,
    this.onAlternatifPressed,
    this.onMalzemeAlternatifiPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tamamlandi ? Colors.green.shade300 : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve öğün tipi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getOgunRengi().withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getOgunRengi().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      yemek.ogun.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yemek.ogun.ad,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getOgunRengi(),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        yemek.ad,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tamamlandi)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Yedim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Malzemeler listesi
          if (yemek.malzemeler.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Malzemeler:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...yemek.malzemeler.asMap().entries.map((entry) {
                    final index = entry.key;
                    final malzeme = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _getOgunRengi(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              malzeme,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Malzeme alternatifi butonu
                          if (onMalzemeAlternatifiPressed != null)
                            InkWell(
                              onTap: () => onMalzemeAlternatifiPressed!(
                                yemek,
                                malzeme,
                                index,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.swap_horiz,
                                  size: 16,
                                  color: _getOgunRengi().withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Makro değerler
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMakroBadge(
                  '🔥',
                  yemek.kalori.toStringAsFixed(0),
                  'kcal',
                  Colors.orange,
                ),
                _buildMakroBadge(
                  '💪',
                  yemek.protein.toStringAsFixed(0),
                  'g P',
                  Colors.red,
                ),
                _buildMakroBadge(
                  '🍚',
                  yemek.karbonhidrat.toStringAsFixed(0),
                  'g K',
                  Colors.amber,
                ),
                _buildMakroBadge(
                  '🥑',
                  yemek.yag.toStringAsFixed(0),
                  'g Y',
                  Colors.green,
                ),
              ],
            ),
          ),

          // Butonlar - Yedim ve Yemedim ayrı ayrı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Yedim / Yemedim butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: tamamlandi ? null : onYedimPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tamamlandi
                              ? Colors.green
                              : Colors.grey.shade200,
                          foregroundColor: tamamlandi
                              ? Colors.white
                              : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: tamamlandi ? 2 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tamamlandi
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Yedim',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !tamamlandi ? null : onYedimPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !tamamlandi
                              ? Colors.red
                              : Colors.grey.shade200,
                          foregroundColor: !tamamlandi
                              ? Colors.white
                              : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: !tamamlandi ? 2 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              !tamamlandi
                                  ? Icons.cancel
                                  : Icons.cancel_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Yemedim',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Alternatif besin butonu
                if (onAlternatifPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAlternatifPressed,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text(
                        'Alternatif Besin Seç',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMakroBadge(
    String emoji,
    String deger,
    String birim,
    Color renk,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          deger,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: renk,
          ),
        ),
        Text(
          birim,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getOgunRengi() {
    switch (yemek.ogun) {
      case OgunTipi.kahvalti:
        return Colors.orange;
      case OgunTipi.araOgun1:
        return Colors.blue;
      case OgunTipi.ogle:
        return Colors.red;
      case OgunTipi.araOgun2:
        return Colors.green;
      case OgunTipi.aksam:
        return Colors.purple;
      case OgunTipi.geceAtistirma:
        return Colors.indigo;
      case OgunTipi.cheatMeal:
        return Colors.pink;
    }
  }
}
