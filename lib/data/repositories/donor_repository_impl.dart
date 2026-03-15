import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/core/utils/geolocation_utils.dart';
import 'package:raktasetu/data/datasources/donor_remote_datasource.dart';
import 'package:raktasetu/domain/entities/donor.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';
import 'package:raktasetu/data/models/donor_search_result_model.dart';

/// Donor Repository Implementation
class DonorRepositoryImpl implements DonorRepository {
  final DonorRemoteDataSource remoteDataSource;

  DonorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<Donor>>> searchDonorsByDistrict({
    required String bloodGroup,
    required String district,
  }) async {
    try {
      final donors = await remoteDataSource.searchDonorsByDistrict(
        bloodGroup: bloodGroup,
        district: district,
      );
      return Right(donors);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<DonorSearchResult>>> searchDonorsByLocation({
    required String bloodGroup,
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  }) async {
    try {
      final donors = await remoteDataSource.getAllDonors();
      
      // Filter by blood group and visibility
      final filteredDonors = donors
          .where((donor) =>
              donor.bloodGroup.group == bloodGroup &&
              donor.isVisibleInSearch)
          .toList();

      // Apply proximity filter
      final nearbyDonorsWithDistance =
          GeolocationUtils.filterDonorsByProximity(
        donors: filteredDonors,
        userLat: userLatitude,
        userLon: userLongitude,
        radiusKm: radiusKm,
      );

      // Convert to DonorSearchResult
      final results = nearbyDonorsWithDistance
          .map((entry) => DonorSearchResultModel(
                donor: entry.key as dynamic,
                distanceKm: entry.value,
                isWithinProximity: true,
              ))
          .toList();

      return Right(results);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<DonorSearchResult>>> getAllNearbyDonors({
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  }) async {
    try {
      final donors = await remoteDataSource.getAllDonors();

      // Filter by visibility and availability
      final visibleDonors = donors
          .where((donor) => donor.isVisibleInSearch && donor.isAvailableNow)
          .toList();

      // Apply proximity filter
      final nearbyDonorsWithDistance =
          GeolocationUtils.filterDonorsByProximity(
        donors: visibleDonors,
        userLat: userLatitude,
        userLon: userLongitude,
        radiusKm: radiusKm,
      );

      // Convert to DonorSearchResult
      final results = nearbyDonorsWithDistance
          .map((entry) => DonorSearchResultModel(
                donor: entry.key as dynamic,
                distanceKm: entry.value,
                isWithinProximity: true,
              ))
          .toList();

      return Right(results);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, Donor>> getDonorById(String donorId) async {
    try {
      final donor = await remoteDataSource.getDonorById(donorId);
      return Right(donor);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<Donor>>> getAllDonors() async {
    try {
      final donors = await remoteDataSource.getAllDonors();
      return Right(donors);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<DonorSearchResult>>> advancedSearch({
    required String? bloodGroup,
    required String? district,
    required double? userLatitude,
    required double? userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
    required bool availableOnly = true,
  }) async {
    try {
      var donors = await remoteDataSource.getAllDonors();

      // Apply visibility filter
      donors = donors.where((d) => d.isVisibleInSearch).toList();

      // Apply availability filter
      if (availableOnly) {
        donors = donors.where((d) => d.isAvailableNow).toList();
      }

      // Apply blood group filter
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        donors = donors.where((d) => d.bloodGroup.group == bloodGroup).toList();
      }

      // Apply district filter
      if (district != null && district.isNotEmpty) {
        donors =
            donors.where((d) => d.district == district).toList();
      }

      // Apply location-based proximity filter
      List<DonorSearchResult> results = [];

      if (userLatitude != null && userLongitude != null) {
        final nearbyDonorsWithDistance =
            GeolocationUtils.filterDonorsByProximity(
          donors: donors,
          userLat: userLatitude,
          userLon: userLongitude,
          radiusKm: radiusKm,
        );

        results = nearbyDonorsWithDistance
            .map((entry) => DonorSearchResultModel(
                  donor: entry.key as dynamic,
                  distanceKm: entry.value,
                  isWithinProximity: true,
                ))
            .toList();
      } else {
        // No location filter, add all donors with 0 distance
        results = donors
            .map((donor) => DonorSearchResultModel(
                  donor: donor as dynamic,
                  distanceKm: 0,
                  isWithinProximity: false,
                ))
            .toList();
      }

      return Right(results);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
