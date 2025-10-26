import 'package:cloud_firestore/cloud_firestore.dart';
import '../post.dart';

class StartInfo {
  final GeoPoint departureCoordinate;
  final String departureName;
  final DateTime departureTime;
  final VehicleType vehicleType;
  final int availableSeats;

  const StartInfo({
    required this.departureCoordinate,
    required this.departureName,
    required this.departureTime,
    required this.vehicleType,
    required this.availableSeats,
  });

  Map<String, dynamic> toMap() => {
    'departureCoordinate': departureCoordinate,
    'departureName': departureName,
    'departureTime': departureTime,
    'vehicleType': vehicleType.name,
    'availableSeats': availableSeats,
  };

  factory StartInfo.fromMap(Map<String, dynamic> m) => StartInfo(
    departureCoordinate: m['departureCoordinate'] as GeoPoint,
    departureName: m['departureName'] as String,
    departureTime: (m['departureTime'] as Timestamp).toDate(),
    vehicleType: VehicleType.values.firstWhere((e) => e.name == m['vehicleType']),
    availableSeats: m['availableSeats'] as int,
  );
}


class StartInfoBuilder {
  GeoPoint? departureCoordinate;
  String? departureName;
  DateTime? departureTime;
  VehicleType? vehicleType;
  int? availableSeats;

  StartInfoBuilder();

  StartInfoBuilder.from(StartInfo s) {
    departureCoordinate = s.departureCoordinate;
    departureName = s.departureName;
    departureTime = s.departureTime;
    vehicleType = s.vehicleType;
    availableSeats = s.availableSeats;
  }

  bool get isComplete =>
      departureCoordinate != null &&
          (departureName?.trim().isNotEmpty ?? false) &&
          departureTime != null &&
          vehicleType != null &&
          (availableSeats ?? 0) > 0;

  StartInfo? tryBuild() => isComplete
      ? StartInfo(
    departureCoordinate: departureCoordinate!,
    departureName: departureName!.trim(),
    departureTime: departureTime!,
    vehicleType: vehicleType!,
    availableSeats: availableSeats!,
  )
      : null;
}