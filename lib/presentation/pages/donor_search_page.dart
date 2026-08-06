import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/constants/app_constants.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/core/utils/location_service.dart';
import 'package:raktasetu/presentation/bloc/donor_search_bloc.dart';
import 'package:raktasetu/presentation/bloc/auth_bloc.dart';
import 'package:raktasetu/presentation/pages/notifications_page.dart';
import 'package:raktasetu/presentation/pages/profile_page.dart';
import 'package:raktasetu/presentation/widgets/blood_group_selector.dart';
import 'package:raktasetu/presentation/widgets/district_selector.dart';
import 'package:raktasetu/presentation/widgets/donor_card.dart';
import 'package:raktasetu/presentation/widgets/common_widgets.dart'
    as custom_widgets;
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Donor Search Page - Main UI for searching donors
class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({Key? key}) : super(key: key);

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  late DonorSearchBloc _searchBloc;
  final ScrollController _scrollController = ScrollController();

  String? _selectedBloodGroup;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<DonorSearchBloc>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToResults() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
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
    final serviceEnabled = await LocationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location Disabled'),
          content: const Text(
            'Please enable location services on your device to find nearby donors.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                LocationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final location = await LocationService.getCurrentLocation();

      _searchBloc.add(
        GetNearbyDonorsEvent(
          userLatitude: location.latitude,
          userLongitude: location.longitude,
          radiusKm: AppConstants.PROXIMITY_RADIUS_KM,
        ),
      );
      _scrollToResults();
    } catch (e) {
      if (!mounted) return;
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
        controller: _scrollController,
        child: Column(
          children: [
            // Premium Header Section with Hero Impact
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.bloodRed,
                    AppTheme.bloodRed.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.bloodRed.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Stats Banner
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('isAvailable', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String activeDonorsStr = "0";
                        if (snapshot.hasData) {
                          activeDonorsStr = snapshot.data!.docs.length
                              .toString();
                        }

                        return FutureBuilder<Map<String, int>>(
                          future: getIt<FirestoreService>().getGlobalAppStats(),
                          builder: (context, statsSnapshot) {
                            String livesSavedStr = "0";
                            if (statsSnapshot.hasData) {
                              livesSavedStr = statsSnapshot.data!['livesSaved']
                                  .toString();
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot.connectionState ==
                                                ConnectionState.waiting
                                            ? '...'
                                            : activeDonorsStr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Active Donors',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Save Lives Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search donors or request blood instantly',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                  // Featured Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeaturedActionCard(
                          icon: Icons.emergency,
                          title: 'Request Blood',
                          subtitle: 'Post urgent need',
                          color: const Color(0xFFDC3545),
                          onTap: () {
                            Navigator.pushNamed(context, '/request-blood');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeaturedActionCard(
                          icon: Icons.local_hospital,
                          title: 'Find Banks',
                          subtitle: 'Locate nearby',
                          color: const Color(0xFF0D6EFD),
                          onTap: () {
                            Navigator.pushNamed(context, '/blood-banks');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeaturedActionCard(
                          icon: Icons.assignment_turned_in,
                          title: 'Check Eligible',
                          subtitle: 'Can you donate?',
                          color: const Color(0xFF198754),
                          onTap: () {
                            Navigator.pushNamed(context, '/eligibility');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

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
                            foregroundColor: Colors.white,
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

  /// Build Featured Action Card
  Widget _buildFeaturedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = 'John Doe';
              String phone = '+91 98765 43210';

              if (state is AuthSuccess) {
                final data = state.userData;
                if (data != null) {
                  name = data['name'] ?? 'No Name';
                  phone = data['phoneNumber'] ?? 'No Phone';
                }
              }

              return DrawerHeader(
                decoration: BoxDecoration(color: AppTheme.bloodRed),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
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
          // Admin Panel — only visible when isAdmin == true in Firestore
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseAuth.instance.currentUser != null
                ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              if (data?['isAdmin'] != true) return const SizedBox.shrink();
              return Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.bloodRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppTheme.bloodRed,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: AppTheme.bloodRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Manage blood banks & hospitals',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin-verify');
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about-us');
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
