import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/general_specifications.dart';


class BasicStatistics extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return  Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 80,
          width: specs.screenWidth - 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: specs.black200,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "3420",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: Colors.black),
                    ),
                    Text(
                      "JOURNEY",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "461",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                    Text(
                      "FOLLOWING",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w400,
                          fontSize: 8,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "461",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                    Text(
                      "FOLLOWERS",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w400,
                          fontSize: 8,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}