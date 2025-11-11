import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/passenger/passengers.dart';

class PassengerFirestore {
  final FirebaseFirestore _db;
  PassengerFirestore({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<void> createPassengerRecord({
    required String postId,
    required String userId,
    required String requestId,
  }) async {
    final pid = postId.trim(), uid = userId.trim(), rid = requestId.trim();
    if (pid.isEmpty || uid.isEmpty || rid.isEmpty) {
      throw Exception('postId/userId/requestId trống');
    }

    final docId = '${pid}_$uid';
    final ref = _db.collection('passengers').doc(docId);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'id': docId,
        'postId': pid,                 // 🔹 lưu
        'userId': uid,                 // 🔹 lưu
        'requestId': rid,
        'status': PassengerStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'status': PassengerStatus.pending.name,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Passenger>> streamByUser({
    required String userId,
    List<PassengerStatus>? inStatuses,
    int? limit,
  }) {
    Query<Map<String, dynamic>> q =
    _db.collection('passengers').where('userId', isEqualTo: userId);

    if (inStatuses != null && inStatuses.isNotEmpty) {
      q = q.where('status', whereIn: inStatuses.map((e) => e.name).toList());
    }
    q = q.orderBy('lastUpdatedAt', descending: true);
    if (limit != null && limit > 0) q = q.limit(limit);

    return q.snapshots().map((s) => s.docs.map(Passenger.fromDoc).toList());
  }

  Stream<List<Passenger>> streamByPost({
    required String postId,
    List<PassengerStatus>? inStatuses,
    int? limit,
  }) {
    Query<Map<String, dynamic>> q =
    _db.collection('passengers').where('postId', isEqualTo: postId);

    if (inStatuses != null && inStatuses.isNotEmpty) {
      q = q.where('status', whereIn: inStatuses.map((e) => e.name).toList());
    }
    q = q.orderBy('lastUpdatedAt', descending: true);
    if (limit != null && limit > 0) q = q.limit(limit);

    return q.snapshots().map((s) => s.docs.map(Passenger.fromDoc).toList());
  }


  Future<void> updatePassengerStatus({
    required String passengerId,
    required PassengerStatus newStatus,
  }) async {
    try {
      final ref = _db.collection('passengers').doc(passengerId);
      final snap = await ref.get();

      if (!snap.exists) {
        throw Exception('Passenger không tồn tại: $passengerId');
      }

      final now = FieldValue.serverTimestamp();
      final updates = <String, dynamic>{
        'status': newStatus.name,
        'lastUpdatedAt': now,
      };

      switch (newStatus) {
        case PassengerStatus.preparingPickup:
          updates['preparingPickupAt'] = now;
          break;
        case PassengerStatus.pickedUp:
          updates['pickedUpAt'] = now;
          break;
        case PassengerStatus.droppedOff:
          updates['droppedOffAt'] = now;
          break;
        case PassengerStatus.canceledByDriver:
          updates['canceledByDriverAt'] = now;
          break;
        case PassengerStatus.canceledByPassenger:
          updates['canceledByPassengerAt'] = now;
          break;
        case PassengerStatus.noShow:
          updates['noShowAt'] = now;
          break;
        case PassengerStatus.pending:
          break;
      }

      await ref.update(updates);
      print('✅ Cập nhật thành công: $passengerId → ${newStatus.name}');
    } catch (e, st) {
      print('❌ Lỗi khi cập nhật Passenger [$passengerId]: $e');
      print(st);
      rethrow; // hoặc throw Exception('Lỗi cập nhật Passenger');
    }
  }





}
