
import 'package:flutter/material.dart';
import 'package:joy_way/models/passenger/passengers.dart';
import 'package:joy_way/services/firebase_services/passenger_services/passenger_firestore.dart';

import '../components/companion/companion_card.dart';

class JourneyCompanions extends StatefulWidget {
  final String postId;
  const JourneyCompanions({super.key,
  required this.postId,
  });

  @override
  State<JourneyCompanions> createState() => _JourneyCompanionsState();
}

class _JourneyCompanionsState extends State<JourneyCompanions> {

  final _pf = PassengerFirestore();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Passenger>>(
      stream: _pf.streamByPost(
        postId: widget.postId
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const [];

        if (items.isEmpty) {
          return const Center(child: Text('No companions'));
        }

        return ListView.separated(
          padding: EdgeInsets.all(0),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = items[i];
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CompanionCard(passenger: p,)
              ],
            );
          },
        );
      },
    );
  }


}
