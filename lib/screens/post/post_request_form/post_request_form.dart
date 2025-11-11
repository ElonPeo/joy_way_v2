
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/screens/post/post_request_form/components/bottom_request_bar.dart';
import 'package:joy_way/screens/post/post_request_form/pages/end_request_page.dart';
import 'package:joy_way/screens/post/post_request_form/pages/start_request_page.dart';
import '../../../models/post/post.dart';
import '../../../models/request/request_journey/components/end_request_info.dart';
import '../../../models/request/request_journey/components/start_request_info.dart';
import '../../../widgets/animated_container/custom_animated_button.dart';
import '../edit_post/components/step_bar.dart';

class PostRequestForm extends StatefulWidget {
  final Post post;
  const PostRequestForm({super.key, required this.post});
  @override
  State<PostRequestForm> createState() => _PostRequestFormState();
}

class _PostRequestFormState extends State<PostRequestForm> {
  int _page = 0;
  final PageController _pageController = PageController();
  final List<String> _titles = [
    "Start",
    "End",
    "Confirm",
  ];

  StartRequestInfo? _startRequestInfo;
  EndRequestInfo? _endRequestInfo;

  void _goTo(int target) {
    if (target == _page) return;
    if ((target - _page).abs() > 1) {
      setState(() => _page = target);
      _pageController.jumpToPage(target);
    } else {
      setState(() => _page = target);
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(width: 1, color: specs.black240)),
            ),
            child: Column(
              children: [
                SizedBox(
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
                            _titles[_page],
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
                const SizedBox(height: 5),
                Text(
                  "Step ${_page + 1} of ${_titles.length}",
                  style: GoogleFonts.roboto(
                    color: specs.black100,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                StepBar(
                  page: _page,
                  totalSteps: 3,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) {
                setState(() => _page = value);
              },
              children: [
                StartRequestPage(
                  startRequestInfo: _startRequestInfo,
                  onStartRequestInfoChanged: (v) {
                    setState(() {
                      _startRequestInfo = v;
                    });
                  },
                ),
                EndRequestPage(
                  endRequestInfo: _endRequestInfo,
                  onEndRequestInfoChanged: (v) {
                    setState(() {
                      _endRequestInfo = v;
                    });
                  },
                ),
                ListView(
                  children: [

                  ],
                )
              ],
            ),
          ),
          BottomRequestBar(
              page: _page,
              onPage: (value) => _goTo(value),
              post: widget.post,
              startRequestInfo: _startRequestInfo,
              endRequestInfo: _endRequestInfo,
          )
        ],
      ),
    );
  }
}
