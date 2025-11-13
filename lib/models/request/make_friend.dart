import 'package:cloud_firestore/cloud_firestore.dart';

class MakeFriend {
  final String id;
  final String senderId;
  final String receiverId;

  // status
  final bool? isAccepted;

  // meta
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MakeFriend({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.isAccepted,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'isAccepted': isAccepted,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  factory MakeFriend.fromMap(Map<String, dynamic> m, {String? id}) {
    return MakeFriend(
      id: (m['id'] as String?) ?? id ?? '',
      senderId: (m['senderId'] ?? '') as String,
      receiverId: (m['receiverId'] ?? '') as String,

      isAccepted: m['isAccepted'] as bool?,
      createdAt: _toDate(m['createdAt']),
      updatedAt: _toDate(m['updatedAt']),
    );
  }

  MakeFriend copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    bool? isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MakeFriend(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
