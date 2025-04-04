/*
* File Name        : pin_auth.dart
* Group            : trOlsz Group
* Description      : This file is has code for Pin Authentication.
*/

import 'package:chronicles/services/secure_storage.dart';

Future<bool> isPinRequired() async {
  SecureStorage loginAuth = SecureStorage();

  String value = await loginAuth.readSecureData('isPinRequired');
  if (value != 'null') {
    if (value == 'true') {
      return true;
    } else {
      return false;
    }
  }
  if (value == 'null') {
    loginAuth.writeSecureData('isPinRequired', 'false');
  }
  return false;
}
