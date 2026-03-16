import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/core/utils/location_service.dart';
import 'package:raktasetu/presentation/bloc/donor_search_bloc.dart';
import 'package:raktasetu/presentation/pages/profile_page.dart';
import 'package:raktasetu/presentation/widgets/blood_group_selector.dart';
import 'package:raktasetu/presentation/widgets/district_selector.dart';
import 'package:raktasetu/presentation/widgets/donor_card.dart';
import 'package:raktasetu/presentation/widgets/common_widgets.dart'
    as custom_widgets;

/// Donor Search Page - Main UI for searching donors
class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({Key? key}) : super(key: key);

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  late DonorSearchBloc _searchBloc;

  String? _selectedBloodGroup;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<DonorSearchBloc>();
  }

  /// Search by District
  void _searchByDistrict() {
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a district')));
      return;
    }

    _searchBloc.add(
      SearchDonorsByDistrictEvent(
        bloodGroup: _selectedBloodGroup!,
        district: _selectedDistrict!,
      ),
    );
  }

  /// Search by Current Location (10km radius)
  void _searchByLocation() async {
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    try {
      final location = await LocationService.getCurrentLocation();

      _searchBloc.add(
        SearchDonorsByLocationEvent(
          bloodGroup: _selectedBloodGroup!,
          userLatitude: location.latitude,
          userLongitude: location.longitude,
          radiusKm: AppConstants.PROXIMITY_RADIUS_KM,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location error: $e')));
    }
  }

  /// Find Nearby Donors (all blood groups)
  void _findNearbyDonors() async {
    try {
      final location = await LocationService.getCurrentLocation();

      _searchBloc.add(
        GetNearbyDonorsEvent(
          userLatitude: location.latitude,
          userLongitude: location.longitude,
          radiusKm: AppConstants.PROXIMITY_RADIUS_KM,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location error: $e')));
    }
  }

  /// Clear search
  void _clearSearch() {
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
    });
    _searchBloc.add(const ClearSearchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Blood Donors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Criteria Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BloodGroupSelector(
                        selectedBloodGroup: _selectedBloodGroup,
                        onBloodGroupSelected: (group) {
                          setState(() => _selectedBloodGroup = group);
                        },
                        bloodGroups: AppConstants.bloodGroups,
                      ),
                      const SizedBox(height: 20),
                      DistrictSelector(
                        selectedDistrict: _selectedDistrict,
                        onDistrictSelected: (district) {
                          setState(() => _selectedDistrict = district);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Search Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _searchByDistrict,
                              icon: const Icon(Icons.search),
                              label: const Text('Search by District'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _searchByLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              icon: const Icon(Icons.location_on),
                              label: const Text('Search by Location (10km)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _findNearbyDonors,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                              ),
                              icon: const Icon(Icons.near_me),
                              label: const Text('Find Nearby (All Types)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search Results Section
              const Text(
                'Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              BlocBuilder<DonorSearchBloc, DonorSearchState>(
                bloc: _searchBloc,
                builder: (context, state) {
                  if (state is DonorSearchInitial) {
                    return custom_widgets.EmptyStateWidget(
                      title: 'Start Searching',
                      message:
                          'Select blood group and search method to find donors',
                      icon: Icons.search,
                    );
                  }

                  if (state is DonorSearchLoading) {
                    return const custom_widgets.LoadingWidget();
                  }

                  if (state is DonorSearchEmpty) {
                    return custom_widgets.EmptyStateWidget(
                      title: 'No Donors Found',
                      message: state.message,
                      icon: Icons.sentiment_dissatisfied,
                      onRetry: _clearSearch,
                    );
                  }

                  if (state is DonorSearchFailure) {
                    return custom_widgets.ErrorWidget(
                      message: state.message,
                      onRetry: _clearSearch,
                    );
                  }

                  if (state is DonorSearchSuccess) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Found ${state.totalCount} donor(s)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  state.searchType.toUpperCase(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: AppTheme.bloodRed.withOpacity(
                                  0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.donors.length,
                          itemBuilder: (context, index) {
                            return DonorCard(
                              donorResult: state.donors[index],
                              onPressed: () {
                                // TODO: Navigate to donor details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Contact: ${state.donors[index].donor.phoneNumber}',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Navigation Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.bloodRed),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+91 98765 43210',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Find Donors'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My Donations'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('RaktaSetu v1.0.0 - Blood Donation Network'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
