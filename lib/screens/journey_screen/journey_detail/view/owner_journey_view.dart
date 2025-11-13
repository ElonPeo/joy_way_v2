import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/post.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/components/passenger_card.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/pages/journey_passenger.dart';
import 'package:joy_way/screens/journey_screen/journey_detail/pages/journey_schedule.dart';
import 'dart:ui' as ui;

import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../pages/journey_detail.dart';


class OwnerJourneyView extends StatefulWidget {
  final Post post;
  const OwnerJourneyView({super.key,
  required this.post,
  });

  @override
  State<OwnerJourneyView> createState() => _OwnerJourneyViewState();
}

class _OwnerJourneyViewState extends State<OwnerJourneyView> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: DefaultTabController(
        length: 4,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          child: CustomAnimatedButton(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              Navigator.pop(context);
                            },
                            height: 30,
                            width: 20,
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            child: SizedBox(
                              height: 23,
                              width: 23,
                              child: Image.asset(
                                  "assets/icons/other_icons/angle-left.png"),
                            ),
                          ),
                        ),
                        Text(
                          "Journey Detail",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        )
                      ],
                    ),
                  ),
                  PreferredSize(
                    preferredSize: ui.Size.fromHeight(45),
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
                        Tab(text: "Detail"),
                        Tab(text: "Schedule"),
                        Tab(text: "Passenger"),
                        Tab(text: "End of journey"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  JourneyDetail(post: widget.post),
                  JourneySchedule(post: widget.post),
                  JourneyPassenger(postId: widget.post.id),
                  Container(

                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}