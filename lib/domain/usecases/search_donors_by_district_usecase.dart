import 'package:dartz/dartz.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';

/// Use Case: Search donors by district
class SearchDonorsByDistrictUseCase {
  final DonorRepository repository;

  SearchDonorsByDistrictUseCase({required this.repository});

  Future<Either<Exception, List<Donor>>> call({
    required String bloodGroup,
    required String district,
  }) async {
    return await repository.searchDonorsByDistrict(
      bloodGroup: bloodGroup,
      district: district,
    );
  }
}
