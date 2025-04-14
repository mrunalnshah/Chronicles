import 'package:chronicles/utilities/components/alerts/auth_alerts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/secure_storage.dart';
import '../../../utilities/components/switch/custom_switch.dart';
import '../../auth/change_password.dart';

final String setPinButtonText = "Enable Pin Login";
final String changePasswordButtonText = "Change Password";
final String aboutUsButtonText = "About Us";
final String resetButtonText = "Reset to Defaults";
final Color iconColor = Color(0xFF4EABCC);

final buttonTextStyle = TextStyle(
  fontSize: 15.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

class SecurityTab extends StatefulWidget {
  @override
  _SecurityTabState createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  bool _isPinLoginEnabled = false;
  String? _pin;
  final SecureStorage storage = SecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadPinLoginStatus();
    checkGoogleUser();
  }

  Future<void> _loadPinLoginStatus() async {
    String? value = await storage.readSecureData('isPinRequired');

    if (mounted) {
      setState(() {
        _isPinLoginEnabled = value == 'true';
      });
    }
  }

  Future<void> checkGoogleUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      isGoogleUser = user.providerData
          .any((provider) => provider.providerId == 'google.com');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.fingerprint, color: iconColor),
          title: Text(
            setPinButtonText,
            style: buttonTextStyle,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          trailing: CustomSwitch(
              value: _isPinLoginEnabled,
              onChanged: (newValue) async {
                if (newValue) {
                  bool pinSet = await showPinPrompt(context);
                  if (pinSet) {
                    setState(() => _isPinLoginEnabled = true);
                    await storage.updateSecureData('isPinRequired', 'true');
                  } else {
                    setState(() => _isPinLoginEnabled = false);
                    await storage.updateSecureData('isPinRequired', 'false');
                  }
                } else {
                  setState(() => _isPinLoginEnabled = false);
                  await storage.updateSecureData('isPinRequired', 'false');
                }
              }),
        ),
        if (_isPinLoginEnabled) ...[
          _securityTile(
            Icons.security,
            "Update PIN",
            () => _verifyPassword(context),
          ),
        ],
        if (!isGoogleUser) ...[
          _securityTile(Icons.password, changePasswordButtonText,
              () => changePassword(context)),
        ] else ...[
          _securityTile(Icons.password, changePasswordButtonText, null,
              isDisabled: true),
        ],
      ],
    );
  }

  Widget _securityTile(IconData icon, String title, VoidCallback? onTap,
      {bool isDisabled = false}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: buttonTextStyle.copyWith(
              color: onTap != null ? Colors.black : Colors.grey)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: isDisabled ? null : onTap, // Disable the tap if isDisabled is true
    );
  }

  Future<bool> showPinPrompt(BuildContext context) async {
    String enteredPin = "";
    TextEditingController pinController = TextEditingController();

    bool pinSet = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter 4-digit PIN"),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(counterText: ""),
            onChanged: (value) {
              if (value.length <= 4) enteredPin = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                pinSet = false;
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (enteredPin.length == 4) {
                  setState(() => _pin = enteredPin);

                  await storage.updateSecureData('pin_store', enteredPin);
                  await storage.updateSecureData('isPinRequired', 'true');
                  pinSet = true;

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid 4-digit PIN")),
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
    return pinSet;
  }

  Future<void> _verifyPassword(BuildContext context) async {
    String enteredPassword = "";
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Account Password"),
          content: TextField(
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
            onChanged: (value) => enteredPassword = value,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                if (enteredPassword.isNotEmpty) {
                  bool isVerified = await _authenticateUser(enteredPassword);

                  if (isVerified) {
                    Navigator.pop(context);
                    await showPinPrompt(context);
                  } else {
                    authAlert(
                      context,
                      message: "Incorrect password. Try again.",
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter your password")),
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword(BuildContext context) async {
    String enteredPassword = "";
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verify Old Password"),
          content: TextField(
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Old Password"),
            onChanged: (value) => enteredPassword = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (enteredPassword.isNotEmpty) {
                  bool isVerified = await _authenticateUser(enteredPassword);
                  if (isVerified) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  } else {
                    authAlert(
                      context,
                      message: "Incorrect password. Try again.",
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter your old password")),
                  );
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _authenticateUser(String password) async {
    try {
      User? user = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print("Authentication Error: $e");
      return false;
    }
  }
}
