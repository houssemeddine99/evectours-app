import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'models.dart';

/// Holds the auth token + current user, persisted on the device.
class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  String? _token;
  AppUser? _user;

  String? get token => _token;
  AppUser? get user => _user;
  bool get isLoggedIn => _token != null && _user != null;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString(_kToken);
    final u = p.getString(_kUser);
    if (u != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(u) as Map<String, dynamic>);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final r = await Api.login(email, password);
    await _set(r.token, r.user);
  }

  Future<void> register(String username, String email, String password) async {
    final r = await Api.register(username, email, password);
    await _set(r.token, r.user);
  }

  Future<void> logout() async {
    await _set(null, null);
  }

  Future<void> _set(String? token, AppUser? user) async {
    _token = token;
    _user = user;
    final p = await SharedPreferences.getInstance();
    if (token != null) {
      await p.setString(_kToken, token);
    } else {
      await p.remove(_kToken);
    }
    if (user != null) {
      await p.setString(_kUser, jsonEncode(user.toJson()));
    } else {
      await p.remove(_kUser);
    }
    notifyListeners();
  }
}
