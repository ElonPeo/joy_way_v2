import 'package:cloud_firestore/cloud_firestore.dart';

class MessageServices {
  MessageServices._();
  static final MessageServices I = MessageServices._();

  final _db = FirebaseFirestore.instance;

  // ===== Helpers =====
  String roomIdFor(String uidA, String uidB) {
    final a = [uidA, uidB]..sort();
    return '${a[0]}_${a[1]}';
  }

  String otherUserId(List<String> userIds, String myUid) {
    return userIds.firstWhere((e) => e != myUid, orElse: () => myUid);
  }

  // ===== Rooms =====
  Future<String> getOrCreateRoom(String uidA, String uidB) async {
    final id = roomIdFor(uidA, uidB);
    final ref = _db.collection('chats').doc(id);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': [uidA, uidB],
        'lastMessage': '',
        'lastSenderId': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': {uidA: 0, uidB: 0},
      });
    }
    return id;
  }

  /// Danh sách phòng có mình (người đã nhắn với mình), mới nhất trước.
  /// NOTE: có thể cần composite index: `participants array-contains + orderBy(updatedAt)`
  Stream<QuerySnapshot<Map<String, dynamic>>> streamRecentRooms({
    required String myUid,
    int limit = 50,
  }) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchRecentRooms({
    required String myUid,
    int limit = 50,
  }) async {
    final qs = await _db
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();
    return qs.docs;
  }

  // ===== Messages =====
  /// ~30 tin gần nhất (config được), mới trước (reverse=true khi render).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamRecentMessages({
    required String roomId,
    int limit = 30,
  }) {
    return _db
        .collection('chats').doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchRecentMessages({
    required String roomId,
    int limit = 30,
  }) async {
    final qs = await _db
        .collection('chats').doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return qs.docs;
  }

  // ===== Send =====
  /// Gửi khi CHƯA có phòng (người nhắn lần đầu) — tự tạo room và gửi.
  Future<void> sendFirstMessage({
    required String senderId,
    required String peerId,
    required String text,
  }) async {
    final roomId = await getOrCreateRoom(senderId, peerId);
    await sendInRoom(roomId: roomId, senderId: senderId, text: text);
  }

  /// Gửi khi ĐÃ có phòng.
  Future<void> sendInRoom({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final refRoom = _db.collection('chats').doc(roomId);
    final refMsg  = refRoom.collection('messages').doc();

    await _db.runTransaction((tx) async {
      // 1) READ trước
      final roomSnap = await tx.get(refRoom); // <— đọc trước khi ghi
      final data = roomSnap.data() ?? {};
      final participants = List<String>.from(data['participants'] ?? const []);
      final unread = Map<String, dynamic>.from(data['unread'] ?? {});

      for (final uid in participants) {
        unread[uid] = (uid == senderId) ? 0 : (unread[uid] ?? 0) + 1;
      }

      // 2) WRITE sau
      tx.set(refMsg, {
        'senderId': senderId,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(refRoom, {
        'lastMessage': text,
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': unread,
      });
    });
  }


  /// Mark đã đọc cho user trong room.
  Future<void> markAsRead({
    required String roomId,
    required String myUid,
  }) async {
    final refRoom = _db.collection('chats').doc(roomId);
    await refRoom.update({'unread.$myUid': 0});
  }

  // ===== Tiện ích phân trang (tuỳ chọn) =====
  /// Lấy thêm tin cũ hơn (cursor == doc cuối cùng bạn đang có).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchMoreMessages({
    required String roomId,
    required DocumentSnapshot<Map<String, dynamic>> startAfterDoc,
    int limit = 30,
  }) async {
    final qs = await _db
        .collection('chats').doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(startAfterDoc)
        .limit(limit)
        .get();
    return qs.docs;
  }
}
