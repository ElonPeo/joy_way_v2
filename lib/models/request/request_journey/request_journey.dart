import 'package:cloud_firestore/cloud_firestore.dart';

class RequestJourney {
  final String journeyId;

  // times
  final DateTime? desiredPickUpTime;
  final DateTime? desiredDropOffTime;

  // pickup / dropoff
  final String? pickUpName;
  final GeoPoint? pickUpPoint;
  final String? dropOffName;
  final GeoPoint? dropOffPoint;

  // content
  final String? message;
  final String? note;

  // status riêng cho journey
  final bool? isAccepted;
  final DateTime? acceptedAt;

  const RequestJourney({
    required this.journeyId,
    this.desiredPickUpTime,
    this.desiredDropOffTime,
    this.pickUpName,
    this.pickUpPoint,
    this.dropOffName,
    this.dropOffPoint,
    this.message,
    this.note,
    this.isAccepted,
    this.acceptedAt,
  });

  DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }


  Map<String, dynamic> toMap() => {
    'journeyId': journeyId,
    if (desiredPickUpTime != null)
      'desiredPickUpTime': Timestamp.fromDate(desiredPickUpTime!),
    if (desiredDropOffTime != null)
      'desiredDropOffTime': Timestamp.fromDate(desiredDropOffTime!),
    'pickUpName': pickUpName,
    'pickUpPoint': pickUpPoint,
    'dropOffName': dropOffName,
    'dropOffPoint': dropOffPoint,
    'message': message,
    'note': note,
    'isAccepted': isAccepted,
    if (acceptedAt != null)
      'acceptedAt': Timestamp.fromDate(acceptedAt!),
  };

  factory RequestJourney.fromMap(Map<String, dynamic> m) {

    DateTime? toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return RequestJourney(
      journeyId: (m['journeyId'] ?? '') as String,
      desiredPickUpTime: toDate(m['desiredPickUpTime']),
      desiredDropOffTime: toDate(m['desiredDropOffTime']),
      pickUpName: m['pickUpName'] as String?,
      pickUpPoint: m['pickUpPoint'] as GeoPoint?,
      dropOffName: m['dropOffName'] as String?,
      dropOffPoint: m['dropOffPoint'] as GeoPoint?,
      message: m['message'] as String?,
      note: m['note'] as String?,
      isAccepted: m['isAccepted'] as bool?,
      acceptedAt: toDate(m['acceptedAt']),
    );
  }

}
