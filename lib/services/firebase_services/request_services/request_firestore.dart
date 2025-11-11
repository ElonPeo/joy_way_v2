import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/passenger/passengers.dart';
import '../../../models/request/app_request.dart';
import '../../../models/request/request_journey/components/end_request_info.dart';
import '../../../models/request/request_journey/components/start_request_info.dart';
import '../../../models/request/request_journey/request_journey.dart';

class RequestFirestore {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  RequestFirestore({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _db.collection('posts').doc(postId);

  DocumentReference<Map<String, dynamic>> _passengerRef(
          String postId, String passengerId) =>
      _postRef(postId).collection('passengers').doc(passengerId);

  String? checkValidStartRequest(StartRequestInfo start) {
    return null;
  }

  String? checkValidEndRequest(EndRequestInfo end) {
    return null;
  }

  String? validateRequest(EndRequestInfo end) {
    return null;
  }

  // ===== CREATE =====
  Future<String> createJourneyRequest({
    required String receiverId,
    required RequestJourney requestJourney,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Must login.");

    final reqRef = _db.collection('requests').doc();
    await _db.runTransaction((tx) async {
      tx.set(reqRef, {
        'id': reqRef.id,
        'senderId': user.uid,
        'receiverId': receiverId.trim(),
        'type': AppRequestType.journey.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final detailRef = reqRef.collection('details').doc('journey');
      tx.set(detailRef, requestJourney.toMap());
    });

    return reqRef.id;
  }

  // ===== QUERY ONE-SHOT =====
  Future<List<Map<String, dynamic>>> getRequestsByReceiverId(
      String receiverId) async {
    final rid = receiverId.trim();
    if (rid.isEmpty) throw Exception("Receiver ID cannot be empty.");

    final qs = await _db
        .collection('requests')
        .where('receiverId', isEqualTo: rid)
        .orderBy('createdAt', descending: true)
        .get();

    return qs.docs.map((d) => d.data()).toList();
  }

  // ===== REALTIME STREAM (cho tab Thông báo) =====
  Stream<List<AppRequest>> streamRequestsByReceiverId(
    String receiverId, {
    AppRequestType? type,
    int? limit,
  }) {
    final rid = receiverId.trim();
    if (rid.isEmpty) return const Stream.empty();

    Query<Map<String, dynamic>> q =
        _db.collection('requests').where('receiverId', isEqualTo: rid);

    if (type != null) {
      q = q.where('type', isEqualTo: type.name);
    }

    q = q.orderBy('createdAt', descending: true);
    if (limit != null && limit > 0) {
      q = q.limit(limit);
    }

    return q.snapshots().map(
          (qs) => qs.docs.map((d) => AppRequest.fromDoc(d)).toList(),
        );
  }

  // ===== LẤY CHI TIẾT JOURNEY CHO 1 REQUEST =====
  Future<Map<String, dynamic>?> getJourneyDetail(String requestId) async {
    final id = requestId.trim();
    if (id.isEmpty) throw Exception("requestId is empty.");

    final doc = await _db
        .collection('requests')
        .doc(id)
        .collection('details')
        .doc('journey')
        .get();

    return doc.data();
  }

  // Stream chỉ AppRequest (doc gốc: requests/{id})
  Stream<AppRequest?> streamAppRequest(String requestId) {
    final id = requestId.trim();
    if (id.isEmpty) return const Stream.empty();
    return _db
        .collection('requests')
        .doc(id)
        .snapshots()
        .map((snap) => snap.exists ? AppRequest.fromDoc(snap) : null);
  }

// Stream chi tiết journey (subdoc: requests/{id}/details/journey)
  Stream<RequestJourney?> streamJourneyDetail(String requestId) {
    final id = requestId.trim();
    if (id.isEmpty) return const Stream.empty();

    return _db
        .collection('requests')
        .doc(id)
        .collection('details')
        .doc('journey')
        .snapshots()
        .map((snap) {
      final m = snap.data();
      if (m == null) return null;
      return RequestJourney.fromMap(m);
    });
  }

  Future<void> updateRequestAcceptance({
    required String requestId,
    required bool isAccepted,
  }) async {
    try {
      final id = requestId.trim();
      if (id.isEmpty) throw Exception("requestId is empty.");

      await _db
          .collection('requests')
          .doc(id)
          .collection('details')
          .doc('journey')
          .update({'isAccepted': isAccepted});
    } on FirebaseException catch (e) {
      throw Exception("Firebase error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to update acceptance: $e");
    }
  }

  Future<({String requestId})?> getJourneyByJourneyId(String journeyId) async {
    if (journeyId.trim().isEmpty) throw Exception('journeyId is empty');
    final qs = await _db
        .collectionGroup('details')
        .where('journeyId', isEqualTo: journeyId.trim())
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return null;
    final doc = qs.docs.first;
    final m = doc.data();
    final requestId = doc.reference.parent.parent!.id;
    return (requestId: requestId);
  }
}
