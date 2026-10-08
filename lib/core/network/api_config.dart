import 'package:flutter/foundation.dart';

/// Where the backend lives and how long to wait for it.
///
/// Override the base URL at build time, e.g.
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3999`
/// (needed for a physical phone, which can't reach your Mac's 127.0.0.1).
abstract final class ApiConfig {
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static const int defaultPort = 3999;

  /// The base URL for every request.
  ///
  /// Defaults: `127.0.0.1` on web, iOS and desktop; `10.0.2.2` on Android,
  /// which is how the Android emulator reaches the host machine.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return isAndroid
        ? 'http://10.0.2.2:$defaultPort'
        : 'http://127.0.0.1:$defaultPort';
  }

  /// How long to wait for the server to accept the connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Answers can take a while: retrieval plus LLM generation.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Uploads are parsed and indexed before the server replies, which can
  /// take several minutes for large PDFs. Used for the upload request only.
  static const Duration uploadReceiveTimeout = Duration(minutes: 5);
}
