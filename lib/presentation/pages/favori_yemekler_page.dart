// lib/presentation/pages/favori_yemekler_page.dart

import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../domain/entities/yemek.dart';
import '../widgets/ogun_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state_widget.dart';

/// 🌟 Favori Yemekler Sayfası
class FavoriYemeklerPage extends StatefulWidget {
  const FavoriYemeklerPage({Key? key}) : super(key: key);

  @override
  State<FavoriYemeklerPage> createState() => _FavoriYemeklerPageState();
}

class _FavoriYemeklerPageState extends State<FavoriYemeklerPage> {
  bool _isLoading = true;
  List<Yemek> _favoriYemekler = [];
  Map<OgunTipi, List<Yemek>> _kategoriliFavoriler = {};
  OgunTipi? _secilenKategori;

  @override
  void initState() {
    super.initState();
    _favorileriYukle();
  }

  Future<void> _favorileriYukle() async {
    setState(() => _isLoading = true);

    try {
      final favoriler = await HiveService.favoriYemekleriGetir();
      
      // Kategorilere ayır
      final kategorili = <OgunTipi, List<Yemek>>{};
      for (final yemek in favoriler) {
        if (!kategorili.containsKey(yemek.ogun)) {
          kategorili[yemek.ogun] = [];
        }
        kategorili[yemek.ogun]!.add(yemek);
      }

      setState(() {
        _favoriYemekler = favoriler;
        _kategoriliFavoriler = kategorili;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favoriler yüklenirken hata: $e')),
        );
      }
    }
  }

  Future<void> _favoridenCikar(String yemekId) async {
    try {
      await HiveService.favoridenCikar(yemekId);
      await _favorileriYukle(); // Listeyi yenile
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilerden çıkarıldı'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Yemeklerim'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_favoriYemekler.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Tüm Favorileri Temizle'),
                    content: const Text(
                      'Tüm favori yemekleri silmek istediğinize emin misiniz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await HiveService.tumFavorileriTemizle();
                          await _favorileriYukle();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Tümünü temizle',
            ),
        ],
      ),
      body: _isLoading
          ? LoadingPage()
          : _favoriYemekler.isEmpty
              ? const EmptyStateWidget(
                  type: EmptyStateType.noFavorites,
                  message: 'Henüz favori yemek eklemediniz',
                )
              : Column(
                  children: [
                    // Kategori filtreleri
                    if (_kategoriliFavoriler.length > 1)
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildKategoriChip(null, 'Tümü', Icons.all_inclusive),
                            ..._kategoriliFavoriler.keys.map((kategori) {
                              final yemekSayisi = _kategoriliFavoriler[kategori]!.length;
                              return _buildKategoriChip(
                                kategori,
                                '${kategori.ad} ($yemekSayisi)',
                                _getKategoriIcon(kategori),
                              );
                            }),
                          ],
                        ),
                      ),
                    
                    // Favori yemek listesi
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _favorileriYukle,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtrelenmisYemekler().length,
                          itemBuilder: (context, index) {
                            final yemek = _filtrelenmisYemekler()[index];
                            return OgunCard(
                              yemek: yemek,
                              isFavorite: true,
                              onFavoriTap: () => _favoridenCikar(yemek.id),
                              showDetails: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  List<Yemek> _filtrelenmisYemekler() {
    if (_secilenKategori == null) {
      return _favoriYemekler;
    }
    return _kategoriliFavoriler[_secilenKategori] ?? [];
  }

  Widget _buildKategoriChip(OgunTipi? kategori, String label, IconData icon) {
    final isSelected = _secilenKategori == kategori;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _secilenKategori = selected ? kategori : null;
          });
        },
        selectedColor: Colors.purple.withOpacity(0.3),
      ),
    );
  }

  IconData _getKategoriIcon(OgunTipi kategori) {
    switch (kategori) {
      case OgunTipi.kahvalti:
        return Icons.breakfast_dining;
      case OgunTipi.araOgun1:
        return Icons.apple;
      case OgunTipi.ogle:
        return Icons.lunch_dining;
      case OgunTipi.araOgun2:
        return Icons.coffee;
      case OgunTipi.aksam:
        return Icons.dinner_dining;
      case OgunTipi.geceAtistirma:
        return Icons.nights_stay;
      case OgunTipi.cheatMeal:
        return Icons.cake;
    }
  }
}