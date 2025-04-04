import 'package:flutter/material.dart';
import '../../../services/friends_services.dart';
import '../../../utilities/components/List_Tile/friends_list_tile.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  final String defaultProfileImage = "assets/images/icons/new_profile_icon.png";
  final FriendServices _friendServices = FriendServices();

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    List<Map<String, String>> friendsList =
        await _friendServices.fetchFriends();
    setState(() {
      friends = friendsList;
      filteredFriends = friendsList;
    });
  }

  void _searchFriends(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) =>
              friend["username"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _removeFriend(String friendId) async {
    await _friendServices.removeFriend(friendId);
    _fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 5.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search friends by username...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchFriends,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: filteredFriends.isEmpty
                  ? _emptyState("No friends found.")
                  : ListView.builder(
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];

                        return FriendsListTile(
                          userId: friend["uid"]!,
                          username: friend["username"]!,
                          fullName:
                              "${friend["firstName"]} ${friend["lastName"]}"
                                  .trim(),
                          onRemove: _removeFriend,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo/panda_image.jpg',
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
