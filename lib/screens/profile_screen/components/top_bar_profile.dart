import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../message_screen/message_room_screen.dart';
import '../../setting/edit_profile/edit_profile.dart';
import '../../setting/setting_and_privacy.dart';


class TopBarProfile extends StatelessWidget {
  final bool isOwnerProfile;
  final String userId;
  final String userName;
  final ImageProvider? imageProvider;
  final Color colorButton;

  const TopBarProfile({
    super.key,
    required this.isOwnerProfile,
    required this.userId,
    required this.userName,
    required this.imageProvider,
    this.colorButton = const Color.fromRGBO(255, 255, 255, 0.8),
  });

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
        width: specs.screenWidth,
        height: 90,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: isOwnerProfile
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomAnimatedButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const EditProfile()),
                        );
                      },
                      height: 35,
                      width: 80,
                      color: colorButton,
                      shadowColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ImageIcon(
                            AssetImage("assets/icons/setting/user-pen.png"),
                            size: 14,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Edit",
                            style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w400),
                          )
                        ],
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomAnimatedButton(
                      onTap: () {},
                      height: 35,
                      width: 35,
                      color: colorButton,
                      shadowColor: Colors.transparent,
                      child: const Center(
                        child: ImageIcon(
                          AssetImage("assets/icons/setting/qr.png"),
                          size: 14,
                        ),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomAnimatedButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const SettingAndPrivacy()),
                        );
                      },
                      height: 35,
                      width: 35,
                      color: colorButton,
                      shadowColor: Colors.transparent,
                      child: const Center(
                        child: ImageIcon(
                          AssetImage("assets/icons/setting/gears.png"),
                          size: 14,
                        ),
                      )),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomAnimatedButton(
                      onTap: () => Navigator.pop(context),
                      height: 35,
                      width: 80,
                      color: colorButton,
                      shadowColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ImageIcon(
                            AssetImage(
                                "assets/icons/other_icons/angle-left.png"),
                            size: 14,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Back",
                            style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w400),
                          )
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomAnimatedButton(
                          onTap: () => {},
                          height: 35,
                          width: 85,
                          color: colorButton,
                          shadowColor: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Follow",
                                style: GoogleFonts.outfit(
                                    fontSize: 13, fontWeight: FontWeight.w400),
                              )
                            ],
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomAnimatedButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => MessageRoomScreen(
                                      userName: userName,
                                      imageProvider: imageProvider,
                                      userId: userId)),
                            );
                          },
                          height: 35,
                          width: 35,
                          color: colorButton,
                          shadowColor: Colors.transparent,
                          child: const Center(
                            child: ImageIcon(
                              AssetImage("assets/icons/bottom_bar/beacon.png"),
                              size: 14,
                            ),
                          )),
                    ],
                  )
                ],
              ));
  }
}
