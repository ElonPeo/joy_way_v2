import 'package:flutter/material.dart';

class GeneralSpecifications {
  final double screenHeight;
  final double screenWidth;
  final Color baseColor1;

  final Color pantoneColor;
  final Color pantoneColor2;
  final Color pantoneColor3;
  final Color pantoneShadow;
  final Color pantoneShadow2;
  final Color startLocation;
  final Color endLocation;

  final Color time;
  final Color black80;
  final Color black100;
  final Color black240;
  final Color black150;
  final Color black200;

  final Color turquoise1;
  final Color turquoise2;
  final Color turquoise3;
  final Color turquoise4;
  final Color turquoise5;
  final Color turquoise6;

  GeneralSpecifications(BuildContext context)
      : screenHeight = MediaQuery.of(context).size.height,
        screenWidth = MediaQuery.of(context).size.width,
        baseColor1 = const Color.fromRGBO(240, 248, 255, 1),

        pantoneColor = const Color.fromRGBO(62, 157, 110, 1),
        // #3E9D6E
        pantoneColor2 = const Color.fromRGBO(44, 122, 84, 1),
        // #6E947C
        pantoneColor3 = const Color.fromRGBO(110, 148, 124, 1),
        // #2C98A0
        turquoise1 = const Color.fromRGBO(44, 152, 160, 1),
        // #38B2A3
        turquoise2 = const Color.fromRGBO(56, 178, 163, 1),
        // #4CC8A3
        turquoise3 = const Color.fromRGBO(76, 200, 163, 1),
        // #67D1A5
        turquoise4 = const Color.fromRGBO(103, 209, 165, 1),
        // #88E8AC
        turquoise5 = const Color.fromRGBO(136, 232, 172, 1),
        // #B0F2BC
        turquoise6 = const Color.fromRGBO(176, 242, 188, 1),
        black80 = const Color.fromRGBO(80, 80, 80, 1),
        black100 = const Color.fromRGBO(100, 100, 100, 1),
        black150 = const Color.fromRGBO(150, 150, 150, 1),
        black200 = const Color.fromRGBO(200, 200, 200, 1),
        black240 = const Color.fromRGBO(240, 240, 240, 1),
        pantoneShadow = const Color.fromRGBO(52, 147, 100, 0.15),
        pantoneShadow2 = const Color.fromRGBO(227, 232, 229, 1),
        startLocation = const Color.fromRGBO(255, 79, 15, 1),
        endLocation = const Color.fromRGBO(255, 166, 115, 1),
        time = const Color.fromRGBO(3, 166, 161, 1);
}
