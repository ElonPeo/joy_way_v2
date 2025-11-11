class BasicUserInfo {
  final String userName;
  final String uid;
  final String? name;
  final String? avatarImageId;
  final String? phoneNumber;

  BasicUserInfo({
    required this.userName,
    required this.uid,
    this.name,
    this.avatarImageId,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'userName': userName,
    'avatarImageId': avatarImageId,
    'phoneNumber': phoneNumber,
    if (name != null) 'name': name,
  };

  factory BasicUserInfo.fromMap(Map<String, dynamic> data, String uid) {
    return BasicUserInfo(
      uid: uid,
      userName: data['userName'] ?? '',
      avatarImageId: data['avatarImageId'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }
}