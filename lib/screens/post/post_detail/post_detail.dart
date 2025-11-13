import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/post_display.dart';
import 'package:joy_way/screens/post/post_detail/components/passenger_statistic.dart';
import 'package:joy_way/screens/post/post_detail/components/request_statistic.dart';
import 'package:joy_way/screens/post/post_detail/components/schedule/post_schedule.dart';
import '../../../config/general_specifications.dart';
import '../../../widgets/animated_container/custom_animated_button.dart';
import 'components/owner_info.dart';
import 'components/post_information.dart';
import 'components/request_join_button.dart';



class PostDetail extends StatefulWidget {
  final PostDisplay postDisplay;

  const PostDetail({
    super.key,
    required this.postDisplay,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
        backgroundColor: specs.backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: specs.screenWidth,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                Border(bottom: BorderSide(width: 1, color: specs.black240)),
              ),
              child: SizedBox(
                height: 80,
                width: specs.screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    SizedBox(
                      height: 30,
                      width: specs.screenWidth - 140,
                      child: Center(
                        child: Text(
                          "Post Detail",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                EdgeInsets.only(top: 15, left: 15, right: 15),
                children: [
                  OwnerInfo(
                    ownerInfo: widget.postDisplay.userInfo,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PassengerStatistic(postId: widget.postDisplay.post.id, seat: widget.postDisplay.post.availableSeats),
                      RequestStatistic(postId: widget.postDisplay.post.id, maxRequest: 30),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  PostInformation(
                    post: widget.postDisplay.post,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
              
                  PostSchedule(
                    post: widget.postDisplay.post,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RequestJoinButton(
                    post: widget.postDisplay.post,
                  ),
              
                  SizedBox(
                    height: specs.screenHeight * 0.3,
                  ),
              
                ],
              ),
            )
          ],
        ));
  }
}
