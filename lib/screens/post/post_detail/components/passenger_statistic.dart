import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:joy_way/services/firebase_services/passenger_services/passenger_firestore.dart';

class PassengerStatistic extends StatelessWidget {
  final String postId;
  final int seat;
  final PassengerFirestore passengerService;

  PassengerStatistic({
    super.key,
    required this.postId,
    required this.seat,
    PassengerFirestore? passengerService,
  }) : passengerService = passengerService ?? PassengerFirestore();

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return StreamBuilder<List<String>>(
      stream: passengerService.streamUserIdsByPostId(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingContainer(
            width: specs.screenWidth / 2 - 25,
            height: 143, borderRadius: BorderRadius.circular(24),);
        }
        final count = snapshot.data?.length ?? 0;
        final double percent =
        seat > 0 ? (count / seat).clamp(0, 1).toDouble() : 0.0;

        return Container(
          width: specs.screenWidth / 2 - 25,
          height: 146,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 0.8,
              color: specs.black240
            )
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        "Companion",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(219, 255, 253, 1),
                    ),
                    child: const Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/post/users.png"),
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 1200,
                percent: percent,
                center: Text(
                  "$count/$seat",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color.fromRGBO(219, 255, 253, 1),
                backgroundColor: specs.black240,
              ),
            ],
          ),
        );
      },
    );
  }
}
