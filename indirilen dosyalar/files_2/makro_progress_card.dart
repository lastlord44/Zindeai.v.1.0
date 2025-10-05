// ============================================================================
// lib/presentation/widgets/makro_progress_card.dart
// FAZ 7: MAKRO PROGRESS CARD WIDGET
// ============================================================================

import 'package:flutter/material.dart';

class MakroProgressCard extends StatelessWidget {
  final String baslik;
  final double mevcut;
  final double hedef;
  final Color renk;
  final String emoji;

  const MakroProgressCard({
    Key? key,
    required this.baslik,
    required this.mevcut,
    required this.hedef,
    required this.renk,
    required this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yuzde = (mevcut / hedef * 100).clamp(0, 100);
    final kalanMiktar = (hedef - mevcut).clamp(0, double.infinity);
    final asanMiktar = (mevcut - hedef).clamp(0, double.infinity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: renk.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                '${mevcut.toStringAsFixed(0)}/${hedef.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: renk,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: yuzde / 100,
              minHeight: 10,
              backgroundColor: renk.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(renk),
            ),
          ),

          const SizedBox(height: 8),

          // Yüzde ve kalan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${yuzde.toStringAsFixed(0)}% tamamlandı',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (kalanMiktar > 0)
                Text(
                  'Kalan: ${kalanMiktar.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                )
              else if (asanMiktar > 0)
                Text(
                  'Aşan: ${asanMiktar.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
