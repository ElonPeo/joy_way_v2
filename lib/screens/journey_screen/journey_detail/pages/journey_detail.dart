import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/components/journey_status_card.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';
import 'package:joy_way/widgets/photo_view/list_avatar_view.dart';

import '../../../../models/post/post.dart';
import '../../../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../../../services/firebase_services/post_services/post_firestore.dart';

class JourneyDetail extends StatefulWidget {
  final Post post;

  const JourneyDetail({
    super.key,
    required this.post,
  });

  @override
  State<JourneyDetail> createState() => _JourneyDetailState();
}

class _JourneyDetailState extends State<JourneyDetail> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: specs.black240,
                  width: 0.8
                )
              ),
              width: specs.screenWidth - 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Information",
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _infoRow(
                    sWidth: specs.screenWidth,
                    title: "Created",
                    iconPath: "assets/icons/post/time-add.png",
                    child: Text(
                      TimeProcessing.formattedDepartureTime3(
                              widget.post.createdAt) ??
                          '',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                      sWidth: specs.screenWidth,
                      title: "Status",
                      iconPath: "assets/icons/post/status.png",
                      child: Row(
                        children: [
                          JourneyStatusCard(postStatus: widget.post.status)
                        ],
                      )),
                  const SizedBox(height: 10),
                  _infoRow(
                    sWidth: specs.screenWidth,
                    title: "Start time",
                    iconPath: "assets/icons/post/calendar-clock.png",
                    child: Text(
                      TimeProcessing.formattedDepartureTime3(
                              widget.post.departureTime) ??
                          '',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    sWidth: specs.screenWidth,
                    title: "Vehicle",
                    iconPath: "assets/icons/post/car.png",
                    child: Text(
                      widget.post.vehicleType.name,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    sWidth: specs.screenWidth,
                    title: "Passenger",
                    iconPath: "assets/icons/post/users.png",
                    child: FutureBuilder<List<String>>(
                      future: PassengerFirestore()
                          .getUserIdsByPostId(widget.post.id),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                              height: 40, width: 40, child: SizedBox());
                        }
                        final ids = snap.data ?? const <String>[];
                        if (ids.isEmpty) {
                          return Text(
                            "No passengers",
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.black54),
                          );
                        }
                        return ListAvatarView(
                            userIds: ids, size: 34, overlap: 12);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    sWidth: specs.screenWidth,
                    title: "Amount",
                    iconPath: "assets/icons/post/coins.png",
                    child: Text(
                      widget.post.amount != null
                          ? '${widget.post.amount.toString()} VND'
                          : '0 VND',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: specs.pantoneColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      "When you enter the departure preparation state, you will no longer receive any requests to join the journey and it will not be possible to remove someone from the journey.",
                      style: GoogleFonts.outfit(
                          color: specs.black150,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            )
          ],
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
                  newStatus: PostStatus.prepareToDepart,
                );

                if (!mounted) return;

                if (success) {
                  ShowNotification.showAnimatedSnackBar(
                    context,
                    'Change status to "Prepare to depart" successful',
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
                'Prepare to depart',
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

  Widget _infoRow({
    required String title,
    required Widget child,
    required String iconPath,
    required sWidth,
  }) {
    return Container(
      width: sWidth,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 115,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageIcon(
                  AssetImage(iconPath),
                  color: Colors.black,
                  size: 14,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: sWidth - 200, child: child)
        ],
      ),
    );
  }
}
