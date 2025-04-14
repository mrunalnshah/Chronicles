import 'package:flutter/material.dart';
import '../../../services/friends_services.dart';
import '../../../utilities/components/List_Tile/friends_list_tile.dart';

final String pandaImagePath = 'assets/images/logo/panda_image.jpg';
final String receivedRequestText = 'Pending Friend Requests (Received)';
final String sentRequestText = 'Sent Friend Requests';
final String emptyFriendListText = 'No friends found';

final double overAllPadding = 8.0;
final double overAllTopPadding = 4.0;
final double spaceBetweenExpandableList = 10.0;
final double padding_5 = 5.0;
final double upDownIconSize = 24.0;
final double emptyListOverAllPadding = 12.0;
final double pandaIconHeight = 150.0;
final double height_10 = 10.0;

final friendListTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F1F1F),
);

final emptyFriendListTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Hind',
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F1F1F),
);

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  final FriendServices friendService = FriendServices();
  List<Map<String, String>> receivedRequests = [];
  List<Map<String, String>> sentRequests = [];

  bool showReceivedRequest = false;
  bool showSendRequest = false;

  @override
  void initState() {
    super.initState();
    pendingRequest();
  }

  Future<void> pendingRequest() async {
    List<Map<String, String>> receivedList =
        await friendService.fetchPendingRequests(true);
    List<Map<String, String>> sentList =
        await friendService.fetchPendingRequests(false);

    setState(() {
      receivedRequests = receivedList;
      sentRequests = sentList;
    });
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    await friendService.acceptRequest(requestId, senderId);
    pendingRequest();
  }

  Future<void> cancelRequest(String requestId, bool isReceived) async {
    await friendService.deleteRequest(requestId);
    pendingRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          overAllPadding, overAllTopPadding, overAllPadding, overAllPadding),
      child: Column(
        children: [
          requestExpandableSection(
              receivedRequestText,
              receivedRequests,
              showReceivedRequest,
              (value) => setState(() => showReceivedRequest = value),
              true),
          SizedBox(height: spaceBetweenExpandableList),
          requestExpandableSection(
              sentRequestText,
              sentRequests,
              showSendRequest,
              (value) => setState(() => showSendRequest = value),
              false),
        ],
      ),
    );
  }

  Widget requestExpandableSection(
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
            padding: EdgeInsets.symmetric(
                vertical: padding_5, horizontal: padding_5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: friendListTextStyle,
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: upDownIconSize,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(
                top: overAllTopPadding,
                right: overAllPadding,
                left: overAllPadding),
            child: requests.isEmpty
                ? emptyFriendList(emptyFriendListText)
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
                        onAccept: isReceived ? acceptRequest : null,
                        onDelete: cancelRequest,
                      );
                    }).toList(),
                  ),
          ),
      ],
    );
  }

  Widget emptyFriendList(String message) {
    return Padding(
      padding: EdgeInsets.all(emptyListOverAllPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            pandaImagePath,
            height: pandaIconHeight,
          ),
          SizedBox(height: height_10),
          Text(
            message,
            style: emptyFriendListTextStyle,
          ),
        ],
      ),
    );
  }
}
