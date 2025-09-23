import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/animated_container/animated_button.dart';
import '../../config/general_specifications.dart';
import 'package:joy_way/widgets/animated_container/animated_icon_button.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final List<Widget> children;
  final Future<void> Function()? onConfirm;
  const CustomScaffold({super.key, this.onConfirm, required this.title, required this.children, this.backgroundColor = Colors.white });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  final ScrollController _c = ScrollController();

  static const double kSnapMin = 0.0;
  static const double kSnapMax = 60.0;
  static const double kThreshold = 20.0;
  static const Duration kDur = Duration(milliseconds: 220);
  static const Curve kCurve = Curves.easeOut;

  bool _snapping = false;


  double? _snapTarget;

  double get _y => _c.hasClients ? _c.offset : 0.0;
  bool _isInSnapZone(double y) => y >= kSnapMin && y <= kSnapMax;

  void _maybeSnap() {
    if (_snapping) return;

    final y = _y;
    if (!_isInSnapZone(y)) return;

    final fromTop = y - kSnapMin;
    final target = (fromTop < kThreshold) ? kSnapMin : kSnapMax;

    if ((target - y).abs() < 0.5) return;

    _snapping = true;
    _snapTarget = target;
    _c.animateTo(target, duration: kDur, curve: kCurve).whenComplete(() {
      _snapping = false;
      _snapTarget = null;
    });
  }

  double _scrollY = 0.0;
  double _opacity1 = 1.0;
  double _opacity2 = 0.0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_updateUIOnScroll);
  }

  // fade A: 0..20, fade B: 20..80
  static const double _kStartOpacity1 = 0.0;
  static const double _kEndOpacity1   = 20.0;
  static const double _kStartOpacity2 = 20.0;
  static const double _kEndOpacity2   = 80.0;

  void _updateUIOnScroll() {
    final y = _c.hasClients ? _c.offset : 0.0;
    final clamped = math.max(0.0, y);
    final op1 = _calcOpacity1(clamped);
    final op2 = _calcOpacity2(clamped);
    if (_shouldRebuild(op1, op2, clamped)) {
      setState(() {
        _opacity1 = op1;
        _opacity2 = op2;
        _scrollY  = clamped;
      });
    }

  }

  double _progress(double value, double start, double end) {
    if (end == start) return 0.0;
    final t = (value - start) / (end - start);
    return t.clamp(0.0, 1.0);
  }

  double _ease(double t) => Curves.easeOut.transform(t);
  double _calcOpacity1(double y) {
    final t = _ease(_progress(y, _kStartOpacity1, _kEndOpacity1));
    return 1.0 - t;
  }
  double _calcOpacity2(double y) {
    final t = _ease(_progress(y, _kStartOpacity2, _kEndOpacity2));
    return t;
  }
  bool _shouldRebuild(double newOp1, double newOp2, double newY,
      {double epsOpacity = 0.01, double epsY = 0.5}) {
    return (newOp1 - _opacity1).abs() > epsOpacity ||
        (newOp2 - _opacity2).abs() > epsOpacity ||
        (newY - _scrollY).abs()   > epsY;
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
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is UserScrollNotification &&
              n.direction == ScrollDirection.idle &&
              !_snapping) {
            _maybeSnap();
          }
          return false;
        },
        child: Stack(
          children: [
            SizedBox(
              height: specs.screenHeight,
              width: specs.screenWidth,
              child: ListView(
                controller: _c,
                padding: const EdgeInsets.only(top: 90, left: 10, right: 10),
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 0),
                    opacity: _opacity1,
                    child: SizedBox(
                      height: 50,
                      width: specs.screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            widget.title,
                            style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widget.children
                  )
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 90,
                    width: specs.screenWidth,
                    color: const Color.fromRGBO(255, 255, 255, 0.7),
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 50,
                          child: AnimatedIconButton(
                            onTap: () => Navigator.pop(context),
                            height: 30,
                            width: 20,
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            child: SizedBox(
                              height: 23, width: 23,
                              child: Image.asset("assets/icons/other_icons/angle-left.png"),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 0),
                          opacity: _opacity2,
                          child: SizedBox(
                            height: 30,
                            width: specs.screenWidth - 130,
                            child: Center(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        widget.onConfirm != null ?
                        AnimatedButton(
                            height: 30,
                            width: 40,
                            text: "Save",
                          fontSize: 18,
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          textColor: specs.pantoneColor4,
                          fontWeight: FontWeight.w500,
                          onTap: () async {
                            if (widget.onConfirm != null) {
                              await widget.onConfirm!.call();
                            }
                          },
                        ) : const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
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
