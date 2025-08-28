import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/animated_container/animated_blur_overlay.dart';
import 'package:joy_way/widgets/animated_icons/loading_rive_icon.dart';

import '../../../../config/general_specifications.dart';
import '../../../../widgets/animated_container/fade_container.dart';

class StatusAndMessage extends StatefulWidget {
  final bool scaleForLoading;
  final int status;
  final List<String> messages;
  final Function(bool) onScaleLoading;
  final Function(int) onStatus;
  final Function(bool) onFinishedAnimation;

  const StatusAndMessage({
    super.key,
    required this.status,
    required this.scaleForLoading,
    required this.messages,
    required this.onScaleLoading,
    required this.onStatus,
    required this.onFinishedAnimation,
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


  bool fadeInCircle = false;
  bool hideTwoCircle = false;
  bool scaleTheFirstCircle = false;

  bool showTitleLoadingText = false;
  bool showSubTitleLoadingText = false;
  bool hideTitleLoadingText = false;
  bool hideSubTitleLoadingText = false;

  bool showTitleMessage = false;
  bool showSubTitleMessage = false;


  /// Return button
  bool showReturnButton = false;
  bool _isTapDown = false;

  /// Icon loading
  bool showAnimatedIcon = false;
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
            showAnimatedIcon = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            showTitleLoadingText = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1200), () {
          setState(() {
            showSubTitleLoadingText = true;
          });
        });
      } else {
        setState(() {
          fadeInCircle = false;
          hideTwoCircle = false;
          scaleTheFirstCircle = false;
          showTitleLoadingText = false;
          showSubTitleLoadingText = false;
          hideTitleLoadingText = false;
          hideSubTitleLoadingText = false;
          showTitleMessage = false;
          showSubTitleMessage = false;
          showReturnButton = false;
          _isTapDown = false;
          showAnimatedIcon = false;
          activeLoading = false;
          activeSuccessful = false;
          activeFail = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            activeLoading = false;
            activeSuccessful = false;
            activeFail = false;
            showAnimatedIcon = false;
          });
        });
      }
    }
    if (oldWidget.status != widget.status ){
      if(widget.status == 0){
        /// Thất bại
        setState(() {
          hideTitleLoadingText = true;
          hideSubTitleLoadingText = true;
          showTitleLoadingText = false;
          showSubTitleLoadingText = false;
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
      } else if(widget.status == 1){
        /// Thành cong
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
            activeSuccessful = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 3000), () {
          setState(() {
            showAnimatedIcon = false;
          });
        });
        Future.delayed(const Duration(milliseconds: 3300), () {
          setState(() {
            scaleTheFirstCircle = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 4000), () {
          setState(() {
            widget.onFinishedAnimation(true);
          });
        });
      } else if(widget.status == 2){
        setState(() {
          hideTitleLoadingText = true;
          showTitleLoadingText = false;
          showTitleLoadingText = false;
          showSubTitleLoadingText = false;
          hideSubTitleLoadingText = true;
        });
        /// Gửi link lấy lại mật khẩu thành công

        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            showTitleMessage = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 700), () {
          setState(() {
            showSubTitleMessage = true;
            activeSuccessful = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            showReturnButton = true;
          });
        });
      }
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
                              AnimatedScale(
                                scale: showAnimatedIcon ? 1 : 0.8,
                                duration: Duration(milliseconds: 100),
                                child: AnimatedOpacity(
                                  opacity: showAnimatedIcon ? 1 : 0,
                                  duration: Duration(milliseconds: 300),
                                  child: Center(
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
                                    child: showAnimatedIcon
                                        ? Center(
                                            child: LoadingRiveIcon(
                                              fatherHeight: 50,
                                              fatherWidth: 50,
                                              activeLoading: activeLoading,
                                              activeSuccessful:
                                                  activeSuccessful,
                                              activeFail: activeFail,
                                            ),
                                          )
                                        : SizedBox(),
                                  )),
                                ),
                              )
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
              animation: !showAnimatedIcon,
              duration: Duration(milliseconds: 700),
              fadeIn: true,
              child: AnimatedBlurOverlay(
                fatherHeight: 100,
                fatherWidth: specs.screenWidth,
                animation: showTitleMessage,
                duration: Duration(milliseconds: 700),
                fadeIn: false,
                child: Container(
                  height: 100,
                  width: specs.screenWidth,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                          top: showTitleMessage ? 35 : 100,
                          left: 0,
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCirc,
                          child: Container(
                              height: 35,
                              width: specs.screenWidth,
                              child: Center(
                                child: Text(
                                  widget.messages[0],
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
          ),
          Positioned(
            top: (specs.screenHeight + 50) / 2 + 50,
            child: AnimatedBlurOverlay(
              animation: !showAnimatedIcon,
              fatherHeight: 200,
              fatherWidth: specs.screenWidth,
              duration: Duration(milliseconds: 700),
              fadeIn: true,
              child: AnimatedBlurOverlay(
                animation: showSubTitleMessage,
                fatherHeight: 200,
                fatherWidth: specs.screenWidth,
                duration: Duration(milliseconds: 700),
                fadeIn: false,
                child: Container(
                  height: 200,
                  width: specs.screenWidth,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                          top: showSubTitleMessage ? 35 : 65,
                          curve: Curves.easeOutCirc,
                          duration: const Duration(milliseconds: 1000),
                          child: Container(
                              width: specs.screenWidth,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  widget.messages[1],
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
                  setState(() {
                    _isTapDown = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 150));
                  setState(() {
                    _isTapDown = false;
                  });
                  await Future.delayed(const Duration(milliseconds: 150));
                  setState(() {
                    widget.onStatus(3);
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
