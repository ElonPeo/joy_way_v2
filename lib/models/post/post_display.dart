import 'package:joy_way/models/post/post.dart';
import 'package:joy_way/models/user/basic_user_info.dart';

/// Dữ liệu đầy đủ để hiển thị PostCard trên UI
class PostDisplay {
  final Post post;
  final BasicUserInfo userInfo;
  final String? timeAgo;

  /// Tuỳ chọn thêm các dữ liệu phụ (like, comment, ... sau này)
  final int commentCount;
  final int likeCount;

  const PostDisplay({
    required this.post,
    required this.userInfo,
    this.timeAgo,
    this.commentCount = 0,
    this.likeCount = 0,
  });

  /// Hàm tạo từ dữ liệu Firestore raw (Post + user)
  factory PostDisplay.fromData({
    required Post post,
    required BasicUserInfo userInfo,
    String? avatarUrl,
    String? timeAgo,
    int commentCount = 0,
    int likeCount = 0,
  }) {
    return PostDisplay(
      post: post,
      userInfo: userInfo,
      timeAgo: timeAgo,
      commentCount: commentCount,
      likeCount: likeCount,
    );
  }

  /// Dùng khi cần clone dữ liệu có chỉnh nhẹ
  PostDisplay copyWith({
    Post? post,
    BasicUserInfo? userInfo,
    String? avatarUrl,
    String? timeAgo,
    int? commentCount,
    int? likeCount,
  }) {
    return PostDisplay(
      post: post ?? this.post,
      userInfo: userInfo ?? this.userInfo,
      timeAgo: timeAgo ?? this.timeAgo,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
