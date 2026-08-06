import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/location.dart';

/// Location Service - Handles GPS and permissions
class LocationService {
  /// Get current user location
  static Future<Location> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: AppConstants.locationTimeout,
    );

    final placemarks = await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address:
            '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}',
      );
    } else {
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Unknown location',
      );
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check current location permission status
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Silently gets GPS coordinates + reverse-geocodes to a district name.
  /// Returns null if permissions are denied, services are off, or any error occurs.
  /// Safe to call fire-and-forget — never throws.
  static Future<({double lat, double lng, String district})?> getLocationWithDistrict() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      // Reverse-geocode to get district name
      String district = '';
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // subAdministrativeArea gives the district/taluk in India
          district = place.subAdministrativeArea ??
              place.locality ??
              place.administrativeArea ??
              '';
        }
      } catch (_) {
        // Geocoding failed — still return coordinates, just no district
      }

      return (lat: position.latitude, lng: position.longitude, district: district);
    } catch (_) {
      return null;
    }
  }
}

