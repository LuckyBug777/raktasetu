class DonorModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String bloodGroup;
  final double latitude;
  final double longitude;
  final String district;
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final int donations;
  final double rating;

  DonorModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.latitude,
    required this.longitude,
    required this.district,
    this.lastDonationDate,
    required this.isAvailable,
    required this.donations,
    required this.rating,
  });

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      district: json['district'] ?? '',
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.parse(json['lastDonationDate'])
          : null,
      isAvailable: json['isAvailable'] ?? false,
      donations: json['donations'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'bloodGroup': bloodGroup,
      'latitude': latitude,
      'longitude': longitude,
      'district': district,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
      'isAvailable': isAvailable,
      'donations': donations,
      'rating': rating,
    };
  }
}
