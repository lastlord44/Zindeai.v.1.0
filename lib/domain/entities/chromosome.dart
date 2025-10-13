
// lib/domain/entities/chromosome.dart

import 'malzeme_miktar.dart';

class Chromosome {
  final List<MalzemeMiktar> malzemeler;

  Chromosome(this.malzemeler);

  Chromosome copyWith({List<MalzemeMiktar>? malzemeler}) =>
      Chromosome(malzemeler ?? this.malzemeler);

  static Chromosome empty() => Chromosome([]);
}
