import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/home/profile_screen/follow_button.dart';
import 'package:joy_way/screens/home/profile_screen/middle_navigation_bar.dart';
import 'package:joy_way/screens/home/profile_screen/setting_button/setting_button.dart';
import '../../../config/general_specifications.dart';
import 'dart:ui' show ImageFilter;

class ProfileScreen extends StatefulWidget {
  final bool isOwnerProfile;

  const ProfileScreen({super.key, this.isOwnerProfile = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _c = ScrollController();

  int _page = 0;

  double _scrollY = 0.0;
  double _backGroundHeight = 250.0;
  double _middleBarPos = 330.0;
  double _middleBarRadius = 20.0;
  double _middleBarMargin = 40.0;

  double _bgRadius = 40.0;
  double _blurSigma = 0.0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_updateUIOnScroll);
  }

// Hằng số cho hiệu ứng khi cuộn
  static const double _kStart = 0.0;
  static const double _kEnd = 80.0;
  static const double _kStart2 = 80;
  static const double _kEnd1 = 160.0;

  static const double _kR0 = 40.0;
  static const double _kH0 = 250.0;
  static const double _kR1 = 20.0;
  static const double _kH1 = 330.0;

  static const double _kHMin = 170.0;
  static const double _kBlur0 = 12.0;

  void _updateUIOnScroll() {
    final y = _c.hasClients ? _c.offset : 0.0;
    final clamped = math.max(0.0, y);
    final bg = _calcBackground(clamped);
    final mid = _calcMiddleBar(clamped);
    if (_shouldRebuild(bg, mid, clamped)) {
      setState(() {
        _scrollY = clamped;

        _backGroundHeight = bg.height;
        _bgRadius = bg.radius;
        _blurSigma = bg.blurSigma;

        _middleBarPos = mid.pos;
        _middleBarRadius = mid.radius;
        _middleBarMargin = mid.margin;
      });
    }
  }

  double _progress(double value, double start, double end) {
    if (end == start) return 0.0;
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  double _ease(double t) => Curves.easeOut.transform(t);

  ({double height, double radius, double blurSigma}) _calcBackground(double y) {
    final double newHeight = (y <= _kStart)
        ? _kH0
        : (y >= _kEnd)
            ? _kHMin
            : _kH0 - (y - _kStart);
    final t = _ease(_progress(y, _kStart, _kEnd));
    final double newRadius = _kR0 * (1.0 - t);
    final double newSigma = _kBlur0 * t;
    return (height: newHeight, radius: newRadius, blurSigma: newSigma);
  }

  ({double pos, double radius, double margin}) _calcMiddleBar(double y) {
    final double newPos = (y <= _kStart)
        ? _kH1
        : (y >= _kEnd1)
            ? _kHMin
            : _kH1 - (y - _kStart);
    final t1 = _ease(_progress(y, _kStart2, _kEnd1));
    final double newRadius = _kR1 * (1.0 - t1);
    final double newMargin = _kR0 * (1.0 - t1);
    return (pos: newPos, radius: newRadius, margin: newMargin);
  }

  bool _shouldRebuild(
    ({double height, double radius, double blurSigma}) bg,
    ({double pos, double radius, double margin}) mid,
    double y, {
    double eps = 0.5,
  }) {
    return ((bg.height - _backGroundHeight).abs() > eps) ||
        ((bg.radius - _bgRadius).abs() > eps) ||
        ((bg.blurSigma - _blurSigma).abs() > eps) ||
        ((mid.pos - _middleBarPos).abs() > eps) ||
        ((mid.radius - _middleBarRadius).abs() > eps) ||
        ((mid.margin - _middleBarMargin).abs() > eps) ||
        ((y - _scrollY).abs() > eps);
  }

  @override
  void dispose() {
    _c.removeListener(_updateUIOnScroll);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Stack(
      children: [
        ListView(
          controller: _c,
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 330,
              width: specs.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 80,
                    width: specs.screenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 50,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: specs.black200,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "3420",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                    color: Colors.black),
                              ),
                              Text(
                                "JOURNEY",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "461",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                              Text(
                                "FOLLOWING",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 8,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "461",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                              Text(
                                "FOLLOWERS",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 8,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 2000,
              width: specs.screenWidth,
              child: const Column(
                children: [],
              ),
            )
          ],
        ),
        Positioned(
            top: _middleBarPos,
            left: _middleBarMargin / 2,
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    _middleBarRadius,
                  ),
                  topRight: Radius.circular(
                    _middleBarRadius,
                  ),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Container(
                  height: 40,
                  width: specs.screenWidth - _middleBarMargin,
                  color: specs.pantoneColor4,
                  child: MiddleNavigationBar(
                    page: _page,
                    onPage: (value) => setState(() => _page = value),
                  ),
                ))),
        Positioned(
          top: 0,
          child: ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_bgRadius),
              bottomRight: Radius.circular(_bgRadius),
            ),
            child: Container(
              height: _backGroundHeight,
              width: specs.screenWidth,
              child: Stack(
                children: [
                  SizedBox(
                    height: _backGroundHeight,
                    width: specs.screenWidth,
                    child: Image.asset(
                      "assets/background/backgroundEX.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurSigma,
                        sigmaY: _blurSigma,
                      ),
                      child: const SizedBox()),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 250,
                      width: specs.screenWidth,
                      color: Colors.black.withOpacity(0.6),
                      padding: const EdgeInsets.only(
                          top: 110, left: 20, right: 20, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      height: 76,
                                      width: 76,
                                      color: specs.black200,
                                      child: Image.asset(
                                          "assets/background/photo-1633332755192-727a05c4013d.jpg"),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: specs.screenWidth * 0.6,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: specs.screenWidth * 0.6,
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        "Louis Saville",
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                        width: specs.screenWidth * 0.6,
                                        child: Text(
                                          textAlign: TextAlign.left,
                                          "@LouisSavi",
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: const Color.fromRGBO(
                                                241, 255, 245, 1),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const ImageIcon(
                                    AssetImage(
                                        "assets/icons/other_icons/pin_map_solid.png"),
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Hadong, Hanoi",
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              widget.isOwnerProfile
                                  ? SettingButton()
                                  : FollowButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
