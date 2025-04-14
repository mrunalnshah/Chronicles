import 'dart:io';
import 'package:chronicles/screens/profile/settings/general_setting_screen.dart';
import 'package:chronicles/screens/profile/settings/personal_info_screen.dart';
import 'package:chronicles/screens/profile/settings/security_screen.dart';
import 'package:chronicles/utilities/components/profile/profile_avatar.dart';
import 'package:flutter/material.dart';
import '../../../services/pfp_services.dart';
import '../../../utilities/data/user_auth_data.dart';

final String titleMessage = "Account Settings";
final String generalTabButton = "General";
final String personalInfoTabButton = "Personal Info";
final String securityTabButton = "Security";
final String defaultPfpPath = 'assets/images/icons/new_profile_icon.png';

final double overAllPadding = 16.0;
final double circleAvatarRadius = 75.0;
final double height_10 = 10;
final double underLineTabWidth = 3.0;
final double iconBottomPosition = 5.0;
final double iconLeftPosition = 215.0;
final double containerHeightWidth = 40.0;

final Color underLineColor = Color(0xFF4EABCC);

final titleMessageStyle = TextStyle(
  fontSize: 22.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

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

final tabButtonTextStyle = TextStyle(
  fontSize: 15.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  File? profileImage;
  String username = "";
  String firstName = "";
  String lastName = "";
  bool isDarkMode = false;
  bool notificationsEnabled = false;
  File? selectedImage;
  late File imageFile;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchUserData();
  }

  void fetchUserData() async {
    UserData data = await UserDataFetcher().fetchUserData();
    setState(() {
      username = data.username ?? "DarthJarJar";
      firstName = data.firstName ?? "Jar Jar";
      lastName = data.lastName ?? "Binks";
    });
  }

  Future<void> pickProfileImage() async {
    File? image = await pickImage();
    if (image != null) {
      selectedImage = image;

      await saveProfileImage(image);
      await saveProfileImageOnline(image);
    }
    setState(() {
      profileImage = image;
    });
  }

  Future<void> saveProfileImage(File image) async {
    String? imagePath = await saveImage(image);

    if (imagePath != null) {
      print('Local profile image updated: $imagePath');
    }
  }

  Future<void> saveProfileImageOnline(File image) async {
    await uploadProfileImageToSupabase(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleMessage,
          style: titleMessageStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(
              context,
              '/ProfileScreen',
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(overAllPadding),
            child: Column(
              children: [
                // GestureDetector(
                //   onTap: pickProfileImage,
                //   child: ProfileAvatar(
                //     key: ValueKey(profileImage?.path ?? 'default'),
                //     circleAvatarRadius: circleAvatarRadius,
                //   ),
                // ),
                GestureDetector(
                  onTap: pickProfileImage,
                  child: Stack(
                    children: [
                      Center(
                        child: ProfileAvatar(
                            key: ValueKey(profileImage?.path ?? 'default'),
                            circleAvatarRadius: circleAvatarRadius),
                      ),
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
                          child: Icon(
                            Icons.edit_outlined,
                            color: Color(0x901F1F1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height_10),
                Text(
                  "$firstName $lastName",
                  style: firstNameLastNameStyle,
                ),
                Text(
                  "@${username.toLowerCase()}",
                  style: usernameStyle,
                ),
              ],
            ),
          ),
          TabBar(
            controller: tabController,
            indicator: UnderlineTabIndicator(
              borderSide:
                  BorderSide(width: underLineTabWidth, color: underLineColor),
            ),
            tabs: [
              Tab(
                child: Text(
                  generalTabButton,
                  style: tabButtonTextStyle,
                ),
              ),
              Tab(
                  child: Text(
                personalInfoTabButton,
                style: tabButtonTextStyle,
              )),
              Tab(
                  child: Text(
                securityTabButton,
                style: tabButtonTextStyle,
              )),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                generalTab(),
                PersonalInfoScreen(),
                SecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
