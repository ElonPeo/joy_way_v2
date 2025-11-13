import 'package:cloud_firestore/cloud_firestore.dart';

class RequestJoinJourney {
  final String id;
  final String senderId;
  final String receiverId;
  final String postId;

  // times
  final DateTime? desiredPickUpTime;
  final DateTime? desiredDropOffTime;

  // pickup / dropoff
  final String? pickUpName;
  final GeoPoint? pickUpPoint;
  final String? dropOffName;
  final GeoPoint? dropOffPoint;

  // content
  final String? note;

  // status
  final bool? isAccepted;

  // meta
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RequestJoinJourney({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.postId,
    this.desiredPickUpTime,
    this.desiredDropOffTime,
    this.pickUpName,
    this.pickUpPoint,
    this.dropOffName,
    this.dropOffPoint,
    this.note,
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
    'postId': postId,
    if (desiredPickUpTime != null)
      'desiredPickUpTime': Timestamp.fromDate(desiredPickUpTime!),
    if (desiredDropOffTime != null)
      'desiredDropOffTime': Timestamp.fromDate(desiredDropOffTime!),
    'pickUpName': pickUpName,
    'pickUpPoint': pickUpPoint,
    'dropOffName': dropOffName,
    'dropOffPoint': dropOffPoint,
    'note': note,
    'isAccepted': isAccepted,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  factory RequestJoinJourney.fromMap(Map<String, dynamic> m, {String? id}) {
    return RequestJoinJourney(
      id: (m['id'] as String?) ?? id ?? '',
      senderId: (m['senderId'] ?? '') as String,
      receiverId: (m['receiverId'] ?? '') as String,
      postId: (m['postId'] ?? '') as String,
      desiredPickUpTime: _toDate(m['desiredPickUpTime']),
      desiredDropOffTime: _toDate(m['desiredDropOffTime']),
      pickUpName: m['pickUpName'] as String?,
      pickUpPoint: m['pickUpPoint'] as GeoPoint?,
      dropOffName: m['dropOffName'] as String?,
      dropOffPoint: m['dropOffPoint'] as GeoPoint?,
      note: m['note'] as String?,
      isAccepted: m['isAccepted'] as bool?,
      createdAt: _toDate(m['createdAt']),
      updatedAt: _toDate(m['updatedAt']),
    );
  }

  RequestJoinJourney copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? postId,
    DateTime? desiredPickUpTime,
    DateTime? desiredDropOffTime,
    String? pickUpName,
    GeoPoint? pickUpPoint,
    String? dropOffName,
    GeoPoint? dropOffPoint,
    String? note,
    bool? isAccepted,
    DateTime? acceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RequestJoinJourney(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      postId: postId ?? this.postId,
      desiredPickUpTime: desiredPickUpTime ?? this.desiredPickUpTime,
      desiredDropOffTime: desiredDropOffTime ?? this.desiredDropOffTime,
      pickUpName: pickUpName ?? this.pickUpName,
      pickUpPoint: pickUpPoint ?? this.pickUpPoint,
      dropOffName: dropOffName ?? this.dropOffName,
      dropOffPoint: dropOffPoint ?? this.dropOffPoint,
      note: note ?? this.note,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
