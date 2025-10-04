class AppConstants {
  // App Info
  static const String appName = 'ZindeAI';
  static const String appVersion = '1.0.0';
  
  // Kalori hesaplama sabitleri
  static const double proteinKaloriPerGram = 4.0;
  static const double karbonhidratKaloriPerGram = 4.0;
  static const double yagKaloriPerGram = 9.0;
  
  // Varsayılan değerler
  static const double minKarbonhidrat = 50.0;
  static const double maxMakroGram = 999.0;
  
  // Kalori açığı/fazlalığı çarpanları
  static const double kiloVerAcik = 0.80; // %20 açık
  static const double kasKazanKiloVerAcik = 0.85; // %15 açık
  static const double formdaKalDenge = 1.0; // Dengede
  static const double kiloAlFazlalik = 1.10; // %10 fazlalık
  static const double kasKazanKiloAlFazlalik = 1.15; // %15 fazlalık
}
