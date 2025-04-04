/* D
* File Name        : change_password.dart
* Group            : trOlsz Group
* Description      : This file has code for the Register Screen
*/

// Importing Packages
import 'package:flutter/material.dart';
import 'package:chronicles/utilities/components/buttons/infinite_width_button.dart';
import 'package:chronicles/utilities/components/textfields/gray_textfield.dart';

import '../../services/change_password_services.dart';

// Variable Values & TextStyles
final double leftRightOverallPadding = 25.0;
final double topOverallPadding = 60.0;
final double iconBorderRadiusFingerprint = 6.0;
final double iconWidthFingerprint = 2.0;
final double passwordResetTextTopPadding = 15.0;
final double passwordResetTextBottomPadding = 42.0;

final Color iconColorFingerprint = Color(0xFFDDDFE5);

final String passwordResetText = 'Set new password';
final String normalMessageText = 'Must be at least 8 characters.';
final String passwordHint = 'Enter password';
final String confirmPasswordHint = 'Enter password';
final String passwordText = 'Password';
final String confirmPasswordText = 'Confirm Password';
final String resetPasswordButtonText = 'Reset Password';
final double iconSize = 80;
final double verticalButtonMargin = 30.0;
final double buttonHeight = 50.0;
final double horizontalMargin = 0.0;
final double topPadding = 0;
final double bottomPadding = 13;
final Color loginTextColor = Color(0xFFFFFFFF);
final Color loginRegisterHighlightColor = Color(0xFF35879F);
final Color loginRegisterSplashColor = Color(0xFF6BC9E2);

final bool isPasswordVisible = true;

final passwordResetTextStyle = TextStyle(
  height: 1.2,
  fontSize: 30.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.bold,
  color: Color(0xFF1F1F1F),
);

final labelTextStyle = TextStyle(
  height: 1.6,
  fontSize: 20.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final normalMessageStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w500,
  color: Color(0xFF5B5A5A),
);

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

TextEditingController newPassword = TextEditingController();
TextEditingController confirmNewPassword = TextEditingController();

void clearTextFields() {
  newPassword.clear();
  confirmNewPassword.clear();
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordService _passwordService = ChangePasswordService();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            clearTextFields();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: leftRightOverallPadding,
            right: leftRightOverallPadding,
            top: topOverallPadding,
          ),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius:
                            BorderRadius.circular(iconBorderRadiusFingerprint),
                        border: Border.all(
                          color: iconColorFingerprint,
                          width: iconWidthFingerprint,
                        ),
                      ),
                      child: Icon(Icons.fingerprint, size: iconSize),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: passwordResetTextTopPadding,
                        bottom: passwordResetTextBottomPadding),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            passwordResetText,
                            style: passwordResetTextStyle,
                          ),
                          Text(
                            normalMessageText,
                            style: normalMessageStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    passwordText,
                    style: labelTextStyle,
                  ),
                  GrayTextfield(
                    controller: newPassword,
                    hintText: passwordHint,
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                  ),
                  Text(
                    confirmPasswordText,
                    style: labelTextStyle,
                  ),
                  GrayTextfield(
                    controller: confirmNewPassword,
                    hintText: confirmPasswordHint,
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                    isPassword: isPasswordVisible,
                  ),
                  InfiniteRoundWidthButton(
                    onPress: () async {
                      String newPass = newPassword.text.trim();
                      String confirmPass = confirmNewPassword.text.trim();

                      if (newPass.isEmpty || confirmPass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please fill in both fields.")),
                        );
                        return;
                      }
                      if (newPass.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Password must be at least 8 characters long.")),
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Passwords do not match.")),
                        );
                        return;
                      }

                      String? error =
                          await _passwordService.changePassword(newPass);
                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Password updated successfully")),
                        );
                        clearTextFields();
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                      clearTextFields();
                      Navigator.pop(context);
                    },
                    buttonLabel: Text(
                      resetPasswordButtonText,
                      style: buttonLabelTextStyle(textColor: loginTextColor),
                    ),
                    verticalMargin: verticalButtonMargin,
                    height: buttonHeight,
                    highlightColor: loginRegisterHighlightColor,
                    splashColor: loginRegisterSplashColor,
                    horizontalMargin: horizontalMargin,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
