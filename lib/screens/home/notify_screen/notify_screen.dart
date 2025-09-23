import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/services/mapbox_services/general_map_services.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import 'package:joy_way/widgets/animated_icons/loading_rive_icon.dart';

import '../../../config/general_specifications.dart';

class NotifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
        height: specs.screenHeight,
        width: specs.screenWidth,
        color: Color(0x66FFFFFF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Loading",
            style: GoogleFonts.outfit(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10,),
          const LoadingRiveIcon(fatherHeight: 30, fatherWidth: 30, )
        ],
      ),
    );
  }
}
