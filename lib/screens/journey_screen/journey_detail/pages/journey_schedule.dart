import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/components/journey_status_card.dart';
import 'package:joy_way/screens/post/post_detail/components/schedule/post_schedule.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';
import 'package:joy_way/widgets/photo_view/list_avatar_view.dart';

import '../../../../models/post/post.dart';
import '../../../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../../../services/firebase_services/post_services/post_firestore.dart';

class JourneySchedule extends StatefulWidget {
  final Post post;
  const JourneySchedule({
    super.key,
    required this.post,
  });
  @override
  State<JourneySchedule> createState() => _JourneyScheduleState();
}

class _JourneyScheduleState extends State<JourneySchedule> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return ListView(
      padding: EdgeInsets.only(top: 15,left: 15,right: 15),
      children: [
        PostSchedule(post: widget.post),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(20),
          width: specs.screenWidth - 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: specs.black240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Note",
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: specs.screenWidth - 50,
                child: Text(
                  "When you change this status it will notify people of your location and they are ready to go.",
                  style: GoogleFonts.outfit(
                      color: specs.black150,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomAnimatedButton(
              height: 45,
              width: specs.screenWidth - 30,
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final success = await PostFirestore().updatePostStatus(
                  postId: widget.post.id,
                  newStatus: PostStatus.hasDeparted,
                );

                if (!mounted) return;

                if (success) {
                  ShowNotification.showAnimatedSnackBar(
                    context,
                    'Change status to "Has departed" successful',
                    3,
                    const Duration(milliseconds: 500),
                  );
                } else {
                  ShowNotification.showAnimatedSnackBar(
                    context,
                    'Failed to change status',
                    1,
                    const Duration(milliseconds: 500),
                  );
                }
              },
              child: Text(
                'Set off and share your journey',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
