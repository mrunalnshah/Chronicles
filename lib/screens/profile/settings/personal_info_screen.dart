import 'package:chronicles/screens/profile/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/secure_storage.dart';
import '../../../utilities/data/gender.dart';
import '../../../utilities/data/user_auth_data.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  SecureStorage storage = SecureStorage();

  String _selectedGender = "Male";
  DateTime? _dob;
  bool _isChanged = false;
  bool _isUsernameValid = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    _userId = await UserDataFetcher().fetchUID();
    if (_userId != null) {
      await _loadUserData(_userId!);
    } else {
      print("Error: User ID not found!");
    }
  }

  Future<void> _loadUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user_account')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      int genderIndex = userData['gender'] ?? -1;

      if (genderIndex < 0 || genderIndex >= Gender.values.length) {
        genderIndex = Gender.values.length - 1;
      }

      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _firstNameController.text = userData['firstname'] ?? '';
        _lastNameController.text = userData['lastname'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _selectedGender = Gender.values[genderIndex].name;
        _dob = userData['dob'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['dob'])
            : null;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_isUsernameValid || _userId == null) return;

    int _selectedGenderIndex = Gender.values.indexOf(Gender.values.firstWhere(
        (g) => g.name == _selectedGender,
        orElse: () => Gender.values.last));

    await FirebaseFirestore.instance
        .collection('user_account')
        .doc(_userId)
        .update({
      'username': _usernameController.text,
      'firstname': _firstNameController.text,
      'lastname': _lastNameController.text,
      'email': _emailController.text,
      'gender': _selectedGenderIndex,
      'dob': _dob?.millisecondsSinceEpoch,
    });

    UserData updatedData = UserData(
      uid: _userId!,
      email: _emailController.text,
      username: _usernameController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      gender: Gender.values[_selectedGenderIndex],
      joinDate: DateTime.now().millisecondsSinceEpoch,
    );

    String dataString = updatedData.toJson();
    await storage.updateSecureData('UserData', dataString);

    setState(() {
      _isChanged = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField("Username", _usernameController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildTextField("First Name", _firstNameController)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField("Last Name", _lastNameController)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField("Email", _emailController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Gender",
                  _selectedGender,
                  ["Male", "Female", "Other", "Prefer not to say"],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildDatePicker("DOB")),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isChanged ? _saveChanges : null,
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() => _isChanged = true),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options) {
    if (!options.contains(value)) value = "Other";

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGender = newValue!;
          _isChanged = true;
        });
      },
      icon: const Icon(Icons.keyboard_arrow_down_sharp, size: 14.9),
    );
  }

  Widget _buildDatePicker(String label) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _dob ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dob = pickedDate;
            _isChanged = true;
          });
        }
      },
      controller: TextEditingController(
        text: _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year}" : "",
      ),
    );
  }
}
