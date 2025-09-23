import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/general_specifications.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 170,
              width: specs.screenWidth - 20,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        border: Border(
                      right: BorderSide(
                        color: specs.black200,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User infor",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              AssetImage(
                                  "assets/icons/user_infor/envelope.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "a@gmail.com",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              AssetImage(
                                  "assets/icons/user_infor/circle-phone-flip.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "0973941815",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              AssetImage("assets/icons/user_infor/sex.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Male",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Social links",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          ImageIcon(
                            AssetImage("assets/icons/user_infor/link-alt.png"),
                            size: 16,
                            color: specs.black100,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "a@gmail.com",
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: specs.screenWidth - 80,
              child: Stack(
                children: [

                  SizedBox(
                    height: 250,
                    width: specs.screenWidth - 80,
                    child: Image.asset("assets/background/backgroundEX.jpg", fit: BoxFit.cover,),
                  ),
                  CustomPaint(
                    size: Size(specs.screenWidth - 80, 250),
                    painter: UserInformationPainter(),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: specs.screenHeight * 0.3,
        ),
      ],
    );
  }
}

class UserInformationPainter extends CustomPainter {
  UserInformationPainter({
    this.borderRadius = 40,
  });

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..color =  Color.fromRGBO(245,245,245, 1)
      ..style = PaintingStyle.fill;

    final path = Path();

    /// Diem bat dau
    path.moveTo(0, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(0, size.height - borderRadius, borderRadius,
        size.height - borderRadius);
    path.lineTo(size.width - borderRadius, size.height - borderRadius);
    path.quadraticBezierTo(size.width, size.height - borderRadius, size.width,
        size.height - borderRadius * 2);
    path.lineTo(size.width, borderRadius * 2);
    path.quadraticBezierTo(
        size.width, borderRadius, size.width - borderRadius, borderRadius);
    path.lineTo(borderRadius, borderRadius);
    path.quadraticBezierTo(0, borderRadius, 0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
