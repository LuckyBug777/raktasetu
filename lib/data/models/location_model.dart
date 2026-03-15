import 'package:raktasetu/domain/entities/location.dart';

/// Location Model - Data Layer
class LocationModel extends Location {
  const LocationModel({
    required double latitude,
    required double longitude,
    String? address,
    String? district,
    double? accuracy,
  }) : super(
    latitude: latitude,
    longitude: longitude,
    address: address,
    district: district,
    accuracy: accuracy,
  );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      district: json['district'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  factory LocationModel.fromEntity(Location location) {
    return LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      district: location.district,
      accuracy: location.accuracy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'district': district,
      'accuracy': accuracy,
    };
  }
}
