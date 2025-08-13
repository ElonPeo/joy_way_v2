import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../config/general_specifications.dart';
import '../../widgets/animated_container/fade_container.dart';
import '../../widgets/animated_container/right_to_left_container.dart';
import 'package:google_fonts/google_fonts.dart';



class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool animate = false;
  VideoPlayerController? _controller;
  List<String> texts = ["Hello ", "Bonjour ", "こんに", "你 ", "Xin ", "Hola "];
  List<String> texts2 = ["There!", "toi!", "ちは!", "好!", "chào!", "amigo!"];
  AnimationController? _text_controller;
  Animation<double>? _animation;
  Timer? _timer;
  int textIndex = 0;
  int textIndex2 = 0;
  bool showIntroText = false;
  bool showStartButton = false;
  bool showLogin = false;
  bool scaleScreen = false;
  bool move = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 6000), () {
      setState(() {
        showIntroText = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 6000), () {
      setState(() {
        showStartButton = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {
        animate = true;
      });
    });

    _controller =
    VideoPlayerController.asset("assets/videos/logo.mp4///////////")
      ..initialize().then((_) {
        if (mounted) setState(() {});
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _controller?.play();
          }
        });
      });

    _text_controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _text_controller!,
      curve: Curves.linear,
    );
    _text_controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          _text_controller!.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          textIndex = (textIndex + 1) % texts.length;
          textIndex2 = (textIndex2 + 1) % texts2.length;
        });
        _text_controller!.forward();
      }
    });
    _text_controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _text_controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: specs.screenHeight,
        width: specs.screenWidth,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: move ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: scaleScreen ? 0.8 : 1.05,
                child: Container(
                  height: specs.screenHeight,
                  width: specs.screenWidth,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(233, 233, 233, 1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color.fromRGBO(153, 172, 156, 1.0),
                      width: 3.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: specs.screenWidth,
                        height: specs.screenHeight,
                        alignment: Alignment.center,
                        child: _controller != null && _controller!.value.isInitialized
                            ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                            : const CircularProgressIndicator(),
                      ),
                      SizedBox(
                        width: specs.screenWidth,
                        height: specs.screenHeight,
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              left: animate ? 0 : (specs.screenWidth - 290) / 2,
                              top: animate
                                  ? specs.screenHeight * 0.15
                                  : (specs.screenHeight - 100) / 2,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: animate ? 0.8 : 1.0,
                                curve: Curves.easeInOut,
                                child: SizedBox(
                                  height: 150,
                                  width: 315,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          FadeTransition(
                                            opacity: _animation!,
                                            child: Text(
                                              texts[textIndex],
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 50,
                                              ),
                                            ),
                                          ),
                                          FadeTransition(
                                            opacity: _animation!,
                                            child: Text(
                                              texts2[textIndex2],
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 50,
                                                color: specs.pantoneColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: specs.screenHeight,
                        width: specs.screenWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: specs.screenHeight * 0.47,
                              width: specs.screenWidth,
                              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FadeContainer(
                                        duration: const Duration(milliseconds: 1000),
                                        fatherWidth: specs.screenWidth * 0.8,
                                        fatherHeight: 130,
                                        animation: showIntroText,
                                        child: Text(
                                          "Start your adventure with JoyWay and share your route in real time, "
                                              "a friend can join you and enjoy the journey together.",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: specs.black80,
                                          ),
                                        ),
                                      ),
                                      RightToLeftContainer(
                                        animation: showStartButton,
                                        fatherHeight: 40,
                                        fatherWidth: specs.screenWidth,
                                        duration: const Duration(milliseconds: 1000),
                                        distance_traveled: 50,
                                        child: GestureDetector(
                                          child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              height: 40,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                color: specs.pantoneColor,
                                                borderRadius: BorderRadius.circular(35),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Start Now",
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )),
                                          onTap: () {
                                            setState(() {
                                              scaleScreen = true;
                                            });

                                            Future.delayed(const Duration(milliseconds: 200), () {
                                              setState(() {
                                                move = true;
                                              });
                                            });

                                            Future.delayed(const Duration(milliseconds: 400), () {
                                              setState(() {
                                                showLogin = true;
                                              });
                                            });
                                            Future.delayed(const Duration(milliseconds: 1000), () {
                                              Navigator.pushNamed(context, '/login');
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
