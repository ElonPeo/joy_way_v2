// pubspec.yaml:
//   firebase_core: ^...
//   firebase_auth: ^...
//   cloud_firestore: ^...
//   firebase_storage: ^...
//   image_picker: ^...

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

enum ImageVisibility { public, private, restricted }

enum ImageType {
  avatar,
  background,
  post,
  message,
}

class ProfileFireStorageImage {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  // Chuẩn hoá path
  String _buildStoragePath({
    required String uid,
    required ImageType type,
    required ImageVisibility visibility,
    required String imageId,
  }) {
    final folder = switch (type) {
      ImageType.avatar => 'avatar',
      ImageType.background => 'background',
      ImageType.message => 'message',
      ImageType.post => 'post',
    };
    final scope = switch (visibility) {
      ImageVisibility.public => 'public',
      ImageVisibility.private => 'private',
      ImageVisibility.restricted => 'restricted',
    };
    return 'users/$uid/$scope/$folder/$imageId';
  }
  // Up ảnh
  Future<({
  String imageId,
  DocumentReference<Map<String, dynamic>> docRef,
  Reference storageRef,
  })> _uploadOne({
    required String ownerUid,
    required File file,
    required ImageType type,
    required ImageVisibility visibility,
    required List<String> allowedUserIds,
  }) async {
    final imageId = _firestore.collection('images').doc().id;
    final storagePath = _buildStoragePath(
      uid: ownerUid,
      type: type,
      visibility: visibility,
      imageId: imageId,
    );
    final storageRef = _storage.ref(storagePath);
    // Metadata upload
    final meta = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: visibility == ImageVisibility.public
          ? 'public, max-age=31536000, immutable'
          : null,
      customMetadata: {
        'ownerUid': ownerUid,
        'imageId': imageId,
        'imageType': type.name,
        'visibility': visibility.name,
      },
    );
    await storageRef.putFile(file, meta);
    // Lấy metadata đầy đủ để lưu Firestore
    final fullMeta = await storageRef.getMetadata();
    final docRef = _firestore.collection('images').doc(imageId);
    await docRef.set({
      'ownerUid': ownerUid,
      'imageType': type.name,
      'visibility': visibility.name,
      'allowedUserIds': allowedUserIds,
      'storagePath': storagePath,
      'mimeType': fullMeta.contentType,
      'size': fullMeta.size,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return (imageId: imageId, docRef: docRef, storageRef: storageRef);
  }


  // Xoá an toàn nếu có lỗi
  Future<String?> _safeDelete(
      DocumentReference<Map<String, dynamic>>? d,
      Reference? r,
      ) async {
    try {
      if (d != null) {
        await d.delete();
      }
    } catch (e) {
      final msg = 'Failed to delete Firestore doc: ${d?.path}, error: $e';
      return msg;
    }
    try {
      if (r != null) {
        await r.delete();
      }
    } catch (e) {
      final msg = 'Failed to delete Storage file: ${r?.fullPath}, error: $e';
      return msg;
    }
    return null;
  }





  Future<String?> uploadAvatarAndBackgroundImages({
    File? avatarFile,
    File? backgroundFile,
    ImageVisibility visibility = ImageVisibility.public,
    List<String> allowedUserIds = const [],
  }) async {
    /// 1) Xác thực người dùng
    final ownerUid = user?.uid;
    if (ownerUid == null) return 'User not logged in';
    if (avatarFile == null && backgroundFile == null) return null;

    /// 2) Thực hiện upload
    ({
    DocumentReference<Map<String, dynamic>>? avatarDoc,
    DocumentReference<Map<String, dynamic>>? bgDoc,
    Reference? avatarRef,
    Reference? bgRef,
    String? newAvatarId,
    String? newBgId,
    }) acc = (avatarDoc: null, bgDoc: null, avatarRef: null, bgRef: null, newAvatarId: null, newBgId: null);

    try {
      // Upload song song
      final futures = <Future<void>>[];
      if (avatarFile != null) {
        futures.add(() async {
          final r = await _uploadOne(
            ownerUid: ownerUid,
            file: avatarFile,
            type: ImageType.avatar,
            visibility: visibility,
            allowedUserIds: allowedUserIds,
          );
          acc = (
          avatarDoc: r.docRef,
          bgDoc: acc.bgDoc,
          avatarRef: r.storageRef,
          bgRef: acc.bgRef,
          newAvatarId: r.imageId,
          newBgId: acc.newBgId,
          );
        }());
      }

      if (backgroundFile != null) {
        futures.add(() async {
          final r = await _uploadOne(
            ownerUid: ownerUid,
            file: backgroundFile,
            type: ImageType.background,
            visibility: visibility,
            allowedUserIds: allowedUserIds,
          );
          acc = (
          avatarDoc: acc.avatarDoc,
          bgDoc: r.docRef,
          avatarRef: acc.avatarRef,
          bgRef: r.storageRef,
          newAvatarId: acc.newAvatarId,
          newBgId: r.imageId,
          );
        }());
      }

      await Future.wait(futures, eagerError: true);

      // Cập nhật pointer trong users/{uid}
      final update = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (acc.newAvatarId != null) update['avatarImageId'] = acc.newAvatarId;
      if (acc.newBgId != null) update['backgroundImageId'] = acc.newBgId;

      if (update.length > 1) {
        await _firestore.collection('users').doc(ownerUid).set(update, SetOptions(merge: true));
      }

      return null; // success
    } catch (e) {
      await _safeDelete(acc.avatarDoc, acc.avatarRef);
      await _safeDelete(acc.bgDoc, acc.bgRef);
      return 'Upload avatar/background failed: $e';
    }
  }







  Future<({String? url, String? error})> getImageUrlById(String imageId) async {
    try {
      final viewer = _auth.currentUser;
      final doc = await _firestore.collection('images').doc(imageId).get();

      if (!doc.exists) {
        return (url: null, error: 'Image not found');
      }
      final data = doc.data()!;
      final ownerUid = data['ownerUid'] as String?;
      final storagePath = data['storagePath'] as String?;
      final visibility = (data['visibility'] as String?) ?? 'public';
      final allowed = (data['allowedUserIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();

      // Kiểm tra quyền xem ở client
      final viewerUid = viewer?.uid;
      final canView = switch (visibility) {
        'public' => true,
        'private' => viewerUid != null && viewerUid == ownerUid,
        'restricted' => viewerUid != null && (viewerUid == ownerUid || allowed.contains(viewerUid)),
        _ => false,
      };
      if (!canView) {
        return (url: null, error: 'Permission denied');
      }

      if (storagePath == null) {
        return (url: null, error: 'Invalid storage path');
      }

      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL(); // Sẽ fail nếu Storage rules chặn
      return (url: url, error: null);
    } catch (e) {
      return (url: null, error: 'Failed to get URL: $e');
    }
  }

  /// Lấy URL ảnh avatar theo imageId (tiện khi đã biết id)
  Future<({String? url, String? error})> getAvatarUrlByImageId(String imageId) {
    return getImageUrlById(imageId);
  }

  /// Lấy URL ảnh nền theo imageId
  Future<({String? url, String? error})> getBackgroundUrlByImageId(String imageId) {
    return getImageUrlById(imageId);
  }

  /// Lấy cả avatar/background URL của MỘT user (dùng users/{uid}.avatarImageId/backgroundImageId)
  Future<({String? avatarUrl, String? bgUrl, String? error})> getUserAvatarAndBackgroundUrls(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return (avatarUrl: null, bgUrl: null, error: 'User not found');
      }
      final data = userDoc.data()!;
      final avatarId = data['avatarImageId'] as String?;
      final bgId = data['backgroundImageId'] as String?;

      String? avatarUrl;
      String? bgUrl;

      if (avatarId != null && avatarId.isNotEmpty) {
        final r = await getImageUrlById(avatarId);
        if (r.error == null) {
          avatarUrl = r.url;
        } else if (r.error == 'Permission denied') {
          // avatarUrl để null, nhưng vẫn trả error tổng hợp phía dưới nếu cần
        } else {
          return (avatarUrl: null, bgUrl: null, error: 'Avatar: ${r.error}');
        }
      }

      if (bgId != null && bgId.isNotEmpty) {
        final r = await getImageUrlById(bgId);
        if (r.error == null) {
          bgUrl = r.url;
        } else if (r.error == 'Permission denied') {
          // bgUrl để null
        } else {
          return (avatarUrl: avatarUrl, bgUrl: null, error: 'Background: ${r.error}');
        }
      }

      // Không coi permission denied là lỗi fatal -> trả về URL nào lấy được
      return (avatarUrl: avatarUrl, bgUrl: bgUrl, error: null);
    } catch (e) {
      return (avatarUrl: null, bgUrl: null, error: 'Failed to read user images: $e');
    }
  }

  /// Lấy URL avatar/background của CURRENT user nhanh gọn
  Future<({String? avatarUrl, String? bgUrl, String? error})> getCurrentUserAvatarAndBackgroundUrls() async {
    final u = _auth.currentUser;
    if (u == null) return (avatarUrl: null, bgUrl: null, error: 'User not logged in');
    return getUserAvatarAndBackgroundUrls(u.uid);
  }


}
