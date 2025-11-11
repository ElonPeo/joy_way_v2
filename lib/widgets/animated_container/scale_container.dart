import 'dart:math';

import 'package:flutter/material.dart';



class ScaleContainer extends StatelessWidget{
  final double fatherWidth;
  final double fatherHeight;
  final Widget child;
  final Duration duration;
  final bool animation;
  final Curve curve;
  final double minS;
  final double maxS;

  const ScaleContainer({
    super.key,
    required this.fatherHeight,
    required this.fatherWidth,
    required this.animation,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutExpo,
    this.minS = 0.8,
    this.maxS = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fatherHeight,
      width: fatherHeight,
      child: Center(
        child: Stack(
          children: [
            AnimatedScale(
              scale: animation ? maxS : minS,
              duration: duration,
              curve: curve,
              child: AnimatedOpacity(
                opacity: animation ? 1 : 0,
                duration: duration,
                curve: curve,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
