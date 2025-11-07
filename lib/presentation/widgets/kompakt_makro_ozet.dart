import 'package:flutter/material.dart';
import '../../domain/entities/gunluk_plan.dart';
import 'animated_meal_card.dart'; // 🎨 Progress Ring Animation

class KompaktMakroOzet extends StatelessWidget {
  final double mevcutKalori;
  final double hedefKalori;
  final double mevcutProtein;
  final double hedefProtein;
  final double mevcutKarb;
  final double hedefKarb;
  final double mevcutYag;
  final double hedefYag;
  final GunlukPlan? plan; // 🎯 Tolerans kontrolü için plan gerekli

  const KompaktMakroOzet({
    Key? key,
    required this.mevcutKalori,
    required this.hedefKalori,
    required this.mevcutProtein,
    required this.hedefProtein,
    required this.mevcutKarb,
    required this.hedefKarb,
    required this.mevcutYag,
    required this.hedefYag,
    this.plan, // Optional - tolerans kontrolü için
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🎯 GENEL TOLERANS UYARISI (Varsa)
        if (plan != null && !plan!.tumMakrolarToleranstaMi)
          _buildToleranceWarningCard(),
        
        if (plan != null && !plan!.tumMakrolarToleranstaMi)
          const SizedBox(height: 12),

        // Ana makro özet kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
          _buildMakroSatir(
            'Kalori',
            '🔥',
            mevcutKalori,
            hedefKalori,
            'kcal',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildMakroSatir(
            'Protein',
            '💪',
            mevcutProtein,
            hedefProtein,
            'g',
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildMakroSatir(
            'Karbonhidrat',
            '🍚',
            mevcutKarb,
            hedefKarb,
            'g',
            Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildMakroSatir(
            'Yağ',
            '🥑',
            mevcutYag,
            hedefYag,
            'g',
            Colors.green,
          ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🚨 TOLERANS UYARI KARTI (Kritik Uyarı!)
  Widget _buildToleranceWarningCard() {
    if (plan == null || plan!.tumMakrolarToleranstaMi) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.2),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⚠️ TOLERANS AŞILDI!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Açıklama
          Text(
            'Günlük planınızda bazı makrolar ±10% tolerans sınırını aştı. '
            'Plan kalitesi düşük olabilir.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Aşan makroların listesi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tolerans aşan makrolar:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ...plan!.toleransAsanMakrolar.map((makro) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            makro,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
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

          const SizedBox(height: 8),

          // Fitness skoru
          Row(
            children: [
              Icon(Icons.fitness_center, color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              Text(
                'Plan Kalite Skoru: ${plan!.makroKaliteSkoru.toStringAsFixed(1)}/100',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMakroSatir(
    String baslik,
    String emoji,
    double mevcut,
    double hedef,
    String birim,
    Color renk,
  ) {
    final yuzde = (mevcut / hedef * 100).clamp(0, 100);
    final progress = (yuzde / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        // 🎨 Animated Progress Ring
        ProgressRing(
          progress: progress,
          size: 50,
          strokeWidth: 5,
          startColor: renk,
          endColor: renk.withOpacity(0.6),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        
        // Başlık ve değerler
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: renk.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(renk),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Değerler
                  Text(
                    '${mevcut.toStringAsFixed(0)}/${hedef.toStringAsFixed(0)}$birim',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
