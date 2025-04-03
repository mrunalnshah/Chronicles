/* D
* File Name        : chronicles.dart
* Group            : trOlsz Group
* Description      : This file is the start point in this app.
*                   It runs the app and send it to the next Screen
*                   based on the authentication requirements set by
*                   the group.
*/

// Importing Packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chronicles/screens/auth/user_detail_screen.dart';
import 'package:chronicles/screens/auth/change_password.dart';
import 'package:chronicles/screens/auth/forgot_password_screen.dart';
import 'package:chronicles/screens/auth/login_screen.dart';
import 'package:chronicles/screens/auth/pin_login_screen.dart';
import 'package:chronicles/screens/auth/register_screen.dart';
import 'package:chronicles/screens/auth/welcome_screen.dart';
import 'package:chronicles/screens/auth/otp_screen.dart';
import 'package:chronicles/screens/dashboard/dashboard.dart';
import 'package:chronicles/screens/profile/profile_screen.dart';
import 'package:chronicles/services/login_auth.dart';
import 'package:chronicles/services/pin_auth.dart';
import 'package:chronicles/themes/galactic_ocean.dart';
import 'package:chronicles/screens/text_editor/diary_archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chronicles/screens/settings/settings_default_view.dart';
import 'package:chronicles/screens/profile/edit_profile.dart';

// Main Function
void main() async {
  // Firebase init
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
  FirebaseFirestore.instance.clearPersistence();

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://fdtswjgykowvvydvymml.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkdHN3amd5a293dnZ5ZHZ5bW1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyOTQxNDcsImV4cCI6MjA1Nzg3MDE0N30.kfMEwPDxDxoDYXHhxaSeMGQLfbMG9U6CVnHPEjioH2k");

  // Running The APP
  runApp(
    Chronicles(),
  );

  // Hide Device Top and Bottom Navigation. [Full Screen]
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.top,
    ],
  );
}

// Chronicles Class builds the first Screen based on Auth.
class Chronicles extends StatelessWidget {
  const Chronicles({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getHomeScreen(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        Widget? homeScreen = snapshot.data;
        return MaterialApp(
          theme: galacticOcean,
          routes: {
            '/WelcomeScreen': (context) => WelcomeScreen(),
            '/Login': (context) => LoginScreen(),
            '/Register': (context) => RegisterScreen(),
            '/OtpScreen': (context) => OtpScreen(),
            '/Dashboard': (context) => Dashboard(),
            '/ForgotPassword': (context) => ForgotPasswordScreen(),
            '/ChangePassword': (context) => ChangePasswordScreen(),
            '/ProfileScreen': (context) => ProfileScreen(),
            '/DiaryArchive': (context) => DiaryArchive(),
            '/UsernameScreen': (context) => UsernameScreen(),
            '/SettingsScreen': (context) => SettingsScreen(),
          },
          home: homeScreen,
        );
      },
    );
  }
}

// _getHomeScreen function returns Screen based on Auth Values.
Future<Widget> _getHomeScreen(BuildContext context) async {
  final bool isUserLoginActive = await isLoginDone();
  final bool isPinLoginRequired = await isPinRequired();

  if (isUserLoginActive) {
    return isPinLoginRequired ? PinLoginScreen() : Dashboard();
  } else {
    return WelcomeScreen();
  }
}
