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

  // ============ DONOR OPERATIONS ============

  /// Get all donors near a location
  Future<List<DonorModel>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required String bloodGroup,
    required double radiusKm,
  }) async {
    try {
      final query = await _firestore
          .collection('donors')
          .where('bloodGroup', isEqualTo: bloodGroup)
          .where('isAvailable', isEqualTo: true)
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
          .collection('donors')
          .where('district', isEqualTo: district)
          .where('bloodGroup', isEqualTo: bloodGroup)
          .where('isAvailable', isEqualTo: true)
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
      final doc = await _firestore.collection('donors').doc(uid).get();
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
      await _firestore.collection('donors').doc(uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
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
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) {
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

  /// Get all blood banks
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
