// user_verification_firestore.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/verify/user_verification.dart';

class UserVerificationFirestore {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  UserVerificationFirestore({
    FirebaseFirestore? db,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _col =>
      _db.collection('userVerifications'); // docId = userId

  Future<String?> _uploadImage({
    required String userId,
    required String fileName,
    required File? file,
  }) async {
    if (file == null) return null;

    final path = 'user_verifications/$userId/$fileName.jpg';
    final ref = _storage.ref(path);

    try {
      await ref.putFile(file); // overwrite luôn file cũ
      return ref.fullPath;     // ví dụ: user_verifications/uid/front_id.jpg
    } catch (e) {
      print("Lỗi upload ảnh $fileName: $e");
      return null;
    }
  }

  Future<void> submitVerification({
    File? frontIdImage,
    File? backIdImage,
    File? faceImage,
    String? ocrRawText,
    String? ocrTextNoAccent,
    double? faceSimilarity,
    double? faceSimilarityThreshold,
    bool? faceMatched,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Không tìm thấy người dùng hiện tại.');
    }

    // Lấy dữ liệu cũ (nếu có) để giữ createdAt + path cũ / info cũ
    UserVerification? old;
    try {
      final doc = await _col.doc(uid).get();
      if (doc.exists) {
        old = UserVerification.fromDoc(doc);
      }
    } catch (_) {}

    String? frontPath = old?.idFrontImagePath;
    String? backPath  = old?.idBackImagePath;
    String? facePath  = old?.faceImagePath;

    // Upload ảnh mới (overwrite), nếu null thì giữ path cũ
    if (frontIdImage != null) {
      final newFrontPath = await _uploadImage(
        userId: uid,
        fileName: 'front_id',
        file: frontIdImage,
      );
      if (newFrontPath != null) {
        frontPath = newFrontPath;
      }
    }

    if (backIdImage != null) {
      final newBackPath = await _uploadImage(
        userId: uid,
        fileName: 'back_id',
        file: backIdImage,
      );
      if (newBackPath != null) {
        backPath = newBackPath;
      }
    }

    if (faceImage != null) {
      final newFacePath = await _uploadImage(
        userId: uid,
        fileName: 'face',
        file: faceImage,
      );
      if (newFacePath != null) {
        facePath = newFacePath;
      }
    }

    final now = DateTime.now();
    final createdAt = old?.createdAt ?? now;

    final ver = UserVerification(
      userId: uid,
      idFrontImagePath: frontPath,
      idBackImagePath: backPath,
      faceImagePath: facePath,
      ocrRawText: ocrRawText ?? old?.ocrRawText,
      ocrTextNoAccent: ocrTextNoAccent ?? old?.ocrTextNoAccent,
      faceSimilarity: faceSimilarity ?? old?.faceSimilarity,
      faceSimilarityThreshold:
      faceSimilarityThreshold ?? old?.faceSimilarityThreshold,
      faceMatched: faceMatched ?? old?.faceMatched,
      idStatus: (frontPath != null && backPath != null) ? 'submitted' : 'none',
      faceStatus: facePath != null ? 'submitted' : 'none',
      overallStatus: 'pending',
      isVerified: false,
      hasIdCard: frontPath != null && backPath != null,
      hasFacePhoto: facePath != null,
      createdAt: createdAt,
      updatedAt: now,
      verifiedAt: old?.verifiedAt,
    );

    await _col.doc(uid).set(ver.toMap(), SetOptions(merge: true));
  }

  Future<UserVerification?> getUserVerification() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserVerification.fromDoc(doc);
  }

  Stream<UserVerification?> watchUserVerification() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<UserVerification?>.empty();
    }
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserVerification.fromDoc(doc);
    });
  }
}
