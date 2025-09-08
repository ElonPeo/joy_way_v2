import 'package:flutter/material.dart';
import 'package:joy_way/widgets/ShowGeneralDialog.dart';

import '../../../widgets/animated_container/animated_button.dart';

class FollowButton extends StatefulWidget {
  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      height: 30,
      width: 90,
      color: Colors.white,
      text: "Follow",
      textColor: Colors.black,
      fontSize: 11,
      onTap: () {
        ShowGeneralDialog.General_Dialog(
            context: context,
            beginOffset: Offset(1, 0),
            child: Scaffold(
              backgroundColor: Colors.white,
            )
        );
      },
    );
  }
}
