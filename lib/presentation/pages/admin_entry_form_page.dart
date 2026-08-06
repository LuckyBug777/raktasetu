import 'package:flutter/material.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

/// Admin Entry Form Page — create or edit a Blood Bank / Hospital entry.
/// Pass an existing entry map via route arguments to enter edit mode.
class AdminEntryFormPage extends StatefulWidget {
  const AdminEntryFormPage({Key? key}) : super(key: key);

  @override
  State<AdminEntryFormPage> createState() => _AdminEntryFormPageState();
}

class _AdminEntryFormPageState extends State<AdminEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Blood unit controllers for each blood type
  final Map<String, TextEditingController> _bloodControllers = {
    'A+': TextEditingController(),
    'A-': TextEditingController(),
    'B+': TextEditingController(),
    'B-': TextEditingController(),
    'O+': TextEditingController(),
    'O-': TextEditingController(),
    'AB+': TextEditingController(),
    'AB-': TextEditingController(),
  };

  String _selectedType = 'Blood Bank';
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _editId;

  static const List<String> _types = ['Blood Bank', 'Hospital'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && !_isEditMode) {
      _isEditMode = true;
      _editId = args['id'] as String?;
      _selectedType = args['type'] as String? ?? 'Blood Bank';
      _nameController.text = args['name'] as String? ?? '';
      _addressController.text = args['address'] as String? ?? '';
      _bloodControllers['A+']!.text = (args['aPlus'] ?? 0).toString();
      _bloodControllers['A-']!.text = (args['aMinus'] ?? 0).toString();
      _bloodControllers['B+']!.text = (args['bPlus'] ?? 0).toString();
      _bloodControllers['B-']!.text = (args['bMinus'] ?? 0).toString();
      _bloodControllers['O+']!.text = (args['oPlus'] ?? 0).toString();
      _bloodControllers['O-']!.text = (args['oMinus'] ?? 0).toString();
      _bloodControllers['AB+']!.text = (args['abPlus'] ?? 0).toString();
      _bloodControllers['AB-']!.text = (args['abMinus'] ?? 0).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    for (final c in _bloodControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> get _bloodUnits => {
        for (final entry in _bloodControllers.entries)
          entry.key: int.tryParse(entry.value.text.trim()) ?? 0,
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = getIt<FirestoreService>();
      if (_isEditMode && _editId != null) {
        await service.updateBloodBank(
          id: _editId!,
          type: _selectedType,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          bloodUnits: _bloodUnits,
        );
      } else {
        await service.addBloodBank(
          type: _selectedType,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          bloodUnits: _bloodUnits,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Entry updated successfully.' : 'Entry added successfully.',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Entry' : 'Add New Entry'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.bloodRed,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: Text(
              _isEditMode ? 'Update' : 'Submit',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppTheme.bloodRed,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Basic Information'),
              const SizedBox(height: 12),

              // Type Dropdown
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category_rounded,
                        color: AppTheme.bloodRed),
                    border: InputBorder.none,
                  ),
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Name field
              _buildCard(
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Apollo Blood Bank',
                    prefixIcon:
                        Icon(Icons.local_hospital_rounded, color: AppTheme.bloodRed),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
              ),
              const SizedBox(height: 12),

              // Address field
              _buildCard(
                child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address / Location',
                    hintText: 'e.g. 123 Main Street, Bangalore',
                    prefixIcon:
                        Icon(Icons.location_on_rounded, color: AppTheme.bloodRed),
                    border: InputBorder.none,
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                ),
              ),
              const SizedBox(height: 24),

              _sectionLabel('Blood Units Available'),
              const SizedBox(height: 12),

              // Blood units grid (2 columns)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
                children: _bloodControllers.entries.map((entry) {
                  return _buildBloodUnitField(entry.key, entry.value);
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bloodRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEditMode
                                  ? Icons.save_rounded
                                  : Icons.add_circle_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isEditMode ? 'Update Entry' : 'Submit Entry',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: child,
    );
  }

  Widget _buildBloodUnitField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.bloodRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.bloodRed.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.bloodRed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  if (int.tryParse(v.trim()) == null) {
                    return 'Invalid';
                  }
                }
                return null;
              },
            ),
          ),
          Text(
            'units',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
