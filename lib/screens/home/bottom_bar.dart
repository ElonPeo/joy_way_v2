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

class _BottomBarState extends State<BottomBar> with WidgetsBindingObserver {
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

  final List<GlobalKey> _itemKeys = List.generate(5, (_) => GlobalKey());
  final List<double> _itemLeft = List.filled(5, 20);

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _animIndex = widget.page;
      _oldAnimIndex = oldWidget.page;
    }
  }

  void initState() {
    super.initState();
    _animIndex = widget.page;
    _oldAnimIndex = widget.page;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _captureItemPositions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _captureItemPositions());
  }

  void _captureItemPositions() {
    for (int i = 0; i < 5; i++) {
      final ctx = _itemKeys[i].currentContext;
      final render = ctx?.findRenderObject() as RenderBox?;
      if (render != null) {
        final topLeft = render.localToGlobal(Offset.zero);
        final left = topLeft.dx;
        if (_itemLeft[i] != left) {
          _itemLeft[i] = left;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return SizedBox(
      height: 100,
      width: specs.screenWidth,
      child: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCirc,
              left: _itemLeft[_animIndex],
              bottom: 37,
              child: Container(
                height: 55,
                width: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) {
                      final forward = _animIndex > _oldAnimIndex; // hướng
                      final slide = Tween<Offset>(
                        begin: forward
                            ? const Offset(0, .35)
                            : const Offset(0, -.35),
                        end: Offset.zero,
                      ).animate(anim);
                      final scale =
                          Tween<double>(begin: .85, end: 1).animate(anim);

                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: slide,
                          child: ScaleTransition(scale: scale, child: child),
                        ),
                      );
                    },
                    child: _DotIcon(
                      key: ValueKey(_animIndex),
                      // bắt buộc để switcher nhận thay đổi
                      asset: _iconAssets[_animIndex], // icon theo page hiện tại
                    ),
                  ),
                ),
              )),
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: BottomBar.kHeight,
              width: MediaQuery.of(context).size.width,
              child: LayoutBuilder(
                builder: (context, c) {
                  const borderRadius = 10.0;
                  const radius = 30.0;
                  const yOffset = 13.0;
                  const smooth = 4.0;
                  const gradientOfSmooth = 4.0;
                  const left = borderRadius;
                  final right = c.maxWidth - borderRadius;
                  const concaveWidth = smooth +
                      gradientOfSmooth +
                      2 * radius +
                      gradientOfSmooth +
                      smooth;
                  final maxStart =
                      (right - left - concaveWidth).clamp(0.0, double.infinity);
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0, end: _itemLeft[_animIndex] - 20.5),
                    curve: Curves.easeOutCirc,
                    builder: (context, value, _) {
                      return CustomPaint(
                        size: Size(c.maxWidth, BottomBar.kHeight),
                        painter: AppBarPainter(
                          anim: AlwaysStoppedAnimation(value),
                          borderRadius: borderRadius,
                          radius: radius,
                          yOffset: yOffset,
                          smooth: smooth,
                          gradientOfSmooth: gradientOfSmooth,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: BottomBar.kHeight,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return Builder(
                      builder: (itemContext) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          _oldAnimIndex = _animIndex;
                          widget.onPage(index);
                          setState(() => _animIndex = index);
                        },
                        child: SizedBox(
                          key: _itemKeys[index],
                          height: 80,
                          width: 55,
                          // color: Colors.green.withOpacity(0.2),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                left: 16.5,
                                top: _animIndex == index ? 0 : 19,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _animIndex == index ? 0 : 1,
                                  child: ImageIcon(
                                    AssetImage("${_iconAssets[index]}"),
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
                                    duration: const Duration(milliseconds: 200),
                                    opacity: _animIndex == index ? 1 : 0,
                                    child: Text(
                                      _titlePage[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: specs.pantoneColor4,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                )),
          ),
        ],
      ),
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

    final double startConcave = anim.value; // <<< dùng giá trị đang animate

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

    // 3) cung tròn (ví dụ chord ~ 2*radius)
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

    // 6) các cạnh & bo góc
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
      child: ImageIcon(AssetImage(asset),
          size: 25, color: const Color.fromRGBO(40, 67, 43, 1)),
    );
  }
}
