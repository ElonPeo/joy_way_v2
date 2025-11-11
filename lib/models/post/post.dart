import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/visibility.dart';

enum VehicleType { motorbike, car, other }
enum ExpenseType { free, share }
enum PostVisibility { public, friends, private }

// trạng thái bài đăng / hành trình
enum PostStatus {
  findingCompanion, // đang tìm người đi cùng (mặc định)
  prepareToDepart, // chuẩn bị xuất phát
  hasDeparted,  // đã xuất phát
  isTravelingWithCompanions, // đang đi cùng những người đồng hành
  finished,         // đã hoàn thành
  canceled,         // đã huỷ
}

class Post {
  // IDs
  final String id;
  final String ownerId;

  // Departure
  final GeoPoint departureCoordinate;
  final String departureName;
  final DateTime departureTime;
  final VehicleType vehicleType;
  final int availableSeats;

  // Arrival
  final GeoPoint arrivalCoordinate;
  final String arrivalName;
  final DateTime? arrivalTime;

  // Cost / detail
  final ExpenseType type;
  final int? amount;
  final String? description;

  // Visibility
  final VisibilityPostInfo visibility;

  // Meta
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Trạng thái hành trình/bài đăng
  final PostStatus status;

  const Post({
    required this.id,
    required this.ownerId,
    required this.departureCoordinate,
    required this.departureName,
    required this.departureTime,
    required this.vehicleType,
    required this.availableSeats,
    required this.arrivalCoordinate,
    required this.arrivalName,
    this.arrivalTime,
    required this.type,
    this.amount,
    this.description,
    this.visibility = const VisibilityPostInfo(),
    this.createdAt,
    this.updatedAt,
    this.status = PostStatus.findingCompanion,
  });

  // ===== Mapping =====
  Map<String, dynamic> toMap({bool includeId = true}) => {
    if (includeId) 'id': id,
    'ownerId': ownerId,
    'departureCoordinate': departureCoordinate,
    'departureName': departureName,
    'departureTime': Timestamp.fromDate(departureTime),
    'vehicleType': vehicleType.name,
    'availableSeats': availableSeats,
    'arrivalCoordinate': arrivalCoordinate,
    'arrivalName': arrivalName,
    if (arrivalTime != null) 'arrivalTime': Timestamp.fromDate(arrivalTime!),
    'type': type.name,
    'amount': amount,
    'description': description,
    'visibility': visibility.toMap(),
    'status': status.name,
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory Post.fromMap(String id, Map<String, dynamic> m) {
    DateTime? _toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    VehicleType _veh(String? s) => VehicleType.values.firstWhere(
          (e) => e.name == s,
      orElse: () => VehicleType.other,
    );

    ExpenseType _exp(String? s) => ExpenseType.values.firstWhere(
          (e) => e.name == s,
      orElse: () => ExpenseType.free,
    );

    PostStatus _status(String? s) => PostStatus.values.firstWhere(
          (e) => e.name == s,
      orElse: () => PostStatus.findingCompanion,
    );

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Post(
      id: id,
      ownerId: (m['ownerId'] ?? '') as String,
      departureCoordinate:
      (m['departureCoordinate'] as GeoPoint?) ?? const GeoPoint(0, 0),
      departureName: (m['departureName'] ?? '') as String,
      departureTime:
      _toDate(m['departureTime']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      vehicleType: _veh(m['vehicleType'] as String?),
      availableSeats: _toInt(m['availableSeats']) ?? 0,
      arrivalCoordinate:
      (m['arrivalCoordinate'] as GeoPoint?) ?? const GeoPoint(0, 0),
      arrivalName: (m['arrivalName'] ?? '') as String,
      arrivalTime: _toDate(m['arrivalTime']),
      type: _exp(m['type'] as String?),
      amount: _toInt(m['amount']),
      description: m['description'] as String?,
      visibility: VisibilityPostInfo.fromMap(
        (m['visibility'] as Map?)?.cast<String, dynamic>(),
      ),

      createdAt: _toDate(m['createdAt']),
      updatedAt: _toDate(m['updatedAt']),
      status: _status(m['status'] as String?),
    );
  }

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Post.fromMap(doc.id, data);
  }

  Post copyWith({
    String? id,
    String? ownerId,
    GeoPoint? departureCoordinate,
    String? departureName,
    DateTime? departureTime,
    VehicleType? vehicleType,
    int? availableSeats,
    GeoPoint? arrivalCoordinate,
    String? arrivalName,
    DateTime? arrivalTime,
    ExpenseType? type,
    int? amount,
    String? description,
    VisibilityPostInfo? visibility,
    List<String>? acceptedRequestIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostStatus? status,
  }) {
    return Post(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      departureCoordinate: departureCoordinate ?? this.departureCoordinate,
      departureName: departureName ?? this.departureName,
      departureTime: departureTime ?? this.departureTime,
      vehicleType: vehicleType ?? this.vehicleType,
      availableSeats: availableSeats ?? this.availableSeats,
      arrivalCoordinate: arrivalCoordinate ?? this.arrivalCoordinate,
      arrivalName: arrivalName ?? this.arrivalName,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  // ===== Helpers tiện cho UI =====
  bool get isFree => type == ExpenseType.free || (amount ?? 0) <= 0;
  String get priceText => isFree ? 'Free' : '${amount ?? 0} VND';
}
