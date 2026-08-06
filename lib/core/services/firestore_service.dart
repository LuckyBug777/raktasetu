import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktasetu/domain/models/donor_model.dart';
import 'package:raktasetu/domain/models/blood_request_model.dart';

/// Firestore Database Service
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // ============ PHONE VALIDATION ============

  /// Normalize any phone format to last 10 digits for Firestore comparison.
  String _normalize(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
  }

  /// Returns true if a user with this phone number exists in Firestore.
  /// Checks both 10-digit and +91-prefixed formats.
  Future<bool> checkPhoneExists(String phoneNumber) async {
    final normalized = _normalize(phoneNumber);
    final withCountryCode = '+91$normalized';

    // Check 10-digit format (e.g. "8546954246")
    var result = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: normalized)
        .limit(1)
        .get();
    if (result.docs.isNotEmpty) return true;

    // Also check +91 prefix format (e.g. "+918546954246")
    result = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: withCountryCode)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // ============ DONOR OPERATIONS ============

  // ============ LOCATION SYNC ============

  /// Compares [newLat]/[newLng] to what is stored in Firestore for [uid].
  /// Writes an update only if the user has moved more than ~1 km or the
  /// district string changed. Silent no-op on any error.
  Future<void> updateLocationIfChanged(
    String uid,
    double newLat,
    double newLng,
    String newDistrict,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return;

      final storedLat = (data['latitude'] as num?)?.toDouble();
      final storedLng = (data['longitude'] as num?)?.toDouble();
      final storedDistrict = (data['district'] as String?) ?? '';

      // ~0.009 degrees ≈ 1 km — skip update if within threshold
      if (storedLat != null && storedLng != null) {
        final latDiff = (newLat - storedLat).abs();
        final lngDiff = (newLng - storedLng).abs();
        if (latDiff < 0.009 && lngDiff < 0.009 && storedDistrict == newDistrict) {
          return; // no meaningful change
        }
      }

      final Map<String, dynamic> updates = {
        'latitude': newLat,
        'longitude': newLng,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      };
      // Only overwrite district if geocoding returned a non-empty value
      if (newDistrict.isNotEmpty) updates['district'] = newDistrict;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (_) {
      // Silent fail — location sync is non-critical
    }
  }



  /// Get all donors near a location
  Future<List<DonorModel>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required String bloodGroup,
    required double radiusKm,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('bloodGroup', isEqualTo: bloodGroup)
          //.where('isComplete', isEqualTo: true)
          .get();

      final donors = query.docs.map((doc) {
        final data = doc.data();
        return DonorModel(
          id: doc.id,
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          bloodGroup: data['bloodGroup'] ?? '',
          latitude: data['latitude'] ?? 0,
          longitude: data['longitude'] ?? 0,
          district: data['district'] ?? '',
          lastDonationDate: data['lastDonationDate'] != null
              ? (data['lastDonationDate'] as Timestamp).toDate()
              : null,
          isAvailable: data['isAvailable'] ?? false,
          donations: data['donations'] ?? 0,
          rating: (data['rating'] ?? 0).toDouble(),
        );
      }).toList();

      return donors;
    } catch (e) {
      throw Exception('Failed to fetch donors: $e');
    }
  }

  /// Get donors by district and blood group
  Future<List<DonorModel>> getDonorsByDistrict({
    required String district,
    required String bloodGroup,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('district', isEqualTo: district)
          .where('bloodGroup', isEqualTo: bloodGroup)
          //.where('isComplete', isEqualTo: true)
          .get();

      final donors = query.docs.map((doc) {
        final data = doc.data();
        return DonorModel(
          id: doc.id,
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          bloodGroup: data['bloodGroup'] ?? '',
          latitude: data['latitude'] ?? 0,
          longitude: data['longitude'] ?? 0,
          district: data['district'] ?? '',
          lastDonationDate: data['lastDonationDate'] != null
              ? (data['lastDonationDate'] as Timestamp).toDate()
              : null,
          isAvailable: data['isAvailable'] ?? false,
          donations: data['donations'] ?? 0,
          rating: (data['rating'] ?? 0).toDouble(),
        );
      }).toList();

      return donors;
    } catch (e) {
      throw Exception('Failed to fetch donors by district: $e');
    }
  }

  /// Get donor profile
  Future<DonorModel?> getDonorProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return DonorModel(
        id: doc.id,
        name: data['name'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        bloodGroup: data['bloodGroup'] ?? '',
        latitude: data['latitude'] ?? 0,
        longitude: data['longitude'] ?? 0,
        district: data['district'] ?? '',
        lastDonationDate: data['lastDonationDate'] != null
            ? (data['lastDonationDate'] as Timestamp).toDate()
            : null,
        isAvailable: data['isAvailable'] ?? false,
        donations: data['donations'] ?? 0,
        rating: (data['rating'] ?? 0).toDouble(),
      );
    } catch (e) {
      throw Exception('Failed to fetch donor profile: $e');
    }
  }

  /// Update donor location
  Future<void> updateDonorLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get all registered donors
  Future<List<DonorModel>> getAllDonors() async {
    try {
      final query = await _firestore.collection('users').get();
      final donors = query.docs.map((doc) {
        final data = doc.data();
        return DonorModel(
          id: doc.id,
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          bloodGroup: data['bloodGroup'] ?? '',
          latitude: data['latitude'] ?? 0,
          longitude: data['longitude'] ?? 0,
          district: data['district'] ?? '',
          lastDonationDate: data['lastDonationDate'] != null
              ? (data['lastDonationDate'] as Timestamp).toDate()
              : null,
          isAvailable: data['isAvailable'] ?? true, // Default to true
          donations: data['donations'] ?? 0,
          rating: (data['rating'] ?? 5).toDouble(),
        );
      }).toList();

      return donors;
    } catch (e) {
      throw Exception('Failed to fetch all donors: $e');
    }
  }

  /// Get aggregated app stats
  Future<Map<String, int>> getGlobalAppStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      int activeDonors = usersSnapshot.docs.length;
      int livesSaved = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        int units = data['unitsCollected'] ?? 0;
        int donations = data['donations'] ?? 0;
        // Approximation: 1 unit can save 3 lives
        livesSaved += (units > 0 ? units * 3 : donations * 3);
      }

      return {
        'activeDonors': activeDonors,
        'livesSaved': livesSaved,
      };
    } catch (e) {
      return {'activeDonors': 0, 'livesSaved': 0};
    }
  }

  // ============ BLOOD REQUEST OPERATIONS ============

  /// Create blood request
  Future<String> createBloodRequest({
    required String requesterUid,
    required String patientName,
    required String hospitalName,
    required String bloodGroup,
    required int units,
    required String urgency,
    required String contactNumber,
    required String? notes,
  }) async {
    try {
      final docRef = await _firestore.collection('bloodRequests').add({
        'requesterUid': requesterUid,
        'patientName': patientName,
        'hospitalName': hospitalName,
        'bloodGroup': bloodGroup,
        'units': units,
        'urgency': urgency,
        'contactNumber': contactNumber,
        'notes': notes,
        'status': 'active', // active, fulfilled, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create blood request: $e');
    }
  }

  /// Get active blood requests
  Future<List<BloodRequestModel>> getActiveBloodRequests() async {
    try {
      final query = await _firestore
          .collection('bloodRequests')
          .where('status', isEqualTo: 'active')
          .get();

      final requests = query.docs.map((doc) {
        final data = doc.data();
        return BloodRequestModel(
          id: doc.id,
          requesterUid: data['requesterUid'] ?? '',
          patientName: data['patientName'] ?? '',
          hospitalName: data['hospitalName'] ?? '',
          bloodGroup: data['bloodGroup'] ?? '',
          units: data['units'] ?? 0,
          urgency: data['urgency'] ?? 'Medium',
          contactNumber: data['contactNumber'] ?? '',
          notes: data['notes'],
          status: data['status'] ?? 'active',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();

      // Sort natively in Dart to avoid Firebase requiring a composite index
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests;
    } catch (e) {
      throw Exception('Failed to fetch blood requests: $e');
    }
  }

  // ============ DONATION HISTORY OPERATIONS ============

  /// Add donation record
  Future<void> recordDonation({
    required String uid,
    required String bloodGroup,
    required String location,
    required int units,
  }) async {
    try {
      await _firestore.collection('donations').add({
        'uid': uid,
        'bloodGroup': bloodGroup,
        'location': location,
        'units': units,
        'status': 'completed',
        'donatedAt': FieldValue.serverTimestamp(),
      });

      // Update donor stats
      await _firestore.collection('donors').doc(uid).update({
        'donations': FieldValue.increment(1),
        'lastDonationDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record donation: $e');
    }
  }

  /// Get user donations
  Future<List<Map<String, dynamic>>> getUserDonations(String uid) async {
    try {
      final query = await _firestore
          .collection('donations')
          .where('uid', isEqualTo: uid)
          .orderBy('donatedAt', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch donations: $e');
    }
  }

  // ============ BLOOD BANK OPERATIONS ============

  /// Get all blood banks as a real-time stream
  Stream<List<Map<String, dynamic>>> getBloodBanksStream() {
    return _firestore
        .collection('bloodBanks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {'id': doc.id, ...data};
            }).toList());
  }

  /// Get all blood banks (one-time fetch)
  Future<List<Map<String, dynamic>>> getBloodBanks() async {
    try {
      final query = await _firestore.collection('bloodBanks').get();
      return query.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch blood banks: $e');
    }
  }

  /// Add a new blood bank / hospital entry
  Future<void> addBloodBank({
    required String type,
    required String name,
    required String address,
    required Map<String, int> bloodUnits,
  }) async {
    try {
      await _firestore.collection('bloodBanks').add({
        'type': type,
        'name': name,
        'address': address,
        'aPlus': bloodUnits['A+'] ?? 0,
        'aMinus': bloodUnits['A-'] ?? 0,
        'bPlus': bloodUnits['B+'] ?? 0,
        'bMinus': bloodUnits['B-'] ?? 0,
        'oPlus': bloodUnits['O+'] ?? 0,
        'oMinus': bloodUnits['O-'] ?? 0,
        'abPlus': bloodUnits['AB+'] ?? 0,
        'abMinus': bloodUnits['AB-'] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add blood bank: $e');
    }
  }

  /// Update an existing blood bank / hospital entry
  Future<void> updateBloodBank({
    required String id,
    required String type,
    required String name,
    required String address,
    required Map<String, int> bloodUnits,
  }) async {
    try {
      await _firestore.collection('bloodBanks').doc(id).update({
        'type': type,
        'name': name,
        'address': address,
        'aPlus': bloodUnits['A+'] ?? 0,
        'aMinus': bloodUnits['A-'] ?? 0,
        'bPlus': bloodUnits['B+'] ?? 0,
        'bMinus': bloodUnits['B-'] ?? 0,
        'oPlus': bloodUnits['O+'] ?? 0,
        'oMinus': bloodUnits['O-'] ?? 0,
        'abPlus': bloodUnits['AB+'] ?? 0,
        'abMinus': bloodUnits['AB-'] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update blood bank: $e');
    }
  }

  /// Delete a blood bank / hospital entry
  Future<void> deleteBloodBank(String id) async {
    try {
      await _firestore.collection('bloodBanks').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete blood bank: $e');
    }
  }

  /// Verify admin password against Firestore
  Future<bool> verifyAdminPassword(String uid, String password) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      final storedPassword = data['adminPassword'] as String?;
      return storedPassword != null && storedPassword == password;
    } catch (e) {
      return false;
    }
  }

  // ============ NOTIFICATION OPERATIONS ============

  /// Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'metadata': metadata,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String uid) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}
