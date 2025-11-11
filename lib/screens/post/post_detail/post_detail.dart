import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/post_display.dart';
import '../../../config/general_specifications.dart';
import '../../../widgets/animated_container/custom_animated_button.dart';
import 'components/companion_statistics.dart';
import 'components/journey_information.dart';
import 'components/owner_info.dart';
import 'components/request_join_button.dart';
import 'components/schedule.dart';



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
                          "Hello",
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
            Container(
                width: specs.screenWidth,
                height: specs.screenHeight - 97,
                child: Stack(
                  children: [
                    Container(
                      width: specs.screenWidth,
                      height: specs.screenHeight - 97,
                      child: ListView(),
                    ),
                    Container(
                        width: specs.screenWidth,
                        height: specs.screenHeight - 97,
                        child: ListView(
                          padding:
                          EdgeInsets.only(top: 100, left: 15, right: 15),
                          children: [
                            OwnerInfo(
                              ownerInfo: widget.postDisplay.userInfo,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CompanionStatistics(),
                            const SizedBox(
                              height: 15,
                            ),
                            JourneyInformation(
                              post: widget.postDisplay.post,
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            Schedule(
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
                        )),
                  ],
                ))
          ],
        ));
  }
}
