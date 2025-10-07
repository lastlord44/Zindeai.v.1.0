// ============================================================================
// ANALYTICS SAYFASI - FAZ 10
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics/analytics_bloc.dart';
import '../widgets/makro_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc()..add(LoadAnalytics(gunSayisi: 7)),
      child: const AnalyticsPageContent(),
    );
  }
}

class AnalyticsPageContent extends StatelessWidget {
  const AnalyticsPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnalyticsError) {
              return _buildErrorState(context, state.mesaj);
            }

            if (state is AnalyticsLoaded) {
              return _buildAnalyticsContent(context, state);
            }

            return const Center(child: Text('İstatistikler yükleniyor...'));
          },
        ),
      ),
    );
  }

  /// Hata durumu
  Widget _buildErrorState(BuildContext context, String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'İstatistik Bulunamadı',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              mesaj,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AnalyticsBloc>().add(LoadWeeklyAnalytics());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Analytics içeriği
  Widget _buildAnalyticsContent(BuildContext context, AnalyticsLoaded state) {
    return Column(
      children: [
        // Üst bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
              const Text(
                '📊 İstatistikler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Zaman aralığı filtreleri
              Row(
                children: [
                  _buildTimeFilterChip(
                    context,
                    '7 Gün',
                    isSelected: state.gunSayisi == 7,
                    onTap: () {
                      context.read<AnalyticsBloc>().add(LoadWeeklyAnalytics());
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip(
                    context,
                    '30 Gün',
                    isSelected: state.gunSayisi == 30,
                    onTap: () {
                      context.read<AnalyticsBloc>().add(LoadMonthlyAnalytics());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // İçerik
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Özet kartları
              _buildSummaryCards(state),
              const SizedBox(height: 24),

              // Kalori grafiği
              MakroChart(
                veriler: state.gunlukKaloriDagilimi,
                tarihler: state.tarihler,
                baslik: 'Günlük Kalori',
                renk: Colors.orange,
                birim: 'kcal',
              ),
              const SizedBox(height: 16),

              // Protein grafiği
              MakroChart(
                veriler: state.gunlukProteinDagilimi,
                tarihler: state.tarihler,
                baslik: 'Günlük Protein',
                renk: Colors.red,
                birim: 'g',
              ),
              const SizedBox(height: 16),

              // Karbonhidrat grafiği
              MakroChart(
                veriler: state.gunlukKarbonhidratDagilimi,
                tarihler: state.tarihler,
                baslik: 'Günlük Karbonhidrat',
                renk: Colors.amber,
                birim: 'g',
              ),
              const SizedBox(height: 16),

              // Yağ grafiği
              MakroChart(
                veriler: state.gunlukYagDagilimi,
                tarihler: state.tarihler,
                baslik: 'Günlük Yağ',
                renk: Colors.green,
                birim: 'g',
              ),
              const SizedBox(height: 16),

              // Fitness skoru grafiği
              MakroChart(
                veriler: state.gunlukFitnessSkoruDagilimi,
                tarihler: state.tarihler,
                baslik: 'Fitness Skoru',
                renk: Colors.purple,
                birim: 'puan',
              ),
              const SizedBox(height: 24),

              // En iyi/en kötü günler
              _buildBestWorstDays(state),
            ],
          ),
        ),
      ],
    );
  }

  /// Zaman filtresi chip
  Widget _buildTimeFilterChip(
    BuildContext context,
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Özet kartları
  Widget _buildSummaryCards(AnalyticsLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ortalama Kalori',
            '${state.ortalamaKalori.toStringAsFixed(0)} kcal',
            Colors.orange,
            Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Ortalama Protein',
            '${state.ortalamaProtein.toStringAsFixed(0)} g',
            Colors.red,
            Icons.fitness_center,
          ),
        ),
      ],
    );
  }

  /// Özet kartı
  Widget _buildSummaryCard(
    String baslik,
    String deger,
    Color renk,
    IconData icon,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: renk, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deger,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }

  /// En iyi/en kötü günler
  Widget _buildBestWorstDays(AnalyticsLoaded state) {
    if (state.enYuksekKaloriGunu == null || state.enDusukKaloriGunu == null) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'En İyi/En Kötü Günler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // En yüksek kalori
          _buildDayRow(
            '🔥 En Yüksek Kalori',
            state.enYuksekKaloriGunu!,
            Colors.orange,
          ),
          const SizedBox(height: 12),

          // En düşük kalori
          _buildDayRow(
            '🌱 En Düşük Kalori',
            state.enDusukKaloriGunu!,
            Colors.green,
          ),
        ],
      ),
    );
  }

  /// Gün satırı
  Widget _buildDayRow(String baslik, dynamic plan, Color renk) {
    final tarih = plan.tarih as DateTime;
    final kalori = plan.toplamKalori as double;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTarih(tarih),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${kalori.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
        ),
      ],
    );
  }

  /// Tarih formatlama
  String _formatTarih(DateTime tarih) {
    final aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${tarih.day} ${aylar[tarih.month - 1]} ${tarih.year}';
  }
}
