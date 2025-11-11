import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/post.dart';


class JourneyStatusCard extends StatelessWidget {
  final PostStatus postStatus;
  const JourneyStatusCard({super.key,
  required this.postStatus
  });


  String _postStatusToString(PostStatus status) {
    switch (status) {
      case PostStatus.findingCompanion:
        return "Searching";
      case PostStatus.prepareToDepart:
        return "Prepare";
      case PostStatus.hasDeparted:
        return "Departed";
      case PostStatus.isTravelingWithCompanions:
        return "Journeyed";
      case PostStatus.finished:
        return "Finished";
      case PostStatus.canceled:
        return "Canceled";
    }
  }

  Color _postStatusToColor(PostStatus status) {
    switch (status) {
      case PostStatus.findingCompanion:
        return const Color.fromRGBO(254, 238, 145, 1);
      case PostStatus.prepareToDepart:
        return const Color.fromRGBO(140, 228, 255, 1);
      case PostStatus.hasDeparted:
        return const Color.fromRGBO(140, 228, 255, 1);
      case PostStatus.isTravelingWithCompanions:
        return const Color.fromRGBO(140, 228, 255, 1);
      case PostStatus.finished:
        return const Color.fromRGBO(62, 157, 110, 1);
      case PostStatus.canceled:
        return const Color.fromRGBO(220, 20, 60, 1);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _postStatusToColor(postStatus)
      ),
      child: Row(
        children: [
          Text(_postStatusToString(postStatus),
          style: GoogleFonts.outfit(
            fontSize: 14
          ),
          )
        ],
      ),
    );
  }
}