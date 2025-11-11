import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/firebase_services/request_services/request_firestore.dart';

import '../../models/request/app_request.dart';
import '../notification/participation_request_notice.dart';
import 'components/top_bar_notify.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({super.key});

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarNotify(
            page: _page,
            onPageChanged: (v) => setState(() => _page = v),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _page == 0
                ? _JourneyRequestList(userId: userId)
                : const _ActivityNotifyList(),
          ),
        ],
      ),
    );
  }
}

/// Danh sách các yêu cầu hành trình được gửi đến người dùng
class _JourneyRequestList extends StatelessWidget {
  final String? userId;
  const _JourneyRequestList({required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text("Vui lòng đăng nhập để xem thông báo."));
    }

    return StreamBuilder<List<AppRequest>>(
      stream: RequestFirestore().streamRequestsByReceiverId(
        userId!,
        type: AppRequestType.journey,
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? const <AppRequest>[];
        if (requests.isEmpty) {
          return const Center(child: Text("Không có yêu cầu mới."));
        }

        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = requests[i];
            return ParticipationRequestNotice(
              appRequest: r,
            );
          },
        );
      },
    );
  }
}


class _ActivityNotifyList extends StatelessWidget {
  const _ActivityNotifyList();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Chưa có thông báo hoạt động."));
  }
}
