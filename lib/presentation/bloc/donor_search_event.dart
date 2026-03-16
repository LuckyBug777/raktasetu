part of 'donor_search_bloc.dart';

/// Events for Donor Search BLoC
abstract class DonorSearchEvent extends Equatable {
  const DonorSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Search by blood group and location (10km radius)
class SearchDonorsByLocationEvent extends DonorSearchEvent {
  final String bloodGroup;
  final double userLatitude;
  final double userLongitude;
  final double radiusKm;

  const SearchDonorsByLocationEvent({
    required this.bloodGroup,
    required this.userLatitude,
    required this.userLongitude,
    this.radiusKm = 10.0,
  });

  @override
  List<Object?> get props => [
    bloodGroup,
    userLatitude,
    userLongitude,
    radiusKm,
  ];
}

/// Event: Search by blood group and district
class SearchDonorsByDistrictEvent extends DonorSearchEvent {
  final String bloodGroup;
  final String district;

  const SearchDonorsByDistrictEvent({
    required this.bloodGroup,
    required this.district,
  });

  @override
  List<Object?> get props => [bloodGroup, district];
}

/// Event: Get all nearby donors (any blood group)
class GetNearbyDonorsEvent extends DonorSearchEvent {
  final double userLatitude;
  final double userLongitude;
  final double radiusKm;

  const GetNearbyDonorsEvent({
    required this.userLatitude,
    required this.userLongitude,
    this.radiusKm = 10.0,
  });

  @override
  List<Object?> get props => [userLatitude, userLongitude, radiusKm];
}

/// Event: Advanced search with multiple filters
class AdvancedSearchDonorsEvent extends DonorSearchEvent {
  final String? bloodGroup;
  final String? district;
  final double? userLatitude;
  final double? userLongitude;
  final double radiusKm;
  final bool availableOnly;

  const AdvancedSearchDonorsEvent({
    this.bloodGroup,
    this.district,
    this.userLatitude,
    this.userLongitude,
    required this.radiusKm,
    required this.availableOnly,
  });

  @override
  List<Object?> get props => [
    bloodGroup,
    district,
    userLatitude,
    userLongitude,
    radiusKm,
    availableOnly,
  ];
}

/// Event: Clear search results
class ClearSearchEvent extends DonorSearchEvent {
  const ClearSearchEvent();
}
