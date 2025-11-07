// lib/presentation/bloc/home/home_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/yemek.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Ana sayfayı yükle
class LoadHomePage extends HomeEvent {
  final DateTime? targetDate;

  const LoadHomePage({this.targetDate});

  @override
  List<Object?> get props => [targetDate];
}

/// Günlük planı yenile
class RefreshDailyPlan extends HomeEvent {
  final bool forceRegenerate;

  const RefreshDailyPlan({this.forceRegenerate = false});

  @override
  List<Object?> get props => [forceRegenerate];
}

/// Öğün tamamlandı olarak işaretle
class ToggleMealCompletion extends HomeEvent {
  final String yemekId;

  const ToggleMealCompletion(this.yemekId);

  @override
  List<Object?> get props => [yemekId];
}

/// Öğünü değiştir
class ReplaceMeal extends HomeEvent {
  final String eskiYemekId;
  final OgunTipi ogun;

  const ReplaceMeal({
    required this.eskiYemekId,
    required this.ogun,
  });

  @override
  List<Object?> get props => [eskiYemekId, ogun];
}

/// Tarihe göre plan yükle
class LoadPlanByDate extends HomeEvent {
  final DateTime date;

  const LoadPlanByDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Haftalık plan oluştur (7 günlük)
class GenerateWeeklyPlan extends HomeEvent {
  final DateTime? startDate;
  final bool forceRegenerate;

  const GenerateWeeklyPlan({
    this.startDate,
    this.forceRegenerate = false,
  });

  @override
  List<Object?> get props => [startDate, forceRegenerate];
}

/// Alternatif yemekler oluştur
class GenerateAlternativeMeals extends HomeEvent {
  final Yemek mevcutYemek;
  final int sayi; // Kaç alternatif isteniyor

  const GenerateAlternativeMeals({
    required this.mevcutYemek,
    this.sayi = 3,
  });

  @override
  List<Object?> get props => [mevcutYemek, sayi];
}

/// Yemeği belirli bir yemekle değiştir
class ReplaceMealWith extends HomeEvent {
  final Yemek eskiYemek;
  final Yemek yeniYemek;

  const ReplaceMealWith({
    required this.eskiYemek,
    required this.yeniYemek,
  });

  @override
  List<Object?> get props => [eskiYemek, yeniYemek];
}

/// Malzeme için alternatif besinler oluştur
class GenerateIngredientAlternatives extends HomeEvent {
  final Yemek yemek;
  final String malzemeMetni; // Örn: "10 adet badem"
  final int malzemeIndex; // Yemekteki malzemelerin hangi index'i

  const GenerateIngredientAlternatives({
    required this.yemek,
    required this.malzemeMetni,
    required this.malzemeIndex,
  });

  @override
  List<Object?> get props => [yemek, malzemeMetni, malzemeIndex];
}

/// Malzemeyi alternatifiyle değiştir
class ReplaceIngredientWith extends HomeEvent {
  final Yemek yemek;
  final int malzemeIndex;
  final String yeniMalzemeMetni; // Örn: "13 adet fındık"

  const ReplaceIngredientWith({
    required this.yemek,
    required this.malzemeIndex,
    required this.yeniMalzemeMetni,
  });

  @override
  List<Object?> get props => [yemek, malzemeIndex, yeniMalzemeMetni];
}

/// 🔥 YENİ EVENT: Alternatif seçimini iptal et ve ana sayfaya dön
class CancelAlternativeSelection extends HomeEvent {
  const CancelAlternativeSelection();
}

/// 🔥 YENİ EVENT: Alternatif yemek seçimini iptal et ve ana sayfaya dön
class CancelAlternativeMealSelection extends HomeEvent {
  const CancelAlternativeMealSelection();
}

/// ✅ YENİ ONAY SİSTEMİ EVENT'LERİ
/// Yemeği yedi olarak işaretle (henüz onaylamadı)
class MarkMealAsEaten extends HomeEvent {
  final String yemekId;
  final String? notlar;

  const MarkMealAsEaten({
    required this.yemekId,
    this.notlar,
  });

  @override
  List<Object?> get props => [yemekId, notlar];
}

/// Yemeği onayla (artık değiştirilemesin)
class ConfirmMealEaten extends HomeEvent {
  final String yemekId;
  final String? notlar;

  const ConfirmMealEaten({
    required this.yemekId,
    this.notlar,
  });

  @override
  List<Object?> get props => [yemekId, notlar];
}

/// Yemeği atla
class SkipMeal extends HomeEvent {
  final String yemekId;
  final String? notlar;

  const SkipMeal({
    required this.yemekId,
    this.notlar,
  });

  @override
  List<Object?> get props => [yemekId, notlar];
}

/// Yemek durumunu sıfırla
class ResetMealStatus extends HomeEvent {
  final String yemekId;

  const ResetMealStatus({required this.yemekId});

  @override
  List<Object?> get props => [yemekId];
}

/// 🌟 FAVORİ YENİ EVENT'LERİ
/// Yemeği favorilere ekle/çıkar (toggle)
class ToggleFavoriteMeal extends HomeEvent {
  final String yemekId;

  const ToggleFavoriteMeal(this.yemekId);

  @override
  List<Object?> get props => [yemekId];
}

/// Favori yemekleri yükle
class LoadFavoriteMeals extends HomeEvent {
  const LoadFavoriteMeals();
}
