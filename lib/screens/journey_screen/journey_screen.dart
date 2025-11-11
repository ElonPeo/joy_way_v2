import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/journey_screen/pages/journey_requirements.dart';
import 'package:joy_way/screens/journey_screen/pages/journey_screens.dart';
import '../../../config/general_specifications.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: specs.black240,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              height: 130,
              width: specs.screenWidth,
              decoration: BoxDecoration(
                color: Colors.white
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 15,),
                      Text(
                        "Journey",
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  PreferredSize(
                    preferredSize: const ui.Size.fromHeight(45),
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      labelColor: Colors.black,
                      unselectedLabelColor: specs.black150,
                      // style chữ
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      dividerColor: specs.black240,

                      // gạch dưới
                      indicatorColor: specs.pantoneColor4,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: "Journey"),
                        Tab(text: "Requirements"),
                        Tab(text: "Past journey"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  JourneyScreens(),
                  JourneyRequirements(),
                  JourneyRequirements(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
