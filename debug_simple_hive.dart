// ============================================================================
// debug_simple_hive.dart
// BASİT HIVE DEBUG - Flutter olmadan
// ============================================================================

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('🔍 HIVE DEBUG BAŞLATILIYOR...');
  
  try {
    // 1. Hive database path'ını bul
    final appDir = Directory.current.path;
    final hivePath = path.join(appDir, 'build', 'hive');
    
    print('📁 App Directory: $appDir');
    print('📁 Hive Path: $hivePath');
    
    // 2. Hive dosyalarını kontrol et
    final hiveDir = Directory(hivePath);
    if (await hiveDir.exists()) {
      print('✅ Hive directory bulundu');
      
      final files = await hiveDir.list().toList();
      print('📄 Hive dosyaları (${files.length}):');
      
      for (final file in files) {
        final fileName = path.basename(file.path);
        int fileSize = 0;
        if (file is File) {
          fileSize = await file.length();
        }
        print('   - $fileName (${fileSize} bytes)');
        
        // Yemek planı dosyasını kontrol et
        if (fileName.contains('plan') || fileName.contains('yemek')) {
          print('     🔍 Yemek planı dosyası tespit edildi');
        }
        
        // Onay durumu dosyasını kontrol et
        if (fileName.contains('onay') || fileName.contains('durum')) {
          print('     🔍 Onay durumu dosyası tespit edildi');
        }
        
        // Kullanıcı profili dosyasını kontrol et
        if (fileName.contains('kullanici') || fileName.contains('profil')) {
          print('     🔍 Kullanıcı profili dosyası tespit edildi');
        }
      }
      
      if (files.isEmpty) {
        print('❌ Hive directory BOŞ!');
        print('💡 Muhtemel nedenler:');
        print('   1. Uygulama hiç çalıştırılmadı');
        print('   2. Hive başlatılamadı');
        print('   3. Database path yanlış');
      }
    } else {
      print('❌ Hive directory bulunamadı!');
      print('💡 Önce uygulamayı çalıştırın: flutter run');
    }
    
    // 3. Flutter build directory'sini kontrol et
    final buildDir = Directory(path.join(appDir, 'build'));
    if (await buildDir.exists()) {
      print('✅ Build directory bulundu');
      
      // iOS/Android build'larını kontrol et
      final iosDir = Directory(path.join(buildDir.path, 'ios'));
      final androidDir = Directory(path.join(buildDir.path, 'android'));
      
      if (await iosDir.exists()) {
        final iosFiles = await iosDir.list().toList();
        print('📱 iOS build dosyaları: ${iosFiles.length}');
      }
      
      if (await androidDir.exists()) {
        final androidFiles = await androidDir.list().toList();
        print('🤖 Android build dosyaları: ${androidFiles.length}');
      }
    } else {
      print('❌ Build directory bulunamadı!');
      print('💡 Uygulama hiç build edilmemiş olabilir');
    }
    
    // 4. Assets dosyalarını kontrol et
    final assetsDir = Directory(path.join(appDir, 'assets'));
    if (await assetsDir.exists()) {
      final assets = await assetsDir.list().toList();
      print('📦 Assets dosyaları: ${assets.length}');
      
      for (final asset in assets) {
        final fileName = path.basename(asset.path);
        if (fileName.contains('.json')) {
          int fileSize = 0;
          if (asset is File) {
            fileSize = await asset.length();
          }
          print('   📄 $fileName (${fileSize} bytes)');
        }
      }
    } else {
      print('❌ Assets directory bulunamadı!');
    }
    
    print('\n🎯 ÖZET:');
    print('Bu debug script Hive dosyalarının varlığını kontrol eder.');
    print('Eğer dosyalar yoksa, Flutter uygulamasını çalıştırın:');
    print('   flutter run');
    print('   sonra plan oluşturun ve tekrar kontrol edin.');
    
  } catch (e, stackTrace) {
    print('❌ Hata: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n🏁 DEBUG BİTTİ');
}