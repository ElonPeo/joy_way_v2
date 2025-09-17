import 'package:flutter/material.dart';

class LoadingContainer extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color overlayColor;
  final double bandWidth;
  final Duration duration;
  final BorderRadius? borderRadius;


  const LoadingContainer({
    super.key,
    required this.width,
    required this.height,
    this.baseColor = const Color.fromRGBO(255, 255, 255, 1),
    this.overlayColor = const Color.fromRGBO(230, 230, 230, 1),
    this.bandWidth = 300,
    this.duration = const Duration(milliseconds: 2000),
    this.borderRadius,
  });

  @override
  State<LoadingContainer> createState() => _LoadingContainerState();
}

class _LoadingContainerState extends State<LoadingContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
    _t = CurvedAnimation(parent: _c, curve: Curves.linear);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
          Container(
          width: widget.width,
          height: widget.height,
          color: widget.baseColor,
          ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (context, child) {
                    // chạy từ trái (-bandWidth) -> phải (width)
                    final total = widget.width + widget.bandWidth;
                    final dx = -widget.bandWidth + total * _t.value;
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: widget.width,
                          height: widget.height,
                          decoration: BoxDecoration(
                            // có thể làm mềm mép dải bằng gradient ngang nhẹ
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color.fromRGBO(255, 255, 255, 0),
                                widget.overlayColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
