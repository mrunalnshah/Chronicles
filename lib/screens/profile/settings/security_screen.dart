import 'package:chronicles/utilities/components/alerts/auth_alerts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/secure_storage.dart';
import '../../../utilities/components/switch/custom_switch.dart';
import '../../auth/change_password.dart';

class SecurityTab extends StatefulWidget {
  @override
  _SecurityTabState createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  bool _isPinLoginEnabled = false;
  String? _pin;
  final SecureStorage storage = SecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadPinLoginStatus();
  }

  Future<void> _loadPinLoginStatus() async {
    String? value = await storage.readSecureData('isPinRequired');
    print("Loaded isPinRequired: $value");

    setState(() {
      _isPinLoginEnabled = value == 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.fingerprint, color: Colors.blue),
          title: const Text("Enable PIN Login"),
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
        _securityTile(
            Icons.password, "Change Password", () => changePassword(context)),
      ],
    );
  }

  Widget _securityTile(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title,
          style: TextStyle(color: onTap != null ? Colors.black : Colors.grey)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: onTap,
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
                    await showPinPrompt(context); // Rewrites PIN
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
                    Navigator.pop(context); // Close the dialog
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
                    const SnackBar(content: Text("Enter your old password")),
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
