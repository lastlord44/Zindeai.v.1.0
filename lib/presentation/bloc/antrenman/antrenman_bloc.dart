// ============================================================================
// ANTRENMAN BLOC - FAZ 9
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/antrenman.dart';
import '../../../domain/entities/egzersiz.dart';
import '../../../data/datasources/antrenman_local_data_source.dart';
import '../../../data/local/hive_service.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class AntrenmanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Tüm antrenman programlarını yükle
class LoadAntrenmanProgramlari extends AntrenmanEvent {}

/// Zorluk seviyesine göre programları filtrele
class FilterByZorluk extends AntrenmanEvent {
  final Zorluk zorluk;

  FilterByZorluk(this.zorluk);

  @override
  List<Object?> get props => [zorluk];
}

/// Kategori'ye göre egzersizleri filtrele
class FilterByKategori extends AntrenmanEvent {
  final EgzersizKategorisi kategori;

  FilterByKategori(this.kategori);

  @override
  List<Object?> get props => [kategori];
}

/// Antrenman programını başlat
class StartAntrenman extends AntrenmanEvent {
  final AntrenmanProgrami program;

  StartAntrenman(this.program);

  @override
  List<Object?> get props => [program];
}

/// Egzersizi tamamla
class CompleteEgzersiz extends AntrenmanEvent {
  final String egzersizId;

  CompleteEgzersiz(this.egzersizId);

  @override
  List<Object?> get props => [egzersizId];
}

/// Antrenmanı tamamla
class CompleteAntrenman extends AntrenmanEvent {
  final int gercekSure; // Saniye
  final int gercekKalori;
  final double? rating; // 1-5 arası
  final String? yorum;

  CompleteAntrenman({
    required this.gercekSure,
    required this.gercekKalori,
    this.rating,
    this.yorum,
  });

  @override
  List<Object?> get props => [gercekSure, gercekKalori, rating, yorum];
}

/// Antrenman geçmişini yükle
class LoadAntrenmanGecmisi extends AntrenmanEvent {}

// ============================================================================
// STATES
// ============================================================================

abstract class AntrenmanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AntrenmanInitial extends AntrenmanState {}

class AntrenmanLoading extends AntrenmanState {}

/// Programlar yüklendi
class AntrenmanProgramlariLoaded extends AntrenmanState {
  final List<AntrenmanProgrami> programlar;
  final Zorluk? filtreZorluk;

  AntrenmanProgramlariLoaded({
    required this.programlar,
    this.filtreZorluk,
  });

  @override
  List<Object?> get props => [programlar, filtreZorluk];
}

/// Egzersizler yüklendi (kategori bazlı)
class EgzersizlerLoaded extends AntrenmanState {
  final List<Egzersiz> egzersizler;
  final EgzersizKategorisi kategori;

  EgzersizlerLoaded({
    required this.egzersizler,
    required this.kategori,
  });

  @override
  List<Object?> get props => [egzersizler, kategori];
}

/// Antrenman aktif
class AntrenmanActive extends AntrenmanState {
  final AntrenmanProgrami program;
  final List<String> tamamlananEgzersizler;
  final DateTime baslangicZamani;

  AntrenmanActive({
    required this.program,
    required this.tamamlananEgzersizler,
    required this.baslangicZamani,
  });

  /// İlerleme yüzdesi
  double get ilerlemYuzdesi {
    if (program.egzersizSayisi == 0) return 0;
    return (tamamlananEgzersizler.length / program.egzersizSayisi) * 100;
  }

  /// Geçen süre (saniye)
  int get gecenSure {
    return DateTime.now().difference(baslangicZamani).inSeconds;
  }

  /// Kalan egzersiz sayısı
  int get kalanEgzersiz {
    return program.egzersizSayisi - tamamlananEgzersizler.length;
  }

  @override
  List<Object?> get props => [program, tamamlananEgzersizler, baslangicZamani];

  AntrenmanActive copyWith({
    AntrenmanProgrami? program,
    List<String>? tamamlananEgzersizler,
    DateTime? baslangicZamani,
  }) {
    return AntrenmanActive(
      program: program ?? this.program,
      tamamlananEgzersizler:
          tamamlananEgzersizler ?? this.tamamlananEgzersizler,
      baslangicZamani: baslangicZamani ?? this.baslangicZamani,
    );
  }
}

/// Antrenman geçmişi yüklendi
class AntrenmanGecmisiLoaded extends AntrenmanState {
  final List<TamamlananAntrenman> gecmis;

  AntrenmanGecmisiLoaded(this.gecmis);

  /// Son 7 günde tamamlanan antrenman sayısı
  int get son7GunAntrenmanSayisi {
    final yediGunOnce = DateTime.now().subtract(const Duration(days: 7));
    return gecmis
        .where((a) => a.tamamlanmaTarihi.isAfter(yediGunOnce))
        .length;
  }

  /// Toplam yakılan kalori (son 30 gün)
  int get toplamKalori {
    final otuzGunOnce = DateTime.now().subtract(const Duration(days: 30));
    return gecmis
        .where((a) => a.tamamlanmaTarihi.isAfter(otuzGunOnce))
        .fold(0, (sum, a) => sum + a.yakilanKalori);
  }

  @override
  List<Object?> get props => [gecmis];
}

class AntrenmanError extends AntrenmanState {
  final String mesaj;

  AntrenmanError(this.mesaj);

  @override
  List<Object?> get props => [mesaj];
}

// ============================================================================
// BLOC
// ============================================================================

class AntrenmanBloc extends Bloc<AntrenmanEvent, AntrenmanState> {
  final AntrenmanLocalDataSource dataSource;

  AntrenmanBloc({required this.dataSource}) : super(AntrenmanInitial()) {
    on<LoadAntrenmanProgramlari>(_onLoadProgramlari);
    on<FilterByZorluk>(_onFilterByZorluk);
    on<FilterByKategori>(_onFilterByKategori);
    on<StartAntrenman>(_onStartAntrenman);
    on<CompleteEgzersiz>(_onCompleteEgzersiz);
    on<CompleteAntrenman>(_onCompleteAntrenman);
    on<LoadAntrenmanGecmisi>(_onLoadGecmis);
  }

  /// Tüm antrenman programlarını yükle
  Future<void> _onLoadProgramlari(
    LoadAntrenmanProgramlari event,
    Emitter<AntrenmanState> emit,
  ) async {
    emit(AntrenmanLoading());

    try {
      final programlar = await dataSource.tumProgramlariYukle();
      emit(AntrenmanProgramlariLoaded(programlar: programlar));
    } catch (e) {
      emit(AntrenmanError('Programlar yüklenemedi: $e'));
    }
  }

  /// Zorluk seviyesine göre filtrele
  Future<void> _onFilterByZorluk(
    FilterByZorluk event,
    Emitter<AntrenmanState> emit,
  ) async {
    emit(AntrenmanLoading());

    try {
      final programlar = await dataSource.zorlugaGoreProgramlariGetir(event.zorluk);
      emit(AntrenmanProgramlariLoaded(
        programlar: programlar,
        filtreZorluk: event.zorluk,
      ));
    } catch (e) {
      emit(AntrenmanError('Filtreleme başarısız: $e'));
    }
  }

  /// Kategori'ye göre egzersizleri filtrele
  Future<void> _onFilterByKategori(
    FilterByKategori event,
    Emitter<AntrenmanState> emit,
  ) async {
    emit(AntrenmanLoading());

    try {
      final egzersizler =
          await dataSource.kategoriyeGoreEgzersizleriGetir(event.kategori);
      emit(EgzersizlerLoaded(
        egzersizler: egzersizler,
        kategori: event.kategori,
      ));
    } catch (e) {
      emit(AntrenmanError('Egzersizler yüklenemedi: $e'));
    }
  }

  /// Antrenman programını başlat
  Future<void> _onStartAntrenman(
    StartAntrenman event,
    Emitter<AntrenmanState> emit,
  ) async {
    emit(AntrenmanActive(
      program: event.program,
      tamamlananEgzersizler: [],
      baslangicZamani: DateTime.now(),
    ));
  }

  /// Egzersizi tamamla
  Future<void> _onCompleteEgzersiz(
    CompleteEgzersiz event,
    Emitter<AntrenmanState> emit,
  ) async {
    if (state is! AntrenmanActive) return;

    final currentState = state as AntrenmanActive;
    final yeniTamamlananlar = List<String>.from(currentState.tamamlananEgzersizler)
      ..add(event.egzersizId);

    emit(currentState.copyWith(tamamlananEgzersizler: yeniTamamlananlar));
  }

  /// Antrenmanı tamamla ve kaydet
  Future<void> _onCompleteAntrenman(
    CompleteAntrenman event,
    Emitter<AntrenmanState> emit,
  ) async {
    if (state is! AntrenmanActive) return;

    final currentState = state as AntrenmanActive;

    try {
      // Tamamlanan antrenman kaydı oluştur
      final tamamlananAntrenman = TamamlananAntrenman(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        antrenmanId: currentState.program.id,
        tamamlanmaTarihi: DateTime.now(),
        tamamlananSure: event.gercekSure,
        yakilanKalori: event.gercekKalori,
        tamamlananEgzersizler: currentState.tamamlananEgzersizler,
        kullaniciNotlari: event.rating,
        yorum: event.yorum,
      );

      // Hive'a kaydet
      await HiveService.tamamlananAntrenmanKaydet(tamamlananAntrenman);

      // Programlar listesine dön
      add(LoadAntrenmanProgramlari());
    } catch (e) {
      emit(AntrenmanError('Antrenman kaydedilemedi: $e'));
    }
  }

  /// Antrenman geçmişini yükle
  Future<void> _onLoadGecmis(
    LoadAntrenmanGecmisi event,
    Emitter<AntrenmanState> emit,
  ) async {
    emit(AntrenmanLoading());

    try {
      final gecmis = await HiveService.tamamlananAntrenmanlar();
      emit(AntrenmanGecmisiLoaded(gecmis));
    } catch (e) {
      emit(AntrenmanError('Geçmiş yüklenemedi: $e'));
    }
  }
}
