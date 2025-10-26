import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_information.dart';

class UserApp extends UserInformation {
  final String email;
  final String userId;

  UserApp({
    required this.email,
    required this.userId,
    super.userName,
    super.name,
    super.sex,
    super.phoneNumber,
    super.dateOfBirth,
    super.livingPlace,
    super.livingCoordinate,
    super.socialLinks,
    super.avatarImageId,
    super.backgroundImageId,
    super.followerList,
  });

  /// Dùng khi đọc từ Firestore
  factory UserApp.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return UserApp.empty();
    }
    return UserApp(
      email: data['email'] ?? '',
      userId: doc.id,
      userName: data['userName'],
      name: data['name'],
      sex: data['sex'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: (data['dateOfBirth'] is Timestamp)
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      livingPlace: data['livingPlace'],
      livingCoordinate: data['livingCoordinate'] as GeoPoint?,
      socialLinks: (data['socialLinks'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      followerList: (data['followerList'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      avatarImageId: data['avatarImageId'],
      backgroundImageId: data['backgroundImageId'],
    );
  }

  /// Gộp thông tin UserApp → Map (để lưu Firestore)
  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    return {
      ...base,
      'email': email,
      'userId': userId,
    };
  }

  /// Khi cần bản rỗng (tránh null crash)
  factory UserApp.empty() => UserApp(
    email: '',
    userId: '',
  );

  /// Khi cần bản sao có cập nhật một vài trường
  UserApp copyWith({
    String? email,
    String? userId,
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
    return UserApp(
      email: email ?? this.email,
      userId: userId ?? this.userId,
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
