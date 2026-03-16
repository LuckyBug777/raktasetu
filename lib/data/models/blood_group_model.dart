import 'package:raktasetu/domain/entities/blood_group.dart';

/// Blood Group Model - Data Layer
class BloodGroupModel extends BloodGroup {
  const BloodGroupModel({
    required String group,
    required bool isPositive,
    required String primaryAbo,
  }) : super(group: group, isPositive: isPositive, primaryAbo: primaryAbo);

  factory BloodGroupModel.fromJson(Map<String, dynamic> json) {
    return BloodGroupModel(
      group: json['group'] as String,
      isPositive: json['isPositive'] as bool,
      primaryAbo: json['primaryAbo'] as String,
    );
  }

  factory BloodGroupModel.fromString(String group) {
    final isPositive = group.endsWith('+');
    final primaryAbo = group.replaceAll(RegExp(r'[+-]'), '');

    return BloodGroupModel(
      group: group,
      isPositive: isPositive,
      primaryAbo: primaryAbo,
    );
  }

  factory BloodGroupModel.fromEntity(BloodGroup bloodGroup) {
    return BloodGroupModel(
      group: bloodGroup.group,
      isPositive: bloodGroup.isPositive,
      primaryAbo: bloodGroup.primaryAbo,
    );
  }

  Map<String, dynamic> toJson() {
    return {'group': group, 'isPositive': isPositive, 'primaryAbo': primaryAbo};
  }
}
