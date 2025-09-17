import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';

class CustomTitleInputProfile extends StatelessWidget {
  final String titleInput;
  final Widget child;

  const CustomTitleInputProfile({super.key, required this.titleInput, required this.child});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    double inputWidth = specs.screenWidth - 60;
    return SizedBox(
      width: inputWidth,
      height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  textAlign: TextAlign.left,
                  titleInput,
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: const Color.fromRGBO(100, 100, 100, 1)),
                ),
              ),
              child
            ],
          ),
        ],
      ),
    );
  }
}
