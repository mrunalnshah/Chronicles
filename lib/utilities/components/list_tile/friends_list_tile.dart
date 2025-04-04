import 'package:flutter/material.dart';
import '../../../services/pfp_services.dart';
import '../buttons/custom_action_button.dart';

final usernameStyle = TextStyle(
  fontSize: 18.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final fullNameStyle = TextStyle(
  fontSize: 14.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w400,
  color: Color(0x901F1F1F),
);

TextStyle buttonLabelTextStyle({required Color textColor}) {
  return TextStyle(
    color: textColor,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 0.5,
  );
}

class FriendsListTile extends StatelessWidget {
  final String userId;
  final String username;
  final String fullName;
  final String? requestId;
  final bool? isReceived;
  final void Function(String, String)? onAccept;
  final void Function(String, bool)? onDelete;
  final void Function(String)? onRemove;

  const FriendsListTile({
    super.key,
    required this.userId,
    required this.username,
    required this.fullName,
    this.requestId,
    this.isReceived,
    this.onAccept,
    this.onDelete,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const String defaultProfileImage =
        "assets/images/icons/new_profile_icon.png";

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      leading: FutureBuilder<String?>(
        future: fetchUserPfpUrl(userId),
        builder: (context, snapshot) {
          return CircleAvatar(
            radius: 24,
            backgroundImage: snapshot.hasData && snapshot.data!.isNotEmpty
                ? NetworkImage(snapshot.data!)
                : AssetImage(defaultProfileImage) as ImageProvider,
            backgroundColor: Colors.transparent,
          );
        },
      ),
      title: Text(
        username,
        style: usernameStyle.copyWith(height: 1.0),
      ),
      subtitle: Text(
        fullName,
        style: fullNameStyle.copyWith(height: 1.0),
      ),
      trailing: _buildTrailingActions(),
    );
  }

  Widget _buildTrailingActions() {
    if (isReceived == true && requestId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomActionButton(
            onPressed: () => onAccept?.call(requestId!, userId),
            label: "Accept",
            backgroundColor: Color(0xFF4EABCC),
            textColor: Colors.white,
            borderColor: Color(0xFF3492B3),
            width: 80,
            height: 45,
          ),
          SizedBox(
            width: 5,
          ),
          CustomActionButton(
            onPressed: () => onDelete?.call(requestId!, true),
            label: "Reject",
            backgroundColor: Color(0xFFF4F4F4),
            textColor: Colors.black,
            borderColor: Color(0xFFDDDFE5),
            width: 80,
            height: 45,
          ),
        ],
      );
    } else if (isReceived == false && requestId != null) {
      //onPressed: () => onDelete?.call(requestId!, false),
      return CustomActionButton(
        onPressed: () => onDelete?.call(requestId!, false),
        label: "Cancel",
        backgroundColor: Color(0xFFF4F4F4),
        textColor: Colors.black,
        borderColor: Color(0xFFDDDFE5),
        width: 90,
        height: 45,
      );
    } else if (onRemove != null) {
      // onPressed: () => onRemove?.call(userId),
      return CustomActionButton(
        onPressed: () => onRemove?.call(userId),
        label: "Remove",
        backgroundColor: Color(0xFFF4F4F4),
        textColor: Colors.black,
        borderColor: Color(0xFFDDDFE5),
        width: 90,
        height: 45,
      );
    }
    return const SizedBox.shrink();
  }
}
