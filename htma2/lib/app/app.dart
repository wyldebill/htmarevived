import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/businesses/data/business_repository.dart';
import '../features/auth/data/auth_session_manager.dart';
import '../features/auth/presentation/auth_gate.dart';

class BuffaloBusinessApp extends StatelessWidget {
  const BuffaloBusinessApp({
    required this.repository,
    required this.googleMapsApiKey,
    required this.auth,
    required this.sessionManager,
    super.key,
  });

  final BusinessRepository repository;
  final String googleMapsApiKey;
  final FirebaseAuth auth;
  final AuthSessionManager sessionManager;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0F766E);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Buffalo Business Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7F9),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFFF4F7F9),
          foregroundColor: colorScheme.onSurface,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: Color(0xFF0F172A),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD6E0E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD6E0E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF475569),
            );
          }),
        ),
      ),
      home: AuthGate(
        auth: auth,
        sessionManager: sessionManager,
        repository: repository,
        googleMapsApiKey: googleMapsApiKey,
      ),
    );
  }
}
