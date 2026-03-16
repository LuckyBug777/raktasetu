/// Karnataka Districts - All 31 Districts
class AppConstants {
  // Location and Geo-constants
  static const double PROXIMITY_RADIUS_KM = 10.0;
  static const double PROXIMITY_RADIUS_METERS = PROXIMITY_RADIUS_KM * 1000;

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Karnataka Districts (All 31 Districts)
  static const List<String> karnatakaDistricts = [
    'Bidar',
    'Kalaburagi',
    'Raichur',
    'Yadgir',
    'Belagavi',
    'Bagalkote',
    'Ballari',
    'Gadag',
    'Koppal',
    'Vijayanagara',
    'Dharwad',
    'Uttara Kannada',
    'Chikkamagaluru',
    'Shimoga',
    'Davanagere',
    'Hassan',
    'Kodagu',
    'Mysuru',
    'Mandya',
    'Chamarajanagar',
    'Dakshina Kannada',
    'Udupi',
    'Chikkaballapur',
    'Kolar',
    'Tumkur',
    'Kangra',
    'Bengaluru Urban',
    'Bengaluru Rural',
    'Ramanagara',
    'Chitradurga',
    'Hassan',
  ];

  // App Colors
  static const String bloodRedHex = '#8B0000';
  static const String softGrayHex = '#F5F5F5';
  static const String whiteHex = '#FFFFFF';

  // API Endpoints (Firebase)
  static const String firebaseProjectId = 'raktasetu';

  // Location Timeout
  static const Duration locationTimeout = Duration(seconds: 30);

  // Error Messages
  static const String locationPermissionDenied = 'Location permission denied';
  static const String locationServicesDisabled =
      'Location services are disabled';
  static const String noDonorsFound = 'No donors found in your area';
}
