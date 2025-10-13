
// lib/domain/rules/validators.dart

import '../entities/besin_malzeme.dart';
import '../entities/malzeme_miktar.dart';
import '../entities/ogun_sablonu.dart';
import '../usecases/malzeme_tabanli_genetik_algoritma.dart';

class RuleViolation {
  final String code;
  final String message;
  const RuleViolation(this.code, this.message);
}

class Validators {
  static bool hasSingleCarb(Iterable<MalzemeMiktar> ms) {
    final count = ms.where((m) => m.besin.kategori == BesinKategorisi.karbonhidrat).length;
    return count <= 1;
  }

  static Makrolar calc(Iterable<MalzemeMiktar> ms) {
    double kcal=0,p=0,ch=0,f=0;
    for (final m in ms) { kcal+=m.kalori; p+=m.protein; ch+=m.karbonhidrat; f+=m.yag; }
    return Makrolar(kalori: kcal, protein: p, karbonhidrat: ch, yag: f);
  }

  static double weightedTolerance(Makrolar tgt, Makrolar act) {
    final k=(act.kalori-tgt.kalori).abs()/ (tgt.kalori>0?tgt.kalori:1);
    final p=(act.protein-tgt.protein).abs()/ (tgt.protein>0?tgt.protein:1);
    final c=(act.karbonhidrat-tgt.karbonhidrat).abs()/ (tgt.karbonhidrat>0?tgt.karbonhidrat:1);
    final y=(act.yag-tgt.yag).abs()/ (tgt.yag>0?tgt.yag:1);
    return k*0.30 + p*0.30 + c*0.25 + y*0.15;
  }

  static List<RuleViolation> checkTemplate(OgunSablonu sablon, Iterable<MalzemeMiktar> ms) {
    final v = <RuleViolation>[];
    final total = calc(ms).kalori;
    Map<BesinKategorisi,int> counts = {};
    Map<BesinKategorisi,double> share = {};
    for (final m in ms) {
      counts[m.besin.kategori] = (counts[m.besin.kategori] ?? 0) + 1;
    }
    sablon.kategoriKurallari.forEach((kat, kural) {
      final c = counts[kat] ?? 0;
      if (c < kural.minAdet) v.add(RuleViolation('count_min', 'Kategori ${kat.name} min adet ihlali'));
      if (c > kural.maxAdet) v.add(RuleViolation('count_max', 'Kategori ${kat.name} max adet ihlali'));
      final kcal = ms.where((m) => m.besin.kategori == kat).fold<double>(0.0, (a,b)=>a+b.kalori);
      final s = total>0? kcal/total : 0.0;
      if (s < kural.minOran) v.add(RuleViolation('ratio_min', 'Kategori ${kat.name} min oran ihlali'));
      if (s > kural.maxOran) v.add(RuleViolation('ratio_max', 'Kategori ${kat.name} max oran ihlali'));
      for (final banned in kural.yasakMalzemeler) {
        final hit = ms.any((m)=> m.besin.ad.toLowerCase().contains(banned.toLowerCase()));
        if (hit) v.add(RuleViolation('banned', 'Yasak malzeme: $banned'));
      }
    });
    if (!hasSingleCarb(ms)) v.add(const RuleViolation('single_carb', 'Birden fazla karbonhidrat kaynağı'));
    return v;
  }
}
