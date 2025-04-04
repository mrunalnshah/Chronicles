import 'package:flutter/material.dart';
import '../../../services/friends_services.dart';
import '../../../utilities/components/List_Tile/friends_list_tile.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  final FriendServices _friendsService = FriendServices();
  List<Map<String, String>> receivedRequests = [];
  List<Map<String, String>> sentRequests = [];

  bool _showReceived = false; // Toggle for received requests
  bool _showSent = false; // Toggle for sent requests

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    List<Map<String, String>> receivedList =
        await _friendsService.fetchPendingRequests(true);
    List<Map<String, String>> sentList =
        await _friendsService.fetchPendingRequests(false);

    setState(() {
      receivedRequests = receivedList;
      sentRequests = sentList;
    });
  }

  Future<void> _acceptRequest(String requestId, String senderId) async {
    await _friendsService.acceptRequest(requestId, senderId);
    _fetchPendingRequests();
  }

  Future<void> _deleteRequest(String requestId, bool isReceived) async {
    await _friendsService.deleteRequest(requestId);
    _fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 4.0, bottom: 8.0, right: 8.0, left: 8.0),
      child: Column(
        children: [
          _buildExpandableSection(
              "Pending Friend Requests (Received)",
              receivedRequests,
              _showReceived,
              (value) => setState(() => _showReceived = value),
              true),
          const SizedBox(height: 10),
          _buildExpandableSection("Sent Friend Requests", sentRequests,
              _showSent, (value) => setState(() => _showSent = value), false),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
      String title,
      List<Map<String, String>> requests,
      bool isExpanded,
      Function(bool) toggleExpand,
      bool isReceived) {
    return Column(
      children: [
        InkWell(
          onTap: () => toggleExpand(!isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
            child: requests.isEmpty
                ? _emptyState("No requests available.")
                : Column(
                    children: requests.map((request) {
                      final String userId = request["userId"] ?? "";
                      final String username = request["username"] ?? "Unknown";
                      final String requestId = request["id"] ?? "";
                      final String firstName = request["firstName"] ?? "";
                      final String lastName = request["lastName"] ?? "";
                      final String fullName =
                          (firstName.isNotEmpty || lastName.isNotEmpty)
                              ? "$firstName $lastName"
                              : "Unknown User";

                      return FriendsListTile(
                        userId: userId,
                        username: username,
                        fullName: fullName,
                        requestId: requestId,
                        isReceived: isReceived,
                        onAccept: isReceived ? _acceptRequest : null,
                        onDelete: _deleteRequest,
                      );
                    }).toList(),
                  ),
          ),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo/panda_image.jpg',
            height: 100,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
