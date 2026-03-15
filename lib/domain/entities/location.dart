import 'package:equatable/equatable.dart';

/// Location Entity
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? district;
  final double? accuracy;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.district,
    this.accuracy,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    address,
    district,
    accuracy,
  ];
}