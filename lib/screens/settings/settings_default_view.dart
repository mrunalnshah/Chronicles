import 'package:chronicles/utilities/components/buttons/custom_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:chronicles/screens/profile/edit_profile.dart';
import 'package:chronicles/screens/auth/change_password.dart';
import '../../utilities/image_import/logo_import.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _passcodeEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // Change length to 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabTextStyle = TextStyle(
      fontSize: 18.0,
      fontFamily: 'Hind',
      fontWeight: FontWeight.w500,
      color: Color(0xFF1F1F1F),
    );

    const contentTextStyle = TextStyle(
      fontSize: 16.0,
      fontFamily: 'Hind',
      fontWeight: FontWeight.w500,
      color: Color(0xFF1F1F1F),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/ProfileScreen',
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Container(
            color: const Color(0xFFDDEDFF),
            height: 280,
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF5C98C8),
            unselectedLabelColor: const Color(0xFF1F1F1F),
            indicatorColor: const Color(0xFF5C98C8),
            indicatorWeight: 2.0,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('General', style: tabTextStyle),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Security', style: tabTextStyle),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Back Up', style: tabTextStyle),
                ),
              )
            ],
            dividerColor: Colors.transparent,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneral(context, contentTextStyle),
                _buildSecurityTab(context, contentTextStyle),
                _buildBackupTab(context, contentTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneral(BuildContext context, TextStyle contentTextStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 13.0),
          TextButton(
            child: Text('Edit Profile', style: contentTextStyle),
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
          const Divider(),
          const SizedBox(height: 10.0),
          TextButton(
            child: Text('Theme', style: contentTextStyle),
            onPressed: () {},
          ),
          const Divider(),
          const SizedBox(height: 10.0),
          TextButton(
            child: Text('Notification', style: contentTextStyle),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context, TextStyle contentTextStyle) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('Passcode', style: contentTextStyle),
              ),
              Transform.scale(
                scale: 0.86,
                child: Switch(
                  value: _passcodeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _passcodeEnabled = value;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF4EABCC),
                  inactiveTrackColor: Colors.transparent,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16.0),
          TextButton(
            child: Text('Change Password', style: contentTextStyle),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/ChangePasswordScreen',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab(BuildContext context, TextStyle contentTextStyle) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Import',
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Hind',
                fontWeight: FontWeight.w500,
                color: Color(0xFF449AB9),
              )),
          const SizedBox(height: 13.0),
          TextButton(
            child: Text('Import file', style: contentTextStyle),
            onPressed: () {},
          ),
          SizedBox(
            height: 20,
          ),
          Text('Export',
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Hind',
                fontWeight: FontWeight.w500,
                color: Color(0xFF449AB9),
              )),
          const SizedBox(height: 13.0),
          TextButton(
            child: Text('All Journal', style: contentTextStyle),
            onPressed: () {},
          ),
          const Divider(),
          const SizedBox(height: 13.0),
          TextButton(
            child: Text('Date Range', style: contentTextStyle),
            onPressed: () {},
          ),
          const Divider(),
          const SizedBox(height: 13.0),
          TextButton(
            child: Text('Export as PDF', style: contentTextStyle),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
