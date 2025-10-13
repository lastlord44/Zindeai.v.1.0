import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/hive_service.dart';
import '../../data/datasources/yemek_hive_data_source.dart';
import '../../domain/usecases/ogun_planlayici.dart';
import '../../domain/usecases/malzeme_bazli_ogun_planlayici.dart';
import '../../data/local/besin_malzeme_hive_service.dart';
import '../../domain/usecases/makro_hesapla.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/hedef.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../widgets/tarih_secici.dart';
import '../widgets/haftalik_takvim.dart';
import '../widgets/kompakt_makro_ozet.dart';
import '../widgets/detayli_ogun_card.dart';
import '../widgets/alt_navigasyon_bar.dart';
import '../widgets/alternatif_yemek_bottom_sheet.dart';
import '../widgets/alternatif_besin_bottom_sheet.dart';
import 'profil_page.dart';
import 'antrenman_page.dart';
import 'maintenance_page.dart';
import 'ai_chatbot_page.dart';

class YeniHomePage extends StatelessWidget {
  const YeniHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        planlayici: OgunPlanlayici(
          dataSource: YemekHiveDataSource(),
        ),
        // ⚡ ESKİ SİSTEM AKTİF: Hazır yemeklerle HIZLI plan!
        // Malzeme bazlı sistem çok yavaş, 4200 besin yüklüyor, donuyor
        malzemeBazliPlanlayici: null, // DEVRE DIŞI!
        makroHesaplama: MakroHesapla(),
      ),
      child: const YeniHomePageView(),
    );
  }
}

class YeniHomePageView extends StatefulWidget {
  const YeniHomePageView({Key? key}) : super(key: key);

  @override
  State<YeniHomePageView> createState() => _YeniHomePageViewState();
}

class _YeniHomePageViewState extends State<YeniHomePageView> {
  NavigasyonSekme _aktifSekme = NavigasyonSekme.beslenme;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        // Android geri tuşu için çıkış onayı
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Uygulamadan Çık'),
            content: const Text('Uygulamadan çıkmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hayır'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Evet, Çık'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
        title: const Text('ZindeAI'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintenancePage(),
                ),
              );
            },
            tooltip: 'Maintenance & Debug',
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Alternatif yemekler yüklendiğinde bottom sheet aç
          if (state is AlternativeMealsLoaded) {
            AlternatifYemekBottomSheet.goster(
              context,
              mevcutYemek: state.mevcutYemek,
              alternatifYemekler: state.alternatifYemekler,
              onYemekSecildi: (yeniYemek) {
                context.read<HomeBloc>().add(
                      ReplaceMealWith(
                        eskiYemek: state.mevcutYemek,
                        yeniYemek: yeniYemek,
                      ),
                    );
              },
            );
          }
          
          // Alternatif malzemeler yüklendiğinde bottom sheet aç
          if (state is AlternativeIngredientsLoaded) {
            AlternatifBesinBottomSheet.goster(
              context,
              orijinalBesinAdi: state.orijinalMalzemeMetni,
              orijinalMiktar: 0, // Parsed değerler zaten alternatif besinlerde
              orijinalBirim: '',
              alternatifler: state.alternatifBesinler,
              alerjiNedeni: 'Malzeme değişikliği',
            ).then((secilenAlternatif) {
              if (secilenAlternatif != null) {
                // Yeni malzeme metnini oluştur
                final yeniMalzemeMetni = '${secilenAlternatif.miktar.toStringAsFixed(0)} ${secilenAlternatif.birim} ${secilenAlternatif.ad}';
                
                context.read<HomeBloc>().add(
                      ReplaceIngredientWith(
                        yemek: state.yemek,
                        malzemeIndex: state.malzemeIndex,
                        yeniMalzemeMetni: yeniMalzemeMetni,
                      ),
                    );
              } else {
                // 🔥 FIX: Alternatif seçilmeden iptal edildiyse, planı yeniden yükle
                context.read<HomeBloc>().add(
                      LoadPlanByDate(state.currentDate),
                    );
              }
            });
          }
        },
        builder: (context, state) {
          // Profil sekmesi seçiliyse ProfilPage'i göster
          if (_aktifSekme == NavigasyonSekme.profil) {
            return Column(
              children: [
                Expanded(
                  child: ProfilPage(
                    // ✅ Profil kaydedilince sadece sekmeyi değiştir, otomatik plan oluşturma YOK
                    onProfilKaydedildi: () {
                      setState(() {
                        _aktifSekme = NavigasyonSekme.beslenme;
                      });
                      // Plan oluşturma YOK - kullanıcı "Plan Oluştur" butonuna basacak
                    },
                  ),
                ),
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          // Antrenman sekmesi - ENTEGRE EDİLDİ! 💪
          if (_aktifSekme == NavigasyonSekme.antrenman) {
            return Column(
              children: [
                const Expanded(child: AntrenmanPage()),
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          // Supplement sekmesi - AI Chatbot 🤖
          if (_aktifSekme == NavigasyonSekme.supplement) {
            return Column(
              children: [
                const Expanded(child: AIChatbotPage()),
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          // Beslenme sekmesi (varsayılan)
          // AlternativeIngredientsLoaded da HomeLoaded gibi render edilmeli
          if (state is AlternativeIngredientsLoaded) {
            return Column(
              children: [
                // Ana içerik
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<HomeBloc>()
                          .add(LoadPlanByDate(state.currentDate));
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Tarih seçici (ok butonları ile)
                        TarihSecici(
                          secilenTarih: state.currentDate,
                          onGeriGit: () {
                            final yeniTarih = state.currentDate
                                .subtract(const Duration(days: 1));
                            context
                                .read<HomeBloc>()
                                .add(LoadPlanByDate(yeniTarih));
                          },
                          onIleriGit: () {
                            final yeniTarih = state.currentDate
                                .add(const Duration(days: 1));
                            context
                                .read<HomeBloc>()
                                .add(LoadPlanByDate(yeniTarih));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Haftalık takvim
                        HaftalikTakvim(
                          secilenTarih: state.currentDate,
                          onTarihSecildi: (tarih) {
                            context.read<HomeBloc>().add(LoadPlanByDate(tarih));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Kompakt makro özeti
                        KompaktMakroOzet(
                          mevcutKalori: _calculateTamamlananKalori(state.plan, state.tamamlananOgunler),
                          hedefKalori: state.hedefler.gunlukKalori,
                          mevcutProtein: _calculateTamamlananProtein(state.plan, state.tamamlananOgunler),
                          hedefProtein: state.hedefler.gunlukProtein,
                          mevcutKarb: _calculateTamamlananKarb(state.plan, state.tamamlananOgunler),
                          hedefKarb: state.hedefler.gunlukKarbonhidrat,
                          mevcutYag: _calculateTamamlananYag(state.plan, state.tamamlananOgunler),
                          hedefYag: state.hedefler.gunlukYag,
                          plan: state.plan, // 🎯 Tolerans kontrolü için
                        ),

                        const SizedBox(height: 24),

                        // Öğünler başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Günlük Öğünler',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('7 Günlük Plan Oluştur'),
                                        content: const Text(
                                          'Pazartesi\'den Pazar\'a kadar 7 günlük besin planı oluşturulsun mu? '
                                          'Her gün 5 öğün (Kahvaltı, Ara Öğün 1, Öğle, Ara Öğün 2, Akşam) içerecek.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext),
                                            child: const Text('İptal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              context.read<HomeBloc>().add(
                                                    GenerateWeeklyPlan(forceRegenerate: true),
                                                  );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Oluştur'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_month, size: 18),
                                  label: const Text('7 Gün'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    context
                                        .read<HomeBloc>()
                                        .add(RefreshDailyPlan(forceRegenerate: true));
                                  },
                                  tooltip: 'Bugünü Yenile',
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Detaylı öğün kartları
                        ...state.plan.ogunler.map((yemek) {
                          final tamamlandi =
                              state.tamamlananOgunler[yemek.id] ?? false;
                          return DetayliOgunCard(
                            yemek: yemek,
                            tamamlandi: tamamlandi,
                            onYedimPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(ToggleMealCompletion(yemek.id));
                            },
                            onAlternatifPressed: () {
                              // Alternatif yemekler oluştur
                              context.read<HomeBloc>().add(
                                    GenerateAlternativeMeals(
                                      mevcutYemek: yemek,
                                      sayi: 3,
                                    ),
                                  );
                            },
                            onMalzemeAlternatifiPressed: (yemek, malzemeMetni, malzemeIndex) {
                              // Malzeme için alternatif besinler oluştur
                              context.read<HomeBloc>().add(
                                    GenerateIngredientAlternatives(
                                      yemek: yemek,
                                      malzemeMetni: malzemeMetni,
                                      malzemeIndex: malzemeIndex,
                                    ),
                                  );
                            },
                          );
                        }),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Alt navigasyon barı
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }
          
          if (state is HomeLoading) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.purple),
                        const SizedBox(height: 16),
                        Text(
                          state.message ?? 'Yükleniyor...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          if (state is HomeError) {
            // Hata durumunda da "Plan Oluştur" butonu göster
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.purple.shade200,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Beslenme Planı Oluştur',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Günlük beslenme planınızı oluşturmak için\naşağıdaki butona tıklayın',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<HomeBloc>().add(LoadHomePage());
                            },
                            icon: const Icon(Icons.add_circle_outline, size: 28),
                            label: const Text(
                              'Plan Oluştur',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          if (state is HomeLoaded) {
            return Column(
              children: [
                // Ana içerik
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<HomeBloc>()
                          .add(LoadPlanByDate(state.currentDate));
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Tarih seçici (ok butonları ile)
                        TarihSecici(
                          secilenTarih: state.currentDate,
                          onGeriGit: () {
                            final yeniTarih = state.currentDate
                                .subtract(const Duration(days: 1));
                            context
                                .read<HomeBloc>()
                                .add(LoadPlanByDate(yeniTarih));
                          },
                          onIleriGit: () {
                            final yeniTarih =
                                state.currentDate.add(const Duration(days: 1));
                            context
                                .read<HomeBloc>()
                                .add(LoadPlanByDate(yeniTarih));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Haftalık takvim
                        HaftalikTakvim(
                          secilenTarih: state.currentDate,
                          onTarihSecildi: (tarih) {
                            context.read<HomeBloc>().add(LoadPlanByDate(tarih));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Kompakt makro özeti
                        KompaktMakroOzet(
                          mevcutKalori: state.tamamlananKalori,
                          hedefKalori: state.hedefler.gunlukKalori,
                          mevcutProtein: state.tamamlananProtein,
                          hedefProtein: state.hedefler.gunlukProtein,
                          mevcutKarb: state.tamamlananKarb,
                          hedefKarb: state.hedefler.gunlukKarbonhidrat,
                          mevcutYag: state.tamamlananYag,
                          hedefYag: state.hedefler.gunlukYag,
                          plan: state.plan, // 🎯 Tolerans kontrolü için
                        ),

                        const SizedBox(height: 24),

                        // Öğünler başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Günlük Öğünler',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('7 Günlük Plan Oluştur'),
                                        content: const Text(
                                          'Pazartesi\'den Pazar\'a kadar 7 günlük besin planı oluşturulsun mu? '
                                          'Her gün 5 öğün (Kahvaltı, Ara Öğün 1, Öğle, Ara Öğün 2, Akşam) içerecek.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext),
                                            child: const Text('İptal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              context.read<HomeBloc>().add(
                                                    GenerateWeeklyPlan(forceRegenerate: true),
                                                  );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Oluştur'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_month, size: 18),
                                  label: const Text('7 Gün'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    context
                                        .read<HomeBloc>()
                                        .add(RefreshDailyPlan(forceRegenerate: true));
                                  },
                                  tooltip: 'Bugünü Yenile',
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Detaylı öğün kartları
                        ...state.plan.ogunler.map((yemek) {
                          final tamamlandi =
                              state.tamamlananOgunler[yemek.id] ?? false;
                          return DetayliOgunCard(
                            yemek: yemek,
                            tamamlandi: tamamlandi,
                            onYedimPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(ToggleMealCompletion(yemek.id));
                            },
                            onAlternatifPressed: () {
                              // Alternatif yemekler oluştur
                              context.read<HomeBloc>().add(
                                    GenerateAlternativeMeals(
                                      mevcutYemek: yemek,
                                      sayi: 3,
                                    ),
                                  );
                            },
                            onMalzemeAlternatifiPressed: (yemek, malzemeMetni, malzemeIndex) {
                              // Malzeme için alternatif besinler oluştur
                              context.read<HomeBloc>().add(
                                    GenerateIngredientAlternatives(
                                      yemek: yemek,
                                      malzemeMetni: malzemeMetni,
                                      malzemeIndex: malzemeIndex,
                                    ),
                                  );
                            },
                          );
                        }),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Alt navigasyon barı
                AltNavigasyonBar(
                  aktifSekme: _aktifSekme,
                  onSekmeSecildi: (sekme) {
                    setState(() {
                      _aktifSekme = sekme;
                    });
                  },
                ),
              ],
            );
          }

          // 🎯 BAŞLANGİÇ DURUMU: Kullanıcıdan plan oluşturmasını bekle
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Colors.purple.shade200,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Beslenme Planı Oluştur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Günlük beslenme planınızı oluşturmak için\naşağıdaki butona tıklayın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<HomeBloc>().add(LoadHomePage());
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 28),
                          label: const Text(
                            'Plan Oluştur',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AltNavigasyonBar(
                aktifSekme: _aktifSekme,
                onSekmeSecildi: (sekme) {
                  setState(() {
                    _aktifSekme = sekme;
                  });
                },
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  // Helper metodlar - tamamlanan makro hesaplamaları
  double _calculateTamamlananKalori(dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.kalori);
  }

  double _calculateTamamlananProtein(dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.protein);
  }

  double _calculateTamamlananKarb(dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.karbonhidrat);
  }

  double _calculateTamamlananYag(dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.yag);
  }

  Future<void> _createDemoUser() async {
    final demoUser = KullaniciProfili(
      id: 'demo_user',
      ad: 'Ahmet',
      soyad: 'Yılmaz',
      yas: 25,
      cinsiyet: Cinsiyet.erkek,
      boy: 180,
      mevcutKilo: 75,
      hedefKilo: 80,
      hedef: Hedef.kasKazanKiloAl,
      aktiviteSeviyesi: AktiviteSeviyesi.ortaAktif,
      diyetTipi: DiyetTipi.normal,
      manuelAlerjiler: [],
      kayitTarihi: DateTime.now(),
    );

    await HiveService.kullaniciKaydet(demoUser);

    if (mounted) {
      context.read<HomeBloc>().add(LoadHomePage());
    }
  }
}
