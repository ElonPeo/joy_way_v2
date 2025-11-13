import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/models/request/request_journey/request_join_journey/request_join_journey.dart';
import 'package:joy_way/screens/notification/request_join_notice_card.dart';

import '../../../models/notification/notice_Item.dart';
import '../../../services/firebase_services/notice_services/notice_services.dart';
import '../../../services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';
import '../../notification/friend_request_notice_card.dart';

class RequestNoticePage extends StatelessWidget {
  const RequestNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Center(child: Text("You are not logged in"));

    final noticeService = NoticeService();

    return StreamBuilder<List<NoticeItem>>(
      stream: noticeService.streamNotices(userId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final items = snap.data!;
        if (items.isEmpty) return const Center(child: Text("No notifications"));

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            switch (it.type) {
              case NoticeType.friend:
                return FriendRequestNoticeCard(makeFriend: it.friend!);
              case NoticeType.journey:
                return RequestJoinNoticeCard(requestJoinJourney: it.journey!);
            }
          },
        );
      },
    );
  }
}

