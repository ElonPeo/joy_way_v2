import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/general_specifications.dart';
import '../../../../../models/passenger/passengers.dart';
import '../../../../../models/request/request_journey/request_join_journey/request_join_journey.dart';
import '../../../../../services/data_processing/location_name_handling.dart';
import '../../../../../services/data_processing/time_processing.dart';
import '../../../../../services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';

class DropOffSchedule extends StatefulWidget {
  final Passenger passenger;
  final int index;
  const DropOffSchedule({super.key, required this.passenger, required this.index});

  @override
  State<DropOffSchedule> createState() => _DropOffScheduleState();
}

class _DropOffScheduleState extends State<DropOffSchedule> {
  RequestJoinJourney? _req;
  String? _userName;
  bool _loading = true;
  String? _error;

  static const _colors = [
    Color.fromRGBO(140, 228, 255, 1),
    Color.fromRGBO(255, 253, 143, 1),
    Color.fromRGBO(193, 120, 90, 1),
  ];

  @override
  void initState() {
    super.initState();
    _loadOnce();
  }

  Future<void> _loadOnce() async {
    try {
      final reqDoc = await FirebaseFirestore.instance
          .collection('request_join_journey')
          .doc(widget.passenger.requestId)
          .get();

      RequestJoinJourney? req;
      if (reqDoc.exists) {
        req = RequestJoinJourney.fromMap(reqDoc.data()!, id: reqDoc.id);
      }

      final userName =
      await ProfileFirestore().getUserNameById(widget.passenger.userId, context);

      if (!mounted) return;
      setState(() {
        _req = req;
        _userName = userName;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: LoadingContainer(height: 100, width: specs.screenWidth ),
      );
    }
    if (_error != null) {
      return const SizedBox.shrink();
    }
    if (_req == null) {
      return const SizedBox.shrink();
    }

    final arrParts = LocationNameHandling.splitPlaceParts(_req!.dropOffName ?? '');
    final arrFull = arrParts.join(', ');

    final timeStr = TimeProcessing.formatHourMinute(_req!.desiredDropOffTime) ?? '';
    final displayName = (_userName ?? '').trim().isEmpty
        ? widget.passenger.userId
        : _userName!.trim();
    return IntrinsicHeight(
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
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _colors[widget.index % _colors.length],
                    ),
                    child:  Center(
                      child: ImageIcon(
                        const AssetImage("assets/icons/post/drop-off.png"),
                        size: 18,
                        color: specs.black100,
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
                  Text(timeStr, style: GoogleFonts.outfit(fontSize: 12, color: specs.black100)),
                  const SizedBox(height: 10),
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
                          "Drop off @$displayName",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: specs.screenWidth - 130,
                          child: Text(
                            "$arrFull",
                            strutStyle: const StrutStyle(height: 1.25, forceStrutHeight: true),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: specs.black100,
                              fontWeight: FontWeight.w400,
                            ),
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
    );
  }
}
