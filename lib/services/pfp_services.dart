import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utilities/data/user_auth_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? savedImagePath;
final supabase = Supabase.instance.client;
const String defaultAssetImage = "assets/images/default_profile.jpg";

Future<File?> pickImage() async {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    selectedImage = File(image.path);
    return selectedImage;
  }
  return null;
}

Future<String> fetchDefaultProfileUrl() async {
  try {
    const String defaultImagePath =
        'profile-images/default Image/new_profile_icon.png';

    final String defaultUrl =
        supabase.storage.from('profile-images').getPublicUrl(defaultImagePath);

    return defaultUrl;
  } catch (e) {
    return '';
  }
}

Future<String?> saveImage(File? selectedImage) async {
  if (selectedImage == null) return null;

  try {
    String userId = await UserDataFetcher().fetchUID();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String userFolderPath = '${appDir.path}/$userId/profile';

    final Directory profileDir = Directory(userFolderPath);
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final String imagePath = '$userFolderPath/profile.jpg';
    final File profileImageFile = File(imagePath);

    if (await profileImageFile.exists()) {
      await profileImageFile.delete();
      await Future.delayed(Duration(milliseconds: 200));
    }
    File newImage = await selectedImage.copy(imagePath);
    if (await newImage.exists()) {
      String savedImagePath = imagePath;
      return savedImagePath;
    }
  } catch (e) {
    //print('Error saving profile image: $e');
  }
  return null;
}

Future<void> uploadProfileImageToSupabase(File imageFile) async {
  try {
    String userId = await UserDataFetcher().fetchUID();
    final path = 'profile-images/$userId.jpg';
    await supabase.storage
        .from('profile-images')
        .upload(path, imageFile, fileOptions: const FileOptions(upsert: true));

    final publicUrl =
        supabase.storage.from('profile-images').getPublicUrl(path);
    await updateUrlInFirebase(userId, publicUrl);
  } catch (e) {
    //print('Upload error: $e');
  }
}

Future<void> updateUrlInFirebase(String uid, String imageUrl) async {
  try {
    await FirebaseFirestore.instance
        .collection('user_account')
        .doc(uid)
        .update({'pfp_url': imageUrl});
  } catch (e) {
    //print("Firestore update error: $e");
  }
}

Future<String?> updateSaveImage() async {
  try {
    String userId = await UserDataFetcher().fetchUID();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String userFolderPath = '${appDir.path}/$userId/profile';

    final Directory profileDir = Directory(userFolderPath);
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final String imagePath = '$userFolderPath/profile.jpg';
    final File profileImageFile = File(imagePath);

    String? supabaseImageUrl = await fetchImageFromSupabase(userId);

    if (supabaseImageUrl != null) {
      await downloadAndSaveImage(supabaseImageUrl, imagePath);

      if (await profileImageFile.exists()) {
        return imagePath;
      } else {
        //      print("Error: Image not saved correctly.");
      }
    } else {
//      print("No image found in Supabase.");
    }
  } catch (e) {
    print('Error saving profile image: $e');
    //print('Error updating profile image: $e');
  }
  return null;
}

Future<String?> fetchImageFromSupabase(String userId) async {
  final String imagePath = 'profile-images/$userId.jpg';

  try {
    final response = await supabase.storage
        .from('profile-images')
        .createSignedUrl(imagePath, 3600);

    return response;
  } catch (e) {
    //print('Error fetching image from Supabase: $e');
    return null;
  }
}

Future<void> downloadAndSaveImage(String imageUrl, String savePath) async {
  try {
    final downloadImage = await http.get(Uri.parse(imageUrl));
    if (downloadImage.statusCode == 200) {
      File file = File(savePath);
      await file.writeAsBytes(downloadImage.bodyBytes);
    } else {
      //print("Failed to download image, status code: ${downloadImage.statusCode}");
    }
  } catch (e) {
    //print('Error downloading image: $e');
  }
}

Future<String?> getSavedImagePath() async {
  try {
    String userId = await UserDataFetcher().fetchUID();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = '${appDir.path}/$userId/profile/profile.jpg';

    if (await File(imagePath).exists()) {
      return imagePath;
    }
  } catch (e) {
    //print('Error retrieving profile image path: $e');
  }
  return null;
}

Future<String?> fetchUserPfpUrl(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('user_account')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data()?['pfp_url'];
    }
  } catch (e) {
    print('Error fetching profile image URL: $e');
  }
  return null;
}
