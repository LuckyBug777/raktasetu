import 'package:get_it/get_it.dart';
import 'package:raktasetu/core/services/firebase_auth_service.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:raktasetu/data/datasources/donor_remote_datasource.dart';
import 'package:raktasetu/data/repositories/donor_repository_impl.dart';
import 'package:raktasetu/domain/repositories/donor_repository.dart';
import 'package:raktasetu/domain/usecases/search_donors_by_location_usecase.dart';
import 'package:raktasetu/domain/usecases/search_donors_by_district_usecase.dart';
import 'package:raktasetu/domain/usecases/get_nearby_donors_usecase.dart';
import 'package:raktasetu/domain/usecases/advanced_search_donors_usecase.dart';
import 'package:raktasetu/presentation/bloc/donor_search_bloc.dart';

final getIt = GetIt.instance;

/// Setup Service Locator & Dependency Injection
void setupServiceLocator() {
  // Firebase Services
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());

  // Data Sources
  getIt.registerSingleton<DonorRemoteDataSource>(DonorRemoteDataSourceImpl());

  // Repositories
  getIt.registerSingleton<DonorRepository>(
    DonorRepositoryImpl(remoteDataSource: getIt<DonorRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<SearchDonorsByLocationUseCase>(
    SearchDonorsByLocationUseCase(repository: getIt<DonorRepository>()),
  );

  getIt.registerSingleton<SearchDonorsByDistrictUseCase>(
    SearchDonorsByDistrictUseCase(repository: getIt<DonorRepository>()),
  );

  getIt.registerSingleton<GetNearbyDonorsUseCase>(
    GetNearbyDonorsUseCase(repository: getIt<DonorRepository>()),
  );

  getIt.registerSingleton<AdvancedSearchDonorsUseCase>(
    AdvancedSearchDonorsUseCase(repository: getIt<DonorRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<DonorSearchBloc>(
    DonorSearchBloc(
      searchDonorsByLocationUseCase: getIt<SearchDonorsByLocationUseCase>(),
      searchDonorsByDistrictUseCase: getIt<SearchDonorsByDistrictUseCase>(),
      getNearbyDonorsUseCase: getIt<GetNearbyDonorsUseCase>(),
      advancedSearchDonorsUseCase: getIt<AdvancedSearchDonorsUseCase>(),
    ),
  );
}
