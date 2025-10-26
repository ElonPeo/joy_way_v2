import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/user_infor_container/list_suggestion_user.dart';

import '../../../../config/general_specifications.dart';


class BasicStatistics extends StatelessWidget{
  const BasicStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return  Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 5,
        ),
        Container(
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
                    size: Size(280, 130),
                    child: Center(
                      child: SizedBox(
                        height: 70,
                        width: 275,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                border: Border(
                                 right: BorderSide(
                                   color: specs.black240,
                                   width: 1
                                 )
                                )
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "3 100",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16
                                      ),
                                    ),
                                    Text(
                                      "Journey",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: specs.black100
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 75,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "1",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16
                                      ),
                                    ),
                                    Text(
                                      "Follow",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: specs.black100
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 75,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "320",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16
                                      ),
                                    ),
                                    Text(
                                      "Followed",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        color: specs.black100
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
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

    /// Diem bat dau
    path.moveTo(leftBorderRadius *2, leftBorderRadius);
    path.quadraticBezierTo(leftBorderRadius*0.5, leftBorderRadius, 0, 0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(leftBorderRadius*0.5, size.height - leftBorderRadius, leftBorderRadius *2, size.height - leftBorderRadius);
    path.lineTo(size.width - rightBorderRadius, size.height - leftBorderRadius);
    path.quadraticBezierTo(size.width, size.height - leftBorderRadius, size.width, size.height - leftBorderRadius - rightBorderRadius);
    path.lineTo(size.width, leftBorderRadius + rightBorderRadius);
    path.quadraticBezierTo(size.width, leftBorderRadius, size.width - rightBorderRadius, leftBorderRadius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
