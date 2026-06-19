import 'package:flutter/material.dart';

import '../auth_store.dart';
import '../constants.dart';
import '../widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_password.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthStore.instance
          .register(_username.text.trim(), _email.text.trim(), _password.text);
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
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Text('Join Evec Tours', style: poppins(size: 24, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Create an account to book and track your trips.',
              style: TextStyle(color: kMuted, fontSize: 14.5)),
          const SizedBox(height: 24),
          if (_error != null) AuthError(_error!),
          AuthField(controller: _username, label: 'Username', icon: Icons.person_outline),
          AuthField(controller: _email, label: 'Email', icon: Icons.mail_outline, keyboard: TextInputType.emailAddress),
          AuthField(controller: _password, label: 'Password', icon: Icons.lock_outline, obscure: true),
          const SizedBox(height: 20),
          AuthButton(label: 'Create account', loading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text.rich(TextSpan(
                text: 'Already have an account?  ',
                style: TextStyle(color: kMuted),
                children: [
                  TextSpan(
                      text: 'Sign in',
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
