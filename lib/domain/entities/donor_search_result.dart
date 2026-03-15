import 'package:equatable/equatable.dart';
import 'donor.dart';

/// Donor Search Result - Contains donor and calculated distance
class DonorSearchResult extends Equatable {
  final Donor donor;
  final double distanceKm;
  final bool isWithinProximity;

  const DonorSearchResult({
    required this.donor,
    required this.distanceKm,
    required this.isWithinProximity,
  });

  @override
  List<Object?> get props => [
    donor,
    distanceKm,
    isWithinProximity,
  ];
}