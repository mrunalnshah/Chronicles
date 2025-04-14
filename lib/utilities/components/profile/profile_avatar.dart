import 'dart:io';
import 'package:chronicles/services/pfp_services.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  final double circleAvatarRadius;

  const ProfileAvatar({
    Key? key,
    required this.circleAvatarRadius,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? profileImage;

  @override
  void initState() {
    super.initState();
    pfpDisplay();
  }

  Future<void> pfpDisplay() async {
    String? imagePath = await getSavedImagePath();
    if (mounted) {
      setState(() {
        if (imagePath != null) {
          profileImage = File(imagePath);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.circleAvatarRadius,
      backgroundColor: Colors.transparent,
      backgroundImage: profileImage != null
          ? FileImage(profileImage!,
              scale: DateTime.now().millisecondsSinceEpoch.toDouble())
          : const AssetImage('assets/images/icons/new_profile_icon.png'),
    );
  }
}
