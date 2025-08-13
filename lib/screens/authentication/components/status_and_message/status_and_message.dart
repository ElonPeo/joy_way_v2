import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

import '../../../../config/general_specifications.dart';

class StatusAndMessage extends StatefulWidget {
  @override
  State<StatusAndMessage> createState() => _StatusAndMessageState();
}

class _StatusAndMessageState extends State<StatusAndMessage> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          Center(
            child: InnerShadow(
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 5,
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(3, 3), // X=30, Y=30
                  blurRadius: 5,
                ),
              ],
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFA4EDCD), // xanh pastel
                      Color(0xFFFFFFFF), // trắng
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                ),
              ),
            ),
          ),

          Center(
            child: InnerShadow(
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(-5, -5),
                  blurRadius: 5,
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(3, 3), // X=30, Y=30
                  blurRadius: 5,
                ),
              ],
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(85, 216, 157, 1),
                      Color.fromRGBO(255, 255, 255, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: InnerShadow(
              shadows: [
                Shadow(
                  color: Color.fromRGBO(166, 133, 211, 1),
                  offset: Offset(-3, -3),
                  blurRadius: 5,
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(3, 3), // X=30, Y=30
                  blurRadius: 5,
                ),
              ],
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(118, 197, 236, 1),
                      Color.fromRGBO(226, 245, 255, 1),
                      Color.fromRGBO(166, 133, 211, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
