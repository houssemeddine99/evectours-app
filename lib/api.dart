import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models.dart';

/// Thin client for the Evec Tours JSON API.
class Api {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<List<Voyage>> voyages() async {
    final res = await http
        .get(Uri.parse('$kApiBase/voyages'))
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Failed to load voyages (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['voyages'] as List?) ?? const [];
    return list
        .map((e) => Voyage.fromList(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Voyage> voyage(String slug) async {
    final res = await http
        .get(Uri.parse('$kApiBase/voyages/$slug'))
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Failed to load voyage (${res.statusCode})');
    }
    return Voyage.fromDetail(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<List<Offer>> offers() async {
    final res = await http
        .get(Uri.parse('$kApiBase/offers'))
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Failed to load offers (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['offers'] as List?) ?? const [];
    return list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Auth ──────────────────────────────────────────────

  static Future<({String token, AppUser user})> login(
      String email, String password) async {
    final res = await http
        .post(Uri.parse('$kApiBase/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}))
        .timeout(_timeout);
    final data = _decode(res.body);
    if (res.statusCode != 200) {
      throw ApiException(data['error']?.toString() ?? 'Login failed.');
    }
    return (token: data['token'] as String, user: AppUser.fromJson(data['user']));
  }

  static Future<({String token, AppUser user})> register(
      String username, String email, String password) async {
    final res = await http
        .post(Uri.parse('$kApiBase/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'username': username, 'email': email, 'password': password}))
        .timeout(_timeout);
    final data = _decode(res.body);
    if (res.statusCode != 201) {
      throw ApiException(data['error']?.toString() ?? 'Registration failed.');
    }
    return (token: data['token'] as String, user: AppUser.fromJson(data['user']));
  }

  static Future<({AppUser user, List<Booking> bookings})> account(
      String token) async {
    final res = await http
        .get(Uri.parse('$kApiBase/auth/account'),
            headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw ApiException('Your session has expired. Please sign in again.');
    }
    final data = _decode(res.body);
    final bookings = ((data['bookings'] as List?) ?? const [])
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
    return (user: AppUser.fromJson(data['user']), bookings: bookings);
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final j = jsonDecode(body);
      return j is Map<String, dynamic> ? j : {};
    } catch (_) {
      return {};
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
