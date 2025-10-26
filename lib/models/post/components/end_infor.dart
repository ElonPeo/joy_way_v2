import 'package:cloud_firestore/cloud_firestore.dart';

class EndInfo {
  final GeoPoint arrivalCoordinate;
  final String arrivalName;
  final DateTime? arrivalTime; // optional

  const EndInfo({
    required this.arrivalCoordinate,
    required this.arrivalName,
    this.arrivalTime,
  });

  Map<String, dynamic> toMap() => {
    'arrivalCoordinate': arrivalCoordinate,
    'arrivalName': arrivalName,
    'arrivalTime': arrivalTime,
  };

  factory EndInfo.fromMap(Map<String, dynamic> m) => EndInfo(
    arrivalCoordinate: m['arrivalCoordinate'] as GeoPoint,
    arrivalName: m['arrivalName'] as String,
    arrivalTime: (m['arrivalTime'] as Timestamp?)?.toDate(),
  );

  EndInfo copyWith({
    GeoPoint? arrivalCoordinate,
    String? arrivalName,
    DateTime? arrivalTime,
  }) => EndInfo(
    arrivalCoordinate: arrivalCoordinate ?? this.arrivalCoordinate,
    arrivalName: arrivalName ?? this.arrivalName,
    arrivalTime: arrivalTime ?? this.arrivalTime,
  );
}


class EndInfoBuilder {
  GeoPoint? arrivalCoordinate;
  String? arrivalName;
  DateTime? arrivalTime;

  EndInfoBuilder();
  EndInfoBuilder.from(EndInfo e) {
    arrivalCoordinate = e.arrivalCoordinate;
    arrivalName = e.arrivalName;
    arrivalTime = e.arrivalTime;
  }

  bool get isComplete =>
      arrivalCoordinate != null &&
          (arrivalName?.trim().isNotEmpty ?? false);

  EndInfo? tryBuild() => isComplete
      ? EndInfo(
    arrivalCoordinate: arrivalCoordinate!,
    arrivalName: arrivalName!.trim(),
    arrivalTime: arrivalTime,
  )
      : null;

  Map<String, dynamic> toPartialMap() => {
    if (arrivalCoordinate != null) 'arrivalCoordinate': arrivalCoordinate,
    if (arrivalName != null) 'arrivalName': arrivalName,
    if (arrivalTime != null) 'arrivalTime': arrivalTime,
  };
}
