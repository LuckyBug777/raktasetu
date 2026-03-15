import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';

/// Use Case: Advanced search with multiple filters
class AdvancedSearchDonorsUseCase {
  final DonorRepository repository;

  AdvancedSearchDonorsUseCase({required this.repository});

  Future<Either<Exception, List<DonorSearchResult>>> call({
    required String? bloodGroup,
    required String? district,
    required double? userLatitude,
    required double? userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
    required bool availableOnly = true,
  }) async {
    return await repository.advancedSearch(
      bloodGroup: bloodGroup,
      district: district,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      radiusKm: radiusKm,
      availableOnly: availableOnly,
    );
  }
}
