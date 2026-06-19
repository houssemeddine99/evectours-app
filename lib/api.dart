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
}
