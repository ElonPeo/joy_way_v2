import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/request/request_journey/request_join_journey/request_join_journey.dart';

class RequestJoinJourneyServices {
  final FirebaseFirestore _db;

  RequestJoinJourneyServices({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Collection chính
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('request_join_journey');

  /// Tạo request mới (id tự sinh)
  Future<String?> createRequest(RequestJoinJourney request) async {
    try {
      final doc = _col.doc();
      final newRequest = request.copyWith(
        id: doc.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await doc.set(newRequest.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Lấy request theo id
  Future<Map<String, dynamic>> getRequestById(String id) async {
    try {
      final snap = await _col.doc(id).get();
      if (!snap.exists) {
        return {'error': null, 'data': null};
      }
      final data = RequestJoinJourney.fromMap(snap.data()!, id: snap.id);
      return {'error': null, 'data': data};
    } catch (e) {
      return {'error': e.toString(), 'data': null};
    }
  }

  /// Stream tất cả request gửi đến người dùng hiện tại
  Stream<Map<String, dynamic>> streamRequestsByReceiver(String receiverId) async* {
    try {
      yield* _col
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => {
        'error': null,
        'data': snapshot.docs
            .map((doc) => RequestJoinJourney.fromMap(doc.data(), id: doc.id))
            .toList(),
      });
    } catch (e) {
      yield {'error': e.toString(), 'data': []};
    }
  }

  /// 🔹 Stream tất cả request mà user hiện tại đã gửi đi (sender)
  Stream<Map<String, dynamic>> streamRequestsBySender(String senderId) async* {
    try {
      yield* _col
          .where('senderId', isEqualTo: senderId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => {
        'error': null,
        'data': snapshot.docs
            .map((doc) => RequestJoinJourney.fromMap(doc.data(), id: doc.id))
            .toList(),
      });
    } catch (e) {
      yield {'error': e.toString(), 'data': []};
    }
  }

  /// 🔹 Cập nhật trạng thái chấp nhận request
  Future<String?> updateRequestStatus({
    required String requestId,
    required bool isAccepted,
  }) async {
    try {
      await _col.doc(requestId).update({
        'isAccepted': isAccepted,
        'updatedAt': DateTime.now(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 🔹 Xoá request
  Future<String?> deleteRequest(String requestId) async {
    try {
      await _col.doc(requestId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Stream danh sách userId (senderId) của các yêu cầu thuộc 1 postId
  Stream<List<String>> streamSenderIdsByPostId(String postId) async* {
    if (postId.trim().isEmpty) {
      yield [];
      return;
    }
    try {
      yield* _col
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final ids = snapshot.docs
            .map((d) => d.data()['senderId'])
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet()      // loại trùng
            .toList();
        print( 'lsajkbvaksj ${ids}');
        return ids;
      });
    } catch (e) {
      yield [];
    }
  }




}
