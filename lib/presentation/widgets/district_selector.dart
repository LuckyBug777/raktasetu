import 'package:flutter/material.dart';
import 'package:raktasetu/core/constants/app_constants.dart';

/// District Selector Dropdown
class DistrictSelector extends StatelessWidget {
  final String? selectedDistrict;
  final Function(String?) onDistrictSelected;

  const DistrictSelector({
    Key? key,
    required this.selectedDistrict,
    required this.onDistrictSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Select District',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedDistrict,
          onChanged: onDistrictSelected,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.location_city),
          ),
          items: AppConstants.karnatakaDistricts.map((district) {
            return DropdownMenuItem<String>(
              value: district,
              child: Text(district),
            );
          }).toList(),
          hint: const Text('Choose a district'),
        ),
      ],
    );
  }
}
