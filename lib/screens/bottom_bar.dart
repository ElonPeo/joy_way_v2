import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/general_specifications.dart';

class BottomBar extends StatefulWidget {
  final int page;
  final Function(int) onPage;

  const BottomBar({
    super.key,
    required this.page,
    required this.onPage,
  });

  static const double kHeight = 65;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _animIndex;
  late int _oldAnimIndex;

  final List<String> _iconAssets = [
    'assets/icons/bottom_bar/home.png',
    'assets/icons/bottom_bar/bell.png',
    'assets/icons/bottom_bar/pin_map.png',
    'assets/icons/bottom_bar/beacon.png',
    'assets/icons/bottom_bar/user.png'
  ];
  final List<String> _titlePage = [
    'Home',
    'Notify',
    'Journey',
    'Message',
    'Profile'
  ];

  @override
  void initState() {
    super.initState();
    _animIndex = widget.page;
    _oldAnimIndex = widget.page;
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _oldAnimIndex = _animIndex;
      _animIndex = widget.page;
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double circleSize = 55.0;
        const double horizontalPadding = 20.0;
        final double itemWidth = width / 5;
        final double itemCenterX = itemWidth * _animIndex + itemWidth / 2;
        final double circleLeft = itemCenterX - circleSize / 2;
        final double concaveStart = circleLeft - horizontalPadding + 0.5;

        return SizedBox(
          height: 100,
          width: width,
          child: Stack(
            children: [
              // Vòng tròn nhô lên
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCirc,
                left: circleLeft,
                bottom: 37,
                child: Container(
                  height: circleSize,
                  width: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      width: 0.8,
                      color: specs.black240,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) {
                        final forward = _animIndex > _oldAnimIndex;
                        final slide = Tween<Offset>(
                          begin:
                          forward ? const Offset(0, .35) : const Offset(0, -.35),
                          end: Offset.zero,
                        ).animate(anim);
                        final scale =
                        Tween<double>(begin: .85, end: 1).animate(anim);

                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: slide,
                            child: ScaleTransition(
                              scale: scale,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _DotIcon(
                        key: ValueKey(_animIndex),
                        asset: _iconAssets[_animIndex],
                      ),
                    ),
                  ),
                ),
              ),

              // Nền bottom bar + concave moving
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: BottomBar.kHeight,
                  width: width,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween<double>(
                      begin: 0,
                      end: concaveStart,
                    ),
                    curve: Curves.easeOutCirc,
                    builder: (context, value, _) {
                      return CustomPaint(
                        size: Size(width, BottomBar.kHeight),
                        painter: AppBarPainter(
                          anim: AlwaysStoppedAnimation(value),
                          borderRadius: 10.0,
                          radius: 30.0,
                          yOffset: 13.0,
                          smooth: 4.0,
                          gradientOfSmooth: 4.0,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  height: BottomBar.kHeight,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          _oldAnimIndex = _animIndex;
                          widget.onPage(index);
                          setState(() => _animIndex = index);
                        },
                        child: SizedBox(
                          height: 80,
                          width: 55,
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                left: 16.5,
                                top: _animIndex == index ? 0 : 19,
                                child: AnimatedOpacity(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  opacity: _animIndex == index ? 0 : 1,
                                  child: ImageIcon(
                                    AssetImage(_iconAssets[index]),
                                    size: 22,
                                    color: _animIndex == index
                                        ? specs.pantoneColor4
                                        : specs.black150,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                child: SizedBox(
                                  width: 55,
                                  child: AnimatedOpacity(
                                    duration:
                                    const Duration(milliseconds: 200),
                                    opacity: _animIndex == index ? 1 : 0,
                                    child: Text(
                                      _titlePage[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppBarPainter extends CustomPainter {
  AppBarPainter({
    required this.anim,
    this.borderRadius = 15,
    this.radius = 30,
    this.yOffset = 10,
    this.smooth = 4,
    this.gradientOfSmooth = 2,
  }) : super(repaint: anim);

  final Animation<double> anim;
  final double borderRadius, radius, yOffset, smooth, gradientOfSmooth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    final double left = borderRadius;
    final double right = size.width - borderRadius;

    final double startConcave = anim.value;

    path.moveTo(left, 0);

    // 1) thẳng tới trước smooth
    final endLineX = startConcave + left;
    path.lineTo(endLineX, 0);

    // 2) bo xuống yOffset
    final sx = endLineX + smooth;
    path.quadraticBezierTo(
      sx,
      0,
      sx + gradientOfSmooth,
      yOffset,
    );

    // 3) cung tròn
    final ex = sx + gradientOfSmooth + 2 * radius;
    path.arcToPoint(
      Offset(ex, yOffset),
      radius: Radius.circular(radius + 3),
      largeArc: false,
      clockwise: false,
    );

    // 4) bo lên lại Ox
    path.quadraticBezierTo(
      ex + gradientOfSmooth,
      0,
      ex + gradientOfSmooth + smooth,
      0,
    );

    // 5) cạnh trên còn lại
    path.lineTo(right, 0);

    // 6) bo 4 góc còn lại
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(size.width, size.height, right, size.height);
    path.lineTo(left, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, left, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AppBarPainter old) {
    return borderRadius != old.borderRadius ||
        radius != old.radius ||
        yOffset != old.yOffset ||
        smooth != old.smooth ||
        gradientOfSmooth != old.gradientOfSmooth;
  }
}

class _DotIcon extends StatelessWidget {
  final String asset;

  const _DotIcon({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 25,
      child: ImageIcon(
        AssetImage(asset),
        size: 25,
        color: Colors.black,
      ),
    );
  }
}
