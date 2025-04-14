import 'package:chronicles/screens/profile/settings/settings_screen.dart';
import 'package:chronicles/utilities/components/buttons/infinite_width_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/secure_storage.dart';
import '../../../utilities/data/gender.dart';
import '../../../utilities/data/user_auth_data.dart';

final double verticalButtonMargin = 20.0;
final double buttonHeight = 50.0;
final double horizontalMargin = 0.0;
final Color signUpTextColor = Color(0xFFFFFFFF);
final Color loginRegisterHighlightColor = Color(0xFF35879F);
final Color loginRegisterSplashColor = Color(0xFF6BC9E2);

final textFieldStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w500,
);

final labelStyle = TextStyle(
  color: Color(0xFF80858D),
  fontFamily: "Hind",
  fontWeight: FontWeight.w500,
);

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

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

    _firstNameController.addListener(() {
      setState(() {
        _isChanged = true;
      });
    });

    _lastNameController.addListener(() {
      setState(() {
        _isChanged = true;
      });
    });
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

      int genderIndex;
      var genderValue = userData['gender'];

      if (genderValue is int) {
        genderIndex = genderValue;
      } else if (genderValue is String) {
        genderIndex = int.tryParse(genderValue) ?? -1;
      } else {
        genderIndex = -1;
      }

      if (genderIndex < 0 || genderIndex >= Gender.values.length) {
        genderIndex = Gender.values.length - 1;
      }

      var dobValue = userData['dob'];
      int? dobMillis;

      if (dobValue is int) {
        dobMillis = dobValue;
      } else if (dobValue is String) {
        dobMillis = int.tryParse(dobValue);
      }

      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _firstNameController.text = userData['firstname'] ?? '';
        _lastNameController.text = userData['lastname'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _selectedGender = Gender.values[genderIndex].name;
        _dob = dobMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dobMillis)
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
            _buildTextField("Username", _usernameController, isReadOnly: true),
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
            _buildTextField("Email", _emailController, isReadOnly: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown("Gender", _selectedGender,
                        ["Male", "Female", "Other", "Prefer not to say"])),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker("DOB")),
              ],
            ),
            const SizedBox(height: 20),
            //onPressed:
            InfiniteRoundWidthButton(
              onPress: _isChanged ? _saveChanges : null,
              buttonLabel: Text(
                "Save Changes",
                style: buttonLabelTextStyle(textColor: signUpTextColor),
              ),
              verticalMargin: verticalButtonMargin,
              height: buttonHeight,
              highlightColor: loginRegisterHighlightColor,
              splashColor: loginRegisterSplashColor,
              horizontalMargin: horizontalMargin,
            ),
          ],
        ));
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isReadOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      style: textFieldStyle.copyWith(
        color: isReadOnly ? Color(0xFF9EA1A7) : Colors.black,
      ),
      decoration: inputDecoration(label),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options) {
    if (!options.contains(value)) value = "Other";
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: inputDecoration(label),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Hind",
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
          icon: const Icon(Icons.keyboard_arrow_down_sharp,
              size: 20, color: Color(0xFF1F1F1F)),
        ));
  }

  Widget _buildDatePicker(String label) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          readOnly: true,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Hind",
            fontWeight: FontWeight.w500,
          ),
          decoration: inputDecoration(
            label,
            suffixIcon: const Icon(Icons.calendar_today,
                size: 18, color: Color(0xFF1F1F1F)),
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
            text:
                _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year}" : "",
          ),
        ));
  }
}

InputDecoration inputDecoration(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Color(0xFF80858D),
      fontFamily: "Hind",
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Color(0xFFF7F8FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFDDDFE5),
        width: 1.2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFDDDFE5),
        width: 1.2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFDDDFE5),
        width: 1.2,
      ),
    ),
    suffixIcon: suffixIcon,
  );
}
