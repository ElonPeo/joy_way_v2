import 'package:cloud_firestore/cloud_firestore.dart';

/// Các loại thông báo gợi ý (chuỗi)
class AppNotifyType {
  // Mối quan hệ
  static const String follow = 'follow';                 // A đã theo dõi bạn
  static const String unfollow = 'unfollow';             // (tuỳ dùng)

  // Hành trình
  static const String journeyRequested = 'journey.requested'; //  đã gửi yêu cầu
  static const String journeyAccepted = 'journey.accepted'; // yêu cầu được chấp nhận
  static const String journeyDeclined = 'journey.declined'; // yêu cầu bị từ chối

  // Bài viết / tương tác (ví dụ)
  static const String postLike = 'post.like';
  static const String postComment = 'post.comment';
}

/// Model thông báo
class AppNotification {
  final String id;

  /// Người nhận thông báo (bắt buộc)
  final String receiverId;

  /// Người gây ra hành động (ví dụ: người follow, người chấp nhận/từ chối)
  final String actorId;

  /// Loại thông báo: dùng các hằng trong AppNotifyType
  final String type;

  /// Đối tượng đính kèm để điều hướng (VD: journeyId / postId / userId ...)
  final String? attachedId;


  /// Thông điệp hiển thị tuỳ chọn
  final String? message;

  /// Đã đọc hay chưa
  final bool isRead;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppNotification({
    required this.id,
    required this.receiverId,
    required this.actorId,
    required this.type,
    this.attachedId,
    this.message,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'receiverId': receiverId,
    'actorId': actorId,
    'type': type,
    'attachedId': attachedId,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory AppNotification.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      receiverId: (m['receiverId'] ?? '') as String,
      actorId: (m['actorId'] ?? '') as String,
      type: (m['type'] ?? '') as String,
      attachedId: (m['attachedId'] ?? '') is String ? m['attachedId'] as String : null,
      message: (m['message'] ?? '') is String ? m['message'] as String : null,
      isRead: (m['isRead'] ?? false) as bool,
      createdAt: _toDate(m['createdAt']),
      updatedAt: _toDate(m['updatedAt']),
    );
  }
}

DateTime? _toDate(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}
