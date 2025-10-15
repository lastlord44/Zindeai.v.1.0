import 'package:flutter/material.dart';
import '../../domain/entities/yemek.dart';
import '../../domain/entities/yemek_onay_sistemi.dart';
import '../pages/meal_detail_page.dart';
import 'animated_meal_card.dart'; // Hero tags için

class DetayliOgunCard extends StatelessWidget {
  final Yemek yemek;
  final YemekDurumu yemekDurumu;
  final VoidCallback? onYedimPressed;
  final VoidCallback? onOnayPressed;
  final VoidCallback? onAtlaPressed;
  final VoidCallback? onSifirlaPressed;
  final VoidCallback? onAlternatifPressed;
  final Function(Yemek yemek, String malzemeMetni, int malzemeIndex)? onMalzemeAlternatifiPressed;

  const DetayliOgunCard({
    Key? key,
    required this.yemek,
    required this.yemekDurumu,
    this.onYedimPressed,
    this.onOnayPressed,
    this.onAtlaPressed,
    this.onSifirlaPressed,
    this.onAlternatifPressed,
    this.onMalzemeAlternatifiPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🎭 Hero transition ile sarmalanmış GestureDetector
    return GestureDetector(
      onTap: () {
        // 🎯 Meal detail page'e navigate et
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailPage(yemek: yemek),
          ),
        );
      },
      child: Hero(
        tag: HeroTags.mealCard(yemek.id),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getDurumRengi(),
                width: _getDurumRengi() == Colors.transparent ? 0 : 2,
              ),
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
          // Başlık ve öğün tipi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getOgunRengi().withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getOgunRengi().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      yemek.ogun.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yemek.ogun.ad,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getOgunRengi(),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 🎭 Hero transition için yemek adı
                      Hero(
                        tag: HeroTags.mealTitle(yemek.id),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            yemek.ad,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getDurumRengi(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDurumIcon(),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDurumMetni(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Malzemeler
          _buildMalzemeler(),

          // Makro değerler
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMakroBadge(
                  '🔥',
                  yemek.kalori.toStringAsFixed(0),
                  'kcal',
                  Colors.orange,
                ),
                _buildMakroBadge(
                  '💪',
                  yemek.protein.toStringAsFixed(0),
                  'g P',
                  Colors.red,
                ),
                _buildMakroBadge(
                  '🍚',
                  yemek.karbonhidrat.toStringAsFixed(0),
                  'g K',
                  Colors.amber,
                ),
                _buildMakroBadge(
                  '🥑',
                  yemek.yag.toStringAsFixed(0),
                  'g Y',
                  Colors.green,
                ),
              ],
            ),
          ),

          // Butonlar - 4-State Onay Sistemi
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Ana durum butonları
                if (yemekDurumu == YemekDurumu.bekliyor) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onYedimPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Yedim',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAtlaPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Atla',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (yemekDurumu == YemekDurumu.yedi) ...[
                  // Yendi, onay bekliyor
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Text(
                          '✅ Yediğinizi belirttiniz. Onaylamak için "Onayla" butonuna basın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onOnayPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Onayla & Kilitle',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onSifirlaPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.undo, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Geri Al',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else if (yemekDurumu == YemekDurumu.onaylandi) ...[
                  // Onaylandı ve kilitlendi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'KİLİTLENDİ',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bu öğün onaylandı ve rapor için kaydedildi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (yemekDurumu == YemekDurumu.ataldi) ...[
                  // Atlandı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ATLANDI',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: onSifirlaPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tekrar Dene',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 🍽️ Alternatif yemek butonu - Tüm yemeği değiştir
                if (onAlternatifPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAlternatifPressed,
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: const Text(
                        'Farklı Yemek Seç',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }

  /// Malzemeler bölümünü oluşturan ana widget.
  /// Tarifte gramaj bilgisi varsa onu, yoksa standart malzeme listesini kullanır.
  Widget _buildMalzemeler() {
    final bool hasTarifWithGrams =
        yemek.tarif != null && yemek.tarif!.contains('(') && yemek.tarif!.contains('g)');

    if (hasTarifWithGrams) {
      final malzemeler = _parseMalzemelerFromTarif(yemek.tarif!);
      return _buildMalzemelerListesi(malzemeler);
    } else if (yemek.malzemeler.isNotEmpty) {
      return _buildMalzemelerListesi(yemek.malzemeler);
    } else {
      return const SizedBox.shrink(); // Malzeme yoksa bir şey gösterme
    }
  }

  /// Verilen bir malzeme listesini UI'da gösteren widget.
  Widget _buildMalzemelerListesi(List<String> malzemeler) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Malzemeler:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...malzemeler.asMap().entries.map((entry) {
            final index = entry.key;
            final malzeme = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getOgunRengi(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      malzeme,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (onMalzemeAlternatifiPressed != null)
                    InkWell(
                      onTap: () => onMalzemeAlternatifiPressed!(
                        yemek,
                        malzeme,
                        index,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: _getOgunRengi().withAlpha(180),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMakroBadge(
    String emoji,
    String deger,
    String birim,
    Color renk,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          deger,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: renk,
          ),
        ),
        Text(
          birim,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Tarif field'ından malzemeleri parse et (gram bilgileriyle)
  List<String> _parseMalzemelerFromTarif(String tarif) {
    // "lor peyniri (120 g), kinoa (80 g), roka (60 g)" formatını parse et
    final malzemeler = tarif.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
    return malzemeler;
  }

  Color _getOgunRengi() {
    switch (yemek.ogun) {
      case OgunTipi.kahvalti:
        return Colors.orange;
      case OgunTipi.araOgun1:
        return Colors.blue;
      case OgunTipi.ogle:
        return Colors.red;
      case OgunTipi.araOgun2:
        return Colors.green;
      case OgunTipi.aksam:
        return Colors.purple;
      case OgunTipi.geceAtistirma:
        return Colors.indigo;
      case OgunTipi.cheatMeal:
        return Colors.pink;
    }
  }

  Color _getDurumRengi() {
    switch (yemekDurumu) {
      case YemekDurumu.bekliyor:
        return Colors.transparent;
      case YemekDurumu.yedi:
        return Colors.blue.shade300;
      case YemekDurumu.onaylandi:
        return Colors.green.shade300;
      case YemekDurumu.ataldi:
        return Colors.red.shade300;
    }
  }

  IconData _getDurumIcon() {
    switch (yemekDurumu) {
      case YemekDurumu.bekliyor:
        return Icons.schedule;
      case YemekDurumu.yedi:
        return Icons.check_circle;
      case YemekDurumu.onaylandi:
        return Icons.verified;
      case YemekDurumu.ataldi:
        return Icons.block;
    }
  }

  String _getDurumMetni() {
    switch (yemekDurumu) {
      case YemekDurumu.bekliyor:
        return 'Bekliyor';
      case YemekDurumu.yedi:
        return 'Yedi';
      case YemekDurumu.onaylandi:
        return 'Onaylandı';
      case YemekDurumu.ataldi:
        return 'Atlandı';
    }
  }
}
