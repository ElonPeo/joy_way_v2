import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformation {
  String? userName;
  String? name;
  String? sex;
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? livingPlace;
  GeoPoint? livingCoordinate;
  List<String>? socialLinks;
  List<String>? followerList;
  String? avatarImageId;
  String? backgroundImageId;

  UserInformation({
    this.userName,
    this.name,
    this.sex,
    this.phoneNumber,
    this.dateOfBirth,
    this.livingPlace,
    this.livingCoordinate,
    this.socialLinks,
    this.followerList,
    this.avatarImageId,
    this.backgroundImageId,
  });

  /// Object → Map (để lưu Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'name': name,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'livingPlace': livingPlace,
      'livingCoordinate': livingCoordinate,
      'socialLinks': socialLinks,
      'followerList': followerList,
      'avatarImageId': avatarImageId,
      'backgroundImageId': backgroundImageId,
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((k, v) => v == null);
  }

  /// Firestore → Object
  factory UserInformation.fromMap(Map<String, dynamic> map) {
    DateTime? dob;
    final dobRaw = map['dateOfBirth'];
    if (dobRaw is Timestamp) dob = dobRaw.toDate();
    if (dobRaw is DateTime) dob = dobRaw;

    return UserInformation(
      userName: map['userName'] as String?,
      name: map['name'] as String?,
      sex: map['sex'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      dateOfBirth: dob,
      livingPlace: map['livingPlace'] as String?,
      livingCoordinate: map['livingCoordinate'] as GeoPoint?,
      socialLinks: (map['socialLinks'] as List?)?.map((e) => e.toString()).toList(),
      followerList: (map['followerList'] as List?)?.map((e) => e.toString()).toList(),
      avatarImageId: map['avatarImageId'] as String?,
      backgroundImageId: map['backgroundImageId'] as String?,
    );
  }

  /// Sao chép object (dùng khi cập nhật cục bộ)
  UserInformation copyWith({
    String? userName,
    String? name,
    String? sex,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? livingPlace,
    GeoPoint? livingCoordinate,
    List<String>? socialLinks,
    List<String>? followerList,
    String? avatarImageId,
    String? backgroundImageId,
  }) {
    return UserInformation(
      userName: userName ?? this.userName,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      livingPlace: livingPlace ?? this.livingPlace,
      livingCoordinate: livingCoordinate ?? this.livingCoordinate,
      socialLinks: socialLinks ?? this.socialLinks,
      followerList: followerList ?? this.followerList,
      avatarImageId: avatarImageId ?? this.avatarImageId,
      backgroundImageId: backgroundImageId ?? this.backgroundImageId,
    );
  }
}
