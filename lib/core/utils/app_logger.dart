// lib/core/utils/app_logger.dart

import 'package:flutter/foundation.dart';

/// Uygulama geneli için merkezi loglama sistemi
///
/// Kullanım:
/// ```dart
/// AppLogger.info('Bilgi mesajı');
/// AppLogger.error('Hata mesajı', error: e, stackTrace: st);
/// ```
class AppLogger {
  static bool _isDebug = kDebugMode;
  static bool _showTimestamp = true;

  /// Logger'ı başlat
  static void init({bool isDebug = true, bool showTimestamp = true}) {
    _isDebug = isDebug;
    _showTimestamp = showTimestamp;
  }

  /// Bilgi seviyesi log
  static void info(String message) {
    if (!_isDebug) return;
    _log('ℹ️ INFO', message, null);
  }

  /// Debug seviyesi log
  static void debug(String message) {
    if (!_isDebug) return;
    _log('🐛 DEBUG', message, null);
  }

  /// Başarı mesajı
  static void success(String message) {
    if (!_isDebug) return;
    _log('✅ SUCCESS', message, null);
  }

  /// Uyarı mesajı
  static void warning(String message) {
    if (!_isDebug) return;
    _log('⚠️ WARNING', message, null);
  }

  /// Hata mesajı
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('❌ ERROR', message, error);
    if (stackTrace != null && _isDebug) {
      debugPrint(stackTrace.toString());
    }
  }

  /// Temel log fonksiyonu
  static void _log(String level, String message, Object? error) {
    final timestamp = _showTimestamp
        ? '[${DateTime.now().toString().substring(11, 19)}] '
        : '';

    final errorMsg = error != null ? ' | Error: $error' : '';

    debugPrint('$timestamp$level: $message$errorMsg');
  }
}
