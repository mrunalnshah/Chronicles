/*
* File Name        : register_auth.dart
* Group            : trOlsz Group
* Description      : This file is has code for Register Authentication.
*/

import 'package:chronicles/utilities/data/user_auth_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronicles/services/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:chronicles/services/user_service.dart';

Future<String> registerAuthentication(BuildContext context, String firstName,
    String lastName, String email, String password) async {
  if (email.isEmpty ||
      password.isEmpty ||
      firstName.isEmpty ||
      lastName.isEmpty) {
    return 'emptyFields';
  }

  SecureStorage storage = SecureStorage();

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserData data;
    String uid = userCredential.user!.uid;
    DateTime nowTime = DateTime.now();
    int nextIndex = await getNextUserIndex();
    String username = 'user${nextIndex.toString().padLeft(4, '0')}';

    try {
      await FirebaseFirestore.instance.collection('user_account').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'firstname': firstName,
        'lastname': lastName,
        'gender': 3,
        'dob': '',
        'pfp_url': '',
        'friends_uid': [],
        'join_date': nowTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      print("Firestore Error: $e");
    }

    data = UserData(
      uid: uid,
      email: email,
      username: username,
      firstName: firstName,
      lastName: lastName,
      joinDate: nowTime.millisecondsSinceEpoch,
    );
    String dataString = data.toJson();
    await storage.updateSecureData('UserData', dataString);

    storage.updateSecureData('isLoginDone', 'true');
    storage.updateSecureData('isPinRequired', 'false');

    updateUserIndex(nextIndex);

    return 'true';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      storage.updateSecureData('isLoginDone', 'false');
      storage.updateSecureData('isPinRequired', 'false');
      return 'emailAlreadyUsed';
    } else if (e.code == 'invalid-email') {
      storage.updateSecureData('isLoginDone', 'false');
      return "invalidEmailSyntax";
    }
  }
  storage.updateSecureData('isLoginDone', 'false');
  storage.updateSecureData('isPinRequired', 'false');
  return 'unexpectedError';
}
