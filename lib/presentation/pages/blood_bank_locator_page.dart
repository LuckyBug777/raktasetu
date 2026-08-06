import 'package:flutter/material.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

/// Blood Bank / Hospital data model (sourced from Firestore)
class BloodBank {
  final String id;
  final String name;
  final String address;
  final String type;
  final Map<String, int> bloodUnits; // e.g. {'A+': 5, 'O-': 0 ...}

  BloodBank({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.bloodUnits,
  });

  /// Blood groups that have at least 1 unit available
  List<String> get availableBloodGroups => bloodUnits.entries
      .where((e) => e.value > 0)
      .map((e) => e.key)
      .toList();

  /// Build from Firestore document map
  factory BloodBank.fromMap(Map<String, dynamic> map) {
    return BloodBank(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      type: map['type'] as String? ?? 'Blood Bank',
      bloodUnits: {
        'A+': (map['aPlus'] as num?)?.toInt() ?? 0,
        'A-': (map['aMinus'] as num?)?.toInt() ?? 0,
        'B+': (map['bPlus'] as num?)?.toInt() ?? 0,
        'B-': (map['bMinus'] as num?)?.toInt() ?? 0,
        'O+': (map['oPlus'] as num?)?.toInt() ?? 0,
        'O-': (map['oMinus'] as num?)?.toInt() ?? 0,
        'AB+': (map['abPlus'] as num?)?.toInt() ?? 0,
        'AB-': (map['abMinus'] as num?)?.toInt() ?? 0,
      },
    );
  }
}

/// Blood Bank Locator Page — real-time data sourced from Firestore admin entries.
class BloodBankLocatorPage extends StatefulWidget {
  const BloodBankLocatorPage({Key? key}) : super(key: key);

  @override
  State<BloodBankLocatorPage> createState() => _BloodBankLocatorPageState();
}

class _BloodBankLocatorPageState extends State<BloodBankLocatorPage> {
  String _searchQuery = '';
  String? _selectedBloodGroup;
  String? _selectedType; // null = All, 'Blood Bank', 'Hospital'

  List<BloodBank> _applyFilters(List<BloodBank> banks) {
    return banks.where((bank) {
      final matchesSearch =
          bank.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bank.address.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesBloodGroup = _selectedBloodGroup == null ||
          bank.availableBloodGroups.contains(_selectedBloodGroup);

      final matchesType =
          _selectedType == null || bank.type == _selectedType;

      return matchesSearch && matchesBloodGroup && matchesType;
    }).toList();
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getIt<FirestoreService>().getBloodBanksStream(),
        builder: (context, snapshot) {
          final allBanks = (snapshot.data ?? [])
              .map((m) => BloodBank.fromMap(m))
              .toList();
          final filtered = _applyFilters(allBanks);

          return SingleChildScrollView(
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
                          'Locate nearby blood banks & hospitals with stock availability',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 2,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
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

                      // Type Filter chips
                      Row(
                        children: [
                          _buildTypeChip(null, 'All'),
                          const SizedBox(width: 8),
                          _buildTypeChip('Blood Bank', 'Blood Banks'),
                          const SizedBox(width: 8),
                          _buildTypeChip('Hospital', 'Hospitals'),
                        ],
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
                            ...[
                              'O+',
                              'O-',
                              'A+',
                              'A-',
                              'B+',
                              'B-',
                              'AB+',
                              'AB-',
                            ]
                                .map((group) =>
                                    _buildBloodGroupChip(group, group))
                                .toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Results Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'} found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (snapshot.hasError)
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 14, color: Colors.orange[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Load error',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[600],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Results list
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          allBanks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (filtered.isEmpty)
                        Center(
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
                                allBanks.isEmpty
                                    ? 'No blood banks added yet'
                                    : 'No results match your filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                allBanks.isEmpty
                                    ? 'The admin hasn\'t added any entries yet.'
                                    : 'Try adjusting your search filters',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: List.generate(
                            filtered.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBloodBankCard(filtered[index]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(String? value, String label) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(
          () => _selectedType = isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildBloodGroupChip(String? value, String label) {
    final isSelected = _selectedBloodGroup == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBloodGroup = isSelected ? null : value;
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
    final isHospital = bank.type == 'Hospital';
    final typeColor =
        isHospital ? const Color(0xFF0D6EFD) : AppTheme.bloodRed;

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
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHospital
                      ? Icons.local_hospital_rounded
                      : Icons.bloodtype_rounded,
                  color: typeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        bank.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address
          if (bank.address.isNotEmpty)
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

          // Available Blood Groups
          if (bank.availableBloodGroups.isNotEmpty) ...[
            Text(
              'Available Blood Groups',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: bank.availableBloodGroups.map((group) {
                final units = bank.bloodUnits[group] ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bloodRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: AppTheme.bloodRed.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$group ($units units)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.bloodRed,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            Text(
              'No blood units currently available',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}
