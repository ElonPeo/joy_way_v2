import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/post.dart';

import '../../../../config/general_specifications.dart';
import '../../../../services/data_processing/time_processing.dart';
import '../../../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../../../widgets/photo_view/list_avatar_view.dart';
import '../../../journey_screen/journey_detail/components/journey_status_card.dart';

class PostInformation extends StatelessWidget {
  final Post post;
  const PostInformation({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
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
              fontSize: 22,
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
                  post.createdAt) ??
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
                  JourneyStatusCard(postStatus: post.status)
                ],
              )),
          const SizedBox(height: 10),
          _infoRow(
            sWidth: specs.screenWidth,
            title: "Start time",
            iconPath: "assets/icons/post/calendar-clock.png",
            child: Text(
              TimeProcessing.formattedDepartureTime3(
                  post.departureTime) ??
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
              post.vehicleType.name,
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
                  .getUserIdsByPostId(post.id),
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
              post.amount != null
                  ? '${post.amount.toString()} VND'
                  : '0 VND',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: specs.pantoneColor,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
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



