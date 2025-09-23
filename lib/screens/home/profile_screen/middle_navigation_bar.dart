import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/general_specifications.dart';

class MiddleNavigationBar extends StatefulWidget {
  final int page;
  final Function(int) onPage;

  const MiddleNavigationBar(
      {super.key, required this.page, required this.onPage});

  @override
  State<MiddleNavigationBar> createState() => _MiddleNavigationBarState();
}

class _MiddleNavigationBarState extends State<MiddleNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onPage(0);
          },
          child: SizedBox(
            height: 46,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Post",
                  style: GoogleFonts.outfit(
                      color: widget.page == 0 ? Colors.white : specs.black150,
                      fontSize: 14,
                      fontWeight: widget.page == 0 ? FontWeight.w500 : FontWeight.w400
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Stack(
                      children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 100),
                      bottom: widget.page == 0 ? -7 : -10,
                      left: 19 ,
                      child: Container(
                        height: 10,
                        width: 65,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(100),
                                topLeft: Radius.circular(100))),
                      ),
                    )
                  ]),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onPage(1);
          },
          child: SizedBox(
            height: 46,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "About",
                  style: GoogleFonts.outfit(
                      color: widget.page == 1 ? Colors.white : specs.black150,
                      fontSize: 14,
                      fontWeight: widget.page == 1 ? FontWeight.w500 : FontWeight.w400
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          bottom: widget.page == 1 ? -7 : -10,
                          left: 13 ,
                          child: Container(
                            height: 10,
                            width: 75,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(100),
                                    topLeft: Radius.circular(100))),
                          ),
                        )
                      ]),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onPage(2);
          },
          child: SizedBox(
            height: 46,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Evaluate",
                  style: GoogleFonts.outfit(
                      color: widget.page == 2 ? Colors.white : specs.black150,
                      fontSize: 14,
                      fontWeight: widget.page == 2 ? FontWeight.w500 : FontWeight.w400
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          bottom: widget.page == 2 ? -7 : -10,
                          left: 15 ,
                          child: Container(
                            height: 10,
                            width: 70,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(100),
                                    topLeft: Radius.circular(100))),
                          ),
                        )
                      ]),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
