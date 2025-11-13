import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';

class RequestStatistic extends StatelessWidget {
  final String postId;
  final int maxRequest;

  const RequestStatistic({
    super.key,
    required this.postId,
    required this.maxRequest,
  });

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final service = RequestJoinJourneyServices();

    return StreamBuilder<List<String>>(
      stream: service.streamSenderIdsByPostId(postId), // <-- Stream<List<String>>
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final currentCount = (snap.data ?? const <String>[]).length;
        final denom = maxRequest <= 0 ? 1 : maxRequest;
        final percent = (currentCount / denom).clamp(0.0, 1.0);

        return Container(
          width: specs.screenWidth / 2 - 25,
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
                  Row(children: [
                    const SizedBox(width: 10),
                    Text(
                      "Request",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 241, 203, 1),
                    ),
                    child: const Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/post/user-question.png"),
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 1000,
                percent: percent,
                center: Text(
                  "$currentCount/$maxRequest",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color.fromRGBO(255, 241, 203, 1),
                backgroundColor: specs.black240,
              ),
            ],
          ),
        );
      },
    );
  }
}
