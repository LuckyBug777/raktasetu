/// Clean Architecture Folder Structure Documentation
/// 
/// RaktaSetu - Blood Donation App
/// 
/// ```
/// lib/
/// ├── core/                           # Core functionality & utilities
/// │   ├── constants/
/// │   │   └── app_constants.dart     # App-wide constants (colors, API keys, districts)
/// │   ├── theme/
/// │   │   └── app_theme.dart         # Material 3 Theme (Blood Red #8B0000)
/// │   └── utils/
/// │       ├── geolocation_utils.dart # Haversine formula & proximity filtering
/// │       └── location_service.dart  # GPS & permission handling
/// │
/// ├── data/                           # Data layer (closest to external API/DB)
/// │   ├── datasources/
/// │   │   └── donor_remote_datasource.dart    # Firebase Firestore interface
/// │   ├── models/
/// │   │   ├── donor_model.dart               # Firestore model (GeoLocatable)
/// │   │   ├── location_model.dart
/// │   │   ├── blood_group_model.dart
/// │   │   └── donor_search_result_model.dart
/// │   └── repositories/
/// │       └── donor_repository_impl.dart     # Repository implementation
/// │
/// ├── domain/                         # Business logic layer (independent)
/// │   ├── entities/
/// │   │   ├── donor.dart                    # Domain Donor entity
/// │   │   ├── location.dart
/// │   │   ├── blood_group.dart
/// │   │   └── donor_search_result.dart
/// │   ├── repositories/
/// │   │   └── donor_repository.dart         # Abstract repository interface
/// │   └── usecases/
/// │       ├── search_donors_by_location_usecase.dart
/// │       ├── search_donors_by_district_usecase.dart
/// │       ├── get_nearby_donors_usecase.dart
/// │       └── advanced_search_donors_usecase.dart
/// │
/// ├── presentation/                  # UI layer
/// │   ├── bloc/
/// │   │   ├── donor_search_bloc.dart
/// │   │   ├── donor_search_event.dart
/// │   │   └── donor_search_state.dart
/// │   ├── pages/
/// │   │   ├── donor_search_page.dart
/// │   │   ├── donor_details_page.dart  (TODO)
/// │   │   ├── booking_page.dart        (TODO)
/// │   │   └── profile_page.dart        (TODO)
/// │   └── widgets/
/// │       ├── blood_group_selector.dart
/// │       ├── district_selector.dart
/// │       ├── donor_card.dart
/// │       └── common_widgets.dart
/// │
/// └── main.dart                       # App entry point
/// ```
/// 
/// 
/// ARCHITECTURE BENEFITS:
/// ✓ Clean Separation of Concerns
/// ✓ Testable layers (DI-friendly)
/// ✓ Independent UI/Business Logic
/// ✓ Easy to maintain and scale
/// ✓ Professional production-ready code
/// 
/// 
/// DATA FLOW:
/// 1. UI (Page) → Event (BLoC)
/// 2. BLoC → UseCase
/// 3. UseCase → Repository (abstract)
/// 4. Repository → DataSource (Firebase)
/// 5. Firebase → Models → Entities
/// 6. Entities → BLoC State
/// 7. State → UI (rebuild)
/// 
/// 
/// PROXIMITY FILTERING LOGIC:
/// The Haversine formula calculates great-circle distances between coordinates.
/// All donors are filtered to show only those within 10km radius.
/// Distance calculations use lat/lon from Firestore GeoPoint.
/// 
/// 
/// NEXT STEPS TO IMPLEMENT:
/// 1. Update pubspec.yaml with dependencies:
///    - flutter_bloc
///    - firebase_core, cloud_firestore
///    - geolocator, google_maps_flutter
///    - equatable, dartz
/// 
/// 2. Set up Firebase (pubspec.yaml already has instructions)
/// 
/// 3. Create service locator (GetIt) for dependency injection
/// 
/// 4. Implement DonorRemoteDataSourceImpl with Firestore queries
/// 
/// 5. Create remaining BLoCs for auth, booking, profile
/// 
/// 6. Add Lottie animations for UI polish
/// 
/// 7. Implement Google Maps integration
///
