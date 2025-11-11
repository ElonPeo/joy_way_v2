import 'package:cloud_firestore/cloud_firestore.dart';

enum AppRequestType {
  journey,
  makeFriend,
}

extension AppRequestTypeX on AppRequestType {
  String get name {
    switch (this) {
      case AppRequestType.journey:
        return 'journey';
      case AppRequestType.makeFriend:
        return 'makeFriend';
    }
  }

  static AppRequestType fromString(String s) {
    switch (s) {
      case 'journey':
        return AppRequestType.journey;
      case 'makeFriend':
        return AppRequestType.makeFriend;
      default:
        return AppRequestType.journey;
    }
  }
}

class AppRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final AppRequestType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'type': type.name,
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory AppRequest.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return AppRequest(
      id: doc.id,
      senderId: (m['senderId'] ?? '') as String,
      receiverId: (m['receiverId'] ?? '') as String,
      type: AppRequestTypeX.fromString((m['type'] ?? '') as String),
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
