import 'package:raktasetu/data/models/donor_model.dart';
import 'package:raktasetu/data/models/blood_group_model.dart';
import 'package:raktasetu/data/models/location_model.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firestore_service.dart';

/// Abstract Data Source for Donor Remote Operations
abstract class DonorRemoteDataSource {
  /// Fetch donors from Firebase by blood group and district
  Future<List<DonorModel>> searchDonorsByDistrict({
    required String bloodGroup,
    required String district,
  });

  /// Fetch all donors from Firebase
  Future<List<DonorModel>> getAllDonors();

  /// Fetch single donor by ID
  Future<DonorModel> getDonorById(String donorId);
}

/// Donor Remote Data Source Implementation (Firebase Firestore)
class DonorRemoteDataSourceImpl implements DonorRemoteDataSource {
  
  FirestoreService get _firestoreService => getIt<FirestoreService>();

  @override
  Future<List<DonorModel>> searchDonorsByDistrict({
    required String bloodGroup,
    required String district,
  }) async {
    try {
      final domainDonors = await _firestoreService.getDonorsByDistrict(
        district: district,
        bloodGroup: bloodGroup,
      );
      
      // Convert domain DonorModel to data DonorModel
      return domainDonors.map((d) => DonorModel(
        id: d.id,
        fullName: d.name,
        phoneNumber: d.phoneNumber,
        bloodGroup: BloodGroupModel.fromString(d.bloodGroup),
        location: LocationModel(latitude: d.latitude, longitude: d.longitude, district: d.district),
        district: d.district,
        lastDonationDate: d.lastDonationDate ?? DateTime.now().subtract(const Duration(days: 365)),
        isVisibleInSearch: d.isAvailable,
        totalDonations: d.donations,
        rating: d.rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      throw Exception('Failed to search donors: $e');
    }
  }

  @override
  Future<List<DonorModel>> getAllDonors() async {
    try {
      final domainDonors = await _firestoreService.getAllDonors();
      
      // Convert domain DonorModel to data DonorModel
      return domainDonors.map((d) => DonorModel(
        id: d.id,
        fullName: d.name,
        phoneNumber: d.phoneNumber,
        bloodGroup: BloodGroupModel.fromString(d.bloodGroup),
        location: LocationModel(latitude: d.latitude, longitude: d.longitude, district: d.district),
        district: d.district,
        lastDonationDate: d.lastDonationDate ?? DateTime.now().subtract(const Duration(days: 365)),
        isVisibleInSearch: d.isAvailable,
        totalDonations: d.donations,
        rating: d.rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch donors: $e');
    }
  }

  @override
  Future<DonorModel> getDonorById(String donorId) async {
    try {
      final d = await _firestoreService.getDonorProfile(donorId);
      if (d == null) throw Exception('Donor not found');
      
      return DonorModel(
        id: d.id,
        fullName: d.name,
        phoneNumber: d.phoneNumber,
        bloodGroup: BloodGroupModel.fromString(d.bloodGroup),
        location: LocationModel(latitude: d.latitude, longitude: d.longitude, district: d.district),
        district: d.district,
        lastDonationDate: d.lastDonationDate ?? DateTime.now().subtract(const Duration(days: 365)),
        isVisibleInSearch: d.isAvailable,
        totalDonations: d.donations,
        rating: d.rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch donor: $e');
    }
  }
}

