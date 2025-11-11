import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/general_specifications.dart';
import '../../../widgets/animated_container/flashing_container.dart';

class TopBarNotify extends StatefulWidget {
  final int page;
  final Function(int) onPageChanged;
  const TopBarNotify({super.key,
  required this.page,
    required this.onPageChanged,
  });

  @override
  State<TopBarNotify> createState() => _TopBarNotifyState();
}

class _TopBarNotifyState extends State<TopBarNotify> {
  int _page = 0;

  @override
  void initState() {
    setState(() {
      _page = widget.page;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(TopBarNotify oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      setState(() {
        _page = widget.page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      width: specs.screenWidth,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                width: 1,
                color: specs.black240,
              )
          )
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              width: specs.screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Notify",
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FlashingContainer(
                        onTap: () {

                        },
                        height: 40,
                        width: 40,
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                        flashingColor: specs.black200,
                        child: const Center(
                          child: ImageIcon(
                              AssetImage(
                                  "assets/icons/other_icons/search.png"),
                              color: Colors.black,
                              size: 20),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      )
                    ],
                  ),
                ],
              )
          ),
          Container(
            height: 50,
            width: specs.screenWidth,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              children: [
                FlashingContainer(
                  onTap: () {
                    setState(() {
                      _page = 0;
                    });
                    widget.onPageChanged(0);
                  },
                  height: 40,
                  width: 45,
                  borderRadius: BorderRadius.circular(100),
                  color: _page == 0 ?  specs.pantoneColor4 : specs.black240,
                  flashingColor: specs.pantoneColor,
                  child: Center(
                    child: Text(
                      "All",
                      style: GoogleFonts.outfit(
                          color: _page == 0 ?  Colors.white : specs.black150,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                FlashingContainer(
                  onTap: () {
                    setState(() {
                      _page = 1;
                    });
                    widget.onPageChanged(1);
                  },
                  height: 40,
                  width: 60,
                  borderRadius: BorderRadius.circular(100),
                  color: _page == 1 ?  specs.pantoneColor4 : specs.black240,
                  flashingColor: specs.pantoneColor,
                  child: Center(
                    child: Text(
                      "Post",
                      style: GoogleFonts.outfit(
                          color: _page == 1 ?  Colors.white : specs.black150,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                FlashingContainer(
                  onTap: () {
                    setState(() {
                      _page = 2;
                    });
                    widget.onPageChanged(2);
                  },
                  height: 40,
                  width: 80,
                  borderRadius: BorderRadius.circular(100),
                  color: _page == 2 ?  specs.pantoneColor4 : specs.black240,
                  flashingColor: specs.pantoneColor,
                  child: Center(
                    child: Text(
                      "Journey",
                      style: GoogleFonts.outfit(
                          color: _page == 2 ?  Colors.white : specs.black150,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}