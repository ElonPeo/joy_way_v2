import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileFirestore {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;
  String? get _email => _user?.email;
  bool get isLoggedIn => _user != null;


  int checkValidPhoneNumber(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(03|05|07|08|09)\d{8}$').hasMatch(clean)) {
      return 305;
    }
    return 1;
  }

  List<String> generateSearchKeywords(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return [''];
    final keywords = <String>[];
    for (int i = 1; i <= v.length; i++) {
      keywords.add(v.substring(0, i));
    }
    return keywords;
  }


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

  Future<Map<String, dynamic>?> getUserInformation(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return {
        'userName': data['userName'],
        'name': data['name'],
        'sex': data['sex'],
        'phoneNumber': data['phoneNumber'],
        'dateOfBirth': data['dateOfBirth'] != null
            ? (data['dateOfBirth'] as Timestamp).toDate()
            : null,
        'currentAddress': data['currentAddress'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserInformation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return {
        'userName': data['userName'],
        'name': data['name'],
        'sex': data['sex'],
        'phoneNumber': data['phoneNumber'],
        'dateOfBirth': data['dateOfBirth'] != null
            ? (data['dateOfBirth'] as Timestamp).toDate()
            : null,
        'currentAddress': data['currentAddress'],
        'email': data['email'],
      };
    } catch (e) {
      return null;
    }
  }


  Future<Map<String, dynamic>?> getOtherUserInformationByUid(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return {
        'userName': data['userName'],
        'name': data['name'],
        'sex': data['sex'],
        'phoneNumber': data['phoneNumber'],
        'dateOfBirth': data['dateOfBirth'] != null
            ? (data['dateOfBirth'] as Timestamp).toDate()
            : null,
        'currentAddress': data['currentAddress'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkUserNameExists(String userName) async {
    try {
      final currentUid = _uid;
      if (currentUid == null) return false;
      final q = await _db
          .collection('users')
          .where('userName', isEqualTo: '@${userName.trim()}')
          .limit(2)
          .get();
      return q.docs.any((d) => d.id != currentUid);
    } catch (e) {
      return true;
    }
  }

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


  // ==== Writes ====
  Future<String?> createUserInformation({
    required String email,
    required String userId,
    String? userName,
    String? name,
    String? sex,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? currentAddress,
  }) async {
    try {
      final docRef = _db.collection('users').doc(userId);

      final data = <String, dynamic>{
        'email': email,
        'userId': userId,
        'userName': userName,
        'searchKeywords': userName != null
            ? generateSearchKeywords(userName)
            : null,
        'name': name,
        'sex': sex,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        'currentAddress': currentAddress,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }..removeWhere((k, v) => v == null);

      await docRef.set(data);
      return null;
    } catch (e) {
      return "Error from create information: $e";
    }
  }

  Future<String?> updateUserInformation({

    String? name,
    String? sex,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? currentAddress,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return "NOT_LOGGED_IN";
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (sex != null) 'sex': sex,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        if (currentAddress != null) 'currentAddress': currentAddress,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
      return null;
    } catch (e) {
      return "Update failed: $e";
    }
  }

  Future<String?> editProfile({
    required String? userName,
    required String? name,
    required String? sex,
    required String? phoneNumber,
    required DateTime? dateOfBirth,
    required String? currentAddress,
  }) async {
    try {
      // 1) kiểm tra đăng nhập
      final uid = _uid;
      final email = _email;
      if (uid == null) return "NOT_LOGGED_IN";
      // 2) kiểm tra tồn tại
      final exists = await checkUserExists(uid);
      if (exists) {
        return await updateUserInformation(
          name: name,
          sex: sex,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          currentAddress: currentAddress,
        );
      } else {
        return await createUserInformation(
          email: email ?? "error email",
          userId: uid,
          userName: userName,
          name: name,
          sex: sex,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          currentAddress: currentAddress,
        );
      }
    } catch (e) {
      return e.toString();
    }
  }





}
