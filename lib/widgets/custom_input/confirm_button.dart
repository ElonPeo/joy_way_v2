import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';

class ConfirmButton extends StatefulWidget {
  final String confirmTitle;
  final String refuseTitle;
  final VoidCallback? onConfirm;
  final VoidCallback? onRefuse;
  final bool isConfirmOnly;
  final bool isChange;

  const ConfirmButton({
    super.key,
    this.confirmTitle = "Next",
    this.refuseTitle = "Previous",
    this.onConfirm,
    this.onRefuse,
    this.isConfirmOnly = true,
    this.isChange = false,
  });

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final double fullW = specs.screenWidth - 40;
    final double halfW = (specs.screenWidth / 2.2) - 20;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: widget.isChange ? 75 : 85,
      width: specs.screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
            width: 1,
            color: specs.black240,
          ))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.isConfirmOnly == true ?
          CustomAnimatedButton(
              onTap: () {
                widget.onConfirm?.call();
              },
              pressedScale: 0.95,
              duration: Duration(milliseconds: 100),
              height: 45,
              width: fullW,
              child: Text(
                widget.confirmTitle,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ))
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAnimatedButton(
                  onTap: () {
                    widget.onRefuse?.call();
                  },
                  pressedScale: 0.95,
                  duration: Duration(milliseconds: 100),
                  height: 45,
                  width: halfW,
                  color: specs.black100,
                  child: Text(
                    widget.refuseTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                  )),
              CustomAnimatedButton(
                  onTap: () {
                    widget.onConfirm?.call();
                  },
                  pressedScale: 0.95,
                  duration: Duration(milliseconds: 100),
                  height: 45,
                  width: halfW,
                  child: Text(
                    widget.confirmTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                  )),
            ],
          ) ,
        ],
      ),
    );
  }
}
