import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/profile_screen/post_screen/post_screen.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import '../../../config/general_specifications.dart';
import 'dart:ui' show ImageFilter;

import '../../../models/user/user_app.dart';
import '../../../services/firebase_services/profile_services/profile_fire_storage_image.dart';
import '../../../services/firebase_services/profile_services/profile_firestore.dart';
import '../../../widgets/photo_view/custom_photo_view.dart';
import 'about_screen/about_screen.dart';
import 'components/middle_navigation_bar.dart';
import 'components/top_bar_profile.dart';
import 'evaluate_screen/evaluate_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnerProfile;
  final String? userId;
  const ProfileScreen({
    super.key,
    this.isOwnerProfile = true,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _switcherKey = GlobalKey();

  // ownership
  String? _targetUid;
  bool _isOwner = false;
  UserApp? _userApp;

  // Ảnh
  File? _avatarImage;
  File? _bgImage;
  String? _avatarUrl;
  String? _bgUrl;

  // State flags
  String? _error;
  bool _isLoaded = false;
  int _page = 0;

  // Animated layout state
  double _currentScrollY = 0.0;
  double _backgroundHeight = 250.0;
  double _userInfoBox = 120.0;
  double _middleBarPosition = 280.0;
  double _middleBarCornerRadius = 20.0;
  double _middleBarHorizontalMargin = 60.0;
  double _backgroundCornerRadius = 60.0;
  double _backgroundBlurSigma = 0.0;

  // auto scroll
  bool _isAutoScrolling = false;
  Timer? _snapTimer;
  static const double _snapMinOffset = 80.0;
  static const double _snapMaxOffset = 110.0;

  // ===== Scroll effect constants =====
  // Nền (bg)
  static const double _scrollStart1 = 0.0;
  static const double _scrollEnd1 = 70.0;

  // Thanh giữa (mid)
  static const double _scrollStart2 = 80.0;
  static const double _scrollEnd2 = 100.0;

  // User box (giống bg/mid: có khoảng start/end riêng)
  static const double _userBoxScrollStart = 0.0;
  static const double _userBoxScrollEnd = 80.0;

  static const double _radiusStart = 60.0;
  static const double _bgHeightStart = 250.0;

  static const double _userInfoBoxStart = 120.0;
  static const double _radiusEnd = 20.0;

  static const double _midBarStartPos = 280.0;
  static const double _minBgHeight = 180.0;
  static const double _minUserInfo = 100.0;

  static const double _maxBlurSigma = 12.0;

  @override
  void initState() {
    super.initState();
    final current = FirebaseAuth.instance.currentUser;
    _targetUid = widget.userId ?? current?.uid;
    _isOwner = (_targetUid != null && _targetUid == current?.uid);
    _loadUserInfo();
    _loadTargetUserImages();
    _scrollController.addListener(_updateUIOnScroll);
  }

  ImageProvider? _bgProvider() {
    if (_bgImage != null) return FileImage(_bgImage!);
    if (_bgUrl != null && _bgUrl!.isNotEmpty) return NetworkImage(_bgUrl!);
    return null;
  }

  ImageProvider? _avatarProvider() {
    if (_avatarImage != null) return FileImage(_avatarImage!);
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(_avatarUrl!);
    }
    return null;
  }

  Future<void> _loadUserInfo() async {
    final userApp = await ProfileFirestore().getUserInformationById(
      context,
      uid: _targetUid,
    );
    if (!mounted) return;
    if (userApp != null) {
      setState(() {
        _userApp = userApp;
        _isLoaded = true;
      });
    } else {
      setState(() {
        _userApp = UserApp(
          userId: _targetUid ?? "unknown",
          email: " ",
          name: "No name",
          userName: "@",
          phoneNumber: " ",
          sex: " ",
          dateOfBirth: null,
          livingPlace: "not set yet",
          livingCoordinate: null,
          socialLinks: [],
          avatarImageId: null,
          backgroundImageId: null,
        );
      });
    }
  }

  Future<void> _loadTargetUserImages() async {
    if (_targetUid == null) {
      setState(() => _isLoaded = true);
      return;
    }
    final imgs = await ProfileFireStorageImage()
        .getUserAvatarAndBackgroundUrls(_targetUid!);
    if (!mounted) return;
    if (imgs.error != null) {
      setState(() => _error = imgs.error);
    }
    setState(() {
      _avatarUrl = imgs.avatarUrl;
      _bgUrl = imgs.bgUrl;
      _isLoaded = true;
    });
  }

  /// Khi đổi page
  void _switchPage(int value) async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (!mounted) return;
    setState(() => _page = value);
  }

  // ===== Scroll handlers =====
  void _updateUIOnScroll() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    final clampedOffset = math.max(0.0, scrollOffset);

    final bg = _calcBackground(clampedOffset);
    final mid = _calcMiddleBar(clampedOffset);
    final userBox = _calcUserInfoBox(clampedOffset);

    if (_shouldRebuild(bg, mid, userBox, clampedOffset)) {
      setState(() {
        _currentScrollY = clampedOffset;

        _backgroundHeight = bg.height;
        _backgroundCornerRadius = bg.radius;
        _backgroundBlurSigma = bg.blurSigma;

        _middleBarPosition = mid.pos;
        _middleBarCornerRadius = mid.radius;
        _middleBarHorizontalMargin = mid.margin;

        _userInfoBox = userBox.height;
      });
    }
    //
    // Auto-snap when in (80, 110)
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted || !_scrollController.hasClients || _isAutoScrolling) return;
      final off = _scrollController.offset;
      if (off > _snapMinOffset && off < _snapMaxOffset) {
        const midOff = (_snapMinOffset + _snapMaxOffset) / 2.0;
        final target = (off >= midOff) ? _snapMaxOffset + 1 : _snapMinOffset;
        _isAutoScrolling = true;
        _scrollController
            .animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        )
            .whenComplete(() => _isAutoScrolling = false);
      }
    });
  }

  double _progress(double value, double start, double end) {
    if (end == start) return 0.0;
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  double _ease(double t) => Curves.easeOut.transform(t);

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ===== Calculations =====
  ({double height, double radius, double blurSigma}) _calcBackground(double y) {
    final double newHeight = (y <= _scrollStart1)
        ? _bgHeightStart
        : (y >= _scrollEnd1)
        ? _minBgHeight
        : _bgHeightStart - (y - _scrollStart1);

    final t = _ease(_progress(y, _scrollStart1, _scrollEnd1));
    final double newRadius = _radiusStart * (1.0 - t);
    final double newSigma = _maxBlurSigma * t;
    return (height: newHeight, radius: newRadius, blurSigma: newSigma);
  }

  ({double pos, double radius, double margin}) _calcMiddleBar(double y) {
    final double newPos = (y <= _scrollStart1)
        ? _midBarStartPos
        : (y >= _scrollEnd2)
        ? _minBgHeight
        : _midBarStartPos - (y - _scrollStart1);

    final t1 = _ease(_progress(y, _scrollStart2, _scrollEnd2));
    final double newRadius = _radiusEnd * (1.0 - t1);
    final double newMargin = 60 * (1.0 - t1);
    return (pos: newPos, radius: newRadius, margin: newMargin);
  }


  ({double height}) _calcUserInfoBox(double y) {
    final t = _ease(_progress(y, _userBoxScrollStart, _userBoxScrollEnd));
    final newHeight = _lerp(_userInfoBoxStart, _minUserInfo, t);
    return (height: newHeight);
  }

  bool _shouldRebuild(
      ({double height, double radius, double blurSigma}) bg,
      ({double pos, double radius, double margin}) mid,
      ({double height}) userBox,
      double y, {
        double eps = 0.5,
      }) {
    return ((bg.height - _backgroundHeight).abs() > eps) ||
        ((bg.radius - _backgroundCornerRadius).abs() > eps) ||
        ((bg.blurSigma - _backgroundBlurSigma).abs() > eps) ||
        ((mid.pos - _middleBarPosition).abs() > eps) ||
        ((mid.radius - _middleBarCornerRadius).abs() > eps) ||
        ((mid.margin - _middleBarHorizontalMargin).abs() > eps) ||
        ((userBox.height - _userInfoBox).abs() > eps) ||
        ((y - _currentScrollY).abs() > eps);
  }

  Widget _buildChild(GeneralSpecifications specs) {
    switch (_page) {
      case 0:
        return const PostScreen();
      case 1:
        return AboutScreen(
          name: _userApp?.name,
          userName: _userApp?.userName,
          phoneNumber: _userApp?.phoneNumber,
          sex: _userApp?.sex,
          email: _userApp?.email,
          dateOfBirth: _userApp?.dateOfBirth,
          livingCoordinate: _userApp?.livingCoordinate,
          livingPlace: _userApp?.livingPlace,
          socialLinks: _userApp?.socialLinks,
        );
      case 2:
        return const EvaluateScreen();
      default:
        return const PostScreen();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateUIOnScroll);
    _scrollController.dispose();
    _snapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final child = _buildChild(specs);
    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 310),
              AnimatedSwitcher(
                key: _switcherKey,
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey<int>(_page),
                  child: child,
                ),
              ),
            ],
          ),
          Positioned(
            top: _middleBarPosition,
            left: _middleBarHorizontalMargin / 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_middleBarCornerRadius),
              child: Container(
                height: 40,
                width: specs.screenWidth - _middleBarHorizontalMargin,
                color: Colors.black,
                child: MiddleNavigationBar(
                  page: _page,
                  onPage: (value) => _switchPage(value),
                ),
              ),
            ),
          ),
      
          // phần background + user info box
          Positioned(
            top: 0,
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_backgroundCornerRadius),
                bottomRight: Radius.circular(_backgroundCornerRadius),
              ),
              child: SizedBox(
                height: _backgroundHeight,
                width: specs.screenWidth,
                child: Stack(
                  children: [
                    !_isLoaded
                        ? LoadingContainer(
                      baseColor: Colors.white,
                      height: _backgroundHeight,
                      width: specs.screenWidth,
                    )
                        : CustomPhotoView(
                      height: _backgroundHeight,
                      width: specs.screenWidth,
                      imageProvider: _bgProvider(),
                      backgroundColor: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(_backgroundCornerRadius),
                        bottomRight:
                        Radius.circular(_backgroundCornerRadius),
                      ),
                      child: Container(color: specs.black240),
                    ),
                    Container(
                      height: _backgroundHeight,
                      width: specs.screenWidth,
                      color: Color.fromRGBO(0, 0, 0, 0.3)
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _backgroundBlurSigma,
                        sigmaY: _backgroundBlurSigma,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: _userInfoBox,
                            width: specs.screenWidth,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: _userInfoBox - 40,
                                  width: _userInfoBox - 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(1000),
                                      child: Container(
                                        height: _userInfoBox - 48,
                                        width: _userInfoBox - 48,
                                        child:                   !_isLoaded
                                            ? LoadingContainer(
                                          baseColor: Colors.white,
                                          height: _userInfoBox - 48,
                                          width: _userInfoBox - 48,
                                        )
                                            : CustomPhotoView(
                                          height: _userInfoBox - 48,
                                          width: _userInfoBox - 48,
                                          imageProvider: _avatarProvider(),
                                          backgroundColor: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(_backgroundCornerRadius),
                                            bottomRight:
                                            Radius.circular(_backgroundCornerRadius),
                                          ),
                                          child: Container(color: specs.black240),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: specs.screenWidth - 140,
                                      child: Text(
                                        _userApp?.name ?? "",
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(
                                      width: specs.screenWidth - 140,
                                      child: Text(
                                        _userApp?.userName == null
                                            ? ""
                                            : "@${_userApp?.userName}",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.white
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    TopBarProfile(
                      isOwnerProfile: widget.isOwnerProfile,
                      userName: _userApp?.userName ?? "",
                      userId: _userApp?.userId ?? "",
                      imageProvider: _avatarProvider(),
                    ),
      
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
