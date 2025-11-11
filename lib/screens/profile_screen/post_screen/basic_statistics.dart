import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/user_infor_container/list_suggestion_user.dart';

import '../../../../config/general_specifications.dart';
import '../../../services/firebase_services/profile_services/user_activity_services.dart';

class BasicStatistics extends StatefulWidget {
  /// true: đang xem chính mình; false: đang xem người khác
  final bool isOwnerProfile;

  /// uid của chủ profile đang được xem (khi xem người khác)
  final String? userId;

  const BasicStatistics({
    super.key,
    required this.isOwnerProfile,
    required this.userId,
  });

  @override
  State<BasicStatistics> createState() => _BasicStatisticsState();
}

class _BasicStatisticsState extends State<BasicStatistics> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final viewerUid = FirebaseAuth.instance.currentUser?.uid;
    final String? rawUid = widget.isOwnerProfile ? viewerUid : widget.userId;
    final String? profileUid =
    (rawUid != null && rawUid.trim().isNotEmpty) ? rawUid.trim() : null;
    if (profileUid == null) {
      return _StatsShell(specs: specs, following: 0, followers: 0);
    }


    return StreamBuilder(
      stream: UserActivityServices.I.streamActivity(profileUid),
      builder: (context, snapshot) {
        final following = snapshot.data?.followingCount ?? 0;
        final followers = snapshot.data?.followerCount ?? 0;

        return _StatsShell(
          specs: specs,
          following: following,
          followers: followers,
        );
      },
    );
  }
}

class _StatsShell extends StatelessWidget {
  final GeneralSpecifications specs;
  final int following;
  final int followers;

  const _StatsShell({
    required this.specs,
    required this.following,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 5),
        SizedBox(
          height: 290,
          width: specs.screenWidth,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                child: ListSuggestionUser(),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  height: 130,
                  width: 275,
                  child: CustomPaint(
                    painter: BasicStatisticsPainter(),
                    size: const Size(280, 130),
                    child: Center(
                      child: SizedBox(
                        height: 70,
                        width: 275,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Journey (placeholder, thay bằng dữ liệu thật nếu có)
                            Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: specs.black240,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "0",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Journey",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: specs.black100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Following
                            SizedBox(
                              height: 50,
                              width: 75,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$following",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Follow",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: specs.black100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Followers
                            SizedBox(
                              height: 50,
                              width: 75,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$followers",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Followed",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: specs.black100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BasicStatisticsPainter extends CustomPainter {
  BasicStatisticsPainter({
    this.rightBorderRadius = 23,
    this.leftBorderRadius = 30,
  });
  final double rightBorderRadius;
  final double leftBorderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(leftBorderRadius * 2, leftBorderRadius);
    path.quadraticBezierTo(leftBorderRadius * 0.5, leftBorderRadius, 0, 0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      leftBorderRadius * 0.5,
      size.height - leftBorderRadius,
      leftBorderRadius * 2,
      size.height - leftBorderRadius,
    );
    path.lineTo(size.width - rightBorderRadius, size.height - leftBorderRadius);
    path.quadraticBezierTo(
      size.width,
      size.height - leftBorderRadius,
      size.width,
      size.height - leftBorderRadius - rightBorderRadius,
    );
    path.lineTo(size.width, leftBorderRadius + rightBorderRadius);
    path.quadraticBezierTo(
      size.width,
      leftBorderRadius,
      size.width - rightBorderRadius,
      leftBorderRadius,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
