class BloodRequestModel {
  final String id;
  final String requesterUid;
  final String patientName;
  final String hospitalName;
  final String bloodGroup;
  final int units;
  final String urgency;
  final String contactNumber;
  final String? notes;
  final String status;
  final DateTime createdAt;

  BloodRequestModel({
    required this.id,
    required this.requesterUid,
    required this.patientName,
    required this.hospitalName,
    required this.bloodGroup,
    required this.units,
    required this.urgency,
    required this.contactNumber,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] ?? '',
      requesterUid: json['requesterUid'] ?? '',
      patientName: json['patientName'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      units: json['units'] ?? 0,
      urgency: json['urgency'] ?? 'Medium',
      contactNumber: json['contactNumber'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterUid': requesterUid,
      'patientName': patientName,
      'hospitalName': hospitalName,
      'bloodGroup': bloodGroup,
      'units': units,
      'urgency': urgency,
      'contactNumber': contactNumber,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
