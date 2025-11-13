import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

import 'package:joy_way/screens/post/edit_post/components/step_bar.dart';
import 'package:joy_way/screens/setting/verify/components/bottom_verify_bar.dart';
import 'package:joy_way/screens/setting/verify/pages/confirm_verify_screen.dart';
import 'package:joy_way/screens/setting/verify/pages/facial_screen.dart';
import 'package:joy_way/screens/setting/verify/pages/identity_screen.dart';

import '../../../widgets/animated_container/custom_animated_button.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});
  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final PageController _pageController = PageController();
  int _page = 0;

  // 🔹 3 ảnh lưu ở đây
  File? _frontIdImage;
  File? _backIdImage;
  File? _faceImage;

  final List<String> _titles = [
    "Identity card",
    "Facial verification",
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
      backgroundColor: specs.backgroundColor,
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
                  child: Row(
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
                    // 🔹 Step 1: truyền file + callback lên Verify
                    IdentityScreen(
                      frontImage: _frontIdImage,
                      backImage: _backIdImage,
                      onFrontChanged: (file) {
                        setState(() => _frontIdImage = file);
                      },
                      onBackChanged: (file) {
                        setState(() => _backIdImage = file);
                      },
                    ),

                    // 🔹 Step 2: truyền file + callback
                    FacialScreen(
                      faceImage: _faceImage,
                      onFaceChanged: (file) {
                        setState(() => _faceImage = file);
                      },
                    ),

                    // 🔹 Step 3: confirm – nhận đủ 3 ảnh
                    ConfirmVerifyScreen(
                      frontIdImage: _frontIdImage,
                      backIdImage: _backIdImage,
                      faceImage: _faceImage,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomVerifyBar(
                    frontIdImage: _frontIdImage,
                    backIdImage: _backIdImage,
                    faceImage: _faceImage,
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
