// ============================================================================
// ANALYTICS SAYFASI - FAZ 10 - DÜZELTILDI
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics/analytics_bloc.dart';
import '../bloc/analytics/analytics_event.dart';
import '../bloc/analytics/analytics_state.dart';
import '../../domain/entities/gunluk_plan.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc()..add(LoadWeeklyAnalytics()),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      state.mesaj ?? 'Yükleniyor...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            if (state is AnalyticsError) {
              return _buildErrorState(context, state.mesaj);
            }

            if (state is WeeklyAnalyticsLoaded) {
              return _buildWeeklyAnalyticsContent(context, state);
            }
            
            if (state is MonthlyAnalyticsLoaded) {
              return _buildMonthlyAnalyticsContent(context, state);
            }

            return const Center(
              child: Text(
                'İstatistikler hazırlanıyor...',
                style: TextStyle(fontSize: 16),
              ),
            );
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
          const Text(
            'İstatistik Bulunamadı',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  /// Haftalık analytics içeriği
  Widget _buildWeeklyAnalyticsContent(BuildContext context, WeeklyAnalyticsLoaded state) {
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
                    isSelected: true,
                    onTap: () {
                      context.read<AnalyticsBloc>().add(LoadWeeklyAnalytics());
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip(
                    context,
                    '30 Gün',
                    isSelected: false,
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

              // Trend bilgisi
              _buildTrendCard(state.data.trend),
              const SizedBox(height: 24),

              // En iyi/en kötü günler
              _buildBestWorstDays(state.data.planlar),
              const SizedBox(height: 24),

              // Favori yemekler
              _buildFavoriteMeals(state.data.enCokYenilenYemekler),
            ],
          ),
        ),
      ],
    );
  }

  /// Aylık analytics içeriği
  Widget _buildMonthlyAnalyticsContent(BuildContext context, MonthlyAnalyticsLoaded state) {
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
                    isSelected: false,
                    onTap: () {
                      context.read<AnalyticsBloc>().add(LoadWeeklyAnalytics());
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildTimeFilterChip(
                    context,
                    '30 Gün',
                    isSelected: true,
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
              // Özet kartları (aylık)
              _buildMonthlySummaryCards(state),
              const SizedBox(height: 24),

              // Trend bilgisi
              _buildTrendCard(state.data.trend),
              const SizedBox(height: 24),

              // En iyi/en kötü günler
              _buildBestWorstDays(state.data.planlar),
              const SizedBox(height: 24),

              // Favori yemekler
              _buildFavoriteMeals(state.data.enCokYenilenYemekler),
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

  /// Haftalık özet kartları
  Widget _buildSummaryCards(WeeklyAnalyticsLoaded state) {
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

  /// Aylık özet kartları
  Widget _buildMonthlySummaryCards(MonthlyAnalyticsLoaded state) {
    final ortalama = _hesaplaOrtalamaMakrolar(state.data.gunlukMakrolar);
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ortalama Kalori',
            '${ortalama.kalori.toStringAsFixed(0)} kcal',
            Colors.orange,
            Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Ortalama Protein',
            '${ortalama.protein.toStringAsFixed(0)} g',
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

  /// Trend kartı
  Widget _buildTrendCard(IlerlemeTrendi trend) {
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
            '📈 İlerleme Trendi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  'Kalori',
                  trend.kaloriTrendi,
                ),
              ),
              Expanded(
                child: _buildTrendItem(
                  'Protein',
                  trend.proteinTrendi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  'Karbonhidrat',
                  trend.karbonhidratTrendi,
                ),
              ),
              Expanded(
                child: _buildTrendItem(
                  'Antrenman',
                  trend.antrenmanTrendi,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Trend öğesi
  Widget _buildTrendItem(String baslik, TrendYonu trend) {
    return Column(
      children: [
        Text(
          trend.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          baslik,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          trend.displayName,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// En iyi/en kötü günler
  Widget _buildBestWorstDays(List<GunlukPlan> planlar) {
    if (planlar.length < 2) {
      return const SizedBox.shrink();
    }

    // En yüksek ve en düşük kalori günlerini bul
    final sortedPlanlar = List<GunlukPlan>.from(planlar)
      ..sort((a, b) => a.toplamKalori.compareTo(b.toplamKalori));
    
    final enDusukPlan = sortedPlanlar.first;
    final enYuksekPlan = sortedPlanlar.last;

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
            '🏆 En İyi/En Kötü Günler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // En yüksek kalori
          _buildDayRow(
            '🔥 En Yüksek Kalori',
            enYuksekPlan,
            Colors.orange,
          ),
          const SizedBox(height: 12),

          // En düşük kalori
          _buildDayRow(
            '🌱 En Düşük Kalori',
            enDusukPlan,
            Colors.green,
          ),
        ],
      ),
    );
  }

  /// Gün satırı
  Widget _buildDayRow(String baslik, GunlukPlan plan, Color renk) {
    final tarih = plan.tarih;
    final kalori = plan.toplamKalori;

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

  /// Favori yemekler
  Widget _buildFavoriteMeals(Map<String, int> yemekSayilari) {
    if (yemekSayilari.isEmpty) return const SizedBox.shrink();

    final sortedYemekler = yemekSayilari.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topYemekler = sortedYemekler.take(5).toList();

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
            '❤️ En Sevilen Yemekler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topYemekler.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entry.value}x',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Ortalama makroları hesapla
  MacroValues _hesaplaOrtalamaMakrolar(Map<DateTime, MacroValues> gunlukMakrolar) {
    if (gunlukMakrolar.isEmpty) {
      return MacroValues(
        kalori: 0,
        protein: 0,
        karbonhidrat: 0,
        yag: 0,
        tarih: DateTime.now(),
      );
    }

    final toplamKalori = gunlukMakrolar.values.fold<double>(0, (sum, makro) => sum + makro.kalori);
    final toplamProtein = gunlukMakrolar.values.fold<double>(0, (sum, makro) => sum + makro.protein);
    final toplamKarb = gunlukMakrolar.values.fold<double>(0, (sum, makro) => sum + makro.karbonhidrat);
    final toplamYag = gunlukMakrolar.values.fold<double>(0, (sum, makro) => sum + makro.yag);

    return MacroValues(
      kalori: toplamKalori / gunlukMakrolar.length,
      protein: toplamProtein / gunlukMakrolar.length,
      karbonhidrat: toplamKarb / gunlukMakrolar.length,
      yag: toplamYag / gunlukMakrolar.length,
      tarih: DateTime.now(),
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