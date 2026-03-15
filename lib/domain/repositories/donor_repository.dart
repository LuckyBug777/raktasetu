import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';

/// Abstract Repository for Donor Search Operations
abstract class DonorRepository {
  /// Search donors by blood group and district
  Future<Either<Exception, List<Donor>>> searchDonorsByDistrict({
    required String bloodGroup,
    required String district,
  });

  /// Search donors by blood group and current location (10km radius)
  Future<Either<Exception, List<DonorSearchResult>>> searchDonorsByLocation({
    required String bloodGroup,
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  });

  /// Search all nearby donors within radius (any blood group)
  Future<Either<Exception, List<DonorSearchResult>>> getAllNearbyDonors({
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  });

  /// Get donor by ID
  Future<Either<Exception, Donor>> getDonorById(String donorId);

  /// Get list of all active donors
  Future<Either<Exception, List<Donor>>> getAllDonors();

  /// Search donors with multiple filters
  Future<Either<Exception, List<DonorSearchResult>>> advancedSearch({
    required String? bloodGroup,
    required String? district,
    required double? userLatitude,
    required double? userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
    required bool availableOnly = true,
  });
}
