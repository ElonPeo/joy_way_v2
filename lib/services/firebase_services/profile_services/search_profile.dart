import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/models/user/basic_user_info.dart';

class SearchProfile {
  final _db = FirebaseFirestore.instance;

  // ===== Helpers: phải KHỚP với nơi tạo searchKeywords =====
  String _canonicalUserName(String v) {
    final s = v.trim().toLowerCase();
    return s.startsWith('@') ? s.substring(1) : s;
  }

  String _removeDiacritics(String s) {
    const map = {
      'a': r'[àáạảãâầấậẩẫăằắặẳẵ]',
      'A': r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]',
      'e': r'[èéẹẻẽêềếệểễ]',
      'E': r'[ÈÉẸẺẼÊỀẾỆỂỄ]',
      'i': r'[ìíịỉĩ]',
      'I': r'[ÌÍỊỈĨ]',
      'o': r'[òóọỏõôồốộổỗơờớợởỡ]',
      'O': r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]',
      'u': r'[ùúụủũưừứựửữ]',
      'U': r'[ÙÚỤỦŨƯỪỨỰỬỮ]',
      'y': r'[ỳýỵỷỹ]',
      'Y': r'[ỲÝỴỶỸ]',
      'd': r'[đ]',
      'D': r'[Đ]',
    };

    map.forEach((plain, pattern) {
      s = s.replaceAll(RegExp(pattern), plain);
    });
    return s;
  }


  String _normalizeKeyword(String keyword) =>
      _removeDiacritics(_canonicalUserName(keyword));

  /// Tìm uid theo username (prefix-search dựa trên mảng searchKeywords)
  Future<List<String>> searchUserIdsByUserName({
    required String keyword,
    int limit = 20,
  }) async {
    final k = _normalizeKeyword(keyword);
    if (k.isEmpty || limit <= 0) return const [];

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final snap = await _db
        .collection('users')
        .where('searchKeywords', arrayContains: k) // k đã normalize
        .limit(limit)
        .get();

    return snap.docs
        .where((d) => d.id != currentUid)
        .map((d) => d.id)
        .toList(growable: false);
  }

  /// Lấy BasicUserInfo theo danh sách uid (chunk 10, chạy song song)
  Future<List<BasicUserInfo>> getUserTagsByUids(
      List<String> uids, {
        bool excludeCurrent = true,
      }) async {
    if (uids.isEmpty) return const [];

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final filtered = excludeCurrent && currentUid != null
        ? uids.where((id) => id != currentUid).toList()
        : List<String>.from(uids);
    if (filtered.isEmpty) return const [];

    const chunkSize = 10; // Firestore whereIn tối đa 10 phần tử
    final chunks = <List<String>>[];
    for (var i = 0; i < filtered.length; i += chunkSize) {
      chunks.add(filtered.sublist(
        i,
        i + chunkSize > filtered.length ? filtered.length : i + chunkSize,
      ));
    }

    // Chạy song song để giảm tổng thời gian
    final futures = chunks.map((sub) {
      return _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: sub)
          .get();
    }).toList();

    final results = await Future.wait(futures);

    return results
        .expand((snap) => snap.docs)
        .map((d) => BasicUserInfo.fromMap(d.data(), d.id))
        .toList(growable: false);
  }
}
