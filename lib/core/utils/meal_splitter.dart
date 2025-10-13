
// lib/domain/utils/meal_splitter.dart

import '../usecases/malzeme_tabanli_genetik_algoritma.dart';

class MealSplit {
  final double kahvalti, ara1, ogle, ara2, aksam;
  const MealSplit({required this.kahvalti, required this.ara1, required this.ogle, required this.ara2, required this.aksam});
}

HedefMakrolar scale(HedefMakrolar m, double k) => HedefMakrolar(
  kalori: m.kalori * k,
  protein: m.protein * k,
  karbonhidrat: m.karbonhidrat * k,
  yag: m.yag * k,
);

Map<String,HedefMakrolar> splitDaily(HedefMakrolar daily, MealSplit s) {
  return {
    "kahvalti": scale(daily, s.kahvalti),
    "ara1": scale(daily, s.ara1),
    "ogle": scale(daily, s.ogle),
    "ara2": scale(daily, s.ara2),
    "aksam": scale(daily, s.aksam),
  };
}
