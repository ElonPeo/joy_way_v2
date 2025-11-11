
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user/user_activity.dart';

class UserActivityServices {
  UserActivityServices._();
  static final UserActivityServices I = UserActivityServices._();

  static const _col = 'userActivities';
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection(_col).doc(uid);


  /// Tạo doc rỗng nếu chưa tồn tại
  Future<void> _ensureDoc(String uid) async {
    final ref = _ref(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(const UserActivity(id: '')
          .toMap(), SetOptions(merge: true)); // id ko lưu trong doc
    }
  }

  /// Theo dõi (myUid -> follow -> targetUid)
  Future<void> follow({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid == targetUid) return; // không tự follow chính mình

    await _db.runTransaction((tx) async {
      final myRef = _ref(myUid);
      final tgRef = _ref(targetUid);

      final mySnap = await tx.get(myRef);
      final tgSnap = await tx.get(tgRef);

      // đảm bảo doc tồn tại
      if (!mySnap.exists) {
        tx.set(myRef, const UserActivity(id: '').toMap(), SetOptions(merge: true));
      }
      if (!tgSnap.exists) {
        tx.set(tgRef, const UserActivity(id: '').toMap(), SetOptions(merge: true));
      }

      final myData = mySnap.data() ?? {};
      final tgData = tgSnap.data() ?? {};

      final myFollowing = List<String>.from(myData['followingIds'] ?? const []);
      final tgFollowers = List<String>.from(tgData['followerIds'] ?? const []);

      final already = myFollowing.contains(targetUid);
      if (already) return; // idempotent

      // update mảng + đếm
      tx.update(myRef, {
        'followingIds': FieldValue.arrayUnion([targetUid]),
        'followingCount': (myData['followingCount'] ?? 0) + 1,
      });

      tx.update(tgRef, {
        'followerIds': FieldValue.arrayUnion([myUid]),
        'followerCount': (tgData['followerCount'] ?? 0) + 1,
      });
    });
  }

  /// Bỏ theo dõi (myUid -> unfollow -> targetUid)
  Future<void> unfollow({
    required String myUid,
    required String targetUid,
  }) async {
    if (myUid == targetUid) return;

    await _db.runTransaction((tx) async {
      final myRef = _ref(myUid);
      final tgRef = _ref(targetUid);

      final mySnap = await tx.get(myRef);
      final tgSnap = await tx.get(tgRef);

      if (!mySnap.exists && !tgSnap.exists) return;

      final myData = mySnap.data() ?? {};
      final tgData = tgSnap.data() ?? {};

      final myFollowing = List<String>.from(myData['followingIds'] ?? const []);
      final isFollowing = myFollowing.contains(targetUid);
      if (!isFollowing) return; // idempotent

      final myCount = (myData['followingCount'] ?? 0) as int;
      final tgCount = (tgData['followerCount'] ?? 0) as int;

      tx.update(myRef, {
        'followingIds': FieldValue.arrayRemove([targetUid]),
        // chống âm
        'followingCount': (myCount > 0) ? myCount - 1 : 0,
      });

      tx.update(tgRef, {
        'followerIds': FieldValue.arrayRemove([myUid]),
        'followerCount': (tgCount > 0) ? tgCount - 1 : 0,
      });
    });
  }

  /// Kiểm tra myUid đã follow targetUid chưa (đọc 1 lần)
  Future<bool> isFollowing({
    required String myUid,
    required String targetUid,
  }) async {
    final snap = await _ref(myUid).get();
    if (!snap.exists) return false;
    final m = snap.data()!;
    final following = List<String>.from(m['followingIds'] ?? const []);
    return following.contains(targetUid);
  }

  /// Nghe realtime trạng thái follow (tiện sync UI)
  Stream<bool> streamIsFollowing({
    required String myUid,
    required String targetUid,
  }) {
    return _ref(myUid).snapshots().map((snap) {
      if (!snap.exists) return false;
      final m = snap.data()!;
      final following = List<String>.from(m['followingIds'] ?? const []);
      return following.contains(targetUid);
    });
  }

  /// Lấy activity (nếu cần dùng lại model)
  Future<UserActivity?> getActivity(String uid) async {
    final snap = await _ref(uid).get();
    if (!snap.exists) return null;
    return UserActivity.fromDoc(snap);
  }

  Stream<UserActivity?> streamActivity(String uid) {
    return FirebaseFirestore.instance
        .collection('userActivities')
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return UserActivity.fromDoc(snap);
    });
  }


}

