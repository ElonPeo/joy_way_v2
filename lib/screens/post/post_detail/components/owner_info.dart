import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

import '../../../../config/general_specifications.dart';


class OwnerInfo extends StatefulWidget {
  final BasicUserInfo ownerInfo;
  const OwnerInfo({super.key,
  required this.ownerInfo
  });

  @override
  State<OwnerInfo> createState() => _OwnerInfoState();
}

class _OwnerInfoState extends State<OwnerInfo> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      width: specs.screenWidth - 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarView(
                size: 55,
                imageId: widget.ownerInfo.avatarImageId,
                nameUser: widget.ownerInfo.userName,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  SizedBox(
                    width: specs.screenWidth - 145,
                    child: Text(
                        widget.ownerInfo.name ?? "No name",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 14
                      )
                    ),
                  ),
                  SizedBox(
                    width: specs.screenWidth - 145,
                    child: Text(
                        "@${widget.ownerInfo.userName}",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: 14
                        )
                    ),
                  ),
                ],
              ),

              GestureDetector(
                child: SizedBox(
                  width: 30,
                  child: ImageIcon(
                    const AssetImage("assets/icons/other_icons/angle-right.png"),
                    size: 18,
                    color: specs.black100,
                  ),
                ),
              )
            ],
          )


        ],
      ),
    );
  }
}