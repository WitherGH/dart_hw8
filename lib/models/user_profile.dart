import 'dart:math' as math;

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.firstName,
    required this.age,
    required this.city,
    required this.distanceKm,
    required this.photoUrl,
  });

  final String userId;
  final String firstName;
  final int age;
  final String city;
  final int distanceKm;
  final String photoUrl;

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    double originLat = 50.4501,
    double originLon = 30.5234,
  }) {
    final name = json['name'] as Map<String, dynamic>? ?? {};
    final dob = json['dob'] as Map<String, dynamic>? ?? {};
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final picture = json['picture'] as Map<String, dynamic>? ?? {};
    final login = json['login'] as Map<String, dynamic>? ?? {};
    final coordinates = location['coordinates'] as Map<String, dynamic>? ?? {};

    final userId = _asSafeString(
      login['uuid'],
      fallback: '${_asSafeString(name['first'], fallback: 'unknown')}-${_asSafeInt(dob['age'], fallback: 0)}-${_asSafeString(location['city'], fallback: 'city')}',
    );
    final firstName = _asSafeString(name['first'], fallback: 'Unknown');
    final age = _asSafeInt(dob['age'], fallback: 0);
    final city = _asSafeString(location['city'], fallback: 'Unknown city');
    final photo = _asSafeString(picture['large'], fallback: '');
    final lat = _asSafeDouble(coordinates['latitude']);
    final lon = _asSafeDouble(coordinates['longitude']);
    final distance = math.min(50, _haversineKm(originLat, originLon, lat, lon).round());

    return UserProfile(
      userId: userId,
      firstName: firstName,
      age: age,
      city: city,
      distanceKm: distance,
      photoUrl: photo,
    );
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double? lat2,
    double? lon2,
  ) {
    if (lat2 == null || lon2 == null) {
      return 0;
    }

    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.pow(math.sin(dLat / 2), 2).toDouble() +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2).toDouble();
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180);

  static String _asSafeString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }
    final converted = value.toString().trim();
    return converted.isEmpty ? fallback : converted;
  }

  static int _asSafeInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double? _asSafeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
