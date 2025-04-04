import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    return auth.currentUser?.uid;
  }

  Future<List<Map<String, String>>> fetchFriends() async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return [];

    DocumentSnapshot userSnapshot =
        await firestore.collection('user_account').doc(currentUserId).get();

    if (!userSnapshot.exists) return [];

    List<String> friendsUid =
        List<String>.from(userSnapshot["friends_uid"] ?? []);
    if (friendsUid.isEmpty) return [];

    List<Map<String, String>> friendsList = [];
    for (String uid in friendsUid) {
      Map<String, String>? friendData = await _getUserDetails(uid);
      if (friendData != null) friendsList.add(friendData);
    }
    return friendsList;
  }

  Future<void> removeFriend(String friendId) async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;

    WriteBatch batch = firestore.batch();
    batch.update(firestore.collection('user_account').doc(currentUserId), {
      "friends_uid": FieldValue.arrayRemove([friendId])
    });
    batch.update(firestore.collection('user_account').doc(friendId), {
      "friends_uid": FieldValue.arrayRemove([currentUserId])
    });

    await batch.commit();
  }

  Future<List<Map<String, String>>> fetchPendingRequests(
      bool isReceived) async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return [];

    String field = isReceived ? "receiverId" : "senderId";
    QuerySnapshot snapshot = await firestore
        .collection('friend_requests')
        .where(field, isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    List<Map<String, String>> requests = [];
    for (var doc in snapshot.docs) {
      String userId = (doc.data()
          as Map<String, dynamic>)[isReceived ? "senderId" : "receiverId"];
      Map<String, String>? userData = await _getUserDetails(userId);
      if (userData != null) {
        requests.add({
          "id": doc.id,
          "userId": userId,
          ...userData,
        });
      }
    }
    return requests;
  }

  Future<Map<String, String>?> _getUserDetails(String userId) async {
    DocumentSnapshot userDoc =
        await firestore.collection('user_account').doc(userId).get();
    if (!userDoc.exists) return null;

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return {
      "uid": userId,
      "username": userData["username"] ?? "Unknown",
      "firstName": userData["firstname"] ?? "",
      "lastName": userData["lastname"] ?? "",
    };
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    String? currentUserId = await getCurrentUserId();
    if (currentUserId == null) return;

    WriteBatch batch = firestore.batch();
    batch.update(firestore.collection('user_account').doc(currentUserId), {
      "friends_uid": FieldValue.arrayUnion([senderId])
    });
    batch.update(firestore.collection('user_account').doc(senderId), {
      "friends_uid": FieldValue.arrayUnion([currentUserId])
    });
    batch.delete(firestore.collection('friend_requests').doc(requestId));

    await batch.commit();
  }

  Future<void> deleteRequest(String requestId) async {
    await firestore.collection('friend_requests').doc(requestId).delete();
  }
}
