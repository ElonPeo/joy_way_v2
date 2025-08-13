import 'package:flutter/material.dart';

// type 0 moves from top to middle, type 1 moves from right to middle, type 2 moves from bottom to middle, type 3 moves from left to middle
// set animation = true to activate the effect and vice versa
// set customizeTravelDistance = true and distance to customize travel distance
class MoveAndFadeContainer extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final Color fatherColor;
  final double widthOfChild;
  final double heightOfChild;
  final int type;
  final Widget child;
  final Duration duration;
  final bool animation;
  final Curve curve;
  final bool customizeTravelDistance;
  final double start;
  final double end;

  const MoveAndFadeContainer({
    super.key,
    required this.fatherHeight,
    required this.fatherWidth,
    required this.heightOfChild,
    required this.widthOfChild,
    required this.animation,
    required this.child,
    this.fatherColor = Colors.transparent,
    this.start = 10,
    this.end = 0,
    this.customizeTravelDistance = false,
    this.type = 0,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  @override
  State<MoveAndFadeContainer> createState() => _MoveAndFadeContainerState();
}

class _MoveAndFadeContainerState extends State<MoveAndFadeContainer> {
  @override
  Widget build(BuildContext context) {
    double centerTop = (widget.fatherHeight - widget.heightOfChild) / 2;
    double centerLeft = (widget.fatherWidth - widget.widthOfChild) / 2;
    double top = centerTop;
    double left = centerLeft;

    if (widget.animation) {
      switch (widget.type) {
        case 0:
          if(widget.customizeTravelDistance){
            top = widget.end;
          }else top = (widget.fatherHeight - widget.heightOfChild) / 2; // center top
          break;
        case 1:
          if(widget.customizeTravelDistance){
            left = widget.end;
          }else left = centerLeft;
          break;
        case 2:
          if(widget.customizeTravelDistance){
            top = widget.end;
          }else top = (widget.fatherHeight - widget.heightOfChild) / 2; // center top
          break;
        case 3:
          if(widget.customizeTravelDistance){
            left = widget.end;
          } else left = centerLeft;
          break;
      }
    } else {
      switch (widget.type) {
        case 0:
          if(widget.customizeTravelDistance){
            top = widget.start;
          } else top = 0;
          break;
        case 1:
          if(widget.customizeTravelDistance){
            left = widget.start;
          } else left = widget.fatherWidth;
          break;
        case 2:
          if(widget.customizeTravelDistance){
            top = widget.start;
          } else top = widget.fatherHeight;
          break;
        case 3:
          if(widget.customizeTravelDistance){
            left = widget.start;
          } else left = 0 - widget.widthOfChild;
          break;
      }
    }

    return Container(
      height: widget.fatherHeight,
      width: widget.fatherWidth,
      color: widget.fatherColor,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: widget.duration,
            curve: widget.curve,
            top: top,
            left: left,
            child: AnimatedOpacity(
              duration: widget.duration,
              opacity: widget.animation ? 1.0 : 0.0,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
