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

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name and Blood Group Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              donor.district,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Blood Group Badge
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bloodRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bloodRed.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      donor.bloodGroup.group,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info Grid
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Distance
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.navigation,
                        label:
                            '${donorResult.distanceKm.toStringAsFixed(1)} km',
                        color: AppTheme.bloodRed,
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    // Donations
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.favorite,
                        label: '${donor.totalDonations}x',
                        color: Colors.pink,
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    // Rating
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.star,
                        label: donor.rating != null
                            ? donor.rating!.toStringAsFixed(1)
                            : 'N/A',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Availability Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: donor.isAvailableNow
                                    ? AppTheme.successGreen
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              donor.isAvailableNow
                                  ? 'Available Now'
                                  : 'Not Available',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: donor.isAvailableNow
                                    ? AppTheme.successGreen
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bloodRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info item
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
