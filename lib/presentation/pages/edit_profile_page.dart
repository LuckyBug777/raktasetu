import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firebase_auth_service.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _bloodGroup;
  late String _district;
  late DateTime? _lastDonationDate;
  late bool _isAvailable;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam', 'Idukki',
    'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod', 'Gadag'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _bloodGroup = widget.userData['bloodGroup'] ?? 'A+';
    _district = widget.userData['district'] ?? 'Ernakulam';
    _lastDonationDate = (widget.userData['lastDonationDate'] as Timestamp?)?.toDate();
    _isAvailable = widget.userData['isAvailable'] ?? true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastDonationDate) {
      setState(() {
        _lastDonationDate = picked;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userId = getIt<FirebaseAuthService>().currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'bloodGroup': _bloodGroup,
        'district': _district,
        'lastDonationDate': _lastDonationDate != null ? Timestamp.fromDate(_lastDonationDate!) : null,
        'isAvailable': _isAvailable,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _bloodGroup = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _district,
                decoration: const InputDecoration(labelText: 'District'),
                items: _districts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _district = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Last Donation Date'),
                subtitle: Text(
                  _lastDonationDate == null
                      ? 'Not set'
                      : DateFormat.yMMMd().format(_lastDonationDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available to Donate'),
                value: _isAvailable,
                onChanged: (bool value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
                activeColor: AppTheme.bloodRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
