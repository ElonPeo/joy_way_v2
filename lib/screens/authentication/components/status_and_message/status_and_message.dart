import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/animated_container/animated_blur_overlay.dart';
import 'package:joy_way/widgets/animated_container/move_and_fade_container.dart';
import 'package:joy_way/widgets/animated_icons/loading_rive_icon.dart';

import '../../../../config/general_specifications.dart';
import '../../../../widgets/animated_container/fade_container.dart';

class StatusAndMessage extends StatefulWidget {
  final bool scaleForLoading;
  final int type;
  final bool goToHomePage;
  final bool isUnsuccessful;
  final bool passwordRecoveryRequestsSuccessful;
  final String messages;
  final Function(bool) onPasswordRecoveryRequest;
  final Function(bool) onScaleLoading;
  final Function(bool) onUnsuccessful;
  final Function(String) onMessages;

  const StatusAndMessage({
    super.key,
    required this.type,
    required this.scaleForLoading,
    required this.goToHomePage,
    required this.messages,
    required this.isUnsuccessful,
    required this.passwordRecoveryRequestsSuccessful,
    required this.onPasswordRecoveryRequest,
    required this.onScaleLoading,
    required this.onUnsuccessful,
    required this.onMessages,
  });

  @override
  State<StatusAndMessage> createState() => _StatusAndMessageState();
}

class _StatusAndMessageState extends State<StatusAndMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim1;
  late Animation<double> _scaleAnim2;
  late Animation<double> _scaleAnim3;

  bool fadeInAnimation1 = false;
  bool fadeInAnimation2 = false;
  bool fadeInCircle = false;
  bool hideTwoCircle = false;
  bool scaleTheFirstCircle = false;

  bool showTitleLoadingText = false;
  bool showSubTitleLoadingText = false;
  bool hideTitleLoadingText = false;
  bool hideSubTitleLoadingText = false;

  bool fadeIn = false;
  bool showTitleMessage = false;
  bool showSubTitleMessage = false;
  bool hideTitleMessage = false;
  bool hideSubTitleMessage = false;

  bool showReturnButton = false;
  bool _isTapDown = false;
  /// Icon loading
  bool activeLoading = false;
  bool activeSuccessful = false;
  bool activeFail = false;

  @override
  void didUpdateWidget(covariant StatusAndMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scaleForLoading != oldWidget.scaleForLoading) {
      if (widget.scaleForLoading) {
        Future.delayed(const Duration(milliseconds: 400), () {
          setState(() {
            fadeInCircle = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            fadeInAnimation1 = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            fadeInAnimation2 = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1200), () {
          setState(() {
            showTitleLoadingText = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1300), () {
          setState(() {
            showSubTitleLoadingText = true;
          });
        });
      } else {
        setState(() {
          fadeInAnimation1 = false;
          fadeInAnimation2 = false;
          fadeInCircle = false;
          hideTwoCircle = false;
          scaleTheFirstCircle = false;
          showTitleLoadingText = false;
          showSubTitleLoadingText = false;
          hideTitleLoadingText = false;
          hideSubTitleLoadingText = false;
          fadeIn = false;
          showTitleMessage = false;
          showSubTitleMessage = false;
          hideTitleMessage = false;
          hideSubTitleMessage = false;
          showReturnButton = false;

          activeLoading = true;
          activeSuccessful = false;
          activeFail = false;
        });
      }
    }
    if (oldWidget.passwordRecoveryRequestsSuccessful !=
            widget.passwordRecoveryRequestsSuccessful ||
        oldWidget.goToHomePage != widget.goToHomePage ||
        oldWidget.isUnsuccessful != widget.isUnsuccessful) {
      if (widget.passwordRecoveryRequestsSuccessful ||
          widget.goToHomePage ||
          widget.isUnsuccessful) {
        setState(() {
          hideTitleLoadingText = true;
          showTitleLoadingText = false;
          showTitleLoadingText = false;
          showSubTitleLoadingText = false;
          hideSubTitleLoadingText = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            showTitleMessage = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 700), () {
          setState(() {
            showSubTitleMessage = true;
          });
        });
      }
    }
    if (oldWidget.passwordRecoveryRequestsSuccessful !=
        widget.passwordRecoveryRequestsSuccessful) {
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          activeSuccessful = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          showReturnButton = true;
        });
      });

    }
    if (oldWidget.isUnsuccessful != widget.isUnsuccessful) {
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          activeFail = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          showReturnButton = true;
        });
      });
    }
    if (oldWidget.goToHomePage != widget.goToHomePage) {
      activeSuccessful = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _scaleAnim1 = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnim2 = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    _scaleAnim3 = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);


    return Container(
      height: specs.screenHeight,
      width: specs.screenWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(253, 253, 253, 1),
            Color.fromRGBO(242, 246, 250, 1),
            Color.fromRGBO(248, 248, 252, 1),
            Color.fromRGBO(224, 218, 234, 1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [

          Positioned(
            top: (specs.screenHeight - 300) / 2 - 80,
            left: (specs.screenWidth - 300) / 2,
            child: Container(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      opacity: fadeInCircle ? 1 : 0,
                      child: AnimatedScale(
                        curve: Curves.easeInOutBack,
                        duration: const Duration(milliseconds: 1000),
                        scale: fadeInCircle ? 1 : 1.6,
                        child: Container(
                          height: 230,
                          width: 230,
                          child: Stack(
                            children: [
                              Center(
                                child: FadeContainer(
                                  fatherHeight: 200,
                                  fatherWidth: 200,
                                  animation: !hideTwoCircle,
                                  duration: const Duration(milliseconds: 300),
                                  child: AnimatedBuilder(
                                    animation: _scaleAnim1,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnim1.value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      height: 220,
                                      width: 220,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(176, 221, 202, 0.2),
                                            Color.fromRGBO(255, 255, 255, 0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: FadeContainer(
                                  fatherHeight: 160,
                                  fatherWidth: 160,
                                  animation: !hideTwoCircle,
                                  duration: const Duration(milliseconds: 300),
                                  child: AnimatedBuilder(
                                    animation: _scaleAnim2,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnim2.value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      height: 170,
                                      width: 170,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(85, 216, 157, 0.1),
                                            Color.fromRGBO(255, 255, 255, 0.2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: AnimatedScale(
                                  scale: scaleTheFirstCircle ? 10 : 1,
                                  curve: Curves.easeOutCirc,
                                  duration: const Duration(milliseconds: 1500),
                                  child: AnimatedBuilder(
                                    animation: _scaleAnim3,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnim3.value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(183, 231, 253, 1),
                                            Color.fromRGBO(247, 252, 255, 1),
                                            Color.fromRGBO(206, 190, 232, 1),
                                          ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),

                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  height: 200,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(240, 240, 240, 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Center(
                                    child: LoadingRiveIcon(
                                      fatherHeight: 50,
                                      fatherWidth: 50,
                                      activeLoading : activeLoading,
                                      activeSuccessful: activeSuccessful,
                                      activeFail: activeFail,
                                    ),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Positioned(
            top: (specs.screenHeight + 50) / 2,
            child: AnimatedOpacity(
              opacity: showTitleLoadingText ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: Container(
                height: 100,
                width: specs.screenWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                        top: hideTitleLoadingText
                            ? 0
                            : showTitleLoadingText
                                ? 35
                                : 70,
                        left: (specs.screenWidth - 100) / 2,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCirc,
                        child: Container(
                            height: 35,
                            width: 100,
                            child: Center(
                              child: Text(
                                'Loading',
                                style: GoogleFonts.outfit(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: (specs.screenHeight + 50) / 2 + 50,
            child: AnimatedOpacity(
              opacity: showSubTitleLoadingText ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                height: 200,
                width: specs.screenWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                        top: hideSubTitleLoadingText
                            ? 0
                            : showSubTitleLoadingText
                                ? 30
                                : 65,
                        curve: Curves.easeOutCirc,
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                            width: specs.screenWidth,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                'We are processing your request.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: specs.black150),
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: (specs.screenHeight + 50) / 2,
            child: AnimatedBlurOverlay(
              fatherHeight: 100,
              fatherWidth: specs.screenWidth,
              animation: showTitleMessage,
              duration: Duration(milliseconds: 700),
              fadeIn: fadeIn,
              child: Container(
                height: 100,
                width: specs.screenWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                        top: hideTitleMessage
                            ? 0
                            : showTitleMessage
                                ? 35
                                : 100,
                        left: 0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCirc,
                        child: Container(
                            height: 35,
                            width: specs.screenWidth,
                            child: Center(
                              child: Text(
                                widget.isUnsuccessful ? 'Warning!' : "Successful",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: (specs.screenHeight + 50) / 2 + 50,
            child: AnimatedBlurOverlay(
              animation: showSubTitleMessage,
              fatherHeight: 200,
              fatherWidth: specs.screenWidth,
              duration: Duration(milliseconds: 700),
              fadeIn: fadeIn,
              child: Container(
                height: 200,
                width: specs.screenWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                        top: hideTitleMessage
                            ? 0
                            : showTitleMessage
                                ? 35
                                : 65,
                        curve: Curves.easeOutCirc,
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                            width: specs.screenWidth,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                "198273649182763498172362893476",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: specs.black150),
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            bottom: showReturnButton ? 20 : -100,
            left: 20,
            child: AnimatedScale(
              scale: _isTapDown ? 0.9 : 1,
              duration: Duration(milliseconds: 150),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) async {
                  setState(() {_isTapDown = true;});
                  await Future.delayed(const Duration(milliseconds: 150));
                  setState(() {_isTapDown = false;});
                  await Future.delayed(const Duration(milliseconds: 150));
                  setState(() {
                    activeLoading = false;
                    activeSuccessful = false;
                    activeFail = false;
                  });
                  setState(() {
                    widget.onScaleLoading(false);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 55,
                  width: specs.screenWidth - 40,
                  decoration: BoxDecoration(
                    color: specs.pantoneColor3,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: specs.pantoneShadow2,
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: _isTapDown
                            ? const Offset(0, 0)
                            : const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Return",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
