// ============================================================================
// MAKRO GRAFİĞİ WİDGET - FAZ 10
// ============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Makro besinlerin günlük dağılımını gösteren line chart
class MakroChart extends StatelessWidget {
  final List<double> veriler;
  final List<DateTime> tarihler;
  final String baslik;
  final Color renk;
  final String birim;
  final double? hedefDeger; // Hedef çizgisi için

  const MakroChart({
    Key? key,
    required this.veriler,
    required this.tarihler,
    required this.baslik,
    required this.renk,
    this.birim = 'g',
    this.hedefDeger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (veriler.isEmpty || tarihler.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
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
        child: Center(
          child: Text(
            'Veri bulunamadı',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final maxY = _hesaplaMaxY();
    final minY = _hesaplaMinY();

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: renk.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: renk,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_hesaplaOrtalama().toStringAsFixed(1)} $birim ort.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: renk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grafik
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: (maxY - minY) / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} $birim',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= tarihler.length) return const Text('');
                        
                        final tarih = tarihler[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${tarih.day}/${tarih.month}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Ana veri çizgisi
                  LineChartBarData(
                    spots: _olusturSpotlar(),
                    isCurved: true,
                    color: renk,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: renk,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: renk.withValues(alpha: 0.1),
                    ),
                  ),
                  // Hedef çizgisi (varsa)
                  if (hedefDeger != null)
                    LineChartBarData(
                      spots: _olusturHedefSpotlari(),
                      isCurved: false,
                      color: Colors.grey.shade400,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: renk.withValues(alpha: 0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 1) return null; // Hedef çizgisini gösterme
                        
                        final tarih = tarihler[spot.x.toInt()];
                        final gunIsimleri = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                        final gun = gunIsimleri[tarih.weekday - 1];
                        
                        return LineTooltipItem(
                          '$gun, ${tarih.day}/${tarih.month}\n${spot.y.toStringAsFixed(1)} $birim',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          // Hedef göstergesi (varsa)
          if (hedefDeger != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Hedef: ${hedefDeger!.toStringAsFixed(0)} $birim',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Spot'ları oluştur (veri noktaları)
  List<FlSpot> _olusturSpotlar() {
    return List.generate(
      veriler.length,
      (index) => FlSpot(index.toDouble(), veriler[index]),
    );
  }

  /// Hedef çizgisi spot'ları
  List<FlSpot> _olusturHedefSpotlari() {
    if (hedefDeger == null) return [];
    
    return [
      FlSpot(0, hedefDeger!),
      FlSpot(veriler.length - 1.0, hedefDeger!),
    ];
  }

  /// Maksimum Y değeri
  double _hesaplaMaxY() {
    final maxVeri = veriler.reduce((a, b) => a > b ? a : b);
    final max = hedefDeger != null && hedefDeger! > maxVeri 
        ? hedefDeger! 
        : maxVeri;
    return (max * 1.2).ceilToDouble(); // %20 padding
  }

  /// Minimum Y değeri
  double _hesaplaMinY() {
    final minVeri = veriler.reduce((a, b) => a < b ? a : b);
    final min = hedefDeger != null && hedefDeger! < minVeri 
        ? hedefDeger! 
        : minVeri;
    return (min * 0.8).floorToDouble(); // %20 padding
  }

  /// Ortalama değer
  double _hesaplaOrtalama() {
    if (veriler.isEmpty) return 0;
    return veriler.reduce((a, b) => a + b) / veriler.length;
  }
}

/// Basitleştirilmiş mini grafik (dashboard için)
class MiniMakroChart extends StatelessWidget {
  final List<double> veriler;
  final Color renk;

  const MiniMakroChart({
    Key? key,
    required this.veriler,
    required this.renk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (veriler.isEmpty) {
      return const SizedBox(height: 40);
    }

    return SizedBox(
      height: 40,
      child: LineChart(
        LineChartData(
          minY: veriler.reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: veriler.reduce((a, b) => a > b ? a : b) * 1.1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                veriler.length,
                (index) => FlSpot(index.toDouble(), veriler[index]),
              ),
              isCurved: true,
              color: renk,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: renk.withValues(alpha: 0.2),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
