import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/authentication/components/recovery/recovery_screen.dart';
import 'package:joy_way/widgets/animated_container/animated_blur_overlay.dart';
import 'package:joy_way/widgets/animated_container/move_and_fade_container.dart';

import '../../../config/general_specifications.dart';

class AuthTitle extends StatefulWidget {
  final int type;
  final Function(int) onChanged;
  final Function(bool) onHideRecoveryPassword;
  const AuthTitle({
    super.key,
    required this.type,
    required this.onChanged,
    required this.onHideRecoveryPassword,
  });

  @override
  State<AuthTitle> createState() => _AuthTitleState();
}

class _AuthTitleState extends State<AuthTitle> {
  int flag = 0;

  bool _animationBlur1 = false;
  bool _fadeIn1 = false;

  bool _animationBlur2 = false;
  bool _fadeIn2 = true;

  bool _animationBack = false;

  final String _loginTitle = "Welcome back!";
  final String _loginSubTitle = "Get started now to choose your ideal trip and connect with interesting fellow travelers.";
  final String _registerTitle = "Hello there!";
  final String _registerSubTitle = "Create a new account and be part of a growing community of journey sharers.";
  final String _recoveryTitle = "Forgot password?";
  final String _recoverySubTitle = "Recover your password in just a few basic steps.";

  String title1 = '';
  String subTitle1 = '';

  String title2 = '';
  String subTitle2 = '';

  @override
  void didUpdateWidget(covariant AuthTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      setState(() {
        _fadeIn1 = !_fadeIn1;
        _fadeIn2 = !_fadeIn2;
        _animationBlur1 = !_animationBlur1;
        _animationBlur2 = !_animationBlur2;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          _animationBlur1 = !_animationBlur1;
          _animationBlur2 = !_animationBlur2;
        });
      });

      if (widget.type == 0) {
        setState(() {
          _animationBack = false;
          if (oldWidget.type == 1) {
            title1 = _loginTitle;
            subTitle1 = _loginSubTitle;
            title2 = _registerTitle;
            subTitle2 = _registerSubTitle;
          }
        });
      }
      if (widget.type == 1) {
        setState(() {
          _animationBack = false;
          title1 = _loginTitle;
          subTitle1 = _loginSubTitle;
          title2 = _registerTitle;
          subTitle2 = _registerSubTitle;
        });
      }
      if (widget.type == 2) {
        setState(() {
          _animationBack = true;
          title2 = _recoveryTitle;
          subTitle2 = _recoverySubTitle;
        });
      }
    }
  }

  @override
  void initState() {
    title1 = 'Welcome back!';
    subTitle1 =
        'Get started now to choose your ideal trip and connect with interesting fellow travelers.';
    _animationBlur1 = true;
    _animationBlur2 = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      width: specs.screenWidth,
      height: specs.screenHeight * 0.25,
      padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
      child: Stack(
        children: [
          AnimatedBlurOverlay(
            fatherHeight: specs.screenHeight * 0.25,
            fatherWidth: specs.screenWidth,
            animation: _animationBlur1,
            fadeIn: _fadeIn1,
            duration: const Duration(milliseconds: 2000),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title1,
                  style: GoogleFonts.outfit(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  subTitle1,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: specs.black150,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          AnimatedBlurOverlay(
            fatherHeight: specs.screenHeight * 0.25,
            fatherWidth: specs.screenWidth,
            animation: _animationBlur2,
            fadeIn: _fadeIn2,
            duration: const Duration(milliseconds: 2000),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoveAndFadeContainer(
                  type: 1,
                  fatherHeight: 50,
                  fatherWidth: 100,
                  heightOfChild: 45,
                  widthOfChild: 45,
                  customizeTravelDistance: true,
                  start: 50,
                  end: 0,
                  animation: _animationBack,
                  duration: const Duration(milliseconds: 1000),
                  child: GestureDetector(
                    onTap: () async {
                      widget.onHideRecoveryPassword(true);
                      if (!mounted) return;
                      await Future.delayed(const Duration(milliseconds: 10));
                      widget.onChanged(0);
                      await Future.delayed(const Duration(milliseconds: 20));
                      widget.onHideRecoveryPassword(false);
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: specs.black150,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: specs.black150,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  title2,
                  style: GoogleFonts.outfit(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  subTitle2,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: specs.black150,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
