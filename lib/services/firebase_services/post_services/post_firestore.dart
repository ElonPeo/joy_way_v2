import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/models/post/components/detail.dart';
import 'package:joy_way/models/post/components/end_infor.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/models/post/post.dart';

import '../../../models/post/post_display.dart';
import '../profile_services/profile_firestore.dart';

class PostFirestore {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  PostFirestore({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Trả về `null` nếu hợp lệ
  String? checkValidStartInfo(StartInfo startInfo) {
    if (startInfo.departureName.trim().isEmpty) {
      return "Departure place (*) is required";
    }
    if (startInfo.availableSeats < 1) {
      return "Minimum seating capacity is 1";
    }
    if (startInfo.availableSeats > 30) {
      return "Maximum seating capacity is 30";
    }
    final now = DateTime.now();
    const grace = Duration(minutes: 1);
    if (startInfo.departureTime.isBefore(now.subtract(grace))) {
      return "Departure time cannot be in the past";
    }
    final latest = now.add(const Duration(days: 7));
    if (startInfo.departureTime.isAfter(latest)) {
      return "Departure time must be within 7 days from now";
    }
    return null;
  }


  String? checkValidEndInfo(EndInfo endInfo) {
    if (endInfo.arrivalName.trim().isEmpty) {
      return "Departure place (*) is required";
    }
    final now = DateTime.now();
    const grace = Duration(minutes: 1);
    if(endInfo.arrivalTime != null) {
      final latest = now.add(const Duration(days: 7));
      if (endInfo.arrivalTime!.isBefore(now.subtract(grace))) {
        return "Departure time cannot be in the past";
      }
      if (endInfo.arrivalTime!.isAfter(latest)) {
        return "Departure time must be within 7 days from now";
      }
    }
    return null;
  }

  String? checkValidDetail(DetailInfo detailInfo) {
    switch (detailInfo.type) {
      case ExpenseType.free:
        if ((detailInfo.amount ?? 0) > 0) {
          return "Free trip must not have an amount.";
        }
        return null;
      case ExpenseType.share:
        final amt = detailInfo.amount;
        if (amt == null) {
          return "Please enter an amount for fixed price.";
        }
        if (amt < 10000 || amt > 1000000) {
          return "Amount must be between 10,000 and 10,000,000 VND.";
        }
        return null;
    }
  }


  Future<String> savePost(Post post) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("You must be logged in to create a post.");
    }
    final err = validatePost(post);
    if (err != null) throw Exception(err);
    final postRef = _db.collection('posts').doc();
    await _db.runTransaction((tx) async {
      tx.set(postRef, {
        ...post.toMap(),
        'id': postRef.id,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return postRef.id;
  }

  String? validatePost(Post p) {
    // tên địa điểm
    if (p.departureName.trim().isEmpty) return "Departure place (*) is required.";
    if (p.arrivalName.trim().isEmpty) return "Arrival place (*) is required.";

    // toạ độ (GeoPoint mặc định 0,0 thì coi như không hợp lệ)
    if (p.departureCoordinate.latitude == 0 && p.departureCoordinate.longitude == 0) {
      return "Invalid departure coordinate.";
    }
    if (p.arrivalCoordinate.latitude == 0 && p.arrivalCoordinate.longitude == 0) {
      return "Invalid arrival coordinate.";
    }

    // thời gian
    final now = DateTime.now();
    const grace = Duration(minutes: 1);
    if (p.departureTime.isBefore(now.subtract(grace))) {
      return "Departure time cannot be in the past.";
    }
    final latest = now.add(const Duration(days: 7));
    if (p.departureTime.isAfter(latest)) {
      return "Departure time must be within 7 days from now.";
    }
    if (p.arrivalTime != null) {
      if (p.arrivalTime!.isBefore(p.departureTime)) {
        return "Arrival time cannot be earlier than departure time.";
      }
      if (p.arrivalTime!.isAfter(now.add(const Duration(days: 10)))) {
        return "Arrival time is too far in the future.";
      }
    }

    // ghế trống
    if (p.availableSeats < 1) return "Minimum seating capacity is 1.";
    if (p.availableSeats > 30) return "Maximum seating capacity is 30.";

    // chi phí
    if (p.type == ExpenseType.free) {
      if ((p.amount ?? 0) > 0) return "Free trip must not have an amount.";
    } else if (p.type == ExpenseType.share) {
      final amt = p.amount;
      if (amt == null) return "Please enter an amount for shared cost.";
      if (amt < 10000 || amt > 10000000) {
        return "Amount must be between 10,000 and 10,000,000 VND.";
      }
    }

    return null;
  }


  Future<List<PostDisplay>> getLatestPostDisplays() async {
    try {
      final snapshot = await _db
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (snapshot.docs.isEmpty) return [];

      final profileService = ProfileFirestore();
      final List<PostDisplay> result = [];

      for (final doc in snapshot.docs) {
        final post = Post.fromDoc(doc);

        // lấy thông tin user
        final userResult = await profileService.getBasicUserInfo(post.ownerId);
        final user = userResult.user;

        if (user != null) {
          result.add(PostDisplay(
            post: post,
            userInfo: user,
            timeAgo: post.departureTime.toString(),
          ));
        }
      }

      return result;
    } catch (e, st) {
      print('Error getLatestPostDisplays: $e');
      print(st);
      return [];
    }
  }





}
