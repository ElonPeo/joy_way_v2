import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/request/make_friend.dart';

class MakeFriendFirestore {
  static const String _col = 'make_friend_requests';
  final FirebaseFirestore _db;
  MakeFriendFirestore({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<String?> createRequest({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final docRef = _db.collection(_col).doc();
      await docRef.set({
        'id': docRef.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'isAccepted': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<MakeFriend>> getLatestReceivedRequests(String userId) {
    return _db
        .collection(_col)
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MakeFriend.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }






}
