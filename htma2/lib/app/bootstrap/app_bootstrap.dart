import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../firebase_options.dart';
import '../../features/auth/data/auth_session_manager.dart';
import '../../features/businesses/data/rtdb_business_repository.dart';
import '../app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_BootstrapResult> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _bootstrap();
  }

  Future<_BootstrapResult> _bootstrap() async {
    final config = await AppConfig.load();
    final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
    _ensureFirebaseOptionsConfigured(firebaseOptions);
    await Firebase.initializeApp(options: firebaseOptions);
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: config.firebaseDatabaseUrl,
    );
    final auth = FirebaseAuth.instanceFor(app: Firebase.app());
    final preferences = await SharedPreferences.getInstance();
    final sessionManager = AuthSessionManager(
      auth: auth,
      preferences: preferences,
    );
    await sessionManager.enforceSessionWindow();
    return _BootstrapResult(
      repository: RtdbBusinessRepository(database: database),
      googleMapsApiKey: config.googleMapsApiKey,
      auth: auth,
      sessionManager: sessionManager,
    );
  }

  void _retry() {
    setState(() {
      _startupFuture = _bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapResult>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingScreen();
        }

        if (snapshot.hasError) {
          return _StartupErrorScreen(error: snapshot.error, onRetry: _retry);
        }

        return BuffaloBusinessApp(
          repository: snapshot.requireData.repository,
          googleMapsApiKey: snapshot.requireData.googleMapsApiKey,
          auth: snapshot.requireData.auth,
          sessionManager: snapshot.requireData.sessionManager,
        );
      },
    );
  }
}

class _BootstrapResult {
  const _BootstrapResult({
    required this.repository,
    required this.googleMapsApiKey,
    required this.auth,
    required this.sessionManager,
  });

  final RtdbBusinessRepository repository;
  final String googleMapsApiKey;
  final FirebaseAuth auth;
  final AuthSessionManager sessionManager;
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      AppConfigException() => error.toString(),
      FirebaseSetupException() => error.toString(),
      FirebaseException firebaseError =>
        'Firebase failed to initialize (${firebaseError.code}). '
            'Confirm flutterfire-generated config files are present for this platform.',
      _ => 'App startup failed. Check configuration and retry.',
    };

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _ensureFirebaseOptionsConfigured(FirebaseOptions options) {
  const placeholder = 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE';
  final values = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
    options.projectId,
  ];
  final hasPlaceholder = values.any((value) => value.contains(placeholder));
  if (!hasPlaceholder) {
    return;
  }

  throw const FirebaseSetupException(
    'Firebase is not configured for this platform yet. '
    'Run "flutterfire configure" and replace lib/firebase_options.dart with the generated file.',
  );
}

class FirebaseSetupException implements Exception {
  const FirebaseSetupException(this.message);

  final String message;

  @override
  String toString() => message;
}
