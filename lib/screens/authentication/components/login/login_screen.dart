import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/animated_container/move_and_fade_container.dart';
import 'package:joy_way/widgets/custom_text_field/custom_text_field.dart';

import '../../../../config/general_specifications.dart';
import '../../../../widgets/animated_container/animated_blur_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPressedLogin = true;
  static const double padding = 40.0;
  //
  bool _animationOrContinueWith1 = false;
  bool _animationOrContinueWith2 = false;

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: specs.screenHeight * 0.7,
      width: specs.screenWidth,
      padding: const EdgeInsets.symmetric(vertical: padding/2),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(27),
            topRight: Radius.circular(27),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: specs.screenWidth - padding,
            decoration: BoxDecoration(
                color: specs.pantoneShadow2,
                borderRadius: BorderRadius.circular(50)),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  left: isPressedLogin ? 4 : specs.screenWidth * 0.4 + 20,
                  top: 4,
                  child: Container(
                    height: 42,
                    width: specs.screenWidth * 0.42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              isPressedLogin = true;
                            });
                          },
                          child: SizedBox(
                            width: specs.screenWidth * 0.42,
                            child: Center(
                              child: Text(
                                'Login',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: isPressedLogin
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: isPressedLogin
                                      ? Colors.black
                                      : specs.black150,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              isPressedLogin = false;
                            });
                          },
                          child: SizedBox(
                            width: specs.screenWidth * 0.42,
                            child: Center(
                              child: Text(
                                'Register',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: isPressedLogin
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                  color: isPressedLogin
                                      ? specs.black150
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomTextField(
            title: 'Email address',
            iconAsset: "assets/icons/authentication/mail.png",
            isHidden: false,
          ),
          const SizedBox(
            height: 15,
          ),
          CustomTextField(
            title: 'Password',
            iconAsset: "assets/icons/authentication/password.png",
            isHidden: true,
          ),
          const SizedBox(
            height: 15,
          ),
          // Recovery button
          SizedBox(
            width: specs.screenWidth - padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Recovery Password",
                  style: GoogleFonts.outfit(
                      color: specs.pantoneColor3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Confirm button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _animationOrContinueWith1 = !_animationOrContinueWith1;
              });
            },
            child: Container(
              height: 50,
              width: specs.screenWidth - padding,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: specs.pantoneShadow2,
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 10),
                  ),
                ],
                color: specs.pantoneColor3,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  "Confirm",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: specs.screenWidth - padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: specs.screenWidth * 0.4,
                  child: Stack(
                    children: [
                      MoveAndFadeContainer(
                          type: 3,
                          fatherHeight: 30,
                          fatherWidth: specs.screenWidth * 0.4,
                          heightOfChild: 1.5,
                          widthOfChild: specs.screenWidth * 0.3,
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutExpo,
                          animation: _animationOrContinueWith1,
                          child: Container(
                            height: 1,
                            width: specs.screenWidth * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  specs.black200,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                AnimatedBlurOverlay(
                  width: 30,
                  height: 30,
                  blurOn: !_animationOrContinueWith1,
                  maxSigma: 20,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  borderRadius: BorderRadius.circular(20),
                  baseColor: Colors.white,
                  child:
                      Center(
                        child: Text("Or",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: specs.black150
                        ),),
                      ),
                ),
                SizedBox(
                  height: 30,
                  width: specs.screenWidth * 0.4,
                  child: Stack(
                    children: [
                      MoveAndFadeContainer(
                          type: 1,
                          fatherHeight: 30,
                          fatherWidth: specs.screenWidth * 0.4,
                          heightOfChild: 1.5,
                          widthOfChild: specs.screenWidth * 0.3,
                          animation: _animationOrContinueWith1,
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutExpo,
                          child: Container(
                            height: 1,
                            width: specs.screenWidth * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  specs.black200,
                                  Colors.white,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
