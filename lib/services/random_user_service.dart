import 'dart:convert';

import 'package:dart_hw8/models/user_profile.dart';
import 'package:http/http.dart' as http;

class RandomUserService {
  final http.Client _client;

  RandomUserService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<UserProfile>> fetchUsers({int count = 10}) async {
    final uri = Uri.parse(
      'https://randomuser.me/api/?results=${count * 3}&nat=us,ua,gb,fr&noinfo',
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? [];

      final users = results
          .whereType<Map<String, dynamic>>()
          .map(UserProfile.fromJson)
          .toList(growable: false);

      final seen = <String>{};
      final unique = <UserProfile>[];
      for (final user in users) {
        if (seen.add(user.userId)) {
          unique.add(user);
          if (unique.length == count) {
            break;
          }
        }
      }

      return unique;
    } catch (_) {
      throw Exception('Failed to load users. Check internet connection.');
    }
  }
}
