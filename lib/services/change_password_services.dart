import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Change Password without old password
  Future<String?> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "User not found. Please log in again.";

      await user.updatePassword(newPassword);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return "You need to log in again to update your password.";
      }
      return "Error: ${e.message}";
    } catch (e) {
      return "An unexpected error occurred. Try again.";
    }
  }
}
