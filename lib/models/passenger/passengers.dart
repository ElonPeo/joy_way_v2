import 'package:cloud_firestore/cloud_firestore.dart';

enum PassengerStatus {
  pending,
  preparingPickup,
  pickedUp,
  droppedOff,
  canceledByDriver,
  canceledByPassenger,
  noShow,
}

class Passenger {
  final String id;            // doc id = "${postId}_${userId}"
  final String postId;        // 🔹 thêm
  final String userId;        // 🔹 dùng để load profile
  final String requestId;
  final PassengerStatus status;

  final DateTime? preparingPickupAt;
  final DateTime? pickedUpAt;
  final DateTime? droppedOffAt;
  final DateTime? canceledByDriverAt;
  final DateTime? canceledByPassengerAt;
  final DateTime? noShowAt;

  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const Passenger({
    required this.id,
    required this.postId,
    required this.userId,
    required this.requestId,
    required this.status,
    this.preparingPickupAt,
    this.pickedUpAt,
    this.droppedOffAt,
    this.canceledByDriverAt,
    this.canceledByPassengerAt,
    this.noShowAt,
    this.createdAt,
    this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'postId': postId,                // 🔹 ghi ra DB
    'userId': userId,                // 🔹 ghi ra DB
    'requestId': requestId,
    'status': status.name,
    'preparingPickupAt': preparingPickupAt == null ? null : Timestamp.fromDate(preparingPickupAt!),
    'pickedUpAt': pickedUpAt == null ? null : Timestamp.fromDate(pickedUpAt!),
    'droppedOffAt': droppedOffAt == null ? null : Timestamp.fromDate(droppedOffAt!),
    'canceledByDriverAt': canceledByDriverAt == null ? null : Timestamp.fromDate(canceledByDriverAt!),
    'canceledByPassengerAt': canceledByPassengerAt == null ? null : Timestamp.fromDate(canceledByPassengerAt!),
    'noShowAt': noShowAt == null ? null : Timestamp.fromDate(noShowAt!),
    'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    'lastUpdatedAt': FieldValue.serverTimestamp(),
  };

  factory Passenger.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    DateTime? _d(v) => v is Timestamp ? v.toDate() : (v is DateTime ? v : null);
    final statusName = (m['status'] as String?) ?? PassengerStatus.pending.name;
    final st = PassengerStatus.values.firstWhere((e) => e.name == statusName, orElse: () => PassengerStatus.pending);

    return Passenger(
      id: (m['id'] ?? doc.id) as String,
      postId: (m['postId'] ?? '') as String,     // 🔹 đọc lại
      userId: (m['userId'] ?? '') as String,     // 🔹 đọc lại
      requestId: (m['requestId'] ?? '') as String,
      status: st,
      preparingPickupAt: _d(m['preparingPickupAt']),
      pickedUpAt: _d(m['pickedUpAt']),
      droppedOffAt: _d(m['droppedOffAt']),
      canceledByDriverAt: _d(m['canceledByDriverAt']),
      canceledByPassengerAt: _d(m['canceledByPassengerAt']),
      noShowAt: _d(m['noShowAt']),
      createdAt: _d(m['createdAt']),
      lastUpdatedAt: _d(m['lastUpdatedAt']),
    );
  }
}
