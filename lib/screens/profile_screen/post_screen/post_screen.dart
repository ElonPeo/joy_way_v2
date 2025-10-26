import 'package:flutter/material.dart';
import 'package:joy_way/config/general_specifications.dart';


import 'basic_statistics.dart';




class PostScreen extends StatelessWidget {
  const PostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BasicStatistics(),
        Container(
          height: 160,
          width: specs.screenWidth,
          decoration: BoxDecoration(
            color: Colors.white
          ),
        ),
        SizedBox(
          height: specs.screenHeight * 0.3,
        )
      ]
    );
  }
}

