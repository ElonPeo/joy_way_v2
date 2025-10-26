import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/components/detail.dart';
import 'package:joy_way/models/post/components/end_infor.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/screens/post/edit_post/components/step_bar.dart';
import 'package:joy_way/screens/post/edit_post/pages/detail_information_screen.dart';
import 'package:joy_way/screens/post/edit_post/pages/end_information_screen.dart';
import 'package:joy_way/screens/post/edit_post/pages/start_information_screen.dart';

import '../../../widgets/animated_container/custom_animated_button.dart';
import 'components/bottom_edit_bar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  StartInfo? _startInfo;
  EndInfo? _endInfo;
  DetailInfo? _detailInfo;

  final List<String> _titles = [
    "Start",
    "End",
    "Detail",
    "Confirm",
  ];

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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Header
          Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(width: 1, color: specs.black240)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: specs.screenWidth,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 50,
                        child: CustomAnimatedButton(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(const Duration(milliseconds: 300));
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
                          child:                 Text(
                            _titles[_page],
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),),
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
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Page body + bottom bar
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    setState(() => _page = value);
                  },
                  children: [
                    StartInformationScreen(
                      startInfo: _startInfo,
                      onStartInfoChanged: (v) {
                        setState(() {
                          _startInfo = v;
                        });
                    },),
                    EndInformationScreen(
                      startInfo: _startInfo,
                      endInfo: _endInfo,
                      onEndInfoChanged: (v) {
                        setState(() {
                          _endInfo = v;
                        });
                      },
                    ),
                    DetailInformationScreen(
                        detailInfo:  _detailInfo,
                        onDetailInfoChanged: (v) {
                          setState(() {
                            _detailInfo = v;
                          });
                        },
                    ),
                    Container(
                      color: Colors.white,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomEditBar(
                    startInfo: _startInfo,
                    endInfo: _endInfo,
                    detailInfo: _detailInfo,
                    page: _page,
                    onPage: (value) => _goTo(value),
                    totalSteps: _titles.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
