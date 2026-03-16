part of 'donor_search_bloc.dart';

/// States for Donor Search BLoC
abstract class DonorSearchState extends Equatable {
  const DonorSearchState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class DonorSearchInitial extends DonorSearchState {
  const DonorSearchInitial();
}

/// Loading State
class DonorSearchLoading extends DonorSearchState {
  const DonorSearchLoading();
}

/// Success State - Displays search results
class DonorSearchSuccess extends DonorSearchState {
  final List<DonorSearchResult> donors;
  final int totalCount;
  final String searchType; // 'location', 'district', 'nearby', 'advanced'

  const DonorSearchSuccess({
    required this.donors,
    required this.totalCount,
    required this.searchType,
  });

  @override
  List<Object?> get props => [donors, totalCount, searchType];
}

/// Failure State
class DonorSearchFailure extends DonorSearchState {
  final String message;
  final String errorCode;

  const DonorSearchFailure({required this.message, required this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Empty State - No donors found
class DonorSearchEmpty extends DonorSearchState {
  final String message;

  const DonorSearchEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}
