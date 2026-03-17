import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

/// Blood Bank Model
class BloodBank {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String distance; // in km
  final double rating;
  final List<String> availableBloodGroups;
  final bool isOpen;
  final String openHours;

  BloodBank({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.distance,
    required this.rating,
    required this.availableBloodGroups,
    required this.isOpen,
    required this.openHours,
  });
}

/// Blood Bank Locator Page
class BloodBankLocatorPage extends StatefulWidget {
  const BloodBankLocatorPage({Key? key}) : super(key: key);

  @override
  State<BloodBankLocatorPage> createState() => _BloodBankLocatorPageState();
}

class _BloodBankLocatorPageState extends State<BloodBankLocatorPage> {
  late List<BloodBank> _banks;
  late List<BloodBank> _filteredBanks;
  String _searchQuery = '';
  String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    _initializeBanks();
  }

  void _initializeBanks() {
    _banks = [
      BloodBank(
        id: '1',
        name: 'Apollo Blood Bank',
        address: 'Apollo Hospital, Koramangala, Bangalore',
        phone: '+91 80 4006 6666',
        distance: '1.2 km',
        rating: 4.8,
        availableBloodGroups: [
          'O+',
          'O-',
          'A+',
          'A-',
          'B+',
          'B-',
          'AB+',
          'AB-',
        ],
        isOpen: true,
        openHours: '6:00 AM - 10:00 PM',
      ),
      BloodBank(
        id: '2',
        name: 'St. Martha\'s Blood Center',
        address: '1st Block, Jayanagar, Bangalore',
        phone: '+91 80 4120 3333',
        distance: '2.5 km',
        rating: 4.6,
        availableBloodGroups: ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-'],
        isOpen: true,
        openHours: '7:00 AM - 9:00 PM',
      ),
      BloodBank(
        id: '3',
        name: 'Red Cross Blood Bank',
        address: 'White Field Road, Bangalore',
        phone: '+91 80 2840 7777',
        distance: '4.8 km',
        rating: 4.5,
        availableBloodGroups: ['O+', 'A+', 'B+', 'AB+'],
        isOpen: false,
        openHours: '9:00 AM - 6:00 PM',
      ),
      BloodBank(
        id: '4',
        name: 'Fortis Blood Bank',
        address: 'Bannerghatta Road, Bangalore',
        phone: '+91 80 6773 5000',
        distance: '6.2 km',
        rating: 4.7,
        availableBloodGroups: [
          'O+',
          'O-',
          'A+',
          'A-',
          'B+',
          'B-',
          'AB+',
          'AB-',
        ],
        isOpen: true,
        openHours: '6:00 AM - 11:00 PM',
      ),
      BloodBank(
        id: '5',
        name: 'Manipal Blood Bank',
        address: 'Old Airport Road, Bangalore',
        phone: '+91 80 4277 0000',
        distance: '7.3 km',
        rating: 4.4,
        availableBloodGroups: ['O+', 'A+', 'B+', 'AB+', 'O-', 'B-'],
        isOpen: true,
        openHours: '7:00 AM - 8:00 PM',
      ),
    ];
    _filteredBanks = _banks;
  }

  void _filterBanks() {
    _filteredBanks = _banks.where((bank) {
      final matchesSearch =
          bank.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bank.address.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesBloodGroup =
          _selectedBloodGroup == null ||
          bank.availableBloodGroups.contains(_selectedBloodGroup);

      return matchesSearch && matchesBloodGroup;
    }).toList();

    // Sort by distance
    _filteredBanks.sort((a, b) {
      final aDistance = double.parse(a.distance.split(' ')[0]);
      final bDistance = double.parse(b.distance.split(' ')[0]);
      return aDistance.compareTo(bDistance);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Banks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Blood Banks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Locate nearby blood banks with stock availability',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterBanks();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search bank name or location...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blood Group Filter
                  const Text(
                    'Filter by Blood Group',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildBloodGroupChip(null, 'All'),
                        const SizedBox(width: 8),
                        ...['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']
                            .map((group) => _buildBloodGroupChip(group, group))
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Results Count
                  Text(
                    '${_filteredBanks.length} blood banks found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blood Banks List
                  _filteredBanks.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.location_off_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No blood banks found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search filters',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        )
                      : Column(
                          children: List.generate(
                            _filteredBanks.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBloodBankCard(_filteredBanks[index]),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGroupChip(String? value, String label) {
    final isSelected = _selectedBloodGroup == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBloodGroup = isSelected ? null : value;
          _filterBanks();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bloodRed : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.bloodRed : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodBankCard(BloodBank bank) {
    return Container(
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
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.bloodRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: AppTheme.bloodRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bank.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bank.isOpen
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bank.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: bank.isOpen ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          bank.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bank.distance,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bank.address,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Opening Hours
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                bank.openHours,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Available Blood Groups
          Wrap(
            spacing: 8,
            children: bank.availableBloodGroups.map((group) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bloodRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.bloodRed.withOpacity(0.3)),
                ),
                child: Text(
                  group,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.bloodRed,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${bank.phone}...'),
                        backgroundColor: AppTheme.bloodRed,
                      ),
                    );
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bloodRed,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening directions for ${bank.name}...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
