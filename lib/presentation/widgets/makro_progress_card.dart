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

  /// ±5% tolerans limiti (GunlukPlan entity ile aynı)
  static const double toleransYuzdesi = 5.0;

  /// Sapma yüzdesi hesapla (mutlak değer)
  double get sapmaYuzdesi {
    return ((mevcut - hedef).abs() / hedef) * 100;
  }

  /// ±5% tolerans içinde mi?
  bool get toleranstaMi {
    return sapmaYuzdesi <= toleransYuzdesi;
  }

  /// Tolerans durumuna göre renk
  Color get durumaGoreRenk {
    if (toleranstaMi) {
      return Colors.green; // ✅ Tolerans içinde
    } else {
      return Colors.red; // ❌ Tolerans aşıldı (SIÇ TIK!)
    }
  }

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
        // 🎯 Tolerans durumuna göre border ekle
        border: !toleranstaMi 
            ? Border.all(color: Colors.red, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.1),
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
              backgroundColor: renk.withValues(alpha: 0.1),
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

          // 🎯 TOLERANS KONTROLÜ (±5%)
          const SizedBox(height: 8),
          _buildToleranceIndicator(),
        ],
      ),
    );
  }

  /// Tolerans göstergesi widget'ı
  Widget _buildToleranceIndicator() {
    if (toleranstaMi) {
      // ✅ Tolerans içinde - yeşil onay
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 6),
            Text(
              '±5% tolerans içinde (${sapmaYuzdesi.toStringAsFixed(1)}% sapma)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      // ❌ Tolerans aşıldı - kırmızı uyarı
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '⚠️ TOLERANS AŞILDI! ${sapmaYuzdesi.toStringAsFixed(1)}% sapma (Max: ±5%)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
