import 'package:equatable/equatable.dart';

/// Blood Group Entity
class BloodGroup extends Equatable {
  final String group; // A+, A-, B+, B-, AB+, AB-, O+, O-
  final bool isPositive;
  final String primaryAbo; // A, B, AB, O

  const BloodGroup({
    required this.group,
    required this.isPositive,
    required this.primaryAbo,
  });

  factory BloodGroup.fromString(String group) {
    final isPositive = group.endsWith('+');
    final primaryAbo = group.replaceAll(RegExp(r'[+-]'), '');
    
    return BloodGroup(
      group: group,
      isPositive: isPositive,
      primaryAbo: primaryAbo,
    );
  }

  @override
  List<Object?> get props => [group, isPositive, primaryAbo];
}