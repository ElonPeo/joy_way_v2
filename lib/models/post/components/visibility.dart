
import '../post.dart';


class VisibilityPostInfo {
  final PostVisibility visibility;
  const VisibilityPostInfo({this.visibility = PostVisibility.public});

  Map<String, dynamic> toMap() => {'visibility': visibility.name};

  factory VisibilityPostInfo.fromMap(Map<String, dynamic>? map) {
    final v = (map?['visibility'] as String?) ?? PostVisibility.public.name;
    return VisibilityPostInfo(
      visibility: PostVisibility.values.firstWhere(
            (e) => e.name == v,
        orElse: () => PostVisibility.public,
      ),
    );
  }
}