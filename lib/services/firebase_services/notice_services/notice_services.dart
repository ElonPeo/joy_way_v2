import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../../models/notification/notice_Item.dart';
import '../../../models/request/make_friend.dart';
import '../../../models/request/request_journey/request_join_journey/request_join_journey.dart';

class NoticeService {
  final FirebaseFirestore _db;
  NoticeService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<NoticeItem>> streamNotices(String userId) {
    final friend$ = _db
        .collection('make_friend_requests')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((qs) => qs.docs
        .map((d) => MakeFriend.fromMap(d.data(), id: d.id))
        .toList());

    final journey$ = _db
        .collection('request_join_journey')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((qs) => qs.docs
        .map((d) => RequestJoinJourney.fromMap(d.data(), id: d.id))
        .toList());

    return Rx.combineLatest2<List<MakeFriend>, List<RequestJoinJourney>, List<NoticeItem>>(
      friend$,
      journey$,
          (friends, journeys) {
        final items = <NoticeItem>[
          ...friends.map((f) => NoticeItem.friend(f)),
          ...journeys.map((j) => NoticeItem.journey(j)),
        ];
        items.sort((a, b) => b.sortTime.compareTo(a.sortTime)); // mới nhất lên đầu
        return items;
      },
    );
  }
}
