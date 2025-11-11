import 'package:cloud_firestore/cloud_firestore.dart';

class UserActivity {
  final String id;
  final List<String> followingIds;
  final List<String> followerIds;
  final int followingCount;
  final int followerCount;

  const UserActivity({
    required this.id,
    this.followingIds = const [],
    this.followerIds = const [],
    this.followingCount = 0,
    this.followerCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'followingIds': followingIds,
    'followerIds': followerIds,
    'followingCount': followingCount,
    'followerCount': followerCount,
  };

  factory UserActivity.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return UserActivity(
      id: doc.id,
      followingIds: List<String>.from(m['followingIds'] ?? const []),
      followerIds: List<String>.from(m['followerIds'] ?? const []),
      followingCount: (m['followingCount'] ?? 0) as int,
      followerCount: (m['followerCount'] ?? 0) as int,
    );
  }
}
