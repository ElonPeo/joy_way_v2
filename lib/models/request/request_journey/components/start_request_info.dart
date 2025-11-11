import 'package:cloud_firestore/cloud_firestore.dart';

class StartRequestInfo {
  final GeoPoint? pickUpPoint;
  final String? pickUpName;
  final DateTime? desiredPickUpTime;

  const StartRequestInfo({
    this.pickUpPoint,
    this.pickUpName,
    this.desiredPickUpTime,
  });

  Map<String, dynamic> toMap() => {
    'pickUpPoint': pickUpPoint,
    'pickUpName': pickUpName,
    'desiredPickUpTime': desiredPickUpTime,
  };

  factory StartRequestInfo.fromMap(Map<String, dynamic> m) {
    final raw = m['desiredPickUpTime'];
    DateTime? time;
    if (raw is Timestamp) {
      time = raw.toDate();
    } else if (raw is DateTime) {
      time = raw;
    } else {
      time = null;
    }

    return StartRequestInfo(
      pickUpPoint: m['pickUpPoint'] as GeoPoint?,
      pickUpName: m['pickUpName'] as String?,
      desiredPickUpTime: time,
    );
  }

  StartRequestInfo copyWith({
    GeoPoint? pickUpPoint,
    String? pickUpName,
    DateTime? desiredPickUpTime,
  }) =>
      StartRequestInfo(
        pickUpPoint: pickUpPoint ?? this.pickUpPoint,
        pickUpName: pickUpName ?? this.pickUpName,
        desiredPickUpTime: desiredPickUpTime ?? this.desiredPickUpTime,
      );
}

class StartRequestInfoBuilder {
  String? pickUpName;
  GeoPoint? pickUpPoint;
  DateTime? desiredPickUpTime;

  StartRequestInfoBuilder();

  StartRequestInfoBuilder.from(StartRequestInfo s) {
    pickUpName = s.pickUpName;
    pickUpPoint = s.pickUpPoint;
    desiredPickUpTime = s.desiredPickUpTime;
  }

  bool get isStartComplete =>
      pickUpPoint != null &&
          (pickUpName?.trim().isNotEmpty ?? false) &&
          desiredPickUpTime != null;

  StartRequestInfo? tryBuild() => isStartComplete
      ? StartRequestInfo(
    pickUpPoint: pickUpPoint,
    pickUpName: pickUpName!.trim(),
    desiredPickUpTime: desiredPickUpTime,
  )
      : null;
}
