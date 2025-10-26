import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/main.dart';
import 'package:joy_way/screens/home_screen/top_bar/search_screen/search_screen.dart';
import 'package:joy_way/widgets/animated_container/flashing_container.dart';

import '../../../../config/general_specifications.dart';



class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: 100,
      padding: const EdgeInsets.only(right: 20, bottom: 5),
      width: specs.screenWidth,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(36),
            bottomLeft: Radius.circular(36),
          ),
        border: Border.all(
          color: specs.black240,
          width: 1
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 60,
            width: 150,
            child: Image.asset('assets/logos/logo_l.png'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlashingContainer(
                onTap: () {

                },
                height: 50,
                width: 40,
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                flashingColor: specs.black200,
                margin: const EdgeInsets.only(bottom: 10),
                child: const Center(
                  child: ImageIcon(
                      AssetImage(
                          "assets/icons/other_icons/filter.png"),
                      color: Colors.black,
                      size: 20),
                ),
              ),

              FlashingContainer(
                onTap: () {
                  showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'search',
                      barrierColor: Colors.black.withOpacity(0.12),
                      transitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => const SearchScreen()
                  );
                },
                height: 50,
                width: 40,
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                flashingColor: specs.black200,
                margin: const EdgeInsets.only(bottom: 10),
                child: const Center(
                  child: ImageIcon(
                      AssetImage(
                          "assets/icons/other_icons/search.png"),
                      color: Colors.black,
                      size: 20),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}