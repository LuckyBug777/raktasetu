import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

/// Blood Group Selection Widget
class BloodGroupSelector extends StatelessWidget {
  final String? selectedBloodGroup;
  final Function(String) onBloodGroupSelected;
  final List<String> bloodGroups;

  const BloodGroupSelector({
    Key? key,
    required this.selectedBloodGroup,
    required this.onBloodGroupSelected,
    required this.bloodGroups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Select Blood Group',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bloodGroups.map((group) {
            final isSelected = selectedBloodGroup == group;
            return FilterChip(
              label: Text(group),
              selected: isSelected,
              onSelected: (_) => onBloodGroupSelected(group),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.bloodRed,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
