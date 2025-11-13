

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/data_processing/location_name_handling.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/post_services/post_firestore.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/animated_container/scale_container.dart';

import '../../../models/post/post.dart';
import '../../../widgets/notifications/show_notification.dart';
import '../journey_detail/components/journey_status_card.dart';
import '../journey_detail/view/owner_journey_view.dart';


class JourneyCard extends StatefulWidget {
  final Post post;

  const JourneyCard({super.key, required this.post});

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard> {

  String? _userName = "";

  @override
  void initState() {
    _loadUserName();
    super.initState();
  }


  Future<void> _loadUserName() async {
    try {
      final name = await ProfileFirestore()
          .getUserNameById(widget.post.ownerId, context); // trả String?
      if (!mounted) return;
      setState(() {
        _userName = name ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ShowNotification.showAnimatedSnackBar(
        context,
        'Error: ${e.toString()}',
        2,
        const Duration(milliseconds: 500),
      );
      setState(() {
        _userName = '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    final List<String> dep = LocationNameHandling.splitPlaceParts(widget.post.departureName);
    final List<String> arr = LocationNameHandling.splitPlaceParts(widget.post.arrivalName);

    final depProvince = dep.isNotEmpty ? dep.last : '';
    final arrProvince = arr.isNotEmpty ? arr.last : '';

    final depRest = dep.length > 1 ? dep.sublist(0, dep.length - 1).join(', ') : '';
    final arrRest = arr.length > 1 ? arr.sublist(0, arr.length - 1).join(', '): '';

    final depTime = TimeProcessing.formatDepartureTime2(widget.post.departureTime);

    final depHour = depTime['time'];
    final depDate = depTime['date'];

    final arrTime = TimeProcessing.formatDepartureTime2(widget.post.arrivalTime);

    final arrHour = arrTime['time'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: specs.screenWidth - 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: specs.black240,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleContainer(
                    animation: true,
                    fatherHeight: 40,
                    fatherWidth: 40,
                      maxS: 1.5,
                      child: Image.asset(
                        "assets/logos/logo.png",
                        fit: BoxFit.cover,
                      ),
                  ),
                  Text(
                    depDate ?? '',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (specs.screenWidth - 80) / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          depProvince,
                          style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        Text(
                          depRest,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            color: specs.black150
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: (specs.screenWidth - 80) / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrProvince,
                          style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        Text(
                          arrRest,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: specs.black150
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (specs.screenWidth - 80) / 2,
                    child: Text(
                      depHour ?? '',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (specs.screenWidth - 80) / 2,
                    child: Text(
                      arrHour ?? '',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: specs.black240,
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: specs.black240,
                      style: BorderStyle.solid
                    )
                  )
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Owner",
                          style: GoogleFonts.outfit(
                              color: specs.black150,
                              fontSize: 14,
                          )
                      ),
                      Text(
                          PostFirestore().isOwnPost(widget.post.ownerId) ? 'You' : '@${_userName ?? ''}',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              "Last update: ",
                              style: GoogleFonts.outfit(
                                color: specs.black150,
                                fontSize: 11,
                              )
                          ),
                          Text(
                              TimeProcessing.formatTimestamp(widget.post.updatedAt),
                              style: GoogleFonts.outfit(
                                color: specs.black150,
                                fontSize: 11,
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          "Status",
                          style: GoogleFonts.outfit(
                              color: specs.black150,
                              fontSize: 14,
                          )
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      JourneyStatusCard(postStatus: widget.post.status)
                    ],
                  )
                ],
              ),

              
              const SizedBox(
                height: 40,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAnimatedButton(
                    height: 40,
                    width: 100,
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "QR",
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            )
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const ImageIcon(
                          AssetImage(
                            "assets/icons/setting/qr.png"
                          ),
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  CustomAnimatedButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OwnerJourneyView(
                            post: widget.post,
                          ),
                        ),
                      );
                    },
                    height: 40,
                    width: specs.screenWidth - 180,
                    child: Text(
                      "Show detail",
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                          fontWeight: FontWeight.w500
                        )
                    )
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: specs.black240,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(100),
                    topLeft: Radius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );

  }
}
