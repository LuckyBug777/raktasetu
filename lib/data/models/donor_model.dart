import 'package:raktasetu/domain/entities/donor.dart';
import 'package:raktasetu/core\utils\geolocation_utils.dart';
import 'blood_group_model.dart';
import 'location_model.dart';

/// Donor Model - Data Layer
class DonorModel extends Donor implements GeoLocatable {
  const DonorModel({
    required String id,
    required String fullName,
    required String phoneNumber,
    required BloodGroupModel bloodGroup,
    required LocationModel location,
    required String district,
    required bool isVisibleInSearch,
    required DateTime lastDonationDate,
    DateTime? nextAvailableDate,
    required int totalDonations,
    double? rating,
    String? avatar,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    fullName: fullName,
    phoneNumber: phoneNumber,
    bloodGroup: bloodGroup,
    location: location,
    district: district,
    isVisibleInSearch: isVisibleInSearch,
    lastDonationDate: lastDonationDate,
    nextAvailableDate: nextAvailableDate,
    totalDonations: totalDonations,
    rating: rating,
    avatar: avatar,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  double get latitude => (location as LocationModel).latitude;

  @override
  double get longitude => (location as LocationModel).longitude;

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      bloodGroup: BloodGroupModel.fromJson(json['bloodGroup'] as Map<String, dynamic>),
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      district: json['district'] as String,
      isVisibleInSearch: json['isVisibleInSearch'] as bool? ?? true,
      lastDonationDate: DateTime.parse(json['lastDonationDate'] as String),
      nextAvailableDate: json['nextAvailableDate'] != null
          ? DateTime.parse(json['nextAvailableDate'] as String)
          : null,
      totalDonations: json['totalDonations'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory DonorModel.fromEntity(Donor donor) {
    return DonorModel(
      id: donor.id,
      fullName: donor.fullName,
      phoneNumber: donor.phoneNumber,
      bloodGroup: BloodGroupModel.fromEntity(donor.bloodGroup),
      location: LocationModel.fromEntity(donor.location),
      district: donor.district,
      isVisibleInSearch: donor.isVisibleInSearch,
      lastDonationDate: donor.lastDonationDate,
      nextAvailableDate: donor.nextAvailableDate,
      totalDonations: donor.totalDonations,
      rating: donor.rating,
      avatar: donor.avatar,
      createdAt: donor.createdAt,
      updatedAt: donor.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'bloodGroup': (bloodGroup as BloodGroupModel).toJson(),
      'location': (location as LocationModel).toJson(),
      'district': district,
      'isVisibleInSearch': isVisibleInSearch,
      'lastDonationDate': lastDonationDate.toIso8601String(),
      'nextAvailableDate': nextAvailableDate?.toIso8601String(),
      'totalDonations': totalDonations,
      'rating': rating,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
