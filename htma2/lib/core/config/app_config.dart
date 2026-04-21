import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._({
    required this.googleMapsApiKey,
    required this.firebaseDatabaseUrl,
  });

  final String googleMapsApiKey;
  final String firebaseDatabaseUrl;

  static const _requiredKeys = <String>['FIREBASE_DATABASE_URL'];

  static Future<AppConfig> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Optional fallback: values can still come from --dart-define.
    }

    final missingKeys = <String>[];
    final resolved = <String, String>{};

    for (final key in _requiredKeys) {
      final value = _resolveValue(key);
      if (value.isEmpty) {
        missingKeys.add(key);
      } else {
        resolved[key] = value;
      }
    }

    if (missingKeys.isNotEmpty) {
      throw AppConfigException(
        'Missing required environment variables: ${missingKeys.join(', ')}.\n'
        'Provide them via --dart-define or htmarevived/.env.',
      );
    }

    final rawDatabaseUrl = resolved['FIREBASE_DATABASE_URL']!;
    final validatedDatabaseUrl = validateFirebaseDatabaseUrl(rawDatabaseUrl);

    return AppConfig._(
      googleMapsApiKey: _resolveValue('GOOGLE_MAPS_API_KEY'),
      firebaseDatabaseUrl: validatedDatabaseUrl,
    );
  }

  static String validateFirebaseDatabaseUrl(String input) {
    final value = input.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      throw AppConfigException(
        'FIREBASE_DATABASE_URL must be a valid URL. '
        'Use your Realtime Database endpoint, e.g. '
        'https://your-project-id-default-rtdb.firebaseio.com/.',
      );
    }

    if (uri.scheme != 'https') {
      throw AppConfigException(
        'FIREBASE_DATABASE_URL must start with https://. '
        'Firebase Realtime Database endpoints are always HTTPS.',
      );
    }

    final host = uri.host.toLowerCase();
    if (host == 'console.firebase.google.com' || host == 'firebase.google.com') {
      throw AppConfigException(
        'FIREBASE_DATABASE_URL is using a Firebase Console URL. '
        'Use the Realtime Database endpoint URL instead, e.g. '
        'https://your-project-id-default-rtdb.firebaseio.com/.',
      );
    }

    final isEndpoint =
        host.endsWith('.firebaseio.com') || host.endsWith('.firebasedatabase.app');
    if (!isEndpoint) {
      throw AppConfigException(
        'FIREBASE_DATABASE_URL must be a Realtime Database endpoint host ending in '
        '.firebaseio.com or .firebasedatabase.app. '
        'Example: https://your-project-id-default-rtdb.firebaseio.com/.',
      );
    }

    return value;
  }

  static String _resolveValue(String key) {
    final fromDefine = switch (key) {
      'GOOGLE_MAPS_API_KEY' => const String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
      ),
      'FIREBASE_DATABASE_URL' => const String.fromEnvironment(
        'FIREBASE_DATABASE_URL',
      ),
      _ => '',
    };
    if (fromDefine.trim().isNotEmpty) {
      return fromDefine.trim();
    }

    final fromDotenv = dotenv.maybeGet(key)?.trim() ?? '';
    return fromDotenv;
  }
}

class AppConfigException implements Exception {
  AppConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
