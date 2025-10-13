// lib/domain/usecases/malzeme_tabanli_genetik_algoritma.dart
// GA v2.1: Tournament selection, crossover, mutation
// + OgunSablonu kural entegrasyonu (min/max adet, oran limitleri, yasak/zorunlu)
// + Tek karbonhidrat kuralı (global sert ceza)

import 'dart:math';
import '../entities/besin_malzeme.dart';
import '../entities/yemek.dart'; // ✅ OgunTipi import edildi
import '../entities/malzeme_miktar.dart';
import '../entities/chromosome.dart';
import '../entities/ogun_sablonu.dart';
import 'package:collection/collection.dart';

class Makrolar {
  final double kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;

  const Makrolar({
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
  });

  Makrolar operator *(double k) => Makrolar(
        kalori: kalori * k,
        protein: protein * k,
        karbonhidrat: karbonhidrat * k,
        yag: yag * k,
      );
}

class HedefMakrolar extends Makrolar {
  const HedefMakrolar({
    required super.kalori,
    required super.protein,
    required super.karbonhidrat,
    required super.yag,
  });
}

class Ogun {
  final OgunTipi tip;
  final List<MalzemeMiktar> malzemeler;
  final Makrolar gercekMakrolar;
  final Makrolar hedefMakrolar;
  final double toleransSapma; // 0..1

  const Ogun({
    required this.tip,
    required this.malzemeler,
    required this.gercekMakrolar,
    required this.hedefMakrolar,
    required this.toleransSapma,
  });

  String toReadableString() {
    final b = StringBuffer();
    b.writeln(tip.name.toUpperCase() + ':');
    for (final m in malzemeler) {
      b.writeln('- ${m.miktarG.toInt()}g ${m.besin.ad}');
    }
    b.writeln('\nMAKROLAR:');
    b.writeln(
        'Kalori: ${gercekMakrolar.kalori.toStringAsFixed(0)} / ${hedefMakrolar.kalori.toStringAsFixed(0)} kcal');
    b.writeln(
        'Protein: ${gercekMakrolar.protein.toStringAsFixed(0)} / ${hedefMakrolar.protein.toStringAsFixed(0)} g');
    b.writeln(
        'Karb: ${gercekMakrolar.karbonhidrat.toStringAsFixed(0)} / ${hedefMakrolar.karbonhidrat.toStringAsFixed(0)} g');
    b.writeln(
        'Yağ: ${gercekMakrolar.yag.toStringAsFixed(0)} / ${hedefMakrolar.yag.toStringAsFixed(0)} g');
    b.writeln('\nTOLERANS SAPMA: %${(toleransSapma * 100).toStringAsFixed(1)}');
    return b.toString();
  }
}

class MalzemeTabanliGenetikAlgoritma {
  final List<BesinMalzeme> besinler;
  final OgunTipi ogunTipi;
  final OgunSablonu sablon;
  final HedefMakrolar hedef;
  final Random _rng;

  static const int populationSize = 40; // PERFORMANS: 150'den 40'a düşürüldü
  static const int maxGenerations = 80; // PERFORMANS: 500'den 80'e düşürüldü
  static const double mutationRate = 0.20; // Daha agresif mutasyon
  static const double crossoverRate = 0.75;
  static const double toleransHedef = 0.05; // %8'den %5'e - ULTRA STRICT! Kullanıcı isteği

  // Kategori bazlı porsiyon limitleri - ABSÜRT MİKTARLARI ÖNLEMEK İÇİN
  static const Map<BesinKategorisi, List<double>> kategoriPorsiyonlari = {
    BesinKategorisi.protein: [
      30,
      50,
      75,
      100,
      120,
      150
    ], // Max 150g et/tavuk/balık
    BesinKategorisi.karbonhidrat: [
      50,
      75,
      100,
      125,
      150,
      200
    ], // Max 200g pirinç/makarna
    BesinKategorisi.sebze: [50, 75, 100, 125, 150, 200], // Max 200g sebze
    BesinKategorisi.meyve: [50, 75, 100, 150, 200], // Max 200g meyve
    BesinKategorisi.sut: [100, 150, 200, 250], // Max 250ml süt/yoğurt
    BesinKategorisi.yag: [5, 10, 15, 20, 25, 30], // Max 30g yağ
  };

  // Özel malzeme limitleri (isim bazlı)
  static double _getMalzemePorsiyon(BesinMalzeme besin, Random rng) {
    final adLower = besin.ad.toLowerCase();

    // Protein tozu - MAX 40G! (50g absürt)
    if (adLower.contains('whey') ||
        adLower.contains('protein tozu') ||
        adLower.contains('tozu') && adLower.contains('protein')) {
      const porsiyonlar = [20.0, 25.0, 30.0, 35.0, 40.0];
      return porsiyonlar[rng.nextInt(porsiyonlar.length)];
    }

    // Yumurta - MAX 3 ADET (150g absürt, 2-3 yumurta ideal)
    if (adLower.contains('yumurta') && !adLower.contains('tozu')) {
      const porsiyonlar = [50.0, 100.0, 150.0]; // 1, 2, veya 3 yumurta (50g/adet)
      return porsiyonlar[rng.nextInt(porsiyonlar.length)];
    }

    // Peynir - MAX 100G
    if (adLower.contains('peynir') ||
        adLower.contains('lor') ||
        adLower.contains('çökelek')) {
      const porsiyonlar = [30.0, 50.0, 75.0, 100.0];
      return porsiyonlar[rng.nextInt(porsiyonlar.length)];
    }

    // Zeytinyağı/sıvı yağlar - MAX 20G
    if (adLower.contains('zeytinyağ') ||
        adLower.contains('sıvı yağ') ||
        adLower.contains('ayçiçek yağ')) {
      const porsiyonlar = [5.0, 10.0, 15.0, 20.0];
      return porsiyonlar[rng.nextInt(porsiyonlar.length)];
    }

    // Kategori bazlı varsayılan
    final porsiyonlar =
        kategoriPorsiyonlari[besin.kategori] ?? [50, 75, 100, 125];
    return porsiyonlar[rng.nextInt(porsiyonlar.length)];
  }

  MalzemeTabanliGenetikAlgoritma({
    required this.besinler,
    required this.ogunTipi,
    required this.sablon,
    required this.hedef,
    Random? rng,
  }) : _rng = rng ?? Random();

  Future<Ogun> optimize() async {
    final uygunHavuz =
        besinler.where((b) => b.uygunOgunler.contains(ogunTipi)).toList();
    if (uygunHavuz.isEmpty) {
      throw StateError('Uygun besin bulunamadı: $ogunTipi');
    }

    var population =
        List.generate(populationSize, (_) => _randomChromosome(uygunHavuz));

    List<double> fitnessScores = [];
    Chromosome? bestEver;
    double bestEverFitness = double.infinity;
    
    for (int gen = 0; gen < maxGenerations; gen++) {
      fitnessScores = population.map(_calculateFitness).toList();
      final bestFitness = fitnessScores.min;
      final bestIdx = fitnessScores.indexOf(bestFitness);
      
      // En iyi çözümü kaydet
      if (bestFitness < bestEverFitness) {
        bestEverFitness = bestFitness;
        bestEver = population[bestIdx];
      }
      
      if (bestFitness <= toleransHedef) {
        return _toOgun(population[bestIdx]);
      }

      final selected = _tournamentSelection(population, fitnessScores);

      final offspring = <Chromosome>[];
      for (int i = 0; i < selected.length; i += 2) {
        final p1 = selected[i];
        final p2 = selected[(i + 1) % selected.length];
        if (_rng.nextDouble() < crossoverRate) {
          offspring.addAll(_onePointCrossover(p1, p2));
        } else {
          offspring
            ..add(p1)
            ..add(p2);
        }
      }

      final mutated = offspring.map(_mutate).toList();

      // elitizm
      final eliteIdx = fitnessScores.indexOf(fitnessScores.min);
      final elite = population[eliteIdx];
      population = mutated;
      population[_rng.nextInt(population.length)] = elite;
    }

    // En iyi bulduğumuzu döndür (tolerans aşılsa bile)
    return _toOgun(bestEver ?? population[fitnessScores.indexOf(fitnessScores.min)]);
  }

  Chromosome _randomChromosome(List<BesinMalzeme> havuz) {
    final adet = 3 + _rng.nextInt(4); // 3–6
    final chosen = <MalzemeMiktar>[];
    final used = <String>{};
    final usedNames = <String>{}; // İsim bazlı kontrol ekledik!
    
    for (int i = 0; i < adet; i++) {
      final b = havuz[_rng.nextInt(havuz.length)];
      
      // TEKRAR KONTROLÜ: Hem ID hem de isim bazlı!
      final baseName = b.ad.toLowerCase()
          .replaceAll('(yerli)', '')
          .replaceAll('(organik)', '')
          .replaceAll('(düşük yağ)', '')
          .replaceAll('(tam)', '')
          .replaceAll('v2', '')
          .trim();
      
      if (used.contains(b.id) || usedNames.contains(baseName)) continue;
      
      used.add(b.id);
      usedNames.add(baseName);
      chosen.add(MalzemeMiktar(b, _getMalzemePorsiyon(b, _rng)));
    }
    return Chromosome(chosen);
  }

  Makrolar _calcMacros(Chromosome c) {
    double kcal = 0, p = 0, ch = 0, f = 0;
    for (final mm in c.malzemeler) {
      kcal += mm.kalori;
      p += mm.protein;
      ch += mm.karbonhidrat;
      f += mm.yag;
    }
    return Makrolar(kalori: kcal, protein: p, karbonhidrat: ch, yag: f);
  }

  double _categoryCalorieShare(Chromosome c, BesinKategorisi kat) {
    final total = _calcMacros(c).kalori;
    if (total <= 0) return 0.0;
    double catKcal = 0.0;
    for (final mm in c.malzemeler) {
      if (mm.besin.kategori == kat) {
        catKcal += mm.kalori;
      }
    }
    return catKcal / total;
  }

  double _calculateFitness(Chromosome c) {
    final m = _calcMacros(c);
    final kSap =
        (m.kalori - hedef.kalori).abs() / (hedef.kalori > 0 ? hedef.kalori : 1);
    final pSap = (m.protein - hedef.protein).abs() /
        (hedef.protein > 0 ? hedef.protein : 1);
    final cSap = (m.karbonhidrat - hedef.karbonhidrat).abs() /
        (hedef.karbonhidrat > 0 ? hedef.karbonhidrat : 1);
    final ySap = (m.yag - hedef.yag).abs() / (hedef.yag > 0 ? hedef.yag : 1);
    
    // TÜM MAKROLARA EŞIT AĞIRLIK! Yağ artık görmezden gelinmiyor
    final weighted = kSap * 0.25 + pSap * 0.25 + cSap * 0.25 + ySap * 0.25;

    final rulePenalty = _calculatePenalty(c);
    return weighted + (rulePenalty * 0.2); // Penalty'i daha da düşürdük - makro odaklı
  }

  double _calculatePenalty(Chromosome c) {
    double penalty = 0.0;

    // 0) Tek karbonhidrat kaynağı — yumuşatıldı
    final carbCount = c.malzemeler
        .where((m) => m.besin.kategori == BesinKategorisi.karbonhidrat)
        .length;
    if (carbCount > 1) penalty += 3.0; // 10'dan 3'e düşürüldü

    // 1) Öğün uygunluğu — yumuşatıldı
    for (final m in c.malzemeler) {
      if (!m.besin.uygunOgunler.contains(ogunTipi))
        penalty += 2.0; // 5'ten 2'ye düşürüldü
    }

    // 2) Sablon kategori adet/min-max ve oran aralıkları
    double totalKcal = _calcMacros(c).kalori;
    if (totalKcal <= 0) totalKcal = 1.0;

    sablon.kategoriKurallari.forEach((kat, kural) {
      final count = c.malzemeler.where((mm) => mm.besin.kategori == kat).length;
      if (count < kural.minAdet) penalty += (kural.minAdet - count) * 1.5;
      if (count > kural.maxAdet) penalty += (count - kural.maxAdet) * 1.5;

      final share = _categoryCalorieShare(c, kat);
      if (share < kural.minOran) penalty += (kural.minOran - share) * 5.0;
      if (share > kural.maxOran) penalty += (share - kural.maxOran) * 5.0;

      // zorunlu/yasak isimler
      for (final y in kural.yasakMalzemeler) {
        final hit = c.malzemeler
            .any((mm) => mm.besin.ad.toLowerCase().contains(y.toLowerCase()));
        if (hit) penalty += 8.0;
      }
      for (final z in kural.zorunluMalzemeler) {
        final has = c.malzemeler
            .any((mm) => mm.besin.ad.toLowerCase().contains(z.toLowerCase()));
        if (!has) penalty += 4.0;
      }
    });

    // 3) porsiyon sınırları ve öğe adedi
    for (final m in c.malzemeler) {
      if (m.miktarG > 300) penalty += 2.0;
      if (m.miktarG < 30) penalty += 1.0;
    }
    if (c.malzemeler.length < 2 || c.malzemeler.length > 6) penalty += 2.0;

    return penalty;
  }

  List<Chromosome> _tournamentSelection(
      List<Chromosome> pop, List<double> fit) {
    final selected = <Chromosome>[];
    const k = 3;
    for (int i = 0; i < pop.length; i++) {
      final a = _rng.nextInt(pop.length);
      final b = _rng.nextInt(pop.length);
      final cIdx = _rng.nextInt(pop.length);
      final bestIdx = [a, b, cIdx].reduce((x, y) => fit[x] < fit[y] ? x : y);
      selected.add(pop[bestIdx]);
    }
    return selected;
  }

  List<Chromosome> _onePointCrossover(Chromosome p1, Chromosome p2) {
    if (p1.malzemeler.isEmpty || p2.malzemeler.isEmpty) return [p1, p2];
    final cut1 = _rng.nextInt(p1.malzemeler.length);
    final cut2 = _rng.nextInt(p2.malzemeler.length);
    final child1 = [
      ...p1.malzemeler.take(cut1),
      ...p2.malzemeler.skip(cut2),
    ];
    final child2 = [
      ...p2.malzemeler.take(cut2),
      ...p1.malzemeler.skip(cut1),
    ];

    List<MalzemeMiktar> dedup(List<MalzemeMiktar> list) {
      final map = <String, MalzemeMiktar>{};
      for (final m in list) {
        map[m.besin.id] = m;
      }
      return map.values.toList();
    }

    return [Chromosome(dedup(child1)), Chromosome(dedup(child2))];
  }

  Chromosome _mutate(Chromosome c) {
    final list = List<MalzemeMiktar>.from(c.malzemeler);
    for (int i = 0; i < list.length; i++) {
      if (_rng.nextDouble() < mutationRate) {
        final mode = _rng.nextInt(3);
        if (mode == 0) {
          final current = list[i];
          final newPortion = _getMalzemePorsiyon(current.besin, _rng);
          list[i] = MalzemeMiktar(current.besin, newPortion);
        } else if (mode == 1) {
          // TEKRAR ÖNLEME: Yeni malzeme seçerken mevcut isimleri kontrol et
          final sameMeal =
              besinler.where((b) => b.uygunOgunler.contains(ogunTipi)).toList();
          
          // Mevcut malzeme isimlerini al
          final usedNames = <String>{};
          for (final m in list) {
            final baseName = m.besin.ad.toLowerCase()
                .replaceAll('(yerli)', '')
                .replaceAll('(organik)', '')
                .replaceAll('(düşük yağ)', '')
                .replaceAll('(tam)', '')
                .replaceAll('v2', '')
                .trim();
            usedNames.add(baseName);
          }
          
          // Tekrar olmayan bir malzeme bul
          BesinMalzeme? candidate;
          for (int attempt = 0; attempt < 10; attempt++) {
            final temp = sameMeal[_rng.nextInt(sameMeal.length)];
            final tempName = temp.ad.toLowerCase()
                .replaceAll('(yerli)', '')
                .replaceAll('(organik)', '')
                .replaceAll('(düşük yağ)', '')
                .replaceAll('(tam)', '')
                .replaceAll('v2', '')
                .trim();
            if (!usedNames.contains(tempName)) {
              candidate = temp;
              break;
            }
          }
          
          if (candidate != null) {
            list[i] = MalzemeMiktar(candidate, _getMalzemePorsiyon(candidate, _rng));
          }
        } else {
          if (_rng.nextBool() && list.length < 6) {
            final pool = besinler
                .where((b) => b.uygunOgunler.contains(ogunTipi))
                .toList();
            
            // TEKRAR ÖNLEME: Yeni ekleme yaparken de kontrol et
            final usedNames = <String>{};
            for (final m in list) {
              final baseName = m.besin.ad.toLowerCase()
                  .replaceAll('(yerli)', '')
                  .replaceAll('(organik)', '')
                  .replaceAll('(düşük yağ)', '')
                  .replaceAll('(tam)', '')
                  .replaceAll('v2', '')
                  .trim();
              usedNames.add(baseName);
            }
            
            BesinMalzeme? addCandidate;
            for (int attempt = 0; attempt < 10; attempt++) {
              final temp = pool[_rng.nextInt(pool.length)];
              final tempName = temp.ad.toLowerCase()
                  .replaceAll('(yerli)', '')
                  .replaceAll('(organik)', '')
                  .replaceAll('(düşük yağ)', '')
                  .replaceAll('(tam)', '')
                  .replaceAll('v2', '')
                  .trim();
              if (!usedNames.contains(tempName)) {
                addCandidate = temp;
                break;
              }
            }
            
            if (addCandidate != null) {
              list.add(MalzemeMiktar(addCandidate, _getMalzemePorsiyon(addCandidate, _rng)));
            }
          } else if (list.length > 2) {
            list.removeAt(_rng.nextInt(list.length));
          }
        }
      }
    }
    return Chromosome(list);
  }

  Ogun _toOgun(Chromosome c) {
    final m = _calcMacros(c);
    final kSap =
        (m.kalori - hedef.kalori).abs() / (hedef.kalori > 0 ? hedef.kalori : 1);
    final pSap = (m.protein - hedef.protein).abs() /
        (hedef.protein > 0 ? hedef.protein : 1);
    final cSap = (m.karbonhidrat - hedef.karbonhidrat).abs() /
        (hedef.karbonhidrat > 0 ? hedef.karbonhidrat : 1);
    final ySap = (m.yag - hedef.yag).abs() / (hedef.yag > 0 ? hedef.yag : 1);
    // TÜM MAKROLARA EŞIT AĞIRLIK
    final weighted = kSap * 0.25 + pSap * 0.25 + cSap * 0.25 + ySap * 0.25;
    return Ogun(
      tip: ogunTipi,
      malzemeler: c.malzemeler,
      gercekMakrolar: m,
      hedefMakrolar: hedef,
      toleransSapma: weighted.clamp(0.0, 1.0),
    );
  }
}
