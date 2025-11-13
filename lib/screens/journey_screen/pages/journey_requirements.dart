import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/screens/journey_screen/components/request_join_card.dart';

import '../../../models/request/request_journey/request_join_journey/request_join_journey.dart';
import '../../../services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';

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
    if (userId == null) {
      return const Center(child: Text("You are not logged in"));
    }

    final service = RequestJoinJourneyServices();

    return StreamBuilder<Map<String, dynamic>>(
      stream: service.streamRequestsByReceiver(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Nếu có lỗi
        if (snapshot.hasError || (snapshot.data?['error'] != null)) {
          return Center(
            child: Text('Err: ${snapshot.data?['error'] ?? snapshot.error}'),
          );
        }

        final List<RequestJoinJourney> list =
            (snapshot.data?['data'] as List<RequestJoinJourney>?) ?? [];

        if (list.isEmpty) {
          return const Center(child: Text("No have requested any"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          itemBuilder: (context, i) {
            final r = list[i];
            return RequestJoinCard(requestJoinJourney: r);
          },
        );

      },
    );
  }

}

