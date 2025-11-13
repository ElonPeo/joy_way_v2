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
        return " Searching";
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

  Color _postStatusTextColor(PostStatus status) {
    switch (status) {
      case PostStatus.findingCompanion:
        return const Color.fromRGBO(200, 86, 5, 1);
      case PostStatus.prepareToDepart:
        return const Color.fromRGBO(0, 134, 177, 1);
      case PostStatus.hasDeparted:
        return const Color.fromRGBO(0, 134, 177, 1);
      case PostStatus.isTravelingWithCompanions:
        return const Color.fromRGBO(0, 134, 177, 1);
      case PostStatus.finished:
        return const Color.fromRGBO(0, 103, 57, 1);
      case PostStatus.canceled:
        return const Color.fromRGBO(220, 20, 60, 1);
    }
  }

  Color _postStatusToColor(PostStatus status) {
    switch (status) {
      case PostStatus.findingCompanion:
        return const Color.fromRGBO(253, 248, 224, 1);
      case PostStatus.prepareToDepart:
        return const Color.fromRGBO(210, 247, 255, 1);
      case PostStatus.hasDeparted:
        return const Color.fromRGBO(210, 247, 255, 1);
      case PostStatus.isTravelingWithCompanions:
        return const Color.fromRGBO(210, 247, 255, 1);
      case PostStatus.finished:
        return const Color.fromRGBO(204, 255, 228, 1);
      case PostStatus.canceled:
        return const Color.fromRGBO(220, 20, 60, 1);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _postStatusToColor(postStatus)
      ),
      child: Center(
        child: Text("●  ${_postStatusToString(postStatus)}",
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _postStatusTextColor(postStatus),
          ),
        ),
      ),
    );
  }
}