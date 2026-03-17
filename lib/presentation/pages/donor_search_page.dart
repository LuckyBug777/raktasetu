import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/core/utils/location_service.dart';
import 'package:raktasetu/presentation/bloc/donor_search_bloc.dart';
import 'package:raktasetu/presentation/pages/my_donations_page.dart';
import 'package:raktasetu/presentation/pages/notifications_page.dart';
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
          'RaktaSetu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bloodRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'O+',
                  style: TextStyle(
                    color: AppTheme.bloodRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.bloodRed,
                    AppTheme.bloodRed.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Blood Donors',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search nearby donors or filter by location',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Search Method Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickSearchCard(
                            icon: Icons.location_on,
                            title: 'Nearby',
                            onTap: _findNearbyDonors,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickSearchCard(
                            icon: Icons.my_location,
                            title: '10km Radius',
                            onTap: _searchByLocation,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickSearchCard(
                            icon: Icons.location_city,
                            title: 'Location',
                            onTap: _searchByDistrict,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search Filters Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Blood Group Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Blood Group',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BloodGroupSelector(
                          selectedBloodGroup: _selectedBloodGroup,
                          onBloodGroupSelected: (group) {
                            setState(() => _selectedBloodGroup = group);
                          },
                          bloodGroups: AppConstants.bloodGroups,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // District Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'District',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DistrictSelector(
                          selectedDistrict: _selectedDistrict,
                          onDistrictSelected: (district) {
                            setState(() => _selectedDistrict = district);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _searchByDistrict,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bloodRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Results Header
                  const Text(
                    'Search Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Results Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<DonorSearchBloc, DonorSearchState>(
                bloc: _searchBloc,
                builder: (context, state) {
                  if (state is DonorSearchInitial) {
                    return SizedBox(
                      height: 300,
                      child: custom_widgets.EmptyStateWidget(
                        title: 'Ready to Find Donors?',
                        message:
                            'Select blood group and choose a search method',
                        icon: Icons.search,
                      ),
                    );
                  }

                  if (state is DonorSearchLoading) {
                    return SizedBox(
                      height: 300,
                      child: const custom_widgets.LoadingWidget(),
                    );
                  }

                  if (state is DonorSearchEmpty) {
                    return SizedBox(
                      height: 300,
                      child: custom_widgets.EmptyStateWidget(
                        title: 'No Donors Found',
                        message: state.message,
                        icon: Icons.sentiment_dissatisfied,
                        onRetry: _clearSearch,
                      ),
                    );
                  }

                  if (state is DonorSearchFailure) {
                    return SizedBox(
                      height: 300,
                      child: custom_widgets.ErrorWidget(
                        message: state.message,
                        onRetry: _clearSearch,
                      ),
                    );
                  }

                  if (state is DonorSearchSuccess) {
                    return Column(
                      children: [
                        // Results Summary Card
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.bloodRed.withOpacity(0.1),
                                AppTheme.bloodRed.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.bloodRed.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.totalCount}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.bloodRed,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Donors Found',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.bloodRed,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  state.searchType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Donors List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.donors.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DonorCard(
                                donorResult: state.donors[index],
                                onPressed: () {
                                  // TODO: Navigate to donor details
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Contact: ${state.donors[index].donor.phoneNumber}',
                                      ),
                                      backgroundColor: AppTheme.bloodRed,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build Quick Search Card
  Widget _buildQuickSearchCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyDonationsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
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
