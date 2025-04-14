/*
* File Name        : google_auth.dart
* Group            : trOlsz Group
* Description      : This file is has code for google Authentication.
*/

import 'package:flutter/material.dart';
import 'package:chronicles/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronicles/services/user_service.dart';
import 'package:chronicles/utilities/data/user_auth_data.dart';
import 'package:chronicles/services/pfp_services.dart';

Future<bool> isGoogleAuthenticationDone(BuildContext context) async {
  SecureStorage storage = SecureStorage();
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return false;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    String uid = userCredential.user!.uid;
    UserData data;
    DateTime nowTime = DateTime.now();

    DocumentSnapshot Doc = await FirebaseFirestore.instance
        .collection('user_account')
        .doc(uid)
        .get();

    String username;
    int nextIndex;
    bool isFirstTime = !Doc.exists;

    if (user == null) {
      return false;
    }

    if (Doc.exists) {
      username = Doc['username'];
      updateSaveImage();
      getSavedImagePath();
    } else {
      nextIndex = await getNextUserIndex();
      username = 'user${nextIndex.toString().padLeft(4, '0')}';

      await FirebaseFirestore.instance.collection('user_account').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': user.email ?? "",
        'firstname': user.displayName?.split(" ").first ?? "",
        'lastname': user.displayName?.split(" ").last ?? "",
        'gender': 3,
        'dob': '',
        'pfp_url': '',
        'friends_uid': [],
        'join_date': nowTime.millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user_account')
        .doc(uid)
        .get();

    data = UserData(
      uid: uid,
      email: userDoc['email'],
      username: userDoc['username'],
      firstName: userDoc['firstname'],
      lastName: userDoc['lastname'],
      joinDate: userDoc['join_date'],
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      Doc.exists ? '/Dashboard' : '/UsernameScreen',
      (Route<dynamic> route) => false,
    );

    storage.updateSecureData('isLoginDone', 'true');
    storage.updateSecureData('isPinRequired', 'false');
    await storage.updateSecureData(
        'isUserDetailDone', isFirstTime ? 'false' : 'true');

    String dataString = data.toJson();
    await storage.updateSecureData('UserData', dataString);
    return true;
  } catch (e) {
    return false;
  }
}
