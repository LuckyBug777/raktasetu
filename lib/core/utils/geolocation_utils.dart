import 'dart:math' as math;

/// Geolocation Utilities - Haversine Formula for distance calculation
class GeolocationUtils {
  // Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  /// 
  /// [lat1], [lon1]: Latitude and Longitude of point 1
  /// [lat2], [lon2]: Latitude and Longitude of point 2
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Check if a user is within proximity radius
  static bool isWithinProximity({
    required double userLat,
    required double userLon,
    required double targetLat,
    required double targetLon,
    required double radiusKm,
  }) {
    final distance = calculateDistance(
      lat1: userLat,
      lon1: userLon,
      lat2: targetLat,
      lon2: targetLon,
    );
    return distance <= radiusKm;
  }

  /// Filter donors by coordinates within proximity radius
  /// Returns list of (donor, distance) pairs sorted by distance
  static List<MapEntry<T, double>> filterDonorsByProximity<T extends GeoLocatable>({
    required List<T> donors,
    required double userLat,
    required double userLon,
    required double radiusKm,
  }) {
    final nearbyDonors = <MapEntry<T, double>>[];

    for (final donor in donors) {
      final distance = calculateDistance(
        lat1: userLat,
        lon1: userLon,
        lat2: donor.latitude,
        lon2: donor.longitude,
      );

      if (distance <= radiusKm) {
        nearbyDonors.add(MapEntry(donor, distance));
      }
    }

    // Sort by distance (nearest first)
    nearbyDonors.sort((a, b) => a.value.compareTo(b.value));

    return nearbyDonors;
  }

  /// Get bearing angle between two coordinates (in degrees)
  /// Useful for showing direction to donor
  static double getBearing({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLon = _degreesToRadians(lon2 - lon1);
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    final bearingDegrees = (bearing * (180.0 / math.pi) + 360) % 360;

    return bearingDegrees;
  }
}

/// Interface for objects that have geographic coordinates
abstract class GeoLocatable {
  double get latitude;
  double get longitude;
}