import 'package:flutter/foundation.dart';

/// 4. HAFTA: Web API bağlantı ayarları.
///
/// Taban adreste gizli anahtar veya parola bulunmaz.
class ApiAyarlari {
  ApiAyarlari._();

  /// Çalıştırırken elle adres vermek için:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5038
  static const String _tanimliAdres = String.fromEnvironment('API_BASE_URL');

  /// Web projesindeki launchSettings.json "http" profilinin portu.
  static const int port = 5038;

  /// Platforma göre varsayılan taban adres:
  /// - Android emülatörü bilgisayara 10.0.2.2 adresiyle ulaşır
  ///   (emülatörün içindeki "localhost" emülatörün kendisidir).
  /// - iOS Simulator bilgisayarla aynı ağı paylaştığı için localhost yeterli.
  static String get tabanAdres {
    if (_tanimliAdres.isNotEmpty) {
      return _tanimliAdres;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  /// Sunucu bu süre içinde yanıt vermezse istek iptal edilir.
  static const Duration zamanAsimi = Duration(seconds: 8);
}
