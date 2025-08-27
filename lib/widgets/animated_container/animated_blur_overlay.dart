import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBlurOverlay extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final Color fatherColor;
  final Widget child;

  final double maxSigma;
  final Duration duration;
  final Curve curve;

  final bool fadeIn;
  final bool animation;

  const AnimatedBlurOverlay({
    this.fatherHeight = 100,
    this.fatherWidth = 100,
    this.fatherColor = Colors.transparent,
    this.maxSigma = 20,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutExpo,
    required this.animation,
    this.fadeIn = false,
    required this.child,
    super.key,
  });

  @override
  State<AnimatedBlurOverlay> createState() => _AnimatedBlurOverlayState();
}

class _AnimatedBlurOverlayState extends State<AnimatedBlurOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _setupAnimations();
    if (widget.animation) _controller.forward();
  }

  void _setupAnimations() {
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _blurAnimation = Tween<double>(
      begin: widget.fadeIn ? 0 : widget.maxSigma,
      end: widget.fadeIn ? widget.maxSigma : 0,
    ).animate(curved);
    if(widget.fadeIn) {
      _opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ));
    } else
      {
        _opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutExpo,
        ));
      }
  }

  @override
  void didUpdateWidget(covariant AnimatedBlurOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.fadeIn != widget.fadeIn ||
        oldWidget.curve != widget.curve ||
        oldWidget.maxSigma != widget.maxSigma) {
      _setupAnimations();
    }
    if (oldWidget.animation != widget.animation) {
      if (widget.animation) {
        _controller.forward(from: 0);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.fatherHeight,
      width: widget.fatherWidth,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              color: widget.fatherColor,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
