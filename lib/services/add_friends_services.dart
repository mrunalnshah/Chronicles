import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utilities/data/user_auth_data.dart';

class AddFriendsService {
  Future<String> fetchUserId() async {
    return await UserDataFetcher().fetchUID();
  }

  Future<List<String>> loadFriendsUid(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('user_account')
        .doc(userId)
        .get();

    if (userDoc.exists && userDoc.data()?['friends_uid'] != null) {
      return List<String>.from(userDoc.data()?['friends_uid']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> loadUsers(
      String currentUserId, List<String> friendsUid) async {
    final usersRef = FirebaseFirestore.instance.collection('user_account');
    final querySnapshot = await usersRef.get();

    List<Map<String, dynamic>> fetchedUsers = [];
    for (var doc in querySnapshot.docs) {
      String userId = doc.id;

      if (userId != currentUserId && !friendsUid.contains(userId)) {
        fetchedUsers.add(doc.data());
      }
    }
    return fetchedUsers;
  }

  Future<Map<String, bool>> loadPendingRequests(String currentUserId) async {
    final requestRef = FirebaseFirestore.instance.collection('friend_requests');
    final querySnapshot = await requestRef
        .where('senderId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    Map<String, bool> pendingMap = {};
    for (var doc in querySnapshot.docs) {
      String receiverId = doc['receiverId'];
      pendingMap[receiverId] = true;
    }
    return pendingMap;
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    if (senderId.isEmpty) {
      return;
    }

    final requestRef = FirebaseFirestore.instance.collection('friend_requests');

    final existingRequest = await requestRef
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      print("Friend request already sent!");
      return;
    }

    await requestRef.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Friend request sent!");
  }
}
