import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime? timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    DateTime? dt;
    final raw = map['timestamp'];
    if (raw is Timestamp) dt = raw.toDate();
    else if (raw is DateTime) dt = raw;
    else if (raw is String && raw.isNotEmpty) dt = DateTime.tryParse(raw);

    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: dt,
    );
  }

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Message.fromMap(doc.id, doc.data() ?? {});
  }

  @override
  String toString() =>
      'Message(id: $id, senderId: $senderId, content: "$content", time: $timestamp)';
}
