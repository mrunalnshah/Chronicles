import 'package:flutter/material.dart';
import '../../../services/add_friends_services.dart';
import '../../../services/pfp_services.dart';
import '../../../utilities/components/buttons/custom_action_button.dart';

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
  final AddFriendsService _service = AddFriendsService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String? currentUserId;
  List<String> friendsUid = [];
  Map<String, bool> pendingRequests = {};

  final String defaultProfileImage = "assets/images/icons/new_profile_icon.png";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    currentUserId = await _service.fetchUserId();
    friendsUid = await _service.loadFriendsUid(currentUserId!);
    users = await _service.loadUsers(currentUserId!, friendsUid);
    filteredUsers = users;

    setState(() {
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      pendingRequests = await _service.loadPendingRequests(currentUserId!);
      setState(() {});
    });
  }

  void _filterUsers(String query) {
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
      appBar: AppBar(title: Text('Add Friends')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _filterUsers,
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
                              double avatarRadius = 24;
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
                                    await _service.sendFriendRequest(
                                        currentUserId ?? '', userId);

                                    setState(() {
                                      pendingRequests[userId] = true;
                                    });
                                  },
                            label: isPending ? 'Pending' : 'Add Friend',
                            backgroundColor: isPending
                                ? Color(0xFFF4F4F4)
                                : Color(0xFF4EABCC),
                            borderColor: isPending
                                ? Color(0xFFDDDFE5)
                                : Color(0xFF3492B3),
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
