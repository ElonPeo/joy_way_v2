import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

class CustomTextBox extends StatefulWidget {
  final double minHeight;
  final double? width;
  final String hiddenText;
  final bool isRequire;
  final String? text;
  final Future<void> Function()? onTap;

  const CustomTextBox(
      {super.key,
        this.isRequire = true,
      this.minHeight = 55,
      this.width,
      this.onTap,
      required this.hiddenText,
      required this.text});

  @override
  State<CustomTextBox> createState() => _CustomTextBoxState();
}

class _CustomTextBoxState extends State<CustomTextBox> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return GestureDetector(
      onTap: () async {
        if (widget.onTap != null) {
          await widget.onTap!.call();
        }
      },
      child: Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight,
          ),
          width: widget.width ?? specs.screenWidth - 20,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: const Color.fromRGBO(240, 240, 240, 1),
              ),
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.text == null) RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    color: specs.black150,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: widget.hiddenText,
                    ),
                    if(widget.isRequire)
                      TextSpan(
                        text: " *",
                        style: TextStyle(color: specs.rSlight, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ) else Text(
                widget.text!,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )),
    );
  }
}
