import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../businesses/data/business_repository.dart';
import '../../businesses/presentation/business_shell_page.dart';
import '../data/auth_session_manager.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    required this.auth,
    required this.sessionManager,
    required this.repository,
    required this.googleMapsApiKey,
    super.key,
  });

  final FirebaseAuth auth;
  final AuthSessionManager sessionManager;
  final BusinessRepository repository;
  final String googleMapsApiKey;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return LoginPage(auth: auth, sessionManager: sessionManager);
        }
        return BusinessShellPage(
          repository: repository,
          googleMapsApiKey: googleMapsApiKey,
          onSignOut: () => sessionManager.signOut(),
        );
      },
    );
  }
}
