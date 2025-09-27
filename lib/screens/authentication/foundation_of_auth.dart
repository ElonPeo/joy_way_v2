import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/general_specifications.dart';
import 'auth_title.dart';
import 'components/login_screen.dart';
import 'components/recovery_screen.dart';
import 'components/register_screen.dart';
import 'components/status_and_message.dart';



class FoundationOfAuth extends StatefulWidget {

  const FoundationOfAuth({
    super.key,

  });

  @override
  State<FoundationOfAuth> createState() => _FoundationOfAuthState();
}

class _FoundationOfAuthState extends State<FoundationOfAuth> {
  int type = 0;
  int status = 3;
  bool scaleForLoading = false;
  List<String> messages = ['', ''];
  bool hideRecoveryPassword = false;
  static const double padding = 40.0;


  Widget _buildChild(GeneralSpecifications specs) {
    switch (type) {
      case 0:
        return LoginScreen(
          type: type,
          onChanged: (value) => setState(() => type = value),
          onScaleForLoading: (value) => setState(() => scaleForLoading = value),
          onMessage: (value) => setState(() => messages = value),
          onStatus: (value) => setState(() => status = value),
        );
      case 1:
        return RegisterScreen(
          onScaleForLoading: (value) => setState(() => scaleForLoading = value),
          onMessage: (value) => setState(() => messages = value),
          onStatus: (value) => setState(() => status = value),
        );
      case 2:
        return RecoveryScreen(
          hideRecoveryPassword: hideRecoveryPassword,
          onChanged: (value) => setState(() => type = value),
          onScaleForLoading: (value) => setState(() => scaleForLoading = value),
          onMessage: (value) => setState(() => messages = value),
          onStatus: (value) => setState(() => status = value),
        );
      default:
        return LoginScreen(
          type: type,
          onChanged: (value) => setState(() => type = value),
          onScaleForLoading: (value) => setState(() => scaleForLoading = value),
          onMessage: (value) => setState(() => messages = value),
          onStatus: (value) => setState(() => status = value),
        );
    }
  }

  Duration customAnimDuration(int type) {
    if (scaleForLoading) {
      return const Duration(milliseconds: 400);
    } else {
      return const Duration(milliseconds: 800);
    }
  }



  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final child = _buildChild(specs);
    double targetTop;
    if (type == 2) {
      targetTop = specs.screenHeight * 0.3;
      if (scaleForLoading) {
        targetTop = specs.screenHeight * 0.3 - 50;
      }
    } else {
      targetTop = 40;
      if (scaleForLoading) {
        targetTop = 0;
      }
    }

    double targetBottom;
    if (type == 2) {
      targetBottom = specs.screenHeight * 0.55;
      if (scaleForLoading) {
        targetBottom = specs.screenHeight;
      }
    } else {
      targetBottom = specs.screenHeight * 0.3;
      if (scaleForLoading) {
        targetBottom = specs.screenHeight;
      }
    }

    final Duration animDuration = customAnimDuration(type);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: specs.screenHeight,
        width: specs.screenWidth,
        child: Stack(
          children: [
            StatusAndMessage(
              scaleForLoading: scaleForLoading,
              messages: messages,
              status: status,
              onScaleLoading: (value) {
                setState(() => scaleForLoading = value);
              },
              onStatus: (value) => setState(() => status = value),
            ),
            // Title
            AnimatedPositioned(
              top: targetTop,
              duration: animDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: scaleForLoading ? 0 : 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInCubic,
                child: AuthTitle(
                  type: type,
                  onHideRecoveryPassword: (value) =>
                      setState(() => hideRecoveryPassword = value),
                  onChanged: (value) => setState(() => type = value),
                ),
              ),
            ),
            // Main content
            AnimatedPositioned(
              top: targetBottom,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: scaleForLoading ? 0 : 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInCubic,
                child: Container(
                  height: specs.screenHeight * 0.7,
                  width: specs.screenWidth,
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(27),
                      topRight: Radius.circular(27),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Nút đổi trang
                      Positioned(
                        top: 0,
                        left: 20,
                        child: AnimatedOpacity(
                          opacity: type == 2 ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 50,
                            width: specs.screenWidth - padding,
                            decoration: BoxDecoration(
                              color: specs.pantoneShadow2,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.fastOutSlowIn,
                                  left: type == 1
                                      ? specs.screenWidth * 0.4 + 20
                                      : 4,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => setState(() => type = 0),
                                          child: SizedBox(
                                            width: specs.screenWidth * 0.42,
                                            child: Center(
                                              child: Text(
                                                'Login',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: type == 0
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: type == 0
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
                                      children: [
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => setState(() => type = 1),
                                          child: SizedBox(
                                            width: specs.screenWidth * 0.42,
                                            child: Center(
                                              child: Text(
                                                'Register',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: type == 1
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: type == 1
                                                      ? Colors.black
                                                      : specs.black150,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        top: type == 2 ? 0 : 50,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: KeyedSubtree(
                            key: ValueKey<int>(type),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
