import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';

/// Use Case: Search donors by location with 10km radius
class SearchDonorsByLocationUseCase {
  final DonorRepository repository;

  SearchDonorsByLocationUseCase({required this.repository});

  Future<Either<Exception, List<DonorSearchResult>>> call({
    required String bloodGroup,
    required double userLatitude,
    required double userLongitude,
    required double radiusKm = AppConstants.PROXIMITY_RADIUS_KM,
  }) async {
    return await repository.searchDonorsByLocation(
      bloodGroup: bloodGroup,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      radiusKm: radiusKm,
    );
  }
}
