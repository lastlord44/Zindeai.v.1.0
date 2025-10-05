// ============================================================================
// lib/presentation/pages/home_page.dart
// FAZ 8: HOME PAGE (ANA EKRAN)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/makro_progress_card.dart';
import '../widgets/ogun_card.dart';
import '../../data/datasources/yemek_local_data_source.dart';
import '../../domain/usecases/ogun_planlayici.dart';
import '../../domain/usecases/makro_hesapla.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        planlayici: OgunPlanlayici(
          dataSource: YemekLocalDataSource(),
        ),
        makroHesaplama: MakroHesapla(),
      )..add(LoadDailyPlan()),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.purple,
          title: const Text(
            'ZindeAI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Ayarlar sayfasına git
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // ================================================================
            // LOADING STATE
            // ================================================================
            if (state is HomeLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Plan hazırlanıyor...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ================================================================
            // ERROR STATE
            // ================================================================
            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.mesaj,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<HomeBloc>().add(LoadDailyPlan());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ================================================================
            // LOADED STATE
            // ================================================================
            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshPlan());
                  // BLoC state'in değişmesini bekle
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Hoş geldin kartı
                    _buildWelcomeCard(state.kullanici.ad),

                    const SizedBox(height: 24),

                    // Makro progress kartları
                    MakroProgressCard(
                      baslik: 'Kalori',
                      mevcut: state.plan.toplamKalori,
                      hedef: state.hedefler.gunlukKalori,
                      renk: Colors.orange,
                      emoji: '🔥',
                    ),
                    MakroProgressCard(
                      baslik: 'Protein',
                      mevcut: state.plan.toplamProtein,
                      hedef: state.hedefler.gunlukProtein,
                      renk: Colors.red,
                      emoji: '💪',
                    ),
                    MakroProgressCard(
                      baslik: 'Karbonhidrat',
                      mevcut: state.plan.toplamKarbonhidrat,
                      hedef: state.hedefler.gunlukKarbonhidrat,
                      renk: Colors.amber,
                      emoji: '🍚',
                    ),
                    MakroProgressCard(
                      baslik: 'Yağ',
                      mevcut: state.plan.toplamYag,
                      hedef: state.hedefler.gunlukYag,
                      renk: Colors.green,
                      emoji: '🥑',
                    ),

                    const SizedBox(height: 24),

                    // Fitness skoru
                    _buildFitnessScore(state.plan.fitnessSkor),

                    const SizedBox(height: 24),

                    // Öğünler başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bugünün Öğünleri',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<HomeBloc>().add(RefreshPlan());
                          },
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Yenile'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Öğün kartları
                    ...state.plan.tumOgunler.map((ogun) {
                      return OgunCard(
                        yemek: ogun,
                        onTap: () {
                          // Öğün detayı göster
                          _showMealDetail(context, ogun);
                        },
                      );
                    }),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            }

            // ================================================================
            // INITIAL STATE
            // ================================================================
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              return FloatingActionButton.extended(
                onPressed: () {
                  context.read<HomeBloc>().add(RefreshPlan());
                },
                backgroundColor: Colors.purple,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Yeni Plan Oluştur'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================

  Widget _buildWelcomeCard(String kullaniciAdi) {
    final saat = DateTime.now().hour;
    String selamlama;

    if (saat < 12) {
      selamlama = 'Günaydın';
    } else if (saat < 18) {
      selamlama = 'İyi günler';
    } else {
      selamlama = 'İyi akşamlar';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_emotions,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selamlama, $kullaniciAdi!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bugün harika bir gün! 💪',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessScore(double skor) {
    Color renk;
    String emoji;
    String mesaj;

    if (skor >= 90) {
      renk = Colors.green;
      emoji = '🌟';
      mesaj = 'Mükemmel eşleşme!';
    } else if (skor >= 75) {
      renk = Colors.blue;
      emoji = '✨';
      mesaj = 'Harika eşleşme!';
    } else if (skor >= 60) {
      renk = Colors.orange;
      emoji = '👍';
      mesaj = 'İyi eşleşme!';
    } else {
      renk = Colors.amber;
      emoji = '⚠️';
      mesaj = 'Orta eşleşme';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Uyum Skoru',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mesaj,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: renk.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${skor.toStringAsFixed(0)}/100',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: renk.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetail(BuildContext context, dynamic ogun) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // İçerik
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    ogun.ad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ogun.ogun.aciklama,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Besin değerleri
                  _buildNutrientRow('🔥 Kalori', '${ogun.kalori.toStringAsFixed(0)} kcal'),
                  _buildNutrientRow('💪 Protein', '${ogun.protein.toStringAsFixed(1)} g'),
                  _buildNutrientRow('🍚 Karbonhidrat', '${ogun.karbonhidrat.toStringAsFixed(1)} g'),
                  _buildNutrientRow('🥑 Yağ', '${ogun.yag.toStringAsFixed(1)} g'),

                  if (ogun.hazirlamaSuresi > 0) ...[
                    const SizedBox(height: 16),
                    _buildNutrientRow('⏱️ Hazırlama', '${ogun.hazirlamaSuresi} dakika'),
                    _buildNutrientRow('${ogun.zorluk.emoji} Zorluk', ogun.zorluk.aciklama),
                  ],

                  const SizedBox(height: 24),

                  // Malzemeler
                  const Text(
                    'Malzemeler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ogun.malzemeler.map((malzeme) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(malzeme),
                        ],
                      ),
                    );
                  }),

                  if (ogun.tarif != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Tarif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ogun.tarif!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
