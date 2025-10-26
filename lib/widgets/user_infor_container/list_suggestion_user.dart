import 'package:flutter/material.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/user_infor_container/user_suggested_infor.dart';

class ListSuggestionUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return SizedBox(
      height: 190,
      width: specs.screenWidth,
      child: ListView(
        padding: EdgeInsets.only(top: 15, left: 20, bottom: 15),
        scrollDirection: Axis.horizontal,
        children: [
          UserSuggestedInfor(),
          SizedBox(
            width: 15,
          ),
          UserSuggestedInfor(),
          SizedBox(
            width: 15,
          ),
          UserSuggestedInfor(),
        ],
      ),
    );
  }
}
