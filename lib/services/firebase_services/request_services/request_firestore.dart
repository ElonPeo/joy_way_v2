import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/request/app_request.dart';
import '../../../models/request/request_journey/request_join_journey/end_request_info.dart';
import '../../../models/request/request_journey/request_join_journey/start_request_info.dart';


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




}
