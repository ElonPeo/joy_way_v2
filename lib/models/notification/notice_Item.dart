import '../request/make_friend.dart';
import '../request/request_journey/request_join_journey/request_join_journey.dart';

enum NoticeType { friend, journey }

class NoticeItem {
  final NoticeType type;
  final DateTime sortTime;
  final MakeFriend? friend;
  final RequestJoinJourney? journey;

  NoticeItem.friend(this.friend)
      : journey = null,
        type = NoticeType.friend,
        sortTime = (friend!.updatedAt ?? friend!.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));

  NoticeItem.journey(this.journey)
      : friend = null,
        type = NoticeType.journey,
        sortTime = (journey!.updatedAt ?? journey!.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
}
