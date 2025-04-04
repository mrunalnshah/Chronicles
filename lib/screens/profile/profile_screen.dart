/* D
* File Name        : profile_screen.dart
* Group            : trOlsz Group
* Description      : This file is has code for Profile Screen.
*/

// Importing Packages

import 'dart:io';
import 'package:chronicles/screens/profile/friends/friend_lists_mainscreen.dart';
import 'package:chronicles/screens/profile/settings/settings_screen.dart';
import 'package:chronicles/services/internet_connectivity.dart';
import 'package:chronicles/utilities/components/alerts/no_internet_alert.dart';
import 'package:chronicles/utilities/components/buttons/infinite_width_button.dart';
import 'package:chronicles/utilities/data/app_policy/terms_and_conditions.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chronicles/services/secure_storage.dart';
import 'package:chronicles/utilities/components/buttons/custom_textbutton.dart';
import 'package:chronicles/utilities/data/app_policy/help.dart';
import 'package:chronicles/utilities/data/app_policy/privacy_policy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chronicles/utilities/data/user_auth_data.dart';
import 'package:chronicles/services/pfp_services.dart';

// Variable Values & TextStyles
final double buttonHeight = 50.0;
final double buttonCircularBorderRadius = 30.0;
final double buttonVerticalPadding = 50.0;
final double buttonHorizontalMargin = 120.0;
final double scrolledUnderElevationValue = 0.5;
final double bodyHorizontalPadding = 20.0;
final double height20 = 20.0;
final double height25 = 25.0;
final double sizedBoxBetweenProfilePicAndSetting = 13.0;
final double profileIconWidth = 150.0;
final double profileIconHeight = 150.0;
final double height60 = 60.0;
final double borderRadiusInfiniteButton = 30.0;
final double profileBorderWidth = 1.0;
final double infiniteButtonVerticalMargin = 5.0;
final double optionBottomPadding = 40.0;
final double optionBorderRadius = 30.0;
final double padding15 = 15.0;
final double padding10 = 10.0;
final double endContainerBorderRadius = 30.0;
final double endContainerBorderWidth = 1.0;

final Color buttonTextColor = Color(0xFFFFFFFF);
final Color buttonHighlightColor = Color(0xFF35879F);
final Color buttonSplashColor = Color(0xFF6BC9E2);
final Color appBarBGColor = Color(0xFFFFFFFF);
final Color profileBGColor = Color(0x4D4EABCC);
final Color profileBorderColor = Color(0xFF4EABCC);
final Color optionBGColor = Color(0xFFF4F4F4);
final Color endContainerBGColor = Color(0x4D4EABCC);
final Color endContainerBorderColor = Color(0xFF4EABCC);

final String friendsButtonLabel = "+ Friends";
final String optionSettingText = "Settings";
final String optionBadgeText = "Badges";
final String optionTemplateText = "Templates";
final String optionHelpText = "Help";
final String optionPrivacyText = "Privacy policy";
final String optionLogoutText = "Logout";

String username = "@Loading...";
String firstName = "firstName";
String lastName = "lastName";

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

final firstNameLastNameStyle = TextStyle(
  fontSize: 20.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

final usernameStyle = TextStyle(
  fontSize: 18.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w300,
  color: Color(0x901F1F1F),
);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;

  @override
  void initState() {
    fetchUserData();
    pfpDisplay();
    super.initState();
  }

  Future<void> pfpDisplay() async {
    String? imagePath = await getSavedImagePath();
    setState(() {
      if (imagePath != null) {
        profileImage = File(imagePath);
      }
    });
  }

  void fetchUserData() async {
    UserData data = await UserDataFetcher().fetchUserData();

    setState(() {
      username = data.username ?? "DarthJarJar";
      firstName = data.firstName ?? "Jar Jar";
      lastName = data.lastName ?? "Binks";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBGColor,
        scrolledUnderElevation: scrolledUnderElevationValue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/Dashboard',
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.help_outline),
              color: Color(0xFF4EABCC),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => HelpDialog(),
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.shieldHalved),
              color: Color(0xFF4EABCC),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PrivacyPolicyDialog(),
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.fileContract),
              color: Color(0xFF4EABCC),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TermsConditionsDialog(),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: bodyHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height25,
            ),
            Stack(clipBehavior: Clip.none, children: [
              Container(
                height: 230,
                width: 355,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFF4F4F4),
                ),
              ),
              Positioned(
                top: -20,
                right: 0,
                left: 0,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF4F4F4),
                      border: Border.all(
                        color: Color(0xFFF4F4F4),
                      )),
                  child: Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : AssetImage(
                                  'assets/images/icons/new_profile_icon.png')
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Column(children: [
                  Text(
                    "$firstName $lastName",
                    style: firstNameLastNameStyle,
                  ),
                  Text(
                    "@${username.toLowerCase()}",
                    style: usernameStyle,
                  ),
                ]),
              ),
            ]),
            SizedBox(
              height: height25,
            ),
            Container(
              height: height60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadiusInfiniteButton),
                color: profileBGColor,
                border: Border.all(
                  color: profileBorderColor,
                  width: profileBorderWidth,
                ),
              ),
              child: InfiniteRoundWidthButton(
                onPress: () async {
                  bool internetStatus = await getInternetStatus();
                  if (internetStatus) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendListScreen(),
                      ),
                    );
                  } else {
                    noInternetAlert(context);
                  }
                },
                buttonLabel: Text(
                  friendsButtonLabel,
                  style: buttonLabelTextStyle(
                    textColor: buttonTextColor,
                  ),
                ),
                height: buttonHeight,
                highlightColor: buttonHighlightColor,
                splashColor: buttonSplashColor,
                horizontalMargin: buttonHorizontalMargin,
                verticalMargin: infiniteButtonVerticalMargin,
              ),
            ),
            SizedBox(
              height: sizedBoxBetweenProfilePicAndSetting,
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: optionBottomPadding,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: optionBGColor,
                  borderRadius: BorderRadius.circular(optionBorderRadius),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: padding15, left: padding15, right: padding15),
                      child: CustomTextButton(
                        text: optionSettingText,
                        icon: Icons.settings,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: padding10, left: padding15, right: padding15),
                      child: CustomTextButton(
                        text: optionBadgeText,
                        icon: Icons.badge_outlined,
                        onPressed: () {},
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: padding10,
                        left: padding15,
                        right: padding15,
                        bottom: padding15,
                      ),
                      child: CustomTextButton(
                        text: optionTemplateText,
                        icon: Icons.design_services,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: height60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(endContainerBorderRadius),
                color: endContainerBGColor,
                border: Border.all(
                  color: endContainerBorderColor,
                  width: endContainerBorderWidth,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding15),
                child: CustomTextButton(
                  text: optionLogoutText,
                  icon: Icons.logout_outlined,
                  containerColor: Color(0x804EABCC),
                  onPressed: () async {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/WelcomeScreen',
                      (Route<dynamic> route) => false,
                    );
                    SecureStorage storage = SecureStorage();
                    GoogleSignIn googleSignIn = GoogleSignIn();

                    await googleSignIn.signOut();

                    storage.updateSecureData('isLoginDone', 'false');
                    storage.updateSecureData('isPinRequired', 'false');
                  },
                ),
              ),
            ),
            SizedBox(height: height20),
          ],
        ),
      ),
    );
  }
}
