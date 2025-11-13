import 'package:cloud_firestore/cloud_firestore.dart';

class EndRequestInfo {
  final GeoPoint? dropOffPoint;
  final String? dropOffName;
  final DateTime? desiredDropOffTime;

  const EndRequestInfo({
    this.dropOffPoint,
    this.dropOffName,
    this.desiredDropOffTime,
  });

  Map<String, dynamic> toMap() => {
    'dropOffPoint': dropOffPoint,
    'dropOffName': dropOffName,
    'desiredDropOffTime': desiredDropOffTime,
  };

  factory EndRequestInfo.fromMap(Map<String, dynamic> m) {
    final raw = m['desiredDropOffTime'];
    DateTime? time;
    if (raw is Timestamp) {
      time = raw.toDate();
    } else if (raw is DateTime) {
      time = raw;
    } else {
      time = null;
    }

    return EndRequestInfo(
      dropOffPoint: m['dropOffPoint'] as GeoPoint?,
      dropOffName: m['dropOffName'] as String?,
      desiredDropOffTime: time,
    );
  }

  EndRequestInfo copyWith({
    GeoPoint? dropOffPoint,
    String? dropOffName,
    DateTime? desiredDropOffTime,
  }) =>
      EndRequestInfo(
        dropOffPoint: dropOffPoint ?? this.dropOffPoint,
        dropOffName: dropOffName ?? this.dropOffName,
        desiredDropOffTime: desiredDropOffTime ?? this.desiredDropOffTime,
      );
}

class EndRequestInfoBuilder {
  String? dropOffName;
  GeoPoint? dropOffPoint;
  DateTime? desiredDropOffTime;


  EndRequestInfoBuilder();

  EndRequestInfoBuilder.from(EndRequestInfo e) {
    dropOffName = e.dropOffName;
    dropOffPoint = e.dropOffPoint;
    desiredDropOffTime = e.desiredDropOffTime;
  }


  bool get isEndComplete =>
      dropOffPoint != null &&
          (dropOffName?.trim().isNotEmpty ?? false) &&
          desiredDropOffTime != null;

  EndRequestInfo? tryBuild() => isEndComplete
      ? EndRequestInfo(
    dropOffPoint: dropOffPoint,
    dropOffName: dropOffName!.trim(),
    desiredDropOffTime: desiredDropOffTime,
  )
      : null;
}
