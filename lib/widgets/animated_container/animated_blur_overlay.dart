import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBlurOverlay extends StatefulWidget {
  /// Kích thước vùng phủ blur (bao ngoài)
  final double width;
  final double height;

  /// Nội dung bên dưới lớp blur
  final Widget child;

  /// Bật/tắt blur (đổi giá trị này để mờ dần/rõ dần)
  final bool blurOn;

  /// Mức mờ tối đa
  final double maxSigma;

  /// Thời lượng & đường cong animation
  final Duration duration;
  final Curve curve;

  /// Bo góc vùng blur (nên dùng để clip)
  final BorderRadius? borderRadius;

  /// Màu phủ mờ phía trên (tuỳ chọn), ví dụ trắng trong suốt để “mềm” hơn
  final Color baseColor;

  /// Cho phép tương tác không
  final bool absorbPointer;

  /// Có animate khi blurOn đổi không (nếu false -> nhảy ngay)
  final bool animate;

  const AnimatedBlurOverlay({
    super.key,
    required this.child,
    required this.blurOn,
    this.width = 200,
    this.height = 200,
    this.maxSigma = 16,
    this.duration = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOut,
    this.borderRadius,
    this.baseColor = Colors.transparent,
    this.absorbPointer = false,
    this.animate = true,
  });

  @override
  State<AnimatedBlurOverlay> createState() => _AnimatedBlurOverlayState();
}

class _AnimatedBlurOverlayState extends State<AnimatedBlurOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _sigma;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _buildAnimation();
    _c.value = widget.blurOn ? 1.0 : 0.0;
  }

  void _buildAnimation() {
    _sigma = Tween<double>(begin: 0.0, end: widget.maxSigma)
        .animate(CurvedAnimation(parent: _c, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant AnimatedBlurOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _c.duration = widget.duration;
    }
    if (oldWidget.curve != widget.curve || oldWidget.maxSigma != widget.maxSigma) {
      final v = _c.value;
      _buildAnimation();
      _c.value = v;
    }
    if (oldWidget.blurOn != widget.blurOn) {
      if (widget.animate) {
        widget.blurOn ? _c.forward() : _c.reverse();
      } else {
        _c.value = widget.blurOn ? 1.0 : 0.0;
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _sigma,
            builder: (context, _) {
              final blur = _sigma.value;
              final clipped = ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    color: widget.blurOn ? Colors.white : Colors.transparent,
                  ),
                ),
              );
              return widget.absorbPointer
                  ? AbsorbPointer(child: clipped)
                  : IgnorePointer(ignoring: true, child: clipped);
            },
          ),
        ],
      ),
    );
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }
    return content;
  }
}

