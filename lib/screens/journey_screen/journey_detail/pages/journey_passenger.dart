
import 'package:flutter/material.dart';
import 'package:joy_way/models/passenger/passengers.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/components/passenger_card.dart';
import 'package:joy_way/services/firebase_services/passenger_services/passenger_firestore.dart';


class JourneyPassenger extends StatefulWidget {
  final String postId;
  const JourneyPassenger({super.key,
    required this.postId,
  });

  @override
  State<JourneyPassenger> createState() => _JourneyCompanionsState();
}

class _JourneyCompanionsState extends State<JourneyPassenger> {

  final _pf = PassengerFirestore();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Passenger>>(
      stream: _pf.streamPassengersByPostId(postId: widget.postId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const [];

        if (items.isEmpty) {
          return const Center(child: Text('No companions'));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i];
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PassengerCard(passenger: p,)
              ],
            );
          },
        );
      },
    );
  }


}
