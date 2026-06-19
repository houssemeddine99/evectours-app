import 'package:flutter/material.dart';

import '../auth_store.dart';
import '../constants.dart';
import '../widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthStore.instance.login(_email.text.trim(), _password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Text('Welcome back', style: poppins(size: 24, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Sign in to continue your journey.',
              style: TextStyle(color: kMuted, fontSize: 14.5)),
          const SizedBox(height: 24),
          if (_error != null) AuthError(_error!),
          AuthField(controller: _email, label: 'Email', icon: Icons.mail_outline, keyboard: TextInputType.emailAddress),
          AuthField(controller: _password, label: 'Password', icon: Icons.lock_outline, obscure: true),
          const SizedBox(height: 20),
          AuthButton(label: 'Sign in', loading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text.rich(TextSpan(
                text: "Don't have an account?  ",
                style: TextStyle(color: kMuted),
                children: [
                  TextSpan(
                      text: 'Create one',
                      style: TextStyle(color: kGoldDark, fontWeight: FontWeight.w700)),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
