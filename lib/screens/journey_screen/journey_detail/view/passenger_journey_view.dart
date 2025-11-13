import 'package:flutter/material.dart';
import 'package:joy_way/config/general_specifications.dart';

class PassengerJourneyView extends StatelessWidget {
  const PassengerJourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: Column(
        children: [

        ],
      ),
    );
  }
}