import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/domain/entities/donor_search_result.dart';

/// Donor Card Widget - Professional UI for displaying donor information
class DonorCard extends StatelessWidget {
  final DonorSearchResult donorResult;
  final VoidCallback onPressed;

  const DonorCard({
    Key? key,
    required this.donorResult,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final donor = donorResult.donor;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Blood Group
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donor.district,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bloodRed,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      donor.bloodGroup.group,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Distance and Availability
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, 
                        color: AppTheme.bloodRed, 
                        size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${donorResult.distanceKm.toStringAsFixed(2)} km away',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: donor.isAvailableNow
                          ? AppTheme.successGreen.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      donor.isAvailableNow ? 'Available' : 'Not Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: donor.isAvailableNow
                            ? AppTheme.successGreen
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Additional Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, 
                        color: AppTheme.bloodRed, 
                        size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${donor.totalDonations} donations',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  if (donor.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, 
                          color: Colors.amber, 
                          size: 18),
                        const SizedBox(width: 4),
                        Text(
                          donor.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
