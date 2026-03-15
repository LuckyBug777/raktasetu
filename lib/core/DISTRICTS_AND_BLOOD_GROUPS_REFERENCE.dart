// =====================================================================
// KARNATAKA DISTRICTS - Complete List of All 31 Districts
// Use this directly in AppConstants
// =====================================================================

// Final List for app_constants.dart:
const List<String> karnatakaDistricts = [
  'Bidar',
  'Kalaburagi', // Gulbarga
  'Raichur',
  'Yadgir',
  'Belagavi', // Belgaum
  'Bagalkote',
  'Ballari', // Bellary
  'Gadag',
  'Koppal',
  'Vijayanagara',
  'Dharwad',
  'Uttara Kannada',
  'Chikkamagaluru',
  'Shimoga', // Shivamogga
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

// =====================================================================
// DETAILED DISTRICT INFORMATION FOR REFERENCE
// =====================================================================

/*
KARNATAKA DISTRICTS (31 Total) - Organized by Region:

NORTHERN DISTRICTS (5):
1. Bidar - Capital: Bidar
2. Kalaburagi - Capital: Kalaburagi (Gulbarga)
3. Raichur - Capital: Raichur
4. Yadgir - Capital: Yadgir
5. Ballari - Capital: Ballari (Bellary)

WESTERN DISTRICTS (7):
6. Belagavi - Capital: Belagavi (Belgaum)
7. Bagalkote - Capital: Bagalkote
8. Gadag - Capital: Gadag
9. Koppal - Capital: Koppal
10. Dharwad - Capital: Dharwad
11. Uttara Kannada - Capital: Karwar
12. Vijayanagara - Capital: Hospete

SOUTHERN DISTRICTS (8):
13. Chikkamagaluru - Capital: Chikkamagaluru
14. Shimoga (Shivamogga) - Capital: Shimoga
15. Davanagere - Capital: Davanagere
16. Hassan - Capital: Hassan
17. Kodagu - Capital: Madikeri
18. Mysuru - Capital: Mysuru
19. Mandya - Capital: Mandya
20. Chamarajanagar - Capital: Chamarajanagar

COASTAL DISTRICTS (2):
21. Dakshina Kannada - Capital: Mangaluru
22. Udupi - Capital: Udupi

CENTRAL DISTRICTS (6):
23. Chikkaballapur - Capital: Chikkaballapur
24. Kolar - Capital: Kolar
25. Tumkur - Capital: Tumkur
26. Kangra - Capital: Kangra
27. Bengaluru Urban - Capital: Bengaluru
28. Bengaluru Rural - Capital: Bengaluru

SOUTHERN CENTRAL (3):
29. Ramanagara - Capital: Ramanagara
30. Chitradurga - Capital: Chitradurga

*/

// =====================================================================
// USAGE IN DROPDOWN
// =====================================================================

/*
// In DistrictSelector widget:
DropdownButtonFormField<String>(
  value: selectedDistrict,
  items: AppConstants.karnatakaDistricts.map((district) {
    return DropdownMenuItem<String>(
      value: district,
      child: Text(district),
    );
  }).toList(),
  onChanged: onDistrictSelected,
)

// Sorted alphabetically for easy search
*/

// =====================================================================
// BLOOD GROUPS - All 8 Types
// =====================================================================

const List<String> bloodGroups = [
  'A+',  // Most common (35%)
  'A-',  // Rare (7%)
  'B+',  // Common (36%)
  'B-',  // Rare (6%)
  'AB+', // Rarest (3%)
  'AB-', // Rarest (1%)
  'O+',  // Most common (37%)
  'O-',  // Universal Donor (6%)
];

/*
KEY FACTS:
- O+ blood is most common (37% of population)
- O- is universal donor (critical for emergencies)
- AB+ is universal recipient
- AB- is rarest type (1%)
*/
