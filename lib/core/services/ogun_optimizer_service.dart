// lib/application/services/ogun_optimizer_service.dart

import 'dart:math';
import '../../domain/entities/besin_malzeme.dart';
import '../../domain/entities/yemek.dart'; // ✅ OgunTipi import edildi
import '../../domain/entities/ogun_sablonu.dart';
import '../../domain/usecases/malzeme_tabanli_genetik_algoritma.dart';

class OgunOptimizerService {
  final List<BesinMalzeme> allFoods;
  final List<OgunSablonu> templates;
  final Random rng;

  OgunOptimizerService({required this.allFoods, required this.templates, Random? rng}) : rng = rng ?? Random();

  Future<Ogun> build({
    required OgunTipi tip,
    required HedefMakrolar hedef,
  }) async {
    final sablon = templates.firstWhere((t) => t.ogunTipi == tip);
    final ga = MalzemeTabanliGenetikAlgoritma(
      besinler: allFoods,
      ogunTipi: tip,
      sablon: sablon,
      hedef: hedef,
      rng: rng,
    );
    return ga.optimize();
  }
}
