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
    return Container(
      width: inputWidth,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
