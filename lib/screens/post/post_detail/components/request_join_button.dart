import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';

import '../../../post/post_request_form/post_request_form.dart';


class RequestJoinButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return CustomAnimatedButton(
        height: 45,
        width: specs.screenWidth - 20,
        color: specs.pantoneColor4,
        shadowColor: Colors.transparent,
        onTap: (){
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => PostRequestForm(

                )),
          );
        },
        child: Text(
          "Request to join",
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
    );
  }
}