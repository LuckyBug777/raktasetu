import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';

/// Use Case: Get all nearby donors (any blood group)
class GetNearbyDonorsUseCase {
  final DonorRepository repository;

  GetNearbyDonorsUseCase({required this.repository});

  Future<Either<Exception, List<DonorSearchResult>>> call({
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  }) async {
    return await repository.getAllNearbyDonors(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      radiusKm: radiusKm,
    );
  }
}
