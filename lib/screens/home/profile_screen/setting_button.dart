import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/setting/setting_and_privacy.dart';
import 'package:joy_way/widgets/ShowGeneralDialog.dart';
import 'package:joy_way/widgets/animated_container/animated_icon_button.dart';
import 'package:joy_way/widgets/animated_container/flashing_container.dart';

import '../../../../config/general_specifications.dart';
import '../../setting/edit_profile/edit_profile.dart';


class SettingButton extends StatefulWidget {
  const SettingButton({super.key});

  @override
  State<SettingButton> createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return AnimatedIconButton(
      height: 30,
      width: 40,
      color: Colors.white,
      child: const Icon(Icons.menu),
      shadowColor: Colors.transparent,
      onTap: () {
        ShowGeneralDialog.General_Dialog(
            context: context,
            beginOffset: const Offset(0, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: specs.screenWidth,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FlashingContainer(
                        onTap: () {
                          ShowGeneralDialog.General_Dialog(
                              context: context,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuart,
                              beginOffset: const Offset(1, 0),
                              child: const EditProfile()
                          );
                        },
                        height: 50,
                        width: specs.screenWidth,
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white,
                        flashingColor: specs.black240,
                        child: Container(
                          width: specs.screenWidth,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: specs.black240,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const ImageIcon(
                                AssetImage(
                                  "assets/icons/setting/user-pen.png",),
                                size: 20,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Edit Profile",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      FlashingContainer(
                        onTap: (){
                        },
                        height: 50,
                        width: specs.screenWidth,
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white,
                        flashingColor: specs.black240,
                        child: Container(
                          width: specs.screenWidth,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: specs.black240,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const ImageIcon(
                                AssetImage("assets/icons/setting/qr.png",),
                                size: 20,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Your QR and scan",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      FlashingContainer(
                        onTap: (){
                          ShowGeneralDialog.General_Dialog(
                              context: context,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuart,
                              beginOffset: const Offset(1, 0),
                              child: const SettingAndPrivacy()
                          );
                        },
                        height: 50,
                        width: specs.screenWidth,
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white,
                        flashingColor: specs.black240,
                        child: Container(
                          width: specs.screenWidth,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const ImageIcon(
                                AssetImage("assets/icons/setting/gears.png",),
                                size: 20,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Setting and privacy",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
