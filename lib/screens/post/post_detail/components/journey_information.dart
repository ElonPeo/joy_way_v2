import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/post.dart';

import '../../../../config/general_specifications.dart';

class JourneyInformation extends StatelessWidget {
  final Post post;

  const JourneyInformation({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      width: specs.screenWidth - 15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Journey information",
                textAlign: TextAlign.left,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: specs.screenWidth,
            height: 1,
            color: specs.black200,
          ),

          Container(
            width: specs.screenWidth - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Vehicle type",
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: specs.black100,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  post.vehicleType.name,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: specs.screenWidth - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available seats",
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: specs.black100,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  post.availableSeats.toString(),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: specs.screenWidth - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Type of cost",
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: specs.black100,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  post.priceText,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: specs.screenWidth - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cost sharing",
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: specs.black100,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  '${post.amount.toString()} VND',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: specs.pantoneColor,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
