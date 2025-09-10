import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedButton extends StatefulWidget {
  final double height;
  final double width;
  final String text;
  final double fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final Color color;
  final Color shadowColor;

  final VoidCallback? onTap;


  const AnimatedButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    this.fontSize = 10,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.w400,
    this.color = const Color.fromRGBO(40, 67, 43, 1),
    this.shadowColor = const Color.fromRGBO(52, 147, 100, 0.15),
    this.onTap,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isTapDown = false;
  bool _shouldCallTap = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        _safeSetState(() => _isTapDown = true);
      },
      onTapUp: (details) {
        _safeSetState(() {
          _isTapDown = false;
          _shouldCallTap = true;
        });
      },
      onTapCancel: () {
        _safeSetState(() => _isTapDown = false);
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            AnimatedScale(
              scale: _isTapDown ? 0.8 : 1,
              duration: const Duration(milliseconds: 150),
              onEnd: () {
                if (!_isTapDown && _shouldCallTap) {
                  _shouldCallTap = false;
                  widget.onTap?.call();
                }
              },
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor,
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: _isTapDown
                          ? const Offset(0, 0)
                          : const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: GoogleFonts.outfit(
                      fontWeight: widget.fontWeight,
                      fontSize: widget.fontSize,
                      color: widget.textColor,
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
