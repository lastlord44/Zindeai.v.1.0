import 'package:flutter/material.dart';

class KompaktMakroOzet extends StatelessWidget {
  final double mevcutKalori;
  final double hedefKalori;
  final double mevcutProtein;
  final double hedefProtein;
  final double mevcutKarb;
  final double hedefKarb;
  final double mevcutYag;
  final double hedefYag;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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

    return Row(
      children: [
        // Emoji ve başlık
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            baslik,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: yuzde / 100,
              minHeight: 8,
              backgroundColor: renk.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(renk),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Değerler
        SizedBox(
          width: 80,
          child: Text(
            '${mevcut.toStringAsFixed(0)}/${hedef.toStringAsFixed(0)}$birim',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
