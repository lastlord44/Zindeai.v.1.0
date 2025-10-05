// lib/presentation/widgets/ogun_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/yemek.dart';

/// Yemek kartı widget'ı
class OgunCard extends StatelessWidget {
  final Yemek yemek;
  final VoidCallback? onTap;
  final VoidCallback? onAlternatifTap;
  final bool showDetails;

  const OgunCard({
    Key? key,
    required this.yemek,
    this.onTap,
    this.onAlternatifTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık satırı
              Row(
                children: [
                  // Öğün emoji
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getOgunColor(yemek.ogun).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        yemek.ogun.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Yemek adı ve öğün
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          yemek.ad,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              yemek.ogun.ad,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${yemek.zorluk.emoji} ${yemek.zorluk.ad}', // ✅ Düzeltildi: aciklama -> ad
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Alternatif butonu
                  if (yemek.alternatifler.isNotEmpty && onAlternatifTap != null)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: onAlternatifTap,
                      tooltip: 'Alternatif öner',
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Makro bilgileri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MakroChip(
                    label: 'Kalori',
                    value: '${yemek.kalori.toInt()}',
                    unit: 'kcal',
                    color: Colors.orange,
                  ),
                  _MakroChip(
                    label: 'Protein',
                    value: '${yemek.protein.toInt()}',
                    unit: 'g',
                    color: Colors.red,
                  ),
                  _MakroChip(
                    label: 'Karb',
                    value: '${yemek.karbonhidrat.toInt()}',
                    unit: 'g',
                    color: Colors.amber,
                  ),
                  _MakroChip(
                    label: 'Yağ',
                    value: '${yemek.yag.toInt()}',
                    unit: 'g',
                    color: Colors.blue,
                  ),
                ],
              ),
              
              // Detaylı bilgiler (opsiyonel)
              if (showDetails) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Hazırlama süresi
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${yemek.hazirlamaSuresi} dakika',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Etiketler
                if (yemek.etiketler.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: yemek.etiketler
                        .map((etiket) => Chip(
                              label: Text(
                                etiket,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Öğün tipine göre renk
  Color _getOgunColor(OgunTipi ogun) {
    switch (ogun) {
      case OgunTipi.kahvalti:
        return Colors.orange;
      case OgunTipi.araOgun1:
        return Colors.green;
      case OgunTipi.ogle:
        return Colors.blue;
      case OgunTipi.araOgun2:
        return Colors.purple;
      case OgunTipi.aksam:
        return Colors.indigo;
      case OgunTipi.geceAtistirma:
        return Colors.teal;
      case OgunTipi.cheatMeal:
        return Colors.pink;
    }
  }
}

/// Makro chip widget'ı
class _MakroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MakroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
