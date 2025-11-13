import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/post/post_detail/components/schedule/pick_up_schedule.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';

import '../../../../../config/general_specifications.dart';
import '../../../../../models/post/post.dart';
import '../../../../../models/request/request_journey/request_join_journey/request_join_journey.dart';

import 'package:joy_way/models/passenger/passengers.dart';
import 'package:joy_way/services/firebase_services/passenger_services/passenger_firestore.dart';
import 'drop_off_schedule.dart';

class PostSchedule extends StatefulWidget {
  final Post post;
  const PostSchedule({super.key, required this.post});

  @override
  State<PostSchedule> createState() => _PostScheduleState();
}

class _PostScheduleState extends State<PostSchedule> {
  final _pf = PassengerFirestore();

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final depTime = TimeProcessing.formatDepartureTime2(widget.post.departureTime);
    final depDate = depTime['date'];
    return Container(
        width: specs.screenWidth - 30,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
            border: Border.all(
                width: 0.8,
                color: specs.black240
            )
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // ======== START ========
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 45,
                        child: Column(
                          children: [
                            Container(
                              height: 45, width: 45,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(192, 253, 203, 1),
                              ),
                              child: Center(
                                child: ImageIcon(
                                  const AssetImage("assets/icons/post/start-location.png"),
                                  size: 18, color: specs.black100,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: Container(width: 1, color: specs.black200)),
                          ],
                        ),
                      ),
                      Container(
                        width: specs.screenWidth - 115,
                        padding: const EdgeInsets.only(top: 12.9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TimeProcessing.formatHourMinute(widget.post.departureTime),
                                  style: GoogleFonts.outfit(fontSize: 12, color: specs.black100),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      depDate ?? '',
                                      style: GoogleFonts.outfit(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: specs.screenWidth - 115,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: specs.black245, borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Start", style: GoogleFonts.outfit(
                                      fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: specs.screenWidth - 130,
                                    child: Text(
                                      "Start in ${widget.post.departureName}",
                                      strutStyle: const StrutStyle(height: 1.25, forceStrutHeight: true),
                                      style: GoogleFonts.outfit(
                                          fontSize: 12, color: specs.black100, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              StreamBuilder<List<Passenger>>(
                stream: _pf.streamPassengersByPostId(postId: widget.post.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Error: ${snap.error}',
                          style: GoogleFonts.outfit(color: Colors.red)),
                    );
                  }

                  final passengers = snap.data ?? const <Passenger>[];
                  if (passengers.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: passengers.asMap().entries.map((e) {
                      final i = e.key;
                      final p = e.value;
                      return Column(
                        children: [
                          PickupSchedule(passenger: p, index: i),
                          DropOffSchedule(passenger: p, index: i),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),

              // ======== END ========
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 45,
                        child: Column(
                          children: [
                            Container(
                              height: 45, width: 45,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(248, 217, 236, 1),
                              ),
                              child: Center(
                                child: ImageIcon(
                                  const AssetImage("assets/icons/post/end-location.png"),
                                  size: 18, color: specs.black100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: specs.screenWidth - 115,
                        padding: const EdgeInsets.only(top: 12.9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.post.arrivalTime != null) ...[
                              Text(
                                TimeProcessing.formatHourMinute(widget.post.arrivalTime),
                                style: GoogleFonts.outfit(fontSize: 12, color: specs.black100),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Container(
                              width: specs.screenWidth - 115,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: specs.black245, borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("End", style: GoogleFonts.outfit(
                                      fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: specs.screenWidth - 130,
                                    child: Text(
                                      "End in ${widget.post.arrivalName}",
                                      strutStyle: const StrutStyle(height: 1.25, forceStrutHeight: true),
                                      style: GoogleFonts.outfit(
                                          fontSize: 12, color: specs.black100, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        )
    );
  }
}



