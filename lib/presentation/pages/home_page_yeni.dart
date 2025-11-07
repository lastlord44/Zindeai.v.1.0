import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_logger.dart'; // 🔥 KRİTİK: Logger import'u eklendi.
import '../../data/datasources/yemek_hive_data_source.dart';
import '../../domain/usecases/ogun_planlayici.dart';
import '../../domain/usecases/makro_hesapla.dart';
import '../../domain/services/ai_beslenme_servisi.dart'; // 🤖 AI SERVİSİ
import '../../domain/services/malzeme_parser_servisi.dart'; // 🔥 PARSE SERVİSİ
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
import '../widgets/shimmer_loading.dart'; // 🎨 Shimmer loading
import '../widgets/animated_meal_card.dart'; // 🎭 Animations
import '../widgets/empty_state_widget.dart'; // 🎭 Empty states
import 'profil_page.dart';
import 'antrenman_page.dart';
import 'maintenance_page.dart';
import 'ai_chatbot_page.dart';
import 'haftalik_rapor_page.dart';
import 'alisveris_listesi_page.dart';
import '../../domain/entities/yemek_onay_sistemi.dart';

class YeniHomePage extends StatelessWidget {
  const YeniHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // 🔥 KRİTİK DÜZELTME: Bloc oluşturulmadan hemen önce log seviyesini ayarla!
        // Bu, tüm alt servislerin (AI, Diyetisyen vb.) doğru log seviyesiyle çalışmasını garanti eder.
        AppLogger.init(level: LogLevel.debug);
        
        return HomeBloc(
          planlayici: OgunPlanlayici(
            dataSource: YemekHiveDataSource(),
          ),
          makroHesaplama: MakroHesapla(),
          aiServisi: AIBeslenmeServisi(), // 🤖 AI SERVİSİ
        )..add(LoadHomePage()); // ✅ F5 yapınca mevcut planı otomatik yükle
      },
      child: const YeniHomePageView(),
    );
  }
}

class YeniHomePageView extends StatefulWidget {
  const YeniHomePageView({Key? key}) : super(key: key);

  @override
  State<YeniHomePageView> createState() => _YeniHomePageViewState();
}

class _YeniHomePageViewState extends State<YeniHomePageView>
    with TickerProviderStateMixin {
  NavigasyonSekme _aktifSekme = NavigasyonSekme.beslenme;
  bool _isFABExtended = false;

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
            content:
                const Text('Uygulamadan çıkmak istediğinize emin misiniz?'),
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
                onClose: () {
                  // 🔥 FIX: X butonu ile kapatıldığında ana sayfaya geri dön (hiçbir şey sıfırlanmasın)
                  context
                      .read<HomeBloc>()
                      .add(const CancelAlternativeMealSelection());
                },
              );
            }

            // Alternatif malzemeler yüklendiğinde bottom sheet aç
            if (state is AlternativeIngredientsLoaded) {
              // 🔥 FIX: Malzemeyi parse et - miktar ve birim bilgilerini al
              final parsedMalzeme = MalzemeParserServisi.parse(state.orijinalMalzemeMetni);
              
              AlternatifBesinBottomSheet.goster(
                context,
                orijinalBesinAdi: parsedMalzeme?.besinAdi ?? state.orijinalMalzemeMetni,
                orijinalMiktar: parsedMalzeme?.miktar ?? 0,
                orijinalBirim: parsedMalzeme?.birim ?? '',
                alternatifler: state.alternatifBesinler,
                alerjiNedeni: 'Malzeme değişikliği',
                onClose: () {
                  // 🔥 FIX: X butonu ile kapatıldığında ana sayfaya geri dön (hiçbir şey sıfırlanmasın)
                  context
                      .read<HomeBloc>()
                      .add(const CancelAlternativeSelection());
                },
              ).then((secilenAlternatif) {
                if (secilenAlternatif != null) {
                  // Yeni malzeme metnini oluştur
                  final yeniMalzemeMetni =
                      '${secilenAlternatif.miktar.toStringAsFixed(0)} ${secilenAlternatif.birim} ${secilenAlternatif.ad}';

                  context.read<HomeBloc>().add(
                        ReplaceIngredientWith(
                          yemek: state.yemek,
                          malzemeIndex: state.malzemeIndex,
                          yeniMalzemeMetni: yeniMalzemeMetni,
                        ),
                      );
                } else {
                  // 🔥 FIX: Bottom sheet dışarı tıklama/geri tuşu ile kapatıldıysa da ana sayfaya dön
                  context
                      .read<HomeBloc>()
                      .add(const CancelAlternativeSelection());
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
                        // 🔥 CRITICAL FIX: AlternativeIngredientsLoaded için de RefreshDailyPlan kullan
                        context
                            .read<HomeBloc>()
                            .add(RefreshDailyPlan(forceRegenerate: false));
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
                              context
                                  .read<HomeBloc>()
                                  .add(LoadPlanByDate(tarih));
                            },
                          ),

                          const SizedBox(height: 16),

                          // 🛒 HAFTALİK RAPOR VE ALIŞVERİŞ (TAKVİMDEN HEMEN SONRA)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HaftalikRaporPage(
                                          baslangicTarihi: state.currentDate,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.analytics_outlined, size: 20),
                                  label: const Text('Haftalık Rapor'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AlisverisListesiPage(
                                          baslangicTarihi: state.currentDate,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                                  label: const Text('Alışveriş Listesi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Kompakt makro özeti
                          KompaktMakroOzet(
                            mevcutKalori: _calculateTamamlananKalori(
                                state.plan, state.tamamlananOgunler),
                            hedefKalori: state.hedefler.gunlukKalori,
                            mevcutProtein: _calculateTamamlananProtein(
                                state.plan, state.tamamlananOgunler),
                            hedefProtein: state.hedefler.gunlukProtein,
                            mevcutKarb: _calculateTamamlananKarb(
                                state.plan, state.tamamlananOgunler),
                            hedefKarb: state.hedefler.gunlukKarbonhidrat,
                            mevcutYag: _calculateTamamlananYag(
                                state.plan, state.tamamlananOgunler),
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
                                          title: const Text(
                                              '7 Günlük Plan Oluştur'),
                                          content: const Text(
                                            'Pazartesi\'den Pazar\'a kadar 7 günlük besin planı oluşturulsun mu? '
                                            'Her gün 5 öğün (Kahvaltı, Ara Öğün 1, Öğle, Ara Öğün 2, Akşam) içerecek.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('İptal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                context.read<HomeBloc>().add(
                                                      GenerateWeeklyPlan(
                                                          forceRegenerate:
                                                              true),
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
                                    icon: const Icon(Icons.calendar_month,
                                        size: 18),
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
                                      context.read<HomeBloc>().add(
                                          RefreshDailyPlan(
                                              forceRegenerate: true));
                                    },
                                    tooltip: 'Bugünü Yenile',
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Detaylı öğün kartları - ✅ YENİ ONAY SİSTEMİ
                          ...state.plan.ogunler.asMap().entries.map((entry) {
                            final index = entry.key;
                            final yemek = entry.value;
                            
                            // ✅ YENİ ONAY SİSTEMİ: gunlukOnayDurumu'ndan durumu al
                            final yemekDurumu = state.gunlukOnayDurumu
                                ?.yemekDurumu(yemek.id.toString())
                                ?.durum ?? YemekDurumu.bekliyor;
                            return DetayliOgunCard(
                              yemek: yemek,
                              yemekDurumu: yemekDurumu,
                              onYedimPressed: () {
                                // Onay dialog'u göster
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Yemek Onayı'),
                                      content: Text(
                                          '${yemek.ad} yemeğini yediğinizi onaylıyor musunuz?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('İptal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            context.read<HomeBloc>().add(
                                                MarkMealAsEaten(
                                                    yemekId: yemek.id.toString()));
                                          },
                                          child: const Text('Evet, Yedim'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onSifirlaPressed: () {
                                context
                                    .read<HomeBloc>()
                                    .add(ResetMealStatus(yemekId: yemek.id.toString()));
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
                              onMalzemeAlternatifiPressed:
                                  (yemek, malzemeMetni, malzemeIndex) {
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
                          // 🔄 Yuvarlak loading indicator veya progress bar
                          if (state.progress != null) ...[
                            // 📊 Progress bar (haftalık plan için)
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: CircularProgressIndicator(
                                      value: state.progress,
                                      strokeWidth: 12,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                                    ),
                                  ),
                                  Text(
                                    '%${(state.progress! * 100).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Belirsiz loading (progress yok)
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 6,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // 📝 Loading mesajı
                          if (state.message != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                state.message!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state.progress != null)
                              Text(
                                '${(state.progress! * 100).toInt()}% tamamlandı',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            else
                              Text(
                                'Lütfen bekleyin...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
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
              // 🎭 Professional empty state
              return Column(
                children: [
                  Expanded(
                    child: EmptyStateWidget(
                      type: EmptyStateType.error,
                      message: state.message,
                      onActionPressed: () {
                        context.read<HomeBloc>().add(LoadHomePage());
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

            if (state is HomeLoaded) {
              return Column(
                children: [
                  // Ana içerik
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        // FAB extend/collapse on scroll
                        if (scrollInfo is ScrollUpdateNotification) {
                          setState(() {
                            _isFABExtended = scrollInfo.metrics.pixels < 100;
                          });
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // 🔥 CRITICAL FIX: Doğru event'i tetikle - RefreshDailyPlan değil LoadPlanByDate
                          context
                              .read<HomeBloc>()
                              .add(RefreshDailyPlan(forceRegenerate: false));
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
                                context
                                    .read<HomeBloc>()
                                    .add(LoadPlanByDate(tarih));
                              },
                            ),

                            const SizedBox(height: 16),

                            // 🛒 HAFTALİK RAPOR VE ALIŞVERİŞ LİSTESİ (TAKVİMDEN HEMEN SONRA)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HaftalikRaporPage(
                                            baslangicTarihi: state.currentDate,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.analytics_outlined,
                                        size: 20),
                                    label: const Text('Haftalık Rapor'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AlisverisListesiPage(
                                            baslangicTarihi: state.currentDate,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 20),
                                    label: const Text('Alışveriş Listesi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
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
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                            title: const Text(
                                                '7 Günlük Plan Oluştur'),
                                            content: const Text(
                                              'Pazartesi\'den Pazar\'a kadar 7 günlük besin planı oluşturulsun mu? '
                                              'Her gün 5 öğün (Kahvaltı, Ara Öğün 1, Öğle, Ara Öğün 2, Akşam) içerecek.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext),
                                                child: const Text('İptal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                  context.read<HomeBloc>().add(
                                                        GenerateWeeklyPlan(
                                                            forceRegenerate:
                                                                true),
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
                                      icon: const Icon(Icons.calendar_month,
                                          size: 18),
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
                                        context.read<HomeBloc>().add(
                                            RefreshDailyPlan(
                                                forceRegenerate: true));
                                      },
                                      tooltip: 'Bugünü Yenile',
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Detaylı öğün kartları - 🎭 Animated
                            ...state.plan.ogunler.asMap().entries.map((entry) {
                              final index = entry.key;
                              final yemek = entry.value;
                              
                              // ✅ YENİ ONAY SİSTEMİ: gunlukOnayDurumu'ndan durumu al
                              final yemekDurumu = state.gunlukOnayDurumu
                                  ?.yemekDurumu(yemek.id.toString())
                                  ?.durum ?? YemekDurumu.bekliyor;
                              return AnimatedMealCard(
                                index: index,
                                child: DetayliOgunCard(
                                  yemek: yemek,
                                  yemekDurumu: yemekDurumu,
                                  onYedimPressed: () {
                                    // ✅ YENİ SİSTEM: Onay dialog'u göster
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text('Yemek Onayı'),
                                          content: Text(
                                              '${yemek.ad} yemeğini yediğinizi onaylıyor musunuz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                              },
                                              child: const Text('İptal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                                context.read<HomeBloc>().add(
                                                    MarkMealAsEaten(
                                                        yemekId: yemek.id.toString()));
                                              },
                                              child: const Text('Evet, Yedim'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onYemedimPressed: () {
                                    // ✅ YENİ SİSTEM: Yemedim dialog'u göster
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text('Yemek Atlama'),
                                          content: Text(
                                              '${yemek.ad} yemeğini yemedim olarak işaretlemek istiyor musunuz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                              },
                                              child: const Text('İptal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                                context.read<HomeBloc>().add(
                                                    SkipMeal(
                                                        yemekId: yemek.id.toString()));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: const Text('Evet, Yemedim'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onOnayPressed: () {
                                    // ✅ YENİ SİSTEM: Onayla ve kilitle
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text('🔒 Yemek Onaylama'),
                                          content: Text(
                                              '${yemek.ad} yemeğini onaylıyor musunuz?\n\nOnaylandıktan sonra değiştirilemez ve rapor için kaydedilir.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                              },
                                              child: const Text('İptal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                                context.read<HomeBloc>().add(
                                                    ConfirmMealEaten(
                                                        yemekId: yemek.id.toString()));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                              ),
                                              child: const Text('Onayla & Kilitle'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onSifirlaPressed: () {
                                    // ✅ YENİ SİSTEM: Sıfırla
                                    context.read<HomeBloc>().add(
                                        ResetMealStatus(yemekId: yemek.id.toString()));
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
                                  onMalzemeAlternatifiPressed:
                                      (yemek, malzemeMetni, malzemeIndex) {
                                    // Malzeme için alternatif besinler oluştur
                                    context.read<HomeBloc>().add(
                                          GenerateIngredientAlternatives(
                                            yemek: yemek,
                                            malzemeMetni: malzemeMetni,
                                            malzemeIndex: malzemeIndex,
                                          ),
                                        );
                                  },
                                ),
                              );
                            }),

                            const SizedBox(height: 100),
                          ],
                        ),
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

            // 🎯 BAŞLANGİÇ DURUMU: Professional empty state
            return Column(
              children: [
                Expanded(
                  child: EmptyStateWidget(
                    type: EmptyStateType.noPlan,
                    onActionPressed: () {
                      context.read<HomeBloc>().add(LoadHomePage());
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
          },
        ),
      ),
    );
  }

  // Helper metodlar - tamamlanan makro hesaplamaları
  double _calculateTamamlananKalori(
      dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.kalori);
  }

  double _calculateTamamlananProtein(
      dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.protein);
  }

  double _calculateTamamlananKarb(
      dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.karbonhidrat);
  }

  double _calculateTamamlananYag(
      dynamic plan, Map<String, bool> tamamlananOgunler) {
    return plan.ogunler
        .where((y) => tamamlananOgunler[y.id] == true)
        .fold(0.0, (sum, y) => sum + y.yag);
  }
}
