import 'dart:io';
import 'package:chronicles/screens/profile/settings/general_setting_screen.dart';
import 'package:chronicles/screens/profile/settings/personal_info_screen.dart';
import 'package:chronicles/screens/profile/settings/security_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/pfp_services.dart';
import '../../../utilities/data/user_auth_data.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? profileImage;
  String username = "";
  String firstName = "";
  String lastName = "";
  bool isDarkMode = false;
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchUserData();
    pfpDisplay();
  }

  Future<void> pfpDisplay() async {
    String? imagePath = await getSavedImagePath();
    if (imagePath != null) {
      setState(() {
        profileImage = File(imagePath);
      });
    }
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
        title: const Text("Account Settings"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.transparent,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : const AssetImage(
                              'assets/images/icons/new_profile_icon.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "@${username.toLowerCase()}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("General"),
                    Text(
                      "Settings",
                    ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Personal"),
                    Text(
                      "Info",
                    ),
                  ],
                ),
              ),
              Tab(text: "Security"),
              Tab(text: "Back Up"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                generalTab(),
                PersonalInfoScreen(),
                SecurityTab(),
                _backupTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backupTab() {
    return ListView(
      children: [
        _settingsTile(
            Icons.cloud_upload, "Back Up Data", "Sync your data to the cloud"),
        _settingsTile(Icons.restore, "Restore Data", "Recover saved backups"),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
