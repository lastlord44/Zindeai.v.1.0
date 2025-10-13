
// lib/domain/entities/malzeme_miktar.dart

import 'besin_malzeme.dart';

class MalzemeMiktar {
  final BesinMalzeme besin;
  final double miktarG;

  const MalzemeMiktar(this.besin, this.miktarG);

  double get kalori => (besin.kalori100g * miktarG) / 100.0;
  double get protein => (besin.protein100g * miktarG) / 100.0;
  double get karbonhidrat => (besin.karbonhidrat100g * miktarG) / 100.0;
  double get yag => (besin.yag100g * miktarG) / 100.0;
}
