// ============================================================================
// ANTRENMAN LOCAL DATA SOURCE - FAZ 9
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/antrenman.dart';
import '../../domain/entities/egzersiz.dart';
import '../../core/utils/logger.dart';

/// JSON'dan antrenman programlarını yükleyen data source
class AntrenmanLocalDataSource {
  /// Tüm antrenman programlarını yükle
  Future<List<AntrenmanProgrami>> tumProgramlariYukle() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/antrenman_programlari.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final programlar = <AntrenmanProgrami>[];
      for (final item in jsonList) {
        programlar.add(_programFromJson(item));
      }
      
      AppLogger.info('${programlar.length} antrenman programı yüklendi');
      return programlar;
    } catch (e) {
      AppLogger.error('Antrenman programları yüklenemedi: $e');
      rethrow;
    }
  }

  /// Zorluk seviyesine göre programları filtrele
  Future<List<AntrenmanProgrami>> zorlugaGoreProgramlariGetir(Zorluk zorluk) async {
    final tumProgramlar = await tumProgramlariYukle();
    return tumProgramlar.where((p) => p.zorluk == zorluk).toList();
  }

  /// Kategori'ye göre egzersizleri filtrele
  Future<List<Egzersiz>> kategoriyeGoreEgzersizleriGetir(EgzersizKategorisi kategori) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/egzersizler.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final tumEgzersizler = <Egzersiz>[];
      for (final item in jsonList) {
        tumEgzersizler.add(_egzersizFromJson(item));
      }
      
      return tumEgzersizler.where((e) => e.kategori == kategori).toList();
    } catch (e) {
      AppLogger.error('Egzersizler yüklenemedi: $e');
      rethrow;
    }
  }

  /// Kas grubuna göre egzersizleri filtrele
  Future<List<Egzersiz>> kasGrubunaGoreEgzersizleriGetir(KasGrubu kasGrubu) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/egzersizler.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final tumEgzersizler = <Egzersiz>[];
      for (final item in jsonList) {
        tumEgzersizler.add(_egzersizFromJson(item));
      }
      
      return tumEgzersizler.where((e) => e.hedefKaslar.contains(kasGrubu)).toList();
    } catch (e) {
      AppLogger.error('Egzersizler yüklenemedi: $e');
      rethrow;
    }
  }

  /// JSON'dan Antrenman Programı oluştur
  AntrenmanProgrami _programFromJson(Map<String, dynamic> json) {
    final egzersizler = (json['egzersizler'] as List)
        .map((e) => _egzersizFromJson(e as Map<String, dynamic>))
        .toList();

    return AntrenmanProgrami(
      id: json['id'] as String,
      ad: json['ad'] as String,
      aciklama: json['aciklama'] as String,
      egzersizler: egzersizler,
      zorluk: _zorlukFromString(json['zorluk'] as String),
      toplamSure: json['toplamSure'] as int,
      toplamKalori: json['toplamKalori'] as int,
      hedefKasGruplari: (json['hedefKasGruplari'] as List)
          .map((k) => _kasGrubuFromString(k as String))
          .toList(),
      gorselUrl: json['gorselUrl'] as String?,
    );
  }

  /// JSON'dan Egzersiz oluştur
  Egzersiz _egzersizFromJson(Map<String, dynamic> json) {
    return Egzersiz(
      id: json['id'] as String,
      ad: json['ad'] as String,
      aciklama: json['aciklama'] as String,
      sure: json['sure'] as int,
      kalori: json['kalori'] as int,
      zorluk: _zorlukFromString(json['zorluk'] as String),
      kategori: _kategoriFromString(json['kategori'] as String),
      hedefKaslar: (json['hedefKaslar'] as List)
          .map((k) => _kasGrubuFromString(k as String))
          .toList(),
      videoUrl: json['videoUrl'] as String?,
      gorselUrl: json['gorselUrl'] as String?,
      talimatlar: (json['talimatlar'] as List)
          .map((t) => t as String)
          .toList(),
      tekrarSayisi: json['tekrarSayisi'] as int?,
      setSayisi: json['setSayisi'] as int?,
    );
  }

  /// String'den Zorluk enum'ı oluştur
  Zorluk _zorlukFromString(String zorluk) {
    switch (zorluk.toLowerCase()) {
      case 'baslangic':
        return Zorluk.baslangic;
      case 'orta':
        return Zorluk.orta;
      case 'ileri':
        return Zorluk.ileri;
      case 'profesyonel':
        return Zorluk.profesyonel;
      default:
        return Zorluk.baslangic;
    }
  }

  /// String'den EgzersizKategorisi enum'ı oluştur
  EgzersizKategorisi _kategoriFromString(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kardiyovaskuler':
        return EgzersizKategorisi.kardiyovaskuler;
      case 'guc':
        return EgzersizKategorisi.guc;
      case 'esneklik':
        return EgzersizKategorisi.esneklik;
      case 'denge':
        return EgzersizKategorisi.denge;
      case 'hiit':
        return EgzersizKategorisi.hiit;
      case 'yoga':
        return EgzersizKategorisi.yoga;
      case 'pilates':
        return EgzersizKategorisi.pilates;
      default:
        return EgzersizKategorisi.kardiyovaskuler;
    }
  }

  /// String'den KasGrubu enum'ı oluştur
  KasGrubu _kasGrubuFromString(String kasGrubu) {
    switch (kasGrubu.toLowerCase()) {
      case 'gogus':
        return KasGrubu.gogus;
      case 'sirt':
        return KasGrubu.sirt;
      case 'bacak':
        return KasGrubu.bacak;
      case 'omuz':
        return KasGrubu.omuz;
      case 'kol':
        return KasGrubu.kol;
      case 'karin':
        return KasGrubu.karin;
      case 'tumvucut':
        return KasGrubu.tumVucut;
      default:
        return KasGrubu.tumVucut;
    }
  }
}
