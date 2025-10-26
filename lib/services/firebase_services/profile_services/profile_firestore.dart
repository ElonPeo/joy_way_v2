import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:joy_way/models/user/user_information.dart';
import 'package:joy_way/services/data_processing/data_processing.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';

import '../../../models/user/basic_user_info.dart';
import '../../../models/user/user_app.dart';




class ProfileFirestore {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;
  String? get _email => _user?.email;
  bool get isLoggedIn => _user != null;

  /// Kiểm trá tính hợp lệ của số điện thoại
  int checkValidPhoneNumber(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(03|05|07|08|09)\d{8}$').hasMatch(clean)) {
      return 305;
    }
    return 1;
  }

  /// tách user name ra để tìm kiếm
  String _canonicalUserName(String v) {
      final s = v.trim().toLowerCase();
      return s.startsWith('@') ? s.substring(1) : s;
    }
  List<String> generateSearchKeywords(String value) {
    final v = _removeDiacritics(_canonicalUserName(value));
    if (v.isEmpty) return [''];
    final list = <String>[];
    for (int i = 1; i <= v.length; i++) {
      list.add(v.substring(0, i));
    }
    return list;
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


  /// kieemr tra sự tồn tại của user
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Timeout when connecting to Firestore'),
      );
      return doc.exists;
    } catch (e) {
      throw Exception("Error when getting user information: $e");
    }
  }



  /// Lấy thông tin người khác theo userId truyền vào
  /// Lấy thông tin người dùng theo uid truyền vào.
  /// Nếu uid == null => dùng uid hiện tại (nếu đã đăng nhập).
  Future<UserApp?> getUserInformationById(BuildContext context, {String? uid}) async {
    try {
      final String? targetUid = uid ?? _uid;
      if (targetUid == null || targetUid.trim().isEmpty) {
        ShowNotification.showAnimatedSnackBar(
          context,
          'You are not logged in',
          2,
          const Duration(milliseconds: 500),
        );
        return null;
      }
      final snap = await _db.collection('users').doc(targetUid).get();
      if (!snap.exists) return null;
      return UserApp.fromDoc(snap);
    } catch (e) {
      ShowNotification.showAnimatedSnackBar(
        context,
        'Error: ${e.toString()}',
        2,
        const Duration(milliseconds: 500),
      );
      return null;
    }
  }






  /// Kiểm tra sự tồn tại của userName
  Future<bool> checkUserNameExists(String userName) async {
    try {
      final currentUid = _uid;
      if (currentUid == null) return false;
      final canonical = _canonicalUserName(userName);
      final q = await _db
          .collection('users')
          .where('userName', isEqualTo: canonical) // không có '@'
          .limit(2)
          .get();
      return q.docs.any((d) => d.id != currentUid);
    } catch (_) {
      return true;
    }
  }
  /// kiểm tra thông tin trước khi gửi yêu cầu lưu dữ liệu
  Future<String?> checkInformationBeforeSending(
      String? userName,
      String? phoneNumber,
      ) async {
    if (userName == null || userName.trim().isEmpty) {
      return "Username cannot be empty.";
    }

    final trimmedUserName = userName.trim();

    if (trimmedUserName.length < 4) {
      return "Username must be at least 4 characters.";
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!usernameRegex.hasMatch(trimmedUserName)) {
      return "Username can only contain letters and numbers (no special characters).";
    }

    final exists = await checkUserNameExists(trimmedUserName);
    if (exists) return "Username already exists.";

    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return "Phone number must be 10 digits and start with 03/05/07/08/09.";
    }

    if (checkValidPhoneNumber(phoneNumber) != 1) {
      return "Phone number must be 10 digits and start with 03/05/07/08/09.";
    }

    return null;
  }


  /// tạo thông tin user
  Future<String?> createUser(UserApp user) async {
    try {
      await _db.collection('users').doc(user.userId).set(user.toMap());
      return null;
    } catch (e) {
      return "Error creating user: $e";
    }
  }

  /// cập nhật thông tin user
  Future<String?> updateUser(UserApp user) async {
    try {
      await _db.collection('users').doc(user.userId).set(user.toMap(), SetOptions(merge: true));
      return null;
    } catch (e) {
      return "Error updating user: $e";
    }
  }

  /// chỉnh sửa thông tin user nếu tồn tại thì cập nhật nếu chưa thì tạo mới
  Future<String?> editProfile(UserInformation user) async {
    try {
      final current = _auth.currentUser;
      if (current == null) return "NOT_LOGGED_IN";

      final uid = current.uid;
      final email = current.email ?? "error email";
      final canonicalUserName = user.userName != null ? _canonicalUserName(user.userName!) : null;

      final userApp = UserApp(
        email: email,
        userId: uid,
        userName: canonicalUserName, // lưu không có '@'
        name: user.name,
        sex: user.sex,
        phoneNumber: user.phoneNumber,
        dateOfBirth: user.dateOfBirth,
        livingPlace: user.livingPlace,
        livingCoordinate: user.livingCoordinate,
        socialLinks: user.socialLinks,
        avatarImageId: user.avatarImageId,
        backgroundImageId: user.backgroundImageId,
      );

      final docRef = _db.collection('users').doc(uid);
      final exists = (await docRef.get()).exists;

      final data = {
        ...userApp.toMap(),
        if (canonicalUserName != null) 'searchKeywords': generateSearchKeywords(canonicalUserName),
      };

      if (exists) {
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.set({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } catch (e) {
      return "Error editing profile: $e";
    }
  }


  Future<({BasicUserInfo? user, String? error})> getBasicUserInfo(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return (user: null, error: 'User not found');
      final data = doc.data()!;
      final user = BasicUserInfo.fromMap(data, uid);
      return (user: user, error: null);
    } catch (e) {
      return (user: null, error: 'Failed to get user info: $e');
    }
  }

  Future<({BasicUserInfo? user, String? error})> getMyBasicUserInfo() async {
    final uid = _uid;
    if (uid == null) return (user: null, error: 'Not logged in');
    return getBasicUserInfo(uid);
  }


}
