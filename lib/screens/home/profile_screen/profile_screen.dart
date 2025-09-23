import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/home/profile_screen/about_screen.dart';
import 'package:joy_way/screens/home/profile_screen/basic_statistics.dart';
import 'package:joy_way/screens/home/profile_screen/evaluate_screen.dart';
import 'package:joy_way/screens/home/profile_screen/follow_button.dart';
import 'package:joy_way/screens/home/profile_screen/middle_navigation_bar.dart';
import 'package:joy_way/screens/home/profile_screen/post_screen.dart';
import 'package:joy_way/screens/home/profile_screen/setting_button.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import '../../../config/general_specifications.dart';
import 'dart:ui' show ImageFilter;

import '../../../services/firebase_services/profile_services/profile_fire_storage_image.dart';
import '../../../services/firebase_services/profile_services/profile_firestore.dart';
import '../../../widgets/photo_view/custom_photo_view.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnerProfile;

  const ProfileScreen({super.key, this.isOwnerProfile = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _c = ScrollController();

  bool _dataFetched = false;
  String? _name;
  String? _userName;
  String? _phoneNumber;
  String? _sex;
  String? _email;
  DateTime? _dateOfBirth;
  String? _currentAddress;

  File? _avatarImage;
  File? _bgImage;
  String? _avatarUrl;
  String? _bgUrl;
  String? _error;
  bool _isLoaded = false;

  int _page = 1;
  double _scrollY = 0.0;
  double _backGroundHeight = 250.0;
  double _middleBarPos = 280.0;
  double _middleBarRadius = 20.0;
  double _middleBarMargin = 60.0;

  double _bgRadius = 60.0;
  double _blurSigma = 0.0;

  ImageProvider? _bgProvider() {
    if (_bgImage != null) return FileImage(_bgImage!);
    if (_bgUrl != null && _bgUrl!.isNotEmpty) return NetworkImage(_bgUrl!);
    return null;
  }

  ImageProvider? _avatarProvider() {
    if (_avatarImage != null) return FileImage(_avatarImage!);
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
      return NetworkImage(_avatarUrl!);
    return null;
  }

  Future<void> _loadUserInfo() async {
    final result = await ProfileFirestore().getCurrentUserInformation();
    if (result != null) {
      setState(() {
        _userName = result['userName'];
        _name = result['name'];
        _sex = result['sex'];
        _email = result['email'];
        _phoneNumber = result['phoneNumber'];
        _dateOfBirth = result['dateOfBirth'];
        _currentAddress = result['currentAddress'];
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _dataFetched = true;
      });
    });
  }

  Future<void> _loadCurrentUserImages() async {
    final imgs =
        await ProfileFireStorageImage().getCurrentUserAvatarAndBackgroundUrls();
    if (!mounted) return;
    if (imgs.error != null) {
      setState(() => _error = imgs.error);
    } else {
      setState(() {
        _avatarUrl = imgs.avatarUrl;
        _bgUrl = imgs.bgUrl;
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCurrentUserImages();
    _c.addListener(_updateUIOnScroll);
  }

// Hằng số cho hiệu ứng khi cuộn
  static const double _kStart = 0.0;
  static const double _kEnd = 80.0;
  static const double _kStart2 = 80;
  static const double _kEnd1 = 110.0;

  static const double _kR0 = 60.0;
  static const double _kH0 = 250.0;
  static const double _kR1 = 20.0;
  static const double _kH1 = 280.0;

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
    final double newMargin = 60 * (1.0 - t1);
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

  Widget _buildChild(GeneralSpecifications specs) {
    switch (_page) {
      case 0:
        return PostScreen();
      case 1:
        return const AboutScreen();
      case 2:
        return EvaluateScreen();
      default:
        return PostScreen();
    }
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
    final child = _buildChild(specs);
    return Stack(
      children: [
        ListView(
          controller: _c,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 340,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                key: ValueKey<int>(_page),
                child: child,
              ),
            )
          ],
        ),
        Positioned(
            top: _middleBarPos,
            left: _middleBarMargin / 2,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _middleBarRadius,
                ),
                child: Container(
                  height: 40,
                  width: specs.screenWidth - _middleBarMargin,
                  color: Colors.black,
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
            child: SizedBox(
              height: _backGroundHeight,
              width: specs.screenWidth,
              child: Stack(
                children: [
                  !_isLoaded
                      ? LoadingContainer(
                          height: _backGroundHeight,
                          width: specs.screenWidth,
                        )
                      : CustomPhotoView(
                          height: _backGroundHeight,
                          width: specs.screenWidth,
                          imageProvider: _bgProvider(),
                          backgroundColor: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(_bgRadius),
                            bottomRight: Radius.circular(_bgRadius),
                          ),
                          child: Container(
                            color: specs.black240,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.isOwnerProfile
                                  ? SizedBox()
                                  : Icon(Icons.close),
                              widget.isOwnerProfile
                                  ? const SettingButton()
                                  : FollowButton(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: !_isLoaded
                                        ? const LoadingContainer(
                                            width: 84, height: 84)
                                        : CustomPhotoView(
                                            height: 84,
                                            width: 84,
                                            imageProvider: _avatarProvider(),
                                            backgroundColor: specs.black150,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: const ImageIcon(
                                              AssetImage(
                                                  "assets/icons/other_icons/user.png"),
                                              size: 30,
                                            )),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: specs.screenWidth * 0.6,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: specs.screenWidth * 0.6,
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        _name ?? "",
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
                                          "@${_userName ?? ""}",
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
