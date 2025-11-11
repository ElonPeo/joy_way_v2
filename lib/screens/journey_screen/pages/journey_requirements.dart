import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/request/app_request.dart';
import '../../../services/firebase_services/request_services/request_firestore.dart';
import '../../notification/participation_request_notice.dart';

class JourneyRequirements extends StatefulWidget {
  const JourneyRequirements({super.key});

  @override
  State<JourneyRequirements> createState() => _JourneyRequirementsState();
}

class _JourneyRequirementsState extends State<JourneyRequirements> {

  late final String? userId;


  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
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