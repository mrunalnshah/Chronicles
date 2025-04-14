/*
* File Name        : login_auth.dart
* Group            : trOlsz Group
* Description      : This file is has code for Login Authentication.
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronicles/services/secure_storage.dart';

import 'package:chronicles/utilities/data/user_auth_data.dart';

Future<bool> isLoginDone() async {
  SecureStorage loginAuth = SecureStorage();

  String value = await loginAuth.readSecureData('isLoginDone');
  if (value != 'null') {
    if (value == 'true') {
      return true;
    } else {
      return false;
    }
  }
  loginAuth.writeSecureData('isLoginDone', 'false');
  return false;
}

Future<String> loginAuthentication(
    context, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return 'emptyFields';
  }

  SecureStorage storage = SecureStorage();

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;
    UserData data;
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

    String dataString = data.toJson();

    await storage.updateSecureData('UserData', dataString);
    storage.updateSecureData('isLoginDone', 'true');
    storage.updateSecureData('isPinRequired', 'false');
    storage.updateSecureData('isUserDetailDone', 'true');

    return 'true';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-credential') {
      storage.updateSecureData('isLoginDone', 'false');
      storage.updateSecureData('isPinRequired', 'false');
      storage.updateSecureData('isUserDetailDone', 'false');

      return "invalidCredentials";
    } else if (e.code == 'invalid-email') {
      storage.updateSecureData('isLoginDone', 'false');
      storage.updateSecureData('isPinRequired', 'false');
      storage.updateSecureData('isUserDetailDone', 'false');

      return "invalidEmailSyntax";
    }
    storage.updateSecureData('isLoginDone', 'false');
    storage.updateSecureData('isPinRequired', 'false');
    storage.updateSecureData('isUserDetailDone', 'false');

    return "unexpectedError";
  }
}
