import 'dart:io';

import 'package:chronicles/utilities/components/alerts/auth_alerts.dart';
import 'package:flutter/material.dart';
import 'package:chronicles/utilities/components/buttons/infinite_width_button.dart';
import 'package:chronicles/utilities/components/textfields/gray_textfield.dart';

import '../../services/internet_connectivity.dart';
import '../../services/pfp_services.dart';
import '../../services/user_service.dart';
import '../../utilities/components/alerts/no_internet_alert.dart';
import '../../utilities/data/user_auth_data.dart';

// Variable Values & TextStyle
final double appBarRightPadding = 10.0;
final double overAllPadding = 15.0;
final double circleAvatarRadius = 90.0;
final double profileIconTopPadding = 40.0;
final double profileIconBottomPadding = 20.0;
final double profileIconHeightWidth = 200.0;
final double iconBottomPosition = 25.0;
final double iconLeftPosition = 215.0;
final double containerHeightWidth = 40.0;
final String usernameHint = 'Enter your Username';
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
    } else {
      print("No image selected, skipping upload.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: appBarRightPadding),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/Dashboard',
                  (Route<dynamic> route) => false,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Skip',
                    style: skipButtonStyle,
                  ),
                  Icon(Icons.arrow_right),
                ],
              ),
            ),
          ),
        ],
      ),
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
                        child: CircleAvatar(
                          radius: circleAvatarRadius,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : AssetImage(
                                  'assets/images/icons/new_profile_icon.png',
                                ) as ImageProvider,
                        ),
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
                      bool hasInternet = await getInternetStatus();
                      if (!hasInternet) {
                        noInternetAlert(context);
                      }
                      if (_selectedImage != null) {
                        await saveProfileImage();
                        await saveProfileImageOnline();
                      } else {
                        String defaultUrl = await fetchDefaultProfileUrl();
                        String userId = await UserDataFetcher().fetchUID();
                        await updateUrlInFirebase(userId, defaultUrl);
                      }

                      var checkUsername =
                          await updateUsername(context, username.text.trim());
                      if (context.mounted) {
                        if (checkUsername == "success") {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/Dashboard',
                            (Route<dynamic> route) => false,
                          );
                          clearTextFields();
                        } else if (checkUsername == "emptyField") {
                          authAlert(
                            context,
                            message: "Username cannot be empty",
                            icon: Icons.error_outline,
                          );
                        } else if (checkUsername == "invalidUsername") {
                          authAlert(
                            context,
                            message: "Invalid Username",
                            icon: Icons.error_outline,
                          );
                        } else if (checkUsername == "invalidLength") {
                          authAlert(
                            context,
                            message:
                                "Username must have 4-8 characters and No spaces",
                            icon: Icons.error_outline,
                          );
                        } else if (checkUsername == "usernameTaken") {
                          authAlert(context,
                              message: "This username is already taken",
                              icon: Icons.warning_amber,
                              iconColor: Colors.orangeAccent);
                        } else {
                          authAlert(context,
                              message: "Unexpected error occurred",
                              icon: Icons.error_outline);
                        }
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
