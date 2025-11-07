// lib/core/utils/app_logger.dart


/// Uygulama geneli için merkezi loglama sistemi
///
/// Kullanım:
/// ```dart
/// AppLogger.info('Bilgi mesajı');
/// AppLogger.error('Hata mesajı', error: e, stackTrace: st);
/// ```
/// Log seviyeleri - Spam'i önlemek için kontrollü logging
enum LogLevel {
  debug,    // Her şey (geliştirme için)
  success,  // Başarı mesajları
  info,     // Bilgiler
  warning,  // Uyarılar
  error,    // Sadece hatalar
}

class AppLogger {
  // 🔥 Varsayılan seviye INFO'ya geri döndürüldü. DEBUG için init() kullanılacak.
  static LogLevel _currentLevel = LogLevel.info; 
  static bool _showTimestamp = true;

  /// Logger seviye ayarla - Spam kontrolü için
  static void init({LogLevel level = LogLevel.info, bool showTimestamp = true}) {
    _currentLevel = level;
    _showTimestamp = showTimestamp;
  }

  /// Bilgi seviyesi log - Kullanıcıya yararlı bilgiler
  static void info(String message) {
    if (_shouldLog(LogLevel.info)) {
      _log('ℹ️ INFO', message, null);
    }
  }

  /// Debug seviyesi log - Sadece geliştirme için
  static void debug(String message) {
    if (_shouldLog(LogLevel.debug)) {
      _log('🐛 DEBUG', message, null);
    }
  }

  /// Başarı mesajı - Önemli tamamlanan işlemler
  static void success(String message) {
    if (_shouldLog(LogLevel.success)) {
      _log('✅ SUCCESS', message, null);
    }
  }

  /// Uyarı mesajı - Potansiyel problemler
  static void warning(String message) {
    if (_shouldLog(LogLevel.warning)) {
      _log('⚠️ WARNING', message, null);
    }
  }

  /// Hata mesajı
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('❌ ERROR', message, error);
    // ✅ Stack trace HER ZAMAN görünsün!
    if (stackTrace != null) {
      print(stackTrace.toString());
    }
  }

  /// Log seviye kontrolü
  static bool _shouldLog(LogLevel level) {
    return level.index <= _currentLevel.index;
  }

  /// Temel log fonksiyonu
  static void _log(String level, String message, Object? error) {
    final timestamp = _showTimestamp
        ? '|> ${DateTime.now().toString().substring(11, 19)} | '
        : '';

    final errorMsg = error != null ? ' | Error: $error' : '';

    print('$timestamp$level: $message$errorMsg');
  }
}
