/* D
* File Name        : register_screen.dart
* Group            : trOlsz Group
* Description      : This file has code for the Pin Login Screen
*/

import 'package:chronicles/utilities/components/alerts/two_buttons_auth_alert.dart';
import 'package:chronicles/utilities/components/keyboard/blue_numeric_keyboard.dart';
import 'package:chronicles/utilities/components/textfields/otp_display_textfield.dart';
import 'package:flutter/material.dart';
import '../../services/secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

final String passwordResetText = 'Pin Login';
final String normalMessageTitleText = 'Enter your 4-digit Pin';
final String normalMessageText = "Can’t remember PIN? ";
final String loginButtonText = "Login again";

final double bodyLeftRightPadding = 25.0;
final double bodyTopPadding = 160.0;
final double iconContainerSize = 90.0;
final double containerRadius = 12.0;
final double iconSize = 80.0;
final double titleTopPadding = 20.0;
final double textFieldTopPadding = 30.0;
final double textFieldBottomPadding = 15.0;

final Color borderColor = Color(0xFFDDDFE5);

final passwordResetTextStyle = TextStyle(
  height: 1.2,
  fontSize: 30.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final normalMessageTitleStyle = TextStyle(
  fontSize: 15.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w500,
  color: Color(0xFF5B5A5A),
);

final normalMessageStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final accountExistStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final loginButtonStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF4EABCC),
);

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreen();
}

class _PinLoginScreen extends State<PinLoginScreen> {
  String inputText = "";
  final SecureStorage storage = SecureStorage();

  void handleKeyTap(String key) async {
    setState(() {
      if (key == "C") {
        inputText = "";
      } else if (key != "✔") {
        if (inputText.length < 4) {
          inputText += key;
        }
      }
    });

    if (key == "✔") {
      String storedPin = await storage.readSecureData('pin_store');

      if (inputText == storedPin) {
        Navigator.pushReplacementNamed(context, '/Dashboard');
      } else {
        // Optional: Show error or shake animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect PIN")),
        );
        setState(() {
          inputText = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: bodyLeftRightPadding,
              right: bodyLeftRightPadding,
              top: bodyTopPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: iconContainerSize,
                    width: iconContainerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(containerRadius),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.password_sharp, size: iconSize),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: titleTopPadding),
                  child: Center(
                    child: Text(
                      passwordResetText,
                      style: passwordResetTextStyle,
                    ),
                  ),
                ),
                Center(
                  child: Text(normalMessageTitleText,
                      style: normalMessageTitleStyle),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: textFieldTopPadding, bottom: textFieldBottomPadding),
                  child: OtpDisplayTextfield(inputText: inputText),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      normalMessageText,
                      style: accountExistStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        twoButtonsAuthAlert(context,
                            message:
                                "You’re about to sign out. Do you want to proceed?",
                            cancelButtonText: "Cancel",
                            proceedButtonText: "Log Out", onProceed: () async {
                          SecureStorage storage = SecureStorage();

                          GoogleSignIn googleSignIn = GoogleSignIn();

                          await googleSignIn.signOut();
                          storage.updateSecureData('isLoginDone', 'false');
                          storage.updateSecureData('isPinRequired', 'false');
                          storage.updateSecureData('isUserDetailDone', 'true');

                          Navigator.popAndPushNamed(context, '/WelcomeScreen');
                        });
                      },
                      child: Text(
                        loginButtonText,
                        style: loginButtonStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: CustomNumericKeyboard(onKeyTap: handleKeyTap)),
        ],
      ),
    );
  }
}
