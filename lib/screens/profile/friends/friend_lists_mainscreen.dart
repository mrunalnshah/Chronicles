import 'package:chronicles/screens/profile/friends/pending_friend_lists_screen.dart';
import 'package:flutter/material.dart';
import 'add_friends.dart';
import 'friends_list_display.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController _tabController;
  List<String> friends = [];
  List<String> pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Your Friends"),
            Tab(text: "Pending"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FriendsListPage(),
          PendingRequestsPage(),
        ],
      ),
    );
  }
}
