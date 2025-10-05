// ============================================================================
// lib/presentation/widgets/ogun_card.dart
// FAZ 7: ÖĞÜN CARD WIDGET
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/yemek.dart';

class OgunCard extends StatelessWidget {
  final Yemek yemek;
  final VoidCallback onTap;
  final bool secili;

  const OgunCard({
    Key? key,
    required this.yemek,
    required this.onTap,
    this.secili = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secili ? Colors.purple : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      yemek.ogun.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Öğün adı
                      Text(
                        yemek.ad,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Makro bilgileri
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildMakroBadge(
                            '🔥',
                            '${yemek.kalori.toStringAsFixed(0)} kcal',
                            Colors.orange,
                          ),
                          _buildMakroBadge(
                            '💪',
                            '${yemek.protein.toStringAsFixed(0)}g',
                            Colors.red,
                          ),
                        ],
                      ),
                      
                      // Zorluk ve süre
                      if (yemek.hazirlamaSuresi > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⏱️ ${yemek.hazirlamaSuresi} dk | ${yemek.zorluk.emoji} ${yemek.zorluk.aciklama}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Seçim ikonu
                Icon(
                  secili ? Icons.check_circle : Icons.chevron_right,
                  color: secili ? Colors.purple : Colors.grey.shade300,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMakroBadge(String emoji, String text, Color color) {
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
