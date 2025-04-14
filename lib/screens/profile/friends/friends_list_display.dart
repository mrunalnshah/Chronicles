import 'package:flutter/material.dart';
import '../../../services/friends_services.dart';
import '../../../utilities/components/List_Tile/friends_list_tile.dart';

final String searchBarHintText = 'Search by Username';
final String emptyFriendListText = 'No friends found';
final String pandaImagePath = 'assets/images/logo/panda_image.jpg';

final double verticalOverAllPadding = 5.0;
final double horizontalOverAllPadding = 3.0;
final double searchBarOverAllPadding = 4.0;
final double searchBarHeight = 50.0;
final double rightPaddingInSearchBar = 10.0;
final double searchBarBorderRadius = 25.0;
final double pandaIconHeight = 150.0;
final double spaceBetweenPandaIconAndText = 16.0;

final Color searchBarColor = Colors.white;
final Color searchBarIconColor = Colors.grey;

final emptyFriendListTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final TextEditingController searchBarController = TextEditingController();
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  final String defaultProfileImage = "assets/images/icons/new_profile_icon.png";
  final FriendServices friendServices = FriendServices();

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    List<Map<String, String>> friendsList = await friendServices.fetchFriends();
    setState(() {
      friends = friendsList;
      filteredFriends = friendsList;
    });
  }

  void searchFriendsByUsername(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) =>
              friend["username"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> removeFriends(String friendId) async {
    await friendServices.removeFriend(friendId);
    loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalOverAllPadding,
          vertical: verticalOverAllPadding),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(searchBarOverAllPadding),
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
                onChanged: searchFriendsByUsername,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: filteredFriends.isEmpty
                  ? emptyFriendList(emptyFriendListText)
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
                          onRemove: removeFriends,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyFriendList(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            pandaImagePath,
            height: pandaIconHeight,
          ),
          SizedBox(height: spaceBetweenPandaIconAndText),
          Text(
            message,
            style: emptyFriendListTextStyle,
          ),
        ],
      ),
    );
  }
}
