import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

class UserSuggestedInfor extends StatelessWidget {
  const UserSuggestedInfor({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36), color: Colors.white,
          border: Border.all(
            width: 1,
            color: specs.black240
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: Container(
                          height: 80,
                          width: 80,
                          child: Image.asset(
                            "assets/background/backgroundEX.jpg",
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                        color: specs.pantoneColor4,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                    ),
                    child: Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/other_icons/plus.png"),
                        size: 10,
                        color: Colors.white,
                      )
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 90,
            child: Text("Trinh Duong Trung Hieu",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.5,
                  height: 1.1,
                )),
          ),
          Container(
            height: 15,
            width: 80,
            child: Text("@trinhieu",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w400,
                  color: specs.black150,
                  letterSpacing: 0.5,
                )),
          ),
        ],
      ),
    );
  }
}



