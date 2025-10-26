import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/widgets/map/view/photo_map_url_view.dart';

import '../../../../config/general_specifications.dart';
import '../../../../services/mapbox_services/mapbox_config.dart';



class AboutScreen extends StatefulWidget {
  final String? name;
  final String? userName;
  final String? phoneNumber;
  final String? sex;
  final String? email;
  final DateTime? dateOfBirth;
  final GeoPoint? livingCoordinate;
  final List<String>? socialLinks;
  final String? livingPlace;

  const AboutScreen({
    super.key,
    required this.name,
    required this.userName,
    required this.phoneNumber,
    required this.sex,
    required this.email,
    required this.dateOfBirth,
    required this.livingCoordinate,
    required this.socialLinks,
    required this.livingPlace,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: specs.screenWidth - 20,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User infor",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              const AssetImage(
                                  "assets/icons/user_infor/envelope.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: specs.screenWidth - 220,
                              child: Text(
                                widget.email ?? '',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              const AssetImage(
                                  "assets/icons/user_infor/circle-phone-flip.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.phoneNumber ?? '',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ImageIcon(
                              const AssetImage("assets/icons/user_infor/dob.png"),
                              size: 16,
                              color: specs.black100,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              TimeProcessing.dateToString(widget.dateOfBirth) ??
                                  '',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    child: Center(
                      child: PhotoMapUrlView(
                          geoPoint: widget.livingCoordinate,
                          height: 140,
                          width: 140,
                          mapboxToken: MapboxConfig.accessToken,
                          address: widget.livingPlace,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          width: specs.screenWidth - 20,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Social links",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: List.generate(
                  widget.socialLinks?.length ?? 0,
                      (index) => Row(
                    children: [
                      const ImageIcon(
                        AssetImage("assets/icons/user_infor/link-alt.png"),
                        size: 16,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: specs.screenWidth - 100,
                        child: Text(
                          widget.socialLinks![index],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        SizedBox(
          height: specs.screenHeight * 0.3,
        ),
      ],
    );
  }
}

