import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.auth,
    required this.sessionManager,
    super.key,
  });

  final FirebaseAuth auth;
  final AuthSessionManager sessionManager;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email is required.';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await widget.sessionManager.markLoginSuccess();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = switch (error.code) {
          'invalid-credential' => 'Invalid email or password.',
          'invalid-email' => 'Please enter a valid email address.',
          'user-disabled' => 'This user account has been disabled.',
          'too-many-requests' =>
            'Too many login attempts. Try again in a few minutes.',
          _ => 'Sign in failed (${error.code}).',
        };
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(labelText: 'Email'),
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      enabled: !_isSubmitting,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Password'),
                      onSubmitted: (_) => _signIn(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _signIn,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
