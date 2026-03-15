import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';
import 'package:raktasetu/domain/usecases/search_donors_by_location_usecase.dart';
import 'package:raktasetu/domain/usecases/search_donors_by_district_usecase.dart';
import 'package:raktasetu/domain/usecases/get_nearby_donors_usecase.dart';
import 'package:raktasetu/domain/usecases/advanced_search_donors_usecase.dart';

part 'donor_search_event.dart';
part 'donor_search_state.dart';

/// BLoC for Donor Search Operations
/// Handles searching donors by location, district, proximity, and advanced filters
class DonorSearchBloc extends Bloc<DonorSearchEvent, DonorSearchState> {
  final SearchDonorsByLocationUseCase searchDonorsByLocationUseCase;
  final SearchDonorsByDistrictUseCase searchDonorsByDistrictUseCase;
  final GetNearbyDonorsUseCase getNearbyDonorsUseCase;
  final AdvancedSearchDonorsUseCase advancedSearchDonorsUseCase;

  DonorSearchBloc({
    required this.searchDonorsByLocationUseCase,
    required this.searchDonorsByDistrictUseCase,
    required this.getNearbyDonorsUseCase,
    required this.advancedSearchDonorsUseCase,
  }) : super(const DonorSearchInitial()) {
    on<SearchDonorsByLocationEvent>(_onSearchByLocation);
    on<SearchDonorsByDistrictEvent>(_onSearchByDistrict);
    on<GetNearbyDonorsEvent>(_onGetNearbyDonors);
    on<AdvancedSearchDonorsEvent>(_onAdvancedSearch);
    on<ClearSearchEvent>(_onClearSearch);
  }

  /// Handle search by location (10km radius)
  Future<void> _onSearchByLocation(
    SearchDonorsByLocationEvent event,
    Emitter<DonorSearchState> emit,
  ) async {
    emit(const DonorSearchLoading());

    final result = await searchDonorsByLocationUseCase(
      bloodGroup: event.bloodGroup,
      userLatitude: event.userLatitude,
      userLongitude: event.userLongitude,
      radiusKm: event.radiusKm,
    );

    result.fold(
      (failure) => emit(
        DonorSearchFailure(
          message: 'Failed to search donors: ${failure.toString()}',
          errorCode: 'SEARCH_ERROR',
        ),
      ),
      (donors) {
        if (donors.isEmpty) {
          emit(
            DonorSearchEmpty(
              message:
                  'No donors with blood group ${event.bloodGroup} found within ${event.radiusKm}km.',
            ),
          );
        } else {
          emit(
            DonorSearchSuccess(
              donors: donors,
              totalCount: donors.length,
              searchType: 'location',
            ),
          );
        }
      },
    );
  }

  /// Handle search by district
  Future<void> _onSearchByDistrict(
    SearchDonorsByDistrictEvent event,
    Emitter<DonorSearchState> emit,
  ) async {
    emit(const DonorSearchLoading());

    final result = await searchDonorsByDistrictUseCase(
      bloodGroup: event.bloodGroup,
      district: event.district,
    );

    result.fold(
      (failure) => emit(
        DonorSearchFailure(
          message: 'Failed to search donors: ${failure.toString()}',
          errorCode: 'SEARCH_ERROR',
        ),
      ),
      (donors) {
        if (donors.isEmpty) {
          emit(
            DonorSearchEmpty(
              message:
                  'No donors with blood group ${event.bloodGroup} found in ${event.district}.',
            ),
          );
        } else {
          // Convert Donor to DonorSearchResult for consistent display
          final searchResults = donors
              .map((donor) => DonorSearchResult(
                    donor: donor,
                    distanceKm: 0,
                    isWithinProximity: false,
                  ))
              .toList();

          emit(
            DonorSearchSuccess(
              donors: searchResults,
              totalCount: searchResults.length,
              searchType: 'district',
            ),
          );
        }
      },
    );
  }

  /// Handle get nearby donors
  Future<void> _onGetNearbyDonors(
    GetNearbyDonorsEvent event,
    Emitter<DonorSearchState> emit,
  ) async {
    emit(const DonorSearchLoading());

    final result = await getNearbyDonorsUseCase(
      userLatitude: event.userLatitude,
      userLongitude: event.userLongitude,
      radiusKm: event.radiusKm,
    );

    result.fold(
      (failure) => emit(
        DonorSearchFailure(
          message: 'Failed to fetch nearby donors: ${failure.toString()}',
          errorCode: 'NEARBY_ERROR',
        ),
      ),
      (donors) {
        if (donors.isEmpty) {
          emit(
            DonorSearchEmpty(
              message:
                  'No donors found within ${event.radiusKm}km of your location.',
            ),
          );
        } else {
          emit(
            DonorSearchSuccess(
              donors: donors,
              totalCount: donors.length,
              searchType: 'nearby',
            ),
          );
        }
      },
    );
  }

  /// Handle advanced search with multiple filters
  Future<void> _onAdvancedSearch(
    AdvancedSearchDonorsEvent event,
    Emitter<DonorSearchState> emit,
  ) async {
    emit(const DonorSearchLoading());

    final result = await advancedSearchDonorsUseCase(
      bloodGroup: event.bloodGroup,
      district: event.district,
      userLatitude: event.userLatitude,
      userLongitude: event.userLongitude,
      radiusKm: event.radiusKm,
      availableOnly: event.availableOnly,
    );

    result.fold(
      (failure) => emit(
        DonorSearchFailure(
          message: 'Failed to search donors: ${failure.toString()}',
          errorCode: 'SEARCH_ERROR',
        ),
      ),
      (donors) {
        if (donors.isEmpty) {
          emit(
            DonorSearchEmpty(
              message: 'No donors match your search criteria.',
            ),
          );
        } else {
          emit(
            DonorSearchSuccess(
              donors: donors,
              totalCount: donors.length,
              searchType: 'advanced',
            ),
          );
        }
      },
    );
  }

  /// Handle clear search
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<DonorSearchState> emit,
  ) async {
    emit(const DonorSearchInitial());
  }
}
