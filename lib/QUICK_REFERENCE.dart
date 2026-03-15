// =====================================================================
// RAKTASETU - QUICK REFERENCE GUIDE FOR DEVELOPERS
// =====================================================================

/*
SEARCH OPERATIONS:
═══════════════════════════════════════════════════════════════════════

1. SEARCH BY DISTRICT
   ─────────────────
   Event: SearchDonorsByDistrictEvent(
     bloodGroup: 'O+',
     district: 'Bengaluru Urban'
   )
   
   Firestore Query:
   db.collection('donors')
     .where('bloodGroup.group', '==', 'O+')
     .where('district', '==', 'Bengaluru Urban')
     .where('isVisibleInSearch', '==', true)
   
   Result: List of O+ donors in Bengaluru Urban
   Use: When user doesn't want to share location


2. SEARCH BY LOCATION (10KM RADIUS)
   ────────────────────────────────
   Event: SearchDonorsByLocationEvent(
     bloodGroup: 'B+',
     userLatitude: 12.9716,
     userLongitude: 77.5946,
     radiusKm: 10.0
   )
   
   Process:
   1. Fetch all B+ donors from Firestore
   2. For each donor, calculate:
      distance = Haversine(userLat, userLon, donorLat, donorLon)
   3. Keep only donors where distance ≤ 10 km
   4. Sort by distance (ascending)
   
   Result: Sorted list [Donor@4.1km, Donor@5.2km, ...]
   Use: Primary use case - find donors near me


3. FIND NEARBY DONORS (ANY BLOOD GROUP)
   ──────────────────────────────────
   Event: GetNearbyDonorsEvent(
     userLatitude: 12.9716,
     userLongitude: 77.5946,
     radiusKm: 10.0
   )
   
   Process:
   1. Fetch all visible & available donors
   2. Apply proximity filter (Haversine)
   3. Sort by distance
   
   Result: Any blood group within 10km
   Use: Emergency scenario - find nearest donor


4. ADVANCED SEARCH (COMBINED FILTERS)
   ────────────────────────────────
   Event: AdvancedSearchDonorsEvent(
     bloodGroup: 'AB+',
     district: 'Mysuru',
     userLatitude: 12.2958,
     userLongitude: 75.7459,
     radiusKm: 15.0,
     availableOnly: true
   )
   
   Process:
   1. Filter by blood group (if specified)
   2. Filter by district (if specified)
   3. Filter by availability (if specified)
   4. Apply proximity filter (if location given)
   5. Sort results
   
   Result: Filtered list sorted by distance
   Use: Multiple criteria search


BLoC EVENTS:
═══════════════════════════════════════════════════════════════════════

SearchDonorsByLocationEvent
  - bloodGroup: String (required)
  - userLatitude: double (required)
  - userLongitude: double (required)
  - radiusKm: double (default: 10.0)

SearchDonorsByDistrictEvent
  - bloodGroup: String (required)
  - district: String (required)

GetNearbyDonorsEvent
  - userLatitude: double (required)
  - userLongitude: double (required)
  - radiusKm: double (default: 10.0)

AdvancedSearchDonorsEvent
  - bloodGroup: String? (optional)
  - district: String? (optional)
  - userLatitude: double? (optional)
  - userLongitude: double? (optional)
  - radiusKm: double (default: 10.0)
  - availableOnly: bool (default: true)

ClearSearchEvent
  - No parameters


BLoC STATES:
═══════════════════════════════════════════════════════════════════════

DonorSearchInitial
  → Initial state, show search form

DonorSearchLoading
  → Searching in progress, show spinner

DonorSearchSuccess
  - donors: List<DonorSearchResult> (data to display)
  - totalCount: int (number of results)
  - searchType: String ('location', 'district', 'nearby', 'advanced')

DonorSearchEmpty
  - message: String (why no results found)
  → Show empty state widget

DonorSearchFailure
  - message: String (error description)
  - errorCode: String (for logging/debugging)
  → Show error widget with retry


FIRESTORE QUERIES REFERENCE:
═══════════════════════════════════════════════════════════════════════

// Get single blood group in single district
db.collection('donors')
  .where('bloodGroup.group', '==', 'O+')
  .where('district', '==', 'Bengaluru Urban')
  .where('isVisibleInSearch', '==', true)

// Get all visible donors
db.collection('donors')
  .where('isVisibleInSearch', '==', true)

// Sorted by rating
db.collection('donors')
  .where('isVisibleInSearch', '==', true)
  .orderBy('rating', 'desc')
  .limit(20)

// Available only
db.collection('donors')
  .where('nextAvailableDate', '<', Timestamp.now())
  .where('isVisibleInSearch', '==', true)

// With offline persistence
db.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);


HAVERSINE FORMULA QUICK MATH:
═══════════════════════════════════════════════════════════════════════

// Constants
earthRadiusKm = 6371

// Convert degrees to radians
radians = degrees * π / 180

// Calculate distance
dLat = lat2 - lat1 (in radians)
dLon = lon2 - lon1 (in radians)

a = sin²(dLat/2) + cos(lat1) × cos(lat2) × sin²(dLon/2)
c = 2 × atan2(√a, √(1-a))
distance = earthRadiusKm × c

// Example values
Distance(12.9716, 77.5946, 12.9716, 77.6946) = 8.2 km
Distance(12.9716, 77.5946, 12.9716, 77.7946) = 16.5 km


BLOOD GROUP COMPATIBILITY:
═══════════════════════════════════════════════════════════════════════

Donor → Recipient
O+ → All (universal donor)
O- → O-, O+, A-, A+, B-, B+, AB-, AB+ (universal donor)
A+ → A+, AB+
A- → A-, A+, AB-, AB+
B+ → B+, AB+
B- → B-, B+, AB-, AB+
AB+ → AB+ (universal recipient)
AB- → AB-, AB+ (universal recipient)


LOCATION PERMISSIONS:
═══════════════════════════════════════════════════════════════════════

Android (AndroidManifest.xml):
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

iOS (Info.plist):
<key>NSLocationWhenInUseUsageDescription</key>
<string>RaktaSetu needs your location to find nearby blood donors.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>RaktaSetu needs your location to find nearby blood donors.</string>

Runtime (Code):
LocationPermission permission = await Geolocator.requestPermission();


DATA FLOW SUMMARY:
═══════════════════════════════════════════════════════════════════════

User taps "Search by Location"
  ↓
DonorSearchPage.searchByLocation()
  ↓
LocationService.getCurrentLocation()
  ↓
SEND SearchDonorsByLocationEvent to BLoC
  ↓
DonorSearchBloc._onSearchByLocation() handler
  ↓
CALL SearchDonorsByLocationUseCase.call()
  ↓
DonorRepositoryImpl.searchDonorsByLocation()
  ↓
DonorRemoteDataSource.getAllDonors() [Firebase]
  ↓
Filter by blood group & visibility
  ↓
Apply GeolocationUtils.filterDonorsByProximity()
  - For each donor: calculate Haversine distance
  - Keep only: distance ≤ 10 km
  - Sort by distance
  ↓
EMIT DonorSearchSuccess state
  ↓
BLoC rebuilds DonorSearchPage
  ↓
ListView of DonorCard widgets displayed
  ↓
User sees: "Name | O+ | 4.1 km away | Available" (in red design)


DEBUGGING TIPS:
═══════════════════════════════════════════════════════════════════════

1. Check if location is being fetched:
   print('User Location: $latitude, $longitude');

2. Verify Haversine calculation:
   final distance = GeolocationUtils.calculateDistance(...);
   print('Distance: ${distance.toStringAsFixed(2)} km');

3. Check Firestore query results:
   final donors = await remoteDataSource.getAllDonors();
   print('Total donors: ${donors.length}');
   donors.forEach((d) => print('${d.fullName}: ${d.location.latitude}'));

4. Monitor BLoC state changes:
   BlocListener<DonorSearchBloc, DonorSearchState>(
     listener: (context, state) {
       print('BLoC state: ${state.runtimeType}');
     },
   );

5. Firebase Console:
   - Check Collection "donors"
   - Verify document structure
   - Check isVisibleInSearch flag
   - Monitor read/write counts


PERFORMANCE OPTIMIZATION:
═══════════════════════════════════════════════════════════════════════

Current: ~200ms for 1000 donors (acceptable)

If slow (>500ms):
1. Reduce dataset: Add more Firestore filters
2. Use pagination: Load 50 nearest, then more if needed
3. Cache results: SharedPreferences for last search
4. Consider geoflutterfire2: Server-side geo-queries

For 100K+ donors:
- Use MongoDB + PostGIS
- Or: Firebase with Geo-hashing (geoflutterfire2)
- Implement pagination


TESTING CHECKLIST:
═══════════════════════════════════════════════════════════════════════

✓ Location permission granted
✓ Location services enabled
✓ GPS coordinates returning valid values
✓ Haversine formula gives correct distances
✓ 10km radius filters correctly
✓ Results sorted by distance
✓ Distance badges display on UI
✓ Different blood groups filter properly
✓ Different districts show in dropdown
✓ Empty state shows when no results
✓ Error state shows on connection failure
✓ Loading state shows during search
✓ Results display in under 1 second


KEY CODE FILES:
═══════════════════════════════════════════════════════════════════════

Core Logic:
- lib/core/utils/geolocation_utils.dart (Haversine formula)
- lib/domain/usecases/* (Business logic)

UI:
- lib/presentation/pages/donor_search_page.dart (Main page)
- lib/presentation/widgets/donor_card.dart (Donor display)

State:
- lib/presentation/bloc/donor_search_bloc.dart (BLoC logic)
- lib/presentation/bloc/donor_search_state.dart (UI states)

Data:
- lib/data/datasources/donor_remote_datasource.dart (Firebase)
- lib/data/models/ (Data models)
- lib/domain/entities/ (Business models)

*/
