import 'package:flutter/material.dart';
import 'package:joy_way/config/general_specifications.dart';


import 'basic_statistics.dart';




class PostScreen extends StatelessWidget {
  final bool isOwnerProfile;
  final String? userId;

  const PostScreen({
    super.key,
    required this.isOwnerProfile,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BasicStatistics(
          isOwnerProfile: isOwnerProfile,
          userId: userId,
        ),
        Container(
          height: 160,
          width: specs.screenWidth,
          decoration: const BoxDecoration(
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

