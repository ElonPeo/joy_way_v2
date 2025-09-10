import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';
import '../../../../widgets/animated_container/flashing_container.dart';
import '../../../../widgets/custom_text_field/custome_select.dart';


class ChooseGender extends StatefulWidget{
  final String? sex;
  final Function(String) onSex;
  const ChooseGender({super.key,
  this.sex, required this.onSex
  });
  @override
  State<ChooseGender> createState() => _ChooseGenderState();
}

class _ChooseGenderState extends State<ChooseGender> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Container(
      padding: const EdgeInsets.all(10),
      width: specs.screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: specs.screenWidth * 0.3,
            child: Text(
              "Sex",
              style: GoogleFonts.outfit(
                  fontSize: 14, color: specs.black100),
            ),
          ),
          CustomeSelect(
              child: SizedBox(
                  width: specs.screenWidth * 0.55 - 10,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        widget.sex ?? "Your sex",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: (widget.sex ?? '').isEmpty
                              ? specs.black200
                              : specs.pantoneColor,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        width: 15,
                        child: Image.asset(
                            "assets/icons/other_icons/angle-right.png"
                        ),
                      )
                    ],
                  )
              ),
              children: [
                FlashingContainer(
                  onTap: () async {
                    await widget.onSex("Male");
                    Navigator.pop(context);
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
                        Text(
                          "Male",
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
                  onTap: () async {
                    await widget.onSex("Female");
                    Navigator.pop(context);
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
                        Text(
                          "Female",
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
                  onTap: () async {
                    await widget.onSex("Other/Prefer not to say");
                    Navigator.pop(context);
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
                        Text(
                          "Other/Prefer not to say",
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
              ]
          ),

        ],
      ),
    );
  }
}