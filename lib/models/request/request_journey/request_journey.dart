import 'package:cloud_firestore/cloud_firestore.dart';

class RequestJourney {
  final String id;
  final String senderId;
  final String receiverId;
  final String journeyId;

  // times
  final DateTime createdAt;
  final DateTime? desiredDepartureTime;
  final DateTime? desiredArrivalTime;

  // pickup / dropoff
  final String? pickUpName;
  final GeoPoint? pickUpPoint;
  final String? dropOffName;
  final GeoPoint? dropOffPoint;

  // content
  final String? message;
  final String? note;

  // status
  final bool isAccepted;
  final bool isPending;

  // === index cho danh sách "đã chấp nhận" ===
  final DateTime? acceptedAt;      // thời điểm accept, tie-break hoặc hiển thị

  const RequestJourney({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.journeyId,
    required this.createdAt,
    this.desiredDepartureTime,
    this.desiredArrivalTime,
    this.pickUpName,
    this.pickUpPoint,
    this.dropOffName,
    this.dropOffPoint,
    this.message,
    this.note,
    this.isAccepted = false,
    this.isPending = true,
    this.acceptedAt,
  });

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'journeyId': journeyId,

    // times
    'createdAt': Timestamp.fromDate(createdAt),
    if (desiredDepartureTime != null) 'desiredDepartureTime': Timestamp.fromDate(desiredDepartureTime!),
    if (desiredArrivalTime != null)   'desiredArrivalTime': Timestamp.fromDate(desiredArrivalTime!),

    // pickup / dropoff
    'pickUpName': pickUpName,
    'pickUpPoint': pickUpPoint,
    'dropOffName': dropOffName,
    'dropOffPoint': dropOffPoint,

    // content
    'message': message,
    'note': note,

    // status
    'isAccepted': isAccepted,
    'isPending' : isPending,

    if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),

    'updatedAt': FieldValue.serverTimestamp(),
  };

  static DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  factory RequestJourney.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return RequestJourney(
      id: doc.id,
      senderId: (m['senderId'] ?? '') as String,
      receiverId: (m['receiverId'] ?? '') as String,
      journeyId: (m['journeyId'] ?? '') as String,

      createdAt: _toDate(m['createdAt']) ?? DateTime.now(),
      desiredDepartureTime: _toDate(m['desiredDepartureTime']),
      desiredArrivalTime:   _toDate(m['desiredArrivalTime']),

      pickUpName:  m['pickUpName'] as String?,
      pickUpPoint: m['pickUpPoint'] as GeoPoint?,
      dropOffName: m['dropOffName'] as String?,
      dropOffPoint:m['dropOffPoint'] as GeoPoint?,

      message: m['message'] as String?,
      note:    m['note'] as String?,

      isAccepted: (m['isAccepted'] ?? false) as bool,
      isPending:  (m['isPending']  ?? true ) as bool,

      acceptedAt: _toDate(m['acceptedAt']),
    );
  }

  RequestJourney copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? journeyId,
    DateTime? createdAt,
    DateTime? desiredDepartureTime,
    DateTime? desiredArrivalTime,
    String? pickUpName,
    GeoPoint? pickUpPoint,
    String? dropOffName,
    GeoPoint? dropOffPoint,
    String? message,
    String? note,
    bool? isAccepted,
    bool? isPending,
    int? acceptedOrder,
    DateTime? acceptedAt,
  }) {
    return RequestJourney(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      journeyId: journeyId ?? this.journeyId,
      createdAt: createdAt ?? this.createdAt,
      desiredDepartureTime: desiredDepartureTime ?? this.desiredDepartureTime,
      desiredArrivalTime: desiredArrivalTime ?? this.desiredArrivalTime,
      pickUpName: pickUpName ?? this.pickUpName,
      pickUpPoint: pickUpPoint ?? this.pickUpPoint,
      dropOffName: dropOffName ?? this.dropOffName,
      dropOffPoint: dropOffPoint ?? this.dropOffPoint,
      message: message ?? this.message,
      note: note ?? this.note,
      isAccepted: isAccepted ?? this.isAccepted,
      isPending: isPending ?? this.isPending,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
