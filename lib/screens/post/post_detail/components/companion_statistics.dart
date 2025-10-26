import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CompanionStatistics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: specs.screenWidth/2 - 25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Companion",
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500
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
                    child: Center(
                      child: ImageIcon(
                        const AssetImage("assets/icons/post/users.png"),
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
                animationDuration: 1200,
                percent: 0,
                center: new Text(
                  "0/1",
                  style:
                  new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Color.fromRGBO(219, 255, 253, 1),
                backgroundColor: specs.black240,
              ),


            ],
          ),
        ),
        Container(
          width: specs.screenWidth/2 - 25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Request",
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 241, 203, 1),
                    ),
                    child: Center(
                      child: ImageIcon(
                        const AssetImage("assets/icons/post/user-question.png"),
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
                animationDuration: 1200,
                percent: 0,
                center: new Text(
                  "0/30",
                  style:
                  new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Color.fromRGBO(255, 241, 203, 1),
                backgroundColor: specs.black240,
              ),


            ],
          ),
        ),
      ],
    );
  }
}
