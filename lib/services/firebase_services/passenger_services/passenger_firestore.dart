import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/passenger/passengers.dart';

class PassengerFirestore {
  final FirebaseFirestore _db;
  PassengerFirestore({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// 🔹 Tạo passenger mới — id = `${postId}_${userId}`
  Future<String?> createPassenger({
    required String postId,
    required String userId,
    required String requestId,
  }) async {
    try {
      final id = '${postId}_$userId';
      final ref = _db.collection('passengers').doc(id);

      final passenger = Passenger(
        id: id,
        postId: postId,
        userId: userId,
        requestId: requestId,
        status: PassengerStatus.pending,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );

      await ref.set(passenger.toMap());
      return null; // ✅ thành công
    } catch (e) {
      print('❌ createPassenger error: $e');
      return e.toString(); // ❌ lỗi
    }
  }

  /// 🔹 Stream danh sách userId của tất cả passengers trong post được truyền vào
  Stream<List<String>> streamUserIdsByPostId(String postId) async* {
    if (postId.trim().isEmpty) {
      yield [];
      return;
    }

    try {
      yield* _db
          .collection('passengers')
          .where('postId', isEqualTo: postId)
          .snapshots()
          .map((snapshot) {
        final userIds = snapshot.docs
            .map((doc) => doc.data()['userId'])
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();
        return userIds;
      });
    } catch (e) {
      print('❌ streamUserIdsByPostId error: $e');
      yield [];
    }
  }

  /// 🔹 Lấy danh sách userId của tất cả passengers trong post được truyền vào
  Future<List<String>> getUserIdsByPostId(String postId) async {
    if (postId.trim().isEmpty) return [];

    try {
      final snapshot = await _db
          .collection('passengers')
          .where('postId', isEqualTo: postId)
          .get();

      final userIds = snapshot.docs
          .map((doc) => doc.data()['userId'])
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      return userIds;
    } catch (e) {
      print('❌ getUserIdsByPostId error: $e');
      return [];
    }
  }


  /// 🔹 Stream toàn bộ danh sách Passenger trong 1 post
  Stream<List<Passenger>> streamPassengersByPostId({required String postId}) async* {
    if (postId.trim().isEmpty) {
      yield [];
      return;
    }

    try {
      yield* _db
          .collection('passengers')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        final passengers = snapshot.docs.map(Passenger.fromDoc).toList();
        return passengers;
      });
    } catch (e) {
      print('❌ streamPassengersByPostId error: $e');
      yield [];
    }
  }

  /// 🔹 Cập nhật trạng thái passenger theo id
  Future<String?> updatePassengerStatus({
    required String passengerId,
    required PassengerStatus newStatus,
  }) async {
    try {
      final ref = _db.collection('passengers').doc(passengerId);
      final now = DateTime.now();

      final Map<String, dynamic> updateData = {
        'status': newStatus.name,
        'lastUpdatedAt': now,
      };

      switch (newStatus) {
        case PassengerStatus.preparingPickup:
          updateData['preparingPickupAt'] = now;
          break;
        case PassengerStatus.pickedUp:
          updateData['pickedUpAt'] = now;
          break;
        case PassengerStatus.droppedOff:
          updateData['droppedOffAt'] = now;
          break;
        case PassengerStatus.canceledByDriver:
          updateData['canceledByDriverAt'] = now;
          break;
        case PassengerStatus.canceledByPassenger:
          updateData['canceledByPassengerAt'] = now;
          break;
        case PassengerStatus.noShow:
          updateData['noShowAt'] = now;
          break;
        default:
          break;
      }

      await ref.update(updateData);
      return null; // ✅ thành công
    } catch (e) {
      print('❌ updatePassengerStatus error: $e');
      return e.toString(); // ❌ lỗi
    }
  }


  Future<List<String>> getPassengerIdsByPostId(String postId) async {
    if (postId.trim().isEmpty) return [];

    try {
      final snap = await _db
          .collection('passengers')
          .where('postId', isEqualTo: postId)
          .get();

      // Lấy danh sách id của tài liệu (document ID)
      final ids = snap.docs.map((d) => d.id).toList();

      return ids;
    } catch (e) {
      print('❌ getPassengerIdsByPostId error: $e');
      return [];
    }
  }


}
