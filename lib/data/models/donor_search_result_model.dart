import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'donor_model.dart';

/// Donor Search Result Model - Data Layer
class DonorSearchResultModel extends DonorSearchResult {
  const DonorSearchResultModel({
    required DonorModel donor,
    required double distanceKm,
    required bool isWithinProximity,
  }) : super(
    donor: donor,
    distanceKm: distanceKm,
    isWithinProximity: isWithinProximity,
  );

  factory DonorSearchResultModel.fromEntity(DonorSearchResult result) {
    return DonorSearchResultModel(
      donor: DonorModel.fromEntity(result.donor),
      distanceKm: result.distanceKm,
      isWithinProximity: result.isWithinProximity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donor': (donor as DonorModel).toJson(),
      'distanceKm': distanceKm,
      'isWithinProximity': isWithinProximity,
    };
  }
}
