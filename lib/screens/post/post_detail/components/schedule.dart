import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';

import '../../../../config/general_specifications.dart';
import '../../../../models/post/post.dart';


class Schedule extends StatefulWidget {
  final Post post;
  const Schedule({super.key,
  required this.post,
  });
  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {

  @override
  Widget build(BuildContext context) {

    final specs = GeneralSpecifications(context);
    return Container(
      width: specs.screenWidth - 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(192, 253, 203, 1),
                          ),
                          child: Center(
                            child: ImageIcon(
                              const AssetImage("assets/icons/post/start-location.png"),
                              size: 18,
                              color: specs.black100,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            width: 1,
                            color: specs.black200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: specs.screenWidth - 105,
                    padding: const EdgeInsets.only(top: 12.9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TimeProcessing.formatHourMinute(widget.post.departureTime),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: specs.black100
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: specs.screenWidth - 115,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: specs.black245,
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Start",
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: specs.screenWidth - 130,
                                child: Text(
                                  "Start in ${widget.post.departureName}",
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: specs.black100,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(248, 217, 236, 1),
                          ),
                          child: Center(
                            child: ImageIcon(
                              const AssetImage("assets/icons/post/end-location.png"),
                              size: 18,
                              color: specs.black100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: specs.screenWidth - 105,
                    padding: const EdgeInsets.only(top: 12.9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(widget.post.arrivalTime != null)
                          Column(
                            children: [
                              Text(
                                TimeProcessing.formatHourMinute(widget.post.arrivalTime),
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: specs.black100
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        Container(
                          width: specs.screenWidth - 115,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: specs.black245,
                              borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "End",
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: specs.screenWidth - 130,
                                child: Text(
                                  "The journey end in ${widget.post.arrivalName}",
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: specs.black100,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}