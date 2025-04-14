import 'package:flutter/material.dart';
import '../../../services/add_friends_services.dart';
import '../../../services/pfp_services.dart';
import '../../../utilities/components/buttons/custom_action_button.dart';

final String titleMessage = "Add Friends";
final String searchBarHintText = 'Search Users';
final String addFriendButtonText = 'Add Friend';
final String pendingButtonText = 'Pending';

final double overAllPadding = 8.0;
final double searchBarHeight = 50.0;
final double rightPaddingInSearchBar = 10.0;
final double searchBarBorderRadius = 25.0;
final double circleAvatarRadius = 24.0;

final Color searchBarIconColor = Colors.grey;
final Color searchBarColor = Colors.white;
final Color addFriendButtonColor = Color(0xFF4EABCC);
final Color pendingButtonColor = Color(0xFFF4F4F4);
final Color addFriendButtonBorderColor = Color(0xFF3492B3);
final Color pendingButtonBorderColor = Color(0xFFDDDFE5);

final titleMessageStyle = TextStyle(
  fontSize: 22.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

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

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final AddFriendsService addFriendsService = AddFriendsService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  TextEditingController searchBarController = TextEditingController();
  String? currentUserId;
  List<String> friendsUid = [];
  Map<String, bool> pendingRequests = {};

  final String defaultProfileImage = "assets/images/icons/new_profile_icon.png";

  @override
  void initState() {
    super.initState();
    loadFriendsData();
  }

  Future<void> loadFriendsData() async {
    currentUserId = await addFriendsService.fetchUserId();
    friendsUid = await addFriendsService.loadFriendsUid(currentUserId!);
    users = await addFriendsService.loadUsers(currentUserId!, friendsUid);
    filteredUsers = users;

    setState(() {
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      pendingRequests =
          await addFriendsService.loadPendingRequests(currentUserId!);
      setState(() {});
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleMessage,
          style: titleMessageStyle,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(overAllPadding),
            child: SizedBox(
              height: searchBarHeight,
              child: SearchBar(
                controller: searchBarController,
                hintText: searchBarHintText,
                trailing: [
                  Padding(
                    padding: EdgeInsets.only(right: rightPaddingInSearchBar),
                    child: Icon(Icons.search, color: searchBarIconColor),
                  ),
                ],
                onChanged: filterUsers,
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                backgroundColor: WidgetStateProperty.all(searchBarColor),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(searchBarBorderRadius),
                  ),
                ),
                elevation: WidgetStateProperty.all(2),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      String userId = user['uid'];
                      bool isPending = pendingRequests[userId] ?? false;

                      return ListTile(
                          leading: FutureBuilder<String?>(
                            future: fetchUserPfpUrl(userId),
                            builder: (context, snapshot) {
                              String? imageUrl = snapshot.data;
                              double avatarRadius = circleAvatarRadius;
                              return CircleAvatar(
                                radius: avatarRadius,
                                backgroundImage:
                                    imageUrl != null && imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : AssetImage(defaultProfileImage)
                                            as ImageProvider,
                                backgroundColor: Colors.transparent,
                              );
                            },
                          ),
                          title: Text(
                            user['username'],
                            style: usernameStyle.copyWith(height: 1.0),
                          ),
                          subtitle: Text(
                            '${user['firstname']} ${user['lastname']}',
                            style: fullNameStyle.copyWith(height: 1.0),
                          ),
                          trailing: CustomActionButton(
                            onPressed: isPending
                                ? null
                                : () async {
                                    await addFriendsService.sendFriendRequest(
                                        currentUserId ?? '', userId);

                                    setState(() {
                                      pendingRequests[userId] = true;
                                    });
                                  },
                            label: isPending
                                ? pendingButtonText
                                : addFriendButtonText,
                            backgroundColor: isPending
                                ? pendingButtonColor
                                : addFriendButtonColor,
                            borderColor: isPending
                                ? pendingButtonBorderColor
                                : addFriendButtonBorderColor,
                            textColor: isPending ? Colors.black : Colors.white,
                          ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
