import 'package:equatable/equatable.dart';
import 'blood_group.dart';
import 'location.dart';

/// Donor Entity - Domain Model
class Donor extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final BloodGroup bloodGroup;
  final Location location;
  final String district;
  final bool isVisibleInSearch;
  final DateTime lastDonationDate;
  final DateTime? nextAvailableDate;
  final int totalDonations;
  final double? rating;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Donor({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.location,
    required this.district,
    required this.isVisibleInSearch,
    required this.lastDonationDate,
    this.nextAvailableDate,
    required this.totalDonations,
    this.rating,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if donor is available now
  bool get isAvailableNow {
    return nextAvailableDate == null ||
        DateTime.now().isAfter(nextAvailableDate!);
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    bloodGroup,
    location,
    district,
    isVisibleInSearch,
    lastDonationDate,
    nextAvailableDate,
    totalDonations,
    rating,
    avatar,
    createdAt,
    updatedAt,
  ];
}
