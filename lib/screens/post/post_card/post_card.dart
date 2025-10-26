import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/post_display.dart';
import 'package:joy_way/services/data_processing/location_name_handling.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/mapbox_services/mapbox_config.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

import '../../../models/post/post.dart';
import '../../../widgets/map/view/route_view.dart';
import '../post_detail/post_detail.dart';

class PostCard extends StatefulWidget {
  final PostDisplay postDisplay;

  const PostCard({
    super.key,
    required this.postDisplay,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final post = widget.postDisplay.post;
    final user = widget.postDisplay.userInfo;
    final timeText = TimeProcessing.formatTimestamp(post.departureTime);
    final placeName = LocationNameHandling.comparePlaces(
        post.departureName, post.arrivalName);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => PostDetail(postDisplay: widget.postDisplay)),
        );
      },
      child: Container(
        width: specs.screenWidth,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 0.5,
          color: specs.black240,
        ))),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 65,
                      ),
                      SizedBox(
                        width: specs.screenWidth - 95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.userName,
                                  style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  TimeProcessing.formatTimestamp(
                                      widget.postDisplay.timeAgo),
                                  style: TextStyle(
                                      color: specs.black150, fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: Image.asset(
                                            'assets/icons/post/heart.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '123',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: Image.asset(
                                            'assets/icons/post/bookmark.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                RoutePreviewBox(
                  height: 200,
                  width: specs.screenWidth,
                  start: post.departureCoordinate,
                  end: post.arrivalCoordinate,
                  accessToken: MapboxConfig.accessToken,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: specs.screenWidth,
                  padding: EdgeInsets.only(top: 10,bottom: 5,left: 20,right: 20),
                  child: Text(
                    "Hello, I'm looking for someone to go with."
                  )
                ),
                SizedBox(
                  width: specs.screenWidth - 40,
                  child: Wrap(
                    spacing: 8, // khoảng cách giữa các phần tử ngang
                    runSpacing: 4, // khoảng cách giữa các dòng
                    children: [
                      Text(
                        '#${placeName['dep'] ?? ''}, ${placeName['arr'] ?? ''}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        post.type == ExpenseType.share ? '#share' : '#free',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '#${post.vehicleType.name}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            Positioned(
              left: 20,
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.white)),
                  child: AvatarView(
                    imageId: user.avatarImageId,
                    nameUser: user.userName,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
