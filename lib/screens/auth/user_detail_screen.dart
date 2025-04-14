import 'dart:io';

import 'package:chronicles/utilities/components/alerts/auth_alerts.dart';
import 'package:chronicles/utilities/components/alerts/two_buttons_auth_alert.dart';
import 'package:chronicles/utilities/components/profile/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:chronicles/utilities/components/buttons/infinite_width_button.dart';
import 'package:chronicles/utilities/components/textfields/gray_textfield.dart';

import '../../services/internet_connectivity.dart';
import '../../services/pfp_services.dart';
import '../../services/secure_storage.dart';
import '../../services/user_service.dart';
import '../../utilities/components/alerts/no_internet_alert.dart';
import '../../utilities/data/user_auth_data.dart';

Future<bool> isUserDetailDone() async {
  SecureStorage userDetail = SecureStorage();

  String value = await userDetail.readSecureData('isUserDetailDone');
  if (value != 'null') {
    if (value == 'true') {
      return true;
    } else {
      return false;
    }
  }
  userDetail.writeSecureData('isUserDetailDone', 'false');
  return false;
}

// Variable Values & TextStyle
final double appBarRightPadding = 10.0;
final double overAllPadding = 15.0;
final double circleAvatarRadius = 90.0;
final double profileIconTopPadding = 130.0;
final double profileIconBottomPadding = 20.0;
final double profileIconHeightWidth = 200.0;
final double iconBottomPosition = 25.0;
final double iconLeftPosition = 215.0;
final double containerHeightWidth = 40.0;
final String usernameText = 'Username';
final String buttonText = 'Submit';
final double verticalButtonMargin = 15.0;
final double buttonHeight = 50.0;
final double horizontalMargin = 0.0;
final double topPadding = 0;
final double bottomPadding = 18;
final Color buttonTextColor = Color(0xFFFFFFFF);
final Color buttonHighlightColor = Color(0xFF35879F);
final Color buttonSplashColor = Color(0xFF6BC9E2);
String usernameHint = 'username';

final skipButtonStyle = TextStyle(
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: 'Hind',
  color: Color(0xFF1F1F1F),
);

final labelTextStyle = TextStyle(
  height: 1.6,
  fontSize: 20.0,
  fontFamily: "Hind",
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

TextEditingController username = TextEditingController();
void clearTextFields() {
  username.clear();
}

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  File? _selectedImage;
  late File imageFile;

  void initState() {
    super.initState();
    fetchUserDetail();
  }

  Future<void> pickProfileImage() async {
    File? image = await pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> saveProfileImage() async {
    String? imagePath = await saveImage(_selectedImage);

    if (imagePath != null) {
      setState(() {
        imageFile = File(imagePath);
      });
    }
  }

  Future<void> saveProfileImageOnline() async {
    if (_selectedImage != null) {
      await uploadProfileImageToSupabase(imageFile);
    }
  }

  void fetchUserDetail() async {
    String uname = await UserDataFetcher().fetchUsername();
    if (!mounted) return;
    setState(() {
      usernameHint = uname;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(overAllPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: profileIconTopPadding,
                    bottom: profileIconBottomPadding),
                child: GestureDetector(
                  onTap: pickProfileImage,
                  child: Stack(
                    children: [
                      Center(
                        child: ProfileAvatar(
                            circleAvatarRadius: circleAvatarRadius),
                      ),
                      if (_selectedImage == null)
                        Positioned(
                          bottom: iconBottomPosition,
                          left: iconLeftPosition,
                          child: Container(
                            height: containerHeightWidth,
                            width: containerHeightWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(5, 5),
                                ),
                              ],
                            ),
                            child: Icon(Icons.add_a_photo),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usernameText,
                    style: labelTextStyle,
                  ),
                  GrayTextfield(
                    controller: username,
                    hintText: usernameHint,
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                  ),
                  InfiniteRoundWidthButton(
                    onPress: () async {
                      SecureStorage storage = SecureStorage();

                      bool hasInternet = await getInternetStatus();
                      if (!hasInternet) {
                        noInternetAlert(context);
                        return;
                      }
                      if (_selectedImage != null) {
                        await saveProfileImage();
                        await saveProfileImageOnline();
                      } else {
                        String defaultUrl = await fetchDefaultProfileUrl();
                        String userId = await UserDataFetcher().fetchUID();
                        await updateUrlInFirebase(userId, defaultUrl);
                      }

                      String enteredUsername = username.text.trim();
                      if (enteredUsername.isEmpty) {
                        twoButtonsAuthAlert(
                          context,
                          message:
                              "$usernameHint will be your permanent username. Continue?",
                          cancelButtonText: "Cancel",
                          proceedButtonText: "Proceed",
                          onProceed: () async {
                            usernameCheck(context, "success");
                            storage.updateSecureData(
                                'isUserDetailDone', 'true');
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      } else {
                        twoButtonsAuthAlert(
                          context,
                          message:
                              "$enteredUsername will be your permanent username. Continue?",
                          cancelButtonText: "Cancel",
                          proceedButtonText: "Proceed",
                          onProceed: () async {
                            String checkUsername =
                                await updateUsername(context, enteredUsername);
                            usernameCheck(context, checkUsername);
                            storage.updateSecureData(
                                'isUserDetailDone', 'true');
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    },
                    buttonLabel: Text(
                      buttonText,
                      style: buttonLabelTextStyle(textColor: buttonTextColor),
                    ),
                    verticalMargin: verticalButtonMargin,
                    height: buttonHeight,
                    highlightColor: buttonHighlightColor,
                    splashColor: buttonSplashColor,
                    horizontalMargin: horizontalMargin,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void usernameCheck(BuildContext context, String result) {
  if (result == "success") {
    Navigator.pushNamedAndRemoveUntil(context, '/Dashboard', (route) => false);
    clearTextFields();
  } else if (result == "emptyField") {
    authAlert(context,
        message: "Username cannot be empty", icon: Icons.error_outline);
  } else if (result == "invalidUsername") {
    authAlert(context, message: "Invalid Username", icon: Icons.error_outline);
  } else if (result == "invalidLength") {
    authAlert(context,
        message: "Username must have 4-8 characters with no spaces",
        icon: Icons.error_outline);
  } else if (result == "usernameTaken") {
    authAlert(context,
        message: "This username is already taken",
        icon: Icons.warning_amber,
        iconColor: Colors.orangeAccent);
  } else {
    authAlert(context,
        message: "Unexpected error occurred", icon: Icons.error_outline);
  }
}
